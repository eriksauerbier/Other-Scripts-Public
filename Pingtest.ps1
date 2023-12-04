#Skript zum dauerhaften Pingen eines Hosts, protokolliert die Fehler unter $LogPath
#V1.0  23.11.2023  Stannek GmbH  N.Kohlmann

$PC = "192.168.10.124"
$LogPath = "C:\test\ping.log"

while($true) {
    try {

        test-connection $PC -count 1 -ErrorAction Stop

    }

    catch {

        out-file  -filepath $LogPath -InputObject "Computer $($PC) nicht erreichbar: $(get-date)" -append  
    }
    Start-Sleep -Seconds 1
}