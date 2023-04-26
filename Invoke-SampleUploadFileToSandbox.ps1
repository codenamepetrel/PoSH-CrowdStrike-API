#####################################################################################################
#                                                                                                   #
#                                                                                                   #
#                           Pete Lenhart - 4/26/2023                                                #
#                           Crowdstrike API - Submit Malware sample to CRowdStrike Sandbox          # 
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
    [string]$uploadfilename
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

    #Submit the file to the CrowdStrike Sandbox
    
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36"
        Invoke-WebRequest -UseBasicParsing -Uri "https://api.crowdstrike.com/samples/entities/samples/v2" `
        -Method "POST" `
        -WebSession $session `
        -Headers @{
        "Accept-Encoding"="gzip, deflate, br"
        "Accept-Language"="en-US,en;q=0.5"  
        "accept"="application/json"
        "authorization"="Bearer $token"
 
} `
    -ContentType "multipart/form-data; boundary=----WebKitFormBoundaryUTX8mQoeFJlrnQCk" `
    -Body ([System.Text.Encoding]::UTF8.GetBytes("------WebKitFormBoundaryUTX8mQoeFJlrnQCk$([char]13)$([char]10) `
        Content-Disposition: form-data; name=`"sample`"; filename=`"$uploadfilename`"$([char]13)$([char]10) `
        Content-Type: application/x-msdownload$([char]13)$([char]10)$([char]13)$([char]10)$([char]13)$([char]10)------WebKitFormBoundaryUTX8mQoeFJlrnQCk$([char]13)$([char]10) `
        Content-Disposition: form-data; name=`"file_name`"$([char]13)$([char]10)$([char]13)$([char]10)$uploadfilename$([char]13)$([char]10)------WebKitFormBoundaryUTX8mQoeFJlrnQCk$([char]13)$([char]10) `
        Content-Disposition: form-data; name=`"comment`"$([char]13)$([char]10)$([char]13)$([char]10)Download file$([char]13)$([char]10)------WebKitFormBoundaryUTX8mQoeFJlrnQCk$([char]13)$([char]10) `
        Content-Disposition: form-data; name=`"is_confidential`"$([char]13)$([char]10)$([char]13)$([char]10)true$([char]13)$([char]10)------WebKitFormBoundaryUTX8mQoeFJlrnQCk--$([char]13)$([char]10)"))
}
END{

    Write-Output "The dishes are done man."
    
}
