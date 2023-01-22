# Array mit Menue Optionen
$options = 
    @(
    "Alle Dienste anzeigen", 
    "Alle laufende Dienste anzeigen",
    "Alle nicht laufenden Dienste anzeigen",
    "Dienst starten",
    "Dienst stoppen",
    "Dienst neustarten",
    "Alle Nutzer anzeigen",
    "Neuen Nutzer anlegen",
    "Nutzer loeschen NO CONFIRMATION!!!",
    "Nutzer aus Datein anlegen",
    "Nutzer aus Datei loeschen NO CONFIRMATION!!!",
    "Pingtest",
    "Traceroute",
    "Exit")

# Variable, die die Do-While schleife unterbricht
$continue = $true

# While loop, welcher ausgegeben wird bis ihn jemand mithilfe einer Menue-Option beendet
while ($continue) {

    # Ausgabe der Menue-Optionen
    Write-Host ""
    for ($i = 0; $i -lt $options.Length; $i++) {
        Write-Host "[$($i + 1)] `t$($options[$i])"
    }
    Write-Host ""

    # Eingabeaufforderung an den User
    $choice = Read-Host "Choose an option (1-$($options.Length))"

    # Switch Statement, welche dann den zu der Menue-Option gehörigen Code ausfuehrt
    switch ($choice) {
    
    # Option 1: Alle Dienste anzeigen    
        {$_ -eq "1"} {Write-Host "You chose $($options[0])"; Get-Service}
      
    # Option 2: Alle laufenden Dienste anzeigen
        {$_ -eq "2"} {Write-Host "You chose $($options[1])"; Get-Service | Where-Object {$_.Status -eq "Running"}}
        
    # Option 3: Alle nicht laufenden Dienste anzeigen
        {$_ -eq "3"} {Write-Host "You chose $($options[2])"; Get-Service | Where-Object {$_.Status -eq "Stopped"}}
        
    # Option 4: Dienst starten    
        {$_ -eq "4"} {Write-Host "You chose $($options[3])"
            try {
                $serviceName = Read-Host "Please enter the service name you wish to start"
                $service = Get-Service $serviceName -ErrorAction SilentlyContinue
                if ($service -ne $null) {
                    if ($service.status -eq "stopped") {
                        Start-Service $serviceName
                    } else {
                        Write-Host "The service is already running"
                    }
                } else {
                    Write-Host "The service does not exist"
                }
            } catch {
                Write-Host "Error: $($_.Exception.Message)"
            }
        }
        
    # Option 5: Dienst stoppen
        {$_ -eq "5"} {Write-Host "You chose $($options[4])"
            try {    
                $serviceName = Read-Host "Please enter the service name you wish to stop"
                $service = Get-Service $serviceName -ErrorAction SilentlyContinue
                if ($service -ne $null) {
                    if ($service.status -eq "running") {
                    
                        if ($service.status -eq "Running" -and $service.DependentServices.Count -gt 0) {
                            $response = Read-Host "The service has dependent services, do you want to stop it with force option (Y/N)?"
                            if ($response -eq "Y" -or $response -eq "y") {
                                Stop-Service $serviceName -Force
                            }
                        } else {
                            Stop-Service $serviceName
                        }

                    } else {
                        Write-Host "The service is not running"
                    }
                } else {
                    Write-Host "The service does not exist"
                }
            } catch {
                Write-Host "Error: $($_.Exception.Message)"
            }
        }
        
    # Option 6: Dienst neustarten
        {$_ -eq "6"} {Write-Host "You chose $($options[5])"
            try {
                $serviceName = Read-Host "Please enter the service name you wish to restart"
                $service = Get-Service $serviceName -ErrorAction SilentlyContinue
                if ($service -ne $null) {
                    if ($service.status -eq "Running" -and $service.DependentServices.Count -gt 0) {
                        $response = Read-Host "The service has dependent services, do you want to restart it (Y/N)?"
                        if ($response -eq "Y" -or $response -eq "y") {
                            Stop-Service $serviceName -Force
                            Start-Service $serviceName
                        }
                    } else {
                        Stop-Service $serviceName
                        Start-Service $serviceName
                    }
                } else {
                    Write-Host "The service does not exist"
                }
            } catch {
                Write-Host "Error: $($_.Exception.Message)"
            }
        }
        
    # Option 7: Alle Nutzer anzeigen
        {$_ -eq "7"} {Write-Host "You chose $($options[6])"; Get-LocalUser}

    # Option 8: Neuen Nutzer anlegen    
        {$_ -eq "8"} {Write-Host "You chose $($options[7])"
            $username = Read-Host "Please enter username"
            $user = Get-LocalUser -Name $username -ErrorAction SilentlyContinue
            if ($user -eq $null) {
                
                # Windows User anlegen
                $password = Read-Host "Please enter password"
                $fullName = Read-Host "Please enter full name"
                $description = Read-Host "Please enter description"
                New-LocalUser -Name $username -Password (ConvertTo-SecureString $password -AsPlainText -Force) -FullName $fullName -Description $description
                Add-LocalGroupMember -Group "Benutzer" -Member $username

                # Datenbank fuer User anlegen
                & 'C:\xampp\mysql\bin\mysql.exe' -u root -p -e "CREATE DATABASE $username; GRANT ALL PRIVILEGES ON $username.* TO '$username'@'localhost' IDENTIFIED BY '$password';"
            
                # Apache Webspace fuer User anlegen

            } else {
                Write-Host "User $username already exists"
            }
        }

    # Option 9:  Nutzer loeschen
        {$_ -eq "9"} {Write-Host "You chose $($options[8])"
            $username = Read-Host "Please enter username"
            $user = Get-LocalUser -Name $username -ErrorAction SilentlyContinue
            if($user -ne $null) {
                
                # Windows User loeschen
                Remove-LocalUser -Name $username -Confirm:$false

                # MySQL User & Datenbank loeschen
                Invoke-Sqlcmd -ServerInstance "Localost" -Database $username + "@localhost" -Query "DROP USER [Username]"

                # Apache Webspace loeschen


            } else {
                Write-Host "User $username does not exist"
            }
        }

    # Option 10: Nutzer aus Datei anlegen
        {$_ -eq "10"} {Write-Host "You chose $($options[9])"
           #Abfrage nach Dateipfad
           $path = Read-Host "Please enter the path of your csv doc"
           
           #Datei wird in einer Variable gespeichert
           $csv = Import-Csv -Path $path -Delimiter ";"
           
           #es wird ein Array Instanziiert, welcher später alle User-Daten speichern soll
           $users = @()

           #Jede Zeile der CSV-Datei wird eingelesen und in unterschiedlichen Parametern gespeichert, je nachdem in welche Spalte die Informationen stehen
           foreach ($line in $csv) {
            
            #Alles was in der Spalte Username steht wird in der username Variable gespeichert
            $username = $line.Username
            
            #Alles was in der Spalte Name steht wird in der name Variable gespeichert
            $name = $line.Name

            #Alles was in der Passwort spalte steht wird in der password Variable gespeichtert
            $password = $line.Passwort

            #Alles was in der Beschreibung steht wird in der description Variable gespeichert
            $description = $line.Beschreibung

            #Die Variablen werden dem Array zugewiesen
            $users += New-Object PSObject -Property @{
                'Username' = $username
                'Name' = $name
                'Password' = $password
                'Description' = $description
                }

                #Der Nutzer wird lokal angelegt, einer Nutzergruppe hinzugefügt und es wird im eine Datenbank zugewiesen
                Write-Host New-LocalUser -Name $users.Username -Password $users.Password -FullName $users.Name -Description $users.Description
                Write-Host Add-LocalGroupMember -Group "Benutzer" -Member $users.Username
                Write-Host 'C:\xampp\mysql\bin\mysql.exe' -u root -p -e "CREATE DATABASE $users.Username; GRANT ALL PRIVILEGES ON $users.Username .* TO '$users.Username'@'localhost' IDENTIFIED BY '$users.Password';"

            }

           
        
        
        }

    # Option 11: Nutzer aus Datei loeschen
        {$_ -eq "11"} {Write-Host "You chose $($options[10])"
            
            #Dateipfad der Liste abfragen
            $path = Read-Host "Please enter the path of your csv doc "
            
            #CSV-Datei wird eingelesen und in einer Variable gespeichert
            $ausgabe= Import-CSV -Path $path -Delimiter ";" 
            
            #Namen der Spalten werden in einer Variable gespeichert
            $spaltennamen = $ausgabe | gm -MemberType NoteProperty | select -Expand Name
                
                #fuer jede spalte wird überbprüft, ob es die spalte "Username" ist
                foreach($spaltennamen in $spaltennamen) {
                    
                    if ($spaltennamen -eq "Username") {
                        
                        $spalte = $ausgabe | select -ExpandProperty $spaltenname
                        
                        $usernames = $spalte -split " "
                        
                        Write-Host "Spaltenname: $spaltenname"
                        
                        #Jeder Spalteneintrag wird in einer Variable gespeichert, und überprüft,
                        #ob der Nutzername einem Nutzer auf dem Rechner entspricht
                        foreach ($username in $usernames) {
                        
                        $user = Get-LocalUser -Name $username -ErrorAction SilentlyContinue
                            if($user -ne $null) {
                                
                                #Ist der User vorhanden wird dieser lokal geloescht
                                Remove-LocalUser -Name $username -Confirm:$false

                                #Datenbank und MySql Nutzer werden geloescht
                                Invoke-Sqlcmd -ServerInstance "Localost" -Database $username + "@localhost" -Query "DROP USER [Username]"

                                #Apache Webspace wird beseitigt
       
                            }else{
                                
                                #Ist der User nicht vorhanden wird ein Fehler zurueckgegeben
                                Write-Host "Error: The User [$username] does not Exist"
                            }
                        }
                    }
                }
            }

    # Option 12: Ping Test
        {$_ -eq "12"} {Write-Host "You chose $($options[11])"
            
            #Es wird abgefragt welche Adresse gepingt werden soll
            $adresse = Read-Host "Please enter destination adress" 

            #Da man bei einem normalen Ping auch angeben kann wie oft eine Adresse gepingt werden soll, kann sich der User heir frei entscheiden, ist die Eingabe aber ungültig, wird ein Fehler ausgespuckt
            $count = Read-Host "Define how often you'd like to ping the adress ? "
            
            #Abfrage, ob die eingabe Valide ist
            if($count -gt 0){
                #Test-Connection wirft keine exception, deswegen benutzen wir das "-Quiet" Keyword, welches uns einen Booleanwert, ob die Verbindung erfolgreich war zurueckgibt
                $result = Test-Connection -Count $count -Quiet $adresse
                if(!$result){
                    Write-Host "Error: Unable to establish connection"
                }else{
                    #Ausgabe des Ping-Ergebnisses
                    Test-Connection -Count $count $adresse
                }
            }else{
                Write-Host "Invalid Input...Input must be greater than 0"
            }
        }

    # Option 13: Trace Route Test
        {$_ -eq "13"} {Write-Host "You chose $($options[12])"

            #Es wird abgefragt welche Adresse gepingt werden soll
            $adresse = Read-Host "Please enter destination adress"

            #Es wird ein Normaler Ping an die Adresse geschickt, wenn die Adresse erreichbar ist gibt der ping true zurück. Das Ergebnis des pings wird in einer Variable gespeichert
            $result = Test-Connection -Quiet $adresse
            
            #Wenn der Ping erfolgreich war wird der Traceroute-Ping gestartet, Ansonsten wird ein Fehler ausgegeben
            if(!$result){
                Write-Host "Error: Unable to establish connection"
            }else{
                Test-Netconnection $adresse -TraceRoute
            }
        }

    # Option 14: Exit
        {$_ -eq "14"} {Write-Host "Exiting..."; $continue = $false}
        default {Write-Host "Invalid choice. Please try again."}
    }
}
