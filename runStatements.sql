-- 1) Lista de lugares al que viajan mas chilenos por año (durante los ultimos 4 años)
    SELECT DISTINCT ON (anio) anio, destino, total_visitas -- DISTINCT es necesario para no escribir los 4 años por separados, u ocupar un loop, tomando solo el primer elemento de cada año
    FROM (
        SELECT EXTRACT(YEAR FROM v.fecha_fin_aprox) AS anio, v.destino, COUNT(*) AS total_visitas
        FROM cliente c
        JOIN cliente_vuelo cv ON c.dni_cliente = cv.dni_cliente
        JOIN vuelo v ON cv.id_vuelo = v.id_vuelo
        WHERE c.nacionalidad = 'Chilena' AND v.fecha_fin_aprox >= CURRENT_DATE - INTERVAL '4 years' --Esta ultima variable puede cambiarse dependiendo de las dechas
        GROUP BY anio, v.destino
        ORDER BY anio, COUNT(*) DESC
    ) AS visitas
    ORDER BY anio, total_visitas DESC;

-- 2) Lista con las secciones de vuelo mas compradas por argentinos
    SELECT p.seccion, COUNT(*) AS total_seccion
    FROM cliente c
    JOIN pasaje p ON c.dni_cliente = p.dni_cliente
    WHERE c.nacionalidad = 'Argentina'
    GROUP BY p.seccion
    ORDER BY total_seccion DESC;

-- 3)   Lista mensual de paises que mas gastan en volar (durante 4 años)

    SELECT c.nacionalidad AS pais, 
    EXTRACT(YEAR FROM p.fecha_ini_real) AS anio, 
    EXTRACT(MONTH FROM p.fecha_ini_real) AS mes,
    SUM(p.costo_pasaje) AS total_gastado
    FROM Pasaje AS p
    JOIN Cliente AS c 
    ON c.dni_cliente = p.dni_cliente
    WHERE p.fecha_ini_real >= current_date - INTERVAL '4 years'
    GROUP BY c.nacionalidad, EXTRACT(YEAR FROM p.fecha_ini_real), EXTRACT(MONTH FROM p.fecha_ini_real)
    ORDER BY anio, mes, total_gastado DESC;

-- 4)  Lista de pasajeros que viajan en 'First Class' mas de 4 veces al mes
    
    SELECT p.dni_cliente, c.nombre_cliente,
    EXTRACT(YEAR FROM p.fecha_ini_real) AS anio,
    EXTRACT(MONTH FROM p.fecha_ini_real) AS mes,
    COUNT(*) AS total_viajes_first_class
    FROM Pasaje AS p
    JOIN Cliente AS c ON c.dni_cliente = p.dni_cliente
    WHERE p.seccion = 'First Class'
    GROUP BY p.dni_cliente, c.nombre_cliente, 
    EXTRACT(YEAR FROM p.fecha_ini_real), 
    EXTRACT(MONTH FROM p.fecha_ini_real)
    HAVING COUNT(*) > 4;
-- 5) Avión con menos vuelos.

    SELECT  avion.patente_avion AS avion, COUNT(*) AS Nro_de_Vuelos
    FROM Vuelo 
    LEFT JOIN avion ON vuelo.patente_avion = avion.patente_avion
    GROUP BY avion.patente_avion
    ORDER BY COUNT(*) ASC

-- 6) Lista mensual de pilotos con mayor sueldo (durante los últimos 4 años).

    SELECT empleado.nombre_empleado AS Empleado, SUM(Sueldo.monto_total) AS Sueldo
    FROM empleado
    INNER JOIN sueldo ON empleado.dni_empleado = sueldo.dni_empleado
    -- fecha de ejemplo
    WHERE sueldo.fecha_sueldo BETWEEN '2021-04-04' AND '2025-04-04'
    GROUP BY Empleado.dni_empleado

-- 7) Lista de compañías indicando cuál es el avión que más ha recaudado en los últimos
--    4 años y cuál es el monto recaudado
    SELECT C.nombre_compania, SubConsulta1.patente_avion, SubConsulta1.total_recaudado
    FROM compania C
    JOIN (
        SELECT CA.rut_compania, v.patente_avion, SUM(p.costo_pasaje) AS total_recaudado
        FROM pasaje P
        JOIN vuelo V ON P.id_vuelo = V.id_vuelo
        JOIN contrato_avion CA ON V.patente_avion = CA.patente_avion
        WHERE P.fecha_ini_real BETWEEN '2022-01-01' AND '2025-12-31'
        GROUP BY CA.rut_compania, V.patente_avion
        ) AS SubConsulta1 ON C.rut_compania = SubConsulta1.rut_compania
    WHERE SubConsulta1.total_recaudado = (
        SELECT MAX(SubConsulta2.total_recaudado)
        FROM (
            SELECT CA2.rut_compania, V2.patente_avion, SUM(P2.costo_pasaje) AS total_recaudado
            FROM pasaje P2
            JOIN vuelo V2 ON P2.id_vuelo = V2.id_vuelo
            JOIN contrato_avion CA2 ON V2.patente_avion = CA2.patente_avion
            WHERE P2.fecha_ini_real BETWEEN '2022-01-01' AND '2025-12-31'
            GROUP BY CA2.rut_compania, V2.patente_avion
        ) AS SubConsulta2
        WHERE SubConsulta2.rut_compania = SubConsulta1.rut_compania
    )
    ORDER BY C.nombre_compania;

