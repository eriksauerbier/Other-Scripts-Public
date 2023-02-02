# Diese Skript loescht Dateien in einem Verzeichnis, die aelter als X-Tage sind
# Stannek GmbH - v.2.0 - 02.02.2023 - E.Sauerbier

# Parameter
$Olderthan = "60"
$Path = "Pfad"

# Loeschdatum ermitteln
$Olderthan = (Get-date).AddDays(-$Olderthan)

# Dateien ermitteln und loeschen
Get-Childitem -Path $Path -recurse | Where-Object {$_.lastwritetime -lt $Olderthan -and -not $_.psiscontainer} | ForEach-Object {Remove-Item -Path $_.fullname -Force -Verbose}

# Ordner ermitteln und loeschen, ausser Ordner mit Archiv-Attribut
Get-Childitem -Path $Path -recurse | Where-Object {($_.lastwritetime -lt $Olderthan) -and ($_.Mode -ne "da----")} | ForEach-Object {Remove-Item -Path $_.fullname -Recurse -Force -Verbose}