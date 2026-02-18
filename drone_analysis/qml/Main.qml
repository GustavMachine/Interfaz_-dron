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
    minimumWidth: 1200
    minimumHeight: 700
    title: "Sistema de Inspección Autónoma - Análisis de Datos"
    color: App.Theme.bgPrimary

    // Propiedades para controlar vistas
    property bool showGasEvolution: false

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
        property bool small: false
        property bool danger: false
        signal clicked()
        
        width: btnContent.width + (small ? 16 : 24)
        height: small ? 28 : 36
        radius: App.Theme.radiusM
        color: {
            if (danger) return btnMouse.containsMouse ? App.Theme.accentRedDim : App.Theme.accentRed
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
                color: (btnRoot.primary || btnRoot.danger) ? App.Theme.textInverse : App.Theme.textPrimary
                font.family: App.Theme.fontPrimary
                font.pixelSize: btnRoot.small ? App.Theme.fontSizeS : App.Theme.fontSizeM
                font.weight: Font.Medium
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        
        MouseArea {
            id: btnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btnRoot.clicked()
        }
    }

    component StatusBadge: Rectangle {
        property string severity: "info"
        property string label: ""
        
        width: badgeText.width + 16
        height: 22
        radius: App.Theme.radiusRound
        color: App.Theme.severityBgColor(severity)
        border.width: 1
        border.color: App.Theme.severityColor(severity)
        
        Text {
            id: badgeText
            anchors.centerIn: parent
            text: label
            color: App.Theme.severityColor(severity)
            font.family: App.Theme.fontPrimary
            font.pixelSize: App.Theme.fontSizeXs
            font.weight: Font.Bold
        }
    }

    component MetricDisplay: Column {
        property string label: ""
        property string value: ""
        property string unit: ""
        property color valueColor: App.Theme.textPrimary
        
        spacing: 2
        
        Text {
            text: label
            color: App.Theme.textSecondary
            font.family: App.Theme.fontPrimary
            font.pixelSize: App.Theme.fontSizeXs
            font.weight: Font.Medium
        }
        Row {
            spacing: 4
            Text {
                text: value
                color: valueColor
                font.family: App.Theme.fontMono
                font.pixelSize: App.Theme.fontSizeL
                font.weight: Font.Bold
            }
            Text {
                text: unit
                color: App.Theme.textTertiary
                font.family: App.Theme.fontMono
                font.pixelSize: App.Theme.fontSizeS
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 2
            }
        }
    }

    component Sparkline: Canvas {
        id: sparkCanvas
        property var data: []
        property color lineColor: App.Theme.accentBlue
        property real minValue: 0
        property real maxValue: 100
        
        onDataChanged: requestPaint()
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            if (data.length < 2) return;
            var w = width;
            var h = height;
            var range = maxValue - minValue;
            if (range === 0) range = 1;
            ctx.strokeStyle = lineColor;
            ctx.lineWidth = 1.5;
            ctx.beginPath();
            for (var i = 0; i < data.length; i++) {
                var x = (i / (data.length - 1)) * w;
                var y = h - ((data[i] - minValue) / range) * h;
                if (i === 0) ctx.moveTo(x, y);
                else ctx.lineTo(x, y);
            }
            ctx.stroke();
            var gradient = ctx.createLinearGradient(0, 0, 0, h);
            gradient.addColorStop(0, Qt.rgba(lineColor.r, lineColor.g, lineColor.b, 0.3));
            gradient.addColorStop(1, Qt.rgba(lineColor.r, lineColor.g, lineColor.b, 0));
            ctx.lineTo(w, h);
            ctx.lineTo(0, h);
            ctx.closePath();
            ctx.fillStyle = gradient;
            ctx.fill();
        }
    }

    // Gráfico completo de evolución de gas
    component GasChart: Rectangle {
        id: gasChartRoot
        property string gasName: "CH₄"
        property string gasKey: "ch4"
        property color gasColor: App.Theme.dataCH4
        property real minVal: 0
        property real maxVal: 2
        property string unit: "% LEL"
        
        color: App.Theme.bgCard
        radius: App.Theme.radiusL
        border.width: 1
        border.color: App.Theme.borderMuted

        Column {
            anchors.fill: parent
            anchors.margins: App.Theme.spacingM
            spacing: App.Theme.spacingS

            RowLayout {
                width: parent.width

                Rectangle {
                    width: 12
                    height: 12
                    radius: 6
                    color: gasChartRoot.gasColor
                }

                Text {
                    text: gasChartRoot.gasName
                    color: App.Theme.textPrimary
                    font.pixelSize: App.Theme.fontSizeM
                    font.weight: Font.Bold
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "Máx: " + gasChartRoot.maxVal.toFixed(2) + " " + gasChartRoot.unit
                    color: App.Theme.textTertiary
                    font.pixelSize: App.Theme.fontSizeXs
                }
            }

            Canvas {
                width: parent.width
                height: 120

                property var telemetryData: analysisController.getAllTelemetry()

                Component.onCompleted: requestPaint()

                Connections {
                    target: analysisController
                    function onTimelinePositionChanged() { parent.children[1].requestPaint() }
                }

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    var w = width;
                    var h = height;
                    var data = telemetryData;
                    if (!data || data.length < 2) return;

                    var padding = 30;
                    var chartW = w - padding;
                    var chartH = h - 20;

                    // Grid
                    ctx.strokeStyle = "#21262d";
                    ctx.lineWidth = 1;
                    for (var i = 0; i <= 4; i++) {
                        var y = 10 + (chartH / 4) * i;
                        ctx.beginPath();
                        ctx.moveTo(padding, y);
                        ctx.lineTo(w, y);
                        ctx.stroke();
                    }

                    // Etiquetas Y
                    ctx.fillStyle = "#6e7681";
                    ctx.font = "10px 'Segoe UI'";
                    ctx.textAlign = "right";
                    for (var j = 0; j <= 4; j++) {
                        var val = gasChartRoot.maxVal - (gasChartRoot.maxVal - gasChartRoot.minVal) * (j / 4);
                        var yPos = 10 + (chartH / 4) * j;
                        ctx.fillText(val.toFixed(1), padding - 5, yPos + 3);
                    }

                    // Línea de datos
                    ctx.strokeStyle = gasChartRoot.gasColor;
                    ctx.lineWidth = 2;
                    ctx.beginPath();
                    for (var k = 0; k < data.length; k++) {
                        var x = padding + (k / (data.length - 1)) * chartW;
                        var dataVal = data[k][gasChartRoot.gasKey] || 0;
                        var yVal = 10 + chartH - ((dataVal - gasChartRoot.minVal) / (gasChartRoot.maxVal - gasChartRoot.minVal)) * chartH;
                        if (k === 0) ctx.moveTo(x, yVal);
                        else ctx.lineTo(x, yVal);
                    }
                    ctx.stroke();

                    // Gradiente
                    var gradient = ctx.createLinearGradient(0, 10, 0, 10 + chartH);
                    gradient.addColorStop(0, Qt.rgba(gasChartRoot.gasColor.r, gasChartRoot.gasColor.g, gasChartRoot.gasColor.b, 0.3));
                    gradient.addColorStop(1, Qt.rgba(gasChartRoot.gasColor.r, gasChartRoot.gasColor.g, gasChartRoot.gasColor.b, 0));
                    ctx.lineTo(padding + chartW, 10 + chartH);
                    ctx.lineTo(padding, 10 + chartH);
                    ctx.closePath();
                    ctx.fillStyle = gradient;
                    ctx.fill();

                    // Marcador de posición actual
                    var currentPos = analysisController.currentTime / analysisController.totalTime;
                    var markerX = padding + currentPos * chartW;
                    ctx.strokeStyle = "#58a6ff";
                    ctx.lineWidth = 2;
                    ctx.setLineDash([4, 4]);
                    ctx.beginPath();
                    ctx.moveTo(markerX, 10);
                    ctx.lineTo(markerX, 10 + chartH);
                    ctx.stroke();
                    ctx.setLineDash([]);

                    // Etiquetas X
                    ctx.fillStyle = "#6e7681";
                    ctx.textAlign = "center";
                    ctx.fillText("0:00", padding, h - 2);
                    ctx.fillText(analysisController.formatTime(analysisController.totalTime / 2), padding + chartW / 2, h - 2);
                    ctx.fillText(analysisController.formatTime(analysisController.totalTime), padding + chartW, h - 2);
                }
            }
        }
    }

    component ToggleSwitch: Rectangle {
        id: toggleRoot
        property bool checked: true
        property string label: ""
        signal toggled(bool value)
        
        width: toggleRow.width
        height: 28
        color: "transparent"
        
        Row {
            id: toggleRow
            spacing: 8
            anchors.verticalCenter: parent.verticalCenter
            
            Rectangle {
                width: 36
                height: 20
                radius: 10
                color: toggleRoot.checked ? App.Theme.accentBlueDim : App.Theme.bgTertiary
                border.width: 1
                border.color: toggleRoot.checked ? App.Theme.accentBlue : App.Theme.borderDefault
                anchors.verticalCenter: parent.verticalCenter
                
                Rectangle {
                    width: 16
                    height: 16
                    radius: 8
                    x: toggleRoot.checked ? parent.width - width - 2 : 2
                    anchors.verticalCenter: parent.verticalCenter
                    color: App.Theme.textPrimary
                    
                    Behavior on x {
                        NumberAnimation { duration: App.Theme.animFast }
                    }
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
                font.family: App.Theme.fontPrimary
                font.pixelSize: App.Theme.fontSizeS
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // HEADER
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: App.Theme.headerHeight
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

                // Logo
                Row {
                    spacing: App.Theme.spacingM
                    Layout.alignment: Qt.AlignVCenter

                    Rectangle {
                        width: 36
                        height: 36
                        radius: App.Theme.radiusM
                        color: App.Theme.accentBlueDim
                        
                        Text {
                            anchors.centerIn: parent
                            text: "🚁"
                            font.pixelSize: 18
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Text {
                            text: "INSPECCIÓN AUTÓNOMA"
                            color: App.Theme.textPrimary
                            font.family: App.Theme.fontPrimary
                            font.pixelSize: App.Theme.fontSizeL
                            font.weight: Font.Bold
                            font.letterSpacing: 1
                        }
                        Text {
                            text: "Sistema de Análisis de Datos"
                            color: App.Theme.textTertiary
                            font.family: App.Theme.fontPrimary
                            font.pixelSize: App.Theme.fontSizeXs
                        }
                    }
                }

                // Navegación
                Row {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 4

                    Repeater {
                        model: [
                            { name: "Configuración", active: false },
                            { name: "Teleoperación", active: false },
                            { name: "Análisis", active: true }
                        ]

                        Rectangle {
                            width: navText.width + 24
                            height: 32
                            radius: App.Theme.radiusM
                            color: modelData.active ? App.Theme.accentBlueDim : (navMouse.containsMouse ? App.Theme.bgCardHover : "transparent")

                            Text {
                                id: navText
                                anchors.centerIn: parent
                                text: modelData.name
                                color: modelData.active ? App.Theme.accentBlue : App.Theme.textSecondary
                                font.family: App.Theme.fontPrimary
                                font.pixelSize: App.Theme.fontSizeS
                                font.weight: modelData.active ? Font.Bold : Font.Normal
                            }

                            MouseArea {
                                id: navMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // Estado misión
                Row {
                    spacing: App.Theme.spacingL
                    Layout.alignment: Qt.AlignVCenter

                    Row {
                        spacing: 6
                        
                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: App.Theme.accentGreen
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        Text {
                            text: "Misión cargada"
                            color: App.Theme.textSecondary
                            font.pixelSize: App.Theme.fontSizeXs
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Column {
                        Text {
                            text: analysisController.missionInfo.id
                            color: App.Theme.textPrimary
                            font.family: App.Theme.fontMono
                            font.pixelSize: App.Theme.fontSizeS
                            font.weight: Font.Bold
                        }
                        Text {
                            text: analysisController.missionInfo.date
                            color: App.Theme.textTertiary
                            font.pixelSize: App.Theme.fontSizeXs
                        }
                    }
                }

                Rectangle {
                    width: 1
                    height: 32
                    color: App.Theme.borderDefault
                    Layout.alignment: Qt.AlignVCenter
                }

                // Reloj
                Column {
                    Layout.alignment: Qt.AlignVCenter
                    
                    Text {
                        id: clockText
                        text: "00:00:00"
                        color: App.Theme.textPrimary
                        font.family: App.Theme.fontMono
                        font.pixelSize: App.Theme.fontSizeM
                        font.weight: Font.Medium

                        Timer {
                            interval: 1000
                            running: true
                            repeat: true
                            onTriggered: {
                                var now = new Date()
                                clockText.text = Qt.formatTime(now, "hh:mm:ss")
                            }
                            Component.onCompleted: {
                                var now = new Date()
                                clockText.text = Qt.formatTime(now, "hh:mm:ss")
                            }
                        }
                    }
                    
                    Text {
                        text: Qt.formatDate(new Date(), "dd MMM yyyy")
                        color: App.Theme.textTertiary
                        font.pixelSize: App.Theme.fontSizeXs
                    }
                }
            }
        }

        // CONTENIDO PRINCIPAL
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // PANEL IZQUIERDO - CORREGIDO
            Rectangle {
                Layout.preferredWidth: 300
                Layout.fillHeight: true
                color: App.Theme.bgSecondary
                z: 1

                Rectangle {
                    anchors.right: parent.right
                    width: 1
                    height: parent.height
                    color: App.Theme.borderMuted
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: App.Theme.spacingM
                    spacing: App.Theme.spacingM

                    // Resumen de Misión
                    Card {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 220  // CAMBIAR: altura fija en lugar de calculada

                        ColumnLayout {
                            id: missionInfoCol
                            anchors.fill: parent
                            anchors.margins: App.Theme.spacingL
                            spacing: App.Theme.spacingS

                            Text {
                                text: "📋 Resumen de Misión"
                                color: App.Theme.textPrimary
                                font.pixelSize: App.Theme.fontSizeM
                                font.weight: Font.Bold
                            }

                            GridLayout {
                                columns: 2
                                columnSpacing: App.Theme.spacingM
                                rowSpacing: 4
                                Layout.fillWidth: true

                                Text { text: "ID:"; color: App.Theme.textTertiary; font.pixelSize: App.Theme.fontSizeXs }
                                Text { text: analysisController.missionInfo.id; color: App.Theme.accentBlue; font.family: App.Theme.fontMono; font.pixelSize: App.Theme.fontSizeXs; font.weight: Font.Bold }

                                Text { text: "Duración:"; color: App.Theme.textTertiary; font.pixelSize: App.Theme.fontSizeXs }
                                Text { text: analysisController.missionInfo.duration + " min"; color: App.Theme.textPrimary; font.family: App.Theme.fontMono; font.pixelSize: App.Theme.fontSizeXs }

                                Text { text: "Distancia:"; color: App.Theme.textTertiary; font.pixelSize: App.Theme.fontSizeXs }
                                Text { text: analysisController.missionInfo.distance + " m"; color: App.Theme.textPrimary; font.family: App.Theme.fontMono; font.pixelSize: App.Theme.fontSizeXs }

                                Text { text: "Sector:"; color: App.Theme.textTertiary; font.pixelSize: App.Theme.fontSizeXs }
                                Text { text: analysisController.missionInfo.sector; color: App.Theme.textPrimary; font.pixelSize: App.Theme.fontSizeXs; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                            }

                            // Botones de descarga
                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: App.Theme.borderMuted
                            }

                            Text {
                                text: "📥 Descargas"
                                color: App.Theme.textSecondary
                                font.pixelSize: App.Theme.fontSizeXs
                                font.weight: Font.Bold
                            }

                            StyledButton {
                                Layout.fillWidth: true
                                text: "Descargar Video"
                                icon: "🎬"
                                onClicked: analysisController.downloadVideo()
                            }

                            StyledButton {
                                Layout.fillWidth: true
                                text: "Descargar Fotos Grietas"
                                icon: "📸"
                                onClicked: analysisController.downloadCrackPhotos()
                            }

                            StyledButton {
                                Layout.fillWidth: true
                                text: "Evolución de Gases"
                                icon: "📈"
                                primary: showGasEvolution
                                onClicked: showGasEvolution = !showGasEvolution
                            }
                        }
                    }

                    // Estadísticas compactas
                    Card {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 140  // CAMBIAR: altura fija en lugar de calculada

                        Column {
                            id: statsCompact
                            anchors.fill: parent
                            anchors.margins: App.Theme.spacingM
                            spacing: App.Theme.spacingS

                            Text {
                                text: "📊 Estadísticas"
                                color: App.Theme.textPrimary
                                font.pixelSize: App.Theme.fontSizeM
                                font.weight: Font.Bold
                            }

                            Row {
                                width: parent.width
                                spacing: 4

                                Rectangle {
                                    width: (parent.width - 8) / 3
                                    height: 50
                                    radius: App.Theme.radiusS
                                    color: App.Theme.bgTertiary

                                    Column {
                                        anchors.centerIn: parent
                                        Text {
                                            text: analysisController.missionStats.total_events
                                            color: App.Theme.textPrimary
                                            font.family: App.Theme.fontMono
                                            font.pixelSize: App.Theme.fontSizeL
                                            font.weight: Font.Bold
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                        Text {
                                            text: "Total"
                                            color: App.Theme.textTertiary
                                            font.pixelSize: 9
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                    }
                                }

                                Rectangle {
                                    width: (parent.width - 8) / 3
                                    height: 50
                                    radius: App.Theme.radiusS
                                    color: App.Theme.statusCriticalBg

                                    Column {
                                        anchors.centerIn: parent
                                        Text {
                                            text: analysisController.missionStats.critical_events
                                            color: App.Theme.statusCritical
                                            font.family: App.Theme.fontMono
                                            font.pixelSize: App.Theme.fontSizeL
                                            font.weight: Font.Bold
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                        Text {
                                            text: "Críticos"
                                            color: App.Theme.statusCritical
                                            font.pixelSize: 9
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                    }
                                }

                                Rectangle {
                                    width: (parent.width - 8) / 3
                                    height: 50
                                    radius: App.Theme.radiusS
                                    color: App.Theme.statusWarningBg

                                    Column {
                                        anchors.centerIn: parent
                                        Text {
                                            text: analysisController.missionStats.warning_events
                                            color: App.Theme.statusWarning
                                            font.family: App.Theme.fontMono
                                            font.pixelSize: App.Theme.fontSizeL
                                            font.weight: Font.Bold
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                        Text {
                                            text: "Warnings"
                                            color: App.Theme.statusWarning
                                            font.pixelSize: 9
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                    }
                                }
                            }

                            // Desglose por tipo
                            GridLayout {
                                columns: 4
                                columnSpacing: App.Theme.spacingS
                                rowSpacing: 2
                                Layout.fillWidth: true

                                Text { text: "💨"; font.pixelSize: 10 }
                                Text { text: analysisController.missionStats.gas_events; color: App.Theme.dataCH4; font.family: App.Theme.fontMono; font.pixelSize: App.Theme.fontSizeXs; font.weight: Font.Bold }
                                Text { text: "⚡"; font.pixelSize: 10 }
                                Text { text: analysisController.missionStats.crack_events; color: App.Theme.accentRed; font.family: App.Theme.fontMono; font.pixelSize: App.Theme.fontSizeXs; font.weight: Font.Bold }

                                Text { text: "🚧"; font.pixelSize: 10 }
                                Text { text: analysisController.missionStats.obstacle_events; color: App.Theme.accentOrange; font.family: App.Theme.fontMono; font.pixelSize: App.Theme.fontSizeXs; font.weight: Font.Bold }
                                Text { text: "⚠"; font.pixelSize: 10 }
                                Text { text: analysisController.missionStats.anomaly_events; color: App.Theme.accentCyan; font.family: App.Theme.fontMono; font.pixelSize: App.Theme.fontSizeXs; font.weight: Font.Bold }
                            }
                        }
                    }

                    // Lista de Eventos
                    Card {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: App.Theme.spacingM
                            spacing: App.Theme.spacingS

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text: "🎯 Eventos"
                                    color: App.Theme.textPrimary
                                    font.pixelSize: App.Theme.fontSizeM
                                    font.weight: Font.Bold
                                }

                                Item { Layout.fillWidth: true }

                                Text {
                                    text: analysisController.filteredEvents.length + " items"
                                    color: App.Theme.textTertiary
                                    font.pixelSize: App.Theme.fontSizeXs
                                }
                            }

                            Row {
                                Layout.fillWidth: true
                                spacing: 4

                                ComboBox {
                                    id: typeFilterCombo
                                    width: (parent.width - 4) / 2
                                    height: 26
                                    model: ["Todos", "Gas", "Grieta", "Obstác.", "Anomalía"]
                                    
                                    background: Rectangle {
                                        color: App.Theme.bgTertiary
                                        radius: App.Theme.radiusS
                                        border.width: 1
                                        border.color: App.Theme.borderDefault
                                    }
                                    
                                    contentItem: Text {
                                        text: typeFilterCombo.displayText
                                        color: App.Theme.textPrimary
                                        font.pixelSize: 10
                                        verticalAlignment: Text.AlignVCenter
                                        leftPadding: 6
                                    }
                                    
                                    onCurrentIndexChanged: {
                                        var filters = ["all", "gas", "crack", "obstacle", "anomaly"]
                                        analysisController.setTypeFilter(filters[currentIndex])
                                    }
                                }

                                ComboBox {
                                    id: severityFilterCombo
                                    width: (parent.width - 4) / 2
                                    height: 26
                                    model: ["Todas", "Crítico", "Warning", "Menor"]
                                    
                                    background: Rectangle {
                                        color: App.Theme.bgTertiary
                                        radius: App.Theme.radiusS
                                        border.width: 1
                                        border.color: App.Theme.borderDefault
                                    }
                                    
                                    contentItem: Text {
                                        text: severityFilterCombo.displayText
                                        color: App.Theme.textPrimary
                                        font.pixelSize: 10
                                        verticalAlignment: Text.AlignVCenter
                                        leftPadding: 6
                                    }
                                    
                                    onCurrentIndexChanged: {
                                        var filters = ["all", "critical", "warning", "low"]
                                        analysisController.setSeverityFilter(filters[currentIndex])
                                    }
                                }
                            }

                            ListView {
                                id: eventsListView
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true
                                spacing: 4
                                model: analysisController.filteredEvents

                                delegate: Rectangle {
                                    width: eventsListView.width
                                    height: 56
                                    radius: App.Theme.radiusM
                                    color: analysisController.selectedEventId === modelData.id ? App.Theme.bgCardHover : (eventItemMouse.containsMouse ? App.Theme.bgTertiary : "transparent")
                                    border.width: analysisController.selectedEventId === modelData.id ? 1 : 0
                                    border.color: App.Theme.typeColor(modelData.type)

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 6
                                        spacing: 6

                                        Rectangle {
                                            width: 32
                                            height: 32
                                            radius: App.Theme.radiusS
                                            color: Qt.rgba(App.Theme.typeColor(modelData.type).r, App.Theme.typeColor(modelData.type).g, App.Theme.typeColor(modelData.type).b, 0.2)

                                            Text {
                                                anchors.centerIn: parent
                                                text: App.Theme.typeIcon(modelData.type)
                                                font.pixelSize: 14
                                            }
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 2

                                            RowLayout {
                                                spacing: 4

                                                Text {
                                                    text: modelData.title
                                                    color: App.Theme.textPrimary
                                                    font.pixelSize: 11
                                                    font.weight: Font.Medium
                                                    elide: Text.ElideRight
                                                    Layout.fillWidth: true
                                                }

                                                StatusBadge {
                                                    severity: modelData.severity
                                                    label: analysisController.getSeverityLabel(modelData.severity)
                                                }
                                            }

                                            Text {
                                                text: analysisController.formatTime(modelData.timestamp) + " | " + modelData.position.toFixed(1) + "m"
                                                color: App.Theme.textTertiary
                                                font.family: App.Theme.fontMono
                                                font.pixelSize: 9
                                            }
                                        }
                                    }

                                    MouseArea {
                                        id: eventItemMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: analysisController.selectEvent(modelData.id)
                                    }
                                }

                                ScrollBar.vertical: ScrollBar { 
                                    active: true 
                                    width: 6
                                    policy: ScrollBar.AsNeeded
                                    contentItem: Rectangle {
                                        implicitWidth: 6
                                        radius: 3
                                        color: parent.pressed ? "#58a6ff" : "#30363d"
                                        }
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

                // Vista principal (túnel o evolución de gases)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 300
                    color: App.Theme.bgPrimary

                    // Vista del túnel
                    Item {
                        id: tunnelVisualization
                        anchors.fill: parent
                        anchors.margins: App.Theme.spacingM
                        visible: !showGasEvolution
                        Image {
                            id: mapImage
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            mipmap: true
                            source: Qt.resolvedUrl("tunel2d.png")
                        }

                        

                        // Panel de capas
                        Card {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            width: 160
                            height: layersColumn.height + App.Theme.spacingM * 2

                            Column {
                                id: layersColumn
                                anchors.fill: parent
                                anchors.margins: App.Theme.spacingM
                                spacing: App.Theme.spacingXs

                                Text {
                                    text: "🗺 Capas"
                                    color: App.Theme.textPrimary
                                    font.pixelSize: App.Theme.fontSizeS
                                    font.weight: Font.Bold
                                }

                                ToggleSwitch { label: "Trayectoria"; checked: analysisController.layers.trajectory; onToggled: function(v) { analysisController.setLayerVisibility("trajectory", v) } }
                                ToggleSwitch { label: "Heatmap gases"; checked: analysisController.layers.gas_heatmap; onToggled: function(v) { analysisController.setLayerVisibility("gas_heatmap", v) } }
                                ToggleSwitch { label: "Grietas"; checked: analysisController.layers.cracks; onToggled: function(v) { analysisController.setLayerVisibility("cracks", v) } }
                                ToggleSwitch { label: "Obstáculos"; checked: analysisController.layers.obstacles; onToggled: function(v) { analysisController.setLayerVisibility("obstacles", v) } }
                                ToggleSwitch { label: "Anomalías"; checked: analysisController.layers.anomalies; onToggled: function(v) { analysisController.setLayerVisibility("anomalies", v) } }
                            }
                        }

                        // Leyenda
                        Card {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            width: legendRow.width + App.Theme.spacingL * 2
                            height: 36

                            Row {
                                id: legendRow
                                anchors.centerIn: parent
                                spacing: App.Theme.spacingM

                                Row {
                                    spacing: 4
                                    Rectangle { width: 8; height: 8; radius: 4; color: App.Theme.statusCritical; anchors.verticalCenter: parent.verticalCenter }
                                    Text { text: "Crítico"; color: App.Theme.textSecondary; font.pixelSize: 10; anchors.verticalCenter: parent.verticalCenter }
                                }
                                Row {
                                    spacing: 4
                                    Rectangle { width: 8; height: 8; radius: 4; color: App.Theme.statusWarning; anchors.verticalCenter: parent.verticalCenter }
                                    Text { text: "Warning"; color: App.Theme.textSecondary; font.pixelSize: 10; anchors.verticalCenter: parent.verticalCenter }
                                }
                                Row {
                                    spacing: 4
                                    Rectangle { width: 8; height: 8; radius: 4; color: App.Theme.statusSuccess; anchors.verticalCenter: parent.verticalCenter }
                                    Text { text: "Menor"; color: App.Theme.textSecondary; font.pixelSize: 10; anchors.verticalCenter: parent.verticalCenter }
                                }
                                Row {
                                    spacing: 4
                                    Rectangle { width: 8; height: 8; radius: 4; color: App.Theme.statusInfo; anchors.verticalCenter: parent.verticalCenter }
                                    Text { text: "Info"; color: App.Theme.textSecondary; font.pixelSize: 10; anchors.verticalCenter: parent.verticalCenter }
                                }
                            }
                        }
                    }

                    // Vista de Evolución de Gases
                    Item {
                        anchors.fill: parent
                        anchors.margins: App.Theme.spacingM
                        visible: showGasEvolution

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: App.Theme.spacingM

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text: "📈 Evolución de Gases en el Tiempo"
                                    color: App.Theme.textPrimary
                                    font.pixelSize: App.Theme.fontSizeL
                                    font.weight: Font.Bold
                                }

                                Item { Layout.fillWidth: true }

                                StyledButton {
                                    text: "Volver al Mapa"
                                    icon: "🗺"
                                    onClicked: showGasEvolution = false
                                }
                            }

                            GasChart {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 160
                                gasName: "CH₄ (Metano)"
                                gasKey: "ch4"
                                gasColor: App.Theme.dataCH4
                                minVal: 0
                                maxVal: 2
                                unit: "% LEL"
                            }

                            GasChart {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 160
                                gasName: "CO (Monóxido de Carbono)"
                                gasKey: "co"
                                gasColor: App.Theme.dataCO
                                minVal: 0
                                maxVal: 30
                                unit: "ppm"
                            }

                            GasChart {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 160
                                gasName: "O₂ (Oxígeno)"
                                gasKey: "o2"
                                gasColor: App.Theme.dataO2
                                minVal: 19
                                maxVal: 22
                                unit: "%"
                            }

                            Item { Layout.fillHeight: true }
                        }
                    }
                }

                // Timeline
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
                    Layout.minimumHeight: 110
                    Layout.maximumHeight: 140
                    Layout.fillHeight: false
                    clip: false
                    color: App.Theme.bgSecondary

                    Rectangle {
                        anchors.top: parent.top
                        width: parent.width
                        height: 1
                        color: App.Theme.borderMuted
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins:6
                        spacing: App.Theme.spacingXs

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36

                            Rectangle {
                                id: timelineTrack
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                height: 8
                                radius: 4
                                color: App.Theme.bgTertiary

                                Rectangle {
                                    width: parent.width * (analysisController.currentTime / analysisController.totalTime)
                                    height: parent.height
                                    radius: 4
                                    color: App.Theme.accentBlue

                                    Behavior on width {
                                        NumberAnimation { duration: 50 }
                                    }
                                }

                                Repeater {
                                    model: analysisController.allEvents

                                    Rectangle {
                                        x: (modelData.timestamp / analysisController.totalTime) * timelineTrack.width - 3
                                        y: -3
                                        width: 6
                                        height: 14
                                        radius: 2
                                        color: App.Theme.severityColor(modelData.severity)
                                        opacity: markerMouse.containsMouse ? 1.0 : 0.7

                                        MouseArea {
                                            id: markerMouse
                                            anchors.fill: parent
                                            anchors.margins: -4
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: analysisController.selectEvent(modelData.id)
                                        }
                                    }
                                }

                                Rectangle {
                                    id: timelineHandle
                                    x: (analysisController.currentTime / analysisController.totalTime) * parent.width - 7
                                    y: -5
                                    width: 14
                                    height: 18
                                    radius: 3
                                    color: handleMouse.pressed ? App.Theme.accentBlue : (handleMouse.containsMouse ? App.Theme.textPrimary : App.Theme.textSecondary)

                                    Behavior on x {
                                        enabled: !handleMouse.pressed
                                        NumberAnimation { duration: 50 }
                                    }

                                    MouseArea {
                                        id: handleMouse
                                        anchors.fill: parent
                                        anchors.margins: -8
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        drag.target: parent
                                        drag.axis: Drag.XAxis
                                        drag.minimumX: -7
                                        drag.maximumX: timelineTrack.width - 7

                                        onPositionChanged: {
                                            if (pressed) {
                                                var newTime = Math.round(((parent.x + 7) / timelineTrack.width) * analysisController.totalTime)
                                                analysisController.seekTo(newTime)
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    anchors.margins: -10
                                    onClicked: function(mouse) {
                                        var newTime = Math.round((mouse.x / width) * analysisController.totalTime)
                                        analysisController.seekTo(newTime)
                                    }
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: App.Theme.spacingS

                            Text {
                                text: analysisController.formatTime(analysisController.currentTime)
                                color: App.Theme.accentBlue
                                font.family: App.Theme.fontMono
                                font.pixelSize: App.Theme.fontSizeL
                                font.weight: Font.Bold
                            }

                            Text {
                                text: "/ " + analysisController.formatTime(analysisController.totalTime)
                                color: App.Theme.textTertiary
                                font.family: App.Theme.fontMono
                                font.pixelSize: App.Theme.fontSizeS
                            }

                            Item { Layout.preferredWidth: App.Theme.spacingM }

                            Row {
                                spacing: 4

                                StyledButton { text: ""; icon: "⏮"; small: true; onClicked: analysisController.goToStart() }
                                StyledButton { text: ""; icon: "⏪"; small: true; onClicked: analysisController.skipBackward() }
                                StyledButton { text: ""; icon: analysisController.isPlaying ? "⏸" : "▶"; primary: true; width: 44; onClicked: analysisController.togglePlayPause() }
                                StyledButton { text: ""; icon: "⏩"; small: true; onClicked: analysisController.skipForward() }
                                StyledButton { text: ""; icon: "⏭"; small: true; onClicked: analysisController.goToEnd() }
                            }

                            Item { Layout.preferredWidth: App.Theme.spacingM }

                            Row {
                                spacing: 4

                                Text {
                                    text: "Velocidad:"
                                    color: App.Theme.textTertiary
                                    font.pixelSize: App.Theme.fontSizeXs
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Repeater {
                                    model: [1, 2, 5, 10]

                                    Rectangle {
                                        width: 28
                                        height: 22
                                        radius: App.Theme.radiusS
                                        color: analysisController.playbackSpeed === modelData ? App.Theme.accentBlueDim : (speedMouse.containsMouse ? App.Theme.bgCardHover : App.Theme.bgTertiary)
                                        border.width: analysisController.playbackSpeed === modelData ? 1 : 0
                                        border.color: App.Theme.accentBlue

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData + "x"
                                            color: analysisController.playbackSpeed === modelData ? App.Theme.accentBlue : App.Theme.textSecondary
                                            font.pixelSize: 10
                                            font.weight: analysisController.playbackSpeed === modelData ? Font.Bold : Font.Normal
                                        }

                                        MouseArea {
                                            id: speedMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: analysisController.setPlaybackSpeed(modelData)
                                        }
                                    }
                                }
                            }

                            Item { Layout.fillWidth: true }

                            Row {
                                spacing: App.Theme.spacingS

                                Text {
                                    text: "📍"
                                    font.pixelSize: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: analysisController.currentPosition.toFixed(1) + "m"
                                    color: App.Theme.accentCyan
                                    font.family: App.Theme.fontMono
                                    font.pixelSize: App.Theme.fontSizeM
                                    font.weight: Font.Bold
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: "de " + analysisController.missionInfo.distance + "m"
                                    color: App.Theme.textTertiary
                                    font.pixelSize: App.Theme.fontSizeXs
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }
                }
            }

            // PANEL DERECHO - TELEMETRÍA
            Rectangle {
                Layout.preferredWidth: 280
                Layout.fillHeight: true
                color: App.Theme.bgSecondary
                z: 1

                Rectangle {
                    anchors.left: parent.left
                    width: 1
                    height: parent.height
                    color: App.Theme.borderMuted
                }
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: App.Theme.spacingM
                    spacing: App.Theme.spacingMs

                    // Telemetría
                    Card {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 130

                        Column {
                            id: telemetryCol
                            anchors.fill: parent
                            anchors.margins: App.Theme.spacingM
                            spacing: App.Theme.spacingS

                            Text {
                                text: "📡 Telemetría"
                                color: App.Theme.textPrimary
                                font.pixelSize: App.Theme.fontSizeM
                                font.weight: Font.Bold
                            }

                            GridLayout {
                                columns: 2
                                columnSpacing: App.Theme.spacingM
                                rowSpacing: App.Theme.spacingS
                                width: parent.width

                                MetricDisplay {
                                    label: "ALTURA"
                                    value: analysisController.currentTelemetry.height ? analysisController.currentTelemetry.height.toFixed(2) : "0.00"
                                    unit: "m"
                                    valueColor: App.Theme.dataAltitude
                                }
                                MetricDisplay {
                                    label: "VELOCIDAD"
                                    value: analysisController.currentTelemetry.speed ? analysisController.currentTelemetry.speed.toFixed(2) : "0.00"
                                    unit: "m/s"
                                    valueColor: App.Theme.dataSpeed
                                }
                                MetricDisplay {
                                    label: "BATERÍA"
                                    value: analysisController.currentTelemetry.battery ? analysisController.currentTelemetry.battery.toFixed(1) : "0.0"
                                    unit: "%"
                                    valueColor: analysisController.currentTelemetry.battery > 30 ? App.Theme.dataBattery : App.Theme.accentRed
                                }
                                MetricDisplay {
                                    label: "SLAM"
                                    value: analysisController.currentTelemetry.slam_quality ? analysisController.currentTelemetry.slam_quality.toFixed(0) : "0"
                                    unit: "%"
                                    valueColor: analysisController.currentTelemetry.slam_quality > 80 ? App.Theme.accentGreen : App.Theme.accentYellow
                                }
                            }
                        }
                    }
                    
                    // Sensores de Gas compacto
                    Card {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 230
                        Layout.fillHeight: false
                        clip: true

                        Column {
                            id: gasColCompact
                            anchors.fill: parent
                            anchors.margins: App.Theme.spacingM
                            spacing: App.Theme.spacingS

                            Text {
                                text: "💨 Gases"
                                color: App.Theme.textPrimary
                                font.pixelSize: App.Theme.fontSizeM
                                font.weight: Font.Bold
                            }

                            // CH4
                            Column {
                                width: parent.width
                                spacing: 2

                                RowLayout {
                                    width: parent.width

                                    Text {
                                        text: "CH₄"
                                        color: App.Theme.textSecondary
                                        font.pixelSize: App.Theme.fontSizeXs
                                    }

                                    Item { Layout.fillWidth: true }

                                    Text {
                                        text: (analysisController.currentTelemetry.ch4 ? analysisController.currentTelemetry.ch4.toFixed(2) : "0.00") + " % LEL"
                                        color: App.Theme.dataCH4
                                        font.family: App.Theme.fontMono
                                        font.pixelSize: App.Theme.fontSizeS
                                        font.weight: Font.Bold
                                    }
                                }

                                Rectangle {
                                    width: parent.width
                                    height: 24
                                    color: App.Theme.bgTertiary
                                    radius: App.Theme.radiusS

                                    Sparkline {
                                        anchors.fill: parent
                                        anchors.margins: 3
                                        lineColor: App.Theme.dataCH4
                                        minValue: 0
                                        maxValue: 2
                                        data: {
                                            var sparkData = analysisController.getSparklineData()
                                            var result = []
                                            for (var i = 0; i < sparkData.length; i++) {
                                                result.push(sparkData[i].ch4)
                                            }
                                            return result
                                        }
                                    }
                                }
                            }

                            // CO
                            Column {
                                width: parent.width
                                spacing: 2

                                RowLayout {
                                    width: parent.width

                                    Text {
                                        text: "CO"
                                        color: App.Theme.textSecondary
                                        font.pixelSize: App.Theme.fontSizeXs
                                    }

                                    Item { Layout.fillWidth: true }

                                    Text {
                                        text: (analysisController.currentTelemetry.co ? analysisController.currentTelemetry.co.toFixed(1) : "0.0") + " ppm"
                                        color: App.Theme.dataCO
                                        font.family: App.Theme.fontMono
                                        font.pixelSize: App.Theme.fontSizeS
                                        font.weight: Font.Bold
                                    }
                                }

                                Rectangle {
                                    width: parent.width
                                    height: 24
                                    color: App.Theme.bgTertiary
                                    radius: App.Theme.radiusS

                                    Sparkline {
                                        anchors.fill: parent
                                        anchors.margins: 3
                                        lineColor: App.Theme.dataCO
                                        minValue: 0
                                        maxValue: 30
                                        data: {
                                            var sparkData = analysisController.getSparklineData()
                                            var result = []
                                            for (var i = 0; i < sparkData.length; i++) {
                                                result.push(sparkData[i].co)
                                            }
                                            return result
                                        }
                                    }
                                }
                            }
                            // H2S
                            Column {
                                width: parent.width
                                spacing: 2

                                RowLayout {
                                    width: parent.width

                                    Text {
                                        text: "H₂S"
                                        color: App.Theme.textSecondary
                                        font.pixelSize: App.Theme.fontSizeXs
                                    }

                                    Item { Layout.fillWidth: true }

                                    Text {
                                        text: (analysisController.currentTelemetry.h2s ? analysisController.currentTelemetry.h2s.toFixed(2) : "0.00") + " ppm"
                                        color: App.Theme.accentYellow   // o el color que quieras
                                        font.family: App.Theme.fontMono
                                        font.pixelSize: App.Theme.fontSizeS
                                        font.weight: Font.Bold
                                    }
                                }

                                Rectangle {
                                    width: parent.width
                                    height: 24
                                    color: App.Theme.bgTertiary
                                    radius: App.Theme.radiusS

                                    Sparkline {
                                        anchors.fill: parent
                                        anchors.margins: 3
                                        lineColor: App.Theme.accentYellow
                                        minValue: 0
                                        maxValue: 10
                                        data: {
                                            var sparkData = analysisController.getSparklineData()
                                            var result = []
                                            for (var i = 0; i < sparkData.length; i++) {
                                                result.push(sparkData[i].h2s)
                                            }
                                            return result
                                        }
                                    }
                                }
                            }
                                
                            // O2
                            Column {
                                width: parent.width
                                spacing: 2

                                RowLayout {
                                    width: parent.width

                                    Text {
                                        text: "O₂"
                                        color: App.Theme.textSecondary
                                        font.pixelSize: App.Theme.fontSizeXs
                                    }

                                    Item { Layout.fillWidth: true }

                                    Text {
                                        text: (analysisController.currentTelemetry.o2 ? analysisController.currentTelemetry.o2.toFixed(1) : "0.0") + " %"
                                        color: App.Theme.dataO2
                                        font.family: App.Theme.fontMono
                                        font.pixelSize: App.Theme.fontSizeS
                                        font.weight: Font.Bold
                                    }
                                }

                                Rectangle {
                                    width: parent.width
                                    height: 24
                                    color: App.Theme.bgTertiary
                                    radius: App.Theme.radiusS

                                    Sparkline {
                                        anchors.fill: parent
                                        anchors.margins: 3
                                        lineColor: App.Theme.dataO2
                                        minValue: 19
                                        maxValue: 22
                                        data: {
                                            var sparkData = analysisController.getSparklineData()
                                            var result = []
                                            for (var i = 0; i < sparkData.length; i++) {
                                                result.push(sparkData[i].o2)
                                            }
                                            return result
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Evento Seleccionado
                    Card {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 200
                        Layout.fillHeight: false

                        visible: analysisController.selectedEvent !== null
                        border.color: analysisController.selectedEvent ? App.Theme.typeColor(analysisController.selectedEvent.type) : App.Theme.borderMuted

                        ScrollView {
                            anchors.fill: parent
                            anchors.margins: App.Theme.spacingM
                            clip: true

                            Column {
                                width: parent.parent.width - App.Theme.spacingM * 2
                                spacing: App.Theme.spacingS

                                RowLayout {
                                    width: parent.width

                                    Text {
                                        text: "🎯 Evento"
                                        color: App.Theme.textPrimary
                                        font.pixelSize: App.Theme.fontSizeM
                                        font.weight: Font.Bold
                                    }

                                    Item { Layout.fillWidth: true }

                                    Rectangle {
                                        width: 22
                                        height: 22
                                        radius: App.Theme.radiusS
                                        color: closeMouse.containsMouse ? App.Theme.bgCardHover : "transparent"

                                        Text {
                                            anchors.centerIn: parent
                                            text: "✕"
                                            color: App.Theme.textTertiary
                                            font.pixelSize: 12
                                        }

                                        MouseArea {
                                            id: closeMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: analysisController.clearEventSelection()
                                        }
                                    }
                                }

                                RowLayout {
                                    width: parent.width
                                    visible: analysisController.selectedEvent !== null

                                    Rectangle {
                                        width: 36
                                        height: 36
                                        radius: App.Theme.radiusM
                                        color: analysisController.selectedEvent ? Qt.rgba(App.Theme.typeColor(analysisController.selectedEvent.type).r, App.Theme.typeColor(analysisController.selectedEvent.type).g, App.Theme.typeColor(analysisController.selectedEvent.type).b, 0.2) : "transparent"

                                        Text {
                                            anchors.centerIn: parent
                                            text: analysisController.selectedEvent ? App.Theme.typeIcon(analysisController.selectedEvent.type) : ""
                                            font.pixelSize: 18
                                        }
                                    }

                                    Column {
                                        Layout.fillWidth: true
                                        spacing: 2

                                        Text {
                                            text: analysisController.selectedEvent ? analysisController.selectedEvent.title : ""
                                            color: App.Theme.textPrimary
                                            font.pixelSize: App.Theme.fontSizeS
                                            font.weight: Font.Bold
                                            wrapMode: Text.WordWrap
                                            width: parent.width
                                        }

                                        Text {
                                            text: analysisController.selectedEvent ? analysisController.selectedEvent.id : ""
                                            color: App.Theme.textTertiary
                                            font.family: App.Theme.fontMono
                                            font.pixelSize: 9
                                        }
                                    }

                                    StatusBadge {
                                        severity: analysisController.selectedEvent ? analysisController.selectedEvent.severity : "info"
                                        label: analysisController.selectedEvent ? analysisController.getSeverityLabel(analysisController.selectedEvent.severity) : ""
                                    }
                                }

                                Rectangle {
                                    width: parent.width
                                    height: 1
                                    color: App.Theme.borderMuted
                                }

                                Text {
                                    text: analysisController.selectedEvent ? analysisController.selectedEvent.description : ""
                                    color: App.Theme.textSecondary
                                    font.pixelSize: App.Theme.fontSizeXs
                                    wrapMode: Text.WordWrap
                                    width: parent.width
                                }

                                GridLayout {
                                    columns: 2
                                    columnSpacing: App.Theme.spacingM
                                    rowSpacing: 2

                                    Text { text: "Tiempo:"; color: App.Theme.textTertiary; font.pixelSize: 10 }
                                    Text {
                                        text: analysisController.selectedEvent ? analysisController.formatTime(analysisController.selectedEvent.timestamp) : ""
                                        color: App.Theme.textPrimary
                                        font.family: App.Theme.fontMono
                                        font.pixelSize: App.Theme.fontSizeXs
                                    }

                                    Text { text: "Posición:"; color: App.Theme.textTertiary; font.pixelSize: 10 }
                                    Text {
                                        text: analysisController.selectedEvent ? analysisController.selectedEvent.position.toFixed(1) + " m" : ""
                                        color: App.Theme.textPrimary
                                        font.family: App.Theme.fontMono
                                        font.pixelSize: App.Theme.fontSizeXs
                                    }
                                }

                                // Imagen placeholder
                                Rectangle {
                                    width: parent.width
                                    height: 70
                                    radius: App.Theme.radiusM
                                    color: App.Theme.bgTertiary
                                    border.width: 1
                                    border.color: App.Theme.borderMuted

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 2

                                        Text {
                                            text: "📷"
                                            font.pixelSize: 20
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }

                                        Text {
                                            text: "Imagen capturada"
                                            color: App.Theme.textTertiary
                                            font.pixelSize: 9
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                    }
                                }

                                // Recomendación
                                Rectangle {
                                    width: parent.width
                                    height: recomCol.height + App.Theme.spacingS * 2
                                    radius: App.Theme.radiusM
                                    color: App.Theme.statusInfoBg
                                    border.width: 1
                                    border.color: App.Theme.statusInfo

                                    Column {
                                        id: recomCol
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.top: parent.top
                                        anchors.margins: App.Theme.spacingS
                                        spacing: 2

                                        Text {
                                            text: "💡 Recomendación"
                                            color: App.Theme.statusInfo
                                            font.pixelSize: 10
                                            font.weight: Font.Bold
                                        }

                                        Text {
                                            text: analysisController.selectedEvent ? analysisController.selectedEvent.recommendation : ""
                                            color: App.Theme.textPrimary
                                            font.pixelSize: App.Theme.fontSizeXs
                                            wrapMode: Text.WordWrap
                                            width: parent.width
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Placeholder sin evento
                    Card {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 200
                        Layout.fillHeight: false
                        visible: analysisController.selectedEvent === null
                        Column {
                            anchors.centerIn: parent
                            spacing: App.Theme.spacingS

                            Text {
                                text: "👆"
                                font.pixelSize: 28
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: "Selecciona un evento"
                                color: App.Theme.textSecondary
                                font.pixelSize: App.Theme.fontSizeS
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: "de la lista o del mapa"
                                color: App.Theme.textTertiary
                                font.pixelSize: App.Theme.fontSizeXs
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }
            }
        }

        // BARRA INFERIOR
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            color: App.Theme.bgTertiary

            Rectangle {
                anchors.top: parent.top
                width: parent.width
                height: 1
                color: App.Theme.borderMuted
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: App.Theme.spacingL
                anchors.rightMargin: App.Theme.spacingL
                spacing: App.Theme.spacingM

                Row {
                    spacing: App.Theme.spacingL

                    Row {
                        spacing: 4
                        Text { text: "📊"; font.pixelSize: 11 }
                        Text { text: "Cobertura:"; color: App.Theme.textTertiary; font.pixelSize: 10 }
                        Text {
                            text: analysisController.missionStats.coverage_percent + "%"
                            color: App.Theme.accentGreen
                            font.family: App.Theme.fontMono
                            font.pixelSize: 11
                            font.weight: Font.Bold
                        }
                    }

                    Row {
                        spacing: 4
                        Text { text: "✓"; font.pixelSize: 11 }
                        Text { text: "Calidad:"; color: App.Theme.textTertiary; font.pixelSize: 10 }
                        Text {
                            text: analysisController.missionStats.data_quality + "%"
                            color: App.Theme.accentGreen
                            font.family: App.Theme.fontMono
                            font.pixelSize: 11
                            font.weight: Font.Bold
                        }
                    }

                    Row {
                        spacing: 4
                        Text { text: "🔋"; font.pixelSize: 11 }
                        Text { text: "Batería:"; color: App.Theme.textTertiary; font.pixelSize: 10 }
                        Text {
                            text: analysisController.missionStats.battery_start + "% → " + analysisController.missionStats.battery_end + "%"
                            color: App.Theme.textSecondary
                            font.family: App.Theme.fontMono
                            font.pixelSize: 11
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                Row {
                    spacing: App.Theme.spacingS

                    StyledButton {
                        text: "Exportar PDF"
                        icon: "📄"
                        onClicked: analysisController.exportToPDF()
                    }

                    StyledButton {
                        text: "Exportar HTML"
                        icon: "🌐"
                        onClicked: analysisController.exportToHTML()
                    }

                    StyledButton {
                        text: "Compartir"
                        icon: "🔗"
                        primary: true
                        onClicked: analysisController.shareReport()
                    }
                }
            }
        }
    }
}
