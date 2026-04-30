param(
    [string]$TomcatUrl = "http://localhost:9090",
    [string]$ContextPath = "calculator",
    [string]$Username,
    [string]$Password,
    [string]$WarPath = "target\calculator.war"
)

$ErrorActionPreference = "Stop"


if (-not (Test-Path $WarPath)) {
    throw "WAR file not found at $WarPath. Run 'mvn clean package' first."
}

if ([string]::IsNullOrWhiteSpace($Username) -or [string]::IsNullOrWhiteSpace($Password)) {
    throw "Tomcat credentials are required. Pass -Username and -Password."
}

$deployUrl = "$TomcatUrl/manager/text/deploy?path=/$ContextPath&update=true"

Write-Host "Deploying $WarPath to $deployUrl"

& curl.exe --fail --show-error --silent `
    -u "$Username`:$Password" `
    --upload-file $WarPath `
    $deployUrl
