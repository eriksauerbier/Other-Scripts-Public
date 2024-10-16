# Skript zum taeglichen abmelden von Konsolen Benutzern
# Stannek GmbH - v.1.0 - 07.10.2024 - E.Sauerbier

# Parameter 
$WorkPath = If($PSISE){Split-Path -Path $psISE.CurrentFile.FullPath}else{Split-Path -Path $MyInvocation.MyCommand.Path}
$PathScripts = Join-Path -Path $env:systemdrive -ChildPath "Skripte"
$PathTask = "\Stannek GmbH"
$TaskName = "Daily Logoff ConsuleUser"
$TaskStartTime = "1am"
$TaskDescription = "Task zum täglichen abmelden von Konsolensitzungen"
$NameScript = "LogOff-ConsoleUser-daily.ps1"
$NameProcess = "ToControl" # Dieser Prozess wird das abmelden verhindern

# Assembly fuer Hinweisboxen laden
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

# Task pruefen und ggf. anlegen
If (!(Get-ScheduledTask | Where-Object {$_.TaskName -eq $TaskName})) {
            # Checken ob Skript im richtigen Pfad liegt
            if (!(Test-Path $(Join-Path -Path $PathScripts -ChildPath $NameScript))){
            $MBmsg = "Das Skript für den Task liegt nicht unter $PathScripts"
            $MBheader = "Das Skript für den Task fehlt" 
            $MBicon = [System.Windows.Forms.MessageBoxIcon]::Warning
            $MBbuttons = "0"
            [System.Windows.Forms.Messagebox]::Show($MBmsg,$MBheader,$MBbuttons,$MBicon)
            break
            }
            
            Write-Host "Task nicht vorhanden, wird nun angelegt"
            $TaskTrigger = New-ScheduledTaskTrigger -Daily -At $TaskStartTime
            $TaskActionArgument = "-Executionpolicy Bypass -File $(Join-Path -Path $PathScripts -ChildPath $NameScript)"
            $TaskUser = "NT Authority\SYSTEM"
            $TaskAction = New-ScheduledTaskAction -WorkingDirectory $PathScripts -Execute "powershell.exe" -Argument $TaskActionArgument
            $TaskConf = New-ScheduledTaskSettingsSet -DontStopIfGoingOnBatteries -AllowStartIfOnBatteries -ExecutionTimeLimit (New-TimeSpan -Minutes 15)
            Register-ScheduledTask -Trigger $TaskTrigger -TaskName $TaskName -Settings $TaskConf -TaskPath $PathTask -Action $TaskAction -Description $TaskDescription -User $TaskUser -Verbose
            }
Else {# Konsolen User abmelden, wenn ein bestimmter Prozess nicht laueft
      If (!(Get-Process -Name $NameProcess -ErrorAction SilentlyContinue)) {
            # Konsolen Sitzung abmelden
            logoff console
            }
      }