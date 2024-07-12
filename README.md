# ADFS-Enum
Active Directory Federation Service (AD FS) enables Federated Identity and Access Management by securely sharing digital identity and entitlements rights across security and enterprise boundaries. AD FS extends the ability to use single sign-on functionality that is available within a single security or enterprise boundary to Internet-facing applications to enable customers, partners, and suppliers a streamlined user experience while accessing the web-based applications of an organization.

## Shodan query
For fun and profit see the shodan query to detect federated domains with the IdpInitiatedSignonPage endpoint active en remotely accessible:
```test```

## Info
In Windows Server 2016-based AD FS Farms, the IdP-initiated Sign-on page is disabled by default. However, since many administrators rely on this page for testing SSO functionality this endpoint is often temporarily enabled. 

It is advisable to disable the IdpInitiatedSignonPage endpoint from being remotely accessible, due to the fact this can give unnecessary information about service providers being used within the corporate environment. To do so, run the following PowerShell command to configure the ADFS Farm:
```Set-AdfsProperties –EnableIdpInitiatedSignonPage $False```
