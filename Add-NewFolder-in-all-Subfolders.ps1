# Skript zum anlegen eines Ordner in alle Unterordner
# Stannek GmbH - v.1.0 - 17.10.2024 - E.Sauerbier

# Parameter
$PathRoot = "E:\HOME"  
$NameFolder = "Aufzeichnungen"  

# Unterorder in Root-Pfad auslesen
$PathSubfolders = Get-ChildItem -path $PathRoot | Where-Object { $_.PSIsContainer }

# Ordner in allen Unterordner anlegen
$PathSubfolders | ForEach-Object {
    Write-host $_.FullName
    New-Item ($_.FullName+"\$NameFolder") -type directory    
    }