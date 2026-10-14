# Regulatory mapping — research registry (14 Oct 2026)

The applicability of each normative document depends on the information system, operator, protected data, and legal scope. This file does **not** claim that every Kubernetes cluster is subject to these requirements.

| Document | Scope to evaluate | Source |
|---|---|---|
| ГОСТ Р 56939-2024 | Secure software development process | https://protect.gost.ru/gost/details/f3818925-a96f-4f55-96e9-46b44720ee64 |
| ГОСТ Р ИСО/МЭК 27001-2021 | ISMS | https://protect.gost.ru/gost/details/5e4acc56-cecf-41d4-a64f-95b3bac0d54f |
| ФСТЭК приказ №117 от 11.04.2025 | Protection of information in ГИС and other covered government systems; effective 01.03.2026; check amendments including №137 (2026) | https://base.garant.ru/483426443/ |
| ФСТЭК приказ №21 от 18.02.2013 | Measures for ИСПДн when applicable | https://www.consultant.ru/document/cons_doc_LAW_146520/ |
| ФСТЭК приказ №239 от 25.12.2017 | Security of significant critical information infrastructure facilities under 187-ФЗ | https://base.garant.ru/71901880/ |

Graph relationships to implement: System -> processes information category -> falls under rule -> requires protection measure -> implemented by K8s/DevSecOps control -> verified by test -> supported by evidence.

For current Russian government information systems, do not silently cite old приказ №17 as the operative requirement without checking changes and replacement by №117.

Books and methodological sources:
- Liz Rice & Michael Hausenblas, Kubernetes Security: https://www.oreilly.com/library/view/kubernetes-security/9781492039075/
- NIST SP 800-190: https://csrc.nist.gov/pubs/sp/800/190/final
- CNCF Cloud Native Security Whitepaper: https://www.cncf.io/reports/cloud-native-security-whitepaper/
- NSA/CISA Kubernetes Hardening Guidance v1.2: https://www.nsa.gov/Press-Room/Digital-Media-Center/Document-Gallery/igphoto/2003066362/

Next: link individual regulatory clauses to specific controls, never claim regulatory compliance from a single YAML check.
