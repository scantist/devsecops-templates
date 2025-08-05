# TeamCity Configuration Templates for Scantist Security Scanning

This directory contains TeamCity configuration templates for integrating Scantist security scanning into your CI/CD workflows.

## Available Templates

### `settings.kts` (Kotlin DSL)
A comprehensive TeamCity configuration template using Kotlin DSL for Software Composition Analysis (SCA) scanning using `sca-bom-detect.jar`.

### `sca-scan-build.xml` (XML Configuration)
An XML-based build configuration template that can be imported directly into TeamCity for teams preferring XML configuration.

## Quick Start

### Prerequisites

1. **TeamCity Setup**:
   - TeamCity server (2023.11 or later recommended)
   - Linux-based build agents with Docker support
   - Administrative access to create/modify build configurations

2. **Environment Variables**:
   Configure these in your TeamCity project or build configuration parameters:
   ```
   SCA_BOM_DETECT_DOWNLOAD_URL=<URL_to_sca-bom-detect.jar>
   DEVSECOPS_TOKEN=<your_devsecops_token> (password parameter)
   DEVSECOPS_IMPORT_URL=<optional_import_url>
   ASYNC=false  # Optional, defaults to false
   ```

### Usage Options

#### Option 1: Kotlin DSL (Recommended)
1. **Copy Configuration**:
   - Copy `settings.kts` to `.teamcity/settings.kts` in your repository root
   - Commit and push to your VCS

2. **Enable Versioned Settings**:
   - Go to TeamCity project settings
   - Enable "Synchronization enabled" under Versioned Settings
   - Select "Use settings from VCS"

3. **Configure Parameters**:
   - Set the required environment variables in project parameters
   - Mark `DEVSECOPS_TOKEN` as a password parameter

#### Option 2: XML Import
1. **Import Configuration**:
   - Go to TeamCity Administration → Projects
   - Select your project → Import Build Configuration
   - Upload the `sca-scan-build.xml` file

2. **Configure VCS Root**:
   - Attach the build configuration to your VCS root
   - Configure branch specifications if needed

3. **Set Parameters**:
   - Configure the required environment variables in build configuration parameters

## Configuration Structure

### Kotlin DSL Components

#### Project Structure
- **Global Parameters**: Shared across all build configurations
- **Build Type**: `ScaScanBuild` - main SCA scanning configuration
- **VCS Integration**: Automatic checkout and branch filtering

#### Build Steps
1. **Setup Dependencies**: Installs curl and OpenJDK 11
2. **SCA Security Scan**: Executes the complete SCA scanning workflow

#### Features
- **Artifact Publishing**: Archives scan reports automatically
- **VCS Triggers**: Runs on code changes with branch filtering
- **Docker Integration**: Uses Ubuntu containers for consistent environment
- **Failure Conditions**: Configurable timeout and exit code handling

### XML Configuration Components

#### Build Runners
- **Setup Dependencies**: System preparation step
- **SCA Scan**: Main scanning execution step

#### Build Features
- **XML Report Processing**: Integrates with TeamCity's report system
- **Commit Status Publisher**: Updates VCS commit status
- **Artifact Rules**: Defines which files to archive

## Build Execution Flow

### 1. VCS Checkout
- Retrieves source code from the configured VCS root
- Performs clean checkout for consistent builds

### 2. Setup Dependencies
- Updates package manager in Ubuntu container
- Installs `curl` and `openjdk-11-jre-headless`
- Prepares the environment for SCA scanning

### 3. Environment Validation
- Validates that `DEVSECOPS_TOKEN` is provided
- Ensures all required parameters are configured

### 4. SCA Detector Download
- Downloads the SCA detector JAR if not present
- Creates necessary directories (`.scantist`)

### 5. SCA Scan Execution
- Creates report directory (`devsecops_report`)
- Executes the SCA scan with DevSecOps integration
- Generates JSON reports

### 6. Artifact Publishing
- Archives scan reports as build artifacts
- Makes reports available in TeamCity interface
- Processes XML reports for dashboard integration

## Customization

### Branch Filtering
Modify the VCS trigger to run on specific branches:

**Kotlin DSL:**
```kotlin
triggers {
    vcs {
        branchFilter = """
            +:refs/heads/main
            +:refs/heads/develop
            +:refs/heads/release/*
            -:refs/heads/feature/temp-*
        """.trimIndent()
    }
}
```

**XML:**
```xml
<build-trigger type="vcsTrigger">
    <parameters>
        <param name="branchFilter">+:refs/heads/main
+:refs/heads/develop
+:refs/heads/release/*
-:refs/heads/feature/temp-*</param>
    </parameters>
</build-trigger>
```

