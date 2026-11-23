# Windows: copia el SavedVariables de un addon a results\ (no versionado).
#
#   powershell -ExecutionPolicy Bypass -File scripts\pull-sv.ps1 [Addon]     (por defecto ProbeAuras)
#
# Usa los mismos destinos que link.ps1; WTF está en <AddOns>\..\..\WTF.
param([string]$Name = 'ProbeAuras')
$ErrorActionPreference = 'Stop'
$Repo = Split-Path -Parent $PSScriptRoot
$out = Join-Path $Repo 'results'
New-Item -ItemType Directory -Force -Path $out | Out-Null
$cfg = Join-Path $Repo '.wow-addons-path'

if (Test-Path $cfg) {
  $dirs = Get-Content $cfg | ForEach-Object { ($_ -replace '#.*$', '').Trim() } | Where-Object { $_ }
} else {
  $base = 'C:\Program Files (x86)\World of Warcraft'
  $dirs = @('_retail_', '_forever_') | ForEach-Object { Join-Path $base "$_\Interface\AddOns" } | Where-Object { Test-Path $_ }
}

$found = $false
foreach ($dest in $dirs) {
  $flavorDir = Split-Path -Parent (Split-Path -Parent $dest)
  $flavor = Split-Path -Leaf $flavorDir
  $wtf = Join-Path $flavorDir 'WTF\Account'
  if (-not (Test-Path $wtf)) { continue }
  Get-ChildItem $wtf -Recurse -Filter "$Name.lua" | Where-Object { $_.Directory.Name -eq 'SavedVariables' } | ForEach-Object {
    $account = $_.Directory.Parent.Name
    $file = Join-Path $out "$Name$flavor$account.lua"
    Copy-Item $_.FullName $file -Force
    Write-Host "copiado: $($_.FullName) -> $file"
    $found = $true
  }
}
if (-not $found) { Write-Host "No se encontró $Name.lua. ¿Hiciste /reload o saliste del juego?" }
