pragma Singleton
import QtQuick 2.15

QtObject {
    // ===== COLORES DE FONDO =====
    readonly property color bgPrimary: "#06080d"
    readonly property color bgSecondary: "#0d1117"
    readonly property color bgTertiary: "#161b22"
    readonly property color bgCard: "#1c2128"
    readonly property color bgCardHover: "#262c36"
    readonly property color bgInput: "#0d1117"
    readonly property color bgOverlay: "#010409"
    
    // ===== COLORES DE ACENTO =====
    readonly property color accentBlue: "#58a6ff"
    readonly property color accentBlueDim: "#1f6feb"
    readonly property color accentGreen: "#3fb950"
    readonly property color accentGreenDim: "#238636"
    readonly property color accentYellow: "#d29922"
    readonly property color accentYellowDim: "#9e6a03"
    readonly property color accentRed: "#f85149"
    readonly property color accentRedDim: "#da3633"
    readonly property color accentPurple: "#a371f7"
    readonly property color accentPurpleDim: "#8957e5"
    readonly property color accentOrange: "#db6d28"
    readonly property color accentOrangeDim: "#bd561d"
    readonly property color accentCyan: "#39c5cf"
    readonly property color accentPink: "#f778ba"
    
    // ===== COLORES DE TEXTO =====
    readonly property color textPrimary: "#e6edf3"
    readonly property color textSecondary: "#8b949e"
    readonly property color textTertiary: "#6e7681"
    readonly property color textMuted: "#484f58"
    readonly property color textLink: "#58a6ff"
    readonly property color textInverse: "#0d1117"
    
    // ===== COLORES DE BORDE =====
    readonly property color borderDefault: "#30363d"
    readonly property color borderMuted: "#21262d"
    readonly property color borderSubtle: "#1b1f24"
    readonly property color borderAccent: "#58a6ff"
    
    // ===== COLORES DE ESTADO =====
    readonly property color statusCritical: "#f85149"
    readonly property color statusCriticalBg: "#490202"
    readonly property color statusWarning: "#d29922"
    readonly property color statusWarningBg: "#4d2d00"
    readonly property color statusSuccess: "#3fb950"
    readonly property color statusSuccessBg: "#0f2d16"
    readonly property color statusInfo: "#58a6ff"
    readonly property color statusInfoBg: "#0d2035"
    
    // ===== COLORES PARA DATOS/GRÁFICOS =====
    readonly property color dataCH4: "#a371f7"
    readonly property color dataCO: "#f85149"
    readonly property color dataO2: "#3fb950"
    readonly property color dataTrajectory: "#58a6ff"
    readonly property color dataBattery: "#3fb950"
    readonly property color dataSpeed: "#39c5cf"
    readonly property color dataAltitude: "#d29922"
    
    // ===== TIPOGRAFÍA =====
    readonly property string fontPrimary: "Segoe UI"
    readonly property string fontMono: "Cascadia Code"
    readonly property string fontFallback: "Arial"
    
    // Tamaños de fuente
    readonly property int fontSizeXs: 10
    readonly property int fontSizeS: 11
    readonly property int fontSizeM: 13
    readonly property int fontSizeL: 15
    readonly property int fontSizeXl: 18
    readonly property int fontSizeXxl: 24
    readonly property int fontSizeTitle: 32
    
    // ===== ESPACIADO =====
    readonly property int spacingXs: 4
    readonly property int spacingS: 8
    readonly property int spacingM: 12
    readonly property int spacingL: 16
    readonly property int spacingXl: 24
    readonly property int spacingXxl: 32
    
    // ===== RADIOS DE BORDE =====
    readonly property int radiusS: 4
    readonly property int radiusM: 6
    readonly property int radiusL: 8
    readonly property int radiusXl: 12
    readonly property int radiusRound: 9999
    
    // ===== SOMBRAS =====
    readonly property color shadowColor: "#000000"
    readonly property real shadowOpacity: 0.4
    
    // ===== ANIMACIONES =====
    readonly property int animFast: 100
    readonly property int animNormal: 200
    readonly property int animSlow: 300
    
    // ===== DIMENSIONES DE LAYOUT =====
    readonly property int headerHeight: 56
    readonly property int sidebarWidth: 320
    readonly property int panelMinWidth: 280
    readonly property int timelineHeight: 120
    readonly property int controlBarHeight: 48
    
    // ===== FUNCIONES DE UTILIDAD =====
    function withOpacity(color, opacity) {
        return Qt.rgba(color.r, color.g, color.b, opacity)
    }
    
    function severityColor(severity) {
        switch(severity) {
            case "critical": return statusCritical
            case "warning": return statusWarning
            case "low": return statusSuccess
            case "info": return statusInfo
            default: return textSecondary
        }
    }
    
    function severityBgColor(severity) {
        switch(severity) {
            case "critical": return statusCriticalBg
            case "warning": return statusWarningBg
            case "low": return statusSuccessBg
            case "info": return statusInfoBg
            default: return bgCard
        }
    }
    
    function typeColor(eventType) {
        switch(eventType) {
            case "gas": return accentPurple
            case "crack": return accentRed
            case "obstacle": return accentOrange
            case "anomaly": return accentCyan
            default: return textSecondary
        }
    }
    
    function typeIcon(eventType) {
        switch(eventType) {
            case "gas": return "💨"
            case "crack": return "⚡"
            case "obstacle": return "🚧"
            case "anomaly": return "⚠️"
            default: return "●"
        }
    }
}