### Custom Docker Images
Use custom Docker images with pre-installed dependencies:

**Kotlin DSL:**
```kotlin
script {
    dockerImage = "your-registry/sca-scanner:latest"
    dockerImagePlatform = ScriptBuildStep.ImagePlatform.Linux
}
```

### Additional Build Steps
Add more build steps for comprehensive security scanning:

**Kotlin DSL:**
```kotlin
steps {
    // ... existing steps
    
    script {
        name = "SAST Scan"
        scriptContent = """
            echo "Running SAST scan..."
            # Add SAST scanning logic
        """.trimIndent()
    }
    
    script {
        name = "Container Scan"
        scriptContent = """
            echo "Running container scan..."
            # Add container scanning logic
        """.trimIndent()
    }
}
```

### Parallel Execution
Run multiple scans in parallel using build chains:

**Kotlin DSL:**
```kotlin
// Create separate build types for different scan types
object SastScan : BuildType({
    name = "SAST Security Scan"
    // SAST-specific configuration
})

object ContainerScan : BuildType({
    name = "Container Security Scan"
    // Container scanning configuration
})

// Create a build chain
object SecurityScanChain : BuildType({
    name = "Complete Security Scan"
    type = BuildTypeSettings.Type.COMPOSITE
    
    dependencies {
        snapshot(ScaScanBuild) {}
        snapshot(SastScan) {}
        snapshot(ContainerScan) {}
    }
})
```

## Environment Variables Reference

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `SCA_BOM_DETECT_DOWNLOAD_URL` | ✅ | - | URL to download the SCA detector JAR |
| `DEVSECOPS_TOKEN` | ✅ | - | Authentication token for DevSecOps platform (password) |
| `DEVSECOPS_IMPORT_URL` | ❌ | - | Optional import URL for DevSecOps integration |
| `ASYNC` | ❌ | `false` | Enable asynchronous processing |
| `SCA_JAR_NAME` | ❌ | `sca-bom-detect.jar` | Name of the SCA detector JAR file |
| `SCA_PLUGIN_DIR` | ❌ | `.scantist` | Directory to store SCA detector |
| `SCA_REPORT_DIR` | ❌ | `devsecops_report` | Directory for scan reports |

## Troubleshooting

### Common Issues

1. **Docker Permission Issues**:
   - Ensure TeamCity agents have Docker access
   - Verify Docker daemon is running on build agents
   - Check agent requirements for Linux compatibility

2. **Parameter Configuration**:
   - Verify password parameters are properly configured
   - Check parameter inheritance from project to build configuration
   - Ensure environment variable names match exactly

3. **VCS Integration Problems**:
   - Verify VCS root is properly configured
   - Check branch filter syntax and patterns
   - Ensure versioned settings are synchronized

4. **Artifact Publishing Issues**:
   - Check artifact rules syntax
   - Verify report directory exists after scan
   - Ensure build completes successfully before artifact collection

5. **Build Agent Compatibility**:
   - Verify agents meet Linux requirement
   - Check Docker image availability
   - Ensure sufficient disk space for artifacts

### Debug Mode

Enable verbose logging by modifying the SCA scan step:

**Kotlin DSL:**
```kotlin
script {
    scriptContent = """
        # Enable debug logging
        set -x
        
        # Your existing scan logic with additional logging
        java -jar "${'$'}{SCA_PLUGIN_DIR}/${'$'}{SCA_JAR_NAME}" \
            -f "${'$'}(pwd)" --debug -report json --verbose
    """.trimIndent()
}
```

### Build Investigation

Use TeamCity's build investigation features:
1. Enable build failure conditions
2. Set up build problem responsibility
3. Configure notification rules for failures
4. Use build log analysis for troubleshooting

## Integration with Other Tools

### Slack Notifications
Add Slack notifications using TeamCity's notification system:

1. **Configure Notifier**:
   - Go to Administration → Notification Rules
   - Add Slack notifier configuration
   - Set up webhook URL and channels

2. **Build-specific Notifications**:
```kotlin
features {
    notifications {
        notifierSettings = slackNotifier {
            connection = "slack-connection-id"
            sendTo = "#security-alerts"
            messageFormat = SlackMessageFormat.VERBOSE
        }
        branchFilter = "+:*"
        buildFailedToStart = true
        buildFailed = true
        buildFinishedSuccessfully = true
    }
}
```

### Email Notifications
Configure email notifications in project settings:

1. **SMTP Configuration**: Set up in Administration → Email Notifier
2. **User Notifications**: Configure per-user notification preferences
3. **Build-specific Rules**: Set up rules for security scan results

