# Skript zum entfernen des Internet-Flags auf Dateien
# Stannek GmbH - v.1.0 - 17.10.2024 - E.Sauerbier

# Parameter
$PathRoot = "C:\"  

# Unterorder in Root-Pfad auslesen
$Files = Get-ChildItem -Path $PathRoot -Recurse -File

# Ordner in allen Unterordner anlegen
$Files | ForEach-Object {
    Write-host $_.FullName
    Unblock-File -Path $_.FullName -Verbose
    }