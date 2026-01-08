function crazyflie_takeoff(scf, height, duration)
    % Esta función realiza el despegue del dron Crazyflie hasta una altura especificada
    % en un tiempo determinado, utilizando un módulo de comandos en Python.
    %
    % Argumentos:
    %   scf: Objeto SyncCrazyflie que representa la conexión activa con el dron Crazyflie.
    %   height: Altura objetivo del despegue en metros. Por defecto es 0.5 metros.
    %   duration: Tiempo en segundos para alcanzar la altura objetivo. Por defecto es 1.0 segundos.
    % -------------------------------------------------------------------------------------

    % Configura la altura de despegue predeterminada si no se proporciona.
    if nargin < 2 || isempty(height)
        height = 0.5;  
    end

    % Configura la duración de despegue predeterminada si no se proporciona.
    if nargin < 3 || isempty(duration)
        duration = 1.0;  
    end
    
    % Verifica que la altura sea un número mayor a 0.1 metros; si no, usa la altura predeterminada.
    if ~isnumeric(height) || height <= 0.1
        warning('Height must be greater than 0.1 meters. Using default height of 0.3 meter.');
        height = 0.5;  
    end

    % Verifica que la duración sea al menos de 1 segundo; si no, usa la duración predeterminada.
    if ~isnumeric(duration) || duration < 1.0
        warning('Duration must be at least 1 second. Using default duration of 2.0 seconds.');
        duration = 1.0;  
    end
    
    % Importa y recarga el módulo Python para comandos de Crazyflie
    module_name = 'crazyflie_python_commands'; 
    py_module = py.importlib.import_module(module_name);  
    py.importlib.reload(py_module);

    % Intenta ejecutar el comando de despegue usando la función `takeoff`.
    try
        % Llama a `takeoff` en el módulo Python, pasando los valores de altura y duración
        % para realizar el despegue del dron hasta la altura especificada en el tiempo indicado.
        py_module.takeoff(scf, height, duration);
        
    catch ME
        % Si ocurre un error durante el despegue, muestra un mensaje de error detallado.
        error('Error using crazyflie_python_commands>takeoff: %s', ME.message);
    end  
end 