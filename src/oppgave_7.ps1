[CmdletBinding()]
param (
    # parameter er ikke obligatorisk siden vi har default verdi
    [Parameter(HelpMessage = "URL til kortstokk", Mandatory = $false)]
    [string]
    # når paramater ikke er gitt brukes default verdi
    $UrlKortstokk = 'http://nav-deckofcards.herokuapp.com/shuffle'
)
try {
        $webRequest = Invoke-WebRequest -Uri $UrlKortstokk
            }
catch   { 
            Write-Output "Den Url'en finnes ikke: $UrlKortstokk :-("
            exit
        }
$kortstokkJson = $webRequest.Content
try {
    $kortstokk = ConvertFrom-Json -InputObject $kortstokkJson
    }
    catch { 
        Write-Output "Den URL'en har ingen kortstokk :-( "
        exit
    }
function kortstokkTilStreng {
    [OutputType([string])]
    param (
        [object[]]
        $kortstokk
    )
    $streng = ""
        foreach ($kort in $kortstokk) {
            $streng = $streng + "$($kort.suit[0])$($kort.value),"
       
        }
        $streng = $streng.Substring(0,$streng.Length-1)
        return $streng
}

function sumPoengKortstokk {
    [OutputType([int])]
    param (
        [object[]]
        $kortstokk
    )

    $poengKortstokk = 0

    foreach ($kort in $kortstokk) {
        # Undersøk hva en Switch er
        $poengKortstokk += switch ($kort.value) {
            { $_ -cin @('J','K','Q') } { 10 }
            { $_ -cin @('A')} { 11 }
            default { $kort.value }
        }
    }
    return $poengKortstokk
}

Write-Output "Kortstokk: $(kortStokkTilStreng -kortstokk $kortstokk)"
Write-Output "Poengsum: $(sumPoengKortstokk -kortstokk $kortstokk)"

$meg = $kortstokk[0..1]
Write-Output "meg: $(kortstokkTilStreng $meg)"
$kortstokk = $kortstokk[2..$kortstokk.Count]
$magnus = $kortstokk[0..1]
Write-Output "magnus: $(kortstokkTilStreng $magnus)"
$kortstokk = $kortstokk[2..$kortstokk.Count]
# Write-Output "Kortstokk:  $(kortstokkTilStreng $kortstokk)"

function skrivUtResultat {
    param (
        [string]
        $vinner,        
        [object[]]
        $kortStokkMagnus,
        [object[]]
        $kortStokkMeg        
    )
    Write-Output "Vinner: $vinner"
    Write-Output "magnus | $(sumPoengKortstokk -kortstokk $kortStokkMagnus) | $(kortstokkTilStreng -kortstokk $kortStokkMagnus)"    
    Write-Output "meg    | $(sumPoengKortstokk -kortstokk $kortStokkMeg) | $(kortstokkTilStreng -kortstokk $kortStokkMeg)"
}

# bruker 'blackjack' som et begrep - er 21
$blackjack = 21

if (((sumPoengKortstokk -kortstokk $meg) -eq $blackjack ) -AND ((sumPoengKortstokk -kortstokk $magnus) -eq $blackjack)) {
    skrivUtResultat -vinner "draw" -kortStokkMagnus $magnus -kortStokkMeg $meg
    exit
}
elseif ((sumPoengKortstokk -kortstokk $magnus) -eq $blackjack ) {
    skrivUtResultat -vinner "magnus" -kortStokkMagnus $magnus -kortStokkMeg $meg
    exit
}
elseif ((sumPoengKortstokk -kortstokk  $meg) -eq $blackjack ) {
    skrivUtResultat -vinner "meg" -kortStokkMagnus $magnus -kortStokkMeg $meg
    exit
}