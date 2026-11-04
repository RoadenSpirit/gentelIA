#!/usr/bin/env bash
# =============================================================================
# vps-gentle-menu.sh — Gestor interactivo de sesiones Gentle Shell en VPS
# Ejecutado automáticamente al conectar con Eternal Terminal (ET) o SSH.
# =============================================================================

export PATH="/home/your-user/.nvm/versions/node/v22.23.4/bin:/home/your-user/.local/bin:$PATH"
export LD_LIBRARY_PATH="/home/your-user/.local/lib:$LD_LIBRARY_PATH"
export TERM="xterm-256color"

PROJ_ROOT="/home/your-user/proyectos"
mkdir -p "$PROJ_ROOT"

# Función para listar sesiones tmux que empiezan con 'gentle-'
get_active_sessions() {
    tmux list-sessions -F "#{session_name}" 2>/dev/null | grep '^gentle-' || true
}

while true; do
    clear
    echo "=========================================================="
    echo "       GENTLE SHELL — GESTOR DE SESIONES VPS (ET)         "
    echo "=========================================================="
    echo "  Node: $(node -v 2>/dev/null || echo 'v22.23.4') · Pi: 1.4.0 · Gentle: 4.3.0"
    echo "  Provider: FreeLLMAPI (http://127.0.0.1:3005/v1)"
    echo "=========================================================="
    echo ""

    # 1. Obtener sesiones activas
    active_sessions=($(get_active_sessions))
    opt_num=1

    declare -A opt_actions
    declare -A opt_targets

    if [ ${#active_sessions[@]} -gt 0 ]; then
        echo "--- 🟢 SESIONES ACTIVAS DE GENTLE SHELL ---"
        for s in "${active_sessions[@]}"; do
            proj_name="${s#gentle-}"
            echo "  [$opt_num] - Reconectar a: $proj_name (tmux: $s)"
            opt_actions[$opt_num]="attach"
            opt_targets[$opt_num]="$s"
            ((opt_num++))
        done
        echo ""
    fi

    # 2. Listar proyectos en /home/your-user/proyectos
    projs=($(find "$PROJ_ROOT" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null | sort))
    echo "--- 📁 PROYECTOS DISPONIBLES EN ~/proyectos ---"
    for p in "${projs[@]}"; do
        # Verificar si ya tiene sesión activa
        if [[ " ${active_sessions[*]} " =~ " gentle-${p} " ]]; then
            continue
        fi
        echo "  [$opt_num] - Iniciar en: $p"
        opt_actions[$opt_num]="start"
        opt_targets[$opt_num]="$p"
        ((opt_num++))
    done
    echo ""

    # 3. Opciones generales
    opt_new=$opt_num
    echo "--- ⚙️  OPCIONES GENERALES ---"
    echo "  [$opt_new] - NUEVO PROYECTO (crea nueva carpeta y arranca)"
    echo "  [0] - Salir de la terminal"
    echo "=========================================================="
    read -p "Selecciona una opción [0-$opt_new]: " choice

    if [ -z "$choice" ] || [ "$choice" = "0" ]; then
        echo "Hasta pronto."
        exit 0
    fi

    if [ "$choice" = "$opt_new" ]; then
        read -p "Nombre del nuevo proyecto (sin espacios): " new_p
        new_p=$(echo "$new_p" | tr -cd 'a-zA-Z0-9_-')
        if [ -n "$new_p" ]; then
            p_dir="$PROJ_ROOT/$new_p"
            mkdir -p "$p_dir"
            sess_name="gentle-$new_p"
            echo "Iniciando Gentle Shell en $p_dir..."
            tmux new-session -s "$sess_name" -c "$p_dir" "gentle-shell"
        fi
        continue
    fi

    action="${opt_actions[$choice]:-}"
    target="${opt_targets[$choice]:-}"

    if [ "$action" = "attach" ]; then
        echo "Reconectando a sesión $target..."
        tmux attach-session -t "$target"
    elif [ "$action" = "start" ]; then
        p_dir="$PROJ_ROOT/$target"
        sess_name="gentle-$target"
        echo "Iniciando sesión $sess_name en $p_dir..."
        tmux new-session -s "$sess_name" -c "$p_dir" "gentle-shell"
    else
        echo "Opción inválida. Presiona Enter para continuar..."
        read -r
    fi
done
