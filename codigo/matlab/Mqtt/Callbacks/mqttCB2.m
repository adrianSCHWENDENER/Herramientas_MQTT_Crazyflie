%% Función con guardado en variable global (x, y, z)
% Requerimientos: paquete .json, los atributos del paquete (source, ts,
% type, command_name, identifier, payload_size_bytes, payload) y la
% variable global definida en el main como un diccionario con la misma
% estructura que el payload (omitiendo "rotation").

% El payload es un diccionario ("pose") con los diccionarios anidados 
% "position" y "rotation", con los valores x, y, z; y qx, qy, qz, qw
% respectivamente.

% El callback printea el mensaje en bruto para la visualización del
% funcionamiento y guarda en la variable global los componentes de
% "position" encontrados en "payload"

% Ideal para graficar y verificar que los datos concuerden con lo realizado
% en el ecosistema Robotat.
%--------------------------------------------------------------------------

function mqttCB2(topic, message)
    global posData; %variable global para guardar los datos fuera del callback

    disp("Mensaje recibido en tópico: " + topic);

    try
        % Convertir mensaje a string
        msgStr = char(message);
        disp(msgStr);

        try
            % Decodificar JSON
            data = jsondecode(msgStr);
            % Verificar si existe el campo de posición
            if isfield(data, "payload") && ...
               isfield(data.payload, "pose") && ...
               isfield(data.payload.pose, "position")
    
                pos = data.payload.pose.position;
    
                % Guardar x, y, z en matrices
                posData.x(end+1) = pos.x;
                posData.y(end+1) = pos.y;
                posData.z(end+1) = pos.z;
            end
        catch
            warning("Mensaje no es JSON válido: %s", msgStr);
            return
        end

    catch ME
        warning("Error en mqttCB: %s", char(ME.message));
    end
end