### Jira Integration
Integrate with Jira for issue tracking:

1. **Install Jira Plugin**: Add TeamCity-Jira integration plugin
2. **Configure Connection**: Set up Jira server connection
3. **Automatic Issue Creation**:
```kotlin
script {
    name = "Create Jira Issues"
    scriptContent = """
        # Parse scan results and create Jira issues
        if [ -f "${'$'}{SCA_REPORT_DIR}/findings.json" ]; then
            python scripts/create_jira_issues.py "${'$'}{SCA_REPORT_DIR}/findings.json"
        fi
    """.trimIndent()
}
```

### Quality Gates
Implement quality gates based on scan results:

**Kotlin DSL:**
```kotlin
failureConditions {
    // Fail build if critical vulnerabilities found
    buildFailureOnMetric {
        metric = BuildFailureOnMetric.MetricType.ARTIFACT_SIZE
        threshold = 0
        units = BuildFailureOnMetric.MetricUnit.DEFAULT_UNIT
        comparison = BuildFailureOnMetric.MetricComparison.MORE
        compareTo = BuildFailureOnMetric.MetricCompareTo.SUCCESSFUL_BUILDS_AVERAGE
    }
}
```

## Security Best Practices

1. **Secure Parameters**: Use password parameters for sensitive tokens
2. **Agent Isolation**: Use dedicated agents for security scanning
3. **Artifact Access Control**: Restrict access to security reports
4. **Regular Updates**: Keep SCA detector and TeamCity updated
5. **Audit Logging**: Enable detailed logging for security operations
6. **Network Security**: Ensure secure communication between agents and server

## Performance Optimization

### Build Caching
Implement caching for SCA detector and dependencies:

**Kotlin DSL:**
```kotlin
script {
    scriptContent = """
        # Cache SCA detector across builds
        CACHE_DIR="/opt/teamcity-agent/system/caches/sca-detector"
        mkdir -p "${'$'}CACHE_DIR"
        
        if [ ! -f "${'$'}CACHE_DIR/${'$'}{SCA_JAR_NAME}" ]; then
            curl -L -o "${'$'}CACHE_DIR/${'$'}{SCA_JAR_NAME}" "${'$'}{SCA_BOM_DETECT_DOWNLOAD_URL}"
        fi
        
        cp "${'$'}CACHE_DIR/${'$'}{SCA_JAR_NAME}" "${'$'}{SCA_PLUGIN_DIR}/${'$'}{SCA_JAR_NAME}"
    """.trimIndent()
}
```

### Resource Management
Configure appropriate resource limits:

**Kotlin DSL:**
```kotlin
requirements {
    contains("teamcity.agent.hardware.memorySizeMb", "4096")
    contains("teamcity.agent.hardware.cpuCount", "2")
}
```

### Build Chains
Use build chains for complex scanning workflows:

```kotlin
object SecurityScanChain : BuildType({
    name = "Security Scan Pipeline"
    type = BuildTypeSettings.Type.COMPOSITE
    
    dependencies {
        snapshot(ScaScanBuild) {
            onDependencyFailure = FailureAction.FAIL_TO_START
        }
        artifacts(ScaScanBuild) {
            artifactRules = "sca-reports.zip!** => sca-results/"
        }
    }
})
```

## Support

For issues related to:
- **TeamCity Configuration**: Check TeamCity documentation and build logs
- **SCA Scanning**: Verify Scantist platform connectivity and token validity
- **Template Customization**: Refer to TeamCity Kotlin DSL documentation
- **XML Configuration**: Use TeamCity's XML schema validation

## Migration from Other CI/CD Platforms

### From GitLab CI
- Map GitLab CI `variables` to TeamCity `parameters`
- Convert `before_script` to setup build steps
- Transform `artifacts` to TeamCity artifact rules
- Migrate `only/except` rules to branch filters

### From Jenkins
- Convert Jenkins Pipeline stages to TeamCity build steps
- Map Jenkins environment variables to TeamCity parameters
- Transform Jenkins `post` actions to TeamCity build features
- Migrate Jenkins agents to TeamCity build agents

### From CircleCI
- Convert CircleCI executors to TeamCity Docker integration
- Map CircleCI commands to TeamCity build steps
- Transform CircleCI workflows to TeamCity build chains
- Migrate CircleCI contexts to TeamCity parameter inheritance

---

**Note**: This template is designed to mirror the functionality of the GitLab CI `bom-sca-scan.yml`, Jenkins `bom-sca-scan.jenkinsfile`, and CircleCI `config.yml` templates, providing consistent security scanning across all major CI/CD platforms.
