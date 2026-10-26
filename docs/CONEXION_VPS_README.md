# CONEXIÓN VPS — GUÍA COMPLETA Y RECURSOS DE ACCESO

Esta carpeta contiene todo lo necesario para conectarse a la VPS (`YOUR_VPS_IP`) desde cualquier sistema operativo (**Windows**, **Linux**, **macOS**), utilizar **OpenCode Web**, el agente **FX (Vercel Labs)** y **Antigravity CLI (agy)**.

---

## 1. Datos de Conexión y Credenciales

| Recurso | Valor |
|---|---|
| **IP Pública VPS** | `YOUR_VPS_IP` |
| **Puerto SSH** | `22` |
| **Usuario SSH** | `your-user` |
| **IP WireGuard Server** | `10.8.0.1` |
| **IP WireGuard Cliente** | `10.8.0.2/24` |
| **Puerto UDP WireGuard** | `60001` |
| **Server PubKey WireGuard** | `8n0VaJ9H6MC/BY4jI0pusnug7e4sHccZViXfKyWXNHE=` |
| **Cliente PubKey WireGuard** | `tmRcSxOtGqJAZnjP+yT1SRHa7LPX5SV/uuQotwyCGTI=` |
| **OpenCode Web Auth** | Usuario: `asere` \| Password: `YOUR_OPENCODE_PASSWORD` |
| **Puerto OpenCode Web** | `4096` |
| **Puerto FX Proxy** | `5090` |
| **Carpeta Raíz Proyectos** | `/home/your-user/proyectos/` |

---

## 2. Instalación Automática en Windows

Hemos creado un instalador automático en PowerShell/Batch para Windows.

### Pasos en Windows:

1. Copia la carpeta `conexion_vps` a tu equipo de Windows.
2. Haz **doble clic** en `setup_windows.bat` (o ejecuta `setup_windows.ps1` desde PowerShell como Administrador).
3. El script realizará automáticamente:
   - Configuración del archivo `wg0.conf` en WireGuard.
   - Creación de la configuración SSH (`C:\Users\<TuUsuario>\.ssh\config`).
   - Creación de ejecutables directos `.bat` para los tres entornos:
     - `conectar_opencode.bat` -> OpenCode Web
     - `conectar_fx.bat` -> FX (Vercel Labs)
     - `conectar_agy.bat` -> Antigravity CLI (agy)

---

## 3. Configuración de WireGuard en Windows (Manual)

Si prefieres importar la configuración de WireGuard manualmente en Windows:

1. Descarga e instala WireGuard para Windows desde [https://www.wireguard.com/install/](https://www.wireguard.com/install/).
2. Abre WireGuard y haz clic en **Añadir túnel** -> **Importar túnel(es) desde archivo...**
3. Selecciona el archivo `wg0.conf` de esta carpeta.
4. Si es una máquina Windows nueva, reemplaza `<REEMPLAZAR_POR_TU_CLAVE_PRIVADA_LOCAL>` por la clave privada generada por WireGuard y registra la nueva clave pública en el servidor.
5. Haz clic en **Activar**.

---

## 4. Archivos incluidos en esta carpeta

- `README.md`: Esta guía.
- `wg0.conf`: Archivo de configuración de WireGuard listo para importar.
- `setup_windows.ps1`: Script de automatización en PowerShell para Windows.
- `setup_windows.bat`: Lanzador ejecutable doble clic para Windows.
- `vps-tunnel`: Script lanzador para Linux/WSL/macOS para OpenCode Web (con submenú de 3 chats por proyecto).
- `vps-fx`: Script lanzador para Linux/WSL/macOS para el agente FX (Vercel Labs + proxy OmniRoute).
- `vps-agy`: Script lanzador espejo para Linux/WSL/macOS para Antigravity CLI (agy).

---

## 5. Uso de los Lanzadores en Linux / WSL / macOS

Para usar los lanzadores desde la consola:

```bash
# Para OpenCode Web (con submenú de 3 chats por proyecto)
vps-tunnel

# Para el agente FX (Vercel Labs)
vps-fx

# Para Antigravity CLI (agy)
vps-agy
```

---

## 6. Resolución de Problemas (Troubleshooting)

- **SSH no conecta por IP pública:** Si tienes ProtonVPN u otra VPN comercial activa en tu PC, desactívala o usa la ruta WireGuard (`10.8.0.1:22`), ya que las VPN comerciales suelen interceptar el puerto 22.
- **Túnel de OpenCode no escucha en puerto 4096:** Ejecuta `systemctl --user restart opencode-tunnel` en tu PC.
- **WireGuard activo pero sin ping a 10.8.0.1:** Desactiva y reactiva la interfaz `wg0` (en Windows: Desactivar/Activar en el panel de WireGuard; en Linux: `sudo wg-quick down wg0 && sudo wg-quick up wg0`).
