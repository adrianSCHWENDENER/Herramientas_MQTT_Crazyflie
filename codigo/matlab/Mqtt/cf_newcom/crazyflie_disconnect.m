function crazyflie_disconnect(scf)
    % Esta función desconecta el dron Crazyflie de la conexión activa y limpia
    % el objeto de conexión de la memoria en el espacio de trabajo.
    %
    % Argumento:
    %   scf: Objeto de conexión que representa la conexión activa con el dron Crazyflie.
    % -------------------------------------------------------------------------------------

    % Importa y recarga el módulo Python para comandos de Crazyflie
    module_name = 'crazyflie_python_commands'; 
    py_module = py.importlib.import_module(module_name);  
    py.importlib.reload(py_module);

    % Intenta desconectar el dron usando la función correspondiente en Python
    % y limpiar el objeto de conexión de la memoria.
    try
        % Llama a la función `disconnect` del módulo Python para finalizar la conexión
        % del dron Crazyflie representado por el objeto `scf`.
        py_module.disconnect(scf);

        % Limpia el objeto de conexión `scf` del espacio de trabajo base,
        % liberando memoria y recursos asociados.
        evalin('base', ['clear ', inputname(1)]);
    catch ME
        % Si ocurre un error durante la desconexión, lanza un mensaje de error detallado
        % con la información de error proporcionada.
        error('Error using crazyflie_python_commands>disconnect_crazyflie: %s', ME.message);
    end  
end