# FATHER DevSecOps Security — Kubernetes security track

## Current status
- 100 author-designed risk scenarios (NOT an official ranked Top-100): [threats/devsecops_top100.csv](threats/devsecops_top100.csv), 10 scenarios per category of OWASP Kubernetes Top 10 (2025).
- Read-only static audit MVP: [agent/audit_k8s.py](agent/audit_k8s.py). This is a rule-based CLI, **not** yet a deployed autonomous LLM agent; no cluster access, no active penetration testing, no automatic fixes.
- Each finding must eventually join nodes: lesson -> Kubernetes object -> threat -> source -> control -> check -> evidence -> remediation -> exception.

## Launch on Windows (after syncing repository)
```powershell
cd 'G:\1\OTUS_Kibirnetes'
python -m pip install pyyaml
python .\SECURITY\agent\audit_k8s.py .\DZ_01\manifests --output .\DZ_01\security-report.json
$LASTEXITCODE
```
Exit code 0: no HIGH/CRITICAL rule hit and no parsing failures; exit 2: at least one HIGH/CRITICAL issue or file error. This does **not** guarantee security. Tool performs static heuristic review of Pod/Deployment/StatefulSet/DaemonSet/Job/CronJob; no active tests. Review results manually.

## OWASP categories: 2025
K01 insecure workload configurations; K02 excessive authorization; K03 secrets failures; K04 missing cluster policies; K05 network segmentation; K06 exposed components; K07 vulnerable/misconfigured components; K08 cloud pivot; K09 authentication; K10 logging and monitoring.

## Course security gates
| Lesson | Security emphasis | Evidence |
|---|---|---|
| 01 Introduction | API access, cluster inventory, kubeconfig permissions | node & API audit |
| 02 Objects (DZ-01) | securityContext, image, resources, ServiceAccount, workload policies | manifest report, Pod status |
| 03 Networking | ingress/egress, NetworkPolicy, DNS, TLS | policy examples and allowed connectivity |
| 04 Storage | PVC, secrets, encryption, backup/restore | access test & restore evidence |
| 05 Resources | requests/limits, quotas, DoS resilience | metrics, quotas, controlled load test |
| 06 Service Mesh | mTLS, service identity, cert rotation | auth policy validation |
| 07 Cluster deployment | CIS baseline, etcd/kubelet/API, patching | control plane hardening checks |
| 08 Git CI/CD | secret scanning, SAST, SCA, SBOM, signatures | reproducible CI outputs |

## Verified external resources (check source version and applicability)
- OWASP Kubernetes Top 10 2025: https://owasp.github.io/www-project-kubernetes-top-ten/
- MITRE ATT&CK Containers: https://attack.mitre.org/matrices/enterprise/containers/
- NSA/CISA Kubernetes Hardening Guidance 1.2: https://www.nsa.gov/Press-Room/Digital-Media-Center/Document-Gallery/igphoto/2003066362/
- NIST SP 800-190: https://csrc.nist.gov/pubs/sp/800/190/final
- CNCF Cloud Native Security Whitepaper: https://www.cncf.io/reports/cloud-native-security-whitepaper/
- Kubescape: https://github.com/kubescape/kubescape
- Trivy: https://github.com/aquasecurity/trivy
- Checkov: https://github.com/bridgecrewio/checkov
- kube-bench: https://github.com/aquasecurity/kube-bench
- Kubernetes Security — Liz Rice, Michael Hausenblas, O'Reilly: https://www.oreilly.com/library/view/kubernetes-security/9781492039075/

## Russian regulatory knowledge graph — source registry, not automatic legal applicability
- ГОСТ Р 56939-2024 (secure software development): https://protect.gost.ru/gost/details/f3818925-a96f-4f55-96e9-46b44720ee64
- ГОСТ Р ИСО/МЭК 27001-2021 (ISMS): https://protect.gost.ru/gost/details/5e4acc56-cecf-41d4-a64f-95b3bac0d54f
- Russian regulatory layers to research individually: 149-ФЗ, 152-ФЗ, 187-ФЗ, ФСТЭК rules for ГИС, ИСПДн, КИИ, applicable ФСБ requirements; relevant edition and legal scope **must be verified** before mapping controls. Standard publication is not equivalent to mandatory legal applicability.

## Next acceptance criteria
1. Verify local Minikube cluster is Ready; don't delete existing Docker images/volumes.
2. Keep original instructor YAML and additional hardened YAML as distinct files.
3. Run auditor against DZ-01, inspect findings; manually adjudicate false positives.
4. Later integrate Trivy/Kubescape, export SARIF/JSON, GitHub CI, knowledge graph, FATHER Factory visualization.
5. No credentials or raw private datasets stored in this repo.
