# Scantist BOM SCA Scanning - GitLab CI Template

Minimal GitLab CI template for BOM (Bill of Materials) SCA scanning using Scantist.

## Files

- `bom-sca-scan.yml` - Main BOM SCA scanning template
- `example-usage.yml` - Usage example
- `bom-sca.sh` - Standalone shell script version

## Quick Start

1. **Include in your `.gitlab-ci.yml`:**
   ```yaml
   include:
     - local: 'v1/ci-templates/gitlab-ci/bom-sca-scan.yml'
   
   variables:
     SCA_BOM_DETECT_DOWNLOAD_URL: "https://download.xxxx.io/sca-bom-detect.jar"
     DEVSECOPS_TOKEN: "${DEVSECOPS_TOKEN}"
   ```

2. **Set GitLab CI/CD variables:**
   - `DEVSECOPS_TOKEN` (required, protected, masked)
   - `DEVSECOPS_IMPORT_URL` (optional)
   - `SCA_BOM_DETECT_DOWNLOAD_URL` (JAR download URL)

3. **Commit and push** - BOM SCA scan runs automatically!

## What it does

- Downloads `sca-bom-detect.jar` automatically
- Scans project dependencies for vulnerabilities
- Uploads results to DevSecOps platform
- Generates reports in `devsecops_report/` folder
- Integrates with GitLab Security Dashboard


## Local GitLab Installation

### Prerequisites

- Docker
- User in docker group

### Usage

Run these 3 scripts in the `local-install-docker-ce/` directory:

```bash
cd local-install-docker-ce/
./install-gitlab-locally.sh
./gitlab-ci-locally.sh
./gitlab-ci-runner-locally.sh
```
Remember to change the hardcoded IP (192.168.0.173) in the scripts to your own.