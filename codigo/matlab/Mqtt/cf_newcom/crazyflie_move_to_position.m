function crazyflie_move_to_position(scf, x, y, z, v)  
    % Esta función mueve el dron Crazyflie a una posición específica (x, y, z)
    % con una velocidad especificada.
    %
    % Argumentos:
    %   scf: Objeto SyncCrazyflie que representa la conexión activa con el dron Crazyflie.
    %   x, y, z: Coordenadas numéricas de la posición objetivo en el espacio 3D.
    %   v: Velocidad a la que el dron debe desplazarse hacia la posición objetivo.
    % -------------------------------------------------------------------------------------
    
    % Verifica que los valores de posición (x, y, z) sean numéricos.
    % Si no son numéricos, lanza un error.
    if ~isnumeric(x) || ~isnumeric(y) || ~isnumeric(z)
        error('ERROR: x, y, and z must be numeric values.');
    end

    % Importa y recarga el módulo Python para comandos de Crazyflie
    module_name = 'crazyflie_python_commands'; 
    py_module = py.importlib.import_module(module_name);  
    py.importlib.reload(py_module);

    % Intenta mover el dron a la posición deseada usando la función `move_to_position`.
    try
        % Llama a `move_to_position` en el módulo Python, que controla el dron
        % para desplazarse a las coordenadas (x, y, z) con la velocidad `v`.
        py_module.move_to_position(scf, x, y, z, v);

    catch ME
        % Si ocurre un error durante el movimiento, muestra un mensaje de error detallado.
        error('Error using crazyflie_python_commands>move_to_position: %s', ME.message);
    end  
end