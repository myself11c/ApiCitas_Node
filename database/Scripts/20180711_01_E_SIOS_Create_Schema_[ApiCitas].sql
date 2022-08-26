-- =================================================================
-- Author:		Alvaro García
-- Create date: 2018/07/11
-- Description:	Crea el esquema para la API de citas
-- =================================================================

IF NOT EXISTS (SELECT 1 FROM SYS.SCHEMAS WHERE name = 'ApiCitas')
BEGIN
	EXEC('CREATE SCHEMA ApiCitas')
END
GO