# Evaluación de sensores de posicionamiento para Crazyflie 2.1

Este proyecto se centra en la **evaluación de diferentes sensores de posicionamiento para el dron Crazyflie 2.1**. Su desarrollo incluyó la implementación de rutinas de software, la integración de distintos sensores y la evaluación de su desempeño mediante experimentos controlados.

El presente repositorio presenta **tres componentes principales**: **Código**, **Manuales** y **Multimedia**, cada uno de los cuales contiene los archivos y recursos utilizados durante el desarrollo del proyecto y necesarios para replicar los resultados obtenidos.

---

## Código

Esta carpeta contiene todos los archivos de programación y las herramientas de software desarrolladas durante el proyecto. Incluye scripts, funciones y programas empleados para:

- La comunicación con el dron  
- La adquisición de datos  
- El procesamiento de información  
- La ejecución de los experimentos  

Los códigos fueron desarrollados principalmente en **MATLAB** y **Python**, lo que permitió comparar el desempeño y las capacidades de ambos entornos de desarrollo para el control y la experimentación con el Crazyflie 2.1.

---

## Manuales

Esta carpeta contiene la documentación necesaria para la correcta configuración y uso del sistema, incluyendo:

- Manual de instalación de todos los requerimientos necesarios para establecer la conexión con el servidor **MQTT**, tanto en **MATLAB** como en **Python**.
- Manual de usuario para la operación del dron **Crazyflie 2.1**.

---

## Multimedia

En esta carpeta se encuentran todos los archivos multimedia generados durante la realización del proyecto.  
Los nombres de los archivos siguen una **nomenclatura estándar** que describe los métodos y herramientas empleados para su obtención:

- **`mc`**: resultado obtenido utilizando únicamente el sistema de captura de movimiento.  
- **`fus`**: resultado obtenido mediante la fusión de sensores.  
- **`func`**: indica que se emplearon las funciones diseñadas para el control del Crazyflie.  
- **`simple`**: indica que se utilizaron únicamente los comandos básicos de la librería `cflib`.  
- **`TCP`**: indica el uso del protocolo de comunicación TCP/IP.  
- **`MQTT`**: indica el uso del protocolo de comunicación MQTT.  
- **`PY`**: indica que se utilizó Python.  
- **`MAT`**: indica que se utilizó MATLAB.  

También se incluye el **diseño del patrón empleado en las planchas antirreflectantes** utilizadas durante los experimentos.
