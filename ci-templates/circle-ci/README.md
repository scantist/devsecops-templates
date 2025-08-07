# CircleCI SCA Orb

SCA (Software Composition Analysis) scanning orb for CircleCI with DevSecOps integration.

## Status: 

Orb `scan/sca@0.0.14` is published and functional with simplified scan logic.
Link: https://circleci.com/developer/orbs/orb/scan/sca

## Quick Start

```yaml
version: 2.1

orbs:
  sca: scan/sca@0.0.14

workflows:
  version: 2
  build-test-workflow:
    jobs:
      - sca/sca-scan:
          context: scantist-security
```

## Environment Variables

**Required:**
- `DEVSECOPS_TOKEN` - DevSecOps platform authentication token

**Optional:**
- `DEVSECOPS_IMPORT_URL` - Import URL for DevSecOps platform

## Publishing New Versions

```bash
./publish-orb.sh publish <version>
```

## TODO

- [ ] Add support for custom scan parameters
- [ ] Implement vulnerability threshold settings
- [ ] Add support for multiple report formats
- [ ] Create orb usage examples and documentation
- [ ] Add integration tests for orb functionality
- [ ] Optimize Docker image size for faster builds
- [ ] Add support for private registries
- [ ] Implement scan result caching
- [ ] Add Slack/Teams notification integration
- [ ] Create orb development and testing guide

## Files

- `orb.yml` - Main orb definition (working version)
- `config.yml` - Original CircleCI template (reference)
- `publish-orb.sh` - Script to publish new orb versions
- `README.md` - This documentation

## Publishing Orb
```bash
# Validate
./publish-orb.sh validate

# Publish development
./publish-orb.sh full-dev

# Publish production
./publish-orb.sh publish 0.0.12
```

## Structure
- `config.yml` - Template configuration
- `src/` - Orb source files
- `bootstrap.sh` - Setup script
- `publish-orb.sh` - Publishing helper

## Features
- Dependency vulnerability scanning
- DevSecOps platform integration
- Artifact storage
- Parameterized configuration
