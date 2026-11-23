# Windows: enlaza cada addon de addons\ en Interface\AddOns con junctions (no requiere administrador).
#
#   powershell -ExecutionPolicy Bypass -File scripts\link.ps1 [link|unlink|status] [Addon ...]
#
# Destino: fichero .wow-addons-path en la raíz del repo (una ruta por línea, # comenta).
# Si no existe, se usa la instalación por defecto si está:
#   C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns
#   C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns
param(
  [ValidateSet('link', 'unlink', 'status')] [string]$Action = 'link',
  [Parameter(ValueFromRemainingArguments = $true)] [string[]]$Addons
)
$ErrorActionPreference = 'Stop'
$Repo = Split-Path -Parent $PSScriptRoot
$cfg = Join-Path $Repo '.wow-addons-path'

$dirs = @()
if (Test-Path $cfg) {
  $dirs = Get-Content $cfg | ForEach-Object { ($_ -replace '#.*$', '').Trim() } | Where-Object { $_ }
} else {
  $base = 'C:\Program Files (x86)\World of Warcraft'
  $dirs = @('_retail_', '_forever_') | ForEach-Object { Join-Path $base "$_\Interface\AddOns" } | Where-Object { Test-Path $_ }
}
if (-not $dirs) { Write-Error "No hay destino: crea $cfg con la ruta de Interface\AddOns." }

if (-not $Addons) { $Addons = Get-ChildItem (Join-Path $Repo 'addons') -Directory | ForEach-Object Name }

foreach ($dest in $dirs) {
  if (-not (Test-Path $dest)) { Write-Warning "No existe: $dest"; continue }
  Write-Host "== $dest"
  foreach ($name in $Addons) {
    $src = Join-Path $Repo "addons\$name"
    $tgt = Join-Path $dest $name
    if (-not (Test-Path $src)) { Write-Host "  ? ${name}: no existe en addons\"; continue }
    $item = Get-Item $tgt -Force -ErrorAction SilentlyContinue
    $isLink = $item -and $item.LinkType
    switch ($Action) {
      'link' {
        if ($isLink) { $item.Delete(); New-Item -ItemType Junction -Path $tgt -Target $src | Out-Null; Write-Host "  = $name (actualizado)" }
        elseif ($item) { Write-Host "  ! ${name}: ya hay una carpeta real; no la toco" }
        else { New-Item -ItemType Junction -Path $tgt -Target $src | Out-Null; Write-Host "  + $name" }
      }
      'unlink' {
        # Delete() en un junction borra solo el enlace, no el contenido del repo
        if ($isLink) { $item.Delete(); Write-Host "  - $name" } else { Write-Host "  · ${name}: no es un enlace" }
      }
      'status' {
        if ($isLink) { Write-Host "  OK $name -> $($item.Target)" }
        elseif ($item) { Write-Host "  ! ${name}: carpeta real" }
        else { Write-Host "  X ${name}: sin enlazar" }
      }
    }
  }
}
