% =========================================================================
% EXPERIMENTOS CON CRAZYFLIE 2.1
% -------------------------------------------------------------------------
% Experimento 2: Despegue y aterrizaje
% =========================================================================

%% Parte 1: Carpeta con herramientas de software para interacción con Crazyflie
% Se añade al path de Matlab la carpeta con las funciones Crazyflie
addpath('crazyflie');

%% Parte 2: Secuencia del experimento
% RECORDATORIO: Previo a ejecutar esta sección debe conectar el dispositivo 
% Crazyradio en algún puerto USB de su ordenador y encender el Crazyflie. 

% Importante, antes de ejecutar esta sección de código debe asegurarse que
% el dron tiene espacio físico suficiente para completar el vuelo.

% Información del vuelo 
altura_de_despegue = 0.75; % (en metros)
tiempo_de_despegue = 2.0; % (en segundos)

% Secuencia del experimento:
% Conexión con Crazyflie
dron_id = 8; % ID del dron Crazyflie específico a utilizar
crazyflie_1 = crazyflie_connect(dron_id); 
% Despegue a una altura específica en un tiempo dado
crazyflie_takeoff(crazyflie_1, altura_de_despegue, tiempo_de_despegue); 
% Tiempo de vuelo luego del despegue
pause(1); 
% Aterrizaje
crazyflie_land(crazyflie_1); 
% Desconexión
crazyflie_disconnect(crazyflie_1); 