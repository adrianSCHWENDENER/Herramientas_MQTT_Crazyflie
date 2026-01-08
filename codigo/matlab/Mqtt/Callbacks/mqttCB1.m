%% Función con decodificación y print completo
% Requerimientos: paquete .json y los atributos del paquete (source, ts,
% type, command_name, identifier, payload_size_bytes, payload). 

% El payload es un diccionario ("pose") con los diccionarios anidados 
% "position" y "rotation", con los valores x, y, z; y qx, qy, qz, qw
% respectivamente.

% El callback printea en la terminal el mensaje en bruto y cada atributo
% listado si lo encuentra, de lo contrario omite el atributo. En caso de
% error, muestra lo que lo ocacionó.

% Ideal para verificar que el paquete se esta enviando correctamente.
%--------------------------------------------------------------------------

function mqttCB1(topic, message)
    disp("Mensaje recibido en tópico: " + topic);

    try
        % Convertir mensaje a string
        msgStr = char(message);
        disp("Contenido bruto del mensaje:");
        disp(msgStr);

        try
            % Decodificar JSON
            data = jsondecode(msgStr);
            
            % Atributos
            if isfield(data, "source")
                disp("Source: " + string(data.source));
            end
    
            if isfield(data, "ts")
                disp("Timestamp: " + string(data.ts));
            end
    
            if isfield(data, "type")
                disp("Tipo: " + string(data.type));
            end
    
            if isfield(data, "command_name")
                disp("Command: " + string(data.command_name));
            end
    
            if isfield(data, "identifier")
                disp("Identifier: " + string(data.identifier));
            end
    
            if isfield(data, "payload_size_bytes")
                fprintf("Payload size: %d bytes\n", data.payload_size_bytes);
            end
    
            % === Procesar payload ===
            if isfield(data, "payload") && isfield(data.payload, "pose")
                pose = data.payload.pose;
    
                % --- Position ---
                if isfield(pose, "position")
                    pos = pose.position;
                    fprintf("Position: x=%.3f, y=%.3f, z=%.3f\n", ...
                        pos.x, pos.y, pos.z);
                end
    
                % --- Rotation ---
                if isfield(pose, "rotation")
                    rot = pose.rotation;
                    fprintf("Rotation quaternion: qx=%.3f, qy=%.3f, qz=%.3f, qw=%.3f\n", ...
                        rot.qx, rot.qy, rot.qz, rot.qw);
                end
            end
        catch
            warning("Mensaje no es JSON válido: %s", msgStr);
            return
        end

    catch ME
        warning("Error al procesar el mensaje MQTT: %s", char(ME.message));
        disp("Mensaje original:");
        disp(char(message));
    end
end

