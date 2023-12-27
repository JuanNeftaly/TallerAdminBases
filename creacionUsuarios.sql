ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;

-- Funcion para crear una contraseña
CREATE OR REPLACE FUNCTION generar_password (p_longitud IN NUMBER) RETURN VARCHAR2 AS
   v_password VARCHAR2(100);
   v_caracteres CONSTANT VARCHAR2(95) := '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz#$_';
   v_letras CONSTANT VARCHAR2(52) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
   v_indice NUMBER;
BEGIN
   -- Generar el primer carácter como una letra
   v_indice := dbms_random.value(1, length(v_letras));
   v_password := v_password || SUBSTR(v_letras, v_indice, 1);
   -- Resto de la generación de la contraseña
   FOR i IN 2..p_longitud LOOP
      v_indice := dbms_random.value(1, length(v_caracteres));
      v_password := v_password || SUBSTR(v_caracteres, v_indice, 1);
   END LOOP;
   
   RETURN v_password;
END;
    
CREATE OR REPLACE PROCEDURE GENERATE_ESTUDIANTE_USERS IS
    password VARCHAR2(15);
    carnet VARCHAR2(20);
    user_name VARCHAR(20);
    -- 
    CURSOR CURSOR_ESTUDIANTE IS
        SELECT carnet
        FROM udbadmin.estudiante;
BEGIN
    OPEN CURSOR_ESTUDIANTE;
    LOOP FETCH CURSOR_ESTUDIANTE INTO carnet;
    user_name := ('U_' || carnet); --Nombre del usuario a crear
    password := (generar_password(10)); --Contraseña generada
    EXIT WHEN CURSOR_ESTUDIANTE%NOTFOUND;
    -- Agregar codigo para crear estudiante
    EXECUTE IMMEDIATE
   'CREATE USER ' || user_name ||
   ' IDENTIFIED BY ' || password ||
   ' DEFAULT TABLESPACE t_estudiantes ' ||
   ' TEMPORARY TABLESPACE temp ' ||
   ' QUOTA UNLIMITED ON t_estudiantes';
    DBMS_OUTPUT.PUT_LINE('Usuario: ' || user_name || ', Password: ' || password);
    END LOOP;
    CLOSE CURSOR_ESTUDIANTE;
END;

EXEC GENERATE_ESTUDIANTE_USERS;

CREATE OR REPLACE PROCEDURE GENERATE_EMPLEADO_USERS IS
    password VARCHAR2(15);
    carnet VARCHAR2(20);
    user_name VARCHAR2(20);
    id_tipo_empleado INT;
    CURSOR CURSOR_EMPLEADO IS
        SELECT carnet, id_tipo_empleado
        FROM udbadmin.empleado;
BEGIN
    OPEN CURSOR_EMPLEADO;
    LOOP
        FETCH CURSOR_EMPLEADO INTO carnet, id_tipo_empleado;
        EXIT WHEN CURSOR_EMPLEADO%NOTFOUND;
        user_name := 'U_' || carnet; -- Nombre del usuario a crear
        password := generar_password(10); -- Contraseña generada
        -- Crear usuario
        EXECUTE IMMEDIATE
           'CREATE USER ' || user_name ||
           ' IDENTIFIED BY ' || password ||
           ' DEFAULT TABLESPACE t_empleados ' ||
           ' TEMPORARY TABLESPACE temp';
        -- Asignar roles según el id_tipo_empleado
        CASE id_tipo_empleado
           WHEN 0 THEN
              EXECUTE IMMEDIATE 'GRANT administrativo TO ' || user_name;
           WHEN 1 THEN
              EXECUTE IMMEDIATE 'GRANT coordinador TO ' || user_name;
           WHEN 2 THEN
              EXECUTE IMMEDIATE 'GRANT docente TO ' || user_name;
           ELSE
              DBMS_OUTPUT.PUT_LINE('Usuario: ' || user_name || ', Password: ' || password || ', Valor no reconocido');
        END CASE;
        DBMS_OUTPUT.PUT_LINE('Usuario: ' || user_name || ', Password: ' || password || ' creado con éxito.');
    END LOOP;
    CLOSE CURSOR_EMPLEADO;
END;

EXEC GENERATE_EMPLEADO_USERS;







