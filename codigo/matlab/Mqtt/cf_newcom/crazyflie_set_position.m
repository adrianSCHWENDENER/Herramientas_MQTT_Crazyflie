function crazyflie_set_position(scf, x, y, z)
    % Esta función establece la posición deseada del dron Crazyflie en el espacio tridimensional,
    % sin modificar su orientación, mediante un módulo de comandos en Python.
    %
    % Argumentos:
    %   scf: Objeto SyncCrazyflie que representa la conexión activa con el dron Crazyflie.
    %   x, y, z: Coordenadas de la posición objetivo en el espacio 3D.
    % -------------------------------------------------------------------------------------
    
    % Importa y recarga el módulo Python para comandos de Crazyflie
    module_name = 'crazyflie_python_commands'; 
    py_module = py.importlib.import_module(module_name);  
    py.importlib.reload(py_module);

    % Intenta establecer la posición del dron usando la función `set_position`.
    try
        % Llama a `set_position` en el módulo Python, pasando las coordenadas de posición (x, y, z).
        % Esto mueve el dron a la posición especificada en el espacio tridimensional.
        py_module.set_position(scf, x, y, z);

    catch ME
        % Si ocurre un error al establecer la posición, muestra un mensaje de error detallado
        % con la información del problema.
        error('Error using crazyflie_python_commands>set_position: %s', ME.message);
    end  
end 