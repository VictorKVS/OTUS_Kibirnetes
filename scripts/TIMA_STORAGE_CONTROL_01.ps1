# =====================================================================
# FATHER ENGINEERING PLATFORM
# AGENT: TIMA / TIMOFEY
# PROJECT: Storage Migration / Infrastructure Governance
# STEP: STORAGE-01 - Read-only inventory
# OUTPUT: G:\1\FATHER\TIMA\reports\storage-migration
# SAFETY: No deletion, movement, restart or uploading system reports
# COMPATIBILITY: Windows PowerShell 5.1
# =====================================================================
[CmdletBinding()]
param()
$ErrorActionPreference = 'Continue'
$ReportDir = 'G:\1\FATHER\TIMA\reports\storage-migration'
New-Item -ItemType Directory -Force -Path $ReportDir -ErrorAction Stop | Out-Null
$Stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$Report = Join-Path $ReportDir ("TIMA_STORAGE_01_$Stamp.txt")
$Lines = New-Object 'System.Collections.Generic.List[string]'
function Log([string]$Message) { Write-Host $Message; [void]$script:Lines.Add($Message) }
function Save-Report { [System.IO.File]::WriteAllLines($Report,$script:Lines.ToArray(),(New-Object System.Text.UTF8Encoding($false))) }
Log '=== TIMA | STORAGE AUDIT | READ ONLY ==='
Log ('Timestamp: ' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))
Log '[01] DISK CAPACITY'
Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | Where-Object { $_.DeviceID -in @('C:','F:','G:') } | ForEach-Object {
  Log ('{0}: total={1:N2} GB; free={2:N2} GB; used={3:N2} GB' -f $_.DeviceID,($_.Size/1GB),($_.FreeSpace/1GB),(($_.Size-$_.FreeSpace)/1GB))
}
Log '[02] DOCKER VHDX'
$DockerVhd = Join-Path $env:LOCALAPPDATA 'Docker\wsl\disk\docker_data.vhdx'
if (Test-Path -LiteralPath $DockerVhd) {
  $d = Get-Item -LiteralPath $DockerVhd
  Log ('Docker data VHDX: {0:N2} GB; path={1}' -f ($d.Length/1GB),$d.FullName)
} else { Log 'Docker data VHDX not present at expected path' }
Log '[03] VMWARE COPIES ON F:'
$VmRoot = 'F:\FATHER_INFRA\VMware'
if (Test-Path -LiteralPath $VmRoot) {
  foreach ($d in (Get-ChildItem -LiteralPath $VmRoot -Directory -ErrorAction SilentlyContinue)) {
    $files = @(Get-ChildItem -LiteralPath $d.FullName -File -Recurse -Force -ErrorAction SilentlyContinue)
    $bytes = ($files | Measure-Object -Property Length -Sum).Sum
    Log ('VM: {0}; files={1}; size={2:N2} GB' -f $d.Name,$files.Count,([double]$bytes/1GB))
  }
} else { Log 'No VMware target folder at expected path' }
Log '[04] VMWARE ORIGINALS ON C:'
$OldVm = Join-Path $env:USERPROFILE 'Documents\Virtual Machines'
if (Test-Path -LiteralPath $OldVm) {
  foreach ($d in (Get-ChildItem -LiteralPath $OldVm -Directory -ErrorAction SilentlyContinue)) {
    $bytes = (Get-ChildItem -LiteralPath $d.FullName -File -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
    Log ('Original VM: {0}; size={1:N2} GB' -f $d.Name,([double]$bytes/1GB))
  }
} else { Log 'No original VMware folder at expected path' }
Log '[05] VIRTUALIZATION PROCESS STATUS'
$p = @(Get-Process vmware-vmx -ErrorAction SilentlyContinue)
Log ('Running vmware-vmx processes: ' + $p.Count)
Log '[06] WSL DISTRIBUTIONS'
try { foreach ($line in (& wsl.exe --list --quiet 2>&1)) { Log ([string]$line) } } catch { Log 'WSL list failed' }
Log '[07] DISK GUARD TASKS'
try {
  Get-ScheduledTask -ErrorAction Stop | Where-Object { $_.TaskName -match 'FATHER|DISK.GUARD|TIMA' } | ForEach-Object { Log ('Task: {0}; state={1}' -f $_.TaskName,$_.State) }
} catch { Log 'Scheduled task inspection unavailable' }
Log '[08] GIT INSTALLATION'
$git = Get-Command git -ErrorAction SilentlyContinue
if ($git) { Log ('Git executable: ' + $git.Source) } else { Log 'Git executable unavailable' }
Log '[09] DOCKER ENGINE STATUS'
$docker = Get-Command docker -ErrorAction SilentlyContinue
if (-not $docker) { Log 'Docker CLI unavailable' } else {
  try {
    $version = & docker info --format '{{.ServerVersion}}' 2>$null
    if ($LASTEXITCODE -eq 0) { Log ('Docker Engine: ' + $version) }
    else { Log 'Docker Engine unavailable (no changes attempted)' }
  } catch { Log 'Docker Engine check failed' }
}
Log '[10] RECOMMENDATION'
Log 'Do not delete old VM folders until boot tests and dependencies are verified.'
Log 'Do not delete Docker VHDX before independent backup and restore plan.'
Log 'Report stays local; it may contain private system paths.'
Save-Report
Write-Host ('[PASS] Report saved: ' + $Report)
Write-Host '=== TIMA | STORAGE AUDIT COMPLETE ==='
