% =========================================================================
% EXPERIMENTOS CON CRAZYFLIE 2.1
% -------------------------------------------------------------------------
% Experimento 6: Trayectoria circular con fusión de sensores
% =========================================================================

%% Parte 1: Carpeta con herramientas de software
% Se añade al path de Matlab la carpeta con las funciones Crazyflie
addpath('crazyflie');
% Se añade al path de Matlab la carpeta con las funciones Robotat
addpath('robotat');

%% Parte 2: Conexión con Robotat y Crazyflie
dron_id = 8; % ID del dron Crazyflie a utilizar
marker_id = 28; % ID del marker del Crazyflie dentro del Robotat

% Conexión con Robotat y Crazyflie
robotat = robotat_connect();
crazyflie_1 = crazyflie_connect(dron_id);
robotat_trvisualize(robotat, 28);

%% Parte 3: Generación de trayectoria
% Se generará una trayectoria circular de 1.0 metro de diámetro a una 
% altura dada, a partir del punto de despegue del Crazyflie. 

% Obtener la pose inicial del dron por medio sistema de captura del Robotat
posicion_inicial = robotat_get_pose(robotat, marker_id, 'eulxyz');
% Establecer la posición inicial absoluta del dron
crazyflie_set_position(crazyflie_1, posicion_inicial(1), posicion_inicial(2), posicion_inicial(3));

% Información del vuelo 
altura_de_despegue = 0.50; % (en metros)
tiempo_de_despegue = 0.75; % (en segundos)
radio_de_trayectoria = 0.50; % (en metros)
velocidad_de_vuelo = 1.00; % (en metros/segundo)

% Generación de puntos clave de la trayectoria
punto_de_despegue = posicion_inicial(1:3) + [0.0, 0.0, altura_de_despegue];
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

%% Parte 4: Ejecución de vuelo en Crazyflie con Flow Deck
% Recordatorio: Previo a ejecutar esta sección debe conectar el dispositivo 
% Crazyradio en algún puerto USB de su ordenador y encender el Crazyflie. 

% Importante, antes de ejecutar esta sección de código debe asegurarse que
% el dron tiene espacio físico suficiente para completar la trayectoria.

% Prueba de obtencion de figura .........................................
% Preasignar la matriz para las posiciones
posiciones = zeros(N, 6);  % Cada fila será la pose del dron en una iteración
%........................................................................

% Secuencia del experimento:
% Despegue a una altura específica en un tiempo dado
crazyflie_takeoff(crazyflie_1, altura_de_despegue, tiempo_de_despegue); 
pause(0.5); % tiempo de seguridad
% Seguimiento de la trayectoria a la velocidad especificada con correción
% de posición utilizando lecturas del sistema de captura del Robotat

for i = 1:N
    crazyflie_goto_robotat(crazyflie_1, x(i), y(i), z(i), velocidad_de_vuelo, robotat, marker_id);
    
    % Prueba de obtencion de figura .....................................
    % Obtener y guardar la posición actual
    posicion_actual = robotat_get_pose(robotat, marker_id, 'eulxyz');
    posiciones(i, :) = posicion_actual;
    %....................................................................

end
pause(0.5); % tiempo de seguridad
% Aterrizaje
crazyflie_land(crazyflie_1); 
% Desconexión
crazyflie_disconnect(crazyflie_1); 

%% Grafica de figura ...................................................
% Visualización 3D
figure;

% Trayectoria teórica (planificada)
plot3(x, y, z, 'r*-', 'DisplayName', 'Trayectoria Teórica'); % Línea de la trayectoria completa
hold on;

% Trayectoria real (medida por Robotat)
x_real = posiciones(:,1);
y_real = posiciones(:,2);
z_real = posiciones(:,3);
plot3(x_real, y_real, z_real, 'b.-', 'DisplayName', 'Trayectoria Real');

% Puntos de despegue y aterrizaje
plot3(posicion_inicial(1), posicion_inicial(2), posicion_inicial(3), 'go', 'MarkerSize', 10, 'DisplayName', 'Posición Inicial');
plot3(punto_de_aterrizaje(1), punto_de_aterrizaje(2), punto_de_aterrizaje(3), 'ko', 'MarkerSize', 10, 'DisplayName', 'Punto de Aterrizaje');

% Ejes y formato
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
title('Comparación de Trayectoria del Dron');
legend('Location', 'best');
grid on;
axis equal;
axis([-1 1 -1 1 0 1]);  % Ajusta según tu espacio de vuelo
view(3);
hold off;
