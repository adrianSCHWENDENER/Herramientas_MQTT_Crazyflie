function pid_z = crazyflie_get_pid_z(scf)
    % Esta función obtiene los valores del controlador PID para el eje Z del dron Crazyflie
    % utilizando un módulo de comandos en Python. 
    %
    % Argumento:
    %   scf: Objeto de conexión que representa la conexión activa con el dron Crazyflie.
    %
    % Salida:
    %   pid_z: Estructura que contiene los valores PID para el eje Z.
    %          Incluye tres campos: 'P' (Proporcional), 'I' (Integral) y 'D' (Derivativo).
    % -------------------------------------------------------------------------------------

    % Importa y recarga el módulo Python para comandos de Crazyflie
    module_name = 'crazyflie_python_commands'; 
    py_module = py.importlib.import_module(module_name);  
    py.importlib.reload(py_module);

    % Intenta obtener los valores PID para el eje Z usando la función Python.
    try
        % Llama a la función `get_pid_z` en el módulo Python, que retorna un diccionario
        % con los valores P, I y D del controlador PID para el eje Z.
        pid_result = py_module.get_pid_z(scf);

        % Extrae y convierte cada valor PID del diccionario Python. 
        pid_z.P = double(pid_result{'P'});
        pid_z.I = double(pid_result{'I'});
        pid_z.D = double(pid_result{'D'});

    catch ME
        % Si ocurre un error al obtener los valores PID, muestra un mensaje de error detallado
        % con la información proporcionada para facilitar la depuración.
        error('Error using crazyflie_python_commands>get_pid_z: %s', ME.message);
    end  
end
