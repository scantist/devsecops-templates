# Jenkins Pipeline Templates for Scantist Security Scanning

This directory contains Jenkins pipeline templates for integrating Scantist security scanning into your CI/CD workflows.

## Available Templates

### `scaScan.groovy`
A reusable Jenkins Pipeline step for Software Composition Analysis (SCA) scanning using `sca-bom-detect.jar`.  
All required configuration values are securely loaded from Jenkins **Credentials**.

---

## Quick Start

### Prerequisites

1. **Jenkins Setup**
   - Jenkins server with **Pipeline** plugin installed
   - Ubuntu-based Jenkins agent (or modify commands for your OS)
   - Access to install packages (`apt-get`) if dependencies aren’t pre-installed
   - Internet access to download the `sca-bom-detect.jar` file

2. **Jenkins Credentials**  
   In **Manage Jenkins → Credentials**, create three **Secret text** entries:

   | ID                               | Example Value |
   |----------------------------------|---------------|
   | `SCA_BOM_DETECT_DOWNLOAD_URL`    | https://download.scantist.io/sca-bom-detect.jar |
   | `DEVSECOPS_IMPORT_URL`           | https://my-import-endpoint |
   | `DEVSECOPS_TOKEN`                | your_api_token |

---

## Usage

### 1. Create or Edit a Pipeline Job
- Go to **Jenkins → New Item → Pipeline** (or edit an existing job)
- Choose **Pipeline script** or **Pipeline script from SCM** depending on your setup

### 2. Call the Template in Your Pipeline
In your `Jenkinsfile`, after your build stage:

```groovy
stage('SCA Scan') {
  steps {
    script {
      evaluate(new URL('https://github.com/scantist/devsecops-templates/blob/main/ci-templates/jenkins/bom-sca-scan.jenkinsfile').text)
      scaScan() // Runs with all secrets loaded from Jenkins credentials 
    }
  }
}
```

---

## What It Does

### Stages Inside `scaScan()`:
1. **Dependency Setup**  
   - Installs `curl` and `openjdk-11-jre-headless` if not present (Debian/Ubuntu agents)
2. **Jar Download**  
   - Downloads `sca-bom-detect.jar` from the URL in `SCA_BOM_DETECT_DOWNLOAD_URL` if missing
3. **SCA Scan Execution**  
   - Runs the scan on the current workspace using `DEVSECOPS_TOKEN` and `DEVSECOPS_IMPORT_URL`
4. **Report Archiving**  
   - Archives all generated reports (`devsecops_report/**`) as Jenkins build artifacts

---

## Environment Variables in This Template
These are **not** passed manually — they are loaded from Jenkins credentials at runtime.

| Jenkins Credential ID              | Purpose |
|------------------------------------|---------|
| `SCA_BOM_DETECT_DOWNLOAD_URL`      | URL to download the SCA detector JAR |
| `DEVSECOPS_IMPORT_URL`             | Optional: Import URL for DevSecOps integration |
| `DEVSECOPS_TOKEN`                  | Authentication token for DevSecOps platform |

---

## Troubleshooting

### Common Issues
1. **Jar download fails** → Verify `SCA_BOM_DETECT_DOWNLOAD_URL` is correct and accessible from the agent
2. **Java not found** → Ensure `openjdk-11-jre-headless` is installed or pre-baked into the agent
3. **Token errors** → Make sure `DEVSECOPS_TOKEN` is valid and stored as a Jenkins **Secret text**

---

## Security Best Practices
- **Never** hardcode URLs or tokens in the Jenkinsfile — always use the credentials store
- Limit access to jobs and credentials to authorized users
- Keep the detector JAR URL up to date for the latest security checks

---

This updated template removes manual environment variable setup from job configuration and ensures all sensitive data is loaded directly from Jenkins secrets at runtime.
