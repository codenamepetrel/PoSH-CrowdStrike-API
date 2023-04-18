#Pete Lenhart
#4/18/2023
#Needs API includes


[CmdletBinding()]
Param
(
    [Parameter]
    [string]$computer
)
BEGIN {
    function getStatus {
        $s = Invoke-Command -ScriptBlock { cmd /c csscancli.exe --status }
        $s
        $s2 = $s.GetValue(4) -split ": "
        $scanID = $s2[1]
    }
    $testScanFile = Test-Path -Path "C:\Program Files\CrowdStrike\csscancli.exe"
    Set-Location "C:\Program Files\CrowdStrike"
    $getType = Get-CimInstance -ClassName Win32_OperatingSystem
    $t = $getType.ProductType    
}
PROCESS {
    if ($testScanFile) {
        switch ($t) {
            1 {
                Write-Host "Starting a scan for Workstation" -BackgroundColor Yellow
                Invoke-Command -ScriptBlock { cmd /c csscancli.exe --scan-all-drives --quarantine=true }
            }        
            2 { 
                Write-Host "Starting a scan for Domain Controller" -BackgroundColor Yellow
                Invoke-Command -ScriptBlock { cmd /c csscancli.exe --scan-all-drives --quarantine=true }
            }
            3 { 
                Write-Host "Starting a scan for Production Server" -BackgroundColor Yellow
                Invoke-Command -ScriptBlock { cmd /c csscancli.exe --scan-all-drives --quarantine=true } 
            }
        }
    }
}

END {
    #Invoke-Command -ScriptBlock { cmd /c csscancli.exe --status=$scanID }
    Write-Host "Scan has been started."
}
