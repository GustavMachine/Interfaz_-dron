import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "." as App

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1920
    height: 1080
    minimumWidth: 1400
    minimumHeight: 800
    title: "Sistema de Inspección de Túneles Mineros"
    color: App.Theme.bgPrimary
    
    property bool missionReady: missionController.isReadyToStart()
    property int warningCount: missionController.getWarningCount()

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: App.Theme.bgPrimary }
            GradientStop { position: 1.0; color: "#030508" }
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // HEADER
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            color: App.Theme.bgSecondary
            
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: App.Theme.borderDefault
            }
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                spacing: 24
                
                // Logo
                RowLayout {
                    spacing: 14
                    
                    Rectangle {
                        width: 42
                        height: 42
                        radius: 10
                        color: App.Theme.accentBlueDark
                        
                        Text {
                            anchors.centerIn: parent
                            text: "🚁"
                            font.pixelSize: 20
                        }
                        
                        Rectangle {
                            anchors.fill: parent
                            radius: parent.radius
                            color: "transparent"
                            border.width: 1
                            border.color: App.Theme.accentBlue
                            opacity: 0.5
                        }
                    }
                    
                    Column {
                        spacing: 2
                        
                        Text {
                            text: "INSPECCIÓN AUTÓNOMA"
                            font.family: App.Theme.fontDisplay
                            font.pixelSize: App.Theme.fontSizeL
                            font.weight: Font.Bold
                            font.letterSpacing: 1
                            color: App.Theme.textPrimary
                        }
                        
                        Text {
                            text: "Sistema de Dron para Túneles Mineros"
                            font.family: App.Theme.fontPrimary
                            font.pixelSize: App.Theme.fontSizeS
                            color: App.Theme.textMuted
                        }
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                // Nav
                RowLayout {
                    spacing: 4
                    
                    NavTab {
                        tabText: "Configuración"
                        tabIcon: "⚙"
                        active: true
                    }
                    
                    NavTab {
                        tabText: "Teleoperación"
                        tabIcon: "🎮"
                        active: false
                    }
                    
                    NavTab {
                        tabText: "Análisis"
                        tabIcon: "📊"
                        active: false
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                // Sector
                Rectangle {
                    width: sectorRow.width + 20
                    height: 36
                    radius: App.Theme.radiusM
                    color: App.Theme.bgTertiary
                    border.width: 1
                    border.color: App.Theme.borderDefault
                    
                    Row {
                        id: sectorRow
                        anchors.centerIn: parent
                        spacing: 8
                        
                        Text {
                            text: "📍"
                            font.pixelSize: 14
                        }
                        
                        Text {
                            text: missionController.sectorInfo.name
                            font.family: App.Theme.fontMono
                            font.pixelSize: App.Theme.fontSizeS
                            color: App.Theme.textSecondary
                        }
                        
                        Rectangle {
                            width: 1
                            height: 16
                            color: App.Theme.borderDefault
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        Text {
                            text: missionController.sectorInfo.level
                            font.family: App.Theme.fontMono
                            font.pixelSize: App.Theme.fontSizeS
                            font.weight: Font.Bold
                            color: App.Theme.accentCyan
                        }
                    }
                }
                
                // Status
                Rectangle {
                    width: connRow.width + 20
                    height: 36
                    radius: App.Theme.radiusM
                    color: Qt.rgba(0.247, 0.725, 0.314, 0.1)
                    border.width: 1
                    border.color: Qt.rgba(0.247, 0.725, 0.314, 0.3)
                    
                    Row {
                        id: connRow
                        anchors.centerIn: parent
                        spacing: 8
                        
                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: App.Theme.accentGreen
                            anchors.verticalCenter: parent.verticalCenter
                            
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { to: 0.5; duration: 800 }
                                NumberAnimation { to: 1.0; duration: 800 }
                            }
                        }
                        
                        Text {
                            text: "ENLACE ACTIVO"
                            font.family: App.Theme.fontMono
                            font.pixelSize: App.Theme.fontSizeXS
                            font.weight: Font.Bold
                            color: App.Theme.accentGreen
                        }
                    }
                }
                
                // Clock
                Column {
                    spacing: 0
                    
                    Text {
                        id: timeText
                        text: Qt.formatTime(new Date(), "HH:mm:ss")
                        font.family: App.Theme.fontMono
                        font.pixelSize: App.Theme.fontSizeL
                        font.weight: Font.Bold
                        color: App.Theme.textPrimary
                        anchors.right: parent.right
                    }
                    
                    Text {
                        text: Qt.formatDate(new Date(), "ddd, dd MMM yyyy")
                        font.family: App.Theme.fontPrimary
                        font.pixelSize: App.Theme.fontSizeXS
                        color: App.Theme.textMuted
                        anchors.right: parent.right
                    }
                }
            }
            
            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: timeText.text = Qt.formatTime(new Date(), "HH:mm:ss")
            }
        }
        
        // MAIN CONTENT
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 16
            spacing: 16
            
            // LEFT COLUMN
            ColumnLayout {
                Layout.preferredWidth: 380
                Layout.fillHeight: true
                spacing: 12
                
                // Checklist Panel
                PanelCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 360
                    panelTitle: "Checklist Pre-Misión"
                    panelIcon: "✓"
                    iconColor: App.Theme.accentBlue
                    badge: warningCount > 0 ? warningCount + " aviso" : "Todo OK"
                    badgeColor: warningCount > 0 ? App.Theme.accentYellow : App.Theme.accentGreen
                    
                    contentItem: ListView {
                        clip: true
                        spacing: 6
                        model: missionController.checklist
                        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                        
                        delegate: ChecklistItem {
                            width: ListView.view.width - 8
                            itemData: modelData
                            onCalibrateClicked: missionController.calibrateSystem(modelData.id)
                        }
                    }
                }
                
                // Preset Panel
                PanelCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 140
                    panelTitle: "Tipo de Inspección"
                    panelIcon: "🎯"
                    iconColor: App.Theme.accentPurple
                    
                    contentItem: RowLayout {
                        spacing: 10
                        
                        PresetCard {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            presetIcon: "🔍"
                            presetTitle: "Grietas"
                            presetSubtitle: "Alta precisión"
                            accentColor: App.Theme.accentBlue
                            isSelected: missionController.missionConfig.preset === "cracks"
                            onClicked: missionController.selectPreset("cracks")
                        }
                        
                        PresetCard {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            presetIcon: "💨"
                            presetTitle: "Gases"
                            presetSubtitle: "Muestreo cont."
                            accentColor: App.Theme.accentOrange
                            isSelected: missionController.missionConfig.preset === "gases"
                            onClicked: missionController.selectPreset("gases")
                        }
                        
                        PresetCard {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            presetIcon: "🔬"
                            presetTitle: "Completa"
                            presetSubtitle: "Todos sensores"
                            accentColor: App.Theme.accentPurple
                            isSelected: missionController.missionConfig.preset === "full"
                            onClicked: missionController.selectPreset("full")
                        }
                    }
                }
                
                // Strategy Panel
                PanelCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
                    panelTitle: "Estrategia de Exploración"
                    panelIcon: "🧭"
                    iconColor: App.Theme.accentCyan
                    
                    contentItem: GridLayout {
                        columns: 2
                        rowSpacing: 6
                        columnSpacing: 6
                        
                        StrategyBtn {
                            Layout.fillWidth: true
                            stratIcon: "→"
                            stratText: "Seguir Túnel"
                            stratId: "follow_tunnel"
                            isSelected: missionController.missionConfig.explorationStrategy === "follow_tunnel"
                            onClicked: missionController.setExplorationStrategy("follow_tunnel")
                        }
                        
                        StrategyBtn {
                            Layout.fillWidth: true
                            stratIcon: "↔"
                            stratText: "Ida y Vuelta"
                            stratId: "round_trip"
                            isSelected: missionController.missionConfig.explorationStrategy === "round_trip"
                            onClicked: missionController.setExplorationStrategy("round_trip")
                        }
                        
                        StrategyBtn {
                            Layout.fillWidth: true
                            stratIcon: "⇉"
                            stratText: "Barrido"
                            stratId: "sweep"
                            isSelected: missionController.missionConfig.explorationStrategy === "sweep"
                            onClicked: missionController.setExplorationStrategy("sweep")
                        }
                        
                        StrategyBtn {
                            Layout.fillWidth: true
                            stratIcon: "◎"
                            stratText: "Puntos Clave"
                            stratId: "point_inspect"
                            isSelected: missionController.missionConfig.explorationStrategy === "point_inspect"
                            onClicked: missionController.setExplorationStrategy("point_inspect")
                        }
                    }
                }
                
                // Start Button
                StartButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 58
                    isReady: missionReady
                    warnings: warningCount
                    onClicked: missionController.startMission()
                }
                
                Item { Layout.fillHeight: true }
            }
            
            // CENTER: MAP
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12
                
                TunnelMap {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    waypoints: missionController.waypoints
                    restrictedZones: missionController.restrictedZones
                    sectorInfo: missionController.sectorInfo
                }
                
                RoutePanel {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 130
                    segments: missionController.simulation.routeSegments
                }
            }
            
            // RIGHT COLUMN
            ColumnLayout {
                Layout.preferredWidth: 350
                Layout.fillHeight: true
                spacing: 12
                
                // Flight Params
                PanelCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 210
                    panelTitle: "Parámetros de Vuelo"
                    panelIcon: "✈"
                    iconColor: App.Theme.accentGreen
                    
                    contentItem: ColumnLayout {
                        spacing: 14
                        
                        ConfigSlider {
                            Layout.fillWidth: true
                            label: "Velocidad"
                            sliderValue: missionController.missionConfig.speed
                            minVal: 0.1
                            maxVal: 1.2
                            unit: "m/s"
                            accentColor: App.Theme.accentBlue
                            onValueUpdated: function(v) { missionController.setMissionParam("speed", v) }
                        }
                        
                        ConfigSlider {
                            Layout.fillWidth: true
                            label: "Altura de vuelo"
                            sliderValue: missionController.missionConfig.hoverAltitude
                            minVal: 1.5
                            maxVal: 4.5
                            unit: "m"
                            accentColor: App.Theme.accentCyan
                            onValueUpdated: function(v) { missionController.setMissionParam("hoverAltitude", v) }
                        }
                        
                        ConfigSlider {
                            Layout.fillWidth: true
                            label: "Tiempo máximo"
                            sliderValue: missionController.missionConfig.maxTime
                            minVal: 5
                            maxVal: 30
                            unit: "min"
                            decimals: 0
                            accentColor: App.Theme.accentYellow
                            onValueUpdated: function(v) { missionController.setMissionParam("maxTime", v) }
                        }
                        
                        ConfigSlider {
                            Layout.fillWidth: true
                            label: "Distancia máxima"
                            sliderValue: missionController.missionConfig.maxDistance
                            minVal: 100
                            maxVal: 600
                            unit: "m"
                            decimals: 0
                            accentColor: App.Theme.accentOrange
                            onValueUpdated: function(v) { missionController.setMissionParam("maxDistance", v) }
                        }
                    }
                }
                
                // Detection Config
                PanelCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 180
                    panelTitle: "Detección y Alertas"
                    panelIcon: "⚠"
                    iconColor: App.Theme.accentYellow
                    
                    contentItem: ColumnLayout {
                        spacing: 12
                        
                        Column {
                            Layout.fillWidth: true
                            spacing: 6
                            
                            Text {
                                text: "Sensibilidad de grietas"
                                font.family: App.Theme.fontPrimary
                                font.pixelSize: App.Theme.fontSizeS
                                color: App.Theme.textSecondary
                            }
                            
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                
                                SensBtn {
                                    Layout.fillWidth: true
                                    btnText: "Alta"
                                    isSelected: missionController.detectionConfig.crackSensitivity === "high"
                                    onClicked: missionController.setCrackSensitivity("high")
                                }
                                
                                SensBtn {
                                    Layout.fillWidth: true
                                    btnText: "Balanceada"
                                    isSelected: missionController.detectionConfig.crackSensitivity === "balanced"
                                    onClicked: missionController.setCrackSensitivity("balanced")
                                }
                                
                                SensBtn {
                                    Layout.fillWidth: true
                                    btnText: "Bajo FP"
                                    isSelected: missionController.detectionConfig.crackSensitivity === "low_fp"
                                    onClicked: missionController.setCrackSensitivity("low_fp")
                                }
                            }
                        }
                        
                        Row {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            GasThreshold {
                                width: (parent.width - 10) / 2
                                label: "Pre-Alarma CH₄"
                                threshValue: missionController.detectionConfig.gasPreAlarm
                                unit: "% LEL"
                                threshColor: App.Theme.accentYellow
                            }
                            
                            GasThreshold {
                                width: (parent.width - 10) / 2
                                label: "Alarma CH₄"
                                threshValue: missionController.detectionConfig.gasAlarm
                                unit: "% LEL"
                                threshColor: App.Theme.accentRed
                            }
                        }
                        
                        Column {
                            Layout.fillWidth: true
                            spacing: 6
                            
                            Text {
                                text: "Comportamiento ante riesgo"
                                font.family: App.Theme.fontPrimary
                                font.pixelSize: App.Theme.fontSizeS
                                color: App.Theme.textSecondary
                            }
                            
                            RiskBehavior {
                                width: parent.width
                                currentBehavior: missionController.missionConfig.riskBehavior
                                onBehaviorChanged: function(b) { missionController.setRiskBehavior(b) }
                            }
                        }
                    }
                }
                
                // Simulation
                SimPanel {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    simulation: missionController.simulation
                    onRefreshClicked: missionController.runSimulation()
                }
            }
        }
    }

    // ========== COMPONENTS ==========
    
    component NavTab: Rectangle {
        property string tabText: ""
        property string tabIcon: ""
        property bool active: false
        
        width: navRow.width + 28
        height: 38
        radius: App.Theme.radiusM
        color: active ? App.Theme.accentBlueDark : (navMouse.containsMouse ? App.Theme.bgTertiary : "transparent")
        
        Behavior on color { ColorAnimation { duration: 100 } }
        
        Row {
            id: navRow
            anchors.centerIn: parent
            spacing: 8
            
            Text {
                text: tabIcon
                font.pixelSize: 14
            }
            
            Text {
                text: tabText
                font.family: App.Theme.fontPrimary
                font.pixelSize: App.Theme.fontSizeS
                font.weight: active ? Font.DemiBold : Font.Normal
                color: active ? App.Theme.textPrimary : App.Theme.textSecondary
            }
        }
        
        MouseArea {
            id: navMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
        }
    }
    
    component PanelCard: Rectangle {
        property string panelTitle: ""
        property string panelIcon: ""
        property color iconColor: App.Theme.accentBlue
        property string badge: ""
        property color badgeColor: App.Theme.accentGreen
        property alias contentItem: loader.sourceComponent
        
        color: App.Theme.bgCard
        radius: App.Theme.radiusL
        border.width: 1
        border.color: App.Theme.borderMuted
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Rectangle {
                    width: 26
                    height: 26
                    radius: 6
                    color: Qt.rgba(iconColor.r, iconColor.g, iconColor.b, 0.15)
                    
                    Text {
                        anchors.centerIn: parent
                        text: panelIcon
                        font.pixelSize: 13
                    }
                }
                
                Text {
                    text: panelTitle
                    font.family: App.Theme.fontDisplay
                    font.pixelSize: App.Theme.fontSizeM
                    font.weight: Font.DemiBold
                    color: App.Theme.textPrimary
                }
                
                Item { Layout.fillWidth: true }
                
                Rectangle {
                    visible: badge !== ""
                    width: bdgText.width + 12
                    height: 20
                    radius: 10
                    color: Qt.rgba(badgeColor.r, badgeColor.g, badgeColor.b, 0.15)
                    border.width: 1
                    border.color: Qt.rgba(badgeColor.r, badgeColor.g, badgeColor.b, 0.4)
                    
                    Text {
                        id: bdgText
                        anchors.centerIn: parent
                        text: badge
                        font.family: App.Theme.fontMono
                        font.pixelSize: 9
                        font.weight: Font.Bold
                        color: badgeColor
                    }
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: App.Theme.borderMuted
            }
            
            Loader {
                id: loader
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }
    
    component ChecklistItem: Rectangle {
        property var itemData: ({})
        signal calibrateClicked()
        
        height: 42
        radius: App.Theme.radiusS
        color: chkMouse.containsMouse ? App.Theme.bgCardHover : App.Theme.bgTertiary
        border.width: itemData.status === "warning" ? 1 : 0
        border.color: App.Theme.accentYellow
        
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 8
            
            Rectangle {
                width: 8
                height: 8
                radius: 4
                color: App.Theme.getStatusColor(itemData.status)
                
                SequentialAnimation on scale {
                    loops: Animation.Infinite
                    running: itemData.status === "warning"
                    NumberAnimation { to: 1.3; duration: 500 }
                    NumberAnimation { to: 1.0; duration: 500 }
                }
            }
            
            Text {
                text: itemData.icon || ""
                font.pixelSize: 14
            }
            
            Column {
                Layout.fillWidth: true
                spacing: 1
                
                Text {
                    text: itemData.label || ""
                    font.family: App.Theme.fontPrimary
                    font.pixelSize: App.Theme.fontSizeS
                    color: App.Theme.textPrimary
                }
                
                Text {
                    text: itemData.detail || ""
                    font.family: App.Theme.fontMono
                    font.pixelSize: 9
                    color: App.Theme.textMuted
                }
            }
            
            Text {
                text: typeof itemData.value === 'number' ? itemData.value + (itemData.unit ? " " + itemData.unit : "") : (itemData.value || "")
                font.family: App.Theme.fontMono
                font.pixelSize: App.Theme.fontSizeS
                font.weight: Font.Medium
                color: App.Theme.getStatusColor(itemData.status)
            }
            
            Rectangle {
                visible: itemData.status === "warning"
                width: 55
                height: 22
                radius: 11
                color: calMouse.containsMouse ? App.Theme.accentYellow : "transparent"
                border.width: 1
                border.color: App.Theme.accentYellow
                
                Text {
                    anchors.centerIn: parent
                    text: "Calibrar"
                    font.pixelSize: 9
                    font.weight: Font.Medium
                    color: calMouse.containsMouse ? App.Theme.bgPrimary : App.Theme.accentYellow
                }
                
                MouseArea {
                    id: calMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: calibrateClicked()
                }
            }
        }
        
        MouseArea {
            id: chkMouse
            anchors.fill: parent
            hoverEnabled: true
            propagateComposedEvents: true
            onPressed: function(m) { m.accepted = false }
        }
    }
    
    component PresetCard: Rectangle {
        property string presetIcon: ""
        property string presetTitle: ""
        property string presetSubtitle: ""
        property color accentColor: App.Theme.accentBlue
        property bool isSelected: false
        signal clicked()
        
        radius: App.Theme.radiusM
        color: isSelected ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.12) : (pMouse.containsMouse ? App.Theme.bgCardHover : App.Theme.bgTertiary)
        border.width: isSelected ? 2 : 1
        border.color: isSelected ? accentColor : App.Theme.borderMuted
        
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 3
            
            Text {
                text: presetIcon
                font.pixelSize: 22
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: presetTitle
                font.family: App.Theme.fontDisplay
                font.pixelSize: App.Theme.fontSizeS
                font.weight: Font.DemiBold
                color: isSelected ? accentColor : App.Theme.textPrimary
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: presetSubtitle
                font.family: App.Theme.fontPrimary
                font.pixelSize: 9
                color: App.Theme.textMuted
                Layout.alignment: Qt.AlignHCenter
            }
        }
        
        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 5
            width: 16
            height: 16
            radius: 8
            color: accentColor
            visible: isSelected
            
            Text {
                anchors.centerIn: parent
                text: "✓"
                font.pixelSize: 9
                font.weight: Font.Bold
                color: "white"
            }
        }
        
        MouseArea {
            id: pMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }
    
    component StrategyBtn: Rectangle {
        property string stratId: ""
        property string stratIcon: ""
        property string stratText: ""
        property bool isSelected: false
        signal clicked()
        
        height: 34
        radius: App.Theme.radiusS
        color: isSelected ? Qt.rgba(App.Theme.accentCyan.r, App.Theme.accentCyan.g, App.Theme.accentCyan.b, 0.15) : (sMouse.containsMouse ? App.Theme.bgCardHover : App.Theme.bgTertiary)
        border.width: isSelected ? 1 : 0
        border.color: App.Theme.accentCyan
        
        Row {
            anchors.centerIn: parent
            spacing: 6
            
            Text {
                text: stratIcon
                font.family: App.Theme.fontMono
                font.pixelSize: 14
                font.weight: Font.Bold
                color: isSelected ? App.Theme.accentCyan : App.Theme.textSecondary
            }
            
            Text {
                text: stratText
                font.family: App.Theme.fontPrimary
                font.pixelSize: App.Theme.fontSizeS
                color: isSelected ? App.Theme.accentCyan : App.Theme.textSecondary
            }
        }
        
        MouseArea {
            id: sMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }
    
    component StartButton: Rectangle {
        property bool isReady: true
        property int warnings: 0
        signal clicked()
        
        radius: App.Theme.radiusL
        gradient: Gradient {
            GradientStop { position: 0.0; color: isReady ? App.Theme.accentGreen : App.Theme.bgTertiary }
            GradientStop { position: 1.0; color: isReady ? App.Theme.accentGreenDark : App.Theme.bgCard }
        }
        
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.width: 2
            border.color: "white"
            visible: isReady
            
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                running: isReady
                NumberAnimation { to: 0.05; duration: 1200 }
                NumberAnimation { to: 0.25; duration: 1200 }
            }
        }
        
        Row {
            anchors.centerIn: parent
            spacing: 12
            
            Text {
                text: isReady ? "🚀" : "⚠"
                font.pixelSize: 22
            }
            
            Column {
                spacing: 0
                anchors.verticalCenter: parent.verticalCenter
                
                Text {
                    text: isReady ? "INICIAR MISIÓN" : "VERIFICAR SISTEMAS"
                    font.family: App.Theme.fontDisplay
                    font.pixelSize: App.Theme.fontSizeL
                    font.weight: Font.Bold
                    color: "white"
                }
                
                Text {
                    visible: !isReady && warnings > 0
                    text: warnings + " sistema" + (warnings > 1 ? "s requieren" : " requiere") + " atención"
                    font.family: App.Theme.fontPrimary
                    font.pixelSize: App.Theme.fontSizeXS
                    color: Qt.rgba(1, 1, 1, 0.7)
                }
            }
        }
        
        MouseArea {
            anchors.fill: parent
            cursorShape: isReady ? Qt.PointingHandCursor : Qt.ForbiddenCursor
            enabled: isReady
            onClicked: parent.clicked()
        }
    }

    component ConfigSlider: ColumnLayout {
        property string label: ""
        property real sliderValue: 0
        property real minVal: 0
        property real maxVal: 100
        property string unit: ""
        property int decimals: 1
        property color accentColor: App.Theme.accentBlue
        signal valueUpdated(real v)
        
        spacing: 4
        
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: label
                font.family: App.Theme.fontPrimary
                font.pixelSize: App.Theme.fontSizeS
                color: App.Theme.textSecondary
            }
            
            Item { Layout.fillWidth: true }
            
            Text {
                text: sliderValue.toFixed(decimals) + " " + unit
                font.family: App.Theme.fontMono
                font.pixelSize: App.Theme.fontSizeS
                font.weight: Font.Bold
                color: accentColor
            }
        }
        
        Slider {
            Layout.fillWidth: true
            from: minVal
            to: maxVal
            value: sliderValue
            onMoved: valueUpdated(value)
            
            background: Rectangle {
                x: parent.leftPadding
                y: parent.topPadding + parent.availableHeight / 2 - height / 2
                width: parent.availableWidth
                height: 4
                radius: 2
                color: App.Theme.bgTertiary
                
                Rectangle {
                    width: parent.parent.visualPosition * parent.width
                    height: parent.height
                    radius: parent.radius
                    color: accentColor
                }
            }
            
            handle: Rectangle {
                x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                y: parent.topPadding + parent.availableHeight / 2 - height / 2
                width: 14
                height: 14
                radius: 7
                color: accentColor
                border.width: 2
                border.color: "white"
            }
        }
    }
    
    component SensBtn: Rectangle {
        property string btnText: ""
        property bool isSelected: false
        signal clicked()
        
        height: 28
        radius: App.Theme.radiusS
        color: isSelected ? App.Theme.accentBlueDark : (sbMouse.containsMouse ? App.Theme.bgCardHover : App.Theme.bgTertiary)
        border.width: isSelected ? 0 : 1
        border.color: App.Theme.borderMuted
        
        Text {
            anchors.centerIn: parent
            text: btnText
            font.family: App.Theme.fontPrimary
            font.pixelSize: App.Theme.fontSizeS
            font.weight: isSelected ? Font.Medium : Font.Normal
            color: isSelected ? App.Theme.textPrimary : App.Theme.textSecondary
        }
        
        MouseArea {
            id: sbMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }
    
    component GasThreshold: Rectangle {
        property string label: ""
        property real threshValue: 0
        property string unit: ""
        property color threshColor: App.Theme.accentYellow
        
        height: 52
        radius: App.Theme.radiusS
        color: App.Theme.bgTertiary
        border.width: 1
        border.color: Qt.rgba(threshColor.r, threshColor.g, threshColor.b, 0.3)
        
        Column {
            anchors.centerIn: parent
            spacing: 2
            
            Text {
                text: label
                font.family: App.Theme.fontPrimary
                font.pixelSize: App.Theme.fontSizeXS
                color: App.Theme.textMuted
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 3
                
                Text {
                    text: threshValue.toFixed(1)
                    font.family: App.Theme.fontMono
                    font.pixelSize: App.Theme.fontSizeL
                    font.weight: Font.Bold
                    color: threshColor
                }
                
                Text {
                    text: unit
                    font.family: App.Theme.fontMono
                    font.pixelSize: 9
                    color: App.Theme.textMuted
                    anchors.bottom: parent.children[0].bottom
                    anchors.bottomMargin: 2
                }
            }
        }
    }
    
    component RiskBehavior: Rectangle {
        property string currentBehavior: "return_base"
        signal behaviorChanged(string b)
        
        height: 30
        radius: App.Theme.radiusS
        color: App.Theme.bgTertiary
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 3
            spacing: 3
            
            Repeater {
                model: [
                    { id: "return_base", icon: "🏠", tip: "Volver" },
                    { id: "hover", icon: "⏸", tip: "Hover" },
                    { id: "mark_continue", icon: "📍", tip: "Marcar" },
                    { id: "alert_only", icon: "🔔", tip: "Alertar" }
                ]
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: App.Theme.radiusS - 2
                    color: currentBehavior === modelData.id ? App.Theme.accentBlueDark : (rbMouse.containsMouse ? App.Theme.bgCardHover : "transparent")
                    
                    Row {
                        anchors.centerIn: parent
                        spacing: 4
                        
                        Text {
                            text: modelData.icon
                            font.pixelSize: 11
                        }
                        
                        Text {
                            text: modelData.tip
                            font.family: App.Theme.fontPrimary
                            font.pixelSize: 9
                            color: currentBehavior === modelData.id ? App.Theme.textPrimary : App.Theme.textMuted
                        }
                    }
                    
                    MouseArea {
                        id: rbMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: behaviorChanged(modelData.id)
                    }
                }
            }
        }
    }

    component TunnelMap: Rectangle {
        property var waypoints: []
        property var restrictedZones: []
        property var sectorInfo: ({})
        
        color: App.Theme.bgCard
        radius: App.Theme.radiusL
        border.width: 1
        border.color: App.Theme.borderMuted
        clip: true
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 0
            
            // Header
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 42
                color: App.Theme.bgTertiary
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 10
                    
                    Text {
                        text: "🗺"
                        font.pixelSize: 15
                    }
                    
                    Text {
                        text: "Vista del Túnel"
                        font.family: App.Theme.fontDisplay
                        font.pixelSize: App.Theme.fontSizeM
                        font.weight: Font.DemiBold
                        color: App.Theme.textPrimary
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Text {
                        text: (sectorInfo.length || 0) + "m de longitud"
                        font.family: App.Theme.fontMono
                        font.pixelSize: App.Theme.fontSizeS
                        color: App.Theme.textMuted
                    }
                    
                    Rectangle {
                        width: 1
                        height: 18
                        color: App.Theme.borderDefault
                    }
                    
                    Row {
                        spacing: 5
                        
                        Text {
                            text: "🌡"
                            font.pixelSize: 11
                        }
                        
                        Text {
                            text: (sectorInfo.temperature || 0) + "°C"
                            font.family: App.Theme.fontMono
                            font.pixelSize: App.Theme.fontSizeS
                            color: App.Theme.textSecondary
                        }
                    }
                    
                    Row {
                        spacing: 5
                        
                        Text {
                            text: "💧"
                            font.pixelSize: 11
                        }
                        
                        Text {
                            text: (sectorInfo.humidity || 0) + "%"
                            font.family: App.Theme.fontMono
                            font.pixelSize: App.Theme.fontSizeS
                            color: App.Theme.textSecondary
                        }
                    }
                }
                
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: App.Theme.borderMuted
                }
            }
            
            // Map content
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                // Grid
                Canvas {
                    anchors.fill: parent
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        ctx.strokeStyle = Qt.rgba(0.2, 0.22, 0.26, 0.4)
                        ctx.lineWidth = 1
                        var g = 30
                        for (var x = 0; x < width; x += g) {
                            ctx.beginPath()
                            ctx.moveTo(x, 0)
                            ctx.lineTo(x, height)
                            ctx.stroke()
                        }
                        for (var y = 0; y < height; y += g) {
                            ctx.beginPath()
                            ctx.moveTo(0, y)
                            ctx.lineTo(width, y)
                            ctx.stroke()
                        }
                    }
                }
                
                // Tunnel
                Rectangle {
                    id: tunnel
                    anchors.centerIn: parent
                    width: parent.width * 0.9
                    height: 90
                    radius: 22
                    color: App.Theme.bgSecondary
                    border.width: 2
                    border.color: App.Theme.borderDefault
                    
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 4
                        radius: parent.radius - 4
                        gradient: Gradient {
                            orientation: Gradient.Vertical
                            GradientStop { position: 0.0; color: "#1c2128" }
                            GradientStop { position: 0.5; color: "#0d1117" }
                            GradientStop { position: 1.0; color: "#1c2128" }
                        }
                    }
                    
                    // Restricted zones
                    Repeater {
                        model: restrictedZones
                        
                        Rectangle {
                            x: (modelData.x / 100) * parent.width - width / 2
                            y: (modelData.y / 100) * parent.height - height / 2
                            width: (modelData.width / 100) * parent.width
                            height: (modelData.height / 100) * parent.height
                            radius: 4
                            color: Qt.rgba(0.973, 0.318, 0.286, 0.2)
                            border.width: 2
                            border.color: App.Theme.accentRed
                            
                            Text {
                                anchors.centerIn: parent
                                text: "⚠"
                                font.pixelSize: 14
                                color: App.Theme.accentRed
                            }
                        }
                    }
                    
                    // Trajectory line
                    Canvas {
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            if (waypoints.length < 2) return
                            ctx.strokeStyle = "#58a6ff"
                            ctx.lineWidth = 3
                            ctx.setLineDash([8, 4])
                            ctx.lineCap = "round"
                            ctx.beginPath()
                            var f = waypoints[0]
                            ctx.moveTo((f.x / 100) * width, (f.y / 100) * height)
                            for (var i = 1; i < waypoints.length; i++) {
                                var w = waypoints[i]
                                ctx.lineTo((w.x / 100) * width, (w.y / 100) * height)
                            }
                            ctx.stroke()
                        }
                        Component.onCompleted: requestPaint()
                    }
                    
                    // Waypoints
                    Repeater {
                        model: waypoints
                        
                        Rectangle {
                            x: (modelData.x / 100) * parent.width - width / 2
                            y: (modelData.y / 100) * parent.height - height / 2
                            width: modelData.type === "start" || modelData.type === "end" ? 26 : 20
                            height: width
                            radius: width / 2
                            color: modelData.type === "start" ? App.Theme.accentGreen :
                                   modelData.type === "end" ? App.Theme.accentBlue :
                                   modelData.type === "inspection" ? App.Theme.accentPurple :
                                   modelData.type === "gas_check" ? App.Theme.accentOrange :
                                   App.Theme.accentYellow
                            border.width: 2
                            border.color: "white"
                            
                            Text {
                                anchors.centerIn: parent
                                text: modelData.type === "start" ? "▶" :
                                      modelData.type === "end" ? "■" :
                                      modelData.type === "inspection" ? "🔍" :
                                      modelData.type === "gas_check" ? "💨" :
                                      modelData.id
                                font.pixelSize: 9
                                font.weight: Font.Bold
                                color: "white"
                            }
                            
                            Rectangle {
                                anchors.top: parent.bottom
                                anchors.topMargin: 3
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: wpLabel.width + 6
                                height: 14
                                radius: 3
                                color: Qt.rgba(0, 0, 0, 0.7)
                                visible: modelData.label !== undefined
                                
                                Text {
                                    id: wpLabel
                                    anchors.centerIn: parent
                                    text: modelData.label || ""
                                    font.family: App.Theme.fontMono
                                    font.pixelSize: 8
                                    color: App.Theme.textSecondary
                                }
                            }
                        }
                    }
                    
                    // Drone
                    Rectangle {
                        x: parent.width * 0.07
                        y: parent.height * 0.5 - height / 2
                        width: 30
                        height: 30
                        radius: 15
                        color: App.Theme.accentGreen
                        border.width: 3
                        border.color: "white"
                        
                        Text {
                            anchors.centerIn: parent
                            text: "🚁"
                            font.pixelSize: 14
                        }
                        
                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width + 14
                            height: parent.height + 14
                            radius: width / 2
                            color: "transparent"
                            border.width: 2
                            border.color: App.Theme.accentGreen
                            z: -1
                            
                            SequentialAnimation on scale {
                                loops: Animation.Infinite
                                NumberAnimation { to: 1.3; duration: 1000 }
                                NumberAnimation { to: 1.0; duration: 1000 }
                            }
                            
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { to: 0.1; duration: 1000 }
                                NumberAnimation { to: 0.4; duration: 1000 }
                            }
                        }
                    }
                }
                
                // Legend
                Rectangle {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.margins: 10
                    width: legCol.width + 14
                    height: legCol.height + 10
                    radius: App.Theme.radiusS
                    color: Qt.rgba(0, 0, 0, 0.75)
                    
                    Column {
                        id: legCol
                        anchors.centerIn: parent
                        spacing: 3
                        
                        LegItem { legColor: App.Theme.accentGreen; legText: "Inicio" }
                        LegItem { legColor: App.Theme.accentYellow; legText: "Waypoint" }
                        LegItem { legColor: App.Theme.accentPurple; legText: "Inspección" }
                        LegItem { legColor: App.Theme.accentOrange; legText: "Zona Gas" }
                        LegItem { legColor: App.Theme.accentBlue; legText: "Fin" }
                        LegItem { legColor: App.Theme.accentRed; legText: "Restringido"; isRect: true }
                    }
                }
                
                // Scale
                Rectangle {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 10
                    width: 80
                    height: 26
                    radius: App.Theme.radiusS
                    color: Qt.rgba(0, 0, 0, 0.75)
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 2
                        
                        Rectangle {
                            width: 45
                            height: 2
                            color: App.Theme.textSecondary
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Text {
                            text: "50 metros"
                            font.family: App.Theme.fontMono
                            font.pixelSize: 8
                            color: App.Theme.textSecondary
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
                
                // Map controls
                Column {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 10
                    spacing: 5
                    
                    MapBtn { mapIcon: "+" }
                    MapBtn { mapIcon: "−" }
                    MapBtn { mapIcon: "⌖" }
                }
            }
        }
    }
    
    component LegItem: Row {
        property color legColor: "white"
        property string legText: ""
        property bool isRect: false
        
        spacing: 5
        
        Rectangle {
            width: 8
            height: 8
            radius: isRect ? 2 : 4
            color: legColor
            anchors.verticalCenter: parent.verticalCenter
        }
        
        Text {
            text: legText
            font.family: App.Theme.fontPrimary
            font.pixelSize: 8
            color: App.Theme.textSecondary
        }
    }
    
    component MapBtn: Rectangle {
        property string mapIcon: ""
        
        width: 26
        height: 26
        radius: App.Theme.radiusS
        color: mbMouse.containsMouse ? App.Theme.bgCardHover : App.Theme.bgTertiary
        border.width: 1
        border.color: App.Theme.borderDefault
        
        Text {
            anchors.centerIn: parent
            text: mapIcon
            font.family: App.Theme.fontMono
            font.pixelSize: 13
            font.weight: Font.Bold
            color: App.Theme.textSecondary
        }
        
        MouseArea {
            id: mbMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
        }
    }

    component RoutePanel: Rectangle {
        property var segments: []
        
        color: App.Theme.bgCard
        radius: App.Theme.radiusL
        border.width: 1
        border.color: App.Theme.borderMuted
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 6
            
            RowLayout {
                Layout.fillWidth: true
                
                Text {
                    text: "📋"
                    font.pixelSize: 13
                }
                
                Text {
                    text: "Segmentos de Ruta"
                    font.family: App.Theme.fontDisplay
                    font.pixelSize: App.Theme.fontSizeM
                    font.weight: Font.DemiBold
                    color: App.Theme.textPrimary
                }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: segments.length + " tramos"
                    font.family: App.Theme.fontMono
                    font.pixelSize: App.Theme.fontSizeS
                    color: App.Theme.textMuted
                }
            }
            
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                ScrollBar.horizontal.policy: ScrollBar.AsNeeded
                ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                
                Row {
                    spacing: 8
                    
                    Repeater {
                        model: segments
                        
                        Rectangle {
                            width: 130
                            height: 70
                            radius: App.Theme.radiusS
                            color: App.Theme.bgTertiary
                            border.width: 1
                            border.color: App.Theme.getRiskColor(modelData.risk)
                            
                            Column {
                                anchors.fill: parent
                                anchors.margins: 7
                                spacing: 3
                                
                                Row {
                                    width: parent.width
                                    spacing: 3
                                    
                                    Text {
                                        text: modelData.from
                                        font.family: App.Theme.fontMono
                                        font.pixelSize: 9
                                        color: App.Theme.textSecondary
                                        elide: Text.ElideRight
                                        width: (parent.width - 15) / 2
                                    }
                                    
                                    Text {
                                        text: "→"
                                        font.pixelSize: 9
                                        color: App.Theme.textMuted
                                    }
                                    
                                    Text {
                                        text: modelData.to
                                        font.family: App.Theme.fontMono
                                        font.pixelSize: 9
                                        color: App.Theme.textSecondary
                                        elide: Text.ElideRight
                                        width: (parent.width - 15) / 2
                                    }
                                }
                                
                                Row {
                                    spacing: 10
                                    
                                    Row {
                                        spacing: 3
                                        
                                        Text {
                                            text: "📏"
                                            font.pixelSize: 9
                                        }
                                        
                                        Text {
                                            text: modelData.distance + "m"
                                            font.family: App.Theme.fontMono
                                            font.pixelSize: 10
                                            font.weight: Font.Bold
                                            color: App.Theme.textPrimary
                                        }
                                    }
                                    
                                    Row {
                                        spacing: 3
                                        
                                        Text {
                                            text: "⏱"
                                            font.pixelSize: 9
                                        }
                                        
                                        Text {
                                            text: modelData.time
                                            font.family: App.Theme.fontMono
                                            font.pixelSize: 10
                                            color: App.Theme.textSecondary
                                        }
                                    }
                                }
                                
                                Rectangle {
                                    width: riskLbl.width + 8
                                    height: 14
                                    radius: 7
                                    color: Qt.rgba(App.Theme.getRiskColor(modelData.risk).r, App.Theme.getRiskColor(modelData.risk).g, App.Theme.getRiskColor(modelData.risk).b, 0.2)
                                    
                                    Text {
                                        id: riskLbl
                                        anchors.centerIn: parent
                                        text: App.Theme.getRiskText(modelData.risk)
                                        font.family: App.Theme.fontMono
                                        font.pixelSize: 8
                                        font.weight: Font.Bold
                                        color: App.Theme.getRiskColor(modelData.risk)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    component SimPanel: Rectangle {
        property var simulation: ({})
        signal refreshClicked()
        
        color: App.Theme.bgCard
        radius: App.Theme.radiusL
        border.width: 1
        border.color: App.Theme.borderMuted
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Rectangle {
                    width: 26
                    height: 26
                    radius: 6
                    color: Qt.rgba(App.Theme.accentPurple.r, App.Theme.accentPurple.g, App.Theme.accentPurple.b, 0.15)
                    
                    Text {
                        anchors.centerIn: parent
                        text: "📊"
                        font.pixelSize: 13
                    }
                }
                
                Text {
                    text: "Simulación Pre-Misión"
                    font.family: App.Theme.fontDisplay
                    font.pixelSize: App.Theme.fontSizeM
                    font.weight: Font.DemiBold
                    color: App.Theme.textPrimary
                }
                
                Item { Layout.fillWidth: true }
                
                Rectangle {
                    width: refRow.width + 10
                    height: 24
                    radius: 12
                    color: refMouse.containsMouse ? App.Theme.bgCardHover : App.Theme.bgTertiary
                    border.width: 1
                    border.color: App.Theme.borderDefault
                    
                    Row {
                        id: refRow
                        anchors.centerIn: parent
                        spacing: 4
                        
                        Text {
                            text: "🔄"
                            font.pixelSize: 10
                        }
                        
                        Text {
                            text: "Actualizar"
                            font.family: App.Theme.fontPrimary
                            font.pixelSize: 9
                            color: App.Theme.textSecondary
                        }
                    }
                    
                    MouseArea {
                        id: refMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: refreshClicked()
                    }
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: App.Theme.borderMuted
            }
            
            GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 2
                rowSpacing: 10
                columnSpacing: 10
                
                SimMetric {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    metricIcon: "⏱"
                    metricLabel: "Duración"
                    metricValue: simulation.duration || "0:00"
                    metricUnit: ""
                    accentColor: App.Theme.accentBlue
                }
                
                SimMetric {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    metricIcon: "📏"
                    metricLabel: "Cobertura"
                    metricValue: (simulation.coverage || 0).toString()
                    metricUnit: "m"
                    accentColor: App.Theme.accentGreen
                }
                
                SimMetric {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    metricIcon: "🔋"
                    metricLabel: "Batería Final"
                    metricValue: (simulation.batteryEnd || 0).toString()
                    metricUnit: "%"
                    accentColor: (simulation.batteryEnd || 0) > 50 ? App.Theme.accentGreen : (simulation.batteryEnd || 0) > 30 ? App.Theme.accentYellow : App.Theme.accentRed
                }
                
                SimMetric {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    metricIcon: "⚠"
                    metricLabel: "Nivel Riesgo"
                    metricValue: App.Theme.getRiskText(simulation.riskLevel || "low")
                    metricUnit: ""
                    accentColor: App.Theme.getRiskColor(simulation.riskLevel || "low")
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 50
                radius: App.Theme.radiusS
                color: App.Theme.bgTertiary
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: "Progreso de batería"
                            font.family: App.Theme.fontPrimary
                            font.pixelSize: App.Theme.fontSizeXS
                            color: App.Theme.textMuted
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Text {
                            text: (simulation.batteryStart || 0) + "% → " + (simulation.batteryEnd || 0) + "%"
                            font.family: App.Theme.fontMono
                            font.pixelSize: App.Theme.fontSizeXS
                            color: App.Theme.textSecondary
                        }
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        height: 8
                        radius: 4
                        color: App.Theme.bgSecondary
                        
                        Rectangle {
                            width: parent.width * ((simulation.batteryEnd || 0) / 100)
                            height: parent.height
                            radius: parent.radius
                            color: (simulation.batteryEnd || 0) > 50 ? App.Theme.accentGreen : (simulation.batteryEnd || 0) > 30 ? App.Theme.accentYellow : App.Theme.accentRed
                        }
                        
                        Rectangle {
                            x: parent.width * ((simulation.batteryEnd || 0) / 100) - 1
                            width: 2
                            height: parent.height
                            color: "white"
                        }
                    }
                }
            }
        }
    }
    
    component SimMetric: Rectangle {
        property string metricIcon: ""
        property string metricLabel: ""
        property string metricValue: ""
        property string metricUnit: ""
        property color accentColor: App.Theme.accentBlue
        
        radius: App.Theme.radiusM
        color: App.Theme.bgTertiary
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 4
            
            Text {
                text: metricIcon
                font.pixelSize: 18
            }
            
            Item { Layout.fillHeight: true }
            
            Row {
                spacing: 3
                
                Text {
                    text: metricValue
                    font.family: App.Theme.fontMono
                    font.pixelSize: App.Theme.fontSizeXL
                    font.weight: Font.Bold
                    color: accentColor
                }
                
                Text {
                    text: metricUnit
                    font.family: App.Theme.fontMono
                    font.pixelSize: App.Theme.fontSizeXS
                    color: App.Theme.textMuted
                    anchors.bottom: parent.children[0].bottom
                    anchors.bottomMargin: 3
                    visible: metricUnit !== ""
                }
            }
            
            Text {
                text: metricLabel
                font.family: App.Theme.fontPrimary
                font.pixelSize: App.Theme.fontSizeXS
                color: App.Theme.textMuted
            }
        }
    }
}
