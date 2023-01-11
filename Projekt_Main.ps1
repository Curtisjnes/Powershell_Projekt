
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
      
      if($input -eq "3"){
        Write-Host "hello"
      }else{
        Write-Host "HALLO"
      }

    
}

menue
$input = Read-Host "Eingabe tätigen"
Get-Input($input)

    

