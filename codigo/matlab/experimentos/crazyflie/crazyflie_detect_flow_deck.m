function flowdeck = crazyflie_detect_flow_deck(scf)
    % Esta función intenta detectar la presencia del Flow Deck en el dron Crazyflie
    % mediante el uso de un módulo de comandos en Python.
    %
    % Argumento:
    %   scf: Objeto de conexión que representa la conexión activa con el dron Crazyflie.
    %
    % Salida:
    %   flowdeck: Resultado de la detección del Flow Deck. Este valor indica si el Flow Deck
    %             está presente y funcional en el dron.
    % -------------------------------------------------------------------------------------
    
    % Importa y recarga el módulo Python para comandos de Crazyflie
    module_name = 'crazyflie_python_commands'; 
    py_module = py.importlib.import_module(module_name);  
    py.importlib.reload(py_module);

    % Intenta detectar el Flow Deck en el dron usando la función correspondiente en Python.
    % Esta función verifica la presencia y el estado operativo del Flow Deck.
    try
        flowdeck = py_module.detect_flow_deck(scf);
    catch ME
        % Si ocurre un error durante la detección, lanza un mensaje de error detallado
        % con la información proporcionada.
        error('Error using crazyflie_python_commands>detect_flow_deck: %s', ME.message);
    end  
end