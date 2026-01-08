% =========================================================================
% EXPERIMENTOS CON CRAZYFLIE 2.1
% -------------------------------------------------------------------------
% Experimento 1: Conexión y desconexión
% =========================================================================

%% Parte 1: Carpeta con herramientas de software para interacción con Crazyflie
% Se añade al path de Matlab la carpeta con las funciones Crazyflie
addpath('crazyflie');

%% Parte 2: Secuencia del experimento
% RECORDATORIO: Previo a ejecutar esta sección debe conectar el dispositivo 
% Crazyradio en algún puerto USB de su ordenador y encender el Crazyflie. 

% Secuencia del experimento:
% Conexión con Crazyflie
dron_id = 8; % ID del dron Crazyflie específico a utilizar
crazyflie_1 = crazyflie_connect(dron_id); 
% Detección de placa Flow Deck
if crazyflie_detect_flow_deck(crazyflie_1) 
    disp("Placa Flow Deck detectada.")
else
    disp("Placa Flow Deck no detectada.")
end
% Desconexión
crazyflie_disconnect(crazyflie_1); 