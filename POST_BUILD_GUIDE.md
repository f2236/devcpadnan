# Post-Build Verification & Next Steps

Your Jenkins build succeeded! Here's how to verify the deployment and set up automation.

## Step 1: Verify the Calculator is Running

Open your browser to:
```
http://localhost:9090/calculator
```

**What you should see:**
- A form with two input fields for numbers
- Three radio buttons for operations (Addition, Subtraction, Multiplication)
- A Submit button

**Test it:**
1. Enter `5` in the first number field
2. Enter `3` in the second number field
3. Select **Addition**
4. Click **Submit**
5. You should see: `Addition 8`

If you see the form and it works, the deployment is successful! ✓

---

## Step 2: Verify Deployment in Tomcat Manager

Open Tomcat Manager:
```
http://localhost:9090/manager/html
```

Log in with credentials:
- Username: `admin`
- Password: `admin123`

**What you should see:**
- `calculator` listed under "Applications"
- Status should be "running" (green)

If you see this, Tomcat is serving your WAR file correctly. ✓

---

## Step 3: Verify Jenkins Build Artifacts

In Jenkins, go to your job and click the build number, then look for:
- **Build Artifacts** section showing `calculator.war`
- **Console Output** showing all stages passed

If all stages show green, the pipeline worked end-to-end. ✓

---

## Step 4: Set Up Build Automation

Once manual testing works, automate future builds.

### Option A: Poll SCM (Jenkins checks for changes)

**Manual setup (if automation script doesn't work):**
1. Go to Jenkins job → **Configure**
2. Under **Build Triggers**, check **Poll SCM**
3. Set the schedule to: `H/15 * * * *`
4. Click **Save**

Jenkins will now check your GitHub repo every 15 minutes for changes and rebuild automatically.

### Option B: GitHub Webhook (instant builds on push)

1. Go to your GitHub repo: `https://github.com/Usman3660/devCiCd`
2. Click **Settings** → **Webhooks** → **Add webhook**
3. Fill in:
   - **Payload URL:** `http://YOUR_JENKINS_SERVER_IP:8080/github-webhook/`
   - **Content type:** `application/json`
   - **Events:** Just the push event
4. Click **Add webhook**

Now every time you push code to GitHub, Jenkins will automatically trigger a build and redeploy to Tomcat.

---

## Step 5: Test the CI/CD Pipeline

**To test the full pipeline end-to-end:**

1. Clone the repo locally:
   ```powershell
   git clone https://github.com/Usman3660/devCiCd.git
   cd devCiCd
   ```

2. Make a small change (e.g., edit the form title in `src/main/webapp/index.jsp`)

3. Commit and push:
   ```powershell
   git add .
   git commit -m "Test CI/CD pipeline"
   git push origin main
   ```

4. Go to Jenkins and watch the build start automatically

5. Once the build completes, refresh the calculator page to see your changes live

---

## Step 6: Monitor with Prometheus & Grafana (Optional)

You have monitoring tools available:
- **Prometheus:** `http://localhost:9091`
- **Grafana:** `http://localhost:3000`

These can track:
- Build success/failure rates
- Deployment frequency
- Application uptime

To integrate them, you would need to:
1. Add metrics export to the calculator app
2. Configure Prometheus scrape targets
3. Create dashboards in Grafana

(This is optional and can be done later if you want monitoring dashboards.)

---

## Troubleshooting

### Calculator shows 404 at http://localhost:9090/calculator

**Possible causes:**
1. Tomcat didn't deploy the WAR
2. Context path is wrong
3. Tomcat is not running

**Fix:**
- Check Tomcat is running: `Get-Service Tomcat9 | Select Status`
- Check Tomcat logs: `C:\Program Files\Apache Software Foundation\Tomcat 9.0\logs\catalina.log`
- Redeploy manually:
  ```powershell
  cd 'd:\Eigth smester\dev\Devcicd\devCiCd'
  .\deploy-to-tomcat.ps1 -Username "admin" -Password "admin123"
  ```

### Jenkins shows "Deploy failed" but Build passed

**Cause:** Tomcat credentials are not set up correctly.

**Fix:** Verify the credential in Jenkins:
1. Go to Manage Jenkins → Manage Credentials → (global)
2. Look for `tomcat-manager` credential
3. Make sure username is `admin` and password is `admin123`
4. Re-run the build

### GitHub webhook isn't triggering builds

**Cause:** Jenkins can't reach your webhook URL from GitHub.

**Fix:**
- Make sure Jenkins is accessible from the internet at your IP
- Or use Poll SCM instead (checks every 15 minutes)
- Check the webhook delivery log in GitHub repo Settings → Webhooks

---

## Summary: What You've Built

✓ **Java Web Calculator** — A simple Maven WAR app with unit tests  
✓ **Jenkins Pipeline** — Automated test, build, and deploy  
✓ **Tomcat Deployment** — One-click redeploy with update flag  
✓ **CI/CD Ready** — Auto-trigger on git push or scheduled poll  

Your infrastructure is now ready for continuous deployment!

---

## Quick Commands for Daily Use

```powershell
# Build locally
cd 'd:\Eigth smester\dev\Devcicd\devCiCd'
mvn clean test package

# Deploy locally without Jenkins
.\deploy-to-tomcat.ps1 -Username "admin" -Password "admin123"

# Check Jenkins build status
# Visit: http://localhost:8080/job/devcicd-calculator

# Check Tomcat deployment
# Visit: http://localhost:9090/manager/html

# Access the calculator
# Visit: http://localhost:9090/calculator
```

---

**You're done!** The pipeline is operational. Start using it by pushing changes to your repo. 🚀
