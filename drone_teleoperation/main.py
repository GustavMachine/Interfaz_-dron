"""
Interfaz de Teleoperación - Sistema de Inspección Autónoma con Dron
Thesis: Diseño de un sistema autónomo de inspección con un dron aéreo
        para la detección de grietas y gases en túneles mineros subterráneos

Interfaz #2: Teleoperación del Dron
"""

import sys
import math
import random

from pathlib import Path
from datetime import datetime

from PyQt6.QtWidgets import QApplication
from PyQt6.QtQml import QQmlApplicationEngine, qmlRegisterType
from PyQt6.QtCore import QObject, pyqtSignal, pyqtSlot, pyqtProperty, QTimer, QUrl, QtMsgType, qInstallMessageHandler


# Handler para capturar mensajes de Qt/QML
def qt_message_handler(mode, context, message):
    if mode == QtMsgType.QtInfoMsg:
        print(f"[INFO] {message}")
    elif mode == QtMsgType.QtWarningMsg:
        print(f"[WARNING] {message}")
    elif mode == QtMsgType.QtCriticalMsg:
        print(f"[CRITICAL] {message}")
    elif mode == QtMsgType.QtFatalMsg:
        print(f"[FATAL] {message}")
    else:
        print(f"[DEBUG] {message}")


class DroneState(QObject):
    """Estado del dron en tiempo real"""
    
    def __init__(self):
        super().__init__()
        
        # Estado de vuelo
        self._is_connected = True
        self._is_armed = False
        self._is_flying = False
        self._flight_mode = "MANUAL"  # MANUAL, ASSISTED, AUTO
        
        # Posición y orientación
        self._position = {"x": 0.0, "y": 0.0, "z": 1.5}
        self._velocity = {"vx": 0.0, "vy": 0.0, "vz": 0.0}
        self._orientation = {"roll": 0.0, "pitch": 0.0, "yaw": 45.0}
        
        # Telemetría crítica
        self._battery = 87.0
        self._signal_strength = 92
        self._latency = 45  # ms
        self._slam_confidence = 94.0
        self._gps_satellites = 0  # En túnel no hay GPS
        
        # Distancias a obstáculos (cm)
        self._obstacle_front = 245
        self._obstacle_back = 380
        self._obstacle_left = 120
        self._obstacle_right = 185
        self._obstacle_top = 95
        self._obstacle_bottom = 150
        
        # Temperaturas
        self._temp_motor1 = 42.0
        self._temp_motor2 = 44.0
        self._temp_motor3 = 43.0
        self._temp_motor4 = 45.0
        self._temp_controller = 38.0
        self._temp_battery = 32.0
        
        # Sensores de gas
        self._ch4 = 0.35
        self._co = 4.2
        self._o2 = 20.8
        self._h2s = 2.5
        
        # Modos asistidos
        self._altitude_hold = True
        self._speed_limiter = True
        self._auto_brake = True
        self._collision_avoidance = True
        
        # Cámara
        self._camera_recording = False
        self._camera_profile = "normal"  # low_light, high_clarity, anti_noise, normal
        self._exposure_lock = False
        self._camera_tilt = 0  # -90 a +30 grados
        
        # Controles
        self._control_mode = "keyboard"  # keyboard, joystick
        self._sensitivity = "normal"  # soft, normal, aggressive
        self._precision_mode = False
        
        # Misión
        self._mission_time = 0  # segundos
        self._distance_traveled = 0.0
        self._events_marked = []


