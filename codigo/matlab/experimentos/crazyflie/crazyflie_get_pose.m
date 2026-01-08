function pose = crazyflie_get_pose(scf)
    % Esta función obtiene la pose actual del dron Crazyflie (posición y orientación)
    % usando un módulo de comandos en Python.
    %
    % Argumento:
    %   scf: Objeto de conexión que representa la conexión activa con el dron Crazyflie.
    %
    % Salida:
    %   pose: Vector que contiene la pose del dron. Normalmente incluye las coordenadas
    %         de posición (x, y, z) y posiblemente la orientación (roll, pitch, yaw) en
    %         función de la configuración del módulo de comandos en Python.
    % -------------------------------------------------------------------------------------

    % Importa y recarga el módulo Python para comandos de Crazyflie
    module_name = 'crazyflie_python_commands'; 
    py_module = py.importlib.import_module(module_name);  
    py.importlib.reload(py_module);

    % Intenta obtener la pose del dron Crazyflie usando la función Python correspondiente.
    try
        % Llama a la función `get_pose` en el módulo Python, que retorna la pose del dron.
        % Convierte el resultado a tipo `double` para su uso en MATLAB.
        pose = double(py_module.get_pose(scf));
        
    catch ME
        % Si ocurre un error al obtener la pose, muestra un mensaje de error detallado
        % con la información del problema para facilitar la depuración.
        error('Error using crazyflie_python_commands>get_pose: %s', ME.message);
    end  
end 