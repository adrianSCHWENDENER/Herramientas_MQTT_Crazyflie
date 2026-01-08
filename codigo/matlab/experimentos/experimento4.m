% =========================================================================
% EXPERIMENTOS CON CRAZYFLIE 2.1
% -------------------------------------------------------------------------
% Experimento 4: Vuelo a través de una trayectoria circular
% =========================================================================

%% Parte 1: Carpeta con herramientas de software para interacción con Crazyflie
% Se añade al path de Matlab la carpeta con las funciones Crazyflie
addpath('crazyflie');

%% Parte 2: Generación de trayectoria
% Se generará una trayectoria circular de 1.0 metro de diámetro a una 
% altura dada, a partir del punto de despegue del Crazyflie. 

% Posición inicial relativa del dron (en metros)
posicion_inicial = [0.0, 0.0, 0.0];

% Información del vuelo 
altura_de_despegue = 0.50; % (en metros)
tiempo_de_despegue = 0.75; % (en segundos)
radio_de_trayectoria = 0.50; % (en metros)
velocidad_de_vuelo = 1.00; % (en metros/segundo)

% Generación de puntos clave de la trayectoria
punto_de_despegue = posicion_inicial + [0.0, 0.0, altura_de_despegue];
punto_inicial_de_trayectoria = punto_de_despegue + [radio_de_trayectoria, 0.0, 0.0];
punto_final_de_trayectoria = punto_inicial_de_trayectoria - [radio_de_trayectoria, 0.0, 0.25];
punto_de_aterrizaje = punto_final_de_trayectoria - [0.0, 0.0, altura_de_despegue];

% Generación de la trayectoria
% Movimiento lineal hasta el punto inicial de la circunferencia
N1 = 5;
x_lineal = linspace(punto_de_despegue(1), punto_inicial_de_trayectoria(1), N1);
y_lineal = linspace(punto_de_despegue(2), punto_inicial_de_trayectoria(2), N1);
z_lineal = linspace(punto_de_despegue(3), punto_inicial_de_trayectoria(3), N1);

% Trayectoria circular en el plano XY a altura constante
N2 = 20;
theta = linspace(0, 2*pi, N2); % Dividir la circunferencia en 20 puntos
x_circulo = punto_de_despegue(1) + radio_de_trayectoria * cos(theta);
y_circulo = punto_de_despegue(2) + radio_de_trayectoria * sin(theta);
z_circulo = ones(size(theta)) * punto_de_despegue(3); % Mantener la altura constante

% Regreso al centro del círculo
N3 = 5;
x_regreso = linspace(x_circulo(end), punto_final_de_trayectoria(1), N3);
y_regreso = linspace(y_circulo(end), punto_final_de_trayectoria(2), N3);
z_regreso = linspace(z_circulo(end), punto_final_de_trayectoria(3), N3);

% Concatenación de todos los segmentos en un solo conjunto de arreglos x, y, z
x = [x_lineal, x_circulo, x_regreso];
y = [y_lineal, y_circulo, y_regreso];
z = [z_lineal, z_circulo, z_regreso];
N = length(x);

% Visualización 3D
figure;
plot3(x, y, z, 'r*-', 'DisplayName', 'Trayectoria Completa'); % Línea de la trayectoria completa
hold on;

% Puntos de despegue y aterrizaje
plot3(posicion_inicial(1), posicion_inicial(2), posicion_inicial(3), 'go', 'MarkerSize', 10, 'DisplayName', 'Posición Inicial');
plot3(punto_de_aterrizaje(1), punto_de_aterrizaje(2), punto_de_aterrizaje(3), 'bo', 'MarkerSize', 10, 'DisplayName', 'Punto de Aterrizaje');

xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
title('Trayectoria Completa del Dron');
legend; % Muestra la leyenda
grid on;
axis equal;
axis([-1 1 -1 1 0 1]);
view(3);
hold off;

%% Ejecución de vuelo en Crazyflie con Flow Deck
% Recordatorio: Previo a ejecutar esta sección debe conectar el dispositivo 
% Crazyradio en algún puerto USB de su ordenador y encender el Crazyflie. 

% Importante, antes de ejecutar esta sección de código debe asegurarse que
% el dron tiene espacio físico suficiente para completar la trayectoria.

% Secuencia del experimento:
% Conexión con Crazyflie
dron_id = 8; 
crazyflie_1 = crazyflie_connect(dron_id); 
% Despegue a una altura específica en un tiempo dado
crazyflie_takeoff(crazyflie_1, altura_de_despegue, tiempo_de_despegue); 
pause(0.5); % tiempo de seguridad
% Seguimiento de la trayectoria a la velocidad especificada
for i = 1:N
    crazyflie_move_to_position(crazyflie_1, x(i), y(i), z(i), velocidad_de_vuelo);
end
pause(0.5); % tiempo de seguridad
% Aterrizaje
crazyflie_land(crazyflie_1); 
% Desconexión
crazyflie_disconnect(crazyflie_1); 