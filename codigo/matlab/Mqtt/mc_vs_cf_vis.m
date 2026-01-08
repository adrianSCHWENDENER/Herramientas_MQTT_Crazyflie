% =========================================================================
% Comparación en tiempo real de posicion segun MoCap y la posición según el
% dron Crazyflie, con retroalimentación del MoCap.
% =========================================================================

%% === Carpetas con herramientas de software ===
addpath('cf_newcom');

%% ==============================================
clear; clc; close all;

% Globales a usar en el callback
global x_m y_m z_m idx_m h_mocap_traj h_mocap_point TAIL_LENGTH

% Parámetros
TAIL_LENGTH = 100;
dron_id = 8; % ID del dron Crazyflie a utilizar
marker_id = 31; % ID del marcador

% Configuración de figura
figure('Name','Comparación Crazyflie vs MoCap');
ax = gca;
grid(ax, 'on');
xlabel(ax, 'X (m)');
ylabel(ax, 'Y (m)');
zlabel(ax, 'Z (m)');
title(ax, 'Comparación de posición: Crazyflie vs MoCap');
hold(ax, 'on');
view(45, 30);

h_mocap_traj = plot3(ax, NaN, NaN, NaN, 'r-', 'LineWidth', 1.5, 'DisplayName', 'MoCap');
h_mocap_point = plot3(ax, NaN, NaN, NaN, 'ro', 'MarkerFaceColor', 'b');

h_cf_traj = plot3(ax, NaN, NaN, NaN, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Crazyflie');
h_cf_point = plot3(ax, NaN, NaN, NaN, 'bo', 'MarkerFaceColor', 'r');

xlim(ax, [-3 3]);
ylim(ax, [-3 3]);
zlim(ax, [0 2]);
axis(ax, 'equal');
axis(ax, 'manual');     % Congela los límites actuales del eje
ax.ZDir = 'normal';

% Prealocación (buffers circulares)
x_m = NaN(1, TAIL_LENGTH);
y_m = NaN(1, TAIL_LENGTH);
z_m = NaN(1, TAIL_LENGTH);
idx_m = 0;

x_cf = NaN(1, TAIL_LENGTH);
y_cf = NaN(1, TAIL_LENGTH);
z_cf = NaN(1, TAIL_LENGTH);
idx_cf = 0;

%% === Bucle principal ===

% Conexión Crazyflie
crazyflie_1 = crazyflie_connect(dron_id);

% Conexión MQTT
mqttObj = mqttclient("tcp://192.168.50.200", Port=1880, KeepAliveDuration=180);
subscribe(mqttObj, "mocap/drone3", Callback=@(topic,message) mqttCB(topic, message, marker_id, [], crazyflie_1));

while true
    % Lectura de posición del dron
    try
        pose_cf = crazyflie_get_pose(crazyflie_1); % [x, y, z, roll, pitch, yaw]
        if ~isempty(pose_cf)
            idx_cf = mod(idx_cf, TAIL_LENGTH) + 1;
            x_cf(idx_cf) = pose_cf(1);
            y_cf(idx_cf) = pose_cf(2);
            z_cf(idx_cf) = pose_cf(3);
        end
    catch
        warning('Error al obtener la posición del Crazyflie.');
    end

    % Actualizar gráfica Crazyflie
    if any(~isnan(x_cf))
        order = [idx_cf+1:TAIL_LENGTH, 1:idx_cf]; % reordenar cola circular
        valid = ~isnan(x_cf(order));
        set(h_cf_traj, 'XData', x_cf(order(valid)), ...
                       'YData', y_cf(order(valid)), ...
                       'ZData', z_cf(order(valid)));
        set(h_cf_point, 'XData', x_cf(idx_cf), ...
                        'YData', y_cf(idx_cf), ...
                        'ZData', z_cf(idx_cf));
    end

    drawnow limitrate nocallbacks;
    pause(0.02);
end

%% === Cierre de conexión ===
crazyflie_disconnect(crazyflie_1); 
clear mqttObj; % borrar el objeto MQTT para dejar de recibir datos
close all;
clear;
clc;

%% === Callback a implementar ===

% global x_m y_m z_m idx_m h_mocap_traj h_mocap_point TAIL_LENGTH

% % Extraer posición
% xm = data.payload.pose.position.x;
% ym = data.payload.pose.position.y;
% zm = data.payload.pose.position.z;
% 
% % Retroalimentación de posición al dron
% crazyflie_set_position(scf, double(xm), double(ym), double(zm))
% 
% % === Buffer circular ===
% idx_m = mod(idx_m, TAIL_LENGTH) + 1;
% x_m(idx_m) = xm;
% y_m(idx_m) = ym;
% z_m(idx_m) = zm;
% 
% % === Reordenar cola circular ===
% order = [idx_m+1:TAIL_LENGTH, 1:idx_m];
% valid = ~isnan(x_m(order));  % omitir espacios vacíos
% 
% % === Actualizar gráficos MQTT (MoCap) ===
% set(h_mocap_traj, 'XData', x_m(order(valid)), ...
%                   'YData', y_m(order(valid)), ...
%                   'ZData', z_m(order(valid)));
% set(h_mocap_point, 'XData', x_m(idx_m), ...
%                    'YData', y_m(idx_m), ...
%                    'ZData', z_m(idx_m));
% 
% % === Refrescar figura sin interrumpir otros callbacks ===
% drawnow limitrate nocallbacks;