% =========================================================================
% Visualización en tiempo real de flujo de datos del servidor TCP/IP.
% =========================================================================

%% Carpetas con herramientas de software
addpath('robotat');

%% ==============================================
clear; clc; close all;

robotat = robotat_connect();

figure(1)
h = animatedline('Color', 'b', 'LineWidth', 2);
axis([-2 2 -2 2 0 2])
grid on
xlabel('X')
ylabel('Y')
zlabel('Z')
title('Animación de Curva 3D')

% Parámetro: número de puntos visibles
N = 100;  % <-- ajusta este valor según prefieras

% Vectores prealocados para eficiencia
xdata = zeros(1, N);
ydata = zeros(1, N);
zdata = zeros(1, N);
idx = 0;

while true
    posmov = robotat_get_pose(robotat, 28, 'eulxyz');
    
    % Actualizar índice circular
    idx = idx + 1;
    if idx > N
        idx = N;  % se mantiene fijo para tener siempre N puntos
        % Desplazar los datos hacia la izquierda (efecto "cola")
        xdata(1:end-1) = xdata(2:end);
        ydata(1:end-1) = ydata(2:end);
        zdata(1:end-1) = zdata(2:end);
    end
    
    % Guardar nuevo punto al final
    xdata(idx) = posmov(1,1);
    ydata(idx) = posmov(1,2);
    zdata(idx) = posmov(1,3);
    
    % Limpiar y redibujar los últimos puntos
    clearpoints(h);
    addpoints(h, xdata(1:idx), ydata(1:idx), zdata(1:idx));
    drawnow;
end

%% --- CIERRE DE CONEXIÓN ---
robotat_disconnect(robotat);
disp("Conexión TCP cerrada.");
