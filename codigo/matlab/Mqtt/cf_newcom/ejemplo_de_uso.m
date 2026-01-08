% Conectarse con un dron Crazyflie específico
dron_id = 1;
crazyflie_1 = crazyflie_connect(dron_id); 

% Detectar si la placa Flow Deck está conectada
if crazyflie_detect_flow_deck(crazyflie_1)
    disp("Placa Flow Deck detectada.")
else
    disp("Placa Flow Deck no detectada.")
end

% Ejecturar el despegue con valores predeterminados
crazyflie_takeoff(crazyflie_1);

% Moverse a la posición (0.5, 0.0, 0.5) a una velocidad de 1 m/s
crazyflie_move_to_position(0.5, 0.0, 0.5, 1.0);

% Ejecutar el aterrizaje del dron con valores predeterminados
crazyflie_land(crazyflie_1);

% Finalizar la conexión
crazyflie_disconnect(crazyflie_1); 