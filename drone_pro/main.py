"""
Sistema de Inspección con Dron para Túneles Mineros
Interfaz de Configuración de Misión - Versión Completa

Tesis: DISEÑO DE UN SISTEMA AUTÓNOMO DE INSPECCIÓN CON UN DRON AÉREO 
       PARA LA DETECCIÓN DE GRIETAS Y GASES EN TÚNELES MINEROS SUBTERRÁNEOS
"""

import sys
import random
from pathlib import Path

from PyQt6.QtWidgets import QApplication
from PyQt6.QtQml import QQmlApplicationEngine
from PyQt6.QtCore import QObject, pyqtSignal, pyqtSlot, pyqtProperty, QUrl, QtMsgType, qInstallMessageHandler, QTimer


class MissionController(QObject):
    """Controlador principal para la lógica de la misión"""
    
    checklistUpdated = pyqtSignal()
    missionConfigUpdated = pyqtSignal()
    simulationUpdated = pyqtSignal()
    waypointsUpdated = pyqtSignal()
    
    def __init__(self):
        super().__init__()
        
        # Estado del checklist pre-misión
        self._checklist = [
            {'id': 'battery', 'icon': '🔋', 'label': 'Batería', 'status': 'ok', 'value': 87, 'detail': '14:30 min autonomía', 'unit': '%'},
            {'id': 'camera', 'icon': '📷', 'label': 'Cámara 4K', 'status': 'ok', 'value': 'Operativa', 'detail': 'Última cal: 2h', 'unit': ''},
            {'id': 'lidar', 'icon': '📡', 'label': 'LiDAR', 'status': 'ok', 'value': 'Operativo', 'detail': 'Última cal: 2h', 'unit': ''},
            {'id': 'imu', 'icon': '🧭', 'label': 'IMU/Giroscopio', 'status': 'warning', 'value': 'Calibrar', 'detail': 'Última cal: 48h', 'unit': ''},
            {'id': 'gas_ch4', 'icon': '💨', 'label': 'Sensor CH₄', 'status': 'ok', 'value': 0.2, 'detail': 'Pre-cal OK', 'unit': '% LEL'},
            {'id': 'gas_co', 'icon': '💨', 'label': 'Sensor CO', 'status': 'ok', 'value': 3, 'detail': 'Pre-cal OK', 'unit': 'ppm'},
            {'id': 'gas_o2', 'icon': '💨', 'label': 'Sensor O₂', 'status': 'ok', 'value': 20.9, 'detail': 'Pre-cal OK', 'unit': '%'},
            {'id': 'slam', 'icon': '🗺', 'label': 'Sistema SLAM', 'status': 'ok', 'value': 94, 'detail': 'Mapa cargado', 'unit': '% calidad'},
            {'id': 'comms', 'icon': '📶', 'label': 'Comunicaciones', 'status': 'ok', 'value': -52, 'detail': 'Latencia: 38ms', 'unit': 'dBm'},
            {'id': 'storage', 'icon': '💾', 'label': 'Almacenamiento', 'status': 'ok', 'value': 73, 'detail': '64 GB libres', 'unit': 'GB usado'},
            {'id': 'motors', 'icon': '⚙', 'label': 'Motores', 'status': 'ok', 'value': 'Test OK', 'detail': '4/4 operativos', 'unit': ''},
            {'id': 'lights', 'icon': '💡', 'label': 'Iluminación', 'status': 'ok', 'value': 'Lista', 'detail': '2400 lúmenes', 'unit': ''},
        ]
        
        # Configuración de misión
        self._missionConfig = {
            'preset': 'cracks',
            'speed': 0.3,
            'maxHeight': 3.0,
            'maxTime': 20,
            'maxDistance': 500,
            'explorationStrategy': 'follow_tunnel',  # follow_tunnel, round_trip, sweep, point_inspect
            'riskBehavior': 'return_base',  # return_base, hover, mark_continue, alert_only
            'lightingMode': 'auto',  # auto, manual, adaptive
            'lightingIntensity': 75,
            'collisionMargin': 1.5,  # metros
            'hoverAltitude': 2.5,  # metros
        }
        
        # Configuración de detección
        self._detectionConfig = {
            'gasPreAlarm': 1.0,
            'gasAlarm': 2.5,
            'coPreAlarm': 15,
            'coAlarm': 25,
            'o2Min': 19.5,
            'crackSensitivity': 'high',  # high, balanced, low_fp
            'crackMinWidth': 2,  # mm
            'minConfidence': 0.75,
            'samplingRate': 10,  # Hz
            'thermalEnabled': True,
            'autoClassify': True,
        }
        
        # Waypoints del túnel (posición relativa 0-100)
        self._waypoints = [
            {'id': 0, 'x': 5, 'y': 50, 'type': 'start', 'label': 'Inicio'},
            {'id': 1, 'x': 20, 'y': 48, 'type': 'waypoint', 'label': 'WP1'},
            {'id': 2, 'x': 35, 'y': 52, 'type': 'inspection', 'label': 'Insp. Grieta'},
            {'id': 3, 'x': 50, 'y': 50, 'type': 'waypoint', 'label': 'WP2'},
            {'id': 4, 'x': 65, 'y': 45, 'type': 'gas_check', 'label': 'Zona Gas'},
            {'id': 5, 'x': 80, 'y': 50, 'type': 'waypoint', 'label': 'WP3'},
            {'id': 6, 'x': 95, 'y': 50, 'type': 'end', 'label': 'Fin'},
        ]
        
        # Zonas restringidas
        self._restrictedZones = [
            {'x': 42, 'y': 30, 'width': 16, 'height': 15, 'reason': 'Derrumbe parcial'},
        ]
        
        # Resultados de simulación
        self._simulation = {
            'duration': '18:24',
            'durationSeconds': 1104,
            'coverage': 487,
            'coveragePercent': 97.4,
            'batteryStart': 87,
            'batteryEnd': 42,
            'batteryConsumption': 45,
            'riskLevel': 'medium',
            'riskScore': 58,
            'estimatedFindings': 3,
            'routeSegments': [
                {'from': 'Inicio', 'to': 'WP1', 'distance': 85, 'time': '2:45', 'risk': 'low'},
                {'from': 'WP1', 'to': 'Insp. Grieta', 'distance': 72, 'time': '3:20', 'risk': 'low'},
                {'from': 'Insp. Grieta', 'to': 'WP2', 'distance': 68, 'time': '2:50', 'risk': 'medium'},
                {'from': 'WP2', 'to': 'Zona Gas', 'distance': 78, 'time': '3:15', 'risk': 'high'},
                {'from': 'Zona Gas', 'to': 'WP3', 'distance': 82, 'time': '3:24', 'risk': 'medium'},
                {'from': 'WP3', 'to': 'Fin', 'distance': 102, 'time': '2:50', 'risk': 'low'},
            ]
        }
        
        # Información del sector
        self._sectorInfo = {
            'name': 'Sector A - Galería Principal',
            'level': '-240m',
            'length': 520,
            'lastInspection': '15 Ene 2026',
            'pendingAlerts': 2,
            'temperature': 24,
            'humidity': 78,
        }
    
    # ===== PROPIEDADES =====
    
    @pyqtProperty('QVariant', notify=checklistUpdated)
    def checklist(self):
        return self._checklist
    
    @pyqtProperty('QVariant', notify=missionConfigUpdated)
    def missionConfig(self):
        return self._missionConfig
    
    @pyqtProperty('QVariant', notify=missionConfigUpdated)
    def detectionConfig(self):
        return self._detectionConfig
    
    @pyqtProperty('QVariant', notify=simulationUpdated)
    def simulation(self):
        return self._simulation
    
    @pyqtProperty('QVariant', notify=waypointsUpdated)
    def waypoints(self):
        return self._waypoints
    
    @pyqtProperty('QVariant', notify=waypointsUpdated)
    def restrictedZones(self):
        return self._restrictedZones
    
    @pyqtProperty('QVariant', constant=True)
    def sectorInfo(self):
        return self._sectorInfo
    
    # ===== SLOTS =====
    
    @pyqtSlot(result=bool)
    def isReadyToStart(self):
        errors = sum(1 for item in self._checklist if item['status'] == 'error')
        return errors == 0
    
    @pyqtSlot(result=int)
    def getWarningCount(self):
        return sum(1 for item in self._checklist if item['status'] == 'warning')
    
    @pyqtSlot(result=int)
    def getErrorCount(self):
        return sum(1 for item in self._checklist if item['status'] == 'error')
    
    @pyqtSlot(result=int)
    def getOkCount(self):
        return sum(1 for item in self._checklist if item['status'] == 'ok')
    
    @pyqtSlot(str, 'QVariant')
    def setMissionParam(self, param, value):
        if param in self._missionConfig:
            self._missionConfig[param] = value
            self.missionConfigUpdated.emit()
            self._updateSimulation()
    
    @pyqtSlot(str, 'QVariant')
    def setDetectionParam(self, param, value):
        if param in self._detectionConfig:
            self._detectionConfig[param] = value
            self.missionConfigUpdated.emit()
    
    @pyqtSlot(str)
    def selectPreset(self, preset):
        self._missionConfig['preset'] = preset
        
        if preset == 'cracks':
            self._missionConfig['speed'] = 0.25
            self._missionConfig['lightingIntensity'] = 100
            self._missionConfig['hoverAltitude'] = 2.0
            self._detectionConfig['crackSensitivity'] = 'high'
            self._detectionConfig['samplingRate'] = 15
            self._detectionConfig['minConfidence'] = 0.70
        elif preset == 'gases':
            self._missionConfig['speed'] = 0.6
            self._missionConfig['lightingIntensity'] = 50
            self._missionConfig['hoverAltitude'] = 3.0
            self._detectionConfig['samplingRate'] = 20
            self._detectionConfig['minConfidence'] = 0.80
        elif preset == 'full':
            self._missionConfig['speed'] = 0.4
            self._missionConfig['lightingIntensity'] = 80
            self._missionConfig['hoverAltitude'] = 2.5
            self._detectionConfig['crackSensitivity'] = 'balanced'
            self._detectionConfig['samplingRate'] = 12
        
        self.missionConfigUpdated.emit()
        self._updateSimulation()
    
    @pyqtSlot(str)
    def setExplorationStrategy(self, strategy):
        self._missionConfig['explorationStrategy'] = strategy
        self.missionConfigUpdated.emit()
        self._updateSimulation()
    
    @pyqtSlot(str)
    def setRiskBehavior(self, behavior):
        self._missionConfig['riskBehavior'] = behavior
        self.missionConfigUpdated.emit()
    
    @pyqtSlot(str)
    def setCrackSensitivity(self, sensitivity):
        self._detectionConfig['crackSensitivity'] = sensitivity
        self.missionConfigUpdated.emit()
    
    @pyqtSlot()
    def runSimulation(self):
        self._updateSimulation()
    
    @pyqtSlot()
    def startMission(self):
        print("=" * 60)
        print("           INICIANDO MISIÓN DE INSPECCIÓN")
        print("=" * 60)
        print(f"Sector: {self._sectorInfo['name']}")
        print(f"Preset: {self._missionConfig['preset']}")
        print(f"Velocidad: {self._missionConfig['speed']} m/s")
        print(f"Tiempo máximo: {self._missionConfig['maxTime']} min")
        print(f"Estrategia: {self._missionConfig['explorationStrategy']}")
        print(f"Waypoints: {len(self._waypoints)}")
        print("=" * 60)
    
    @pyqtSlot(str)
    def calibrateSystem(self, systemId):
        for item in self._checklist:
            if item['id'] == systemId and item['status'] == 'warning':
                item['status'] = 'ok'
                item['value'] = 'Calibrado'
                item['detail'] = 'Recién calibrado'
                self.checklistUpdated.emit()
                break
    
    def _updateSimulation(self):
        speed = self._missionConfig['speed']
        maxTime = self._missionConfig['maxTime']
        maxDistance = self._missionConfig['maxDistance']
        batteryStart = self._checklist[0]['value']
        
        # Calcular cobertura
        theoretical_coverage = speed * maxTime * 60
        actual_coverage = min(theoretical_coverage * 0.85, maxDistance)
        coverage_percent = (actual_coverage / self._sectorInfo['length']) * 100
        
        # Calcular duración
        if speed > 0:
            duration_seconds = int(actual_coverage / speed)
        else:
            duration_seconds = maxTime * 60
        duration_seconds = min(duration_seconds, maxTime * 60)
        duration_min = duration_seconds // 60
        duration_sec = duration_seconds % 60
        
        # Calcular batería
        base_consumption = duration_seconds / 60 * 2.2
        speed_factor = 1 + (speed - 0.3) * 0.5
        light_factor = 1 + (self._missionConfig['lightingIntensity'] - 50) / 200
        total_consumption = base_consumption * speed_factor * light_factor
        battery_end = max(10, batteryStart - total_consumption)
        
        # Calcular riesgo
        risk_score = 20
        if battery_end < 30:
            risk_score += 30
        elif battery_end < 50:
            risk_score += 15
        
        if maxDistance > 400:
            risk_score += 20
        elif maxDistance > 300:
            risk_score += 10
        
        if speed > 0.8:
            risk_score += 15
        
        if len(self._restrictedZones) > 0:
            risk_score += 10
        
        risk_score = min(100, risk_score)
        
        if risk_score < 35:
            risk_level = 'low'
        elif risk_score < 65:
            risk_level = 'medium'
        else:
            risk_level = 'high'
        
        self._simulation = {
            'duration': f"{duration_min}:{duration_sec:02d}",
            'durationSeconds': duration_seconds,
            'coverage': int(actual_coverage),
            'coveragePercent': round(coverage_percent, 1),
            'batteryStart': batteryStart,
            'batteryEnd': int(battery_end),
            'batteryConsumption': int(batteryStart - battery_end),
            'riskLevel': risk_level,
            'riskScore': risk_score,
            'estimatedFindings': random.randint(2, 6),
            'routeSegments': self._simulation.get('routeSegments', [])
        }
        
        self.simulationUpdated.emit()


def qt_message_handler(msg_type, context, message):
    if msg_type in [QtMsgType.QtWarningMsg, QtMsgType.QtCriticalMsg, QtMsgType.QtFatalMsg]:
        if "white-space" not in message.lower() and "accessible" not in message.lower():
            print(f"[QML] {message}")


def main():
    qInstallMessageHandler(qt_message_handler)
    
    app = QApplication(sys.argv)
    app.setApplicationName("DroneMineTunnel - Configuración de Misión")
    app.setOrganizationName("Tesis UAV Mining")
    
    engine = QQmlApplicationEngine()
    
    basedir = Path(__file__).parent.resolve()
    qml_dir = basedir / "qml"
    main_qml = qml_dir / "Main.qml"
    
    print(f"[INFO] Cargando interfaz desde: {main_qml}")
    
    engine.addImportPath(str(qml_dir))
    
    controller = MissionController()
    engine.rootContext().setContextProperty("missionController", controller)
    
    engine.load(QUrl.fromLocalFile(str(main_qml)))
    
    if not engine.rootObjects():
        print("[ERROR] No se pudo cargar la interfaz")
        sys.exit(-1)
    
    print("[OK] Interfaz cargada correctamente")
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
