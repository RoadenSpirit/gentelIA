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

# Usar socket dedicado para que todas las sesiones y clientes se reconozcan siempre
TMUX_CMD="tmux -L gentle"

# Función para listar sesiones tmux activas en el socket unificado
get_active_sessions() {
    $TMUX_CMD list-sessions -F "#{session_name}" 2>/dev/null | grep '^gentle-' || true
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

    # 2. Listar carpetas de proyectos disponibles en ~/proyectos
    echo "--- 📁 INICIAR NUEVA SESIÓN EN PROYECTO EXISTENTE ---"
    for dir in "$PROJ_ROOT"/*/; do
        [ -d "$dir" ] || continue
        dirname=$(basename "$dir")
        sess_name="gentle-$dirname"

        # Si ya tiene sesión activa, omitir de esta lista
        is_active=0
        for s in "${active_sessions[@]}"; do
            if [ "$s" = "$sess_name" ]; then
                is_active=1
                break
            fi
        done
        [ $is_active -eq 1 ] && continue

        echo "  [$opt_num] - Iniciar en: $dirname"
        opt_actions[$opt_num]="start"
        opt_targets[$opt_num]="$dirname"
        ((opt_num++))
    done
    echo ""

    # 3. Opciones generales y de gestión
    opt_new=$opt_num
    ((opt_num++))
    opt_kill=$opt_num

    echo "--- ⚙️  OPCIONES GENERALES ---"
    echo "  [$opt_new] - NUEVO PROYECTO (crea nueva carpeta y arranca)"
    if [ ${#active_sessions[@]} -gt 0 ]; then
        echo "  [$opt_kill] - 🗑️  CERRAR/TERMINAR UNA SESIÓN ACTIVA"
    fi
    echo "  [0] - Salir de la terminal"
    echo "=========================================================="
    read -p "Selecciona una opción [0-$opt_num]: " choice

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
            $TMUX_CMD new-session -s "$sess_name" -c "$p_dir" "gentle-shell"
        fi
        continue
    fi

    if [ ${#active_sessions[@]} -gt 0 ] && [ "$choice" = "$opt_kill" ]; then
        echo ""
        echo "--- SELECCIONA LA SESIÓN QUE DESEAS TERMINAR ---"
        k_num=1
        declare -A kill_targets
        for s in "${active_sessions[@]}"; do
            echo "  [$k_num] - $s"
            kill_targets[$k_num]="$s"
            ((k_num++))
        done
        echo "  [0] - Cancelar"
        read -p "Opción a terminar: " k_choice
        if [ -n "$k_choice" ] && [ "$k_choice" != "0" ] && [ -n "${kill_targets[$k_choice]:-}" ]; then
            target_to_kill="${kill_targets[$k_choice]}"
            echo "Cerrando $target_to_kill..."
            $TMUX_CMD kill-session -t "$target_to_kill" 2>/dev/null || true
            sleep 1
        fi
        continue
    fi

    action="${opt_actions[$choice]:-}"
    target="${opt_targets[$choice]:-}"

    if [ "$action" = "attach" ]; then
        echo "Reconectando a sesión $target..."
        $TMUX_CMD attach-session -t "$target"
    elif [ "$action" = "start" ]; then
        p_dir="$PROJ_ROOT/$target"
        sess_name="gentle-$target"
        echo "Iniciando sesión $sess_name en $p_dir..."
        $TMUX_CMD new-session -s "$sess_name" -c "$p_dir" "gentle-shell"
    else
        echo "Opción inválida. Presiona Enter para continuar..."
        read -r
    fi
done
