<#
.SYNOPSIS
    Crea un cliente nuevo en 1 comando: repo + plantilla + GitHub Pages (+ CNAME si usas dominio).
    Imprime la URL final y el enlace del QR.

.DESCRIPTION
    Copia _template/, reemplaza los marcadores del index.html, crea el repo PUBLICO
    en GitHub desde tu cuenta, hace push y activa GitHub Pages.

    MODO GRATIS (por defecto, sin -Dominio):
        URL del cliente = https://<tu-usuario>.github.io/menu-<cliente>/
        No se crea archivo CNAME. Cero configuracion extra.

    MODO DOMINIO (con -Dominio):
        URL del cliente = https://<subdominio>.<dominio>
        Crea el archivo CNAME. Requiere el DNS wildcard configurado (ver README §2).

.PARAMETER Cliente
    Nombre corto en minusculas con guiones. Genera el repo "menu-<cliente>".
    Ej: -Cliente donbeto  ->  repo menu-donbeto

.PARAMETER Dominio
    Tu dominio base (ej: tudominio.com). Si lo omites, se usa el MODO GRATIS
    de GitHub Pages (recomendado mientras no compres un dominio).

.PARAMETER Subdominio
    Subdominio para MODO DOMINIO (por defecto = Cliente). Se ignora en MODO GRATIS.

.PARAMETER Nombre
    Nombre visible del restaurante (reemplaza NOMBRE_RESTAURANTE en index.html).

.PARAMETER Direccion
    Direccion del restaurante (reemplaza DIRECCION en index.html).

.PARAMETER WhatsApp
    Numero con indicativo y sin signos, ej: 5215512345678 (reemplaza WHATSAPP_NUMERO).

.PARAMETER Telefono
    Telefono para boton "Llamar", ej: 5215512345678 (reemplaza TELEFONO_NUMERO).

.PARAMETER Owner
    Usuario/organizacion de GitHub (por defecto se autodetecta con gh).

.PARAMETER DryRun
    Muestra lo que haria sin tocar GitHub (para probar).

.EXAMPLE
    # MODO GRATIS (recomendado)
    .\scripts\nuevo-cliente.ps1 -Cliente donbeto -Nombre "Don Beto" -Direccion "Av. Hidalgo 123, Centro" -WhatsApp 5215512345678 -Telefono 5215512345678

.EXAMPLE
    # MODO DOMINIO
    .\scripts\nuevo-cliente.ps1 -Cliente donbeto -Dominio tudominio.com -Subdominio donbeto -Nombre "Don Beto"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[a-z0-9]+(-[a-z0-9]+)*$')]
    [string]$Cliente,

    [string]$Dominio,

    [string]$Subdominio,

    [string]$Nombre,

    [string]$Direccion,

    [ValidatePattern('^[0-9]{8,15}$')]
    [string]$WhatsApp,

    [ValidatePattern('^[0-9]{8,15}$')]
    [string]$Telefono,

    [string]$Owner,

    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

# --- Normalizacion (DNS/GitHub en minusculas) -----------------------------
$Cliente    = $Cliente.Trim().ToLower()
$Subdominio = $Subdominio.Trim().ToLower()
$Dominio    = $Dominio.Trim().ToLower()
if (-not $Subdominio) { $Subdominio = $Cliente }

$ModoDominio  = [bool]$Dominio
$Slug         = "menu-$Cliente"
$TemplateDir  = Join-Path (Split-Path -Parent $PSScriptRoot) "_template"

if ($ModoDominio) {
    if ($Dominio -notmatch '^[a-z0-9]+(-[a-z0-9]+)*(\.[a-z0-9]+(-[a-z0-9]+)*)+$') {
        throw "Dominio invalido: '$Dominio'. Ej: tudominio.com"
    }
    if ($Subdominio -notmatch '^[a-z0-9]+(-[a-z0-9]+)*$') {
        throw "Subdominio invalido: '$Subdominio'. Usa minusculas, numeros y guiones (ej: taqueria-mario)."
    }
}

if (-not (Test-Path (Join-Path $TemplateDir "index.html"))) {
    throw "No se encontro la plantilla en: $TemplateDir"
}

# --- Prerrequisitos -------------------------------------------------------
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "No se encontro git. Instala Git for Windows: https://git-scm.com/download/win"
}
if (-not $DryRun) {
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        throw "No se encontro GitHub CLI. Instala con:  winget install GitHub.cli   (luego reinicia la terminal y ejecuta: gh auth login)"
    }
    if (-not $Owner) {
        $Owner = ((gh api user --jq .login) | Out-String).Trim()
        if (-not $Owner) { throw "No se pudo obtener tu usuario de GitHub. Ejecuta: gh auth login" }
    }

    $prevEAP = $ErrorActionPreference
    $ErrorActionPreference = "SilentlyContinue"
    gh repo view "$Owner/$Slug" *> $null
    $repoExiste = ($LASTEXITCODE -eq 0)
    $ErrorActionPreference = $prevEAP
    if ($repoExiste) { throw "El repo $Owner/$Slug ya existe en GitHub. Elige otro nombre de cliente." }
}
if (-not $Owner) { $Owner = "EdgarM100" }

