# Skript zum bereinigen der Log-Files im IIS
# Stannek GmbH - Version 1.1 - 24.05.2024 - E.Sauerbier

# Parameter
$DaysafterDelete = "14" # ab welchem Alter (Tagen) Log-Files entfernt werden


# Module importieren
import-module webadministration

# Loeschdatum festlegen
$DaysafterDelete = (get-date).adddays(-$DaysafterDelete)

# Webseiten auslesen
$websites = get-website

# Logfile-Pfad pro Webseite auslesen
foreach ($website in $websites)
    {
    # Log-Pfad fuer aktuelle Webseite auslesen
    $PathLogFile = $website.logfile.directory
    # Falls im Log-Pfad eine Systemvariable stehen sollte, wird diese angepasst
    if ($PathLogFile -match "%SystemDrive%") {$PathLogFile  = $PathLogFile  -replace "%SystemDrive%",$env:SystemDrive}
    # Dateien auslesen, die entfernt werden sollen
    $LogFileList = Get-ChildItem $PathLogFile -Recurse | Where-Object {! $_.PSIsContainer -and $_.lastwritetime -lt $DaysafterDelete} | Select-Object fullname
    # Dateien entfernen
    foreach ($LogFile in $LogFileList) {Remove-Item $LogFile.fullname}
}
