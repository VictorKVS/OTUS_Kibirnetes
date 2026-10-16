# =====================================================================
# FATHER ENGINEERING PLATFORM | OTUS KUBERNETES
# SCRIPT:      RUN_LESSON03_STEP01.ps1
# LESSON:      03 - Kubernetes Networking
# STEP:        01 - Read-only inspection and isolated namespace
# TARGET:      kind-otus-dz01 / otus-k8s-dz02
# EVIDENCE:    reports/lesson03/step01/latest.txt
# SECURITY:    Allowlisted kubectl output only; no tokens or kubeconfig
# =====================================================================
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$Ctx = 'kind-otus-dz01'
$Ns = 'otus-k8s-dz02'
$EvidenceRel = 'reports/lesson03/step01/latest.txt'
$Evidence = Join-Path $Root $EvidenceRel
$dir = Split-Path $Evidence -Parent
New-Item -ItemType Directory -Force -Path $dir | Out-Null
$lines = New-Object System.Collections.Generic.List[string]
$script:failed = $false
function Add-Log([string]$text) {
    Write-Host $text
    [void]$lines.Add($text)
}
function Run-Kubectl([string]$label, [string[]]$arguments) {
    Add-Log ("[${label}] kubectl " + ($arguments -join ' '))
    $output = & kubectl @arguments 2>&1
    $code = $LASTEXITCODE
    foreach ($line in $output) { Add-Log ([string]$line) }
    Add-Log ("EXIT_CODE=${code}")
    if ($code -ne 0) { $script:failed = $true }
}
Add-Log '====================================================================='
Add-Log 'FATHER | OTUS Kubernetes | Lesson 03 | Step 01'
Add-Log 'Purpose: verify kind cluster, networking and DZ-02 namespace'
Add-Log 'Mode: allowlisted diagnostics, namespace-only creation'
Add-Log ('UTC: ' + [DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ'))
Add-Log ('TargetContext: ' + $Ctx)
Add-Log ('TargetNamespace: ' + $Ns)
Add-Log '====================================================================='
# Preflight: hard stop if wrong context or unavailable tooling.
if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) { throw 'kubectl missing' }
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw 'git missing' }
$current = (& kubectl config current-context 2>&1)
# Every kubectl call uses explicit --context; no global context switch.
Run-Kubectl '01-NODES' @('--context', $Ctx, 'get', 'nodes', '-o', 'wide')
Run-Kubectl '02-KUBE-SYSTEM-PODS' @('--context', $Ctx, '-n', 'kube-system', 'get', 'pods')
Run-Kubectl '03-INGRESS-CLASSES' @('--context', $Ctx, 'get', 'ingressclass')
# Isolated namespace idempotent operation; no changes to DZ-01.
if (-not $script:failed) {
    Run-Kubectl '04-ENSURE-NAMESPACE' @('--context', $Ctx, 'create', 'namespace', $Ns, '--dry-run=client', '-o', 'name')
    if (-not $script:failed) {
        $present = & kubectl --context $Ctx get namespace $Ns -o name 2>$null
        if ($LASTEXITCODE -ne 0) {
            Run-Kubectl '05-CREATE-NAMESPACE' @('--context', $Ctx, 'create', 'namespace', $Ns)
        } else { Add-Log ('[05-NAMESPACE] already exists: ' + $Ns) }
    }
}
Run-Kubectl '06-NAMESPACES' @('--context', $Ctx, 'get', 'namespaces')
Add-Log ('RESULT=' + $(if ($script:failed) { 'FAIL' } else { 'PASS' }))
# Save only allowlisted output above; never dump env, Kubernetes secrets, kubeconfig.
[System.IO.File]::WriteAllLines($Evidence, $lines.ToArray(), (New-Object System.Text.UTF8Encoding($false)))
Add-Log ('EVIDENCE: ' + $Evidence)
& git -C $Root add -- $EvidenceRel
if ($LASTEXITCODE -ne 0) { throw 'git add failed' }
& git -C $Root diff --cached --quiet -- $EvidenceRel
if ($LASTEXITCODE -eq 0) {
    Add-Log '[GIT] evidence unchanged; nothing to commit'
} else {
    & git -C $Root commit -m 'evidence(k8s): refresh lesson03 step01 diagnostics' -- $EvidenceRel
    if ($LASTEXITCODE -ne 0) { throw 'git commit failed; configure git user.name and user.email' }
}
& git -C $Root push origin HEAD:main
if ($LASTEXITCODE -ne 0) { throw 'GitHub push failed; check Git authentication and branch synchronization' }
Add-Log '[DONE] GitHub evidence published. Reply with 1.'
if ($script:failed) { exit 1 }
