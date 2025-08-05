# CircleCI Configuration Templates for Scantist Security Scanning

This directory contains CircleCI configuration templates for integrating Scantist security scanning into your CI/CD workflows.

## Available Templates

### `config.yml`
A comprehensive CircleCI configuration template for Software Composition Analysis (SCA) scanning using `sca-bom-detect.jar`.

## Quick Start

### Prerequisites

1. **CircleCI Setup**:
   - CircleCI account and project connected to your repository
   - Ubuntu-based Docker executor (default configuration)

2. **Environment Variables**:
   Configure these in your CircleCI project settings (Project Settings → Environment Variables):
   ```
   SCA_BOM_DETECT_DOWNLOAD_URL=<URL_to_sca-bom-detect.jar>
   DEVSECOPS_TOKEN=<your_devsecops_token>
   DEVSECOPS_IMPORT_URL=<optional_import_url>
   ASYNC=false  # Optional, defaults to false
   ```

### Usage

1. **Copy Configuration**:
   - Copy `config.yml` to `.circleci/config.yml` in your repository root
   - Or use the template as reference for your existing CircleCI configuration

2. **Configure Environment Variables**:
   - Go to CircleCI project settings
   - Add the required environment variables listed above

3. **Push to Repository**:
   - Commit and push the configuration
   - CircleCI will automatically trigger the SCA scan workflow

## Configuration Structure

The CircleCI configuration includes the following components:

### Executors
- **ubuntu-executor**: Ubuntu-based Docker environment for consistent scanning

### Commands (Reusable Steps)
- **setup-dependencies**: Installs curl and OpenJDK 11
- **validate-environment**: Validates required environment variables
- **download-sca-detector**: Downloads the SCA detector JAR
- **run-sca-scan**: Executes the SCA scan with DevSecOps integration

### Jobs
- **sca-scan**: Main job that orchestrates the complete SCA scanning process

### Workflows
- **sca-security-scan**: Workflow that runs on specified branches

## Job Execution Flow

### 1. Checkout
- Retrieves source code from the repository

### 2. Setup Dependencies
- Updates package manager
- Installs `curl` and `openjdk-11-jre-headless`
- Prepares the environment for SCA scanning

### 3. Environment Validation
- Validates that `DEVSECOPS_TOKEN` is provided
- Ensures all required variables are set

### 4. SCA Detector Download
- Downloads the SCA detector JAR if not present
- Creates necessary directories

### 5. SCA Scan Execution
- Creates report directory
- Executes the SCA scan with DevSecOps integration
- Generates JSON reports

### 6. Artifact Storage
- Stores scan reports as CircleCI artifacts
- Makes reports available in the CircleCI dashboard

## Customization

### Branch Filtering
Modify the workflow to run on specific branches:

```yaml
workflows:
  sca-security-scan:
    jobs:
      - sca-scan:
          filters:
            branches:
              only:
                - main
                - develop
                - /release\/.*/
```

### Custom Docker Image
Use a custom Docker image with pre-installed dependencies:

```yaml
executors:
  custom-executor:
    docker:
      - image: your-registry/custom-image:latest
    working_directory: ~/project
```

### Additional Dependencies
Add more dependencies to the setup command:

```yaml
commands:
  setup-dependencies:
    steps:
      - run:
          name: "📦 Installing dependencies"
          command: |
            apt-get update
            apt-get install -y curl openjdk-11-jre-headless git maven nodejs
```

### Parallel Execution
Run multiple scans in parallel:

```yaml
workflows:
  parallel-scans:
    jobs:
      - sca-scan:
          name: sca-scan-main
      - sca-scan:
          name: sca-scan-feature
          filters:
            branches:
              only: /feature\/.*/
```

### Context Integration
Use CircleCI contexts for environment variables:

