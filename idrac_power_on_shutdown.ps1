[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [String]$idrac_ip,

    [Parameter(Mandatory)]
    [ValidateSet('On', 'GracefulShutdown')]
    [String]$ResetType
)

#To fix the connection issues to iDRAC REST API
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
        }
    }
"@

[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Tls11

#Get iDRAC creds
$Credentials = Get-Credential -Message "Enter iDRAC Creds"

$JsonBody = @{"ResetType" = $ResetType} | ConvertTo-Json
$u1 = "https://$($idrac_ip)/redfish/v1/Systems/System.Embedded.1/Actions/ComputerSystem.Reset"

Invoke-RestMethod -Uri $u1 -Credential $Credentials -Method Post -UseBasicParsing -ContentType 'application/json' -Body $JsonBody -Headers @{"Accept"="application/json"} -Verbose


