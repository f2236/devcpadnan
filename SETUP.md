# Complete CI/CD Setup Guide for Java Web Calculator

This guide walks you through deploying the calculator with Jenkins and Tomcat, step by step.

## Prerequisites
- Jenkins running at `http://localhost:8080`
- Tomcat running at `http://localhost:9090`
- Git installed
- Maven installed

---

## Step 1: Enable Tomcat Manager User

Edit your Tomcat user config file:

**Windows:**
```
C:\Program Files\Apache Software Foundation\Tomcat 9.0\conf\tomcat-users.xml
```

Add these lines before the closing `</tomcat-users>` tag:

```xml
<role rolename="manager-gui"/>
<role rolename="manager-script"/>
<user username="admin" password="admin123" roles="manager-gui,manager-script"/>
```

Save the file and restart Tomcat.

### To restart Tomcat on Windows:
```powershell
# Stop Tomcat
Stop-Service Tomcat9

# Start Tomcat
Start-Service Tomcat9
```

Verify Tomcat Manager is accessible: `http://localhost:9090/manager/html` (use admin/admin123)

---

## Step 2: Generate Jenkins API Token

1. Go to `http://localhost:8080`
2. Click your username (top-right) → **Configure**
3. Under **API Token**, click **Add new Token**
4. Name it `devcicd-token`
5. Click **Generate**
6. **Copy the token value** — you'll need it in Step 3

---

## Step 3: Add Tomcat Credentials to Jenkins (Automated)

Open PowerShell and run:

```powershell
cd 'd:\Eigth smester\dev\Devcicd\devCiCd'

.\setup-jenkins-credentials.ps1 `
  -JenkinsUrl "http://localhost:8080" `
  -JenkinsUser "admin" `
  -JenkinsToken "YOUR_API_TOKEN_HERE" `
  -TomcatUser "admin" `
  -TomcatPassword "admin123"
```

Replace `YOUR_API_TOKEN_HERE` with the token from Step 2.

**Expected output:**
```
Adding Jenkins credential with ID: tomcat-manager
SUCCESS: Credentials added to Jenkins.

Next steps:
1. Go to Jenkins: http://localhost:8080
2. Run your pipeline job again - it should now find the tomcat-manager credentials.
3. The pipeline will deploy calculator.war to http://localhost:9090/calculator
```

---

## Step 4: Create a Jenkins Pipeline Job

1. Go to `http://localhost:8080`
2. Click **New Item**
3. Enter job name: `devcicd-calculator`
4. Select **Pipeline**
5. Click **OK**
6. In the job configuration:
   - Scroll to **Pipeline** section
   - Under **Definition**, select **Pipeline script from SCM**
   - Set **SCM** to **Git**
   - Set **Repository URL** to: `https://github.com/Usman3660/devCiCd.git`
   - Set **Branch** to: `main`
   - Set **Script Path** to: `JavaWebCalculator/Jenkinsfile`
7. Click **Save**

---

## Step 5: Run the Pipeline

1. In Jenkins, click your job name `devcicd-calculator`
2. Click **Build Now**
3. Watch the build progress in the console output

**Expected stages:**
- ✅ Checkout
- ✅ Test (runs 3 unit tests)
- ✅ Package (creates calculator.war)
- ✅ Deploy to Tomcat (uploads to Tomcat Manager)

---

## Step 6: Verify Deployment

Once the pipeline succeeds:

1. Visit `http://localhost:9090/calculator` in your browser
2. You should see the calculator form
3. Try entering two numbers and selecting an operation (Addition, Subtraction, Multiplication)
4. Click Submit and verify the result

---

## Troubleshooting

### Pipeline fails at "Deploy to Tomcat" stage

**Error:** `ERROR: Could not find credentials entry with ID 'tomcat-manager'`

**Solution:** Run Step 3 again with the correct Jenkins API token.

### Tomcat Manager shows 401 Unauthorized

**Solution:** Verify your Tomcat credentials are correct in `tomcat-users.xml` and Tomcat has been restarted.

### Cannot clone from GitHub

**Error:** `No credentials specified` in git checkout

**Solution:** If the repo is private, add a GitHub credential to Jenkins with ID `github-credentials` and update the Jenkinsfile.

---

## One-Click Manual Deploy (Outside Jenkins)

After building locally with `mvn clean package`, you can deploy directly:

```powershell
cd 'd:\Eigth smester\dev\Devcicd\devCiCd\JavaWebCalculator'

.\deploy-to-tomcat.ps1 `
  -Username "admin" `
  -Password "admin123"
```

This deploys the built WAR immediately to `http://localhost:9090/calculator`.

---

## Next Steps

- Enable **Poll SCM** in Jenkins to auto-build on git commits
- Add a GitHub webhook for instant builds
- Monitor the pipeline in Prometheus/Grafana (ports 9091/3000)
