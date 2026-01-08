function pid_values = crazyflie_get_pid_values(scf)
    % Esta función obtiene los valores de los controladores PID del dron Crazyflie
    % para cada uno de los ejes (X, Y, Z) usando un módulo de comandos en Python.
    %
    % Argumento:
    %   scf: Objeto de conexión que representa la conexión activa con el dron Crazyflie.
    %
    % Salida:
    %   pid_values: Estructura que contiene los valores PID para los ejes X, Y y Z.
    %               Cada campo (X, Y, Z) es un vector que incluye los tres valores PID
    %               (Kp, Ki, Kd) del respectivo eje.
    % -------------------------------------------------------------------------------------

    % Importa y recarga el módulo Python para comandos de Crazyflie
    module_name = 'crazyflie_python_commands'; 
    py_module = py.importlib.import_module(module_name);  
    py.importlib.reload(py_module);

    % Intenta obtener los valores PID usando la función correspondiente en Python.       
    try
        % Llama a la función `get_pid_values` del módulo Python, que retorna un
        % diccionario con los valores PID para los ejes X, Y y Z.
        pid_result = py_module.get_pid_values(scf);

        % Extrae y convierte los valores PID del diccionario Python para cada eje.
        pid_values.X = [double(pid_result{'X'}{1}), double(pid_result{'X'}{2}), double(pid_result{'X'}{3})];
        pid_values.Y = [double(pid_result{'Y'}{1}), double(pid_result{'Y'}{2}), double(pid_result{'Y'}{3})];
        pid_values.Z = [double(pid_result{'Z'}{1}), double(pid_result{'Z'}{2}), double(pid_result{'Z'}{3})];

    catch ME
        % Si ocurre un error al obtener los valores PID, muestra un mensaje de error detallado
        % con la información del problema.
        error('Error using crazyflie_python_commands>get_pid_values: %s', ME.message);
    end  

end
