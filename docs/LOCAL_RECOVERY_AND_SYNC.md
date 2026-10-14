# Local recovery and repository synchronization (PowerShell)

This is a guide, **not** a claim that the Windows host was modified. Preserve existing disks, containers, Docker volumes and image caches.

## Observed failures, 2026-10-14
- Minikube 1.39.0 profile otus-k8s contains invalid state: missing C:\Users\1\.minikube\machines\otus-k8s\config.json.
- `kubectl --context otus-k8s` has no context because cluster initialization did not finish.
- PyYAML 6.0.3 installed but `G:\1\OTUS_Kibirnetes\SECURITY\agent\audit_k8s.py` missing locally because remote changes have not been synced.

## Diagnosis — first step
```powershell
minikube profile list
minikube status -p otus-k8s
docker ps -a --filter "name=otus-k8s"
Test-Path "$env:USERPROFILE\.minikube\machines\otus-k8s\config.json"
```
If the Minikube profile is broken, `minikube delete -p otus-k8s` removes that named local cluster, not unrelated Docker images or volumes. Check that it is a disposable lab profile before deletion. Do not run prune/reset.

If a clean start again fails with `icacls`, collect full error and stop. Never recursively change security ACLs of the user profile as a generic workaround.

## Local Git checkout without overwriting an existing non-Git directory
```powershell
$Root = 'G:\1\OTUS_Kibirnetes'
$Mirror = Join-Path $Root '_github_snapshot'
if (-not (Test-Path $Mirror)) {
    git clone https://github.com/VictorKVS/OTUS_Kibirnetes.git $Mirror
}
git -C $Mirror status --short
git -C $Mirror pull --ff-only
# Copy only missing folder, never overwrite existing work:
if (-not (Test-Path (Join-Path $Root 'SECURITY'))) {
    Copy-Item (Join-Path $Mirror 'SECURITY') (Join-Path $Root 'SECURITY') -Recurse
}
Test-Path (Join-Path $Root 'SECURITY\agent\audit_k8s.py')
```
NOTE: security-ci PR branch is not in main until approved/merged. For PR content, inspect branch via remote pull request, do not blindly replace existing folders.

## Audit the current files (only after checking manifests exist)
```powershell
python -m pip install 'PyYAML==6.0.3'
python .\SECURITY\agent\audit_k8s.py .\DZ_01\manifests --output .\DZ_01\security-report.json
```
