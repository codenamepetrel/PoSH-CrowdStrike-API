#####################################################################################################
#                                                                                                   #
#                                                                                                   #
#                           Pete Lenhart - 4/14/2023                                                #
#                           Crowdstrike API - Get Details about host from CrowdStrike               # 
#                                                                                                   #
#####################################################################################################


[CmdletBinding()]

Param
(
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$hostname,
    )
BEGIN {
    try {
        . (".\Powershell\Classes\APIHelper.ps1")
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
END{
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36"
$results = Invoke-RestMethod -UseBasicParsing -Uri "https://api.crowdstrike.com/devices/entities/devices/v2?ids=$aid" `
-WebSession $session `
-Headers @{
"Accept-Encoding"="gzip, deflate, br"
  "Accept-Language"="en-US,en;q=0.6"
  "accept"="application/json"
  "authorization"="Bearer $token"
}

Write-Output ""
Write-Output "<<<<<<<<< Host Information >>>>>>>>"
Write-Output ""
$endResults = $results.resources
Write-Output ("Hostname:         " + ($endResults.Hostname))
Write-Output ("Node Type:        " + ($endResults.chassis_type_desc))
Write-Output ("Operating System: " + ($endResults.os_product_name))
Write-Output ("OS Kernel Ver:    " + ($endResults.kernel_version))
Write-Output ("External IP:      " + ($endResults.external_ip))
Write-Output ("Local IP:         " + ($endResults.local_ip))
Write-Output ("Gateway IP:       " + ($endResults.default_gateway_ip))
Write-Output ("Domain Joined:    " + ($endResults.machine_domain))
Write-Output ("OU:               " + ($endResults.ou))
Write-Output ("System Brand:     " + ($endResults.system_manufacturer))
Write-Output ("System Model:     " + ($endResults.system_product_name ))
Write-Output ""
Write-Output "<<<<<<<<< CrowdStrike Info >>>>>>>>>"
Write-Output ""
Write-Output ("CS AID:           " + ($endResults.device_id))
Write-Output ("CS Agent Version: " + ($endResults.agent_version))
Write-Output ("CS First Seen:    " + ($endResults.first_seen))
Write-Output ("CS Last Seen:     " + ($endResults.last_seen))
Write-Output ("CS Tags:          " + ($endResults.tags))
}
