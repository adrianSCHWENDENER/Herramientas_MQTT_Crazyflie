function crazyflie_land(scf, height, duration)
    % Esta función aterriza el dron Crazyflie desde su altura actual hasta una altura
    % especificada, dentro de un tiempo definido, usando comandos de un módulo Python.
    %
    % Argumentos:
    %   scf: Objeto SyncCrazyflie que representa la conexión activa con el dron Crazyflie.
    %   height: Altura final de aterrizaje. Por defecto es 0.0 metros.
    %   duration: Tiempo que durará el aterrizaje en segundos. Por defecto es 2.0 segundos.
    % -------------------------------------------------------------------------------------

    % Configura la altura de aterrizaje predeterminada si no se proporciona.
    if nargin < 2 || isempty(height)
        height = 0.0; 
    end

    % Configura la duración de aterrizaje predeterminada si no se proporciona.
    if nargin < 3 || isempty(duration)
        duration = 2.0;  
    end

    % Verifica que `scf` sea un objeto válido de SyncCrazyflie para asegurar la
    % compatibilidad con las funciones de control del dron.
    if ~isa(scf, 'py.cflib.crazyflie.syncCrazyflie.SyncCrazyflie')
        error('ERROR: Invalid SyncCrazyflie object.');
    end
    
    % Verifica que la altura sea un número no negativo; si no, usa la altura predeterminada.
    if ~isnumeric(height) || height < 0.0
        warning('Height must be 0 or greater for landing. Using default height of 0.0 meters.');
        height = 0.0;  
    end

    % Verifica que la duración sea de al menos 2 segundos; si no, usa la duración predeterminada.
    if ~isnumeric(duration) || duration < 2.0
        warning('Duration must be at least 2 seconds. Using default duration of 2.0 seconds.');
        duration = 2.0; 
    end

    % Importa y recarga el módulo Python para comandos de Crazyflie
    module_name = 'crazyflie_python_commands'; 
    py_module = py.importlib.import_module(module_name);  
    py.importlib.reload(py_module);

    % Intenta ejecutar el comando de aterrizaje usando la función `land` en Python.
    try
        % Llama a `land` con los parámetros `scf`, `height` y `duration`, lo cual
        % inicia el proceso de aterrizaje del dron.
        py_module.land(scf, height, duration);
    
    catch ME
        % Si ocurre un error durante el aterrizaje, muestra un mensaje detallado con el error.
        error('Error using crazyflie_python_commands>land: %s', ME.message);
    end  
end