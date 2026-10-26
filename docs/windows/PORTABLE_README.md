# GUÍA DE CONEXIÓN PORTABLE EN WINDOWS (SIN WSL)

Esta carpeta contiene todo lo necesario para conectarte a **Gentle Shell** en tu VPS desde **cualquier PC con Windows (Windows 10 u 11)** de forma 100% portable y **sin necesidad de WSL, Docker ni permisos de administrador**.

---

## 1. ¿Cómo funciona en Windows sin WSL?

El binario incluido en `et-client\et.exe` es un **ejecutable nativo de Windows (Win64 Portable)** compilado por el creador de Eternal Terminal.
- **No requiere WSL** ni máquinas virtuales.
- **No requiere instalación**: corre directamente al hacer doble clic.
- **Utiliza OpenSSH nativo de Windows**: Windows 10 y 11 ya traen `ssh.exe` en `C:\Windows\System32\OpenSSH\ssh.exe` de serie para autenticar el handshake inicial.
- **Zero-lag y reconexión**: Se conecta al puerto `2022` del VPS y mantiene la sesión viva ante microcortes o cambios de Wi-Fi.

---

## 2. Contenido de esta Carpeta Portable

```text
conexion_windows/
├── conectar_gentle.bat      <- LANZADOR PORTABLE (doble clic)
├── et-client/
│   └── et.exe               <- Binario nativo Windows x64 (Eternal Terminal)
├── wg0.conf                 <- Configuración de WireGuard (opcional)
└── PORTABLE_README.md       <- Esta guía
```

---

## 3. Cómo usarlo en cualquier PC (3 Casos de Uso)

### Caso 1: En tu PC habitual con tu clave SSH configurada
1. Ten WireGuard encendido en Windows (o conéctate directo si estás en red externa).
2. Haz doble clic en **`conectar_gentle.bat`**.
3. El script detectará tu clave en `%USERPROFILE%\.ssh` y abrirá la terminal al instante.

### Caso 2: En una PC prestada / nueva (100% Portable con Pendrive)
Si estás en una PC que no tiene tus claves SSH en `C:\Users\<Usuario>\.ssh`:
1. Copia tu archivo de clave privada (ej. `id_ed25519` o `id_rsa`) directamente **dentro de esta misma carpeta** junto a `conectar_gentle.bat`.
2. Haz doble clic en **`conectar_gentle.bat`**.
3. El script detectará automáticamente la clave en su propia carpeta y se autenticará con la VPS sin tocar ni configurar nada en esa PC ajena.

### Caso 3: En una PC sin WireGuard instalado
1. Si la PC no tiene la app de WireGuard, el script hace ping a `10.8.0.1`, detecta que no responde y **conmuta automáticamente a la IP pública `YOUR_VPS_IP`**.
2. La conexión se establece con la misma fluidez y seguridad a través de los puertos protegidos `22` y `2022`.

---

## 4. Comando para Descargar esta Carpeta a tu PC

Desde PowerShell o CMD en Windows:
```powershell
scp -P 22 -r your-user@YOUR_VPS_IP:/home/your-user/proyectos/gentelIA/docs/windows ./gentle_windows
```
Entra en la carpeta `gentle_windows` y ejecuta `conectar_gentle.bat`.
