function crazyflie_goto_robotat(crazyflie, x, y, z, velocity, tcp_obj, agent_id)
    % Esta función controla el movimiento de un dron Crazyflie para que se desplace a una
    % posición específica, verifique su pose a través de un sistema de captura de movimiento
    % y actualice su posición en el espacio absoluto.
    %
    % Argumentos:
    %   crazyflie: Objeto que representa el dron Crazyflie.
    %   x, y, z: Coordenadas de la posición objetivo relativa a alcanzar.
    %   velocity: Velocidad deseada para el desplazamiento del dron.
    %   tcp_obj: Objeto TCP para la comunicación con el sistema de captura de movimiento.
    %   agent_id: Identificador del dron en el sistema de captura de movimiento (1-100).
    % -------------------------------------------------------------------------------------
    
    % Importa y recarga el módulo Python para comandos de Crazyflie
    module_name = 'crazyflie_python_commands';
    py_module = py.importlib.import_module(module_name);
    py.importlib.reload(py_module);

    % Intento de mover el dron a la posición objetivo especificada.
    try        
        % Llama a `move_to_position` en Python, que mueve el dron a las coordenadas (x, y, z)
        % relativas con una velocidad especificada.
        py_module.move_to_position(crazyflie, x, y, z, velocity);

    catch ME
        % Si ocurre un error en el movimiento, muestra una advertencia y sale de la función.
        warning('Error using crazyflie_python_commands>move_to_position');
        return;
    end

    % Obtención de la pose actual del dron a través del objeto TCP y el ID del agente.
    try
        if (min(agent_id) <= 0 || max(agent_id) > 100)
            error('ERROR: Invalid ID(s).');
        end

        % Configura la solicitud de obtención de pose:
        s.dst = 1; % DST_ROBOTAT
        s.cmd = 1; % CMD_GET_POSE
        s.pld = round(agent_id);
        % Envía la solicitud de pose al servidor mediante el objeto TCP.
        write(tcp_obj, uint8(jsonencode(s)));

        % Espera la respuesta del servidor hasta alcanzar un tiempo de espera máximo.
        timeout_count = 0;
        timeout_in100ms = 1 / 0.1; % Máximo tiempo de espera (10 segundos).
        while (tcp_obj.BytesAvailable == 0 && timeout_count < timeout_in100ms)
            timeout_count = timeout_count + 1;
            pause(0.1);
        end

        % Verifica si se agotó el tiempo de espera sin recibir datos.
        if (timeout_count == timeout_in100ms)
            error('ERROR: Failed to receive data from the server.');
        end

        % Decodifica la respuesta del servidor para obtener los datos de la pose.
        mocap_data = jsondecode(char(read(tcp_obj)));
        mocap_data = reshape(mocap_data, [7, numel(agent_id)])';

        % Extrae la nueva posición absoluta en (x, y, z).
        new_x = mocap_data(1, 1);
        new_y = mocap_data(1, 2);
        new_z = mocap_data(1, 3);

    catch ME
        % Si ocurre un error al obtener la pose, muestra una advertencia y sale de la función.
        warning('Error obtaining the Crazyflie pose');
        return; 
    end

    % Actualización de la posición absoluta del dron con los valores obtenidos.
    try
        % Llama a `set_position` en el módulo Python para actualizar la posición del dron
        % en el sistema de referencia global.
        py_module.set_position(crazyflie, new_x, new_y, new_z);

    catch ME
        % Si ocurre un error al actualizar la posición, muestra una advertencia y sale de la función.
        warning('Error using crazyflie_python_commands>set_position');
        return; 
    end
end
