% =========================================================================
% EXPERIMENTOS CON CRAZYFLIE 2.1
% -------------------------------------------------------------------------
% Experimento 3: Vuelo a través de una trayectoria lineal
% =========================================================================

%% Parte 1: Carpeta con herramientas de software para interacción con Crazyflie
% Se añade al path de Matlab la carpeta con las funciones Crazyflie
addpath('crazyflie');

%% Parte 2: Generación de trayectoria
% Se generará una trayectoria lineal simple de 1.0 metro de distancia a
% partir del punto de despegue en dirección del eje X del Crazyflie. 

% Posición inicial relativa del dron (en metros)
posicion_inicial = [0.0, 0.0, 0.0];

% Información del vuelo 
altura_de_despegue = 0.50; % (en metros)
tiempo_de_despegue = 0.75; % (en segundos)
distancia_de_vuelo = 0.50; % (en metros)
velocidad_de_vuelo = 1.00; % (en metros/segundo)

% Generación de puntos clave de la trayectoria
punto_inicial_de_trayectoria = posicion_inicial + [0.0, 0.0, altura_de_despegue];
punto_final_de_trayectoria = punto_inicial_de_trayectoria + [distancia_de_vuelo, 0.0, 0.0];
punto_de_aterrizaje = punto_final_de_trayectoria - [0.0, 0.0, altura_de_despegue];

% Generación de la trayectoria
N = 5; % Cantidad de puntos en la trayectoria
x = linspace(punto_inicial_de_trayectoria(1), punto_final_de_trayectoria(1), N);
y = linspace(punto_inicial_de_trayectoria(2), punto_final_de_trayectoria(2), N);
z = linspace(punto_inicial_de_trayectoria(3), punto_final_de_trayectoria(3), N);

% Visualización 3D
figure;
plot3(x, y, z, 'r*-', 'DisplayName', 'Trayectoria'); % Línea de la trayectoria
hold on;
plot3(posicion_inicial(1), posicion_inicial(2), posicion_inicial(3), 'go', 'MarkerSize', 10, 'DisplayName', 'Posición incial'); % Punto de despegue en verde
plot3(punto_de_aterrizaje(1), punto_de_aterrizaje(2), punto_de_aterrizaje(3), 'bo', 'MarkerSize', 10, 'DisplayName', 'Punto de Aterrizaje'); % Punto de aterrizaje en azul
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
title('Trayectoria generada');
legend; % Muestra la leyenda
grid on;
axis equal;
axis([-0.5 1.5 -1 1 0 1.5]);
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