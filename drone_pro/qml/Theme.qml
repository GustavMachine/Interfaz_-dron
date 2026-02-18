pragma Singleton
import QtQuick

QtObject {
    // ===== COLORES DE FONDO =====
    readonly property color bgPrimary: "#06080d"
    readonly property color bgSecondary: "#0d1117"
    readonly property color bgTertiary: "#161b22"
    readonly property color bgCard: "#1c2128"
    readonly property color bgCardHover: "#262c36"
    readonly property color bgInput: "#0d1117"
    readonly property color bgOverlay: "#000000"
    
    // ===== COLORES DE ACENTO =====
    readonly property color accentBlue: "#58a6ff"
    readonly property color accentBlueBright: "#79c0ff"
    readonly property color accentBlueDark: "#1f6feb"
    readonly property color accentGreen: "#3fb950"
    readonly property color accentGreenBright: "#56d364"
    readonly property color accentGreenDark: "#238636"
    readonly property color accentYellow: "#d29922"
    readonly property color accentYellowBright: "#e3b341"
    readonly property color accentOrange: "#db6d28"
    readonly property color accentOrangeBright: "#f0883e"
    readonly property color accentRed: "#f85149"
    readonly property color accentRedBright: "#ff7b72"
    readonly property color accentRedDark: "#da3633"
    readonly property color accentPurple: "#a371f7"
    readonly property color accentPink: "#db61a2"
    readonly property color accentCyan: "#39c5cf"
    
    // ===== COLORES DE TEXTO =====
    readonly property color textPrimary: "#f0f6fc"
    readonly property color textSecondary: "#8b949e"
    readonly property color textMuted: "#6e7681"
    readonly property color textDisabled: "#484f58"
    
    // ===== COLORES DE BORDE =====
    readonly property color borderDefault: "#30363d"
    readonly property color borderMuted: "#21262d"
    readonly property color borderSubtle: "#1b1f24"
    
    // ===== COLORES SEMÁNTICOS =====
    readonly property color statusOk: "#3fb950"
    readonly property color statusWarning: "#d29922"
    readonly property color statusError: "#f85149"
    readonly property color statusInfo: "#58a6ff"
    
    // ===== TIPOGRAFÍA =====
    readonly property string fontPrimary: "Segoe UI"
    readonly property string fontMono: "Cascadia Code"
    readonly property string fontDisplay: "Segoe UI"
    
    // ===== TAMAÑOS DE FUENTE =====
    readonly property int fontSizeXS: 10
    readonly property int fontSizeS: 11
    readonly property int fontSizeM: 13
    readonly property int fontSizeL: 15
    readonly property int fontSizeXL: 18
    readonly property int fontSizeXXL: 22
    readonly property int fontSizeHuge: 28
    readonly property int fontSizeGiant: 36
    
    // ===== ESPACIADO =====
    readonly property int spacingXS: 4
    readonly property int spacingS: 8
    readonly property int spacingM: 12
    readonly property int spacingL: 16
    readonly property int spacingXL: 24
    readonly property int spacingXXL: 32
    
    // ===== BORDES REDONDEADOS =====
    readonly property int radiusS: 4
    readonly property int radiusM: 8
    readonly property int radiusL: 12
    readonly property int radiusXL: 16
    readonly property int radiusRound: 9999
    
    // ===== ANIMACIONES =====
    readonly property int animFast: 120
    readonly property int animNormal: 200
    readonly property int animSlow: 350
    
    // ===== FUNCIONES HELPER =====
    function getStatusColor(status) {
        if (status === 'ok') return statusOk
        if (status === 'warning') return statusWarning
        if (status === 'error') return statusError
        return statusInfo
    }
    
    function getRiskColor(risk) {
        if (risk === 'low') return accentGreen
        if (risk === 'medium') return accentYellow
        if (risk === 'high') return accentRed
        return textMuted
    }
    
    function getRiskText(risk) {
        if (risk === 'low') return 'BAJO'
        if (risk === 'medium') return 'MEDIO'
        if (risk === 'high') return 'ALTO'
        return 'N/A'
    }
    
    function getStrategyText(strategy) {
        if (strategy === 'follow_tunnel') return 'Seguir Túnel'
        if (strategy === 'round_trip') return 'Ida y Vuelta'
        if (strategy === 'sweep') return 'Barrido'
        if (strategy === 'point_inspect') return 'Inspección Puntual'
        return strategy
    }
    
    function getBehaviorText(behavior) {
        if (behavior === 'return_base') return 'Volver a Base'
        if (behavior === 'hover') return 'Hover en Lugar'
        if (behavior === 'mark_continue') return 'Marcar y Continuar'
        if (behavior === 'alert_only') return 'Solo Alertar'
        return behavior
    }
    
    function getSensitivityText(sens) {
        if (sens === 'high') return 'Alta'
        if (sens === 'balanced') return 'Balanceada'
        if (sens === 'low_fp') return 'Bajo FP'
        return sens
    }
    
    function formatTime(seconds) {
        var min = Math.floor(seconds / 60)
        var sec = seconds % 60
        return min + ":" + (sec < 10 ? "0" : "") + sec
    }
}
