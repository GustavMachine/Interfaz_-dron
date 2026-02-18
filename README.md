# Interfaz_-dron

# CÓDIGO_INTERFAZ
## Interfaz de Usuario – Sistema de Inspección Autónoma con Dron (Tesis)

Este repositorio agrupa **tres interfaces** del sistema, organizadas por etapa de operación:

1. **Configuración de misión** (pre-misión): definición de presets y parámetros de operación.  
2. **Teleoperación** (en misión): supervisión y control en tiempo real desde tablet industrial.  
3. **Análisis de datos** (post-misión): revisión de lecturas, alertas, eventos y resultados de inspección.

La implementación utiliza **Python + PyQt6** como puente de integración y **Qt Quick (QML)** para la capa visual, exponiendo propiedades y acciones mediante `QObject`, `pyqtProperty` y `pyqtSlot`.

---

## 1. Estructura del repositorio

```
CODIGO_INTERFAZ/
├─ drone_pro/                 # Interfaz 1: Configuración de misión
│  ├─ main.py
│  └─ qml/
│     ├─ Main.qml
│     ├─ Theme.qml
│     └─ qmldir
│
├─ drone_teleoperation/       # Interfaz 2: Teleoperación
│  ├─ main.py
│  └─ qml/
│     ├─ Main.qml
│     ├─ Theme.qml
│     ├─ qmldir
│     └─ imagen_socavon.png
│
└─ drone_analysis/            # Interfaz 3: Análisis de datos (post-misión)
   ├─ main.py
   └─ qml/
      ├─ Main.qml
      ├─ Theme.qml
      ├─ qmldir
      └─ tunel2d.png
```

> **Nota:** cada interfaz es autónoma (su propio `main.py` + `qml/Main.qml`).

---

## 2. Requisitos

- **Python 3.10+** (recomendado)
- **PyQt6**

Instalación (en un entorno virtual recomendado):

```bash
pip install PyQt6
```

---

## 3. Ejecución

Desde la carpeta `CODIGO_INTERFAZ`, ejecutar según la interfaz requerida:

### 3.1 Configuración de misión
```bash
cd drone_pro
python main.py
```

### 3.2 Teleoperación
```bash
cd drone_teleoperation
python main.py
```

### 3.3 Análisis de datos
```bash
cd drone_analysis
python main.py
```

---

## 4. Descripción funcional (resumen)

### 4.1 Configuración de misión (pre-misión)
- Presets y parámetros de operación
- Selección del tipo de inspección (grietas / gases / combinada)
- Estrategia de exploración y validación previa

### 4.2 Teleoperación (tiempo real)
- Estado crítico: batería, enlace, latencia, confianza SLAM
- Lecturas de gases: CH₄, CO, O₂, H₂S
- Temperaturas: motores y controlador
- Vista de cámara con superposición (OSD)
- Joysticks virtuales y modos asistidos
- Panel de emergencia (E-STOP, Hover, RTH, Safe Mode)
- Marcado de eventos durante la operación

### 4.3 Análisis de datos (post-misión)
- Resumen de misión, eventos y alertas
- Telemetría y resultados de inspección
- Vista espacial/temporal para evaluación de hallazgos

---

## 5. Alcance dentro de la tesis

Este repositorio documenta la **capa de interfaz** del sistema mecatrónico, orientada a:
- interacción operador–sistema,
- supervisión segura,
- trazabilidad de eventos,
- soporte a decisiones durante y después de la misión.

---

## 6. Referencias tecnológicas (APA 7)

Python Software Foundation. (s. f.). *Python* [Computer software]. https://www.python.org/

Riverbank Computing. (s. f.). *PyQt6* [Computer software]. https://www.riverbankcomputing.com/software/pyqt/

The Qt Company. (s. f.). *Qt* [Computer software]. https://www.qt.io/

The Qt Company. (s. f.). *Qt Documentation: Qt Quick (QML)* [Documentation]. https://doc.qt.io/qt-6/qtquick-index.html
