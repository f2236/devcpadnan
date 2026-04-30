param(
    [string]$JenkinsUrl = "http://localhost:8080",
    [string]$JenkinsUser = "admin",
    [string]$JenkinsToken,
    [string]$TomcatUser = "admin",
    [string]$TomcatPassword = "admin123",
    [string]$CredentialId = "tomcat-manager"
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($JenkinsToken)) {
    throw "Jenkins API token is required. Pass -JenkinsToken with your Jenkins user token."
}

# Base64 encode Jenkins credentials
$JenkinsAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$JenkinsUser`:$JenkinsToken"))

# XML payload for Jenkins credentials
$credentialXml = @"
<?xml version='1.1' encoding='UTF-8'?>
<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl plugin="credentials@1319.v7eb_51b03a_c81">
  <scope>GLOBAL</scope>
  <id>$CredentialId</id>
  <description>Tomcat Manager Credentials</description>
  <username>$TomcatUser</username>
  <password>$TomcatPassword</password>
</com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
"@

$credentialUrl = "$JenkinsUrl/credentials/store/system/domain/_/createCredentials"

Write-Host "Adding Jenkins credential with ID: $CredentialId"

try {
    $response = Invoke-WebRequest -Uri $credentialUrl `
        -Method Post `
        -Headers @{
            "Authorization" = "Basic $JenkinsAuth"
            "Content-Type" = "application/xml"
        } `
        -Body $credentialXml `
        -ErrorAction SilentlyContinue

    if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 302) {
        Write-Host "SUCCESS: Credentials added to Jenkins."
    } else {
        Write-Host "WARNING: Response code was $($response.StatusCode). Credential may have been created."
    }
} catch {
    Write-Host "ERROR: Could not add credentials. Ensure Jenkins is running and the API token is correct."
    Write-Host "Details: $_"
    exit 1
}

Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Go to Jenkins: $JenkinsUrl"
Write-Host "2. Run your pipeline job again - it should now find the tomcat-manager credentials."
Write-Host "3. The pipeline will deploy calculator.war to http://localhost:9090/calculator"
