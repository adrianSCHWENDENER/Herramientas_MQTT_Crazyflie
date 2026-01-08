classdef mqttRobotat < handle
    % MQTTROBOTAT Guarda paquetes recibidos en un callback y para
    % obtenerlos en el código principal.
    %   logger = mqttRobotat(maxHistory)
    %   - updateLatest(data): guarda el último paquete
    %   - appendLatestToHistory(): añade el último paquete a un buffer circular
    %   - getLatest(): devuelve el último paquete (struct) o [] si none
    %   - getHistoryMatrix(): devuelve el historial de pose
    %   - clearHistory(): limpia el historial
    
    properties (Access = private)
        MaxHistory   % tamaño del buffer circular
        Count = 0    % número de entradas válidas actualmente
        Head = 0     % índice del último elemento insertado (1..MaxHistory)
        xs
        ys
        zs
        qx
        qy
        qz
        qw
        % ts           % datetime array
    end
    
    properties (Access = public)
        Latest = []  % último paquete JSON decodificado (struct)
    end
    
    methods
        function obj = mqttRobotat(maxHistory)
            if nargin < 1 || isempty(maxHistory)
                maxHistory = 300000; % valor por defecto (ajustable)
            end
            obj.MaxHistory = maxHistory;
            obj.xs = nan(maxHistory,1);
            obj.ys = nan(maxHistory,1);
            obj.zs = nan(maxHistory,1);
            obj.qx = nan(maxHistory,1);
            obj.qy = nan(maxHistory,1);
            obj.qz = nan(maxHistory,1);
            obj.qw = nan(maxHistory,1);
            % obj.ts = NaT(maxHistory,1);
            obj.Latest = [];
        end
        
        function updateLatest(obj, dataStruct)
            % Guarda el último paquete. dataStruct suele venir
            % resultado de jsondecode.
            obj.Latest = dataStruct;
        end
        
        function appended = appendLatestToHistory(obj)
            % Añade obj.Latest al buffer circular (si tiene posición)
            appended = false;
            d = obj.Latest;
            if isempty(d)
                warning('append: Latest vacío');
                return;
            end
            try
                % Intentar extraer position & rotation con expected path:
                % payload.pose.position.{x,y,z}, payload.pose.rotation.{qx,...,qw}
                if isfield(d, "payload") && isfield(d.payload, "pose") ...
                        && isfield(d.payload.pose, "position")
                    pos = d.payload.pose.position;
                    rot = []; %como rot es opcional, se inicializa
                    if isfield(d.payload.pose, "rotation")
                        rot = d.payload.pose.rotation;
                    end
                    
                    idx = mod(obj.Head, obj.MaxHistory) + 1; %siguiente index
                    obj.Head = idx; %en que dato va (dentro del array)
                    if obj.Count < obj.MaxHistory
                        obj.Count = obj.Count + 1; %cuantos datos hay
                    end
                    
                    % guardar valores (formato double), si existen
                    obj.xs(idx) = getfield_or_nan(pos, 'x');
                    obj.ys(idx) = getfield_or_nan(pos, 'y');
                    obj.zs(idx) = getfield_or_nan(pos, 'z');
                    
                    if ~isempty(rot)
                        obj.qx(idx) = getfield_or_nan(rot, 'qx');
                        obj.qy(idx) = getfield_or_nan(rot, 'qy');
                        obj.qz(idx) = getfield_or_nan(rot, 'qz');
                        obj.qw(idx) = getfield_or_nan(rot, 'qw');
                    else
                        obj.qx(idx:idx) = NaN;
                        obj.qy(idx:idx) = NaN;
                        obj.qz(idx:idx) = NaN;
                        obj.qw(idx:idx) = NaN;
                    end
                    
                    % % timestamp: intentar convertir si existe
                    % if isfield(d, "ts")
                    %     try
                    %         obj.ts(idx) = datetime(d.ts, 'InputFormat', "yyyy-MM-dd'T'HH:mm:ss'Z'", 'TimeZone', 'UTC');
                    %     catch
                    %         obj.ts(idx) = datetime('now');
                    %     end
                    % else
                    %     obj.ts(idx) = datetime('now');
                    % end
                    
                    appended = true;
                else
                    warning('append: estructura inesperada en Latest');
                end
            catch ME
                warning('append: error al procesar paquete -> %s', char(ME.message));
            end
        end
        
        function out = getLatest(obj)
            out = obj.Latest;
        end

        function [data] = getHistoryMatrix(obj)
            % Devuelve el historial como:
            %   ts   -> vector datetime (n x 1)
            %   data -> matriz numérica (n x 7) con columnas [x y z qx qy qz qw]
    
            n = obj.Count;
            if n == 0
                %ts = [];
                data = [];
                return;
            end
    
            % Reconstruir índices circulares
            idxStart = obj.Head - n + 1;
            indices = idxStart:(idxStart + n - 1);
            indices = mod(indices - 1, obj.MaxHistory) + 1;
    
            % Extraer datos en orden
            %ts = obj.ts(indices);
            data = [ ...
                obj.xs(indices), ...
                obj.ys(indices), ...
                obj.zs(indices), ...
                obj.qx(indices), ...
                obj.qy(indices), ...
                obj.qz(indices), ...
                obj.qw(indices) ...
            ];
        end
        
        function clearHistory(obj)
            obj.Count = 0;
            obj.Head = 0;
            obj.xs(:) = NaN;
            obj.ys(:) = NaN;
            obj.zs(:) = NaN;
            obj.qx(:) = NaN;
            obj.qy(:) = NaN;
            obj.qz(:) = NaN;
            obj.qw(:) = NaN;
            % obj.ts(:) = NaT(size(obj.ts));
        end
    end
end

% Helper: safe field retrieval
function v = getfield_or_nan(s, fname)
    if isfield(s, fname)
        v = double(s.(fname));
    else
        v = NaN;
    end
end
