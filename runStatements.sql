1
2
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
    SELECT nombre_compania, patente_avion, total_recaudado
    FROM (
        SELECT c.nombre_compania, v.patente_avion, SUM(p.costo_pasaje) AS total_recaudado,
            ROW_NUMBER() OVER (PARTITION BY c.nombre_compania ORDER BY SUM(p.costo_pasaje) DESC) AS enumeracion
        FROM pasaje p
        JOIN vuelo v ON p.id_vuelo = v.id_vuelo
        JOIN contrato_avion ca ON v.patente_avion = ca.patente_avion
        JOIN compania c ON c.rut_compania = ca.rut_compania
        WHERE p.fecha_ini_real >= NOW() - INTERVAL '4 years'
        GROUP BY c.nombre_compania, v.patente_avion
    ) AS subconsulta
    WHERE enumeracion = 1;

    -- * Expliación ROW_NUMBRER asigna números de fila únicos e incrementales 
    -- empezando por "enumeracion = 1"
    -- * El OVER vea a definir como se van a agrupar y ordenar
    -- los numeros de la columna enumeracion
    -- * PARTITION BY va a dividir los resultados en grupos basados en c.nombre_compania,
    -- es decir, que cada compania va a tener su propia enumeracion
    -- * ORDER BY SUM (p.costo_pasaje)DESC se ordena en base a el costo del pasaje en DESC,
    -- es decir, que el numero de 1 en la columna enumeracion va a tener al coste que más recaudó

-- 8) Lista de compañías y total de aviones por año (en los últimos 10 años)

-- 9) Lista anual de compañias que en promedio han pagado mas a sus empleados (durante los últimos 10 años) 
    SELECT c.nombre_compania, AVG(s.monto_total) as sueldo_prom_pagado
    FROM sueldo s
    INNER JOIN compania c on s.compania = c.rut_compania
    WHERE s.fecha_sueldo BETWEEN '2015-04-03' AND '2025-04-04'
    GROUP BY c.rut_compania
    ORDER BY sueldo_prom_pagado DESC;

-- 10) Modelo de avion mas usado por compañia durante 2021

    SELECT conteo_usos.compania, conteo_usos.modelo_avion, conteo_usos.usos_modelo as modelo_mas_usado
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
