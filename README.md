# ADFS-Enum
Active Directory Federation Service (AD FS) enables Federated Identity and Access Management by securely sharing digital identity and entitlements rights across security and enterprise boundaries. AD FS extends the ability to use single sign-on functionality that is available within a single security or enterprise boundary to Internet-facing applications to enable customers, partners, and suppliers a streamlined user experience while accessing the web-based applications of an organization.

The Active Directory Federation Services (AD FS) sign-on page can be used to check if authentication is working. This test is done by navigating to the page and signing in. Also, you can use the sign-in page to verify that all SAML 2.0 relying parties are listed. [1] 

## Info
In Windows Server 2016-based AD FS Farms, the IdP-initiated Sign-on page is disabled by default. However, since many administrators rely on this page for testing SSO functionality this endpoint is often (temporarily) enabled and forgotten. 

It is advisable to disable the IdpInitiatedSignonPage endpoint from being remotely accessible, due to the fact this can give unnecessary information about various service providers being used within the corporate environment. To do so, run the following PowerShell command to configure the ADFS Farm:
```Set-AdfsProperties –EnableIdpInitiatedSignonPage $False```

# Usage
Open a powershell prompt:

1. ```cd C:\Location\where\this\script\locates```
2. ```Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process```
3. ```.\ADFS-enum.ps1```
4. Enter the domain name that you'd like to test out (e.g. ```tesla.com```)
5. Receive output..

## Example output

![image](https://github.com/user-attachments/assets/0aa0b408-07f3-4bd2-8131-fb177c0ba577)

### MITRE ATT&CK® 
Gather Victim Network Information: Network Trust Dependencies
https://attack.mitre.org/techniques/T1590/003/ 

### References
[1] https://learn.microsoft.com/en-us/windows-server/identity/ad-fs/troubleshooting/ad-fs-tshoot-initiatedsignon


