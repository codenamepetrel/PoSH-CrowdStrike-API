#Pete Lenhart - 4/13/2023
#Submit URL to CrowdStrike Sandbox

[CmdletBinding()]

Param
(
    
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$actionScript,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$envID,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$submitName,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$suspectURL,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$userTag
)
BEGIN {

    try {
        . (".\Classes\falconapihelper.ps1")
        }
    catch {
        Write-Host "Error while loading supporting PowerShell Scripts" 
        Break
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
PROCESS{

    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36"
    Invoke-WebRequest -UseBasicParsing -Uri "https://api.crowdstrike.com/falconx/entities/submissions/v1" `
        -Method "POST" `
        -WebSession $session `
        -Headers @{
            "Accept-Encoding"="gzip, deflate, br"
            "Accept-Language"="en-US,en;q=0.5"
            "accept"="application/json"
            "authorization"="Bearer $token"
  
} `
-ContentType "application/json" `
-Body ([System.Text.Encoding]::UTF8.GetBytes("{$([char]10)  `"sandbox`": [$([char]10)    {$([char]10)      `" `
action_script`": `"default`",$([char]10)      `"enable_tor`": true,$([char]10)      `"environment_id`": $envID,$([char]10)      `" `
network_settings`": `"tor`",$([char]10)      `"submit_name`": `"$submitName`",$([char]10)       `" `
url`": `"$suspectURL`"$([char]10)    }$([char]10)  ],$([char]10)  `"send_email_notification`": true,$([char]10)  `" `
user_tags`": [$([char]10)    `"$userTag`"$([char]10)  ]$([char]10)}"))
}
END{

    Write-Output "The URL is being investigated."
    
}
