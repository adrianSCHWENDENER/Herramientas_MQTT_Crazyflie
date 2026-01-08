% =========================================================================
% Función callback: Función callback base. Desempaqueta el mensaje recibido
% e identifica el marcador de interés.
%   - topic: tópico donde se publican los paquetes.
%   - message: paquete recibido.
%   - agent_id: id del marcador de interés.
%   - manager: clase que guarda el histórico de posiciones (si se usa).
%   - scf: objeto Crazyflie del dron conectado (si se usa).
% 
% Se debe agregar ÚNICAMENTE lo que se debe realizar cada vez que se recibe
% un paquete MQTT.
% =========================================================================

% === NO MODIFICAR === %
function mqttCB(topic, message, agent_id, manager, scf)

    % == Variables (modificar) ===

    % === NO MODIFICAR ===
    try
        msgStr = char(message); %intentar convertir mensaje a string
        try
            data = jsondecode(msgStr); %intentar decodificar el paquete .json
            
            % Verificar si existe "identifier" y coincide con el deseado
            if isfield(data, "identifier") && strcmp(data.identifier, num2str(agent_id))

                % === Lógica del callback (modificar) ===
                

            end
        catch
            warning("Mensaje no es JSON válido: %s", msgStr);
            return
        end
    catch ME
        warning("Error en mqttCB: %s", char(ME.message));
    end
end
