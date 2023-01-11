
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
		'Dienstanhalten',
        'Netzwerktest'
	)
	
	$s = 0
	
	foreach ( $node in $auswahl )
	{	
   		Write-Host "[$s]: [$node]"
		$s = $s+1
	}

    
}

function Get-Input{
        param($input)
    
}


menue
$input = Read-Host "Eingabe tätigen "

    

