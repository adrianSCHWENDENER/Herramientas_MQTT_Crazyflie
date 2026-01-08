function crazyflie_set_pose(scf, x, y, z, qx, qy, qz, qw)
    % Esta función establece la pose deseada del dron Crazyflie en el espacio tridimensional,
    % incluyendo su posición y orientación, mediante un módulo de comandos en Python.
    %
    % Argumentos:
    %   scf: Objeto SyncCrazyflie que representa la conexión activa con el dron Crazyflie.
    %   x, y, z: Coordenadas de la posición objetivo en el espacio 3D.
    %   qx, qy, qz, qw: Componentes del cuaternión que definen la orientación deseada
    %                   del dron en el espacio.
    % -------------------------------------------------------------------------------------

    % Importa y recarga el módulo Python para comandos de Crazyflie
    module_name = 'crazyflie_python_commands'; 
    py_module = py.importlib.import_module(module_name);  
    py.importlib.reload(py_module);

    % Intenta establecer la pose del dron usando la función `set_pose`.
    try
        % Llama a `set_pose` en el módulo Python, pasando las coordenadas de posición (x, y, z)
        % y los componentes del cuaternión (qx, qy, qz, qw) para definir la orientación.
        py_module.set_pose(scf, x, y, z, qx, qy, qz, qw);
    catch ME
        % Si ocurre un error al establecer la pose, muestra un mensaje de error detallado
        % con la información del problema.
        error('Error using crazyflie_python_commands>set_pose: %s', ME.message);
    end  
end 