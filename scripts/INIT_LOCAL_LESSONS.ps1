# Creates local lesson directories without deleting or overwriting any existing files.
$ErrorActionPreference = 'Stop'
$Root = 'G:\1\OTUS_Kibirnetes'
$Lessons = @(
  '01_Introduction_to_Kubernetes',
  '02_Kubernetes_Objects',
  '03_Kubernetes_Networking',
  '04_Kubernetes_Storage',
  '05_Requests_Limits_Load_Balancing',
  '06_Service_Mesh',
  '07_Kubernetes_Cluster_Deployment',
  '08_Git_and_CICD'
)
New-Item -ItemType Directory -Path $Root -Force | Out-Null
foreach ($Name in $Lessons) {
  $Path = Join-Path $Root ('LESSONS\' + $Name)
  New-Item -ItemType Directory -Path $Path -Force | Out-Null
  Write-Host ('READY: ' + $Path)
}
New-Item -ItemType Directory -Path (Join-Path $Root 'DZ_01\evidence') -Force | Out-Null
Write-Host 'Existing folder 1 and its PDFs were not changed.'
Get-ChildItem (Join-Path $Root 'LESSONS') -Directory | Select-Object Name,FullName
