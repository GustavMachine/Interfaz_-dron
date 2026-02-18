"""
Sistema de Inspección con Dron para Túneles Mineros
Interfaz de Análisis de Datos Post-Misión
Desarrollado con PyQt6 + Qt Quick/QML

Tesis: DISEÑO DE UN SISTEMA AUTÓNOMO DE INSPECCIÓN CON UN DRON AÉREO 
       PARA LA DETECCIÓN DE GRIETAS Y GASES EN TÚNELES MINEROS SUBTERRÁNEOS
"""

import sys
import os
import random
from pathlib import Path
from datetime import datetime

from PyQt6.QtWidgets import QApplication
from PyQt6.QtQml import QQmlApplicationEngine
from PyQt6.QtCore import QObject, pyqtSignal, pyqtSlot, pyqtProperty, QUrl, QTimer


class MissionData:
    """Datos simulados de una misión completada"""
    
    def __init__(self):
        self.mission_id = "MSN-2026-0142"
        self.date = "31 Enero 2026"
        self.start_time = "09:15:32"
        self.end_time = "09:28:17"
        self.duration = "12:45"
        self.distance = 342  # metros
        self.max_depth = 245  # metros bajo tierra
        self.sector = "Sector A - Nivel -240m"
        self.operator = "Juan Pérez"
        self.drone_id = "UAV-MINE-007"
        
        # Generar datos de telemetría simulados
        self.telemetry = self._generate_telemetry()
        
        # Generar eventos detectados
        self.events = self._generate_events()
        
        # Estadísticas de la misión
        self.stats = self._calculate_stats()
    
    def _generate_telemetry(self):
        """Genera datos de telemetría simulados"""
        data = []
        num_points = 765  # ~12:45 minutos a 1Hz
        
        for i in range(num_points):
            timestamp = i  # segundos desde inicio
            
            # Posición simulada (avance lineal con variaciones)
            position = (i / num_points) * 342  # metros
            
            # Gases simulados con picos
            ch4_base = 0.3 + random.uniform(-0.1, 0.1)
            co_base = 5 + random.uniform(-2, 2)
            o2_base = 20.8 + random.uniform(-0.2, 0.2)
            h2s_base = 0.5 + random.uniform(-0.2, 0.2) 
            # Añadir picos de gas en ciertos momentos
            if 180 <= i <= 220:  # Pico de CH4
                ch4_base += 1.2 * (1 - abs(i - 200) / 20)
            if 450 <= i <= 480:  # Pico de CO
                co_base += 15 * (1 - abs(i - 465) / 15)
            
            # Altura y velocidad
            height = 2.5 + random.uniform(-0.3, 0.3)
            speed = 0.45 + random.uniform(-0.1, 0.1)
            
            # Batería (decremento gradual)
            battery = 87 - (i / num_points) * 19
            
            # Calidad SLAM
            slam_quality = 92 + random.uniform(-5, 3)
            
            # Temperatura
            temperature = 24 + random.uniform(-1, 1)
            if 630 <= i <= 670:  # Anomalía térmica
                temperature += 8 * (1 - abs(i - 650) / 20)
            
            data.append({
                'timestamp': timestamp,
                'position': round(position, 1),
                'ch4': round(max(0, ch4_base), 2),
                'co': round(max(0, co_base), 1),
                'o2': round(o2_base, 1),
                'h2s': round(max(0, h2s_base), 2),
                'height': round(height, 2),
                'speed': round(speed, 2),
                'battery': round(battery, 1),
                'slam_quality': round(min(100, max(0, slam_quality)), 0),
                'signal_strength': -55 + random.randint(-10, 5),
                'temperature': round(temperature, 1)
            })
        
        return data
    
    def _generate_events(self):
        """Genera eventos detectados durante la misión"""
        events = [
            {
                'id': 'EVT-001',
                'type': 'gas',
                'subtype': 'ch4_peak',
                'timestamp': 200,
                'position': 89.2,
                'severity': 'warning',
                'title': 'Pico de CH4 detectado',
                'description': 'Concentración máxima: 1.5% LEL',
                'value': 1.5,
                'unit': '% LEL',
                'recommendation': 'Verificar ventilación en zona'
            },
            {
                'id': 'EVT-002',
                'type': 'crack',
                'subtype': 'longitudinal',
                'timestamp': 285,
                'position': 126.4,
                'severity': 'critical',
                'title': 'Grieta longitudinal crítica',
                'description': 'Longitud: 45cm, Ancho: 12mm',
                'value': 12,
                'unit': 'mm',
                'confidence': 0.94,
                'recommendation': 'Inspección manual urgente requerida'
            },
            {
                'id': 'EVT-003',
                'type': 'crack',
                'subtype': 'radial',
                'timestamp': 340,
                'position': 151.2,
                'severity': 'warning',
                'title': 'Grieta radial moderada',
                'description': 'Longitud: 28cm, Ancho: 5mm',
                'value': 5,
                'unit': 'mm',
                'confidence': 0.87,
                'recommendation': 'Monitorear en próxima inspección'
            },
            {
                'id': 'EVT-004',
                'type': 'gas',
                'subtype': 'co_peak',
                'timestamp': 465,
                'position': 206.8,
                'severity': 'critical',
                'title': 'Pico de CO detectado',
                'description': 'Concentración máxima: 22 ppm',
                'value': 22,
                'unit': 'ppm',
                'recommendation': 'Evacuar zona y verificar fuente de emisión'
            },
            {
                'id': 'EVT-005',
                'type': 'crack',
                'subtype': 'surface',
                'timestamp': 520,
                'position': 231.5,
                'severity': 'low',
                'title': 'Grieta superficial menor',
                'description': 'Longitud: 15cm, Ancho: 2mm',
                'value': 2,
                'unit': 'mm',
                'confidence': 0.91,
                'recommendation': 'Sin acción inmediata requerida'
            },
            {
                'id': 'EVT-006',
                'type': 'obstacle',
                'subtype': 'debris',
                'timestamp': 580,
                'position': 258.1,
                'severity': 'info',
                'title': 'Escombros detectados',
                'description': 'Obstrucción parcial del túnel (~30%)',
                'value': 30,
                'unit': '%',
                'recommendation': 'Programar limpieza de vía'
            },
            {
                'id': 'EVT-007',
                'type': 'anomaly',
                'subtype': 'temperature',
                'timestamp': 650,
                'position': 289.3,
                'severity': 'warning',
                'title': 'Anomalía térmica detectada',
                'description': 'Diferencia de +8°C respecto a baseline',
                'value': 8,
                'unit': '°C',
                'recommendation': 'Investigar posible fuente de calor'
            },
            {
                'id': 'EVT-008',
                'type': 'crack',
                'subtype': 'network',
                'timestamp': 710,
                'position': 316.2,
                'severity': 'warning',
                'title': 'Red de microgrietas',
                'description': 'Área afectada: ~0.5m², Profundidad estimada: 3mm',
                'value': 3,
                'unit': 'mm',
                'confidence': 0.82,
                'recommendation': 'Evaluación estructural recomendada'
            }
        ]
        return events
    
    def _calculate_stats(self):
        """Calcula estadísticas de la misión"""
        gas_events = [e for e in self.events if e['type'] == 'gas']
        crack_events = [e for e in self.events if e['type'] == 'crack']
        
        # Calcular promedios de telemetría
        avg_ch4 = sum(t['ch4'] for t in self.telemetry) / len(self.telemetry)
        avg_co = sum(t['co'] for t in self.telemetry) / len(self.telemetry)
        max_ch4 = max(t['ch4'] for t in self.telemetry)
        max_co = max(t['co'] for t in self.telemetry)
        avg_o2 = sum(t['o2'] for t in self.telemetry) / len(self.telemetry)
        min_o2 = min(t['o2'] for t in self.telemetry)
        
        return {
            'total_events': len(self.events),
            'gas_events': len(gas_events),
            'crack_events': len(crack_events),
            'obstacle_events': len([e for e in self.events if e['type'] == 'obstacle']),
            'anomaly_events': len([e for e in self.events if e['type'] == 'anomaly']),
            'critical_events': len([e for e in self.events if e['severity'] == 'critical']),
            'warning_events': len([e for e in self.events if e['severity'] == 'warning']),
            'low_events': len([e for e in self.events if e['severity'] == 'low']),
            'avg_ch4': round(avg_ch4, 2),
            'avg_co': round(avg_co, 1),
            'avg_o2': round(avg_o2, 1),
            'max_ch4': round(max_ch4, 2),
            'max_co': round(max_co, 1),
            'min_o2': round(min_o2, 1),
            'avg_speed': 0.45,
            'coverage_percent': 98.5,
            'data_quality': 96.2,
            'slam_avg_quality': 91.4,
            'battery_start': 87,
            'battery_end': 68
        }


