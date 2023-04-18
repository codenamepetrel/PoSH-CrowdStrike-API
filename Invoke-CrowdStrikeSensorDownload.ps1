##############################################################################
#                                                                            #
# Pete Lenhart                                                               #
# Download CrowdStrike sensor.                                               #
# You need to get the Sensor Version ID for $sensorID                        #
# Add your API key and Secret
##############################################################################


[CmdletBinding()]
Param
(
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$clientid = "X",
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$seecret = "X"
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$sensorID = "X"
)
BEGIN {

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
    
}
PROCESS {

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36"
Invoke-WebRequest -UseBasicParsing -Uri "https://api.crowdstrike.com/sensors/entities/download-installer/v1?id=$sensorID" `
-WebSession $session `
-Headers @{
  "Accept-Encoding"="gzip, deflate, br"
  "Accept-Language"="en-US,en;q=0.8"
  "accept"="application/json"
  "authorization"="Bearer $token" 
}
}
END {}
