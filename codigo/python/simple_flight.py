import json
import time
import threading
import paho.mqtt.client as mqtt
import matplotlib.pyplot as plt
from cflib.crazyflie import Crazyflie
from cflib.crazyflie.syncCrazyflie import SyncCrazyflie
from cflib.crazyflie.high_level_commander import HighLevelCommander
import cflib.crtp
from datetime import datetime, timezone

## Vuelo del dron usando Mocap y Flowdeck, con verificación de vuelo final. Usada para
## comprobar que tan diferente es el funcionamiento de la fusión de sensores en Python sin
## librerías.

# -------------------------------------------------------
# CONFIGURACIÓN
# -------------------------------------------------------

URI = "radio://0/80/2M/E7E7E7E7E1"
MQTT_TOPIC = 'mocap/drone3'
MQTT_BROKER = '192.168.50.200'
PORT = 1880

# -------------------------------------------------------
# VARIABLES GLOBALES
# -------------------------------------------------------
mocap_pose = {'x': 0.0, 'y': 0.0, 'z': 0.0}
real_trajectory = []
theoretical_trajectory = []
cf = None  # referencia global al dron
last_ts = None  # timestamp del último mensaje procesado


# -------------------------------------------------------
# CALLBACK MQTT (lectura y envío a EKF)
# -------------------------------------------------------
def on_message(client, userdata, msg):
    global mocap_pose, cf, last_ts
    try:
        data = json.loads(msg.payload.decode())
        pos = data['payload']['pose']['position']
        ts_str = data.get('ts', None)

        # Convertir timestamp ISO 8601 a datetime con zona UTC
        if ts_str is not None:
            msg_time = datetime.fromisoformat(ts_str.replace('Z', '+00:00'))

            # Ignorar mensajes antiguos
            if last_ts is not None and msg_time <= last_ts:
                return  # este mensaje es viejo
            last_ts = msg_time

        mocap_pose['x'] = float(pos['x'])
        mocap_pose['y'] = float(pos['y'])
        mocap_pose['z'] = float(pos['z'])

        # Si el dron está conectado, enviar posición al EKF
        if cf is not None:
            cf.extpos.send_extpos(
                mocap_pose['x'],
                mocap_pose['y'],
                mocap_pose['z']
            )

        # Guardar trayectoria real
        real_trajectory.append([mocap_pose['x'], mocap_pose['y'], mocap_pose['z']])

    except Exception as e:
        print("Error en MQTT:", e)
        print("Mensaje:", msg.payload.decode())

def start_mqtt():
    client = mqtt.Client()
    client.on_message = on_message
    client.connect(MQTT_BROKER, PORT, 60)
    client.subscribe(MQTT_TOPIC)
    client.loop_forever()


# -------------------------------------------------------
# TRAJECTORIA SIMPLE (takeoff -> hover -> land)
# -------------------------------------------------------
def fly_simple(cf):
    global theoretical_trajectory

    commander = HighLevelCommander(cf)
    hover_height = 0.50
    hover_time = 3.0

    print("Despegando...")
    commander.takeoff(hover_height, 2.0)
    start = time.time()

    while time.time() - start < hover_time:
        theoretical_trajectory.append([0, 0, hover_height])
        time.sleep(0.05)

    print("Aterrizando...")
    commander.land(0.0, 1.0)
    time.sleep(3.0)
    commander.stop()


# -------------------------------------------------------
# GRAFICAR
# -------------------------------------------------------
def plot_trajectories():
    import numpy as np
    if len(real_trajectory) == 0:
        print("No se registró trayectoria real.")
        return

    real = np.array(real_trajectory)
    theo = np.array(theoretical_trajectory)

    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')
    ax.plot(theo[:, 0], theo[:, 1], theo[:, 2], 'r--', label='Trayectoria teórica')
    ax.plot(real[:, 0], real[:, 1], real[:, 2], 'b', label='Trayectoria real (MoCap)')
    ax.set_xlim([-2, 2])
    ax.set_ylim([-2, 2])
    ax.set_zlim([0, 2])
    ax.set_xlabel('X [m]')
    ax.set_ylabel('Y [m]')
    ax.set_zlabel('Z [m]')
    ax.legend()
    plt.title("Comparación: Trayectoria teórica vs real (MoCap)")
    plt.show()


# -------------------------------------------------------
# MAIN
# -------------------------------------------------------
def main():
    global cf

    # Inicializar drivers
    cflib.crtp.init_drivers()

    # Hilo MQTT (recibe datos MoCap)
    mqtt_thread = threading.Thread(target=start_mqtt, daemon=True)
    mqtt_thread.start()

    print("Conectando al dron...")
    with SyncCrazyflie(URI, cf=Crazyflie(rw_cache='./cache')) as scf:
        cf = scf.cf  # referencia al objeto Crazyflie interno
        print("Conectado correctamente.")
        time.sleep(0.1)

        cf.param.set_value('stabilizer.estimator', '2')  # 2 = Kalman
        # --- Reiniciar el estimador Kalman ---
        print("Reiniciando el estimador Kalman...")
        cf.param.set_value('kalman.resetEstimation', '1')
        time.sleep(0.1)
        cf.param.set_value('kalman.resetEstimation', '0')  # vuelve a 0
        print("Estimador reiniciado correctamente.")

        time.sleep(3.0) #esperar al EKF

        # Ejecutar trayectoria simple
        fly_simple(cf)

    # Graficar trayectorias
    plot_trajectories()


# -------------------------------------------------------
if __name__ == '__main__':
    main()
