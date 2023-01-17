# Create an array of menu options
$options = @(
        "Alle Dienste anzeigen", 
        "Alle laufende Dienste anzeigen", 
        "Alle nicht laufenden Dienste anzeigen", 
        "Dienst starten", 
        "Dienst stoppen", 
        "Dienst neustarten", 
        "Neuen Nutzer anlegen", 
        "Nutzer anzeigen",
        "Nutzer löschen", 
        "Nutzer aus Datein anlegen", 
        "Nutzer aus Datei löschen",
        "Netzwerktest", 
        "Exit"
        )

# Create a variable to track whether the menu should continue to run
$continue = $true

# Use a while loop to keep displaying the menu until the user chooses to exit
while ($continue) {
    # Display the menu options
    Write-Host ""

    $index = 1

    for ($i = 0; $i -lt $options.Length; $i++) {
        Write-Host "$("[" + $index + "]"):  `t$($options[$i])"
        $index++
    }

    # Ask the user to choose an option
    $choice = Read-Host "Choose an option (1-$($options.Length))"

    # Use a switch statement to determine what to do based on the user's choice
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

    # Option 7: Neuen Nutzer anlegen    
        {$_ -eq "7"} {Write-Host "You chose $($options[6])"
            $username = Read-Host "Please enter username"
            $password = Read-Host "Please enter password"
            $fullName = Read-Host "Please enter full name"
            $description = Read-Host "Please enter description"
            New-LocalUser -Name $username -Password (ConvertTo-SecureString $password -AsPlainText -Force) -FullName $fullName -Description $description
            Add-LocalGroupMember -Group "Benutzer" -Member $username

            & 'C:\xampp\mysql\bin\mysql.exe' -u root -p -e "CREATE DATABASE $username; GRANT ALL PRIVILEGES ON $username.* TO '$username'@'localhost' IDENTIFIED BY '$password';"
            
        }

    # Option 8: Nutzer anzeigen
        {$_ -eq "8"} {Write-Host "You chose $($options[7])"
        
            Write-Host Get-LocalUser -Name * 
        }

    # Option 9:  Nutzer löschen    
        {$_ -eq "9"} {Write-Host "You chose $($options[8])"
   
         $benutzer = Read-Host "Welchen Benutzer wollen Sie löschen? (Vollen Namen eingeben) " 
         
         Remove-LocalUser -Name $benutzer
        
        }

    # Option 10: Nutzer aus Datei anlegen    
        {$_ -eq "10"} {Write-Host "You chose $($options[9])"}

    # Option 11: Nutzer aus Datei löschen  
        {$_ -eq "11"} {Write-Host "You chose $($options[10])"}
    
    # Option 12: Netzwerktest
        {$_ -eq "12"} {Write-Host "You chose $($options[11])"
            $auswahl = Read-Host "Normal Ping or Traceroute ping 0/1"
            if($auswahl -eq "0"){
                Write-Host "You chose Normal Ping"          
                $adresse = Read-Host "Which Adress or Website do you want to ping ?" 
                $count = Read-Host "Define how often you'd like to ping the adress ? "  
                if($count -gt 0){
                    try{
                        #Test-Connection wirft keine exception, deswegen benutzen wir das "-Quiet" Keyword, welches uns einen Booleanwert, ob die Verbindung erfolgreich war zurückgibt
                        $result = Test-Connection -Count $count -Quiet $adresse
                        if(!$result){
                            Write-Host "Error: Unable to establish connection"
                            Start-Sleep -Seconds 2
                        }else{
                            Test-Connection -Count $count $adresse
                            Start-Sleep -Seconds 3
                        }
                    }catch{
                        Write-Host "Error: $($_.Exception.Message)"
                    }
                }else{   
                    Write-Host "Invalid Input...Input must be greater than 0"
                    Start-Sleep -Seconds 2
                }
            }elseif ($auswahl -eq "1"){
                Write-Host "You chose TraceRoute-Test"
                $adresse = Read-Host "Which Adress or Website do you want to ping ?"
                $result = Test-Connection -Quiet $adresse
                if(!$result){
                    Write-Host "Error: Unable to establish connection"
                    Start-Sleep -Seconds 2
                }else{
                    Test-Netconnection $adresse -TraceRoute
                    Start-Sleep -Seconds 3
                }
            }else{
                Write-Host "Invalid input only values 0 and 1 are accepted"
                Start-Sleep -Seconds 2
            }    
        }
    
    # Option 13: Exit
        {$_ -eq "13"} {Write-Host "Exiting..."; $continue = $false}
        default {Write-Host "Invalid choice. Please try again."}
    }
}
