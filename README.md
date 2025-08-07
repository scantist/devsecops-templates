# devsecops-templates

## TODO: 

### 1. GitLab Security Dashboard Integration Issues

The `bom-sca-scan.yml` template currently works and executes successfully, but shows GitLab errors related to Security Dashboard integration. The main issues identified are:

1. **GitLab Security Dashboard Integration Issue:**
   - The JSON format might not match GitLab's expected schema, causing parsing errors
   - GitLab expects specific JSON report format for security vulnerabilities

2. **Missing Report Files:**
   - The template expects JSON reports in `devsecops_report/*.json`, but if the SCA tool generates reports in a different format or location, GitLab will show errors about missing report files

#### Most Likely Cause
The GitLab Security Dashboard integration (`dependency_scanning`) report is probably the main source of errors. GitLab expects a very specific JSON schema for security reports, and if the SCA tool generates reports in a different format, GitLab will show errors even though the scan completed successfully.

#### Potential Solutions
1. **Update JSON Schema:** Ensure the generated reports match GitLab's dependency scanning report schema
2. **Add Report Validation:** Add validation steps to check if reports are in the correct format before GitLab processes them
3. **Configure Artifact Paths:** Verify that artifact paths match the actual output locations
4. **Add Error Handling:** Implement better error handling for missing environment variables and report generation failures

#### Status
- ✅ Template executes successfully
- ❌ GitLab Security Dashboard integration shows errors
- 🔄 Investigation needed for JSON schema compatibility
