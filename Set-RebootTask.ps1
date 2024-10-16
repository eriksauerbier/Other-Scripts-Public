﻿# Skript zum erstellen bzw. Anpassen eine Neustarttasks
# Stannek GmbH - Version 1.4 - 16.10.2024 ES

# Diese Skript muss als Administrator ausgeführt werden, ansonsten wird es nicht gestartet
#Requires -RunAsAdministrator

# Parameter
$TaskName = "einmaliger Neustart"
$PathTask = "\Stannek GmbH"

# Assemblys laden
Add-Type -AssemblyName System.Windows.Forms

## Abfrage Fenster ##

# Erstellt das Hauptfenster
$font = New-Object System.Drawing.Font("Arial", 11)
$mainForm = New-Object System.Windows.Forms.Form
$mainForm.Text = "Neustart-Task planen"
$mainForm.Font = $font
$mainForm.ForeColor = "Black"
$mainForm.BackColor = "White"
$mainForm.Width = 300
$mainForm.Height = 200
$mainForm.StartPosition = "CenterScreen"
$mainForm.MaximizeBox = $False

# Erzeugt das Description Label
$DescriptLabel = New-Object System.Windows.Forms.Label
$DescriptLabel.Text = "Wann soll der Computer neustarten?"
$DescriptLabel.Location = "15, 10"
$DescriptLabel.Height = 22
$DescriptLabel.Width = 280
# Fügt Label zum Hauptfenster hinzu
$mainForm.Controls.Add($DescriptLabel)


# Rezeugt das DatePicker Label
$datePickerLabel = New-Object System.Windows.Forms.Label
$datePickerLabel.Text = "Datum"
$datePickerLabel.Location = "15, 45"
$datePickerLabel.Height = 22
$datePickerLabel.Width = 90
# Fügt Label zum Hauptfenster hinzu
$mainForm.Controls.Add($datePickerLabel)

# Erzeugt das TimePicker Label
$TimePickerLabel = New-Object System.Windows.Forms.Label
$TimePickerLabel.Text = "Uhrzeit"
$TimePickerLabel.Location = "15, 80"
$TimePickerLabel.Height = 22
$TimePickerLabel.Width = 90
# Fügt Label zum Hauptfenster hinzu
$mainForm.Controls.Add($TimePickerLabel)

# Erzeugt das DatePicker-Feld
$datePicker = New-Object System.Windows.Forms.DateTimePicker
$datePicker.Location = "110, 42"
$datePicker.Width = "150"
$datePicker.Format = [windows.forms.datetimepickerFormat]::custom
$datePicker.CustomFormat = "dd/MM/yyyy"
# Fügt DatePicker-Feld zum Hauptfenster hinzu
$mainForm.Controls.Add($datePicker)

# Erzeugt das TimePicker-Feld
$TimePicker = New-Object System.Windows.Forms.DateTimePicker
$TimePicker.Location = "110, 77"
$TimePicker.Width = "150"
$TimePicker.Format = [windows.forms.datetimepickerFormat]::custom
$TimePicker.CustomFormat = "HH:mm"
$TimePicker.ShowUpDown = $TRUE
# Fügt TimePicker-Feld zum Hauptfenster hinzu
$mainForm.Controls.Add($TimePicker)

# Erzeugt den OK Button
$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = "15, 130"
$okButton.ForeColor = "Black"
$okButton.BackColor = "White"
$okButton.Text = "OK"
# Legt die Button Aktion fest (DialogResult auf OK und Eingabefenster schließen
$okButton.add_Click({$mainForm.DialogResult = "OK";$mainForm.close()})
# Fügt Button zum Hauptfenster hinzu
$mainForm.Controls.Add($okButton)

# Fensterausgabe
[void] $mainForm.ShowDialog()

## Ende Abfrage Fenster ##

# Skript abbrechen, wenn Fenster geschlossen wird
If ($mainForm.DialogResult -eq "Cancel") {Break}

# Datum und Uhrzeit aus Abfrage für Task aufbereiten
$TaskDatetrigger = Get-Date -Date $datePicker.Value.Date -Hour $TimePicker.Value.TimeOfDay.Hours -Minute $TimePicker.Value.TimeOfDay.Minutes

# Erzeuge Task Einstellungen
$TaskAction = New-ScheduledTaskAction -Execute "shutdown.exe" -Argument "/r /f /t 5"
$TaskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit 00:15:00
$TaskSettings.StartWhenAvailable = $false
$TaskPrincipal = New-ScheduledTaskPrincipal -UserId $(Get-WMIObject -class Win32_ComputerSystem | select UserName).username -RunLevel Highest -LogonType Interactive
$TaskUser = "NT Authority\SYSTEM"

# Erstelle Task oder passe vorhanden Task an

# TaskTrigger Zeit setzen
$TaskTrigger = New-ScheduledTaskTrigger -At $TaskDatetrigger -Once

If (($(Get-ScheduledTask -TaskName $Taskname -ErrorAction SilentlyContinue).TaskName -eq $TaskName) -and ($(Get-ScheduledTask -TaskName $Taskname -ErrorAction SilentlyContinue).TaskPath -ne "\"))
    {# Setzt den neue Tasktrigger
    Set-ScheduledTask -TaskPath $PathTask -TaskName $Taskname -Trigger $TaskTrigger
    }
ElseIf ((Get-ScheduledTask -TaskName $Taskname -ErrorAction SilentlyContinue).TaskPath -eq "\") {
        # Entfernt den alten Task und erstellt einen neuen Task
        Get-ScheduledTask -TaskName $Taskname | Unregister-ScheduledTask -Confirm:$false
        Register-ScheduledTask -Action $TaskAction -Trigger $TaskTrigger -TaskPath $PathTask -Settings $TaskSettings -User $TaskUser -TaskName $TaskName -Description "Führt einen Neustart des Computers zu einer festgelegten Zeit aus"
        }
Else
    {# Erstellt Neustart Task, da keiner vorhanden ist
    Register-ScheduledTask -Action $TaskAction -Trigger $TaskTrigger -TaskPath $PathTask -Settings $TaskSettings -User $TaskUser -TaskName $TaskName -Description "Führt einen Neustart des Computers zu einer festgelegten Zeit aus"
    }

# Pruefe Task ob dieser deaktiviert ist
If ((Get-ScheduledTask -TaskName $Taskname).State -eq "Disabled") {Enable-ScheduledTask -TaskName $TaskName}
