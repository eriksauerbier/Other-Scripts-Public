# Skript zum erstellen bzw. Anpassen eine Neustarttasks
# Stannek GmbH - Version 1.0 - 29.12.2022 ES

# Parameter
$TaskName = "einmaliger Neustart"

# Assemblys laden
Add-Type -AssemblyName System.Windows.Forms

## Abfrage Fenster ##

# Hauptfenster
$mainForm = New-Object System.Windows.Forms.Form
$font = New-Object System.Drawing.Font("Arial", 11)
$mainForm.Text = "Neustart-Task planen"
$mainForm.Font = $font
$mainForm.ForeColor = "Black"
$mainForm.BackColor = "White"
$mainForm.Width = 300
$mainForm.Height = 200

# Description Label
$DescriptLabel = New-Object System.Windows.Forms.Label
$DescriptLabel.Text = "Wann soll der Computer neustarten?"
$DescriptLabel.Location = "15, 10"
$DescriptLabel.Height = 22
$DescriptLabel.Width = 280
$mainForm.Controls.Add($DescriptLabel)


#DatePicker Label
$datePickerLabel = New-Object System.Windows.Forms.Label
$datePickerLabel.Text = "Datum"
$datePickerLabel.Location = "15, 45"
$datePickerLabel.Height = 22
$datePickerLabel.Width = 90
$mainForm.Controls.Add($datePickerLabel)

#TimePicker Label
$TimePickerLabel = New-Object System.Windows.Forms.Label
$TimePickerLabel.Text = "Uhrzeit"
$TimePickerLabel.Location = "15, 80"
$TimePickerLabel.Height = 22
$TimePickerLabel.Width = 90
$mainForm.Controls.Add($TimePickerLabel)

#DatePicker-Feld
$datePicker = New-Object System.Windows.Forms.DateTimePicker
$datePicker.Location = "110, 42"
$datePicker.Width = "150"
$datePicker.Format = [windows.forms.datetimepickerFormat]::custom
$datePicker.CustomFormat = "dd/MM/yyyy"
$mainForm.Controls.Add($datePicker)

#TimePicker-Feld
$TimePicker = New-Object System.Windows.Forms.DateTimePicker
$TimePicker.Location = "110, 77"
$TimePicker.Width = "150"
$TimePicker.Format = [windows.forms.datetimepickerFormat]::custom
$TimePicker.CustomFormat = "HH:mm"
$TimePicker.ShowUpDown = $TRUE
$mainForm.Controls.Add($TimePicker)

#OK Button
$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = "15, 130"
$okButton.ForeColor = "Black"
$okButton.BackColor = "White"
$okButton.Text = "OK"
$okButton.add_Click({$mainForm.close()})
$mainForm.Controls.Add($okButton)

#Fensterausgabe
[void] $mainForm.ShowDialog()

## Ende Abfrage Fenster ##


# Datum und Uhrzeit aus Abfrage für Task aufbereiten
$TaskDatetrigger = Get-Date -Date $datePicker.Value.Date -Hour $TimePicker.Value.TimeOfDay.Hours -Minute $TimePicker.Value.TimeOfDay.Minutes

# Erstelle Task oder passe vorhanden Task an

# TaskTrigger Zeit setzen
$TaskTrigger = New-ScheduledTaskTrigger -At $TaskDatetrigger -Once


If ((Get-ScheduledTask -TaskName $Taskname -ErrorAction SilentlyContinue).TaskName -eq $TaskName) 
    {# Setzt den neue Tasktrigger
    Set-ScheduledTask -TaskName $Taskname -Trigger $TaskTrigger
    }
Else
    {# Erstellt Neustart Task, da keiner vorhanden ist
    $TaskAction = New-ScheduledTaskAction -Execute "shutdown.exe" -Argument "/r /f /t 5"
    $TaskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit 00:15:00
    $TaskSettings.StartWhenAvailable = $false
    $TaskPrincipal = New-ScheduledTaskPrincipal -UserId $(Get-WMIObject -class Win32_ComputerSystem | select UserName).username -RunLevel Highest -LogonType Interactive
    Register-ScheduledTask -Action $TaskAction -Trigger $TaskTrigger -Settings $TaskSettings -Principal $TaskPrincipal -TaskName $TaskName -Description "Führt einen Neustart des Computers zu einer festgelegten Zeit aus"
    }