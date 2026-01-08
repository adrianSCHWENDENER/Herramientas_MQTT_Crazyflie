% =========================================================================
% Ejemplo de conexión MQTT.
% =========================================================================

%% ==============================================
clear; clc; close all;

% Globales a usar en el callback

% Parámetros
marker_id = 31; % ID del marcador

% Conexión MQTT
mqttObj = mqttclient("tcp://192.168.50.200", Port=1880, KeepAliveDuration=180);
subscribe(mqttObj, "mocap/drone3", Callback=@(topic,message) mqttCB(topic, message, marker_id, [], []));

%% === Cierre de conexión ===
clear mqttObj; % borrar el objeto MQTT para dejar de recibir datos
close all;
clear;
clc;

%% === Callback a implementar ===

% disp(msgStr);
