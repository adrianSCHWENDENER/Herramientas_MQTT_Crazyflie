function scf = crazyflie_connect(drone_number)
    % Esta función establece una conexión con el dron Crazyflie especificado
    % usando un número de dron que identifica al dron en la lista de URIs.
    %
    % Argumento:
    %   drone_number: Número entero que identifica al dron específico (entre 1 y 12).
    %
    % Salida:
    %   scf: Objeto de conexión para el dron especificado.
    % -------------------------------------------------------------------------------

    % Verifica que el número de dron es un entero entre 1 y 12
    if ~isnumeric(drone_number) || mod(drone_number, 1) ~= 0 || drone_number < 1 || drone_number > 12
        error('ERROR: Invalid drone number. It must be an integer between 1 and 12.');
    end
    
    % Define una lista de URIs para cada dron disponible, donde cada URI es
    % un identificador único que permite la comunicación con un dron específico.
    uris = {
        'radio://0/80/2M/E7E7E7E7E0', % Drone 1
        'radio://0/80/2M/E7E7E7E7E1', % Drone 2
        'radio://0/80/2M/E7E7E7E7E2', % Drone 3
        'radio://0/80/2M/E7E7E7E7E3', % Drone 4
        'radio://0/80/2M/E7E7E7E7E4', % Drone 5
        'radio://0/80/2M/E7E7E7E7E5', % Drone 6
        'radio://0/84/2M/E7E7E7E7E7', % Drone 7
        'radio://0/64/2M/E7E7E7E7E8', % Drone 8
        'radio://0/80/2M/E7E7E7E7D0', % Drone 9
        'radio://0/80/2M/E7E7E7E7D1', % Drone 10
        'radio://0/80/2M/E7E7E7E7D2', % Drone 11
        'radio://0/80/2M/E7E7E7E7D3'  % Drone 12
    };
    
    % Selecciona la URI del dron especificado
    uri = uris{drone_number};

    % Carga el módulo de comandos en Python para los drones Crazyflie.
    % Este módulo contiene las funciones necesarias para establecer la conexión
    % y ejecutar comandos específicos en el dron.
    python_folder = fileparts(mfilename('fullpath'));
    if count(py.sys.path, python_folder) == 0
        insert(py.sys.path, int32(0), python_folder);
    end

    % Carga el módulo de comandos en Python
    module_name = 'crazyflie_python_commands'; 
    py_module = py.importlib.import_module(module_name);  
    py.importlib.reload(py_module);  

    % Intenta establecer la conexión con el dron utilizando el URI.
    % La función `connect` en el módulo Python realiza la conexión.
    try
        scf = py_module.connect(uri); 

    catch ME
        % Si ocurre un error durante la conexión, lanza un mensaje detallado
        % con la información de error proporcionada.
        error('Error using crazyflie_python_commands>connect: %s', ME.message);
    end    
end
