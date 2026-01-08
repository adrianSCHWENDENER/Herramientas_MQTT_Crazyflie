% =========================================================================
% Medición y grafica de retraso (LAG) de los mensajes recibidos del
% servidor MQTT.
% =========================================================================

%% === Carpetas con herramientas de software ===
addpath('cf_newcom');

%% ==============================================
clear; clc; close all;

% Globales a usar en el callback
global total_msgs processed_msgs processed_ratio timestamps idx last_ts start_time
total_msgs = 0;
processed_msgs = 0;
processed_ratio = zeros(1, 5000);
timestamps = zeros(1, 5000);
last_ts = datetime.empty;
idx = 0;

% Parámetros
dron_id = 8; % ID del dron Crazyflie a utilizar
marker_id = 31; % ID del marcador
duracion = 60; % segundos
start_time = tic; % inicio de medición

% Conexión Crazyflie
crazyflie_1 = crazyflie_connect(dron_id);

% Conexión MQTT
mqttObj = mqttclient("tcp://192.168.50.200", Port=1880, KeepAliveDuration=180);
subscribe(mqttObj, "mocap/drone3", Callback=@(topic,message) mqttCB(topic, message, marker_id, [], crazyflie_1));

pause(duracion); % Esperar mientras se ejecuta el callback

clear mqttObj; % borrar el objeto MQTT para dejar de recibir datos

processed_ratio = processed_ratio(1:idx);
timestamps = timestamps(1:idx);

% Resultados
fprintf('\n=== Medición completada ===\n');
fprintf('Mensajes totales: %d\n', total_msgs);
fprintf('Mensajes procesados: %d\n', processed_msgs);
fprintf('Porcentaje procesado: %.2f%%\n', (processed_msgs/total_msgs)*100);

% --- Gráfica ---
figure('Name', 'Fracción de mensajes procesados');
plot(timestamps, processed_ratio, '-o', 'MarkerSize', 3);
xlabel('Tiempo (s)');
ylabel('Fracción acumulada de mensajes procesados');
title('Eficiencia de recepción MQTT');
ylim([0 1.05]);
grid on;
%% === Cierre de conexión ===
crazyflie_disconnect(crazyflie_1); 
close all;
clear;
clc;

%% === Callback a implementar ===

% global total_msgs processed_msgs processed_ratio timestamps idx last_ts start_time

% total_msgs = total_msgs + 1;
% 
% pos = data.payload.pose.position;
% ts_str = data.ts; % tiempo de envío (ts del paquete)
% 
% % Validar timestamp
% if ~isempty(ts_str)
%     msg_time = datetime(strrep(ts_str, 'Z', '+00:00'), ...
%         'InputFormat', 'yyyy-MM-dd''T''HH:mm:ssXXX', ...
%         'TimeZone', 'UTC');
% 
%     % Ignorar mensajes duplicados o antiguos
%     if ~isempty(last_ts) && msg_time <= last_ts
%         return
%     end
%     last_ts = msg_time;
% 
%     % === Mensaje válido ===
%     processed_msgs = processed_msgs + 1;
% 
%     % Enviar posición al dron (EKF)
%     crazyflie_set_position(scf, double(pos.x), double(pos.y), double(pos.z))
% 
%     % Actualizar métricas
%     if idx < numel(processed_ratio)
%         idx = idx + 1;
%         processed_ratio(idx) = processed_msgs / total_msgs;
%         timestamps(idx) = toc(start_time);
%     end
% end
