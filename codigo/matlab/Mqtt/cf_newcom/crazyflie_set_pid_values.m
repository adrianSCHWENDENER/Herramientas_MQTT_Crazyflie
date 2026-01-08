function crazyflie_set_pid_values(scf, p_gains, i_gains, d_gains)
    % Esta función establece los valores de las ganancias PID para el dron Crazyflie
    % en los tres ejes (P, I, D) utilizando un módulo de comandos en Python.
    %
    % Argumentos:
    %   scf: Objeto SyncCrazyflie que representa la conexión activa con el dron Crazyflie.
    %   p_gains: Estructura o diccionario con las ganancias proporcionales (P) para los ejes.
    %   i_gains: Estructura o diccionario con las ganancias integrales (I) para los ejes.
    %   d_gains: Estructura o diccionario con las ganancias derivativas (D) para los ejes.
    % -------------------------------------------------------------------------------------

    % Importa y recarga el módulo Python para comandos de Crazyflie
    module_name = 'crazyflie_python_commands'; 
    py_module = py.importlib.import_module(module_name);  
    py.importlib.reload(py_module);

    % Intenta establecer los valores PID en el dron usando la función `set_pid_values`.
    try
        % Convierte las ganancias PID proporcionadas en estructuras de diccionario de Python,
        % compatibles con la función `set_pid_values` en el módulo Python.
        py_p_gains = py.dict(p_gains);
        py_i_gains = py.dict(i_gains);
        py_d_gains = py.dict(d_gains);

        % Llama a `set_pid_values` en el módulo Python, pasando los diccionarios de ganancias
        % PID para cada uno de los ejes (P, I, D).
        py_module.set_pid_values(scf, py_p_gains, py_i_gains, py_d_gains);

    catch ME
        % Si ocurre un error al establecer los valores PID, muestra un mensaje de error detallado.
        error('Error using crazyflie_python_commands>set_pid_values: %s', ME.message);
    end  
end