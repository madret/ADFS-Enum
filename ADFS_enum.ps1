# User input for domain
Write-Host -ForegroundColor Blue "Enter the domain name used for authentication (e.g. example.com):"
$domain = Read-Host
$email = "test@$domain"
$realmUrl = "https://login.microsoftonline.com/getuserrealm.srf?login=$email&xml=1"

# Tracking ADFS use
$adfsDetected = $false
$adfsSubdomain = $null

# 1: Try Microsoft Federation Endpoint
try {
    $realmResponse = Invoke-WebRequest -Uri $realmUrl -UseBasicParsing -TimeoutSec 5
    $xml = [xml]$realmResponse.Content
    $namespaceType = $xml.RealmInfo.NameSpaceType
    $authUrl = $xml.RealmInfo.AuthURL
    $mexUrl = $xml.RealmInfo.MEXURL

    if ($namespaceType -eq "Federated") {
        $uri = if ($authUrl) { [uri]$authUrl } elseif ($mexUrl) { [uri]$mexUrl } else { $null }
        if ($uri) {
            $adfsSubdomain = $uri.Host
            $adfsDetected = $true
        }
    } else {
        Write-Host -ForegroundColor Yellow "Microsoft indicates this domain is managed, not federated. Performing manual ADFS checks..."
    }
} catch {
    Write-Host -ForegroundColor Red "Failed to fetch federation information from Microsoft Online. Continuing with manual checks..."
}

# 2: Manual Subdomain check if ADFS not yet detected
if (-not $adfsDetected) {
    $subdomains = @(
        "adfs", "idp", "fs", "toegang", "sts", "auth", "sso", "wsso", "login", "federation", "signin",
        "secure", "portal", "identity", "identiteit", "authn", "accounts", "myaccount", "myid", "logon",
        "fed", "token", "access", "oauth", "openid", "pass"
    )

    function Test-ADFS {
        param ([string]$subdomain)
        $url = "https://$subdomain/adfs/ls"
        try {
            $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
            return ($response.StatusCode -eq 200)
        } catch {
            return $false
        }
    }

    foreach ($sub in $subdomains) {
        $testSubdomain = "$sub.$domain"
        Write-Host -ForegroundColor Yellow "Checking $testSubdomain..."
        if (Test-ADFS -subdomain $testSubdomain) {
            $adfsSubdomain = $testSubdomain
            $adfsDetected = $true
            break
        }
    }
}

# If ADFS detected: Run IdP-Initiated sign-on check
if ($adfsDetected -and $adfsSubdomain) {
    Write-Host ""
    Write-Host -ForegroundColor Yellow "This company domain appears to use AD FS to enable single sign-on functionality."
    Write-Host -ForegroundColor Yellow "And is using the following (sub)domain: " -NoNewline
    Write-Host -ForegroundColor Green "$adfsSubdomain"

    $idpUrl = "https://$adfsSubdomain/adfs/ls/IdpInitiatedSignOn.aspx"
    try {
        $response = Invoke-WebRequest -Uri $idpUrl -UseBasicParsing -TimeoutSec 5
        $htmlContent = $response.Content
        $pattern = '<option value="[^"]*">([^<]*)<\/option>'
        $matches = [regex]::Matches($htmlContent, $pattern)

        if ($matches.Count -gt 0) {
            Write-Host ""
            Write-Host -ForegroundColor Yellow "This domain has the following service providers:"
            foreach ($match in $matches) {
                Write-Host -ForegroundColor Green "$($match.Groups[1].Value)"
            }

            Write-Host ""
            Write-Host -ForegroundColor Yellow "It is advisable to disable the IdpInitiatedSignonPage endpoint from being publicly accessible."
        } else {
            Write-Host -ForegroundColor Yellow "No service providers found or the IdpInitiatedSignonPage endpoint seems to be offline (which is a security best practice)."
        }
    } catch {
        Write-Host -ForegroundColor Yellow "IdpInitiatedSignonPage endpoint seems to be offline or inaccessible (which is a security best practice)."
    }

    Write-Host -ForegroundColor Yellow "Get additional federation information about this domain, browse to: " -NoNewline
    Write-Host "https://login.microsoftonline.com/getuserrealm.srf?login=test@$($domain)&xml=1"

} else {
    Write-Host -ForegroundColor Yellow "No indication of ADFS being in use on given domain."
}
