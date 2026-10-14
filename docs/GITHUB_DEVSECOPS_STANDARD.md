# Secure GitHub development standard (OTUS + FATHER)

## Required human workflow
Issue -> short-lived feature branch -> changes -> local tests -> Pull Request -> CI -> review -> merge -> tagged release -> deployed manifest -> observed evidence.

## Branch strategy
- main: stable branch, protected by ruleset when enabled by repository owner.
- feature/*, fix/*, docs/*, security/*: isolated changes.
- No direct pushes to main after protection is enabled; no force-push; no branch deletion of main.
- Use Conventional Commits: feat:, fix:, docs:, test:, security:, chore:.
- Require PR with at least one approval when a second independent human reviewer is available. AI agent does not count as independent approval.
- Require green tests and review of all alerts before merge. Never use blanket suppressions.

## Security baseline
- Enforce MFA/passkeys for maintainers; least-privilege collaborator access.
- Restrict Actions permissions to read-only by default. Avoid untrusted pull_request_target with secrets.
- Turn on secret scanning/push protection, Dependabot alerts/updates, CodeQL where available.
- Avoid committing .env, kubeconfigs, keys, PDFs with confidential data.
- Scan with gitleaks, semgrep, trivy/checkov and test Kubernetes YAML in controlled, version-pinned CI (progressive additions).
- Pin third-party GitHub Actions to full commit SHA after verifying trusted releases; starter workflow currently uses major tags and does NOT yet satisfy that hardening rule.
- Prefer workload identity/OIDC for cloud credentials; avoid long-lived GitHub secrets.
- CI findings should fail release gates once false positives and baselines are tuned.
- Store threat-to-control-to-test-to-evidence links for audit.

## Recommended repo settings (must configure in GitHub UI)
Settings > Rules > Rulesets or Branches > branch protection for main:
  Require PR, checks, block force-push/deletion, conversation resolution, restrict bypass.
Settings > Actions > General:
  default GITHUB_TOKEN read-only and restrict untrusted actions as needed.
Settings > Security / Advanced Security (availability varies):
  enable security scanning and Dependabot; validate plan-dependent features.
Set 2FA on account.

## Current limitations
The initial Security CI includes Python unit tests and a basic token-pattern check. The manifest auditor is informational in CI while risk rules are being tuned (continue-on-error). It is **not** a full GitHub security baseline yet. No production deploy or secrets access.
