# 🍽️ Menús Digitales en Campo — Harness de Despliegue Ultra Rápido

> **Modelo:** llegas → foto del menú → IA genera HTML → lo subes a GitHub → QR impreso/enviado → cobras.
> **Costo total: $0** (GitHub Pages gratis, repos públicos ilimitados).

> ⚠️ **REEMPLAZA EN TODO ESTE DOC:**
> - `midominio.com` → tu dominio real
> - Los nombres de subdominio son ejemplos (`donbeto.midominio.com`)
> - Usuario de GitHub: **EdgarM100** ✅

---

## Índice

1. [Hosting: comparativa gratis y decisión](#1-hosting-comparativa-gratuita)
2. [DNS — configuración única (~10 min)](#2-dns--configuración-única)
3. [Estructura del repositorio](#3-estructura-del-repositorio)
4. [Flujo en campo desde tu iPhone (~4 min por cliente)](#4-flujo-en-campo-desde-tu-iphone)
5. [Prompt estándar para la IA](#5-prompt-estándar-para-la-ia)
6. [Plantilla base HTML/CSS mobile-first](#6-plantilla-base-htmlcss-mobile-first)
7. [QR, impresión y cobro](#7-qr-impresión-y-cobro)
8. [Checklist cronometrada del restaurante](#8-checklist-cronometrada-del-restaurante)
9. [Comandos exactos (PC)](#9-comandos-exactos-pc)
10. [Solución de problemas](#10-solución-de-problemas)

---

## 1. Hosting: comparativa gratuita

| Servicio | Gratis | Subdominios tipo `cliente.tudominio.com` | Uso comercial | Veredicto |
|---|---|---|---|---|
| **GitHub Pages** ✅ | Sí, $0 | Sí: DNS wildcard + 1 archivo `CNAME` por repo | Sí | **ELECCIÓN** — ya tienes GitHub, sin límite de clientes |
| Netlify | Sí (100 GB/mes) | Sí (1 CNAME por sitio) | Sí | Alternativa válida: permite *drag & drop* desde el navegador |
| Cloudflare Pages | Sí (banda ilimitada) | Sí | Sí | Alternativa sólida si algún día migras |
| Vercel Hobby | Sí | Sí (wildcard nativo) | ❌ **NO** (plan Hobby = solo proyectos personales) | Descartado para negocio |

**Cómo funciona gratis el subdominio por cliente en GitHub Pages:**
GitHub Pages **no permite wildcard nativo** (cada sitio = 1 dominio por repo). La solución que usaremos:

```
DNS (una sola vez):   *.midominio.com  →  CNAME  →  EdgarM100.github.io
Cada repo declara:    archivo CNAME = "donbeto.midominio.com"
GitHub enruta por Host → sirve el repo correcto ✅
```

Resultado: **un repo = un cliente = un subdominio**, sin costo, sin límite.

---

## 2. DNS — configuración única

**Dónde:** panel de tu proveedor de dominio (GoDaddy, Namecheap, Hostinger, etc.) → sección **DNS / Zona DNS / Manage DNS**.

### Registro 1 — Wildcard (obligatorio)

| Campo | Valor |
|---|---|
| Tipo | **CNAME** |
| Nombre / Host | `*` |
| Valor / Destination | `EdgarM100.github.io` |
| TTL | Auto (o 30 min) |

> En algunos paneles el campo Nombre hay que ponerlo completo: `*.midominio.com`.
> Algunos proveedores añaden tu dominio automáticamente al valor — si ves `EdgarM100.github.io.midominio.com`, **está mal**, debe quedar exactamente `EdgarM100.github.io`.

### Registro 2 — Apex (opcional, solo si quieres que `midominio.com` también muestre algo)

| Campo | Valor |
|---|---|
| Tipo | **A** |
| Nombre | `@` |
| Valor | `185.199.108.153` |

Repite el registro A con: `185.199.109.153`, `185.199.110.153`, `185.199.111.153`.

### Verificación (desde tu PC o celular)

```powershell
Resolve-DnsName donbeto.midominio.com
```
```bash
nslookup donbeto.midominio.com
```
Debe devolver una cadena CNAME → `EdgarM100.github.io` → IP `185.199.x.x`. **Propagación típica: 5–30 min** (a veces hasta 1 h la primera vez).

### HTTPS automático
GitHub emite certificado HTTPS por cada subdominio declarado en un repo. En **Settings → Pages** aparecerá **"Enforce HTTPS"** cuando el certificado esté listo (minutos la primera vez). No hay que configurar nada más.

---

## 3. Estructura del repositorio

### En tu PC (esta carpeta = harness central)

```
06. Menus_Github/
├── README.md                    ← este archivo (la biblia del sistema)
├── _template/                   ← plantilla que se convierte en cada cliente
│   ├── index.html               ← menú mobile-first base
│   ├── CNAME                    ← subdominio (se edita por cliente)
│   └── .nojekyll                ← desactiva Jekyll (evita que borre archivos raros)
└── scripts/
    └── nuevo-cliente.ps1        ← crea un cliente completo en 1 comando
```

### En tu cuenta de GitHub (ilimitado, gratis)

```
EdgarM100/
├── menus-github       ← este harness (referencia/documentación)
├── menu-plantilla     ← repo Marcado como "Template repository" (para duplicar desde el cel)
├── menu-donbeto       ← cliente 1 → donbeto.midominio.com
├── menu-laparra       ← cliente 2 → laparra.midominio.com
└── menu-taqueria-mario ← cliente 3 → taqueria-mario.midominio.com
```

**Convención de nombres:**
- Repo: `menu-<nombre-corto-del-cliente>` (minúsculas, guiones; ej. `menu-donbeto`)
- Subdominio: `<nombre-corto>.midominio.com` (ej. `donbeto.midominio.com`)
- Siempre iguales → el QR y los links nunca se rompen.

**Qué hace cada archivo dentro del repo del cliente:**

| Archivo | Función |
|---|---|
| `CNAME` | Contiene SOLO el subdominio: `donbeto.midominio.com` (sin `https://`, una línea) |
| `index.html` | El menú que genera la IA |
| `.nojekyll` | GitHub Pages no procesa el repo con Jekyll → nada se borra |
| `img/` (opcional) | Tus fotos de platos — el repo te sirve de hosting de imágenes gratis |

---

## 4. Flujo en campo desde tu iPhone

> **Primer cliente (una vez):** crea el repo plantilla en GitHub (ver §9) y márcalo como *Template repository* en Settings → casilla **Template repository**.

### Método A — Recomendado: desde la plantilla (iPhone, ~4 min)

1. **Foto el menú** con tu celular.
2. **IA genera el HTML** (prompt en §5) — mientras hablas con el cliente.
3. **Crear repo desde plantilla** (en Safari o la app GitHub):
   - Abre: `https://github.com/EdgarM100/menu-plantilla/generate`
   - Nombre: `menu-donbeto` → **Create repository from template**
4. **Poner el subdominio** → abre `CNAME` → ✏️ editar → escribe `donbeto.midominio.com` → **Commit changes**.
5. **Pegar el menú** → abre `index.html` → ✏️ editar → seleccionar todo → pega el HTML de la IA → **Commit changes**.
6. **Activar Pages** (solo primera vez de ese repo) → abre:
   `https://github.com/EdgarM100/menu-donbeto/settings/pages`
   → Source: **Deploy from a branch** → Branch: **main** / **(root)** → **Save**
7. **Verificar:** abre `https://donbeto.midominio.com` (espera ~1–10 min la primera vez; después 30–60 seg).
8. **QR** → imprime o envía por WhatsApp → **cobra**. ✅

> 💡 La app de GitHub en iOS también te deja editar archivos directo (lápiz ✏️). Si la app te manda a una vista web, continúa igual — es el mismo flujo.

### Método B — Desde tu PC (1 comando)

```powershell
.\scripts\nuevo-cliente.ps1 -Cliente donbeto -Nombre "Don Beto" -Direccion "Av. Hidalgo 123, Centro" -WhatsApp 5215512345678 -Telefono 5215512345678
```
Crea repo, escribe CNAME, copia plantilla, activa Pages y te imprime la URL. Detalle en §9.

### Actualizar un menú desde el celular (~60 seg)

1. App GitHub → repo del cliente → `index.html` → ✏️
2. Editar lo que cambió (precios, platillos) → **Commit**
3. **Live en ~30–60 segundos.** Abrir la URL para verificar.

### Limitaciones a respetar desde el celular

- **Archivo `index.html` < ~250 KB**: si la IA te devuelve HTML gigante (imágenes en base64), pídele: *"sin imágenes embebidas, sin base64, HTML ligero"*.
- **Fotos de platos:** súbelas al repo (`Add file → Upload files` → carpeta `img/`) y referéncialas como `img/plato.jpg`. El repo = hosting de imágenes gratis.
- Nunca borres el archivo `CNAME` ni el `.nojekyll`.

---

## 5. Prompt estándar para la IA

Guárdalo en Notas del iPhone para pegarlo en un tap. Adjúntale la foto del menú:

```
Eres experto en HTML. A partir de esta foto del menú de un restaurante,
crea la página web completa del menú.

REGLAS OBLIGATORIAS:
- Un SOLO archivo index.html (HTML + CSS inline, sin frameworks ni CDN)
- Mobile-first, que cargue en menos de 3 segundos en datos móviles
- SIN imágenes embebidas ni base64 (solo texto y código)
- Tipografía del sistema, máximo ~15 KB, HTML válido, lang="es"
- Diseño moderno: fondo oscuro, precios claros y alineados a la derecha
- Encabezado: NOMBRE DEL RESTAURANTE, dirección, teléfono
- Menú por categorías (Entradas, Fuertes, Postres, Bebidas...) con
  nombre del platillo, descripción corta y precio en MXN
- Botón fijo abajo: Llamar (href="tel:+52...") y WhatsApp (href="https://wa.me/52...")
- Incluye meta viewport, title y theme-color
- Marcadores exactos que reemplazaré después: NOMBRE_RESTAURANTE,
  DIRECCION, TELEFONO, WHATSAPP_NUMERO
```

---

## 6. Plantilla base HTML/CSS mobile-first

**Archivo:** `_template/index.html` — es el punto de partida de cada menú.

Características (optimizado para lectura en smartphone en el restaurante):

- **Mobile-first**: viewport, tamaños base para pantalla chica, `max-width: 640px` centrado en desktop
- **Ligera**: un solo archivo, CSS inline, **sin JavaScript**, tipografía del sistema (cero descargas)
- **Estructura**: header fijo con nombre → categoría con anclas → filas platillo/precio → footer
- **Acción**: botones fijos abajo de **Llamar** (`tel:`) y **WhatsApp** (`wa.me`)
- **Performance**: `theme-color`, imágenes lazy (`loading="lazy"` si agregas fotos)
- Marcadores para reemplazar: `NOMBRE_RESTAURANTE`, `DIRECCION`, `TELEFONO`, `WHATSAPP_NUMERO`

Para personalizar colores por cliente: cambia las variables `--bg`, `--card`, `--accent` al inicio del `<style>`.

---

## 7. QR, impresión y cobro

### Generar el QR (desde el celular)

Abre esta URL reemplazando el subdominio (luego mantén presionada → guardar imagen):

```
https://api.qrserver.com/v1/create-qr-code/?size=400x400&data=https%3A%2F%2Fdonbeto.midominio.com
```

### Imprimir en la mini impresora

- Tamaño mínimo: **3 × 3 cm**
- Blanco puro alrededor del QR (zona de silencio) — las térmicas imprimen bien el negro sólido
- Si sale grisátono, sube contraste; un QR sucio no escanea

### Sin impresora en el lugar

Envía la **imagen del QR por WhatsApp al cliente** + el link visible. Funciona idéntico: él puede imprimirlo después o usarlo en pantalla.

### Verificar el QR antes de cobrar

Escanea **con el celular del cliente** (no con el tuyo) y confirma que abre el menú. ✅

---

## 8. Checklist cronometrada del restaurante

| Tiempo | Acción |
|---|---|
| 0:00 | Saludo, mostrar ejemplo en tu cel, **foto del menú completo** (todas las páginas, buena luz) |
| 0:30 | Pegar prompt + foto en la IA → genera HTML mientras platicas con el dueño |
| 1:30 | Crear repo desde plantilla (Método A) o script en PC (Método B) |
| 2:30 | Editar `CNAME` + pegar `index.html` + activar Pages |
| 3:30 | Abrir la URL **en el celular del dueño** (prueba real, le encanta ver su menú) |
| 4:30 | Generar QR → imprimir / enviar por WhatsApp |
| 5:00 | Enseñar qué pasará cuando cambie precios (60 seg, desde el cel) |
| 5:30 | **💰 COBRAR** |

---

## 9. Comandos exactos (PC)

### 9.1 Prerrequisitos (una vez)

```powershell
# ¿Tienes GitHub CLI? (si dice "no se reconoce", instálalo):
winget install GitHub.cli
# Reinicia la terminal y autentícate:
gh auth login
# Verificar:
gh auth status
git config user.name    # debe estar (ya lo tienes: EdgarM100)
```

### 9.2 Montar el harness en GitHub (una vez)

```powershell
cd "C:\Users\eddga\OneDrive\Escritorio\Edgar\Innova Voice\Clientes\06. Menus_Github"
git branch -m main
git add .
git commit -m "harness: README + plantilla + script"
gh repo create menus-github --public --source . --push
```

### 9.3 Crear el repo plantilla (una vez)

```powershell
cd "_template"
git init -b main
git add .
git commit -m "plantilla menú mobile-first"
gh repo create menu-plantilla --public --source . --push
# ⚠️ En el navegador: https://github.com/EdgarM100/menu-plantilla/settings
#    → marca la casilla "Template repository" → Save
cd ..
```

### 9.4 Crear un cliente nuevo (1 comando)

```powershell
.\scripts\nuevo-cliente.ps1 -Cliente donbeto -Nombre "Don Beto" -Direccion "Av. Hidalgo 123, Centro" -WhatsApp 5215512345678 -Telefono 5215512345678
```

### 9.5 Equivalente manual (por si el script falla)

```powershell
# 1. Crear repo desde plantilla y clonarlo
gh repo create menu-donbeto --public --template EdgarM100/menu-plantilla
gh repo clone menu-donbeto
cd menu-donbeto

# 2. Subdominio
Set-Content CNAME "donbeto.midominio.com" -NoNewline

# 3. Pegar el HTML del cliente en index.html (editor de tu preferencia)

# 4. Subir
git add .
git commit -m "menú donbeto"
git push

# 5. Activar GitHub Pages
gh api repos/EdgarM100/menu-donbeto/pages -X POST -f "source[branch]=main" -f "source[path]=/"

# 6. Verificar
start https://donbeto.midominio.com
```

### 9.6 Comandos de verificación

```powershell
Resolve-DnsName donbeto.midominio.com          # DNS resuelve?
Invoke-WebRequest https://donbeto.midominio.com -Method Head   # ¿responde 200?
gh api repos/EdgarM100/menu-donbeto/pages --jq .html_url         # estado de Pages
```

---

## 10. Solución de problemas

| Síntoma | Causa / Solución |
|---|---|
| 404 en el subdominio | Pages no activo (§9.5 paso 5) o `CNAME` mal escrito o DNS sin propagar (`Resolve-DnsName`) |
| "DNS check in progress" en Settings→Pages | Espera propagación (5–60 min primera vez) |
| No aparece "Enforce HTTPS" | Certificado aún emitiéndose (hasta ~10–15 min en subdominio nuevo) |
| "Domain is already in use" | Otro repo reclamó ese subdominio: busca el `CNAME` viejo en tus repos y bórralo |
| La IA devuelve HTML de +1 MB | Re-pide *"sin base64, sin imágenes, solo texto, <15 KB"* |
| Cambios no se ven | Refresca con caché: abre en modo privado del Safari, o espera 60 seg |
| El QR no escanea | Imprime ≥3×3 cm, contraste alto, zona blanca alrededor |

---

## Resumen mental (guárdalo)

```
DNS wildcard:  UNA VEZ        *.midominio.com → EdgarM100.github.io
Nuevo cliente: 1 REPO         menu-<cliente> con su CNAME + index.html + Pages ON
En campo:      60 SEG          GitHub app → editar index.html → commit → LIVE
Costo:         $0             forever
```
