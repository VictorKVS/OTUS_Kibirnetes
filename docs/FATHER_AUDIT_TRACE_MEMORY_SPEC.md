# FATHER Engineering — Audit, Knowledge, Traceability Specification v0.1

Status: design specification, NOT deployed or certified. 2026-10-14.

## Fundamental contract

Every button action SHALL have a predefined allowlisted operation, actor, task, project, scope, input validation, approval policy, idempotency key, timestamp and expected outcome. No arbitrary shell execution from browser. High-risk mutations need explicit human approval.

### Event envelope
```json
{
  "event_id":"UUIDv7","trace_id":"UUID","span_id":"UUID",
  "occurred_at":"2026-10-14T12:00:00+03:00",
  "project_id":"OTUS-K8S","lesson_id":"02","task_id":"DZ-01",
  "actor_type":"human|agent|runner","actor_id":"stable-id",
  "operation":"minikube.healthcheck","operation_version":"1.0",
  "target":"local:otus-k8s","scope":"read-only",
  "input_digest":"sha256:...","result":"failed","error_code":"GUEST_NOT_FOUND",
  "artifact_ids":["EV-..."],"parent_event_id":null,
  "approval_id":null,"policy_version":"sec-policy-1","record_schema_version":"1.0"
}
```
Do not record passwords, tokens, secrets, raw personal information or sensitive prompts in event payloads. Generate trace IDs server-side; authenticate the actual human actor; do not trust actor IDs from browser input. Correlate across frontend → API → orchestrator → runner → Git/CI → Kubernetes.

## Storage separation
1. Source code + change history: Git repositories.
2. Development Journal: decisions, ADRs, risks, tests, changes linked to commits/PRs.
3. Execution Ledger: append-only structured action events; RBAC, integrity control and retention rules.
4. Security Audit Log: security-relevant authentication, authorization, policy and administrative events; restricted access and external forwarding.
5. Incident Registry: incident lifecycle, root cause, corrective/preventive actions, retest.
6. Knowledge Base / Graph: normalized and verified propositions and references, with source provenance, validity period, versions, confidence and reviewers.
7. Agent Memory: operational context, possibly fallible and mutable; NEVER source of truth for audit.
8. Evidence Store: immutable/versioned artifacts, hashes, metadata, retention and access controls. SHA-256 detects accidental/intentional modification when checked against trusted independent digest; by itself doesn't prove authorship.

## Minimum trace graph
Requirement -> Threat -> Control -> Test -> Run -> Evidence -> Finding -> Remediation -> PR -> Build -> Release -> Deployment -> Runtime Observation.
Each edge records source, actor, timestamp, policy version and validation status; unknown and unverified edges do not receive PASS.

## UI requirements
Every action panel shows: what/why, affected assets, access rights, prerequisites, threat controls, source documentation, simulated/real mode, risk class, explicit confirmation (if required), progress status, real output, error reason, guided safe remediation, rollback or manual alternative, links to journal/evidence.
All actions require server-side auth and authorization. Use request timeouts, concurrency limits, CSRF protection where relevant, network isolation, structured logging, correlation IDs and rate limiting.
Buttons never claim success without validated backend completion.

## Regulatory support
- ГОСТ Р 56939-2024, particularly §§4.11–4.13: evidence artifacts, version control, CI, task/error tracking and traceability: https://base.garant.ru/410749342/
- ФСТЭК methodological document of 12.04.2026, security event registration measures РСБ.1 etc.: https://base.garant.ru/414070697/
- Existing Russian regulatory applicability register: SECURITY/regulations/RU_REGULATORY_MAP.md.
- Determine applicability per system class, information category, regulatory edition, actual legal requirements and approved threat model. No blanket claim of FSTEC compliance / certification.

## Required acceptance tests (future implementation)
- One action generates trace events + source-link + human-readable journal without exposing secrets.
- Unauthorized action denied and denial logged.
- Mutation with high risk cannot run without valid human approval.
- All artifacts can be retrieved by trace_id, and evidence hash checked.
- A repeated action does not duplicate destructive changes.
- A disconnected runner generates failure/timeout and no fake success.
- Event retention and RBAC enforced; failures to persist audit events cause safe failure for critical operations.
- Export auditor dossier: system scope, requirements mapping, evidence index, responsible actors, test reports, exceptions.
- Verify backup and restore of audit/event/evidence metadata.
