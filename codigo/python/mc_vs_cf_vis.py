import time
import json
import threading
import numpy as np
from cflib.crazyflie import Crazyflie
from cflib.crazyflie.syncCrazyflie import SyncCrazyflie
from cflib.crazyflie.syncLogger import SyncLogger
from cflib.crazyflie.log import LogConfig
from cflib.crtp import init_drivers
import paho.mqtt.client as mqtt
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation

# Gráfica en tiempo real de la posición según MoCap y la posición según el dron Crazyflie,
# con retroalimentación del MoCap.

# -------------------------------------------------------
# CONFIGURACIÓN
# -------------------------------------------------------
URI = "radio://0/64/2M/E7E7E7E7E8"
MQTT_TOPIC = 'mocap/drone3'
BROKER = '192.168.50.200'
PORT = 1880

# Variables globales
mocap_pose = {'x': 0.0, 'y': 0.0, 'z': 0.0}
cf_pose = {'x': 0.0, 'y': 0.0, 'z': 0.0}
cf = None  # referencia global al dron
max_len = 100 # trayectoria corta
mocap_traj = {'x': [], 'y': [], 'z': []}
cf_traj = {'x': [], 'y': [], 'z': []}

# -------------------------------------------------------
# CALLBACK MQTT (lectura y envío al dron)
# -------------------------------------------------------
def on_message(client, userdata, msg):
    global mocap_pose, cf
    try:
        data = json.loads(msg.payload.decode())
        pos = data['payload']['pose']['position']

        # Actualizar posición del MoCap
        mocap_pose['x'] = float(pos['x'])
        mocap_pose['y'] = float(pos['y'])
        mocap_pose['z'] = float(pos['z'])

        # Si el dron está conectado, enviar posición al dron
        if cf is not None and cf.is_connected():
            cf.extpos.send_extpos(
                mocap_pose['x'],
                mocap_pose['y'],
                mocap_pose['z']
            )
        else:
            print("No hay un cf conectado")

    except Exception as e:
        print("Error en MQTT:", e)
        print("Mensaje:", msg.payload.decode())

def start_mqtt():
    client = mqtt.Client()
    client.on_message = on_message
    client.connect(BROKER, PORT, 60)
    client.subscribe(MQTT_TOPIC)
    client.loop_forever()

# -------------------------------------------------------
# LECTURA CRAZYFLIE
# -------------------------------------------------------
def start_cf_logging():
    global cf_pose, cf
    init_drivers(enable_debug_driver=False)

    with SyncCrazyflie(URI, cf=Crazyflie(rw_cache='./cache')) as scf:        
        cf = scf.cf
        cf.param.set_value('stabilizer.estimator', '2')  # 2 = Kalman
        
        # Configurar logger
        log_conf = LogConfig(name='Crazyflie', period_in_ms=50)
        log_conf.add_variable('stateEstimate.x', 'float')
        log_conf.add_variable('stateEstimate.y', 'float')
        log_conf.add_variable('stateEstimate.z', 'float')

        with SyncLogger(scf, log_conf) as logger:
            for log_entry in logger:
                data = log_entry[1]
                cf_pose['x'] = data['stateEstimate.x']
                cf_pose['y'] = data['stateEstimate.y']
                cf_pose['z'] = data['stateEstimate.z']

# -------------------------------------------------------
# GRAFICADO EN TIEMPO REAL
# -------------------------------------------------------
fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')

# Puntos actuales
mocap_point, = ax.plot([], [], [], 'ro', label='MoCap', markersize=6)
cf_point, = ax.plot([], [], [], 'bo', label='Crazyflie', markersize=6)

# Líneas de trayectoria
mocap_line, = ax.plot([], [], [], 'r-', alpha=0.5)
cf_line, = ax.plot([], [], [], 'b-', alpha=0.5)

# Límites de los ejes
ax.set_xlim(-2, 2)
ax.set_ylim(-2, 2)
ax.set_zlim(0, 2)
ax.set_xlabel('X [m]')
ax.set_ylabel('Y [m]')
ax.set_zlabel('Z [m]')
ax.legend()
ax.view_init(elev=30, azim=135)  # angulo de vista
ax.set_title("Comparación de posición: Crazyflie vs MoCap")

def update(frame):
    # Actualizar trayectorias
    for src, traj in [(mocap_pose, mocap_traj), (cf_pose, cf_traj)]:
        for k in traj:
            traj[k].append(src[k])
            if len(traj[k]) > max_len:
                traj[k].pop(0)

    # Actualizar líneas y puntos
    mocap_line.set_data(mocap_traj['x'], mocap_traj['y'])
    mocap_line.set_3d_properties(mocap_traj['z'])

    cf_line.set_data(cf_traj['x'], cf_traj['y'])
    cf_line.set_3d_properties(cf_traj['z'])

    mocap_point.set_data([mocap_pose['x']], [mocap_pose['y']])
    mocap_point.set_3d_properties([mocap_pose['z']])

    cf_point.set_data([cf_pose['x']], [cf_pose['y']])
    cf_point.set_3d_properties([cf_pose['z']])

    return mocap_point, cf_point, mocap_line, cf_line

ani = FuncAnimation(fig, update, interval=100)

# -------------------------------------------------------
# HILOS PARA MQTT Y CF
# -------------------------------------------------------
mqtt_thread = threading.Thread(target=start_mqtt, daemon=True)
cf_thread = threading.Thread(target=start_cf_logging, daemon=True)

mqtt_thread.start()
cf_thread.start()

plt.show()
