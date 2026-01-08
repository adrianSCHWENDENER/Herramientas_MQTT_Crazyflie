function crazyflie_set_pid_y(scf, P, I, D)
    % Esta función establece los valores de las ganancias PID (Proporcional, Integral, Derivativa)
    % específicamente para el eje Y del dron Crazyflie, usando un módulo de comandos en Python.
    %
    % Argumentos:
    %   scf: Objeto SyncCrazyflie que representa la conexión activa con el dron Crazyflie.
    %   P: Ganancia proporcional para el eje Y.
    %   I: Ganancia integral para el eje Y.
    %   D: Ganancia derivativa para el eje Y.
    % -------------------------------------------------------------------------------------

    % Importa y recarga el módulo Python para comandos de Crazyflie
    module_name = 'crazyflie_python_commands'; 
    py_module = py.importlib.import_module(module_name);  
    py.importlib.reload(py_module);

    % Intenta establecer los valores PID para el eje Y usando la función `set_pid_y`.
    try
        % Llama a `set_pid_y` en el módulo Python, pasando las ganancias P, I, y D
        % específicas para el eje Y.
        py_module.set_pid_y(scf, P, I, D);

    catch ME
        % Si ocurre un error al establecer los valores PID para el eje Y, muestra un mensaje
        % de error detallado con la información del problema.
        error('Error using crazyflie_python_commands>set_pid_y: %s', ME.message);
    end  
end