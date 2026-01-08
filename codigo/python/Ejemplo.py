import json
import threading
import paho.mqtt.client as mqtt

## Ejemplo de conexión MQTT

# -------------------------------------------------------
# CONFIGURACIÓN
# -------------------------------------------------------
MQTT_TOPIC = 'mocap/drone3'
MQTT_BROKER = '192.168.50.200'
PORT = 1880

# -------------------------------------------------------
# MQTT
# -------------------------------------------------------
def on_message(client, userdata, msg): # Callback
    try:
        payload = msg.payload.decode()
        print(f"[MQTT] Mensaje recibido: {payload}")
    except Exception as e:
        print("Error al decodificar mensaje MQTT:", e)

def start_mqtt(): # Hilo
    client = mqtt.Client()
    client.on_message = on_message
    client.connect(MQTT_BROKER, PORT, 60)
    client.subscribe(MQTT_TOPIC)
    client.loop_forever()

# -------------------------------------------------------
# MAIN
# -------------------------------------------------------
def main():
    mqtt_thread = threading.Thread(target=start_mqtt, daemon=True)
    mqtt_thread.start()

    # Mantener el programa vivo
    while True:
        pass

# -------------------------------------------------------
if __name__ == '__main__':
    main()
