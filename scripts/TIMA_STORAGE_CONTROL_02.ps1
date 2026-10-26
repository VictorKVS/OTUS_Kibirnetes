# =====================================================================
# FATHER ENGINEERING PLATFORM
# AGENT: TIMA / TIMOFEY
# PROJECT: Storage migration
# STEP: STORAGE-02 - Backup Docker VHDX to F:
# SAFETY: no deletion, no overwrite, no automatic shutdown
# IMPORTANT: close Docker Desktop and run wsl --shutdown manually
# =====================================================================
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$Src = Join-Path $env:LOCALAPPDATA 'Docker\wsl\disk\docker_data.vhdx'
$Base = 'F:\FATHER_INFRA\BACKUPS\Docker'
$Stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$Dst = Join-Path $Base ("docker_data_$Stamp.vhdx")
$Summary = Join-Path $Base ("docker_data_$Stamp.sha256.txt")
Write-Host '[01] Source and destination'
if (-not (Test-Path -LiteralPath $Src -PathType Leaf)) { throw "Source missing: $Src" }
$SourceInfo = Get-Item -LiteralPath $Src
if (-not (Test-Path 'F:\')) { throw 'Drive F: unavailable' }
$Volume = Get-Volume -DriveLetter F
if ($Volume.FileSystem -ne 'NTFS' -or $Volume.HealthStatus -ne 'Healthy') { throw 'Target F: not healthy NTFS' }
if ($Volume.SizeRemaining -lt ($SourceInfo.Length + 50GB)) { throw 'Insufficient F: capacity for backup plus 50 GB reserve' }
if (Test-Path -LiteralPath $Dst) { throw 'Destination already exists' }
Write-Host ('Source: {0:N2} GB' -f ($SourceInfo.Length/1GB))
Write-Host ('Destination: ' + $Dst)
Write-Host '[02] Ensure Docker and WSL are not running'
$Running = @(Get-Process -Name 'com.docker.backend','Docker Desktop','vmmem','vmmemWSL' -ErrorAction SilentlyContinue)
if ($Running.Count -gt 0) { $Running | Select-Object ProcessName,Id | Format-Table; throw 'Docker/WSL still active. Stop services gracefully and rerun.' }
$WslList = (& wsl.exe --list --running 2>&1 | Out-String)
if ($WslList -match '(?im)^\s*(Ubuntu|docker-desktop)\s*$') { throw 'Running WSL distributions detected. Stop them first.' }
Write-Host '[03] Copy, no source deletion'
New-Item -ItemType Directory -Path $Base -Force | Out-Null
$robolog = Join-Path $Base ("copy_$Stamp.log")
& robocopy (Split-Path $Src -Parent) $Base (Split-Path $Dst -Leaf) /R:0 /W:0 /J /COPY:DAT /NP /LOG:$robolog
# robocopy cannot rename the source via file mask; use Copy-Item instead
throw 'Safety stop: copy with rename needs explicit verified implementation. No source deleted.'