class AnalysisController(QObject):
    """Controlador principal para la interfaz de análisis"""
    
    # Señales
    timelinePositionChanged = pyqtSignal()
    dataUpdated = pyqtSignal()
    eventSelected = pyqtSignal(str)
    layerVisibilityChanged = pyqtSignal()
    playbackSpeedChanged = pyqtSignal()
    filterChanged = pyqtSignal()
    
    def __init__(self):
        super().__init__()
        
        # Cargar datos de misión simulados
        self._mission = MissionData()
        
        # Estado de la timeline
        self._current_time = 0  # segundos
        self._total_time = 765  # segundos (12:45)
        self._is_playing = False
        self._playback_speed = 1  # 1x, 2x, 5x, 10x
        
        # Evento seleccionado
        self._selected_event_id = ""
        
        # Visibilidad de capas
        self._layers = {
            'trajectory': True,
            'gas_heatmap': True,
            'cracks': True,
            'obstacles': True,
            'anomalies': True
        }
        
        # Filtros activos
        self._severity_filter = "all"  # 'all', 'critical', 'warning', 'low', 'info'
        self._type_filter = "all"  # 'all', 'gas', 'crack', 'obstacle', 'anomaly'
        
        # Timer para reproducción
        self._play_timer = QTimer()
        self._play_timer.timeout.connect(self._on_play_tick)
        self._update_timer_interval()
    
    def _update_timer_interval(self):
        """Actualiza el intervalo del timer según la velocidad"""
        base_interval = 1000  # 1 segundo real = 1 segundo simulado a 1x
        self._play_timer.setInterval(int(base_interval / self._playback_speed))
    
    # ===== PROPIEDADES DE MISIÓN =====
    @pyqtProperty('QVariant', constant=True)
    def missionInfo(self):
        return {
            'id': self._mission.mission_id,
            'date': self._mission.date,
            'startTime': self._mission.start_time,
            'endTime': self._mission.end_time,
            'duration': self._mission.duration,
            'distance': self._mission.distance,
            'maxDepth': self._mission.max_depth,
            'sector': self._mission.sector,
            'operator': self._mission.operator,
            'droneId': self._mission.drone_id
        }
    
    @pyqtProperty('QVariant', constant=True)
    def missionStats(self):
        return self._mission.stats
    
    @pyqtProperty('QVariant', constant=True)
    def allEvents(self):
        return self._mission.events
    
    @pyqtProperty('QVariant', notify=filterChanged)
    def filteredEvents(self):
        """Retorna eventos filtrados según los filtros activos"""
        events = self._mission.events
        
        if self._type_filter != "all":
            events = [e for e in events if e['type'] == self._type_filter]
        
        if self._severity_filter != "all":
            events = [e for e in events if e['severity'] == self._severity_filter]
        
        return events
    
    # ===== PROPIEDADES DE TIMELINE =====
    @pyqtProperty(int, notify=timelinePositionChanged)
    def currentTime(self):
        return self._current_time
    
    @currentTime.setter
    def currentTime(self, value):
        if self._current_time != value:
            self._current_time = max(0, min(value, self._total_time))
            self.timelinePositionChanged.emit()
    
    @pyqtProperty(int, constant=True)
    def totalTime(self):
        return self._total_time
    
    @pyqtProperty(bool, notify=timelinePositionChanged)
    def isPlaying(self):
        return self._is_playing
    
    @pyqtProperty(int, notify=playbackSpeedChanged)
    def playbackSpeed(self):
        return self._playback_speed
    
    @pyqtProperty('QVariant', notify=timelinePositionChanged)
    def currentTelemetry(self):
        """Obtiene la telemetría en el tiempo actual"""
        if 0 <= self._current_time < len(self._mission.telemetry):
            return self._mission.telemetry[self._current_time]
        return self._mission.telemetry[0] if self._mission.telemetry else {}
    
    @pyqtProperty(float, notify=timelinePositionChanged)
    def currentPosition(self):
        """Posición actual del dron en metros"""
        tel = self.currentTelemetry
        return tel.get('position', 0) if tel else 0
    
    # ===== PROPIEDADES DE EVENTO SELECCIONADO =====
    @pyqtProperty(str, notify=eventSelected)
    def selectedEventId(self):
        return self._selected_event_id
    
    @pyqtProperty('QVariant', notify=eventSelected)
    def selectedEvent(self):
        """Retorna el evento seleccionado completo"""
        if self._selected_event_id:
            for event in self._mission.events:
                if event['id'] == self._selected_event_id:
                    return event
        return None
    
    # ===== PROPIEDADES DE FILTROS =====
    @pyqtProperty(str, notify=filterChanged)
    def typeFilter(self):
        return self._type_filter
    
    @pyqtProperty(str, notify=filterChanged)
    def severityFilter(self):
        return self._severity_filter
    
    # ===== PROPIEDADES DE CAPAS =====
    @pyqtProperty('QVariant', notify=layerVisibilityChanged)
    def layers(self):
        return self._layers
    
    # ===== SLOTS DE TIMELINE =====
    @pyqtSlot(int)
    def seekTo(self, time):
        """Mover la timeline a un tiempo específico"""
        self.currentTime = time
    
    @pyqtSlot()
    def play(self):
        """Iniciar reproducción"""
        if not self._is_playing:
            self._is_playing = True
            self._play_timer.start()
            self.timelinePositionChanged.emit()
    
    @pyqtSlot()
    def pause(self):
        """Pausar reproducción"""
        if self._is_playing:
            self._is_playing = False
            self._play_timer.stop()
            self.timelinePositionChanged.emit()
    
    @pyqtSlot()
    def togglePlayPause(self):
        """Alternar entre play y pause"""
        if self._is_playing:
            self.pause()
        else:
            self.play()
    
    @pyqtSlot()
    def skipBackward(self):
        """Retroceder 30 segundos"""
        self.seekTo(self._current_time - 30)
    
    @pyqtSlot()
    def skipForward(self):
        """Avanzar 30 segundos"""
        self.seekTo(self._current_time + 30)
    
    @pyqtSlot()
    def goToStart(self):
        """Ir al inicio"""
        self.seekTo(0)
    
    @pyqtSlot()
    def goToEnd(self):
        """Ir al final"""
        self.seekTo(self._total_time)
    
    @pyqtSlot(int)
    def setPlaybackSpeed(self, speed):
        """Cambiar velocidad de reproducción"""
        if speed in [1, 2, 5, 10]:
            self._playback_speed = speed
            self._update_timer_interval()
            self.playbackSpeedChanged.emit()
    
    @pyqtSlot()
    def cyclePlaybackSpeed(self):
        """Ciclar entre velocidades de reproducción"""
        speeds = [1, 2, 5, 10]
        current_index = speeds.index(self._playback_speed) if self._playback_speed in speeds else 0
        next_index = (current_index + 1) % len(speeds)
        self.setPlaybackSpeed(speeds[next_index])
    
    def _on_play_tick(self):
        """Callback del timer de reproducción"""
        if self._current_time < self._total_time:
            self.currentTime = self._current_time + 1
        else:
            self.pause()
    
    # ===== SLOTS DE EVENTOS =====
    @pyqtSlot(str)
    def selectEvent(self, event_id):
        """Seleccionar un evento"""
        self._selected_event_id = event_id
        # Buscar el evento y mover timeline a su posición
        for event in self._mission.events:
            if event['id'] == event_id:
                self.seekTo(event['timestamp'])
                break
        self.eventSelected.emit(event_id)
    
    @pyqtSlot()
    def clearEventSelection(self):
        """Limpiar selección de evento"""
        self._selected_event_id = ""
        self.eventSelected.emit("")
    
    @pyqtSlot(str, result='QVariant')
    def getEventById(self, event_id):
        """Obtener un evento por su ID"""
        for event in self._mission.events:
            if event['id'] == event_id:
                return event
        return None
    
    @pyqtSlot(result='QVariant')
    def getEventsAtCurrentTime(self):
        """Obtener eventos cercanos al tiempo actual (±10 segundos)"""
        current = self._current_time
        return [e for e in self._mission.events 
                if abs(e['timestamp'] - current) <= 10]
    
    # ===== SLOTS DE FILTROS =====
    @pyqtSlot(str)
    def setTypeFilter(self, filter_type):
        """Establecer filtro por tipo"""
        if filter_type != self._type_filter:
            self._type_filter = filter_type
            self.filterChanged.emit()
    
    @pyqtSlot(str)
    def setSeverityFilter(self, severity):
        """Establecer filtro por severidad"""
        if severity != self._severity_filter:
            self._severity_filter = severity
            self.filterChanged.emit()
    
    @pyqtSlot()
    def clearFilters(self):
        """Limpiar todos los filtros"""
        self._type_filter = "all"
        self._severity_filter = "all"
        self.filterChanged.emit()
    
    # ===== SLOTS DE CAPAS =====
    @pyqtSlot(str, bool)
    def setLayerVisibility(self, layer, visible):
        """Cambiar visibilidad de una capa"""
        if layer in self._layers:
            self._layers[layer] = visible
            self.layerVisibilityChanged.emit()
    
    @pyqtSlot(str)
    def toggleLayer(self, layer):
        """Alternar visibilidad de una capa"""
        if layer in self._layers:
            self._layers[layer] = not self._layers[layer]
            self.layerVisibilityChanged.emit()
    
    @pyqtSlot(str, result=bool)
    def isLayerVisible(self, layer):
        """Verificar si una capa está visible"""
        return self._layers.get(layer, False)
    
    # ===== SLOTS DE DATOS =====
    @pyqtSlot(int, int, result='QVariant')
    def getTelemetryRange(self, start, end):
        """Obtener rango de telemetría para gráficos"""
        start = max(0, start)
        end = min(len(self._mission.telemetry), end)
        return self._mission.telemetry[start:end]
    
    @pyqtSlot(str, result='QVariant')
    def getGasDataForChart(self, gas_type):
        """Obtener datos de un gas específico para gráficos"""
        return [{'x': t['timestamp'], 'y': t[gas_type]} 
                for t in self._mission.telemetry]
    
    @pyqtSlot(result='QVariant')
    def getSparklineData(self):
        """Obtener últimos 60 puntos para sparklines"""
        start = max(0, self._current_time - 60)
        end = self._current_time + 1
        return self._mission.telemetry[start:end]
    
    @pyqtSlot(result='QVariant')
    def getAllTelemetry(self):
        """Obtener toda la telemetría"""
        return self._mission.telemetry
    
    # ===== SLOTS DE REPORTES =====
    @pyqtSlot(result=str)
    def generateReportSummary(self):
        """Generar resumen del reporte"""
        stats = self._mission.stats
        info = self.missionInfo
        
        summary = f"""
═══════════════════════════════════════════════════════════════
              REPORTE DE INSPECCIÓN AUTÓNOMA
═══════════════════════════════════════════════════════════════

INFORMACIÓN DE MISIÓN
─────────────────────
ID Misión:    {info['id']}
Fecha:        {info['date']}
Hora:         {info['startTime']} - {info['endTime']}
Sector:       {info['sector']}
Operador:     {info['operator']}
Dron:         {info['droneId']}
Duración:     {info['duration']}
Distancia:    {info['distance']}m
Profundidad:  -{info['maxDepth']}m

RESUMEN DE HALLAZGOS
────────────────────
Total de eventos detectados:  {stats['total_events']}
  • Críticos:                  {stats['critical_events']}
  • Advertencias:              {stats['warning_events']}
  • Menores:                   {stats['low_events']}

Por tipo:
  • Detecciones de gas:        {stats['gas_events']}
  • Detecciones de grietas:    {stats['crack_events']}
  • Obstáculos:                {stats['obstacle_events']}
  • Anomalías:                 {stats['anomaly_events']}

CONCENTRACIONES DE GAS
──────────────────────
Metano (CH4):
  Promedio: {stats['avg_ch4']}% LEL | Máximo: {stats['max_ch4']}% LEL

Monóxido de Carbono (CO):
  Promedio: {stats['avg_co']} ppm | Máximo: {stats['max_co']} ppm

Oxígeno (O2):
  Promedio: {stats['avg_o2']}% | Mínimo: {stats['min_o2']}%

CALIDAD DE DATOS
────────────────
Cobertura del túnel:          {stats['coverage_percent']}%
Calidad de datos general:     {stats['data_quality']}%
Calidad SLAM promedio:        {stats['slam_avg_quality']}%
Batería: {stats['battery_start']}% → {stats['battery_end']}%

═══════════════════════════════════════════════════════════════
        Generado automáticamente por Sistema UAV-MINE
═══════════════════════════════════════════════════════════════
"""
        return summary
    
    @pyqtSlot()
    def exportToPDF(self):
        """Exportar reporte a PDF"""
        print("="*60)
        print("EXPORTANDO REPORTE A PDF...")
        print("="*60)
        print(self.generateReportSummary())
        print("\n✓ Reporte guardado: reporte_mision_{}.pdf".format(self._mission.mission_id))
    
    @pyqtSlot()
    def exportToHTML(self):
        """Exportar reporte a HTML"""
        print("="*60)
        print("EXPORTANDO REPORTE A HTML...")
        print("="*60)
        print("\n✓ Reporte guardado: reporte_mision_{}.html".format(self._mission.mission_id))
    
    @pyqtSlot()
    def shareReport(self):
        """Compartir reporte"""
        print("="*60)
        print("COMPARTIENDO REPORTE...")
        print("="*60)
        print("\n✓ Enlace de compartición generado")
    
    @pyqtSlot()
    def downloadVideo(self):
        """Descargar video de la misión"""
        print("="*60)
        print("DESCARGANDO VIDEO DE MISIÓN...")
        print("="*60)
        print(f"Misión: {self._mission.mission_id}")
        print(f"Duración del video: {self._mission.duration}")
        print("\n✓ Video guardado: video_mision_{}.mp4".format(self._mission.mission_id))
        print("  Ubicación: /home/usuario/Descargas/")
    
    @pyqtSlot()
    def downloadCrackPhotos(self):
        """Descargar fotos de grietas detectadas"""
        print("="*60)
        print("DESCARGANDO FOTOS DE GRIETAS...")
        print("="*60)
        crack_events = [e for e in self._mission.events if e['type'] == 'crack']
        print(f"Total de grietas detectadas: {len(crack_events)}")
        for i, crack in enumerate(crack_events, 1):
            print(f"  {i}. {crack['title']} - {crack['position']}m")
        print(f"\n✓ {len(crack_events)} fotos guardadas en: grietas_mision_{self._mission.mission_id}/")
        print("  Ubicación: /home/usuario/Descargas/")
    
    @pyqtSlot(result='QVariant')
    def getAllTelemetry(self):
        """Obtener toda la telemetría para gráficos completos"""
        return self._mission.telemetry
    
    # ===== UTILIDADES =====
    @pyqtSlot(int, result=str)
    def formatTime(self, seconds):
        """Formatear segundos a MM:SS"""
        minutes = seconds // 60
        secs = seconds % 60
        return f"{minutes:02d}:{secs:02d}"
    
    @pyqtSlot(str, result=str)
    def getSeverityColor(self, severity):
        """Obtener color según severidad"""
        colors = {
            'critical': '#f85149',
            'warning': '#d29922',
            'low': '#3fb950',
            'info': '#58a6ff'
        }
        return colors.get(severity, '#8b949e')
    
    @pyqtSlot(str, result=str)
    def getTypeColor(self, event_type):
        """Obtener color según tipo de evento"""
        colors = {
            'gas': '#a371f7',
            'crack': '#f85149',
            'obstacle': '#d29922',
            'anomaly': '#58a6ff'
        }
        return colors.get(event_type, '#8b949e')
    
    @pyqtSlot(str, result=str)
    def getEventIcon(self, event_type):
        """Obtener icono según tipo de evento"""
        icons = {
            'gas': '💨',
            'crack': '⚡',
            'obstacle': '🚧',
            'anomaly': '⚠️'
        }
        return icons.get(event_type, '●')
    
    @pyqtSlot(str, result=str)
    def getTypeLabel(self, event_type):
        """Obtener etiqueta según tipo de evento"""
        labels = {
            'gas': 'Gas',
            'crack': 'Grieta',
            'obstacle': 'Obstáculo',
            'anomaly': 'Anomalía'
        }
        return labels.get(event_type, 'Desconocido')
    
    @pyqtSlot(str, result=str)
    def getSeverityLabel(self, severity):
        """Obtener etiqueta según severidad"""
        labels = {
            'critical': 'Crítico',
            'warning': 'Advertencia',
            'low': 'Menor',
            'info': 'Info'
        }
        return labels.get(severity, 'Desconocido')


def main():
    # Configurar aplicación
    app = QApplication(sys.argv)
    app.setApplicationName("DroneMineTunnel - Análisis de Datos")
    app.setOrganizationName("Tesis UAV Mining")
    
    # Crear el motor QML
    engine = QQmlApplicationEngine()
    
    # Crear y registrar el controlador
    controller = AnalysisController()
    engine.rootContext().setContextProperty("analysisController", controller)
    
    # Cargar el archivo QML principal
    qml_file = Path(__file__).parent / "qml" / "Main.qml"
    engine.load(QUrl.fromLocalFile(str(qml_file)))
    
    # Verificar que se cargó correctamente
    if not engine.rootObjects():
        print("Error: No se pudo cargar la interfaz QML")
        print(f"Archivo buscado: {qml_file}")
        sys.exit(-1)
    
    print("="*60)
    print("  Sistema de Análisis de Datos Post-Misión")
    print("  Interfaz cargada correctamente")
    print("="*60)
    
    # Ejecutar la aplicación
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
