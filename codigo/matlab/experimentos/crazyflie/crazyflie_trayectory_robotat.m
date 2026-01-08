function crazyflie_trayectory_robotat(crazyflie, x, y, z, velocity, tcp_obj, agent_id)
    % Esta función dirige al dron Crazyflie a seguir una trayectoria definida por los puntos
    % en los arreglos x, y, y z. El dron se desplaza de un punto a otro a la velocidad
    % especificada.
    %
    % Argumentos:
    %   crazyflie: Objeto que representa el dron Crazyflie.
    %   x, y, z: Arreglos de coordenadas para la trayectoria en el espacio 3D.
    %   velocity: Velocidad de desplazamiento del dron entre los puntos de la trayectoria.
    %   tcp_obj: Objeto TCP utilizado para la comunicación con el sistema de captura de movimiento.
    %   agent_id: ID del dron en el sistema de captura de movimiento (para identificarlo en el sistema).
    % -------------------------------------------------------------------------------------

    % Verifica si los arreglos de entrada (x, y, z) tienen la misma longitud.
    % Si no, lanza un error indicando que deben tener el mismo número de elementos.
    if length(x) ~= length(y) || length(y) ~= length(z)
        error('The x, y, and z arrays must have the same length');
    end

    % Refuerza la posición inicial moviendo el dron al primer punto de la trayectoria.
    crazyflie_goto_robotat(crazyflie, x(1), y(1), z(1), velocity, tcp_obj, agent_id);

    % Bucle que recorre cada punto en la trayectoria.
    for i = 1:length(x)
        % Mueve el dron al punto actual en la trayectoria, definido por las coordenadas
        % x(i), y(i), z(i).
        crazyflie_goto_robotat(crazyflie, x(i), y(i), z(i), velocity, tcp_obj, agent_id);
    end

    % Refuerza la posición final moviendo el dron al último punto de la trayectoria.
    crazyflie_goto_robotat(crazyflie, x(end), y(end), z(end), velocity, tcp_obj, agent_id);

    % Proporciona un mensaje de retroalimentación indicando que la trayectoria ha sido completada.
    fprintf('Trajectory completed successfully.\n');
end
