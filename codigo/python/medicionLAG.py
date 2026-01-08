import paho.mqtt.client as mqtt
import matplotlib.pyplot as plt
import threading
import atexit
import time
from datetime import datetime, timezone
import json
from cflib.crazyflie import Crazyflie
from cflib.crazyflie.syncCrazyflie import SyncCrazyflie
import cflib.crtp

# Medición y grafica de retraso (LAG) de los mensajes recibidos del servidor MQTT.

# -------------------------------------------------------
# CONFIGURACIÓN
# -------------------------------------------------------
URI = "radio://0/64/2M/E7E7E7E7E8"
BROKER = '192.168.50.200'
TOPIC = 'mocap/drone3'
DURACION = 60  # segundos

mocap_pose = {'x': 0.0, 'y': 0.0, 'z': 0.0}
cf = None          # referencia al dron
run_program = True
last_ts = None

total_msgs = 0
processed_msgs = 0
processed_ratio  = [0.0] * 5000
timestamps = [0.0] * 5000
idx = 0                         # índice actual
start_time = time.time()

# -------------------------------------------------------
# FUNCIONES
# -------------------------------------------------------
def on_message(client, userdata, msg):
    """Callback que calcula el lag y envía posición al dron."""
    global idx, mocap_pose, cf, total_msgs, processed_msgs, last_ts
    #Si el dron aún no está conectado, no procesar mensajes
    if cf is None: 
        return

    try:
        data = json.loads(msg.payload.decode())
        pos = data['payload']['pose']['position']
        ts_str = data.get('ts', None) # tiempo de envío (ts del paquete)

        total_msgs += 1

        # Validar timestamp
        if ts_str is not None:
            msg_time = datetime.fromisoformat(ts_str.replace('Z', '+00:00'))

            # Ignorar mensajes antiguos o duplicados
            if last_ts is not None and msg_time <= last_ts:
                return
            last_ts = msg_time

            # Guardar datos para gráfica
            if idx < 5000:
                ratio = processed_msgs / total_msgs if total_msgs > 0 else 0
                processed_ratio[idx] = ratio
                timestamps[idx] = time.time() - start_time
                idx += 1

        processed_msgs += 1

        # Actualizar posición
        mocap_pose['x'] = float(pos['x'])
        mocap_pose['y'] = float(pos['y'])
        mocap_pose['z'] = float(pos['z'])

        # Enviar posición al dron (EKF)
        cf.extpos.send_extpos(
            mocap_pose['x'],
            mocap_pose['y'],
            mocap_pose['z']
        )
    
    except Exception as e:
        print("Error en MQTT:", e)


def medir_duracion():
    """Controla el tiempo total de ejecución."""
    global run_program
    while run_program:
        if time.time() - start_time >= DURACION:
            run_program = False
            break
        time.sleep(0.1)


def mostrar_resultados_finales():
    """Genera la gráfica de mensajes ignorados."""
    global idx, processed_ratio, timestamps, total_msgs, processed_msgs

    processed_ratio = processed_ratio[:idx]
    timestamps = timestamps[:idx]

    print("\n=== Medición completada ===")
    print(f"Mensajes totales: {total_msgs}")
    print(f"Mensajes procesados: {processed_msgs}")
    print(f"Porcentaje procesado: {(processed_msgs/total_msgs)*100:.2f}%")

    if not timestamps:
        print("No se recibieron datos.")
        return

    # --- Gráfica ---
    fig, ax = plt.subplots()
    ax.plot(timestamps, processed_ratio, '-o', markersize=3)
    ax.set_xlabel('Tiempo (s)')
    ax.set_ylabel('Fracción acumulada de mensajes procesados')
    ax.set_title('Eficiencia de recepción MQTT')
    ax.grid(True)
    plt.show()

# -------------------------------------------------------
# MAIN
# -------------------------------------------------------
atexit.register(mostrar_resultados_finales)

# Inicializar drivers del Crazyflie
cflib.crtp.init_drivers()

# Conectar al dron
print("Conectando al dron...")
with SyncCrazyflie(URI, cf=Crazyflie(rw_cache='./cache')) as scf:
    cf = scf.cf
    print("Conectado correctamente.")

    cf.param.set_value('stabilizer.estimator', '2')  # 2 = Kalman

    # Conexión MQTT
    client = mqtt.Client()
    client.on_message = on_message
    client.connect(BROKER, 1880, 60)
    client.subscribe(TOPIC)

    # Hilos para MQTT y duración
    threading.Thread(target=client.loop_forever, daemon=True).start()
    threading.Thread(target=medir_duracion, daemon=True).start()
    
    # Esperar mientras se ejecuta la medición
    while run_program:
        time.sleep(0.5)

print("Medición finalizada, el dron se desconectará automáticamente.")
