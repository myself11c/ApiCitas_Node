IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[ApiCitas].[Administradoras]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [ApiCitas].[Administradoras]
GO

IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[ApiCitas].[usp_Administradoras]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [ApiCitas].[usp_Administradoras]
GO

CREATE PROCEDURE [ApiCitas].[usp_Administradoras] 
AS BEGIN
/*
		----------------------------------------------------------------------------
		Nombre:			  [ApiCitas].[usp_Administradoras]
		----------------------------------------------------------------------------
		Tipo:			  Procedimiento almacenado
		creación:			  2018 JUL 24
		Desarrollador:		  Victor Alfonso Cardona Hernandez
		Proposito:		  Consultar Administradoras
		Parámetros:		  N/A
		----------------------------------------------------------------------------
		-- Salidas:		  Listado de las Administradoras que tiene el bit AtencionCitas Activo
		----------------------------------------------------------------------------
		----------------------------------------------------------------------------
		-- Modificaciones
		----------------------------------------------------------------------------
	-- Pruebas y Ejemplos

	   EXEC [ApiCitas].[usp_Administradoras]

*/ 

    SELECT CodAdminis AS 'Codigo'
	   , Nombre AS 'Nombre'
    FROM dbo.Administradoras WITH(NOLOCK)
    WHERE Citas <> 0
    ORDER BY Nombre
	
END