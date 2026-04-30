param(
    [string]$JenkinsUrl = "http://localhost:8080",
    [string]$JenkinsUser = "admin",
    [string]$JenkinsToken,
    [string]$JobName = "devcicd-calculator",
    [string]$GitHubRepo = "https://github.com/Usman3660/devCiCd.git",
    [string]$GitHubWebhookUrl = ""
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($JenkinsToken)) {
    Write-Host "Jenkins API token is required for automation setup."
    Write-Host ""
    Write-Host "To get your API token:"
    Write-Host "1. Go to $JenkinsUrl"
    Write-Host "2. Click your username (top-right) → Configure"
    Write-Host "3. Under 'API Token', click 'Add new Token'"
    Write-Host "4. Name it 'automation-token' and copy the value"
    Write-Host ""
    Write-Host "Then run:"
    Write-Host "  .\setup-jenkins-automation.ps1 -JenkinsToken YOUR_TOKEN_HERE"
    exit 1
}

$JenkinsAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$JenkinsUser`:$JenkinsToken"))

# Step 1: Enable Poll SCM
Write-Host "Configuring Poll SCM (checks for changes every 15 minutes)..."

$jobConfigUrl = "$JenkinsUrl/job/$JobName/config.xml"

try {
    $response = Invoke-WebRequest -Uri $jobConfigUrl `
        -Method Get `
        -Headers @{"Authorization" = "Basic $JenkinsAuth"} `
        -ErrorAction SilentlyContinue

    if ($response.StatusCode -eq 200) {
        [xml]$jobConfig = $response.Content
        
        # Check if triggers already exist, if not add them
        if ($jobConfig.project.triggers -eq $null) {
            $triggersElement = $jobConfig.CreateElement("triggers")
            $jobConfig.project.AppendChild($triggersElement) | Out-Null
        }

        # Add Poll SCM trigger
        $pollTrigger = $jobConfig.CreateElement("com.cloudbees.jenkins.GitHubPushTrigger")
        $pollTrigger.SetAttribute("plugin", "github@1.35.0")
        $jobConfig.project.triggers.AppendChild($pollTrigger) | Out-Null

        # Also add periodic trigger as backup
        $timerTrigger = $jobConfig.CreateElement("hudson.triggers.TimerTrigger")
        $specElement = $jobConfig.CreateElement("spec")
        $specElement.InnerText = "H/15 * * * *"
        $timerTrigger.AppendChild($specElement) | Out-Null
        $jobConfig.project.triggers.AppendChild($timerTrigger) | Out-Null

        # Update the job config
        $updateResponse = Invoke-WebRequest -Uri $jobConfigUrl `
            -Method Post `
            -Headers @{"Authorization" = "Basic $JenkinsAuth"} `
            -Body $jobConfig.OuterXml `
            -ContentType "application/xml" `
            -ErrorAction SilentlyContinue

        if ($updateResponse.StatusCode -eq 200 -or $updateResponse.StatusCode -eq 302) {
            Write-Host "✓ Poll SCM enabled (15-minute interval)"
        }
    }
} catch {
    Write-Host "Note: Could not auto-configure Poll SCM. You can set it manually:"
    Write-Host "  1. Go to $JenkinsUrl/job/$JobName/configure"
    Write-Host "  2. Check 'Poll SCM' under Build Triggers"
    Write-Host "  3. Set schedule to: H/15 * * * *"
    Write-Host "  4. Click Save"
}

# Step 2: Display GitHub webhook instructions
Write-Host ""
Write-Host "To set up GitHub webhook for instant builds:"
Write-Host "1. Go to your GitHub repo: $GitHubRepo"
Write-Host "2. Click Settings → Webhooks → Add webhook"
Write-Host "3. Set Payload URL to:"
Write-Host "   http://YOUR_JENKINS_IP:8080/github-webhook/"
Write-Host "4. Set Content type: application/json"
Write-Host "5. Click 'Add webhook'"
Write-Host ""
Write-Host "Then Jenkins will auto-build on every git push!"
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Test the calculator at: http://localhost:9090/calculator"
Write-Host "2. Try pushing a change to your GitHub repo"
Write-Host "3. Watch the build start automatically in Jenkins"
