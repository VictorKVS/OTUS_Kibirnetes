#!/usr/bin/env python3
"""FATHER DevSecOps Security Agent MVP: read-only local Kubernetes YAML audit."""
import argparse
import json
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    sys.exit("Install dependency: python -m pip install pyyaml")

def audit_doc(obj, source):
    found = []
    if not isinstance(obj, dict):
        return found
    kind = obj.get("kind", "")
    meta = obj.get("metadata") or {}
    name = meta.get("name", "unnamed")
    spec = obj.get("spec") or {}
    if kind == "Pod":
        template_spec = spec
    elif kind in ("Deployment", "StatefulSet", "DaemonSet", "Job"):
        template_spec = ((spec.get("template") or {}).get("spec") or {})
    elif kind == "CronJob":
        template_spec = (((((spec.get("jobTemplate") or {}).get("spec") or {}).get("template") or {}).get("spec")) or {})
    else:
        return found
    def issue(rule, severity, message, owasp="K01"):
        found.append({"rule":rule,"severity":severity,"source":str(source),"kind":kind,"resource":name,"message":message,"owasp":owasp})
    if template_spec.get("hostNetwork"):
        issue("K8S-HOST-NET","HIGH","Host network enabled","K05")
    if template_spec.get("hostPID") or template_spec.get("hostIPC"):
        issue("K8S-HOST-NS","HIGH","Host PID/IPC namespace enabled")
    if template_spec.get("automountServiceAccountToken", True):
        issue("K8S-SA-TOKEN","MEDIUM","ServiceAccount token automount not disabled","K02")
    for vol in template_spec.get("volumes") or []:
        if "hostPath" in vol:
            issue("K8S-HOST-PATH","HIGH","Host path volume present")
    for container in (template_spec.get("containers") or []) + (template_spec.get("initContainers") or []):
        n = container.get("name","unnamed")
        image = container.get("image","")
        sc = container.get("securityContext") or {}
        if not image or image.endswith(":latest") or (":" not in image.rsplit("/",1)[-1] and "@sha256:" not in image):
            issue("K8S-IMAGE-TAG","MEDIUM",f"{n}: missing pinned image tag/digest","K07")
        if sc.get("privileged"):
            issue("K8S-PRIVILEGED","CRITICAL",f"{n}: privileged enabled")
        if sc.get("allowPrivilegeEscalation") is not False:
            issue("K8S-ESCALATION","HIGH",f"{n}: allowPrivilegeEscalation not false")
        if sc.get("runAsNonRoot") is not True:
            issue("K8S-NONROOT","HIGH",f"{n}: runAsNonRoot not true")
        if sc.get("readOnlyRootFilesystem") is not True:
            issue("K8S-ROOTFS","MEDIUM",f"{n}: root filesystem not explicitly read-only")
        caps = (sc.get("capabilities") or {}).get("drop") or []
        if "ALL" not in caps:
            issue("K8S-CAPABILITIES","MEDIUM",f"{n}: capabilities.drop does not include ALL")
        resources = container.get("resources") or {}
        if not (resources.get("limits") and resources.get("requests")):
            issue("K8S-RESOURCES","MEDIUM",f"{n}: missing resource requests or limits")
        if not container.get("readinessProbe"):
            issue("K8S-READINESS","LOW",f"{n}: readinessProbe missing")
        for env in container.get("env") or []:
            if any(x in str(env.get("name","")).upper() for x in ("PASSWORD","SECRET","TOKEN","API_KEY")) and "value" in env:
                issue("K8S-PLAINTEXT-SECRET","HIGH",f"{n}: potential plain-text credential in env","K03")
    return found

def main():
    ap = argparse.ArgumentParser(description="Local read-only audit of Kubernetes YAML manifests")
    ap.add_argument("target", help="A YAML file or directory")
    ap.add_argument("--output", default="security-report.json")
    args = ap.parse_args()
    target = Path(args.target)
    if not target.exists():
        sys.exit("Target does not exist: " + str(target))
    paths = [target] if target.is_file() else sorted([*target.rglob("*.yaml"), *target.rglob("*.yml")])
    findings, errors = [], []
    for path in paths:
        try:
            for obj in yaml.safe_load_all(path.read_text(encoding="utf-8-sig")):
                findings.extend(audit_doc(obj,path))
        except (yaml.YAMLError, UnicodeError, OSError) as e:
            errors.append({"file":str(path),"error":str(e)})
    report = {"agent":"FATHER-DevSecOps-MVP","mode":"local-read-only","files_checked":len(paths),"findings":findings,"errors":errors}
    Path(args.output).write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf-8")
    print(f"Files: {len(paths)} | Findings: {len(findings)} | Errors: {len(errors)}")
    for f in findings:
        print(f"[{f['severity']}] {f['rule']} {f['resource']}: {f['message']}")
    print("Report:",args.output)
    return 2 if errors or any(f["severity"] in ("HIGH","CRITICAL") for f in findings) else 0

if __name__ == "__main__":
    sys.exit(main())
