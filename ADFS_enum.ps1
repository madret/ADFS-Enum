# User input for domain
Write-Host -ForegroundColor Blue "Enter the base domain (e.g. example.com):"
$domain = Read-Host

# Potential and common ADFS subdomains
$subdomains = @(
    "adfs",
    "idp",
    "fs",
    "toegang",
    "sts",
    "auth",
    "sso",
    "wsso",
    "login",
    "federation",
    "signin",
    "secure",
    "portal",
    "identity",
    "identiteit",
    "authn",
    "accounts",
    "myaccount",
    "myid",
    "logon",
    "fed",
    "token",
    "access",
    "oauth",
    "openid",
    "pass"
)

# Function to check if given subdomain is using ADFS
function Test-ADFS {
    param (
        [string]$subdomain
    )
    $url = "https://$subdomain/adfs/ls"
    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            return $true
        }
    } catch {
        return $false
    }
}

# Foreach loop to test each subdomain
$adfsSubdomain = $null
foreach ($sub in $subdomains) {
    $testSubdomain = "$sub.$domain"
    Write-Host -ForegroundColor Yellow "Checking $testSubdomain..."
    if (Test-ADFS -subdomain $testSubdomain) {
        $adfsSubdomain = $testSubdomain
        break
    }
}

# Output based on the test results
if ($null -ne $adfsSubdomain) {
    Write-Host ""    
    Write-Host -ForegroundColor Yellow "This company domain appears to use AD FS to enable single sign-on functionality."
    Write-Host -ForegroundColor Yellow "And is using the following (sub)domain: " -NoNewline
    Write-Host -ForegroundColor Green "$adfsSubdomain"
    
    # IdP-initiated sign-on endpoint
    $url = "https://$adfsSubdomain/adfs/ls/IdpInitiatedSignOn.aspx"

    # Fetch HTML
    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 3
        $htmlContent = $response.Content

        # Regex to extract service providers from HTML content
        $serviceProviderPattern = '<option value="[^"]*">([^<]*)<\/option>'
        $matches = [regex]::Matches($htmlContent, $serviceProviderPattern)

        if ($matches.Count -gt 0) {
            Write-Host ""
            Write-Host -ForegroundColor Yellow "This domain has the following service providers:"
            foreach ($match in $matches) {
                Write-Host -ForegroundColor Green "$($match.Groups[1].Value)"
            }

            Write-Host ""
            Write-Host -ForegroundColor Yellow "It is advisable to disable the IdpInitiatedSignonPage endpoint from being remotely accessible, due to the fact this can give unnecessary information about service providers being used within the corporate environment. To do so, run the following PowerShell command to configure the ADFS Farm:"
            Write-Host -ForegroundColor Blue "Set-AdfsProperties –EnableIdpInitiatedSignonPage `$False"
	    Write-Host -ForegroundColor Yellow "Get additional federation information about this domain, browse to: " -NoNewline
	    Write-Host "https://login.microsoftonline.com/getuserrealm.srf?login=test@$($domain)&xml=1"
        } else {
            Write-Host -ForegroundColor Yellow "No service providers found or the IdpInitiatedSignonPage endpoint seems to be offline, which is a security best practice."
	    Write-Host -ForegroundColor Yellow "Get additional federation information about this domain, browse to: " -NoNewline
	    Write-Host "https://login.microsoftonline.com/getuserrealm.srf?login=test@$($domain)&xml=1"
        }
    } catch {
        Write-Host -ForegroundColor Yellow "No service providers found or the IdpInitiatedSignonPage endpoint seems to be offline, which is a security best practice."
        Write-Host -ForegroundColor Yellow "Get additional federation information about this domain, browse to: " -NoNewline
	Write-Host "https://login.microsoftonline.com/getuserrealm.srf?login=test@$($domain)&xml=1"
    }
} else {
    Write-Host -ForegroundColor Yellow "No indication of ADFS being in use on given domain."
}
