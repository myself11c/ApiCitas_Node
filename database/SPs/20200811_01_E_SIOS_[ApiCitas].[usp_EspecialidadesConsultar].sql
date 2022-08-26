IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[ApiCitas].[usp_EspecialidadesConsultar]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [ApiCitas].[usp_EspecialidadesConsultar]
GO

CREATE PROCEDURE [ApiCitas].[usp_EspecialidadesConsultar]
AS BEGIN

	/*


	    ----------------------------------------------------------------------------
		Nombre:			[ApiCitas].[usp_EspecialidadesConsultar]
		----------------------------------------------------------------------------
		Tipo:			Procedimiento almacenado
		creación:		11-AGO-2020
		Desarrollador:  Victor Alfonso CardonaHernandez
		Proposito:		Consultar las especialidades configuradas para api de citas
					
		Ejemplos:
		--------------

		EXEC [ApiCitas].[usp_EspecialidadesConsultar]

	*/ 
	DECLARE @xmlConfiguracionConsultas XML = NULL;
	
	SELECT TOP 1 @xmlConfiguracionConsultas = VlrXml 
	FROM dbo.admconfiguracion WITH(NOLOCK) 
	WHERE codigo = 'EspeciConsulAPiCita'

	SELECT  E.Codigo
		,	E.Descrip AS 'Nombre'
	FROM @xmlConfiguracionConsultas.nodes('/Configuracion/EspecialidadConsultas') AS T(c) 
				INNER JOIN dbo.Especialidades E ON  T.c.query('.').value('(//IdEspecialidad)[1]', 'VARCHAR(20)') = E.Codigo
	ORDER BY  E.Descrip
	 
END