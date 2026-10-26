# =====================================================================
# FATHER ENGINEERING PLATFORM
# AGENT: TIMA / TIMOFEY
# PROJECT: Storage migration
# STEP: STORAGE-02 - Backup Docker VHDX to F:
# SAFETY: no deletion, no overwrite, no automatic shutdown
# REQUIREMENT: quit Docker Desktop and run wsl --shutdown beforehand
# =====================================================================
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$Source = Join-Path $env:LOCALAPPDATA 'Docker\wsl\disk\docker_data.vhdx'
$Base = 'F:\FATHER_INFRA\BACKUPS\Docker'
$Stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$DestinationDir = Join-Path $Base $Stamp
$Destination = Join-Path $DestinationDir 'docker_data.vhdx'
Write-Host '[01] PREFLIGHT'
if (-not (Test-Path -LiteralPath $Source -PathType Leaf)) { throw ('Source missing: ' + $Source) }
$SrcInfo = Get-Item -LiteralPath $Source
$Volume = Get-Volume -DriveLetter F -ErrorAction Stop
if ($Volume.FileSystem -ne 'NTFS' -or $Volume.HealthStatus -ne 'Healthy') { throw 'Target F: not healthy NTFS' }
if ($Volume.SizeRemaining -lt ($SrcInfo.Length + 50GB)) { throw 'Insufficient free space including 50 GB reserve' }
if (Test-Path -LiteralPath $DestinationDir) { throw 'Backup folder already exists; refuse overwrite' }
$processes = @(Get-Process -Name 'com.docker.backend','Docker Desktop','vmmem','vmmemWSL','vmwp' -ErrorAction SilentlyContinue)
if ($processes.Count -gt 0) { $processes | Select-Object ProcessName,Id | Format-Table; throw 'Virtualization processes detected. Stop Docker and WSL gracefully first.' }
$running = (& wsl.exe --list --running 2>&1 | Out-String)
# WSL output may be UTF-16 in an interactive shell; conservative process checks above still apply.
if ($LASTEXITCODE -ne 0) { throw 'Cannot confirm WSL status' }
if ($running -match 'Ubuntu|docker-desktop') { throw 'WSL distributions still running' }
Write-Host ('Source {0:N2} GB' -f ($SrcInfo.Length/1GB))
Write-Host ('Backup destination: ' + $Destination)
Write-Host '[02] COPYING WITH ROBOCOPY'
New-Item -ItemType Directory -Path $DestinationDir -ErrorAction Stop | Out-Null
& robocopy (Split-Path $Source -Parent) $DestinationDir 'docker_data.vhdx' /R:0 /W:0 /J /COPY:DAT /NP
$Code = $LASTEXITCODE
if ($Code -ge 8) { throw ('Robocopy failed: ' + $Code) }
if (-not (Test-Path -LiteralPath $Destination -PathType Leaf)) { throw 'Backup missing' }
if ((Get-Item -LiteralPath $Destination).Length -ne $SrcInfo.Length) { throw 'Backup size mismatch' }
Write-Host '[03] SHA256 VERIFICATION'
$OriginalHash = (Get-FileHash -LiteralPath $Source -Algorithm SHA256 -ErrorAction Stop).Hash
$BackupHash = (Get-FileHash -LiteralPath $Destination -Algorithm SHA256 -ErrorAction Stop).Hash
if ($OriginalHash -ne $BackupHash) { throw 'SHA256 mismatch: do not use backup' }
Write-Host '[PASS] Docker VHDX backed up; SHA256 identical; original on C: preserved.'
Write-Host ('Backup: ' + $Destination)
Write-Host '[NEXT] Configure Docker Desktop disk image location on F: after separate review.'