```yaml
workflows:
  sca-security-scan:
    jobs:
      - sca-scan:
          context:
            - scantist-security-context
            - company-wide-secrets
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
   - Ensure using Ubuntu-based executor with root privileges
   - Consider using custom Docker image with pre-installed dependencies

2. **Java Not Found**:
   - Verify OpenJDK installation in setup-dependencies command
   - Check if Java is properly added to PATH

3. **SCA JAR Download Fails**:
   - Verify `SCA_BOM_DETECT_DOWNLOAD_URL` is accessible from CircleCI
   - Check network connectivity and firewall settings

4. **DevSecOps Token Issues**:
   - Ensure `DEVSECOPS_TOKEN` is properly configured in project settings
   - Verify token has necessary permissions and is not expired

5. **Workflow Not Triggering**:
   - Check branch filters in workflow configuration
   - Verify `.circleci/config.yml` is in repository root
   - Check CircleCI project settings and repository connection

### Debug Mode

Enable verbose logging by modifying the SCA scan command:

```yaml
- run:
    name: "🔍 Running SCA scan (Debug Mode)"
    command: |
      java -jar "${SCA_PLUGIN_DIR}/${SCA_JAR_NAME}" \
        -f "$(pwd)" --debug -report json --verbose
```

### SSH Debugging

Enable SSH access for debugging failed builds:

```yaml
- run:
    name: "Enable SSH (Debug Only)"
    command: |
      # Add this step temporarily for debugging
      echo "SSH debugging enabled"
    when: on_fail
```

## Integration with Other Tools

### Slack Notifications
Add Slack notifications using CircleCI orbs:

```yaml
version: 2.1

orbs:
  slack: circleci/slack@4.10.1

jobs:
  sca-scan:
    # ... existing configuration
    steps:
      # ... existing steps
      - slack/notify:
          event: fail
          template: basic_fail_1
      - slack/notify:
          event: pass
          template: success_tagged_deploy_1
```

### Email Notifications
Configure email notifications in CircleCI project settings or use custom commands:

```yaml
commands:
  notify-email:
    steps:
      - run:
          name: "📧 Send email notification"
          command: |
            # Custom email notification logic
            curl -X POST "https://api.sendgrid.com/v3/mail/send" \
              -H "Authorization: Bearer $SENDGRID_API_KEY" \
              -H "Content-Type: application/json" \
              -d '{
                "personalizations": [{"to": [{"email": "security@company.com"}]}],
                "from": {"email": "circleci@company.com"},
                "subject": "SCA Scan Results",
                "content": [{"type": "text/plain", "value": "SCA scan completed"}]
              }'
          when: always
```

### Jira Integration
Create Jira tickets for security findings:

```yaml
- run:
    name: "🎫 Create Jira ticket for findings"
    command: |
      # Parse scan results and create Jira tickets
      if [ -f "devsecops_report/findings.json" ]; then
        # Custom Jira integration logic
        python scripts/create_jira_tickets.py devsecops_report/findings.json
      fi
    when: always
```

## Security Best Practices

1. **Secure Environment Variables**: Use CircleCI contexts for sensitive data
2. **Limited Scope**: Restrict workflow execution to specific branches
3. **Artifact Retention**: Configure appropriate retention policies for security reports
4. **Access Control**: Limit access to security scan results based on team roles
5. **Regular Updates**: Keep the SCA detector JAR updated regularly

## Performance Optimization

### Caching
Cache dependencies and SCA detector JAR:

```yaml
- restore_cache:
    keys:
      - sca-detector-{{ checksum "SCA_BOM_DETECT_DOWNLOAD_URL" }}
      - sca-detector-

- save_cache:
    key: sca-detector-{{ checksum "SCA_BOM_DETECT_DOWNLOAD_URL" }}
    paths:
      - .scantist/
```

### Resource Classes
Use appropriate resource classes for faster execution:

```yaml
jobs:
  sca-scan:
    executor: ubuntu-executor
    resource_class: medium+  # or large for faster execution
```

## Support

For issues related to:
- **CircleCI Configuration**: Check CircleCI documentation and build logs
- **SCA Scanning**: Verify Scantist platform connectivity and token validity
- **Template Customization**: Refer to CircleCI configuration reference

---

**Note**: This template is designed to mirror the functionality of the GitLab CI `bom-sca-scan.yml` and Jenkins `bom-sca-scan.jenkinsfile` templates, providing consistent security scanning across different CI/CD platforms.
