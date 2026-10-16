# 🍽️ Menús Digitales en Campo — Harness de Despliegue Ultra Rápido

> **Modelo:** llegas → foto del menú → IA genera HTML → lo subes a GitHub → QR impreso/enviado → cobras.
> **Costo total: $0** — GitHub Pages gratis, repos públicos ilimitados, **sin necesidad de comprar dominio**.

---

## Dos modos de operar

| | **Modo GRATIS** (por defecto, actívalo ya) | **Modo DOMINIO** (cuando compres/consigas uno) |
|---|---|---|
| URL del cliente | `https://edgarm100.github.io/menu-donbeto/` | `https://donbeto.tudominio.com` |
| Costo | **$0 para siempre** | dominio ~$10–12 USD/año |
| DNS | Nada que configurar | 1 registro wildcard (ver §2) |
| Archivo `CNAME` | No se usa | Sí |
| Setup | 0 minutos | 15 min |

> **La verdad sin rodeos:** un subdominio propio bonito (`cliente.tudominio.com`) **no se puede conseguir gratis** — hay que comprar el dominio. Lo que sí es gratis y funciona igual de bien para el negocio es la URL de GitHub Pages (Modo GRATIS). Si algún día quieres las URLs bonitas, compras el dominio y **solo agregas el CNAME**, todo lo demás queda igual.
>
> Alternativas gratis que existen (por si te interesan): `eu.org` (dominio gratis pero tarda semanas en aprobarse), `netlify.app` / `pages.dev` (subdominio por sitio, requiere cuenta extra), `duckdns.org` (subdominios gratis pero de servicio DDNS, poco profesional).

---

## Índice

