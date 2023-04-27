#Pete Lenhart--Version 1--April 10th 2023

class apihelper {
    [string]$apiKey
    [string]$apiSeecret

    [string]GetAPIInfo() {
        return "$($this.apiKey) $($this.apiSeecret)"
    }

    [void]SetAPIInfo([string]$apihelper) {
        $this.apiKey = ($apihelper -split ' ')[0]
        $this.apiSeecret = ($apihelper -split ' ')[1]
    }

    [void]SetAPIInfo([string]$apiKey,[string]$apiSeecret) {
        $this.apiKey = $apiKey
        $this.apiSeecret = $apiSeecret
    }

}

$myAPICreds = [apihelper]::new()

#API Key and API secret here.
#space between key and secret
$myAPICreds.SetAPIInfo("<KEY> <SECRET")

class sandboxapihelper {
    [string]$apiKey
    [string]$apiSeecret

    [string]GetAPIInfo() {
        return "$($this.apiKey) $($this.apiSeecret)"
    }

    [void]SetAPTInfo([string]$sandboxapihelper) {
        $this.apiKey = ($sandboxapihelper -split ' ')[0]
        $this.apiSeecret = ($sandboxapihelper -split ' ')[1]
    }

}

$myHostAPICreds = [hostapihelper]::new()
$myHostAPICreds.SetAPTInfo("<KEY> <SECRET")
$myHostAPICreds
