% =========================================================================
% Comparación en tiempo real de flujo de datos del servidor MQTT y TCP/IP.
% =========================================================================

%% === Carpetas con herramientas de software ===
addpath('robotat');

%% ==============================================
clear; clc; close all;

% Globales a usar en el callback
global x_mqtt y_mqtt z_mqtt i_mqtt TAIL_LENGTH h_mqtt_traj h_mqtt_point

% Parámetros
TAIL_LENGTH = 100;
marker_id = 31; % ID del marcador

% Configuración de figuras
figure('Name','Comparación de posición: TCP/IP vs MQTT');

% Subplot TCP/IP
ax1 = subplot(1,2,1);
grid(ax1, 'on');
xlabel(ax1, 'X (m)'); ylabel(ax1, 'Y (m)'); zlabel(ax1, 'Z (m)');
title(ax1, 'TCP/IP');
view(ax1, 45, 30);
axis(ax1, 'equal');
xlim(ax1, [-2 2]); ylim(ax1, [-2 2]); zlim(ax1, [0 2]);
hold(ax1, 'on');
h_tcp_traj  = plot3(ax1, NaN, NaN, NaN, 'r-', 'LineWidth', 1.5);
h_tcp_point = plot3(ax1, NaN, NaN, NaN, 'ro', 'MarkerFaceColor', 'r');

% Subplot MQTT
ax2 = subplot(1,2,2);
grid(ax2, 'on');
xlabel(ax2, 'X (m)'); ylabel(ax2, 'Y (m)'); zlabel(ax2, 'Z (m)');
title(ax2, 'MQTT');
view(ax2, 45, 30);
axis(ax2, 'equal');
xlim(ax2, [-2 2]); ylim(ax2, [-2 2]); zlim(ax2, [0 2]);
hold(ax2, 'on');
h_mqtt_traj  = plot3(ax2, NaN, NaN, NaN, 'b-', 'LineWidth', 1.5);
h_mqtt_point = plot3(ax2, NaN, NaN, NaN, 'bo', 'MarkerFaceColor', 'b');

% Prealocación (buffers circulares)
x_tcp = NaN(1, TAIL_LENGTH);
y_tcp = NaN(1, TAIL_LENGTH);
z_tcp = NaN(1, TAIL_LENGTH);
i_tcp = 0;

x_mqtt = NaN(1, TAIL_LENGTH);
y_mqtt = NaN(1, TAIL_LENGTH);
z_mqtt = NaN(1, TAIL_LENGTH);
i_mqtt = 0;

%% === Bucle principal ===

% Conexión TCP/IP
robotat = robotat_connect();

% Conexion MQTT
mqttObj = mqttclient("tcp://192.168.50.200", Port=1880, KeepAliveDuration=180);
subscribe(mqttObj, "mocap/drone3", Callback=@(topic,message) mqttCB(topic, message, marker_id, [], []));

while true
    % Lectura TCP/IP
    try
        pos_tcp = robotat_get_pose(robotat, marker_id, 'eulxyz');
        if ~isempty(pos_tcp)
            i_tcp = mod(i_tcp, TAIL_LENGTH) + 1;
            x_tcp(i_tcp) = pos_tcp(1,1);
            y_tcp(i_tcp) = pos_tcp(1,2);
            z_tcp(i_tcp) = pos_tcp(1,3);
        end
    catch
        warning('Error al leer TCP.');
    end

    % Actualizar gráfica TCP/IP
    if any(~isnan(x_tcp))
        idx_tcp = [i_tcp+1:TAIL_LENGTH, 1:i_tcp];  % reordenar cola
        valid_tcp = ~isnan(x_tcp(idx_tcp));
        set(h_tcp_traj, 'XData', x_tcp(idx_tcp(valid_tcp)), ...
                        'YData', y_tcp(idx_tcp(valid_tcp)), ...
                        'ZData', z_tcp(idx_tcp(valid_tcp)));
        set(h_tcp_point, 'XData', x_tcp(i_tcp), ...
                         'YData', y_tcp(i_tcp), ...
                         'ZData', z_tcp(i_tcp));
    end

    drawnow limitrate;
    pause(0.02);
end

%% === Cierre de conexión ===
robotat_disconnect(robotat);
clear mqttObj; % borrar el objeto MQTT para dejar de recibir datos
close all;
clear;
clc;

%% === Callback a implementar ===

% global x_mqtt y_mqtt z_mqtt i_mqtt TAIL_LENGTH h_mqtt_traj h_mqtt_point

% % Extraer posición
% xm = data.payload.pose.position.x;
% ym = data.payload.pose.position.y;
% zm = data.payload.pose.position.z;
% 
% % Actualizar buffer circular
% i_mqtt = mod(i_mqtt, TAIL_LENGTH) + 1;
% x_mqtt(i_mqtt) = xm;
% y_mqtt(i_mqtt) = ym;
% z_mqtt(i_mqtt) = zm;
% 
% % Actualizar cola visible
% idx = [i_mqtt+1:TAIL_LENGTH, 1:i_mqtt];
% valid = ~isnan(x_mqtt(idx));
% 
% % Actualizar gráficos MQTT
% set(h_mqtt_traj, 'XData', x_mqtt(idx(valid)), ...
%                  'YData', y_mqtt(idx(valid)), ...
%                  'ZData', z_mqtt(idx(valid)));
% set(h_mqtt_point, 'XData', x_mqtt(i_mqtt), ...
%                   'YData', y_mqtt(i_mqtt), ...
%                   'ZData', z_mqtt(i_mqtt));
% 
% drawnow limitrate nocallbacks;
