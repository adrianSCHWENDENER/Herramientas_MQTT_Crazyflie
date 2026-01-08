% Conectar con el sistema Robotat
robotat = robotat_connect();

% Obtener pose de un marcador específico
marker_id = 1;
pose = robotat_get_pose(robotat, marker_id, 'eulxyz');

% Desconectar del sistema Robotat
robotat_disconnect(robotat);