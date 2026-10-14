# FATHER DevSecOps — minimal threat graph schema

## Node types
Lesson, System, Asset, KubernetesObject, ThreatScenario, Requirement, RegulationClause, Control, Check, Evidence, Finding, Risk, Exception, Change, Release.

## Edge types
LESSON_COVERS, HOSTS, EXPOSES, THREATENS, APPLIES_TO, MITIGATED_BY, TESTED_BY, PRODUCED, SUPPORTED_BY, CONFLICTS_WITH, FIXED_BY, RELEASED_IN.

## Mandatory provenance
source_uri, source_version, observed_at, document_section, extraction_method, reviewer, confidence, lifecycle_state.

## Separate scores
likelihood, impact, exposure, evidence_confidence, remediation_priority (do not collapse into one undifferentiated weight). Unknown != zero.

## Example
LESSON-02 -> LESSON_COVERS -> Deployment;
Deployment -> EXPOSES -> DST-001;
DST-001 -> MITIGATED_BY -> allowPrivilegeEscalation:false;
Control -> TESTED_BY -> K8S-ESCALATION;
Check -> PRODUCED -> security-report.json.

Reminder: heuristic scanner findings need validation, and normative applicability is determined by the system context, not merely a YAML property.
