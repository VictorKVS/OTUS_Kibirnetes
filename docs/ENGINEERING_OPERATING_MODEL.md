# FATHER / OTUS: secure engineering operating model

Status: proposed operating model, not proof of production deployment. Created 2026-10-14.

## One delivery cycle, for every lesson and every project
1. Intake: requirement, system boundary, data classification, acceptance criteria and owner.
2. Threat model: reference scenario in SECURITY/threats/devsecops_top100.csv; identify assets and attacker assumptions.
3. Architecture: diagram, trust boundaries, integration and threat-control-test-evidence chain.
4. Implement in feature branch with versioned manifests and tests.
5. Local security review: lint, static analysis, secrets, dependencies, container images, IaC/K8s config.
6. Pull Request: automated CI checks and independent human review; exception requires expiry, owner and rationale.
7. Build provenance + SBOM + release tag (future work).
8. Deploy via GitOps to test stage, policy gates, runtime validation.
9. Observe: events, audit logs, drift, vulnerabilities, incident response and rollback.
10. Archive reproducible evidence: outputs, hashes, screenshots and test results without leaking personal data or secrets.

## Responsibilities
- Architect/FATHER: design and traceability, no unilateral production approval.
- Analyst/Alina: sources, requirements, applicability and evidence.
- OSINT: verified vulnerability/technology intelligence with provenance.
- DevOps/Platform: build pipelines, infrastructure, release and rollback.
- Security agent: offline static checks initially; later scanner orchestration.
- QA: functional/security acceptance testing.
- Human maintainer/security owner: authorizes active tests, risk exceptions and releases.

## Mandatory controls for Kubernetes DZ-01
- Original instructor manifests retained unmodified.
- Read-only baseline audit report, with reviewed false positives.
- Separate hardened deployment/example; do not overwrite instructor version.
- Confirm exact context/namespace before apply.
- Capture Pod+Deployment, 3->5 scaling, nginx 1.28 and rollout.
- Never commit kubeconfig, plaintext secrets, private tokens or confidential screenshots.

## Gate status
Implemented in repository: risk register (100 candidate scenarios), local read-only YAML auditor, PR CI starter, test and PR templates.
Not yet implemented or validated: standalone LLM agent, live cluster scanner, automated threat graph, secrets/code/dependency scanners in CI, signed builds, enforced branch rules, tested GitOps deployments.
