# FATHER Factory integration contract — Kubernetes + DevSecOps

Integration target: VictorKVS/OTUS- branch feature/otus-homework-site, factory/. This document does not assert integration has been deployed.

## Source of truth
- Course lessons: LESSONS/01 through LESSONS/08 in this repo.
- Homework: DZ_01 and subsequent assignments.
- Security scenario catalog: SECURITY/threats/devsecops_top100.csv.
- Security auditor: SECURITY/agent/audit_k8s.py.
- Source normative map: SECURITY/regulations/RU_REGULATORY_MAP.md.
- CI baseline (pending PR): .github/workflows/security-ci.yml.
- Human review / evidence: pull requests and evidence store.

## Factory stage I/O
Input: lesson ID, repo/ref, manifests, risk scope, system classification, access approval.
Agents: Alina (requirements) -> DevOps (implementation) + DevSecOps (audit) -> QA -> FATHER supervisor.
Output: threat-control-test-evidence records; JSON audit; PR checks; release decision.
Security checks cannot authorize active testing or production release autonomously.

## Site features
- Visible navigation to Kubernetes/DevSecOps course.
- Eight lessons mapped to threat/control checkpoints.
- Status: roadmap / scaffold / live evidence separately, never infer completion.
- Build-time data from public Git files; prohibit committing credentials or personal data.
