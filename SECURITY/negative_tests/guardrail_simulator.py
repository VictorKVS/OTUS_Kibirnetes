#!/usr/bin/env python3
"""FATHER: deterministic OFFLINE policy simulator. No kubectl, docker, shell, or network calls."""
import json
import sys
from pathlib import Path

ALLOWED_TARGET = "otus-k8s"
ALLOWED_NAMESPACE = "otus-k8s-dz01"
READ_ONLY = {"minikube.healthcheck"}
GUARDED = {"kubectl.apply", "minikube.delete"}

def decide(action, context):
    if action not in READ_ONLY | GUARDED:
        return "deny"
    if context.get("target") != ALLOWED_TARGET:
        return "deny"
    if action in READ_ONLY:
        return "allow_read_only"
    if action == "kubectl.apply" and context.get("namespace") != ALLOWED_NAMESPACE:
        return "deny"
    if not context.get("approval", False):
        return "require_approval"
    if not context.get("policy_ok", True):
        return "deny"
    if context.get("runner_available", True) is False:
        return "fail_closed"
    return "allow_guarded"

def main():
    path = Path(__file__).with_name("scenarios.json")
    cases = json.loads(path.read_text(encoding="utf-8"))["scenarios"]
    results = []
    for case in cases:
        observed = decide(case["action"], case["context"])
        results.append({"id":case["id"],"expected":case["expect"],"observed":observed,"passed":observed == case["expect"]})
    failures = [r for r in results if not r["passed"]]
    print(json.dumps({"mode":"simulation-only","passed":len(results)-len(failures),"total":len(results),"results":results},ensure_ascii=False,indent=2))
    return 1 if failures else 0

if __name__ == "__main__":
    sys.exit(main())
