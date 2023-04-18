#####################################################################################################
#                                                                                                   #
#                                                                                                   #
#                           Pete Lenhart - 4/14/2023                                                #
#                           Crowdstrike API - Get Logins for Host                                   # 
#                                                                                                   #
#####################################################################################################

[CmdletBinding()]

Param
(
    #[Parameter(Mandatory = $false)]
    #[ValidateNotNullOrEmpty()]
    #[string]$clientid,
    #[Parameter(Mandatory = $false)]
    #[ValidateNotNullOrEmpty()]
    #[string]$seecret,
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$hostname
    #[Parameter(Mandatory = $false)]
    #[ValidateNotNullOrEmpty()]
    #[string]$aid      
)
BEGIN {
    try {
        . (".\Classes\APIHelperClass.psm1")
        }
    catch {
        Write-Host "Error while loading supporting PowerShell Scripts" 
        }

    #$myAPICreds.GetAPIInfo()
    $myID = $myAPICreds.apiKey
    $mySec = $myAPICreds.apiSeecret

    $crowdStrikeSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $crowdStrikeResponse = Invoke-WebRequest -UseBasicParsing -Uri "https://api.crowdstrike.com/oauth2/token" `
        -Method "POST" `
        -WebSession $crowdStrikeSession `
        -Headers @{
        "Accept-Encoding" = "gzip, deflate, br"
        "Accept-Language" = "en-US,en;q=0.5"
        "accept"          = "application/json"
    } `
        -ContentType "application/x-www-form-urlencoded" `
        -Body "client_id=$myID&client_secret=$mySec"

    #GET THE BEARER TOKEN AND PASS IT TO THE NEXT CALL
    $tokenRespJSON = ConvertFrom-Json $crowdStrikeResponse.Content
    $tokingBearer = $tokenRespJSON.token_type
    $token = $tokenRespJSON.access_token
    #$token
}
PROCESS {
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36"
    $a = Invoke-RestMethod -UseBasicParsing -Uri "https://api.crowdstrike.com/devices/queries/devices/v1?filter=hostname%3A%22$hostname%22" `
        -WebSession $session `
        -Headers @{
        "Accept-Encoding"="gzip, deflate, br"
        "Accept-Language"="en-US,en;q=0.8"
        "accept"="application/json"
        "authorization"="Bearer $token"
  } 
$aid = $a.resources
}
END {
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36"
$getContent = Invoke-RestMethod -UseBasicParsing -Uri "https://api.crowdstrike.com/devices/combined/devices/login-history/v1" `
-Method "POST" `
-WebSession $session `
-Headers @{
"Accept-Encoding"="gzip, deflate, br"
"Accept-Language"="en-US,en;q=0.8"
"accept"="application/json"
"authorization"="Bearer $token"  
} `
-ContentType "application/json" `
-Body ([System.Text.Encoding]::UTF8.GetBytes("{$([char]10)  `"ids`": [$([char]10)    `"$aid`"$([char]10)  ]$([char]10)}"))
$recentLogins = $getContent.resources
$recentLogins.recent_logins
}
