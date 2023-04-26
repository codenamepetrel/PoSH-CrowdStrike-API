#####################################################################################################
#                                                                                                   #
#                                                                                                   #
#                           Pete Lenhart - 4/14/2023                                                #
#                           Crowdstrike API - Contain a host in CrowdStrike                         # 
#                                                                                                   #
#####################################################################################################


[CmdletBinding()]
Param
(
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$hostname,
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$aid,
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet("contain", "lift_containment")]
    [string]$action
)
BEGIN {
    try {
        . (".\Powershell\Classes\APIHelper.ps1")
        }
    catch {
        Write-Host "Error while loading supporting PowerShell Scripts" 
        }

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
        -Body "client_id=$clientid&client_secret=$seecret"

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

    $crowdStrikeSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $crowdStrikeResponse = Invoke-WebRequest -UseBasicParsing -Uri "https://api.crowdstrike.com/devices/entities/devices-actions/v2?action_name=$action" `
        -Method "POST" `
        -WebSession $crowdStrikeSession `
        -Headers @{
        "Accept-Encoding" = "gzip, deflate, br"
        "Accept-Language" = "en-US,en;q=0.6"
        "accept"          = "application/json"
        "authorization"   = "$tokingBearer $token"
    } `
        -ContentType "application/json" `
        -Body ([System.Text.Encoding]::UTF8.GetBytes("{$([char]10)  `"action_parameters`": [$([char]10)    {$([char]10)      `"name`": `"string`",$([char]10)      `"value`": `"string`"$([char]10)    }$([char]10)  ],$([char]10)  `"ids`": [$([char]10)    `"$aid`"$([char]10)  ]$([char]10)}"))
    
}
