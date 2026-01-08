function pid_y = crazyflie_get_pid_y(scf)
    % Esta función obtiene los valores del controlador PID para el eje Y del dron Crazyflie
    % utilizando un módulo de comandos en Python.
    %
    % Argumento:
    %   scf: Objeto de conexión que representa la conexión activa con el dron Crazyflie.
    %
    % Salida:
    %   pid_y: Estructura que contiene los valores PID para el eje Y.
    %          Incluye tres campos: 'P' (Proporcional), 'I' (Integral) y 'D' (Derivativo).}
    % -------------------------------------------------------------------------------------

    % Importa y recarga el módulo Python para comandos de Crazyflie
    module_name = 'crazyflie_python_commands'; 
    py_module = py.importlib.import_module(module_name);  
    py.importlib.reload(py_module);

    % Intenta obtener los valores PID para el eje Y usando la función Python.
    try
        % Llama a la función `get_pid_y` en el módulo Python, que retorna un diccionario
        % con los valores P, I y D del controlador PID para el eje Y.
        pid_result = py_module.get_pid_y(scf);

        % Extrae y convierte cada valor PID del diccionario Python.    
        pid_y.P = double(pid_result{'P'});
        pid_y.I = double(pid_result{'I'});
        pid_y.D = double(pid_result{'D'});

    catch ME
        % Si ocurre un error al obtener los valores PID, muestra un mensaje de error detallado
        % con la información proporcionada para facilitar la depuración.
        error('Error using crazyflie_python_commands>get_pid_y: %s', ME.message);
    end  
end
