IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[ApiCitas].[Sedes]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [ApiCitas].[Sedes]
GO

IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[ApiCitas].[usp_Sedes]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [ApiCitas].[usp_Sedes]
GO

CREATE PROCEDURE [ApiCitas].[usp_Sedes] 
AS BEGIN
/*
		----------------------------------------------------------------------------
		Nombre:			[ApiCitas].[usp_Sedes]
		----------------------------------------------------------------------------
		Tipo:			  Procedimiento almacenado
		creación:			  2018 JUL 24
		Desarrollador:		  Victor Alfonso Cardona Hernandez
		Proposito:		  Consultar Sedes
		Parámetros:		  N/A
		----------------------------------------------------------------------------
		-- Salidas:		  Listado de las sedes que tiene el bit AtencionCitas Activo
		----------------------------------------------------------------------------
		----------------------------------------------------------------------------
		-- Modificaciones
		----------------------------------------------------------------------------
	-- Pruebas y Ejemplos
		EXEC [ApiCitas].[usp_Sedes]
*/ 

    DECLARE @xmlConfiguracionSedes XML = NULL
    --Obtener la configuración de las consultas por primera vez o control
    SELECT TOP 1 @xmlConfiguracionSedes = A.VlrXml
    FROM [dbo].[admConfiguracion] A WITH(NOLOCK) 
    WHERE Codigo = 'SedesAplicaApiCita'  

    IF @xmlConfiguracionSedes IS NULL BEGIN
	   RAISERROR('No se han configurado las sedes que aplican para la Api de asignación de citas.',16,1);
	   RETURN;
    END
	  
    SELECT 
	   Codigo
	   , Descrip AS 'Nombre'
    FROM dbo.PuestoAtencion PA WITH(NOLOCK)
		INNER JOIN @xmlConfiguracionSedes.nodes('/Configuracion/Sedes') AS T(c) ON PA.Codigo = T.c.query('.').value('(//IdSede)[1]', 'VARCHAR(20)')  
    WHERE AtencionCitas <> 0

END