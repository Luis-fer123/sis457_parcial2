
CREATE DATABASE Parcial2Lfms;
GO

CREATE LOGIN usrparcial2 
WITH PASSWORD = '12345678',
	CHECK_POLICY = ON,
	CHECK_EXPIRATION = OFF,
	DEFAULT_DATABASE = Parcial2Lfms;
GO

USE Parcial2Lfms;
GO

CREATE USER usrparcial2 FOR LOGIN usrparcial2;
GO

ALTER ROLE db_owner ADD MEMBER usrparcial2;
GO



IF OBJECT_ID('paListarProgramas', 'P') IS NOT NULL DROP PROC paListarProgramas;
IF OBJECT_ID('paListarCanales', 'P') IS NOT NULL DROP PROC paListarCanales;
IF OBJECT_ID('Programa', 'U') IS NOT NULL DROP TABLE Programa;
IF OBJECT_ID('Canal', 'U') IS NOT NULL DROP TABLE Canal;
GO



CREATE TABLE Canal (
	id INT IDENTITY(1,1) PRIMARY KEY,
	nombre VARCHAR(50) NOT NULL,
	frecuencia VARCHAR(20) NOT NULL,
	usuarioRegistro VARCHAR(50) NOT NULL DEFAULT SUSER_NAME(),
	fechaRegistro DATETIME NOT NULL DEFAULT GETDATE(),
	estado SMALLINT NOT NULL DEFAULT 1 -- -1: Eliminado, 0: Inactivo, 1: Activo
);
GO


CREATE TABLE Programa (
	id INT IDENTITY(1,1) PRIMARY KEY,
	idCanal INT NOT NULL,
	titulo VARCHAR(100) NOT NULL,
	descripcion VARCHAR(250) NULL,
	duracion INT NULL,
	tipo VARCHAR(50) NULL,
	productor VARCHAR(100) NULL,
	fechaEstreno DATE NULL,
	usuarioRegistro VARCHAR(50) NOT NULL DEFAULT SUSER_NAME(),
	fechaRegistro DATETIME NOT NULL DEFAULT GETDATE(),
	estado SMALLINT NOT NULL DEFAULT 1, -- -1: Eliminado, 0: Inactivo, 1: Activo
	FOREIGN KEY (idCanal) REFERENCES Canal(id)
);
GO


CREATE PROC paListarCanales 
    @parametro VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		id,
		nombre,
		frecuencia,
		usuarioRegistro,
		fechaRegistro,
		estado
	FROM Canal
	WHERE estado > -1
	  AND (nombre + frecuencia) LIKE '%' + REPLACE(@parametro, ' ', '%') + '%'
	ORDER BY estado DESC, nombre ASC;
END;
GO


CREATE PROC paListarProgramas 
    @parametro VARCHAR(50),
    @tipo VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        p.id,
        p.titulo,
        p.descripcion,
        p.duracion,
        p.tipo,
        p.productor,
        p.fechaEstreno,
        c.nombre AS Canal,
        p.usuarioRegistro,
        p.fechaRegistro,
        p.estado
    FROM Programa p
    INNER JOIN Canal c ON p.idCanal = c.id
    WHERE p.estado > -1
      AND (p.titulo + ISNULL(p.descripcion, '') + ISNULL(p.productor, '') + c.nombre)
          LIKE '%' + REPLACE(@parametro, ' ', '%') + '%'
      AND (@tipo IS NULL OR p.tipo = @tipo)
    ORDER BY p.estado DESC, p.titulo ASC;
END;
GO



-- Canales
INSERT INTO Canal (nombre, frecuencia)
VALUES 
('Canal 7', '90.1 FM'),
('Canal 13', '105.5 FM'),
('Canal 21', '87.7 FM');
GO

-- Programas
INSERT INTO Programa (idCanal, titulo, descripcion, duracion, tipo, productor, fechaEstreno)
VALUES
(1, 'Noticias al Día', 'Resumen de noticias locales y nacionales.', 60, 'Noticias', 'Juan Pérez', '2023-05-01'),
(2, 'Deportes Hoy', 'Resumen deportivo nacional e internacional.', 45, 'Deportes', 'Carlos Ruiz', '2023-04-10'),
(3, 'Música en Vivo', 'Conciertos y artistas invitados.', 90, 'Música', 'Ana Torres', '2023-07-20');
GO

EXEC paListarCanales '';
GO

EXEC paListarProgramas '';
GO
