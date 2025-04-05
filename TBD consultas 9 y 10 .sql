SELECT c.nombre_compania, AVG(s.monto_total) as sueldo_prom_pagado
FROM sueldo s
INNER JOIN compania c on s.compania = c.rut_compania
WHERE s.fecha_sueldo BETWEEN '2015-03-31' AND '2025-03-31'
GROUP BY c.rut_compania
ORDER BY sueldo_prom_pagado DESC;


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