# =====================================================================
# FATHER ENGINEERING PLATFORM
# PROJECT: OTUS Kubernetes / FATHER DevSecOps
# LESSON: 03 - Networking
# STEP: 01 - Inspect and create isolated DZ-02 namespace
# MODE: Safe diagnostics; only namespace otus-k8s-dz02 may be created
# OUTPUT: reports/lesson03/step01/latest.txt
# SECURITY: No kubeconfig, tokens, secrets or full environment dumps
# =====================================================================
[CmdletBinding()]
param()
$ErrorActionPreference = 'Continue'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$Ctx = 'kind-otus-dz01'
$Ns = 'otus-k8s-dz02'
$Rel = 'reports/lesson03/step01/latest.txt'
$Out = Join-Path $Root 'reports\lesson03\step01\latest.txt'
$Log = New-Object 'System.Collections.Generic.List[string]'
$HasFailure = $false

function Say([string]$Message) {
    Write-Host $Message
    [void]$script:Log.Add($Message)
}
function Kube([string]$Step, [string[]]$KubectlArgs) {
    Say ('[' + $Step + '] kubectl ' + ($KubectlArgs -join ' '))
    try {
        $result = & kubectl @KubectlArgs 2>&1
        $code = $LASTEXITCODE
        foreach ($item in $result) {
            $line = [string]$item
            # Allowlisted commands only. Avoid accidental token/error dumps.
            if ($line -match '(?i)token=|authorization:|password=|client-key-data:|client-certificate-data:') {
                Say '[REDACTED: possible credential]'
            } else { Say $line }
        }
        Say ('EXIT_CODE=' + $code)
        if ($code -ne 0) { $script:HasFailure = $true }
        return $code
    } catch {
        Say ('[ERROR] ' + $_.Exception.GetType().Name)
        $script:HasFailure = $true
        return 1
    }
}
Say '====================================================================='
Say 'FATHER | OTUS KUBERNETES | LESSON 03 | STEP 01'
Say ('UTC=' + [DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ'))
Say ('CONTEXT=' + $Ctx)
Say ('NAMESPACE=' + $Ns)
Say '====================================================================='

$kubectlExists = [bool](Get-Command kubectl -ErrorAction SilentlyContinue)
$gitExists = [bool](Get-Command git -ErrorAction SilentlyContinue)
if (-not $kubectlExists) { Say '[FAIL] kubectl is not installed'; $HasFailure = $true }
if (-not $gitExists) { Say '[WARN] git is not available; local log will remain'; $HasFailure = $true }
if ($kubectlExists) {
    $nodesCode = Kube '01-NODES' @('--context',$Ctx,'get','nodes','-o','wide')
    if ($nodesCode -eq 0) {
        $null = Kube '02-NETWORK' @('--context',$Ctx,'-n','kube-system','get','pods')
        # No ingressclass is normal for an unconfigured cluster.
        $null = Kube '03-INGRESS' @('--context',$Ctx,'get','ingressclass')
        # Avoid treating absence of ingressclass as a blocking error.
        $currentNs = & kubectl --context $Ctx get namespace $Ns -o name 2>$null
        if ($LASTEXITCODE -eq 0) {
            Say ('[04-NAMESPACE] Already exists: ' + $Ns)
        } else {
            $null = Kube '04-CREATE-NAMESPACE' @('--context',$Ctx,'create','namespace',$Ns)
        }
        $null = Kube '05-NAMESPACES' @('--context',$Ctx,'get','namespaces')
    } else { Say '[WARN] Cluster unavailable; no changes attempted' }
}
Say ('RESULT=' + $(if ($HasFailure) {'FAIL'} else {'PASS'}))
New-Item -ItemType Directory -Force -Path (Split-Path $Out -Parent) | Out-Null
[System.IO.File]::WriteAllLines($Out,$Log.ToArray(),(New-Object System.Text.UTF8Encoding($false)))
Write-Host ('[EVIDENCE] ' + $Out)

if ($gitExists) {
    $branch = (& git -C $Root branch --show-current 2>&1)
    if ($LASTEXITCODE -ne 0 -or $branch.Trim() -ne 'main') {
        Write-Host ('[GIT FAIL] Expected main branch, actual: ' + $branch)
        exit 2
    }
    # Pull BEFORE staging so remote script updates are fast-forwarded safely.
    & git -C $Root pull --ff-only origin main
    if ($LASTEXITCODE -ne 0) { Write-Host '[GIT FAIL] Pull failed; evidence is saved locally'; exit 2 }
    & git -C $Root add -- $Rel
    if ($LASTEXITCODE -ne 0) { Write-Host '[GIT FAIL] Add failed'; exit 2 }
    & git -C $Root diff --cached --quiet -- $Rel
    if ($LASTEXITCODE -ne 0) {
        & git -C $Root commit -m 'evidence: Kubernetes lesson 03 step 01' -- $Rel
        if ($LASTEXITCODE -ne 0) { Write-Host '[GIT FAIL] Commit failed'; exit 2 }
    }
    & git -C $Root push origin main
    if ($LASTEXITCODE -ne 0) { Write-Host '[GIT FAIL] Push failed; evidence remains locally'; exit 2 }
    Write-Host '[GITHUB PASS] Evidence published. Reply 1.'
}
if ($HasFailure) { exit 1 }
exit 0
