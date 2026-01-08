% =========================================================================
% EXPERIMENTOS CON CRAZYFLIE 2.1
% -------------------------------------------------------------------------
% Experimento 7: Despegue con modificación en controlador PID de eje Z
% =========================================================================

%% Parte 1: Carpeta con herramientas de software 
% Se añade al path de Matlab la carpeta con las funciones Crazyflie
addpath('crazyflie');

%% Parte 2: Establecer valores para las ganancias del controlador
% Valores a establecer en las ganacias del controlador PID del eje Z
Kp = 2.00; % Ganancia propocional
Ki = 5.00; % Ganancia integrativa
Kd = 0.00; % Ganancia derivativa

%% Parte 3: Secuencia del experimento
% RECORDATORIO: Previo a ejecutar esta sección debe conectar el dispositivo 
% Crazyradio en algún puerto USB de su ordenador y encender el Crazyflie. 

% Importante, antes de ejecutar esta sección de código debe asegurarse que
% el dron tiene espacio físico suficiente para completar el vuelo.

% Secuencia del experimento:
% Conexión con Crazyflie
dron_id = 8; % ID del dron Crazyflie específico a utilizar
crazyflie_1 = crazyflie_connect(dron_id);
% Configurar las nuevas ganancias en el controlador PID del eje Z
crazyflie_set_pid_z(crazyflie_1, Kp, Ki, Kd);
% Despegue a altura predeterminada
crazyflie_takeoff(crazyflie_1); 
% Tiempo de vuelo luego del despegue
pause(5); % Colocar un tiempo considerable para que se estabilice 
% Aterrizaje
crazyflie_land(crazyflie_1); 
% Desconexión
crazyflie_disconnect(crazyflie_1); 