1. [Hosting: comparativa gratuita](#1-hosting-comparativa-gratuita)
2. [DNS — solo Modo DOMINIO (opcional)](#2-dns--solo-modo-dominio-opcional)
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

| Servicio | Gratis | URL por cliente sin dominio | Uso comercial | Veredicto |
|---|---|---|---|---|
| **GitHub Pages** ✅ | Sí, $0 | `edgarm100.github.io/menu-cliente/` | Sí | **ELECCIÓN** — ya lo tienes montado, sin límite de clientes |
| Netlify | Sí (100 GB/mes) | `menu-cliente.netlify.app` | Sí | Alternativa si quieres subdominio sin comprar dominio |
| Cloudflare Pages | Sí (banda ilimitada) | `menu-cliente.pages.dev` | Sí | Alternativa sólida |
| Vercel Hobby | Sí | `menu-cliente.vercel.app` | ❌ **NO** (Hobby = solo proyectos personales) | Descartado para negocio |

**¿Por qué GitHub Pages gana?** Ya está configurado en tu cuenta, es gratis para siempre, público, sin límite de repos y sin tarjeta. Cada cliente = 1 repo = 1 URL propia.

---

## 2. DNS — solo Modo DOMINIO (opcional)

> ⚠️ **Puedes ignorar toda esta sección** mientras uses Modo GRATIS. Vuelve aquí solo si compras un dominio.

**Cómo funciona en Modo DOMINIO:** GitHub Pages no permite wildcard nativo, pero con **DNS wildcard + 1 archivo `CNAME` por repo** funciona:

```
DNS (una sola vez):   *.tudominio.com  →  CNAME  →  edgarm100.github.io
Cada repo declara:    archivo CNAME = "donbeto.tudominio.com"
GitHub enruta por Host → sirve el repo correcto ✅
```

### Registro DNS (en tu proveedor: GoDaddy, Namecheap, Hostinger...)

| Campo | Valor |
|---|---|
| Tipo | **CNAME** |
| Nombre / Host | `*` |
| Valor / Destination | `edgarm100.github.io` |
| TTL | Auto (o 30 min) |

> Algunos paneles piden el nombre completo: `*.tudominio.com`.
> Si el valor queda como `edgarm100.github.io.tudominio.com`, **está mal**: debe ser exactamente `edgarm100.github.io`.

### Verificación

```powershell
Resolve-DnsName donbeto.tudominio.com   # debe resolver a 185.199.x.x vía CNAME
```

HTTPS es automático: GitHub emite el certificado por cada subdominio declarado.

---

## 3. Estructura del repositorio

### En tu PC (esta carpeta = harness central)

```
06. Menus_Github/
├── README.md                    ← este archivo (la biblia del sistema)
├── _template/                   ← plantilla que se convierte en cada cliente
│   ├── index.html               ← menú mobile-first base
│   └── .nojekyll                ← desactiva Jekyll (evita que borre archivos raros)
└── scripts/
    └── nuevo-cliente.ps1        ← crea un cliente completo en 1 comando
```

> El archivo `CNAME` **no está en la plantilla** a propósito: solo se crea cuando usas Modo DOMINIO (el script lo genera).

### En tu cuenta de GitHub (ilimitado, gratis)

```
EdgarM100/
├── menus-github       ← este harness (documentación + script)
├── menu-plantilla     ← repo marcado como "Template repository" (para duplicar desde el cel)
├── menu-demo          ← menú de ventas / demo → edgarm100.github.io/menu-demo/
├── menu-donbeto       ← cliente 1 → edgarm100.github.io/menu-donbeto/
├── menu-laparra       ← cliente 2 → edgarm100.github.io/menu-laparra/
└── menu-taqueria-mario ← cliente 3 → edgarm100.github.io/menu-taqueria-mario/
```

**Convención:**
- Repo: `menu-<nombre-corto>` (minúsculas y guiones; ej. `menu-donbeto`)
- URL Modo GRATIS: `https://edgarm100.github.io/menu-<nombre-corto>/`
- URL Modo DOMINIO: `https://<nombre-corto>.tudominio.com`
- No cambies el nombre del repo después: **el QR dejaría de funcionar**.

**Archivos dentro del repo del cliente:**

| Archivo | Función |
|---|---|
| `index.html` | El menú que genera la IA |
| `.nojekyll` | GitHub Pages no procesa el repo con Jekyll → nada se borra |
| `CNAME` | Solo Modo DOMINIO (una línea: `donbeto.tudominio.com`) |
| `img/` (opcional) | Fotos de platos — el repo te sirve de hosting de imágenes gratis |

---

## 4. Flujo en campo desde tu iPhone

> **Una vez:** el repo `menu-plantilla` ya está creado y marcado como *Template repository* ✅

### Modo GRATIS — ~4 min (recomendado)

1. **Foto el menú** con tu celular.
2. **IA genera el HTML** (prompt en §5) — mientras hablas con el cliente.
3. **Crear repo desde plantilla** (Safari o app GitHub):
   - Abre: `https://github.com/EdgarM100/menu-plantilla/generate`
   - Nombre: `menu-donbeto` → **Create repository from template**
4. **Pegar el menú** → abre `index.html` → ✏️ editar → seleccionar todo → pega el HTML de la IA → **Commit changes**.
5. **Activar Pages** (solo la primera vez de ese repo) → abre:
   `https://github.com/EdgarM100/menu-donbeto/settings/pages`
   → Source: **Deploy from a branch** → Branch: **main** / **(root)** → **Save**
6. **Verificar:** abre `https://edgarm100.github.io/menu-donbeto/` (~30–60 seg la primera vez).
7. **QR** → imprime o envía por WhatsApp → **cobra**. ✅

### Modo DOMINIO — un paso extra

Igual que arriba, más:
- Crea el archivo `CNAME` con `donbeto.tudominio.com` (una línea) y **antes** de activar Pages.
- La URL será `https://donbeto.tudominio.com`.

> 💡 La app de GitHub en iOS también te deja editar archivos directo (lápiz ✏️). Si te manda a vista web, es el mismo flujo.

### Desde tu PC (1 comando)

```powershell
# Modo GRATIS (sin dominio):
.\scripts\nuevo-cliente.ps1 -Cliente donbeto -Nombre "Don Beto" -Direccion "Av. Hidalgo 123, Centro" -WhatsApp 5215512345678 -Telefono 5215512345678

# Modo DOMINIO (cuando tengas dominio):
.\scripts\nuevo-cliente.ps1 -Cliente donbeto -Dominio tudominio.com -Subdominio donbeto -Nombre "Don Beto"
```

### Actualizar un menú desde el celular (~60 seg)

1. App GitHub → repo del cliente → `index.html` → ✏️
2. Editar lo que cambió (precios, platillos) → **Commit**
3. **Live en ~30–60 segundos.** Abre la URL para verificar.

### Reglas de oro

- **`index.html` < ~250 KB**: si la IA devuelve HTML gigante, pídele *"sin imágenes embebidas, sin base64, HTML ligero"*.
- **Fotos:** súbelas al repo (`Add file → Upload files` → carpeta `img/`) y referéncialas como `img/plato.jpg`.
- **Nunca** renombres el repo ni borres `.nojekyll`.

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

**Archivo:** `_template/index.html` — punto de partida de cada menú.

- **Mobile-first**: viewport correcto, `max-width: 640px` centrado en pantallas grandes
- **Ligera**: un solo archivo, CSS inline, **sin JavaScript**, tipografía del sistema (cero descargas) — pesa ~6 KB
- **Estructura**: header → chips de categorías con anclas → filas platillo/precio → footer
- **Acción**: botones fijos abajo de **Llamar** (`tel:`) y **WhatsApp** (`wa.me`)
- Marcadores a reemplazar: `NOMBRE_RESTAURANTE`, `DIRECCION`, `TELEFONO_NUMERO`, `WHATSAPP_NUMERO`
- Colores personalizables por cliente: variables `--bg`, `--card`, `--accent` al inicio del `<style>`

---

## 7. QR, impresión y cobro

### Generar el QR (desde el celular)

Abre esta URL (mantén presionada la imagen → **Guardar en Fotos**):

```
https://api.qrserver.com/v1/create-qr-code/?size=400x400&data=https%3A%2F%2Fedgarm100.github.io%2Fmenu-donbeto%2F
```

> El script `nuevo-cliente.ps1` ya te imprime la URL exacta del QR lista para copiar.

### Imprimir en la mini impresora

- **Modo GRATIS** (URL larga): imprime **mínimo 4 × 4 cm** — la URL de GitHub lleva más caracteres y el QR es más denso.
- **Modo DOMINIO** (URL corta): 3 × 3 cm es suficiente.
- Zona blanca alrededor del QR (silencio) y contraste alto — las térmicas deben imprimir negro sólido.

### Sin impresora en el lugar

Envía la **imagen del QR por WhatsApp al cliente** + el link en texto. Funciona idéntico.

### Verificar antes de cobrar

Escanea **con el celular del cliente** (no con el tuyo) y confirma que abre el menú. ✅

---

## 8. Checklist cronometrada del restaurante

| Tiempo | Acción |
|---|---|
| 0:00 | Saludo, mostrar `edgarm100.github.io/menu-demo/` en tu cel, **foto del menú completo** (buena luz) |
| 0:30 | Pegar prompt + foto en la IA → genera HTML mientras platicas con el dueño |
| 1:30 | Crear repo desde plantilla (cel) o script (PC) |
| 2:30 | Pegar `index.html` + activar Pages (Modo GRATIS) o también crear `CNAME` (Modo DOMINIO) |
| 3:30 | Abrir la URL **en el celular del dueño** (le encanta ver su menú) |
| 4:30 | Generar QR → imprimir / enviar por WhatsApp |
| 5:00 | Enseñar qué pasará cuando cambie precios (60 seg, desde el cel) |
| 5:30 | **💰 COBRAR** |

---

## 9. Comandos exactos (PC)

### 9.1 Prerrequisitos

```powershell
# Ya instalado ✅ (si no):
winget install GitHub.cli
gh auth login
gh auth status    # debe decir: Logged in as EdgarM100
```

### 9.2 Estado actual (ya hecho)

```powershell
# ✅ https://github.com/EdgarM100/menus-github    (harness)
# ✅ https://github.com/EdgarM100/menu-plantilla  (marcado como Template repository)
# ✅ https://github.com/EdgarM100/menu-demo       (menú de ventas)
```

### 9.3 Actualizar el harness (cuando edites README o plantilla)

```powershell
cd "C:\Users\eddga\OneDrive\Escritorio\Edgar\Innova Voice\Clientes\06. Menus_Github"
git add .
git commit -m "update harness"
git push
```

### 9.4 Crear un cliente nuevo (1 comando)

```powershell
# Modo GRATIS (sin dominio) — recomendado:
.\scripts\nuevo-cliente.ps1 -Cliente donbeto -Nombre "Don Beto" -Direccion "Av. Hidalgo 123, Centro" -WhatsApp 5215512345678 -Telefono 5215512345678

# Modo DOMINIO (requiere DNS wildcard configurado, §2):
.\scripts\nuevo-cliente.ps1 -Cliente donbeto -Dominio tudominio.com -Subdominio donbeto -Nombre "Don Beto"
```

El script: crea el repo público desde `_template`, reemplaza marcadores, hace push, activa GitHub Pages e imprime la URL + QR.

### 9.5 Equivalente manual (si el script falla)

```powershell
# 1. Crear repo desde plantilla y clonarlo
gh repo create menu-donbeto --public --template EdgarM100/menu-plantilla
gh repo clone menu-donbeto
cd menu-donbeto

# 2. Pegar el HTML del cliente en index.html (editor de tu preferencia)

# 3. Subir
git add .
git commit -m "menú donbeto"
git push

# 4. Activar GitHub Pages
gh api repos/EdgarM100/menu-donbeto/pages -X POST -f "source[branch]=main" -f "source[path]=/"

# 5. Abrir la URL (Modo GRATIS)
start https://edgarm100.github.io/menu-donbeto/
```

### 9.6 Comandos de verificación

```powershell
Invoke-WebRequest https://edgarm100.github.io/menu-donbeto/ -Method Head   # ¿responde 200?
gh api repos/EdgarM100/menu-donbeto/pages --jq .status                    # debe decir: built
gh api repos/EdgarM100/menu-donbeto/pages --jq .html_url
```

---

## 10. Solución de problemas

| Síntoma | Causa / Solución |
|---|---|
| 404 en la URL | Pages no activo (§9.5 paso 4). Espera 30–60 seg tras activarlo |
| Página se ve sin estilos o vacía | Pegaste el HTML incompleto; vuelve a pegar el `index.html` completo |
| Cambios no se ven | Caché del celular: abre en pestaña privada o espera 60 seg |
| La URL "se va" a otro dominio | Hay un archivo `CNAME` en el repo (Modo DOMINIO) apuntando a un dominio que no existe. En Modo GRATIS **borra el archivo `CNAME`** |
| El QR no escanea | Imprime ≥4×4 cm (URL larga), contraste alto, zona blanca alrededor |
| La IA devuelve HTML de +1 MB | Re-pide *"sin base64, sin imágenes, solo texto, <15 KB"* |
| `gh: command not found` | `winget install GitHub.cli` y abre una terminal nueva |

---

## Resumen mental (guárdalo)

```
MODO GRATIS:   0 CONFIG       repo menu-<cliente> + Pages ON  →  edgarm100.github.io/menu-<cliente>/
MODO DOMINIO:  1 VEZ          *.tudominio.com → EdgarM100.github.io  +  CNAME por repo
En campo:      60 SEG         GitHub app → editar index.html → commit → LIVE
Costo:         $0             (dominio opcional ~$10-12 USD/año, solo si quieres URL bonita)
```