class TeleoperationController(QObject):
    """Controlador principal de teleoperación"""
    
    # Señales
    stateChanged = pyqtSignal()
    telemetryUpdated = pyqtSignal()
    alertTriggered = pyqtSignal(str, str)  # tipo, mensaje
    eventMarked = pyqtSignal(str)  # tipo de evento
    emergencyActivated = pyqtSignal(str)  # tipo de emergencia
    
    def __init__(self):
        super().__init__()
        self._state = DroneState()
        self._alerts = []
        self._events = []
        
        # Timer para simular telemetría en tiempo real
        self._telemetry_timer = QTimer()
        self._telemetry_timer.timeout.connect(self._update_telemetry)
        self._telemetry_timer.start(100)  # 10 Hz
        
        # Timer para tiempo de misión
        self._mission_timer = QTimer()
        self._mission_timer.timeout.connect(self._update_mission_time)
        self._mission_timer.start(1000)  # 1 Hz
    
    def _update_telemetry(self):
        """Actualizar telemetría simulada"""
        # Simular pequeñas variaciones
        self._state._battery = max(0, self._state._battery - 0.001)
        self._state._signal_strength = max(0, min(100, self._state._signal_strength + random.uniform(-2, 2)))
        self._state._latency = max(20, min(200, self._state._latency + random.uniform(-5, 5)))
        self._state._slam_confidence = max(60, min(100, self._state._slam_confidence + random.uniform(-1, 1)))
        
        # Variaciones de temperatura
        self._state._temp_motor1 = max(30, min(70, self._state._temp_motor1 + random.uniform(-0.5, 0.5)))
        self._state._temp_motor2 = max(30, min(70, self._state._temp_motor2 + random.uniform(-0.5, 0.5)))
        self._state._temp_motor3 = max(30, min(70, self._state._temp_motor3 + random.uniform(-0.5, 0.5)))
        self._state._temp_motor4 = max(30, min(70, self._state._temp_motor4 + random.uniform(-0.5, 0.5)))
        
        # Variaciones de distancia a obstáculos
        self._state._obstacle_front = max(30, min(500, self._state._obstacle_front + random.uniform(-10, 10)))
        self._state._obstacle_left = max(30, min(300, self._state._obstacle_left + random.uniform(-5, 5)))
        self._state._obstacle_right = max(30, min(300, self._state._obstacle_right + random.uniform(-5, 5)))
        
        # Gases
        self._state._ch4 = max(0, min(5, self._state._ch4 + random.uniform(-0.05, 0.05)))
        self._state._co = max(0, min(50, self._state._co + random.uniform(-0.2, 0.2)))
        self._state._o2 = max(18, min(22, self._state._o2 + random.uniform(-0.1, 0.1)))
        self._state._h2s = max(0, min(20, self._state._h2s + random.uniform(-0.3, 0.3)))
        
        # Orientación (simular pequeños movimientos)
        if self._state._is_flying:
            self._state._orientation["roll"] = max(-15, min(15, self._state._orientation["roll"] + random.uniform(-1, 1)))
            self._state._orientation["pitch"] = max(-15, min(15, self._state._orientation["pitch"] + random.uniform(-1, 1)))
        
        # Verificar alertas
        self._check_alerts()
        
        self.telemetryUpdated.emit()
    
    def _update_mission_time(self):
        """Actualizar tiempo de misión"""
        if self._state._is_flying:
            self._state._mission_time += 1
            self._state._distance_traveled += random.uniform(0.1, 0.5)
        self.stateChanged.emit()
    
    def _check_alerts(self):
        """Verificar condiciones de alerta"""
        new_alerts = []
        
        # Batería baja
        if self._state._battery < 20:
            new_alerts.append({"type": "critical", "message": "Batería crítica < 20%"})
        elif self._state._battery < 30:
            new_alerts.append({"type": "warning", "message": "Batería baja < 30%"})
        
        # Latencia alta
        if self._state._latency > 150:
            new_alerts.append({"type": "critical", "message": "Latencia crítica > 150ms"})
        elif self._state._latency > 100:
            new_alerts.append({"type": "warning", "message": "Latencia alta > 100ms"})
        
        # SLAM bajo
        if self._state._slam_confidence < 70:
            new_alerts.append({"type": "critical", "message": "Localización no confiable"})
        elif self._state._slam_confidence < 80:
            new_alerts.append({"type": "warning", "message": "SLAM degradado"})
        
        # Obstáculos cercanos
        if self._state._obstacle_front < 50:
            new_alerts.append({"type": "critical", "message": "¡Obstáculo frontal muy cercano!"})
        elif self._state._obstacle_front < 100:
            new_alerts.append({"type": "warning", "message": "Obstáculo frontal cercano"})
        
        # Temperatura alta
        max_temp = max(self._state._temp_motor1, self._state._temp_motor2, 
                       self._state._temp_motor3, self._state._temp_motor4)
        if max_temp > 65:
            new_alerts.append({"type": "critical", "message": "Temperatura motores crítica"})
        elif max_temp > 55:
            new_alerts.append({"type": "warning", "message": "Temperatura motores alta"})
        
        # Gas peligroso
        if self._state._ch4 > 1.0:
            new_alerts.append({"type": "critical", "message": "¡Nivel CH4 peligroso!"})
        if self._state._co > 25:
            new_alerts.append({"type": "critical", "message": "¡Nivel CO peligroso!"})
        if self._state._h2s > 10:
            new_alerts.append({"type": "critical", "message": "¡Nivel H2S peligroso!"})
        if self._state._o2 < 19.5:
            new_alerts.append({"type": "warning", "message": "Nivel O2 bajo"})
        
        self._alerts = new_alerts
    
    # ===== PROPIEDADES QML =====
    
    @pyqtProperty(bool, notify=stateChanged)
    def isConnected(self):
        return self._state._is_connected
    
    @pyqtProperty(bool, notify=stateChanged)
    def isArmed(self):
        return self._state._is_armed
    
    @pyqtProperty(bool, notify=stateChanged)
    def isFlying(self):
        return self._state._is_flying
    
    @pyqtProperty(str, notify=stateChanged)
    def flightMode(self):
        return self._state._flight_mode
    
    @pyqtProperty(float, notify=telemetryUpdated)
    def battery(self):
        return self._state._battery
    
    @pyqtProperty(int, notify=telemetryUpdated)
    def signalStrength(self):
        return int(self._state._signal_strength)
    
    @pyqtProperty(int, notify=telemetryUpdated)
    def latency(self):
        return int(self._state._latency)
    
    @pyqtProperty(str, notify=telemetryUpdated)
    def latencyLevel(self):
        if self._state._latency < 50:
            return "low"
        elif self._state._latency < 100:
            return "medium"
        else:
            return "high"
    
    @pyqtProperty(float, notify=telemetryUpdated)
    def slamConfidence(self):
        return self._state._slam_confidence
    
    @pyqtProperty('QVariant', notify=telemetryUpdated)
    def position(self):
        return self._state._position
    
    @pyqtProperty('QVariant', notify=telemetryUpdated)
    def velocity(self):
        return self._state._velocity
    
    @pyqtProperty('QVariant', notify=telemetryUpdated)
    def orientation(self):
        return self._state._orientation
    
    @pyqtProperty('QVariant', notify=telemetryUpdated)
    def obstacles(self):
        return {
            "front": self._state._obstacle_front,
            "back": self._state._obstacle_back,
            "left": self._state._obstacle_left,
            "right": self._state._obstacle_right,
            "top": self._state._obstacle_top,
            "bottom": self._state._obstacle_bottom
        }
    
    @pyqtProperty('QVariant', notify=telemetryUpdated)
    def temperatures(self):
        return {
            "motor1": self._state._temp_motor1,
            "motor2": self._state._temp_motor2,
            "motor3": self._state._temp_motor3,
            "motor4": self._state._temp_motor4,
            "controller": self._state._temp_controller,
            "battery": self._state._temp_battery
        }
    
    @pyqtProperty('QVariant', notify=telemetryUpdated)
    def gases(self):
        return {
            "ch4": self._state._ch4,
            "co": self._state._co,
            "o2": self._state._o2,
            "h2s": self._state._h2s
        }
    
    @pyqtProperty(bool, notify=stateChanged)
    def altitudeHold(self):
        return self._state._altitude_hold
    
    @pyqtProperty(bool, notify=stateChanged)
    def speedLimiter(self):
        return self._state._speed_limiter
    
    @pyqtProperty(bool, notify=stateChanged)
    def autoBrake(self):
        return self._state._auto_brake
    
    @pyqtProperty(bool, notify=stateChanged)
    def collisionAvoidance(self):
        return self._state._collision_avoidance
    
    @pyqtProperty(bool, notify=stateChanged)
    def cameraRecording(self):
        return self._state._camera_recording
    
    @pyqtProperty(str, notify=stateChanged)
    def cameraProfile(self):
        return self._state._camera_profile
    
    @pyqtProperty(bool, notify=stateChanged)
    def exposureLock(self):
        return self._state._exposure_lock
    
    @pyqtProperty(int, notify=stateChanged)
    def cameraTilt(self):
        return self._state._camera_tilt
    
    @pyqtProperty(str, notify=stateChanged)
    def controlMode(self):
        return self._state._control_mode
    
    @pyqtProperty(str, notify=stateChanged)
    def sensitivity(self):
        return self._state._sensitivity
    
    @pyqtProperty(bool, notify=stateChanged)
    def precisionMode(self):
        return self._state._precision_mode
    
    @pyqtProperty(int, notify=stateChanged)
    def missionTime(self):
        return self._state._mission_time
    
    @pyqtProperty(float, notify=stateChanged)
    def distanceTraveled(self):
        return self._state._distance_traveled
    
    @pyqtProperty('QVariant', notify=stateChanged)
    def alerts(self):
        return self._alerts
    
    @pyqtProperty('QVariant', notify=stateChanged)
    def markedEvents(self):
        return self._state._events_marked
    
    # ===== SLOTS - CONTROL DE VUELO =====
    
    @pyqtSlot()
    def arm(self):
        """Armar el dron"""
        if not self._state._is_armed:
            self._state._is_armed = True
            print("✓ Dron ARMADO")
            self.stateChanged.emit()
    
    @pyqtSlot()
    def disarm(self):
        """Desarmar el dron"""
        if self._state._is_armed and not self._state._is_flying:
            self._state._is_armed = False
            print("✓ Dron DESARMADO")
            self.stateChanged.emit()
    
    @pyqtSlot()
    def takeoff(self):
        """Despegar"""
        if self._state._is_armed and not self._state._is_flying:
            self._state._is_flying = True
            self._state._position["z"] = 1.5
            print("✓ DESPEGUE iniciado")
            self.stateChanged.emit()
    
    @pyqtSlot()
    def land(self):
        """Aterrizar"""
        if self._state._is_flying:
            self._state._is_flying = False
            self._state._position["z"] = 0.0
            print("✓ ATERRIZAJE iniciado")
            self.stateChanged.emit()
    
    @pyqtSlot(str)
    def setFlightMode(self, mode):
        """Cambiar modo de vuelo"""
        if mode in ["MANUAL", "ASSISTED", "AUTO"]:
            self._state._flight_mode = mode
            print(f"✓ Modo de vuelo: {mode}")
            self.stateChanged.emit()
    
    # ===== SLOTS - EMERGENCIAS =====
    
    @pyqtSlot()
    def emergencyStop(self):
        """Parada de emergencia"""
        print("="*60)
        print("🚨 EMERGENCY STOP ACTIVADO")
        print("="*60)
        self._state._is_flying = False
        self._state._is_armed = False
        self._state._velocity = {"vx": 0, "vy": 0, "vz": 0}
        self.emergencyActivated.emit("E-STOP")
        self.stateChanged.emit()
    
    @pyqtSlot()
    def hover(self):
        """Mantener posición (hover)"""
        print("✓ HOVER - Manteniendo posición")
        self._state._velocity = {"vx": 0, "vy": 0, "vz": 0}
        self.emergencyActivated.emit("HOVER")
        self.stateChanged.emit()
    
    @pyqtSlot()
    def returnToHome(self):
        """Retorno al punto de inicio"""
        print("✓ RTH - Retornando al inicio")
        self._state._flight_mode = "AUTO"
        self.emergencyActivated.emit("RTH")
        self.stateChanged.emit()
    
    @pyqtSlot()
    def safeMode(self):
        """Activar modo seguro"""
        print("✓ MODO SEGURO activado")
        self._state._flight_mode = "ASSISTED"
        self._state._altitude_hold = True
        self._state._collision_avoidance = True
        self._state._speed_limiter = True
        self.emergencyActivated.emit("SAFE_MODE")
        self.stateChanged.emit()
    
    # ===== SLOTS - MODOS ASISTIDOS =====
    
    @pyqtSlot(bool)
    def setAltitudeHold(self, enabled):
        self._state._altitude_hold = enabled
        print(f"✓ Altitude Hold: {'ON' if enabled else 'OFF'}")
        self.stateChanged.emit()
    
    @pyqtSlot(bool)
    def setSpeedLimiter(self, enabled):
        self._state._speed_limiter = enabled
        print(f"✓ Speed Limiter: {'ON' if enabled else 'OFF'}")
        self.stateChanged.emit()
    
    @pyqtSlot(bool)
    def setAutoBrake(self, enabled):
        self._state._auto_brake = enabled
        print(f"✓ Auto Brake: {'ON' if enabled else 'OFF'}")
        self.stateChanged.emit()
    
    @pyqtSlot(bool)
    def setCollisionAvoidance(self, enabled):
        self._state._collision_avoidance = enabled
        print(f"✓ Collision Avoidance: {'ON' if enabled else 'OFF'}")
        self.stateChanged.emit()
    
    # ===== SLOTS - CÁMARA =====
    
    @pyqtSlot()
    def toggleRecording(self):
        self._state._camera_recording = not self._state._camera_recording
        status = "INICIADA" if self._state._camera_recording else "DETENIDA"
        print(f"✓ Grabación {status}")
        self.stateChanged.emit()
    
    @pyqtSlot(str)
    def setCameraProfile(self, profile):
        if profile in ["low_light", "high_clarity", "anti_noise", "normal"]:
            self._state._camera_profile = profile
            print(f"✓ Perfil de cámara: {profile}")
            self.stateChanged.emit()
    
    @pyqtSlot(bool)
    def setExposureLock(self, locked):
        self._state._exposure_lock = locked
        print(f"✓ Bloqueo de exposición: {'ON' if locked else 'OFF'}")
        self.stateChanged.emit()
    
    @pyqtSlot(int)
    def setCameraTilt(self, angle):
        self._state._camera_tilt = max(-90, min(30, angle))
        print(f"✓ Inclinación cámara: {self._state._camera_tilt}°")
        self.stateChanged.emit()
    
    @pyqtSlot()
    def capturePhoto(self):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        print(f"📸 Foto capturada: IMG_{timestamp}.jpg")
        self.stateChanged.emit()
    
    @pyqtSlot(str)
    def markEvent(self, event_type):
        """Marcar evento con toda la información"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        event = {
            "type": event_type,
            "timestamp": timestamp,
            "position": self._state._position.copy(),
            "gases": {
                "ch4": self._state._ch4,
                "co": self._state._co,
                "o2": self._state._o2
            },
            "frame": f"FRAME_{len(self._state._events_marked)+1:04d}.jpg"
        }
        self._state._events_marked.append(event)
        print(f"🎯 EVENTO MARCADO: {event_type}")
        print(f"   Posición: ({event['position']['x']:.1f}, {event['position']['y']:.1f}, {event['position']['z']:.1f})")
        print(f"   Gases: CH4={event['gases']['ch4']:.2f}%, CO={event['gases']['co']:.1f}ppm, O2={event['gases']['o2']:.1f}%")
        self.eventMarked.emit(event_type)
        self.stateChanged.emit()
    
    # ===== SLOTS - CONTROLES =====
    
    @pyqtSlot(str)
    def setControlMode(self, mode):
        if mode in ["keyboard", "joystick"]:
            self._state._control_mode = mode
            print(f"✓ Modo de control: {mode}")
            self.stateChanged.emit()
    
    @pyqtSlot(str)
    def setSensitivity(self, level):
        if level in ["soft", "normal", "aggressive"]:
            self._state._sensitivity = level
            print(f"✓ Sensibilidad: {level}")
            self.stateChanged.emit()
    
    @pyqtSlot(bool)
    def setPrecisionMode(self, enabled):
        self._state._precision_mode = enabled
        print(f"✓ Modo precisión: {'ON' if enabled else 'OFF'}")
        self.stateChanged.emit()
    
    # ===== SLOTS - MOVIMIENTO =====
    
    @pyqtSlot(float, float, float, float)
    def sendMovement(self, throttle, yaw, pitch, roll):
        """Enviar comando de movimiento"""
        if self._state._is_flying:
            # Aplicar sensibilidad
            factor = 0.5 if self._state._precision_mode else 1.0
            if self._state._sensitivity == "soft":
                factor *= 0.6
            elif self._state._sensitivity == "aggressive":
                factor *= 1.4
            
            # Simular movimiento
            self._state._velocity["vx"] = pitch * factor
            self._state._velocity["vy"] = roll * factor
            self._state._velocity["vz"] = throttle * factor
            
            self._state._position["x"] += self._state._velocity["vx"] * 0.1
            self._state._position["y"] += self._state._velocity["vy"] * 0.1
            if not self._state._altitude_hold:
                self._state._position["z"] += self._state._velocity["vz"] * 0.1
            
            self._state._orientation["yaw"] += yaw * factor * 5
    
    # ===== UTILIDADES =====
    
    @pyqtSlot(int, result=str)
    def formatTime(self, seconds):
        """Formatear tiempo en MM:SS"""
        mins = seconds // 60
        secs = seconds % 60
        return f"{mins:02d}:{secs:02d}"


def main():
    # Instalar handler de mensajes para debug
    qInstallMessageHandler(qt_message_handler)
    
    app = QApplication(sys.argv)
    app.setApplicationName("Drone Teleoperation")
    app.setOrganizationName("DroneInspection")
    
    engine = QQmlApplicationEngine()
    
    # Registrar controlador ANTES de cargar el QML
    controller = TeleoperationController()
    engine.rootContext().setContextProperty("teleop", controller)
    
    # Cargar QML
    qml_file = Path(__file__).parent / "qml" / "Main.qml"
    print(f"Cargando: {qml_file}")
    engine.load(QUrl.fromLocalFile(str(qml_file)))
    
    if not engine.rootObjects():
        print("Error: No se pudo cargar la interfaz QML")
        print(f"Archivo buscado: {qml_file}")
        sys.exit(-1)
    
    sys.exit(app.exec())


if __name__ == "__main__":
    main()