# --- URL final ------------------------------------------------------------
if ($ModoDominio) {
    $Url   = "https://$Subdominio.$Dominio"
    $Modo  = "DOMINIO ($Dominio)"
} else {
    $Url   = "https://$($Owner.ToLower()).github.io/$Slug/"
    $Modo  = "GRATIS (GitHub Pages)"
}

Write-Host ""
Write-Host "Cliente : $Cliente"        -ForegroundColor Cyan
Write-Host "Modo    : $Modo"           -ForegroundColor Cyan
Write-Host "Repo    : $Owner/$Slug"    -ForegroundColor Cyan
Write-Host "URL     : $Url"            -ForegroundColor Cyan

# --- 1. Copiar plantilla a un directorio temporal -------------------------
$Work = Join-Path ([IO.Path]::GetTempPath()) ("menu-" + $Cliente + "-" + [Guid]::NewGuid().ToString("N").Substring(0, 6))
New-Item -ItemType Directory -Path $Work -Force | Out-Null
Copy-Item -Path (Join-Path $TemplateDir "*") -Destination $Work -Recurse -Force

# --- 2. CNAME solo en MODO DOMINIO (SOLO host, sin https://) --------------
$cnamePath = Join-Path $Work "CNAME"
if ($ModoDominio) {
    Set-Content -Path $cnamePath -Value "$Subdominio.$Dominio" -NoNewline
} elseif (Test-Path $cnamePath) {
    Remove-Item $cnamePath -Force
}

# --- 3. Reemplazar marcadores en index.html ------------------------------
$htmlPath = Join-Path $Work "index.html"
$html     = Get-Content -Path $htmlPath -Raw
if ($Nombre)    { $html = $html.Replace("NOMBRE_RESTAURANTE", $Nombre) }
if ($Direccion) { $html = $html.Replace("DIRECCION", $Direccion) }
if ($WhatsApp)  { $html = $html.Replace("WHATSAPP_NUMERO", $WhatsApp) }
if ($Telefono)  { $html = $html.Replace("TELEFONO_NUMERO", $Telefono) }
Set-Content -Path $htmlPath -Value $html -NoNewline

$pendientes = @("NOMBRE_RESTAURANTE", "DIRECCION", "TELEFONO_NUMERO", "WHATSAPP_NUMERO") |
    Where-Object { $html -match $_ }
if ($pendientes) {
    Write-Warning ("Marcadores sin reemplazar en index.html: " + ($pendientes -join ", ") +
        ". Editalos desde el cel o vuelve a correr el script con los parametros.")
}

# --- 4. git + crear repo + push -------------------------------------------
if ($DryRun) {
    Write-Host "[DRYRUN] No se toca GitHub. Archivos listos en: $Work" -ForegroundColor Yellow
} else {
    git -C $Work init -b main | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "git init fallo" }
    git -C $Work add .
    git -C $Work commit -m "menú $Cliente - inicial" | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "git commit fallo (revisa git config user.name/user.email)" }

    gh repo create "$Owner/$Slug" --public --source $Work --push | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "gh repo create fallo. Verifica: gh auth status" }

    # --- 5. Activar GitHub Pages ---
    gh api "repos/$Owner/$Slug/pages" -X POST -f "source[branch]=main" -f "source[path]=/" | Out-Null
    if ($LASTEXITCODE -ne 0) { Write-Warning "No se pudo activar Pages via API. Activalo en: https://github.com/$Owner/$Slug/settings/pages" }
}

# --- Resultado ------------------------------------------------------------
$qr = "https://api.qrserver.com/v1/create-qr-code/?size=400x400&data=$([uri]::EscapeDataString($Url))"
Write-Host ""
if ($DryRun) {
    Write-Host "[DRYRUN] Listo (sin publicar)." -ForegroundColor Yellow
} else {
    Write-Host "OK - CLIENTE PUBLICADO (Pages tarda ~30-60s)" -ForegroundColor Green
}
Write-Host "   URL  : $Url"
Write-Host "   QR   : $qr"
Write-Host "   Repo : https://github.com/$Owner/$Slug"
Write-Host "   Edit : https://github.com/$Owner/$Slug/edit/main/index.html"
Write-Host ""
