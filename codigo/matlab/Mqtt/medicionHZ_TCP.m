% =========================================================================
% Medición y grafica de la velocidad de entrega de datos del servidor TCP/IP.
% =========================================================================

%% === Carpetas con herramientas de software ===
addpath('robotat');

%% ==============================================
clear; clc; close all;

% Conexión TCP/IP
robotat = robotat_connect();

% Parámetros
marker_id = 31; % ID del marcador
duracion = 60; % segundos

% Variables 
mensaje_count = 0;
frecuencias = zeros(1, 1000); %Prealocación (estimado)
tiempos = zeros(1, 1000);
idx = 0;
t_inicio = tic;

while toc(t_inicio) < duracion
    % Lectura TCP/IP
    pose = robotat_get_pose(robotat, marker_id, 'eulxyz');
    if ~isempty(pose)
        mensaje_count = mensaje_count + 1;
    end
    clear pose
    
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
fprintf('Frecuencia promedio final: %.2f lecturas/s\n', frecuencia_final);

% Gráfica
figure('Name','Frecuencia promedio de recepción TCP/IP','NumberTitle','off');
plot(tiempos, frecuencias, '-o', 'DisplayName', 'Frecuencia promedio');
hold on;
yline(frecuencia_final, '--r', sprintf('Promedio final: %.2f mensajes/s', frecuencia_final), ...
    'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'bottom');
grid on;
xlabel('Tiempo [s]');
ylabel('Frecuencia promedio [mensajes/s]');
title('Frecuencia promedio de recepción TCP/IP');

%% === Cierre de conexión ===
robotat_disconnect(robotat);
close all;
clear;
clc;
