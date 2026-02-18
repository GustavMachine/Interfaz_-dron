import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import "." as App

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1600
    height: 900
    minimumWidth: 1400
    minimumHeight: 800
    title: "Sistema de Inspección Autónoma - Teleoperación"
    color: App.Theme.bgPrimary

    property bool isTeleoperated: true

    // ===== COMPONENTES =====

    component Card: Rectangle {
        color: App.Theme.bgCard
        radius: App.Theme.radiusL
        border.width: 1
        border.color: App.Theme.borderMuted
    }

    component StyledButton: Rectangle {
        id: btnRoot
        property string text: ""
        property string icon: ""
        property bool primary: false
        property bool danger: false
        property bool small: false
        property bool enabled: true
        signal clicked()
        
        width: btnContent.width + (small ? 16 : 24)
        height: small ? 28 : 36
        radius: App.Theme.radiusM
        opacity: enabled ? 1.0 : 0.5
        color: {
            if (!enabled) return App.Theme.bgTertiary
            if (danger) return btnMouse.containsMouse ? "#d62828" : App.Theme.accentRed
            if (primary) return btnMouse.containsMouse ? App.Theme.accentBlueDim : App.Theme.accentBlue
            return btnMouse.containsMouse ? App.Theme.bgCardHover : App.Theme.bgCard
        }
        border.width: (primary || danger) ? 0 : 1
        border.color: App.Theme.borderDefault
        
        Row {
            id: btnContent
            anchors.centerIn: parent
            spacing: 6
            Text {
                text: btnRoot.icon
                font.pixelSize: btnRoot.small ? 12 : 14
                visible: btnRoot.icon !== ""
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: btnRoot.text
                color: (btnRoot.primary || btnRoot.danger) ? "#ffffff" : App.Theme.textPrimary
                font.family: App.Theme.fontPrimary
                font.pixelSize: btnRoot.small ? App.Theme.fontSizeS : App.Theme.fontSizeM
                font.weight: Font.Medium
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        MouseArea {
            id: btnMouse
            anchors.fill: parent
            hoverEnabled: btnRoot.enabled
            cursorShape: btnRoot.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: if (btnRoot.enabled) btnRoot.clicked()
        }
    }

    component EmergencyButton: Rectangle {
        id: emergBtn
        property string text: ""
        property string icon: ""
        property color btnColor: App.Theme.accentRed
        signal clicked()
        
        width: 100
        height: 70
        radius: App.Theme.radiusL
        color: emergMouse.pressed ? Qt.darker(btnColor, 1.3) : (emergMouse.containsMouse ? Qt.lighter(btnColor, 1.1) : btnColor)
        border.width: 2
        border.color: Qt.lighter(btnColor, 1.3)
        
        Column {
            anchors.centerIn: parent
            spacing: 4
            Text {
                text: emergBtn.icon
                font.pixelSize: 24
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: emergBtn.text
                color: "#ffffff"
                font.pixelSize: App.Theme.fontSizeS
                font.weight: Font.Bold
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        MouseArea {
            id: emergMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: emergBtn.clicked()
        }
    }

    component ToggleSwitch: Rectangle {
        id: toggleRoot
        property bool checked: false
        property string label: ""
        signal toggled(bool value)
        
        width: toggleRow.width
        height: 24
        color: "transparent"
        
        Row {
            id: toggleRow
            spacing: 8
            anchors.verticalCenter: parent.verticalCenter
            
            Rectangle {
                width: 36
                height: 18
                radius: 9
                color: toggleRoot.checked ? App.Theme.accentGreen : App.Theme.bgTertiary
                border.width: 1
                border.color: toggleRoot.checked ? App.Theme.accentGreen : App.Theme.borderDefault
                anchors.verticalCenter: parent.verticalCenter
                
                Rectangle {
                    width: 14
                    height: 14
                    radius: 7
                    x: toggleRoot.checked ? parent.width - width - 2 : 2
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#ffffff"
                    Behavior on x { NumberAnimation { duration: 150 } }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        toggleRoot.checked = !toggleRoot.checked
                        toggleRoot.toggled(toggleRoot.checked)
                    }
                }
            }
            Text {
                text: toggleRoot.label
                color: App.Theme.textSecondary
                font.pixelSize: App.Theme.fontSizeXs
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    component MetricBox: Rectangle {
        property string label: ""
        property string value: ""
        property string unit: ""
        property color valueColor: App.Theme.textPrimary
        
        color: App.Theme.bgTertiary
        radius: App.Theme.radiusM
        width: 115
        height: 50
        
        Column {
            anchors.centerIn: parent
            spacing: 2
            Text {
                text: label
                color: App.Theme.textTertiary
                font.pixelSize: 10
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 2
                Text {
                    text: value
                    color: valueColor
                    font.family: App.Theme.fontMono
                    font.pixelSize: App.Theme.fontSizeM
                    font.weight: Font.Bold
                }
                Text {
                    text: unit
                    color: App.Theme.textTertiary
                    font.pixelSize: 10
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 1
                }
            }
        }
    }

    component VirtualJoystick: Item {
        id: joystickBase
        property real outputX: 0
        property real outputY: 0
        property string label: ""
        property color accentColor: App.Theme.accentBlue
        signal moved(real x, real y)
        
        width: 120
        height: 140

        Text {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            text: joystickBase.label
            color: App.Theme.textSecondary
            font.pixelSize: 10
            font.weight: Font.Bold
        }

        Rectangle {
            id: joystickCircle
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 10
            width: 100
            height: 100
            radius: 50
            color: Qt.rgba(0, 0, 0, 0.5)
            border.width: 2
            border.color: joystickBase.accentColor

            Rectangle {
                anchors.centerIn: parent
                width: 60
                height: 1
                color: Qt.rgba(joystickBase.accentColor.r, joystickBase.accentColor.g, joystickBase.accentColor.b, 0.3)
            }
            Rectangle {
                anchors.centerIn: parent
                width: 1
                height: 60
                color: Qt.rgba(joystickBase.accentColor.r, joystickBase.accentColor.g, joystickBase.accentColor.b, 0.3)
            }

            Rectangle {
                id: knob
                width: 40
                height: 40
                radius: 20
                color: joystickBase.accentColor
                x: parent.width / 2 - 20
                y: parent.height / 2 - 20

                Rectangle {
                    anchors.centerIn: parent
                    width: 16
                    height: 16
                    radius: 8
                    color: Qt.lighter(joystickBase.accentColor, 1.4)
                }
            }

            MouseArea {
                anchors.fill: parent
                
                onPressed: function(mouse) { updateKnob(mouse.x, mouse.y) }
                onPositionChanged: function(mouse) { if (pressed) updateKnob(mouse.x, mouse.y) }
                onReleased: {
                    knob.x = joystickCircle.width / 2 - 20
                    knob.y = joystickCircle.height / 2 - 20
                    joystickBase.outputX = 0
                    joystickBase.outputY = 0
                    joystickBase.moved(0, 0)
                }
                
                function updateKnob(mx, my) {
                    var centerX = joystickCircle.width / 2
                    var centerY = joystickCircle.height / 2
                    var maxDist = 30
                    var dx = mx - centerX
                    var dy = my - centerY
                    var dist = Math.sqrt(dx * dx + dy * dy)
                    if (dist > maxDist) { dx = dx / dist * maxDist; dy = dy / dist * maxDist }
                    knob.x = centerX + dx - 20
                    knob.y = centerY + dy - 20
                    joystickBase.outputX = dx / maxDist
                    joystickBase.outputY = -dy / maxDist
                    joystickBase.moved(joystickBase.outputX, joystickBase.outputY)
                }
            }
        }

        Text {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            text: joystickBase.outputX.toFixed(1) + " , " + joystickBase.outputY.toFixed(1)
            color: joystickBase.accentColor
            font.family: App.Theme.fontMono
            font.pixelSize: 9
        }
    }

    // ===== LAYOUT PRINCIPAL =====
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // HEADER
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            color: App.Theme.bgSecondary
            z: 10

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: App.Theme.borderMuted
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: App.Theme.spacingL
                anchors.rightMargin: App.Theme.spacingL
                spacing: App.Theme.spacingL

                Row {
                    spacing: App.Theme.spacingM
                    Layout.alignment: Qt.AlignVCenter

                    Rectangle {
                        width: 36
                        height: 36
                        radius: App.Theme.radiusM
                        color: App.Theme.accentBlueDim
                        Text { anchors.centerIn: parent; text: "🚁"; font.pixelSize: 18 }
                    }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            text: "INSPECCIÓN AUTÓNOMA"
                            color: App.Theme.textPrimary
                            font.pixelSize: App.Theme.fontSizeL
                            font.weight: Font.Bold
                        }
                        Text {
                            text: "Sistema de Teleoperación"
                            color: App.Theme.textTertiary
                            font.pixelSize: App.Theme.fontSizeXs
                        }
                    }
                }

                Row {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 4
                    Repeater {
                        model: [{ name: "Configuración", active: false }, { name: "Teleoperación", active: true }, { name: "Análisis", active: false }]
                        Rectangle {
                            width: navText.width + 24
                            height: 32
                            radius: App.Theme.radiusM
                            color: modelData.active ? App.Theme.accentBlueDim : "transparent"
                            Text {
                                id: navText
                                anchors.centerIn: parent
                                text: modelData.name
                                color: modelData.active ? App.Theme.accentBlue : App.Theme.textSecondary
                                font.pixelSize: App.Theme.fontSizeS
                                font.weight: modelData.active ? Font.Bold : Font.Normal
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                Row {
                    spacing: App.Theme.spacingM
                    Layout.alignment: Qt.AlignVCenter

                    Rectangle {
                        width: statusRow.width + 16
                        height: 28
                        radius: App.Theme.radiusM
                        color: teleop.isConnected ? App.Theme.statusSuccessBg : App.Theme.statusCriticalBg
                        border.width: 1
                        border.color: teleop.isConnected ? App.Theme.statusSuccess : App.Theme.statusCritical
                        Row {
                            id: statusRow
                            anchors.centerIn: parent
                            spacing: 6
                            Rectangle { width: 8; height: 8; radius: 4; color: teleop.isConnected ? App.Theme.statusSuccess : App.Theme.statusCritical; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: teleop.isConnected ? "CONECTADO" : "DESCONECTADO"; color: teleop.isConnected ? App.Theme.statusSuccess : App.Theme.statusCritical; font.pixelSize: App.Theme.fontSizeXs; font.weight: Font.Bold; anchors.verticalCenter: parent.verticalCenter }
                        }
                    }

                    Rectangle {
                        width: modeText.width + 16
                        height: 28
                        radius: App.Theme.radiusM
                        color: isTeleoperated ? App.Theme.accentBlueDim : App.Theme.statusSuccessBg
                        Text {
                            id: modeText
                            anchors.centerIn: parent
                            text: isTeleoperated ? "TELEOPERADO" : "AUTÓNOMO"
                            color: isTeleoperated ? App.Theme.accentBlue : App.Theme.statusSuccess
                            font.pixelSize: App.Theme.fontSizeXs
                            font.weight: Font.Bold
                        }
                    }
                }

                Rectangle { width: 1; height: 32; color: App.Theme.borderDefault; Layout.alignment: Qt.AlignVCenter }

                Column {
                    Layout.alignment: Qt.AlignVCenter
                    Text {
                        text: "Misión: " + teleop.formatTime(teleop.missionTime)
                        color: App.Theme.textPrimary
                        font.family: App.Theme.fontMono
                        font.pixelSize: App.Theme.fontSizeM
                    }
                    Text {
                        id: clockText
                        color: App.Theme.textTertiary
                        font.family: App.Theme.fontMono
                        font.pixelSize: App.Theme.fontSizeXs
                        Timer {
                            interval: 1000
                            running: true
                            repeat: true
                            onTriggered: clockText.text = Qt.formatTime(new Date(), "hh:mm:ss")
                            Component.onCompleted: clockText.text = Qt.formatTime(new Date(), "hh:mm:ss")
                        }
                    }
                }
            }
        }

        // CONTENIDO PRINCIPAL
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // PANEL IZQUIERDO
            Rectangle {
                id: leftPanel
                Layout.preferredWidth: 280
                Layout.fillHeight: true
                color: App.Theme.bgSecondary

                Rectangle { anchors.right: parent.right; width: 1; height: parent.height; color: App.Theme.borderMuted }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: App.Theme.spacingM
                    spacing: App.Theme.spacingS

                    // Estado Crítico
                    Card {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 180
                        border.color: App.Theme.statusWarning

                        Column {
                            anchors.fill: parent
                            anchors.margins: App.Theme.spacingM
                            spacing: App.Theme.spacingS

                            Row {
                                spacing: 6
                                Text { text: "⚠"; font.pixelSize: 14 }
                                Text { text: "ESTADO CRÍTICO"; color: App.Theme.statusWarning; font.pixelSize: App.Theme.fontSizeM; font.weight: Font.Bold }
                            }

                            Row {
                                spacing: 6
                                anchors.horizontalCenter: parent.horizontalCenter
                                MetricBox {
                                    label: "BATERÍA"
                                    value: teleop.battery.toFixed(0)
                                    unit: "%"
                                    valueColor: teleop.battery > 30 ? App.Theme.accentGreen : App.Theme.statusCritical
                                }
                                MetricBox {
                                    label: "SEÑAL"
                                    value: teleop.signalStrength.toString()
                                    unit: "%"
                                    valueColor: teleop.signalStrength > 70 ? App.Theme.accentGreen : App.Theme.statusWarning
                                }
                            }

                            Row {
                                spacing: 6
                                anchors.horizontalCenter: parent.horizontalCenter
                                MetricBox {
                                    label: "LATENCIA"
                                    value: teleop.latency.toString()
                                    unit: "ms"
                                    valueColor: teleop.latencyLevel === "low" ? App.Theme.accentGreen : App.Theme.statusWarning
                                }
                                MetricBox {
                                    label: "SLAM"
                                    value: teleop.slamConfidence.toFixed(0)
                                    unit: "%"
                                    valueColor: teleop.slamConfidence > 80 ? App.Theme.accentGreen : App.Theme.statusWarning
                                }
                            }
                        }
                    }

                    // Temperaturas
                    Card {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80

                        Column {
                            anchors.fill: parent
                            anchors.margins: App.Theme.spacingM
                            spacing: App.Theme.spacingXs

                            Row {
                                spacing: 6
                                Text { text: "🌡"; font.pixelSize: 12 }
                                Text { text: "Temperaturas"; color: App.Theme.textPrimary; font.pixelSize: App.Theme.fontSizeS; font.weight: Font.Bold }
                            }

                            Grid {
                                columns: 6
                                spacing: 6
                                anchors.horizontalCenter: parent.horizontalCenter

                                Text { text: "M1:"; color: App.Theme.textTertiary; font.pixelSize: 10 }
                                Text { text: teleop.temperatures.motor1.toFixed(0) + "°"; color: App.Theme.textPrimary; font.family: App.Theme.fontMono; font.pixelSize: 11 }
                                Text { text: "M2:"; color: App.Theme.textTertiary; font.pixelSize: 10 }
                                Text { text: teleop.temperatures.motor2.toFixed(0) + "°"; color: App.Theme.textPrimary; font.family: App.Theme.fontMono; font.pixelSize: 11 }
                                Text { text: "M3:"; color: App.Theme.textTertiary; font.pixelSize: 10 }
                                Text { text: teleop.temperatures.motor3.toFixed(0) + "°"; color: App.Theme.textPrimary; font.family: App.Theme.fontMono; font.pixelSize: 11 }

                                Text { text: "M4:"; color: App.Theme.textTertiary; font.pixelSize: 10 }
                                Text { text: teleop.temperatures.motor4.toFixed(0) + "°"; color: App.Theme.textPrimary; font.family: App.Theme.fontMono; font.pixelSize: 11 }
                                Text { text: "CTRL:"; color: App.Theme.textTertiary; font.pixelSize: 10 }
                                Text { text: teleop.temperatures.controller.toFixed(0) + "°"; color: App.Theme.textPrimary; font.family: App.Theme.fontMono; font.pixelSize: 11 }
                                Text { text: "BAT:"; color: App.Theme.textTertiary; font.pixelSize: 10 }
                                Text { text: teleop.temperatures.battery.toFixed(0) + "°"; color: App.Theme.textPrimary; font.family: App.Theme.fontMono; font.pixelSize: 11 }
                            }
                        }
                    }

                    // Sensores de Gas
                    Card {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 130

                        Column {
                            anchors.fill: parent
                            anchors.margins: App.Theme.spacingM
                            spacing: App.Theme.spacingS

                            Row {
                                spacing: 6
                                Text { text: "💨"; font.pixelSize: 12 }
                                Text { text: "Sensores de Gas"; color: App.Theme.textPrimary; font.pixelSize: App.Theme.fontSizeS; font.weight: Font.Bold }
                            }

                            Grid {
                                columns: 2
                                spacing: 6
                                anchors.horizontalCenter: parent.horizontalCenter

                                MetricBox { label: "CH₄"; value: teleop.gases.ch4.toFixed(2); unit: "%"; valueColor: teleop.gases.ch4 > 1.0 ? App.Theme.statusCritical : App.Theme.dataCH4 }
                                MetricBox { label: "CO"; value: teleop.gases.co.toFixed(1); unit: "ppm"; valueColor: teleop.gases.co > 25 ? App.Theme.statusCritical : App.Theme.dataCO }
                                MetricBox { label: "O₂"; value: teleop.gases.o2.toFixed(1); unit: "%"; valueColor: teleop.gases.o2 < 19.5 ? App.Theme.statusWarning : App.Theme.dataO2 }
                                MetricBox { label: "H₂S"; value: teleop.gases.h2s ? teleop.gases.h2s.toFixed(1) : "0.0"; unit: "ppm"; valueColor: teleop.gases.h2s > 10 ? App.Theme.statusCritical : App.Theme.accentYellow }
                            }
                        }
                    }

                    // Modos Asistidos
                    Card {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 160   // fijo para dejar espacio abajo

                        Column {
                            anchors.fill: parent
                            anchors.margins: App.Theme.spacingM
                            spacing: App.Theme.spacingS

                            Row {
                                spacing: 6
                                Text { text: "🛡"; font.pixelSize: 12 }
                                Text { text: "Modos Asistidos"; color: App.Theme.textPrimary; font.pixelSize: App.Theme.fontSizeS; font.weight: Font.Bold }
                            }

                            ToggleSwitch { label: "Hold de Altura"; checked: teleop.altitudeHold; onToggled: function(v) { teleop.setAltitudeHold(v) } }
                            ToggleSwitch { label: "Limitador Velocidad"; checked: teleop.speedLimiter; onToggled: function(v) { teleop.setSpeedLimiter(v) } }
                            ToggleSwitch { label: "Frenado Automático"; checked: teleop.autoBrake; onToggled: function(v) { teleop.setAutoBrake(v) } }
                            ToggleSwitch { label: "Evitar Colisiones"; checked: teleop.collisionAvoidance; onToggled: function(v) { teleop.setCollisionAvoidance(v) } }
                        }
                    }

                    // Joystick Izquierdo - Throttle / Yaw (DEBE ser hermano, no hijo)
                    Card {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 130
                        visible: isTeleoperated
                        Layout.bottomMargin: 10 // 👈 esto lo “sube” 20px


                        Rectangle {
                            anchors.fill: parent
                            radius: App.Theme.radiusL
                            color: Qt.rgba(0,0,0,0.5)
                            border.width: 1
                            border.color: App.Theme.accentBlue

                            VirtualJoystick {
                                anchors.centerIn: parent
                                anchors.verticalCenterOffset: 6 
                                label: "Throttle / Yaw"
                                accentColor: App.Theme.accentBlue
                                onMoved: function(x, y) {
                                    if (teleop.isFlying) teleop.sendMovement(y, x, 0, 0)
                                }
                            }
                        }
                    }

                }
            }

            // PANEL CENTRAL
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                // Video Feed
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#000000"

                    Rectangle {
                        id: videoFeed
                        anchors.fill: parent
                        anchors.margins: 2
                        clip: true
                        color: "#1a1a2e"
                        radius: App.Theme.radiusM
                        Image {
                            anchors.fill: parent
                            source: Qt.resolvedUrl("imagen_socavon.png")
                            fillMode: Image.PreserveAspectCrop
                            smooth: true
                            opacity: 1.0   // si luego tienes stream real: visible: !teleop.hasVideo
                        }

                        // Overlay oscuro para que el UI siga legible
                        Rectangle {
                            anchors.fill: parent
                            color: "#000000"
                            opacity: 0.40
                            radius: App.Theme.radiusM
                        }
                        // Grid
                        Canvas {
                            anchors.fill: parent
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.reset()
                                var w = width
                                var h = height
                                ctx.strokeStyle = "rgba(88, 166, 255, 0.2)"
                                ctx.lineWidth = 1
                                for (var i = 1; i < 3; i++) { ctx.beginPath(); ctx.moveTo(w * i / 3, 0); ctx.lineTo(w * i / 3, h); ctx.stroke() }
                                for (var j = 1; j < 3; j++) { ctx.beginPath(); ctx.moveTo(0, h * j / 3); ctx.lineTo(w, h * j / 3); ctx.stroke() }
                                ctx.strokeStyle = "rgba(88, 166, 255, 0.5)"
                                ctx.lineWidth = 2
                                var cx = w / 2
                                var cy = h / 2
                                ctx.beginPath(); ctx.moveTo(cx - 30, cy); ctx.lineTo(cx - 10, cy); ctx.stroke()
                                ctx.beginPath(); ctx.moveTo(cx + 10, cy); ctx.lineTo(cx + 30, cy); ctx.stroke()
                                ctx.beginPath(); ctx.moveTo(cx, cy - 30); ctx.lineTo(cx, cy - 10); ctx.stroke()
                                ctx.beginPath(); ctx.moveTo(cx, cy + 10); ctx.lineTo(cx, cy + 30); ctx.stroke()
                                ctx.beginPath(); ctx.arc(cx, cy, 5, 0, Math.PI * 2); ctx.stroke()
                            }
                        }

                        // Texto central
                        Column {
                            anchors.centerIn: parent
                            spacing: 8
                            Text { text: "📹 FEED DE CÁMARA EN VIVO"; color: App.Theme.textTertiary; font.pixelSize: App.Theme.fontSizeL; anchors.horizontalCenter: parent.horizontalCenter }
                            Text { text: "Conectado a cámara del dron"; color: App.Theme.textTertiary; font.pixelSize: App.Theme.fontSizeS; anchors.horizontalCenter: parent.horizontalCenter }
                        }

                        // REC
                        Row {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.margins: App.Theme.spacingM
                            spacing: 8
                            visible: teleop.cameraRecording
                            Rectangle {
                                width: 12; height: 12; radius: 6; color: App.Theme.statusCritical
                                SequentialAnimation on opacity { loops: Animation.Infinite; NumberAnimation { to: 0.3; duration: 500 } NumberAnimation { to: 1.0; duration: 500 } }
                            }
                            Text { text: "REC"; color: App.Theme.statusCritical; font.pixelSize: App.Theme.fontSizeS; font.weight: Font.Bold }
                        }

                        // OSD
                        Rectangle {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: App.Theme.spacingM
                            width: 140
                            height: osdCol.height + 12
                            radius: App.Theme.radiusS
                            color: Qt.rgba(0, 0, 0, 0.7)
                            Column {
                                id: osdCol
                                anchors.centerIn: parent
                                spacing: 2
                                Text { text: "ALT: " + teleop.position.z.toFixed(2) + " m"; color: "#ffffff"; font.family: App.Theme.fontMono; font.pixelSize: 11 }
                                Text { text: "YAW: " + teleop.orientation.yaw.toFixed(1) + "°"; color: "#ffffff"; font.family: App.Theme.fontMono; font.pixelSize: 11 }
                                Text { text: "DIST: " + teleop.distanceTraveled.toFixed(1) + " m"; color: "#ffffff"; font.family: App.Theme.fontMono; font.pixelSize: 11 }
                                Text { text: "BAT: " + teleop.battery.toFixed(0) + "%"; color: teleop.battery > 30 ? "#3fb950" : "#f85149"; font.family: App.Theme.fontMono; font.pixelSize: 11 }
                            }
                        }
                        // Perfil Cámara
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottomMargin: 15
                            width: profileRow.width + 20
                            height: 32
                            radius: App.Theme.radiusM
                            color: Qt.rgba(0, 0, 0, 0.7)

                            Row {
                                id: profileRow
                                anchors.centerIn: parent
                                spacing: 4
                                Text { text: "📷"; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
                                Repeater {
                                    model: [{ id: "low_light", label: "Baja Luz" }, { id: "high_clarity", label: "Nitidez" }, { id: "anti_noise", label: "Anti Ruido" }, { id: "normal", label: "Normal" }]
                                    Rectangle {
                                        width: 65; height: 24; radius: App.Theme.radiusS
                                        color: teleop.cameraProfile === modelData.id ? App.Theme.accentCyan : "transparent"
                                        border.width: 1
                                        border.color: teleop.cameraProfile === modelData.id ? App.Theme.accentCyan : App.Theme.borderDefault
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.label
                                            color: teleop.cameraProfile === modelData.id ? "#000000" : App.Theme.textSecondary
                                            font.pixelSize: 9
                                            font.weight: teleop.cameraProfile === modelData.id ? Font.Bold : Font.Normal
                                        }
                                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: teleop.setCameraProfile(modelData.id) }
                                    }
                                }
                            }
                        }
                    }
                }

                // Barra Inferior
                Rectangle {
                    id: bottomBar
                    Layout.fillWidth: true
                    Layout.preferredHeight: 130
                    color: App.Theme.bgSecondary

                    Rectangle { anchors.top: parent.top; width: parent.width; height: 1; color: App.Theme.borderMuted }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: App.Theme.spacingS
                        spacing: App.Theme.spacingM

                        // Cámara
                        Card {
                            Layout.preferredWidth: 180
                            Layout.fillHeight: true
                            Column {
                                anchors.fill: parent
                                anchors.margins: App.Theme.spacingS
                                spacing: App.Theme.spacingS
                                Text { text: "🎥 Cámara"; color: App.Theme.textPrimary; font.pixelSize: App.Theme.fontSizeS; font.weight: Font.Bold }
                                Row {
                                    spacing: 6
                                    StyledButton { text: teleop.cameraRecording ? "⏹ Stop" : "⏺ Grabar"; danger: teleop.cameraRecording; small: true; onClicked: teleop.toggleRecording() }
                                    StyledButton { text: "📷 Foto"; small: true; onClicked: teleop.capturePhoto() }
                                    StyledButton { text: teleop.exposureLock ? "🔒" : "🔓"; small: true; primary: teleop.exposureLock; onClicked: teleop.setExposureLock(!teleop.exposureLock) }
                                }
                            }
                        }

                        // Marcar Evento
                        Card {
                            Layout.preferredWidth: 200
                            Layout.fillHeight: true
                            border.color: App.Theme.accentCyan
                            Column {
                                anchors.fill: parent
                                anchors.margins: App.Theme.spacingS
                                spacing: App.Theme.spacingS
                                Row {
                                    spacing: 6
                                    Text { text: "🎯"; font.pixelSize: 12 }
                                    Text { text: "Marcar Evento"; color: App.Theme.accentCyan; font.pixelSize: App.Theme.fontSizeS; font.weight: Font.Bold }
                                    Text { text: "(" + teleop.markedEvents.length + ")"; color: App.Theme.textTertiary; font.pixelSize: App.Theme.fontSizeXs }
                                }
                                Row {
                                    spacing: 6
                                    StyledButton { text: "💨 Gas"; small: true; onClicked: teleop.markEvent("gas") }
                                    StyledButton { text: "⚡ Grieta"; small: true; onClicked: teleop.markEvent("crack") }
                                    StyledButton { text: "🚧 Obstác."; small: true; onClicked: teleop.markEvent("obstacle") }
                                }
                            }
                        }

                        // Controles
                        Card {
                            Layout.preferredWidth: 340
                            Layout.fillHeight: true
                            Column {
                                anchors.fill: parent
                                anchors.margins: App.Theme.spacingS
                                spacing: App.Theme.spacingS

                                Text { text: "🎮 Controles"; color: App.Theme.textPrimary; font.pixelSize: App.Theme.fontSizeS; font.weight: Font.Bold }

                                Row {
                                    spacing: App.Theme.spacingS
                                    Rectangle {
                                        width: 120; height: 36; radius: App.Theme.radiusM
                                        color: isTeleoperated ? App.Theme.accentBlueDim : App.Theme.bgTertiary
                                        border.width: isTeleoperated ? 2 : 1
                                        border.color: isTeleoperated ? App.Theme.accentBlue : App.Theme.borderDefault
                                        Row {
                                            anchors.centerIn: parent
                                            spacing: 6
                                            Text { text: "🕹"; font.pixelSize: 14 }
                                            Text { text: "Teleoperado"; color: isTeleoperated ? App.Theme.accentBlue : App.Theme.textSecondary; font.pixelSize: App.Theme.fontSizeS; font.weight: isTeleoperated ? Font.Bold : Font.Normal }
                                        }
                                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: isTeleoperated = true }
                                    }
                                    Rectangle {
                                        width: 120; height: 36; radius: App.Theme.radiusM
                                        color: !isTeleoperated ? App.Theme.statusSuccessBg : App.Theme.bgTertiary
                                        border.width: !isTeleoperated ? 2 : 1
                                        border.color: !isTeleoperated ? App.Theme.accentGreen : App.Theme.borderDefault
                                        Row {
                                            anchors.centerIn: parent
                                            spacing: 6
                                            Text { text: "🤖"; font.pixelSize: 14 }
                                            Text { text: "Autónomo"; color: !isTeleoperated ? App.Theme.accentGreen : App.Theme.textSecondary; font.pixelSize: App.Theme.fontSizeS; font.weight: !isTeleoperated ? Font.Bold : Font.Normal }
                                        }
                                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: isTeleoperated = false }
                                    }
                                }

                                Row {
                                    spacing: 6
                                    visible: isTeleoperated
                                    Text { text: "Sensibilidad:"; color: App.Theme.textTertiary; font.pixelSize: 10; anchors.verticalCenter: parent.verticalCenter }
                                    Repeater {
                                        model: [{ id: "soft", label: "🐢 Suave" }, { id: "normal", label: "🚶 Normal" }, { id: "aggressive", label: "🏃 Rápido" }]
                                        Rectangle {
                                            width: 75; height: 26; radius: App.Theme.radiusS
                                            color: teleop.sensitivity === modelData.id ? App.Theme.accentBlueDim : App.Theme.bgTertiary
                                            border.width: teleop.sensitivity === modelData.id ? 1 : 0
                                            border.color: App.Theme.accentBlue
                                            Text { anchors.centerIn: parent; text: modelData.label; color: teleop.sensitivity === modelData.id ? App.Theme.accentBlue : App.Theme.textSecondary; font.pixelSize: 10 }
                                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: teleop.setSensitivity(modelData.id) }
                                        }
                                    }
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // Estado
                        Card {
                            Layout.preferredWidth: 180
                            Layout.fillHeight: true
                            Column {
                                anchors.fill: parent
                                anchors.margins: App.Theme.spacingS
                                spacing: App.Theme.spacingS
                                Text { text: "✈ Estado"; color: App.Theme.textPrimary; font.pixelSize: App.Theme.fontSizeS; font.weight: Font.Bold }
                                Row {
                                    spacing: 6
                                    StyledButton { text: teleop.isArmed ? "🔴 ARMADO" : "⚪ ARMAR"; primary: teleop.isArmed; small: true; enabled: !teleop.isFlying; onClicked: teleop.isArmed ? teleop.disarm() : teleop.arm() }
                                }
                                Row {
                                    spacing: 6
                                    StyledButton { text: "🛫 Despegar"; small: true; primary: true; enabled: teleop.isArmed && !teleop.isFlying; onClicked: teleop.takeoff() }
                                    StyledButton { text: "🛬 Aterrizar"; small: true; enabled: teleop.isFlying; onClicked: teleop.land() }
                                }
                            }
                        }
                    }
                }
            }

            // PANEL DERECHO
            Rectangle {
                id: rightPanel
                Layout.preferredWidth: 260
                Layout.fillHeight: true
                color: App.Theme.bgSecondary

                Rectangle { anchors.left: parent.left; width: 1; height: parent.height; color: App.Theme.borderMuted }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: App.Theme.spacingM
                    spacing: App.Theme.spacingM

                    // Emergencia
                    Card {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 190
                        border.color: App.Theme.statusCritical
                        border.width: 2

                        Column {
                            anchors.fill: parent
                            anchors.margins: App.Theme.spacingM
                            spacing: App.Theme.spacingS

                            Row {
                                spacing: 6
                                anchors.horizontalCenter: parent.horizontalCenter
                                Text { text: "🚨"; font.pixelSize: 16 }
                                Text { text: "EMERGENCIA"; color: App.Theme.statusCritical; font.pixelSize: App.Theme.fontSizeM; font.weight: Font.Bold }
                            }

                            Row {
                                spacing: App.Theme.spacingS
                                anchors.horizontalCenter: parent.horizontalCenter
                                EmergencyButton { text: "E-STOP"; icon: "⛔"; btnColor: "#d62828"; onClicked: teleop.emergencyStop() }
                                EmergencyButton { text: "HOVER"; icon: "⏸"; btnColor: "#f77f00"; onClicked: teleop.hover() }
                            }

                            Row {
                                spacing: App.Theme.spacingS
                                anchors.horizontalCenter: parent.horizontalCenter
                                EmergencyButton { text: "VOLVER"; icon: "🏠"; btnColor: "#fcbf49"; onClicked: teleop.returnToHome() }
                                EmergencyButton { text: "SEGURO"; icon: "🛡"; btnColor: "#2a9d8f"; onClicked: teleop.safeMode() }
                            }
                        }
                    }

                    // Alertas
                    Card {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 200  

                        Column {
                            anchors.fill: parent
                            anchors.margins: App.Theme.spacingM
                            spacing: App.Theme.spacingS

                            Row {
                                spacing: 6
                                Text { text: "⚠"; font.pixelSize: 14 }
                                Text { text: "Alertas"; color: App.Theme.textPrimary; font.pixelSize: App.Theme.fontSizeS; font.weight: Font.Bold }
                                Rectangle {
                                    width: 20; height: 20; radius: 10
                                    color: teleop.alerts.length > 0 ? App.Theme.statusCritical : App.Theme.bgTertiary
                                    visible: teleop.alerts.length > 0
                                    Text { anchors.centerIn: parent; text: teleop.alerts.length; color: "#ffffff"; font.pixelSize: 10; font.weight: Font.Bold }
                                }
                            }

                            ListView {
                                width: parent.width
                                height: parent.height - 30
                                clip: true
                                spacing: 4
                                model: teleop.alerts
                                delegate: Rectangle {
                                    width: ListView.view.width
                                    height: 32
                                    radius: App.Theme.radiusS
                                    color: modelData.type === "critical" ? App.Theme.statusCriticalBg : App.Theme.statusWarningBg
                                    border.width: 1
                                    border.color: modelData.type === "critical" ? App.Theme.statusCritical : App.Theme.statusWarning
                                    Row {
                                        anchors.fill: parent
                                        anchors.margins: 6
                                        spacing: 6
                                        Rectangle { width: 6; height: 6; radius: 3; color: modelData.type === "critical" ? App.Theme.statusCritical : App.Theme.statusWarning; anchors.verticalCenter: parent.verticalCenter }
                                        Text { text: modelData.message; color: modelData.type === "critical" ? App.Theme.statusCritical : App.Theme.statusWarning; font.pixelSize: 10; anchors.verticalCenter: parent.verticalCenter; elide: Text.ElideRight; width: parent.width - 20 }
                                    }
                                }
                                Text { anchors.centerIn: parent; text: "✓ Sin alertas"; color: App.Theme.accentGreen; font.pixelSize: App.Theme.fontSizeS; visible: teleop.alerts.length === 0 }
                            }
                        }
                    }

                    // Eventos Marcados
                    Card {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100

                        Column {
                            anchors.fill: parent
                            anchors.margins: App.Theme.spacingM
                            spacing: App.Theme.spacingS

                            Row {
                                spacing: 6
                                Text { text: "📍"; font.pixelSize: 12 }
                                Text { text: "Eventos Marcados"; color: App.Theme.textPrimary; font.pixelSize: App.Theme.fontSizeS; font.weight: Font.Bold }
                            }

                            ListView {
                                width: parent.width
                                height: 70
                                clip: true
                                spacing: 2
                                model: teleop.markedEvents
                                delegate: Row {
                                    spacing: 6
                                    Text { text: modelData.type === "gas" ? "💨" : modelData.type === "crack" ? "⚡" : "🚧"; font.pixelSize: 12 }
                                    Text { text: modelData.type.toUpperCase(); color: App.Theme.textPrimary; font.pixelSize: 10; font.weight: Font.Bold }
                                    Text { text: modelData.timestamp; color: App.Theme.textTertiary; font.pixelSize: 9 }
                                }
                                Text { anchors.centerIn: parent; text: "Sin eventos"; color: App.Theme.textTertiary; font.pixelSize: 10; visible: teleop.markedEvents.length === 0 }
                            }
                        }
                    }
                    // Joystick Derecho - Pitch / Roll
                    Card {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 200
                        visible: isTeleoperated

                        Rectangle {
                            anchors.fill: parent
                            radius: App.Theme.radiusL
                            color: Qt.rgba(0,0,0,0.5)
                            border.width: 1
                            border.color: App.Theme.accentGreen

                            VirtualJoystick {
                                anchors.centerIn: parent
                                anchors.verticalCenterOffset: 6
                                label: "Pitch / Roll"
                                accentColor: App.Theme.accentGreen
                                onMoved: function(x, y) {
                                    if (teleop.isFlying)
                                        teleop.sendMovement(0, 0, y, x)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    

    // Teclado
    Item {
        focus: true
        Keys.onPressed: function(event) {
            if (!teleop.isFlying || !isTeleoperated) return
            var t = 0, y = 0, p = 0, r = 0
            switch(event.key) {
                case Qt.Key_W: p = 1; break
                case Qt.Key_S: p = -1; break
                case Qt.Key_A: r = -1; break
                case Qt.Key_D: r = 1; break
                case Qt.Key_Q: y = -1; break
                case Qt.Key_E: y = 1; break
                case Qt.Key_Space: t = 1; break
                case Qt.Key_Control: t = -1; break
            }
            if (t !== 0 || y !== 0 || p !== 0 || r !== 0) teleop.sendMovement(t, y, p, r)
        }
    }



}
