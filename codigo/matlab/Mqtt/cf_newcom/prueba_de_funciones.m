% =========================================================================
% HERRAMIENTAS DE SOFTWARE PARA CONTROL DE CRAZYFLIE 2.1
% -------------------------------------------------------------------------
% Ejemplo de uso de las funciones Crazyflie
% =========================================================================

%% Carpetas con herramientas de software
% Se añade al path de Matlab la carpeta con las funciones Crazyflie
addpath('crazyflie');
% Se añade al path de Matlab la carpeta con las funciones Robotat
addpath('robotat');

%% Instrucciones generales
% Para verificar el funcionamiento de las funcines Crazyflie, es importante
% que consulte la documentación en el archivo leer_primero para tener en
% cuenta las características requeridas del entorno de experimentación.

% Para todos los experimentos es necesario que tenga conectado el
% dispositivo Crazyradio en algún puerto USB de su ordenador, el dron
% Crazyflie debe estar encendido y, en algunos casos, debe estar conectado
% a la red WiFi del ecosistema Robotat.

%% crazyflie_connect.m
% Función Crazyflie para incializar la conexión con un dron específico.
crazyflie_1 = crazyflie_connect(8);

%% crazyflie_disconnect.m
% Función Crazyflie para cerrar la conexión con el dron conectado.
crazyflie_disconnect(crazyflie_1);

%% crazyflie_detect_flow_deck.m
% Función Crazyflie para validar la detección de la placa de expansión Flow
% Deck sobre el dron Crazyflie conectado.
flowdeck = crazyflie_detect_flow_deck(crazyflie_1);

%% crazyflie_get_pid_values.m
% 
pose = crazyflie_get_pose(crazyflie_1);

%% Comando para actualización de posición con fuente externa
crazyflie_set_position(crazyflie_1, 1, 3, 0);

%% Comando para actualización de posición con fuente externa
crazyflie_set_position(crazyflie_1, 1, 3, 0);

%% Comando para lectura en conjunto de controladores PID de posición
PID = crazyflie_get_pid_values(crazyflie_1);

%% Comando para definir las nuevas ganancias de los controladores PID de posición
p_gains = struct('X', 4.75, 'Y', 2.5, 'Z', 2.0);
i_gains = struct('X', 0.1, 'Y', 0.1, 'Z', 0.2);
d_gains = struct('X', 0.0, 'Y', 0.0, 'Z', 0.1);
crazyflie_set_pid_values(crazyflie_1, p_gains, i_gains, d_gains);

%% Comando para lectura individual de controladores PID de posición
crazyflie_get_pid_x(crazyflie_1);
crazyflie_get_pid_y(crazyflie_1);
crazyflie_get_pid_z(crazyflie_1);

%% Comando para definir individualmente las nuevas ganancias de los controladores PID de posición
crazyflie_set_pid_x(crazyflie_1, 7, 2.5, 0.001);
crazyflie_set_pid_y(crazyflie_1, 6, 1.5, 0.002);
crazyflie_set_pid_z(crazyflie_1, 5, 0.5, 0.003);

%% Comando para realizar el despegue del Crazyflie
crazyflie_takeoff(crazyflie_1);

%% Comando para realizar el aterrizaje del Crazyflie
crazyflie_land(crazyflie_1);

%% Función de envío de posición
crazyflie_move_to_position(crazyflie_1, 0, 0, 1);