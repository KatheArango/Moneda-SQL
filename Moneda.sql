DO $$ 
BEGIN
    -- Verificar si la tabla Moneda ya existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'Moneda') THEN
        -- Creamos la tabla MONEDA
        CREATE TABLE Moneda( 
            Id SERIAL PRIMARY KEY,
            Nombre VARCHAR(100) NOT NULL,
            Sigla VARCHAR(5) NOT NULL,
            Imagen BYTEA
        );

        -- CREAMOS UN INDEX UNICO
        CREATE UNIQUE INDEX ixMoneda_Nombre
            ON Moneda(Nombre);

        -- Mensaje de creación exitosa de la tabla
        RAISE NOTICE 'Tabla Moneda creada exitosamente';
    ELSE
        -- Mostrar un mensaje indicando que la tabla ya existe
        RAISE NOTICE 'La tabla Moneda ya existe, no es necesario crearla nuevamente';
    END IF;
END $$;

-- Creamos un procedimiento almacenado para agregar monedas
CREATE OR REPLACE PROCEDURE AgregarMonedas()
AS $$
BEGIN
    INSERT INTO Moneda (Nombre, Sigla)
    SELECT DISTINCT moneda, LEFT(moneda, 3)
    FROM Pais
    ON CONFLICT (Nombre) DO NOTHING;
END;
$$ LANGUAGE plpgsql;

-- Ejecutamos el procedimiento para agregar las monedas
CALL AgregarMonedas();

-- Creamos un procedimiento almacenado para actualizar la tabla Pais con los ID de las monedas
CREATE OR REPLACE PROCEDURE ActualizarIdMoneda()
AS $$
BEGIN
    ALTER TABLE Pais ADD COLUMN IF NOT EXISTS IdMoneda INT; -- Agregamos la columna IdMoneda si no existe
    UPDATE Pais
    SET IdMoneda = Moneda.Id
    FROM Moneda
    WHERE Pais.Moneda = Moneda.Nombre;
END;
$$ LANGUAGE plpgsql;

-- Ejecutamos el procedimiento para actualizar los ID de las monedas en la tabla Pais
CALL ActualizarIdMoneda();

-- Agregamos las columnas faltantes para cumplir con el punto 2
ALTER TABLE IF EXISTS Pais
ADD Mapa BYTEA,
ADD Bandera BYTEA;

-- finalmente eliminamos la columna de pais porque ya tenemos todos los datos en una tabla. 
ALTER TABLE Pais
DROP COLUMN IF EXISTS Moneda;