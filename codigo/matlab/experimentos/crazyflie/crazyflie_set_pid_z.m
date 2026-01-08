function crazyflie_set_pid_z(scf, P, I, D)
    % Esta función establece los valores de las ganancias PID (Proporcional, Integral, Derivativa)
    % específicamente para el eje Z del dron Crazyflie, usando un módulo de comandos en Python.
    %
    % Argumentos:
    %   scf: Objeto SyncCrazyflie que representa la conexión activa con el dron Crazyflie.
    %   P: Ganancia proporcional para el eje Z.
    %   I: Ganancia integral para el eje Z.
    %   D: Ganancia derivativa para el eje Z.
    % -------------------------------------------------------------------------------------

    % Importa y recarga el módulo Python para comandos de Crazyflie
    module_name = 'crazyflie_python_commands'; 
    py_module = py.importlib.import_module(module_name);  
    py.importlib.reload(py_module);

    % Intenta establecer los valores PID para el eje Z usando la función `set_pid_z`.
    try
        % Llama a `set_pid_z` en el módulo Python, pasando las ganancias P, I, y D
        % específicas para el eje Z.
        py_module.set_pid_z(scf, P, I, D);

    catch ME
        % Si ocurre un error al establecer los valores PID para el eje Z, muestra un mensaje
        % de error detallado con la información del problema.
        error('Error using crazyflie_python_commands>set_pid_z: %s', ME.message);
    end  
end