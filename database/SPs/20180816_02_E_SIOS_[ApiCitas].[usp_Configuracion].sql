IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[ApiCitas].[Configuracion]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [ApiCitas].[Configuracion]
GO

IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[ApiCitas].[usp_Configuracion]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [ApiCitas].[usp_Configuracion]
GO

CREATE PROCEDURE [ApiCitas].[usp_Configuracion](

    @sAccion				  VARCHAR(50)

)
AS BEGIN

        /*
		----------------------------------------------------------------------------
		Nombre:			[ApiCitas].[Configuracion]
		----------------------------------------------------------------------------
		Tipo:			Procedimiento almacenado
		creación:		     2018 JUL 09
		Desarrollador:		Victor Alfonso Cardona Hernandez
		Proposito:		Configuraciones asignación de citas
		Parámetros:		N/A
						 
		----------------------------------------------------------------------------
		-- Salidas:
		----------------------------------------------------------------------------
			Según el parametro @sAccion:
		----------------------------------------------------------------------------
	     -- Pruebas y Ejemplos
		  --@sAccion: 
			 

		----------------------------------------------------------------------------
		-- Modificaciones

    */ 


    IF @sAccion = 'DatosIniciales' BEGIN

	   SELECT  table_name = 'Planes'
		  , P.Id AS 'Codigo'
		  , P.Nombre AS 'Nombre'
		  , P.Administradora AS 'IdAdministradora'
	   FROM dbo.PlanAdm P WITH(NOLOCK)
	   WHERE P.Citas <> 0
		  AND P.Activo <> 0
	   ORDER BY Nombre

	   SELECT  table_name = 'Especialidades'
		  , E.Codigo AS 'Codigo'
		  , E.Codigo + ' - ' + E.Descrip AS 'Nombre'
	   FROM dbo.Especialidades E WITH(NOLOCK)

	   SELECT  table_name = 'Consultas'
		  , IdProcedimientos AS 'Codigo'
		  , E.CodProce + ' - ' + E.DESCRIP AS 'Nombre'
	   FROM dbo.Procedimientos E WITH(NOLOCK)
	   WHERE Activo <> 0
		  AND Clasificacion = 'C'

		SELECT table_name = 'Administradoras'
			, CodAdminis AS 'Codigo'
		    , Nombre AS 'Nombre'
		FROM dbo.Administradoras WITH(NOLOCK)
		WHERE Citas <> 0
		ORDER BY Nombre

		SELECT  table_name = 'Sedes'
			, Codigo
			, Codigo + ' - ' + Descrip AS 'Nombre'
		FROM dbo.PuestoAtencion WITH(NOLOCK)
		WHERE AtencionCitas <> 0

		SELECT  table_name = 'Prestadores'
			, Identificacion AS 'Codigo'
			, Identificacion + ' - ' + Nombre AS 'Nombre'
		FROM dbo.Prestadores WITH(NOLOCK)
		WHERE Cita <> 0

		SELECT table_name = 'Regimen'
			, Codigo
		    , Nombre
		FROM (
			SELECT 'C' AS 'Codigo', 'Contributivo' AS 'Nombre' UNION ALL
			SELECT 'O' AS 'Codigo', 'Otro' AS 'Nombre'   UNION ALL
			SELECT 'S' AS 'Codigo', 'Subsidiado' AS 'Nombre' 
		)AS T

		SELECT table_name = 'Operador'
			, Codigo
		    , Nombre
		FROM (
			SELECT 'R' AS 'Codigo', 'Rango' AS 'Nombre' UNION ALL
			SELECT 'M' AS 'Codigo', 'Mayor que' AS 'Nombre'  
		)AS T

		SELECT table_name = 'UnidadTiempo'
			, Codigo
		    , Nombre
		FROM (
			SELECT 'D' AS 'Codigo', 'Día(s)' AS 'Nombre' UNION ALL
			SELECT 'M' AS 'Codigo', 'Mes(es)' AS 'Nombre'  
		)AS T

		SELECT table_name = 'TipoConsulta'
			, Codigo
		    , Nombre
		FROM (
			SELECT 'C' AS 'Codigo', 'Control' AS 'Nombre' UNION ALL 
			SELECT 'P' AS 'Codigo', 'Primera vez' AS 'Nombre' 
		)AS T

		SELECT table_name = 'TipoCita'
			, Codigo
		    , Nombre
		FROM (
			SELECT 'MG' AS 'Codigo', 'Medicina general' AS 'Nombre' UNION ALL 
			SELECT 'ME' AS 'Codigo', 'Medicina especializada' AS 'Nombre' 
		)AS T

		SELECT table_name = 'TipoAtencion'
			, Codigo
		    , Nombre
		FROM (
			SELECT 'ES' AS 'Codigo', 'Especialista' AS 'Nombre'   UNION ALL
			SELECT 'EV' AS 'Codigo', 'Evento' AS 'Nombre' UNION ALL
			SELECT 'MG' AS 'Codigo', 'Medicina General' AS 'Nombre' 
		)AS T

    END

END