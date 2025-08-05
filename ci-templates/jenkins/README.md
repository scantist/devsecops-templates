# Jenkins Pipeline Templates for Scantist Security Scanning

This directory contains Jenkins pipeline templates for integrating Scantist security scanning into your CI/CD workflows.

## Available Templates

### `bom-sca-scan.jenkinsfile`
A comprehensive Jenkins pipeline template for Software Composition Analysis (SCA) scanning using `sca-bom-detect.jar`.

## Quick Start

### Prerequisites

1. **Jenkins Setup**:
   - Jenkins server with Pipeline plugin installed
   - Ubuntu-based Jenkins agent (or modify the `agent` section for your setup)
   - Required permissions to install system packages (`apt-get`)

2. **Environment Variables**:
   Configure these in your Jenkins job or globally:
   ```
   SCA_BOM_DETECT_DOWNLOAD_URL=<URL_to_sca-bom-detect.jar>
   DEVSECOPS_TOKEN=<your_devsecops_token>
   DEVSECOPS_IMPORT_URL=<optional_import_url>
   ASYNC=false  # Optional, defaults to false
   ```

### Usage

1. **Create a New Pipeline Job**:
   - Go to Jenkins → New Item → Pipeline
   - Name your job (e.g., "SCA-Security-Scan")

2. **Configure Pipeline**:
   - In the Pipeline section, choose "Pipeline script from SCM"
   - Point to your repository containing the Jenkinsfile
   - Set Script Path to: `v1/ci-templates/jenkins/bom-sca-scan.jenkinsfile`

3. **Set Environment Variables**:
   - Go to job configuration → Build Environment
   - Add the required environment variables listed above

4. **Run the Pipeline**:
   - Click "Build Now" to execute the SCA scan

## Pipeline Stages

The Jenkins pipeline includes the following stages:

### 1. Setup Dependencies
- Updates package manager
- Installs `curl` and `openjdk-11-jre-headless`
- Prepares the environment for SCA scanning

### 2. SCA Scan
- Validates required environment variables
- Downloads the SCA detector JAR if not present
- Creates report directory
- Executes the SCA scan with DevSecOps integration
- Generates JSON reports

### Post-Build Actions
- **Always**: Archives scan reports as Jenkins artifacts
- **Success**: Logs successful completion
- **Failure**: Logs failure details for debugging
- **Cleanup**: Performs workspace cleanup

## Customization

### Agent Configuration
Modify the `agent` section to match your Jenkins setup:

```groovy
agent {
    // For Docker-based agents
    docker {
        image 'ubuntu:latest'
    }
}

// Or for specific node labels
agent {
    label 'your-custom-label'
}
```

### Additional Dependencies
Add more dependencies in the "Setup Dependencies" stage:

```groovy
sh '''
    apt-get update
    apt-get install -y curl openjdk-11-jre-headless git maven
'''
```

### Custom Report Processing
Extend the `post` section to process reports:

```groovy
post {
    always {
        // Your custom report processing
        publishHTML([
            allowMissing: false,
            alwaysLinkToLastBuild: true,
            keepAll: true,
            reportDir: "${SCA_REPORT_DIR}",
            reportFiles: '*.json',
            reportName: 'SCA Security Report'
        ])
    }
}
```

## Environment Variables Reference

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `SCA_BOM_DETECT_DOWNLOAD_URL` | ✅ | - | URL to download the SCA detector JAR |
| `DEVSECOPS_TOKEN` | ✅ | - | Authentication token for DevSecOps platform |
| `DEVSECOPS_IMPORT_URL` | ❌ | - | Optional import URL for DevSecOps integration |
| `ASYNC` | ❌ | `false` | Enable asynchronous processing |

## Troubleshooting

### Common Issues

1. **Permission Denied for apt-get**:
   - Ensure Jenkins agent runs with sufficient privileges
   - Consider using Docker agents with pre-installed dependencies

2. **Java Not Found**:
   - Verify OpenJDK installation in the Setup Dependencies stage
   - Check if `JAVA_HOME` is properly set

3. **SCA JAR Download Fails**:
   - Verify `SCA_BOM_DETECT_DOWNLOAD_URL` is accessible
   - Check network connectivity from Jenkins agent

4. **DevSecOps Token Issues**:
   - Ensure `DEVSECOPS_TOKEN` is properly configured
   - Verify token has necessary permissions

### Debug Mode

Enable debug logging by modifying the SCA scan command:
```bash
java -jar "${SCA_PLUGIN_DIR}/${SCA_JAR_NAME}" -f "${WORKSPACE}" --debug -report json --verbose
```

## Integration with Other Tools

### Slack Notifications
Add Slack notifications to the `post` section:

```groovy
post {
    success {
        slackSend channel: '#security', 
                  color: 'good', 
                  message: "✅ SCA scan completed successfully for ${env.JOB_NAME}"
    }
    failure {
        slackSend channel: '#security', 
                  color: 'danger', 
                  message: "❌ SCA scan failed for ${env.JOB_NAME}"
    }
}
```

### Email Notifications
Configure email notifications:

```groovy
post {
    always {
        emailext (
            subject: "SCA Scan Results: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
            body: "SCA scan completed. Check attached reports for details.",
            to: "${env.CHANGE_AUTHOR_EMAIL}",
            attachmentsPattern: "${SCA_REPORT_DIR}/*.json"
        )
    }
}
```

## Security Best Practices

1. **Secure Credentials**: Store sensitive tokens in Jenkins Credential Store
2. **Agent Isolation**: Use dedicated agents for security scanning
3. **Report Access**: Restrict access to security reports based on user roles
4. **Regular Updates**: Keep the SCA detector JAR updated regularly

## Support

For issues related to:
- **Jenkins Pipeline**: Check Jenkins logs and pipeline syntax
- **SCA Scanning**: Verify Scantist platform connectivity and token validity
- **Template Customization**: Refer to Jenkins Pipeline documentation

---

**Note**: This template is designed to mirror the functionality of the GitLab CI `bom-sca-scan.yml` template, providing consistent security scanning across different CI/CD platforms.
