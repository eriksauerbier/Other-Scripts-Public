# Skript zum hinterlegen eines Transfer Laufwerks
# Stannek GmbH - E.Sauerbier - v.1.0 - 09.11.2026

# Parameter
$ShareServer = "xxx.xxx.xxx.xxx"
$PathShare = "\\xxx.xxx.xxx.xxx\TRANSFER"
$DriveLetter = "R"
$User = "xxx\tsX"

# Credentials aus Credentialsstore
$wincred = cmdkey /list:$ShareServer

# Abfrage ob die Credentials evtl. schon gespeichert sind
if($wincred -eq "* Keine *"){
    # Credentials abfragen
    $Cred = Get-Credential -UserName $User -Message "Bitte Anmeldedaten angeben"
    # Passwort fuer cmdkey konvertieren
    $Cred = [System.Net.NetworkCredential]::new("",$Cred.Password).Password
    cmdkey /add:$ShareServer /user:$User /pass:$Cred
    Read-Host "Die Anmeldedaten wurde hinterlegt"
	}
Else {Write-Host "Anmeldedaten bereits hinterlegt"}

# Laufwerk verbinden
New-PSDrive -Name $DriveLetter -Root $PathShare -PSProvider FileSystem -Persist -Scope Local -ErrorVariable PSDriveError