

function Get-Input([String] $eingabe){
      
      switch($eingabe)
      {
            "0" {Exit 1}
            "1" {Benutzer-Anlegen}
            "2" {Benutzer-Loeschen}
            "3" {Benutzer-Bearbeiten}
            "4" {Mehrere-Benutzer-Anlegen}
            "5" {Mehrere-Benutzer-Loeschen}
            "6" {Dienste-Ausgeben}
            "7" {Dienst-Starten}
            "8" {Dienst-Anhalten}
            "9" {Netzwerktest}
      }

    
}

function Benutzer-Anlegen{

    $passwort = Read-Host "Passwort festlegen " -AsSecureString
    $Name = Read-Host "Einmal bitte den Vornamen des Users eingeben "
    $Nachname = Read-Host "Einmal bitte den Nachnamen des Users eingeben "
    
    Write-Host "New-LocalUser $Name -Password [$passwort] -FullName [$Name $Nachname] -Description CompleteVisibility"
     

}

function Benutzer-Loeschen(){
        
       Get-LocalUser | Select *
       $benutzer = Read-Host "Welchen Benutzer wollen Sie löschen? (Vollen Namen eingeben) "
       Remove-LocalUser -Name $benutzer


}

function Benutzer-Bearbeiten{
    
    Get-LocalUser | Select *
    $benutzer = Read-Host "Welchen Benutzer wollen Sie löschen? (Vollen Namen eingeben) "
    Edit-LocalUser -Name $benutzer

}

function Mehrere-Benutzer-Anlegen{

    $pfad = Read-Host "Bitte den Pfad der Datei hier reinkopieren "


}



function menue (){
	$auswahl = 
	@(
		'Beenden',
	 	'Benutzer anlegen',
		'Benutzer löschen',
	 	'Benutzer bearbeiten',
		'Mehrere Benutzer anlegen',
		'Mehrere Benutzer Löschen',
		'Dienste ausgeben',
		'Dienst starten',
		'Dienst anhalten',
        'Netzwerktest'
	)
	
	$s = 0
	
	foreach ( $node in $auswahl )
	{	
   		Write-Host "[$s]: [$node]"
		$s = $s+1
	}

    
}



menue
[String] $eingabe = Read-Host "Eingabe tätigen"
Write-Host $eingabe.GetType().Name
Get-Input -eingabe $eingabe 
    

