import jetbrains.buildServer.configs.kotlin.*
import jetbrains.buildServer.configs.kotlin.buildSteps.script
import jetbrains.buildServer.configs.kotlin.triggers.vcs

/*
 * SCA Scan - TeamCity Configuration Template (Kotlin DSL)
 * =======================================================
 *
 * Simple, modular SCA (Software Composition Analysis) scanning configuration
 * Uses sca-bom-detect.jar to scan dependencies for vulnerabilities
 *
 * USAGE:
 * ------
 * 1. Copy this file to .teamcity/settings.kts in your repository
 * 2. Configure the required parameters in TeamCity project settings:
 *    - SCA_BOM_DETECT_DOWNLOAD_URL
 *    - DEVSECOPS_TOKEN
 *    - DEVSECOPS_IMPORT_URL (optional)
 *    - ASYNC (optional, defaults to false)
 * 3. Push to trigger the SCA scan build configuration
 */

version = "2023.11"

project {
    description = "Scantist SCA Security Scanning Project"

    buildType(ScaScanBuild)

    params {
        // Global project parameters - equivalent to GitLab CI variables
        param("SCA_BOM_DETECT_JAR", "sca-bom-detect.jar")
        param("SCA_JAR_NAME", "sca-bom-detect.jar")
        param("SCA_PLUGIN_DIR", ".scantist")
        param("SCA_REPORT_DIR", "devsecops_report")
        param("ASYNC", "false") // defaults to false if not set
        
        // These should be configured as secure parameters in TeamCity UI
        param("env.SCA_BOM_DETECT_DOWNLOAD_URL", "")
        password("env.DEVSECOPS_TOKEN", "")
        param("env.DEVSECOPS_IMPORT_URL", "")
    }
}

object ScaScanBuild : BuildType({
    name = "SCA Security Scan"
    description = "Software Composition Analysis scanning using sca-bom-detect.jar"

    // VCS settings
    vcs {
        root(DslContext.settingsRoot)
        cleanCheckout = true
    }

    // Build steps
    steps {
        // Step 1: Setup Dependencies - equivalent to GitLab CI before_script
        script {
            name = "Setup Dependencies"
            id = "setup_dependencies"
            scriptContent = """
                echo "📦 Installing required dependencies..."
                apt-get update
                apt-get install -y curl openjdk-11-jre-headless
                echo "✅ Dependencies installed successfully"
            """.trimIndent()
            dockerImage = "ubuntu:latest"
            dockerImagePlatform = ScriptBuildStep.ImagePlatform.Linux
        }

        // Step 2: SCA Scan - equivalent to GitLab CI script
        script {
            name = "SCA Security Scan"
            id = "sca_scan"
            scriptContent = """
                echo "🔍 Starting Scantist SCA scan..."
                
                # Validate DevSecOps token is provided
                if [[ -z "${'$'}{DEVSECOPS_TOKEN:-}" ]]; then
                    echo "[SCA ERROR] DEVSECOPS_TOKEN environment variable is required" >&2
                    exit 1
                fi
                
                # Download SCA detector if not exists
                if [[ ! -f "${'$'}{SCA_PLUGIN_DIR}/${'$'}{SCA_JAR_NAME}" ]]; then
                    echo "[SCA] Downloading SCA detector..."
                    mkdir -p "${'$'}{SCA_PLUGIN_DIR}"
                    curl -L -o "${'$'}{SCA_PLUGIN_DIR}/${'$'}{SCA_JAR_NAME}" "${'$'}{SCA_BOM_DETECT_DOWNLOAD_URL}"
                    echo "[SCA] Download completed"
                fi
                
                # Create report directory
                mkdir -p "${'$'}{SCA_REPORT_DIR}"
                
                # Run SCA scan with DevSecOps integration
                echo "[SCA] Starting scan on: ${'$'}(pwd)"
                echo "[SCA] DevSecOps integration enabled"
                
                env DEVSECOPS_TOKEN="${'$'}{DEVSECOPS_TOKEN}" \
                    ${'$'}{DEVSECOPS_IMPORT_URL:+DEVSECOPS_IMPORT_URL="${'$'}{DEVSECOPS_IMPORT_URL}"} \
                    java -jar "${'$'}{SCA_PLUGIN_DIR}/${'$'}{SCA_JAR_NAME}" -f "${'$'}(pwd)" --debug -report json
                
                echo "[SCA] Scan completed. Reports in: ${'$'}{SCA_REPORT_DIR}"
            """.trimIndent()
            dockerImage = "ubuntu:latest"
            dockerImagePlatform = ScriptBuildStep.ImagePlatform.Linux
        }
    }

    // Build triggers
    triggers {
        vcs {
            id = "vcsTrigger"
            branchFilter = """
                +:*
                -:refs/heads/temp-*
            """.trimIndent()
        }
    }

    // Artifact publishing - equivalent to GitLab CI artifacts
    artifactRules = """
        %SCA_REPORT_DIR%/** => sca-reports.zip
        %SCA_REPORT_DIR%/*.json => sca-reports-json.zip
    """.trimIndent()

    // Build features
    features {
        // Archive artifacts on build completion
        feature {
            type = "xml-report-plugin"
            param("xmlReportParsing.reportType", "findBugs")
            param("xmlReportParsing.reportDirs", "%SCA_REPORT_DIR%/*.xml")
        }
    }

    // Requirements
    requirements {
        contains("teamcity.agent.jvm.os.name", "Linux")
    }

    // Failure conditions
    failureConditions {
        executionTimeoutMin = 30
        nonZeroExitCode = true
    }

    // Build options
    options {
        artifactRules = "%SCA_REPORT_DIR%/**"
        publishArtifacts = PublishMode.SUCCESSFUL
    }

    // Parameters specific to this build configuration
    params {
        // Override global parameters if needed
        param("teamcity.build.workingDir", ".")
    }
})
