CREATE TABLE "avion" (
  "patente_avion" VARCHAR(10),
  "modelo" VARCHAR(30),
  "capacidad_economy" INT,
  "capacidad_premium" INT,
  "capacidad_business" INT,
  "capacidad_first_class" INT,
  PRIMARY KEY ("patente_avion")
);

CREATE TABLE "vuelo" (
  "id_vuelo" INT,
  "origen" VARCHAR(30),
  "destino" VARCHAR(30),
  "fecha_ini_aprox" DATE,
  "fecha_fin_aprox" DATE,
  "patente_avion" VARCHAR(10),
  PRIMARY KEY ("id_vuelo"),
  CONSTRAINT "FK_vuelo.patente_avion"
    FOREIGN KEY ("patente_avion")
      REFERENCES "avion"("patente_avion")
);

CREATE TABLE "cliente" (
  "dni_cliente" VARCHAR(10),
  "nombre_cliente" VARCHAR(30),
  "fecha_nacimiento" DATE,
  "nacionalidad" VARCHAR(30),
  PRIMARY KEY ("dni_cliente")
);

CREATE TABLE "cliente_vuelo" (
  "dni_cliente" VARCHAR(10),
  "id_vuelo" INT,
  CONSTRAINT "FK_cliente_vuelo.id_vuelo"
    FOREIGN KEY ("id_vuelo")
      REFERENCES "vuelo"("id_vuelo"),
  CONSTRAINT "FK_cliente_vuelo.dni_cliente"
    FOREIGN KEY ("dni_cliente")
      REFERENCES "cliente"("dni_cliente")
);

CREATE TABLE "compania" (
  "rut_compania" VARCHAR(10),
  "nombre_compania" VARCHAR(30),
  PRIMARY KEY ("rut_compania")
);

CREATE TABLE "cliente_compania" (
  "dni_cliente" VARCHAR(10),
  "rut_compania" VARCHAR(10),
  CONSTRAINT "FK_cliente_compania.rut_compania"
    FOREIGN KEY ("rut_compania")
      REFERENCES "compania"("rut_compania"),
  CONSTRAINT "FK_cliente_compania.dni_cliente"
    FOREIGN KEY ("dni_cliente")
      REFERENCES "cliente"("dni_cliente")
);

CREATE TABLE "contrato_avion" (
  "id_contrato" INT,
  "patente_avion" VARCHAR(10),
  "rut_compania" VARCHAR(10),
  "ini_contrato" DATE,
  "fin_contrato" DATE,
  PRIMARY KEY ("id_contrato"),
  CONSTRAINT "FK_contrato_avion.patente_avion"
    FOREIGN KEY ("patente_avion")
      REFERENCES "avion"("patente_avion"),
  CONSTRAINT "FK_contrato_avion.rut_compania"
    FOREIGN KEY ("rut_compania")
      REFERENCES "compania"("rut_compania")
);

CREATE TABLE "empleado" (
  "dni_empleado" VARCHAR(10),
  "nombre_empleado" VARCHAR(30),
  PRIMARY KEY ("dni_empleado")
);

CREATE TABLE "sueldo" (
  "id_sueldo" INT,
  "monto_total" INT,
  "fecha_sueldo" DATE,
  "cargo" VARCHAR(30),
  "dni_empleado" VARCHAR(10),
  "compania" VARCHAR(10),
  PRIMARY KEY ("id_sueldo"),
  CONSTRAINT "FK_sueldo.compania"
    FOREIGN KEY ("compania")
      REFERENCES "compania"("rut_compania"),
  CONSTRAINT "FK_sueldo.dni_empleado"
    FOREIGN KEY ("dni_empleado")
      REFERENCES "empleado"("dni_empleado")
);

CREATE TABLE "pasaje" (
  "id_pasaje" INT,
  "seccion" VARCHAR(30),
  "costo_pasaje" INT,
  "fecha_ini_real" DATE,
  "fecha_fin_real" DATE,
  "asiento" VARCHAR(5),
  "id_vuelo" INT,
  "dni_cliente" VARCHAR(10),
  PRIMARY KEY ("id_pasaje"),
  CONSTRAINT "FK_pasaje.dni_cliente"
    FOREIGN KEY ("dni_cliente")
      REFERENCES "cliente"("dni_cliente"),
  CONSTRAINT "FK_pasaje.id_vuelo"
    FOREIGN KEY ("id_vuelo")
      REFERENCES "vuelo"("id_vuelo")
);

CREATE TABLE "vuelo_empleado" (
  "id_vuelo" INT,
  "dni_empleado" VARCHAR(10),
  CONSTRAINT "FK_vuelo_empleado.id_vuelo"
    FOREIGN KEY ("id_vuelo")
      REFERENCES "vuelo"("id_vuelo"),
  CONSTRAINT "FK_vuelo_empleado.dni_empleado"
    FOREIGN KEY ("dni_empleado")
      REFERENCES "empleado"("dni_empleado")
);

