#!/usr/bin/env bash
# ============================================================
# Script dinámico de rendimiento para Ryzen 5 5600
# Usa amd-pstate en modo activo (EPP) + límite de frecuencia
# ============================================================

# Comprobación de permisos
if [ "$EUID" -ne 0 ]; then
    echo "⚠️  Ejecuta este script con sudo o como root."
    exit 1
fi

# Verificar que cpupower está disponible
if ! command -v cpupower &> /dev/null; then
    echo "❌ cpupower no encontrado. Instálalo con: sudo pacman -S cpupower"
    exit 1
fi

# Verificar que se usa el driver amd-pstate
CURRENT_DRIVER=$(cpupower frequency-info | grep "driver:" | awk '{print $2}')
if [ "$CURRENT_DRIVER" != "amd-pstate" ] && [ "$CURRENT_DRIVER" != "amd-pstate-epp" ]; then
    echo "❌ No se detecta amd-pstate como driver activo (driver actual: $CURRENT_DRIVER)."
    echo "   Añade 'amd_pstate=active' en los parámetros del kernel."
    exit 1
fi

# -----------------------------------------------------------
# MODO NORMAL (Ahorro energético, dinámico, máx. 3.5 GHz)
# -----------------------------------------------------------
function normal {
    echo "🧊 Activando modo NORMAL (ahorro dinámico, tope = frecuencia base)..."

    cpupower frequency-set -g powersave > /dev/null 2>&1

    if [ -e /sys/devices/system/cpu/cpufreq/policy0/energy_performance_preference ]; then
        echo balance_power | tee /sys/devices/system/cpu/cpufreq/policy*/energy_performance_preference > /dev/null
    elif [ -e /sys/devices/system/cpu/cpufreq/policy0/amd_pstate_epp ]; then
        echo balance_power | tee /sys/devices/system/cpu/cpufreq/policy*/amd_pstate_epp > /dev/null
    fi

    if [ -e /sys/devices/system/cpu/amd_pstate/cpb ]; then
        echo 0 | tee /sys/devices/system/cpu/amd_pstate/cpb > /dev/null
        turbo_msg="Turbo (CPB): DESACTIVADO"
    elif [ -e /sys/devices/system/cpu/cpufreq/boost ]; then
        echo 0 | tee /sys/devices/system/cpu/cpufreq/boost > /dev/null
        turbo_msg="Turbo Boost: DESACTIVADO"
    else
        turbo_msg="Turbo: No controlable dinámicamente"
    fi

    if [ -f /sys/devices/system/cpu/cpu0/cpufreq/base_frequency ]; then
        BASE_FREQ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/base_frequency)
    else
        # Fallback para Ryzen 5 5600 (3500 MHz en kHz)
        BASE_FREQ=3900000
    fi
    echo "$BASE_FREQ" | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq > /dev/null

    echo ""
    echo "✅ Modo NORMAL activado"
    echo "   • Gobernador    : powersave"
    echo "   • EPP           : balance_power"
    echo "   • $turbo_msg"
    echo "   • Frec. máxima  : $((BASE_FREQ / 1000)) MHz (dinámico hasta ese tope)"
    echo "   • Rango actual  :"
    cpupower frequency-info | grep -E "hardware limits|available frequency" | sed 's/^/     /'
    echo ""
}

# -----------------------------------------------------------
# MODO TURBO (Máximo rendimiento, boost completo)
# -----------------------------------------------------------
function turbo {
    echo "⚡️ Activando modo TURBO (máximo rendimiento, boost habilitado)..."

    cpupower frequency-set -g performance > /dev/null 2>&1

    if [ -e /sys/devices/system/cpu/cpufreq/policy0/energy_performance_preference ]; then
        echo performance | tee /sys/devices/system/cpu/cpufreq/policy*/energy_performance_preference > /dev/null
    elif [ -e /sys/devices/system/cpu/cpufreq/policy0/amd_pstate_epp ]; then
        echo performance | tee /sys/devices/system/cpu/cpufreq/policy*/amd_pstate_epp > /dev/null
    fi

    if [ -e /sys/devices/system/cpu/amd_pstate/cpb ]; then
        echo 1 | tee /sys/devices/system/cpu/amd_pstate/cpb > /dev/null
        turbo_msg="Turbo (CPB): ACTIVADO"
    elif [ -e /sys/devices/system/cpu/cpufreq/boost ]; then
        echo 1 | tee /sys/devices/system/cpu/cpufreq/boost > /dev/null
        turbo_msg="Turbo Boost: ACTIVADO"
    else
        turbo_msg="Turbo: No controlable dinámicamente"
    fi

    if [ -f /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq ]; then
        REAL_MAX=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)
        echo "$REAL_MAX" | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq > /dev/null
    fi

    echo ""
    echo "✅ Modo TURBO activado"
    echo "   • Gobernador    : performance"
    echo "   • EPP           : performance"
    echo "   • $turbo_msg"
    echo "   • Frec. máxima  : sin límite artificial (boost disponible)"
    echo "   • Rango actual  :"
    cpupower frequency-info | grep -E "hardware limits|available frequency" | sed 's/^/     /'
    echo ""
}

# -----------------------------------------------------------
# Uso del script
# -----------------------------------------------------------
case "$1" in
    normal) normal ;;
    turbo)  turbo  ;;
    *)
        echo "📋 Uso: $0 {normal|turbo}"
        echo "   normal → Ahorro dinámico (hasta frecuencia base 3.5 GHz)"
        echo "   turbo  → Máximo rendimiento con boost"
        exit 1
        ;;
esac
