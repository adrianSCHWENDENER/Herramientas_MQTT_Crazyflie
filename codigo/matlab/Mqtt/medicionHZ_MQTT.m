% =========================================================================
% Medición y grafica de la velocidad de entrega de datos del servidor MQTT.
% =========================================================================

%% ==============================================
clear; clc; close all;

% Globales a usar en el callback
global mensaje_count
mensaje_count = 0;

% Parámetros
marker_id = 31; % ID del marcador
duracion = 60; % segundos

% Variables
frecuencias = zeros(1, 5000); % Prealocación estimada
tiempos = zeros(1, 5000);
idx = 0;

% Conexión MQTT
mqttObj = mqttclient("tcp://192.168.50.200", Port=1880, KeepAliveDuration=180);
subscribe(mqttObj, "mocap/drone3", Callback=@(topic,message) mqttCB(topic, message, marker_id, [], []));

t_inicio = tic;

while toc(t_inicio) < duracion
    % Frecuencia promedio
    t_actual = toc(t_inicio);
    frecuencia_prom = mensaje_count / t_actual;

    idx = idx + 1;
    tiempos(idx) = t_actual;
    frecuencias(idx) = frecuencia_prom;

    pause(0.02);
end

% Recortar vectores al tamaño real
tiempos = tiempos(1:idx);
frecuencias = frecuencias(1:idx);

% Resultados
frecuencia_final = frecuencias(end);
fprintf('\n=== Medición completada ===\n');
fprintf('Tiempo total: %.2f s\n', tiempos(end));
fprintf('Frecuencia promedio final: %.2f mensajes/s\n', frecuencia_final);

% Gráfica
figure('Name','Frecuencia promedio de recepción MQTT','NumberTitle','off');
plot(tiempos, frecuencias, '-o', 'DisplayName', 'Frecuencia promedio');
hold on;
yline(frecuencia_final, '--r', sprintf('Promedio final: %.2f mensajes/s', frecuencia_final), ...
    'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'bottom');
grid on;
xlabel('Tiempo [s]');
ylabel('Frecuencia promedio [mensajes/s]');
title('Frecuencia promedio de recepción MQTT');

%% === Cierre de conexión ===
clear mqttObj; % borrar el objeto MQTT para dejar de recibir datos
close all;
clear;
clc;

%% === Callback a implementar ===

% global mensaje_count

% mensaje_count = mensaje_count + 1;