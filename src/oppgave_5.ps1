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
    return $streng.Substring(0,$streng.Length-1)
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