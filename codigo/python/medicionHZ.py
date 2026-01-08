import paho.mqtt.client as mqtt
import matplotlib.pyplot as plt
import time
import threading
import atexit

# Medición y grafica de la velocidad de entrega de datos del servidor MQTT.

# -------------------------------------------------------
# CONFIGURACIÓN
# -------------------------------------------------------
BROKER = '192.168.50.200'
TOPIC = 'mocap/drone3'
DURACION = 60  # segundos

# Variables iniciales
mensaje_count = 0
start_time = time.time()
frecuencias = [0.0] * 5000
tiempos = [0.0] * 5000
idx = 0
run_program = True

# -------------------------------------------------------
# FUNCIONES
# -------------------------------------------------------
def on_message(client, userdata, msg):
    """Callback: incrementa el contador de mensajes recibidos."""
    global mensaje_count
    mensaje_count += 1


def medir_frecuencia():
    """Calcula frecuencia promedio cada segundo durante DURACION."""
    global mensaje_count, idx, run_program
    while run_program:
        time.sleep(0.02)
        elapsed = time.time() - start_time
        if elapsed > 0:
            frecuencia_prom = mensaje_count / elapsed
            frecuencias[idx] = frecuencia_prom
            tiempos[idx] = elapsed
            idx += 1
        if elapsed >= DURACION:
            run_program = False
            break


def mostrar_resultado_final():
    """Muestra resultados y la gráfica al finalizar la ejecución."""
    global tiempos, frecuencias, idx
    if tiempos:
        # Recortar vectores al tamaño real
        frecuencias = frecuencias[:idx]
        tiempos = tiempos[:idx]
        
        frecuencia_final = frecuencias[-1]
        print(f"\n=== Medición completada ===")
        print(f"Tiempo total: {tiempos[-1]:.1f} s")
        print(f"Frecuencia promedio final: {frecuencia_final:.2f} mensajes/s")

        # --- Gráfica final ---
        plt.figure()
        plt.plot(tiempos, frecuencias, '-o', label='Frecuencia promedio')
        plt.axhline(y=frecuencia_final, color='r', linestyle='--',
                    label=f'Promedio final: {frecuencia_final:.2f} msg/s')
        plt.xlabel("Tiempo (s)")
        plt.ylabel("Frecuencia promedio (mensajes/s)")
        plt.title("Frecuencia promedio de recepción MQTT")
        plt.grid(True)
        plt.legend()
        plt.show()
    else:
        print("\nNo se recibieron mensajes durante la medición.")

# -------------------------------------------------------
# MAIN 
# -------------------------------------------------------
atexit.register(mostrar_resultado_final)

# Conexión MQTT
client = mqtt.Client()
client.on_message = on_message
client.connect(BROKER, 1880, 60)
client.subscribe(TOPIC)

# Hilos
threading.Thread(target=client.loop_forever, daemon=True).start()
threading.Thread(target=medir_frecuencia, daemon=True).start()

# Esperar a que termine la medición
while run_program:
    time.sleep(0.5)

# Mostrar resultados al final
mostrar_resultado_final()