-- 8) Lista de compañías y total de aviones por año (en los últimos 10 años)
    SELECT C.nombre_compania, EXTRACT(YEAR FROM CA.ini_contrato) AS anio, 
        COUNT(A.patente_avion) AS total_aviones
    FROM compania C
    JOIN contrato_avion CA ON C.rut_compania = CA.rut_compania
    JOIN avion A ON CA.patente_avion = A.patente_avion
    WHERE CA.ini_contrato BETWEEN '2015-01-01' AND '2025-12-31'
    GROUP BY C.nombre_compania, anio
    ORDER BY C.nombre_compania, anio;

-- 9) Lista anual de compañias que en promedio han pagado mas a sus empleados (durante los últimos 10 años) 
    SELECT c.nombre_compania, AVG(s.monto_total) as sueldo_prom_pagado
    FROM sueldo s
    INNER JOIN compania c on s.compania = c.rut_compania
    WHERE s.fecha_sueldo BETWEEN '2016-01-01' AND '2025-12-31'
    GROUP BY c.rut_compania
    ORDER BY sueldo_prom_pagado DESC;

-- 10) Modelo de avion mas usado por compañia durante 2021

    SELECT conteo_usos.compania, conteo_usos.modelo_avion, conteo_usos.usos_modelo as cantidad_usos
        -- cuenta los usos por modelo de avion de cada compañia
    FROM (SELECT c.nombre_compania as compania, c.rut_compania as rut, usos2021.modelo as modelo_avion, COUNT(*) as usos_modelo
        FROM (SELECT a.patente_avion as avion, ca.rut_compania as compania, a.modelo as modelo, ca.ini_contrato as ini_cont, ca.fin_contrato as fin_cont
                FROM contrato_avion ca
                INNER JOIN avion a ON ca.patente_avion = a.patente_avion
                WHERE ca.ini_contrato BETWEEN '2021-01-01' AND '2021-12-31'
                OR ca.ini_contrato < '2021-01-01' AND ca.fin_contrato >= '2021-01-01'
                GROUP BY ca.rut_compania, a.patente_avion, ca.ini_contrato, ca.fin_contrato) as usos2021
        INNER JOIN vuelo v ON v.patente_avion = usos2021.avion
        INNER JOIN compania c ON usos2021.compania = c.rut_compania
        WHERE v.fecha_ini_aprox BETWEEN usos2021.ini_cont AND usos2021.fin_cont
        AND v.fecha_ini_aprox BETWEEN '2021-01-01' AND '2021-12-31'
        GROUP BY c.rut_compania, usos2021.modelo) AS conteo_usos
        -- toma el conteo de usos y saca el modelo o modelos que tengan mas usos por compañia
    INNER JOIN (SELECT cu.compania compania, MAX(cu.usos_modelo) as max_usos 
                FROM (SELECT c.nombre_compania as compania, c.rut_compania as rut, usos2021.modelo as modelo_avion, COUNT(*) as usos_modelo
                    FROM (SELECT a.patente_avion as avion, ca.rut_compania as compania, a.modelo as modelo, ca.ini_contrato as ini_cont, ca.fin_contrato as fin_cont
                            FROM contrato_avion ca
                            INNER JOIN avion a ON ca.patente_avion = a.patente_avion
                            WHERE ca.ini_contrato BETWEEN '2021-01-01' AND '2021-12-31'
                            OR ca.ini_contrato < '2021-01-01' AND ca.fin_contrato >= '2021-01-01'
                            GROUP BY ca.rut_compania, a.patente_avion, ca.ini_contrato, ca.fin_contrato) as usos2021
                    INNER JOIN vuelo v ON v.patente_avion = usos2021.avion
                    INNER JOIN compania c ON usos2021.compania = c.rut_compania
                    WHERE v.fecha_ini_aprox BETWEEN usos2021.ini_cont AND usos2021.fin_cont
                    AND v.fecha_ini_aprox BETWEEN '2021-01-01' AND '2021-12-31'
                    GROUP BY c.rut_compania, usos2021.modelo) as cu
                GROUP BY cu.compania) as max_x_comp
    ON max_x_comp.compania = conteo_usos.compania
    -- toma las tuplas que tenga el modelo mas usado por compañia, que el numero de usos coincida con los usos del modelo mas usado de cada compañia
    WHERE max_x_comp.max_usos = conteo_usos.usos_modelo
    GROUP BY conteo_usos.compania, conteo_usos.modelo_avion, conteo_usos.usos_modelo;
