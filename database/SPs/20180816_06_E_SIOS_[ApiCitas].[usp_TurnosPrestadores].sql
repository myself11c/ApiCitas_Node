IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[ApiCitas].[TurnosPrestadores]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [ApiCitas].[TurnosPrestadores]
GO

IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[ApiCitas].[usp_TurnosPrestadores]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [ApiCitas].[usp_TurnosPrestadores]
GO

CREATE PROCEDURE [ApiCitas].[usp_TurnosPrestadores](
     @sAccion				  VARCHAR(50)
    ,@sCodigoEspecialidad	  VARCHAR(10) = NULL
    ,@sIdSede				  VARCHAR(10) = NULL
    ,@sIdPaciente			  VARCHAR(8)  = NULL
    ,@iTope					  INT		  = NULL
    ,@bCitaEspecialista		  BIT		  = 0
    ,@sFecha				  VARCHAR(8)  = NULL--//YYYYMMDD Formato 112 SQL
    ,@sIdPrestador			  VARCHAR(20) = NULL
    ,@sTipoIdentificacion	  VARCHAR(5)  = NULL
    ,@sNumeroIdentificacion	  VARCHAR(20) = NULL

)
AS BEGIN

        /*
		----------------------------------------------------------------------------
		Nombre:			[ApiCitas].[usp_TurnosPrestadores]
		----------------------------------------------------------------------------
		Tipo:			  Procedimiento almacenado
		creación:			  2018 JUL 09
		Desarrollador:		  Victor Alfonso Cardona Hernandez
		Proposito:		  obtener información de los turnos del prestador
		Parámetros:		  @sAccion				 --> Indica el bloque del SP que se ejecutara
						  ,@sCodigoEspecialidad	 --> Código de la especialudad del prestador
						  ,@sIdSede				 --> Código de la sede donde se quiere verificar si hay disponibilidad - Si este valor el null se consultara en todas las sedes
						  ,@sIdPaciente			 --> Id consecutivo del paciente
						  ,@iTope				 --> Indica la cantidad de registro que se devolveran aplica a la consulta ListarTurnosPrestadores
						  ,@bCitaEspecialista       --> Indica si la disponibilidad del prestador que se quiere buscar es por especialista(1) - o No (0)
						  ,@sFecha				 --> Fecha en al cual se consultaran los cupos disponibles
						  ,@sFecha				 --> Fecha en al cual se consultaran los cupos disponibles
						  ,@sIdPrestador			 --> Id del prestador al cual se le consultaran los cupos disponibles
						  ,@sTipoIdentificacion	 --> Tipo de identificacion del paciente
						  ,@sNumeroIdentificacion   --> Número de identificacion del paciente
						 
		----------------------------------------------------------------------------
		-- Salidas:
		----------------------------------------------------------------------------
			Según el parametro @sAccion:

			 --ListarTurnosPrestadores	   --> Lista que contine Prestador - Sede - Fecha de los turnos del prestador
			 --ListarCuposDisponiblesFecha   --> Lista De los cupos disponibles del prestador en la sede y fecha seleleccionada

		----------------------------------------------------------------------------
		-- Modificaciones
		----------------------------------------------------------------------------
	     -- Pruebas y Ejemplos
		  --@sAccion: ListarTurnosPrestadores No especialista
		  EXEC [ApiCitas].[usp_TurnosPrestadores]
			  @sAccion			 = 'ListarTurnosPrestadores'
			 ,@sCodigoEspecialidad	 = '389'
			 ,@sIdSede			 = '01'
			 ,@sIdPaciente		 = '9986'
			 ,@iTope				 = 5
			 ,@bCitaEspecialista	 = 0

		  --@sAccion: ListarTurnosPrestadores  especialista
		  EXEC [ApiCitas].[usp_TurnosPrestadores]
	   		  @sAccion			 = 'ListarTurnosPrestadores'
			 ,@sCodigoEspecialidad	 = '389'
			 ,@sIdSede			 = '01'
			 ,@sIdPaciente		 = '9986'
			 ,@iTope				 = 5
			 ,@bCitaEspecialista	 = 1

		 -- @sAccion: ListarCuposDisponiblesFecha 
		  EXEC [ApiCitas].[usp_TurnosPrestadores]
	   		  @sAccion			 = 'ListarCuposDisponiblesFecha'
			 ,@sIdSede			 = '01'
			 ,@sCodigoEspecialidad	 = '389'
			 ,@sFecha				 = '20180727'
			 ,@sIdPrestador		 = '73200534'

    */ 

    DECLARE @fFechaActual DATE = GETDATE();
    DECLARE @fFechaInicial DATE =  NULL;
    DECLARE @fFechaFin DATE =  NULL;
    DECLARE @bPrimeraVez BIT = 1
    DECLARE @sOperador VARCHAR(5) = ''
    DECLARE @iInicio INT = ''
    DECLARE @iFin INT = ''
    DECLARE @sUnidad VARCHAR(5) = ''
    DECLARE @XmlConfiguracionOportunidad XML = NULL
    DECLARE @XmlConfiguracionMedAplicanApiCita XML = NULL

    

    IF @iTope IS NULL BEGIN SET @iTope = 15 END

    IF @sAccion = 'ListarTurnosPrestadores' BEGIN

	   SELECT TOP 1 @bPrimeraVez = 0
	   FROM dbo.ConsultasMedicas CM WITH(NOLOCK)
	   WHERE CM.Paciente = @sIdPaciente
		  AND Especialidad = @sCodigoEspecialidad
		  AND Atendido <> 0
		  AND (Cancelada IS NULL OR Cancelada = 0)

	   SELECT TOP 1 @XmlConfiguracionMedAplicanApiCita = VlrXml 
	   FROM dbo.admconfiguracion WITH(NOLOCK) 
	   WHERE codigo = 'MedAplicanApiCita'

	   IF @XmlConfiguracionMedAplicanApiCita IS NULL BEGIN
		  	
		  RAISERROR('No se han configurado los prestadores.',16,1);
		  RETURN;

	   END 

	   SELECT TOP 1 @XmlConfiguracionOportunidad = VlrXml 
	   FROM dbo.admconfiguracion WITH(NOLOCK) 
	   WHERE codigo = 'OportunidadAsigCita'

	   IF @XmlConfiguracionOportunidad IS NOT NULL BEGIN

		  SELECT  @sOperador = T.c.query('.').value('(//IdOperador)[1]', 'VARCHAR(20)') 
			 , @iInicio = T.c.query('.').value('(//Inicio)[1]', 'INT') 
			 , @iFin = T.c.query('.').value('(//Fin)[1]', 'INT') 
			 , @sUnidad = T.c.query('.').value('(//IdUnidad)[1]', 'VARCHAR(20)') 
		  FROM  @XmlConfiguracionOportunidad.nodes('/Configuracion/Oportunidad') AS T(c)
		  WHERE  (
				    (@bPrimeraVez = 1 AND @bCitaEspecialista = 0 AND T.c.query('.').value('(//IdTipoCita)[1]', 'VARCHAR(20)') = 'MG' AND T.c.query('.').value('(//IdTipoConsulta)[1]', 'VARCHAR(20)') = 'P' ) OR --// Cita de primera vez y no es de especialista
				    (@bPrimeraVez = 0 AND @bCitaEspecialista = 0 AND T.c.query('.').value('(//IdTipoCita)[1]', 'VARCHAR(20)') = 'MG' AND T.c.query('.').value('(//IdTipoConsulta)[1]', 'VARCHAR(20)') = 'C' ) OR --// Cita NO primera vez y No es de especialista
				    (@bPrimeraVez = 0 AND @bCitaEspecialista = 1 AND T.c.query('.').value('(//IdTipoCita)[1]', 'VARCHAR(20)') = 'ME' AND T.c.query('.').value('(//IdTipoConsulta)[1]', 'VARCHAR(20)') = 'C' ) OR --// Cita NO primera vez y SI es de especialista
				    (@bPrimeraVez = 1 AND @bCitaEspecialista = 1 AND T.c.query('.').value('(//IdTipoCita)[1]', 'VARCHAR(20)') = 'ME' AND T.c.query('.').value('(//IdTipoConsulta)[1]', 'VARCHAR(20)') = 'P' )    --// Cita SI primera vez y SI es de especialista
			 )

		  --SELECT @sOperador, @iInicio, @iFin, @sUnidad, @bPrimeraVez, @bCitaEspecialista

		  IF @sOperador = 'R' BEGIN

			 IF @sUnidad = 'D' BEGIN

				SET @fFechaInicial = DATEADD(day, @iInicio, @fFechaActual);
				SET @fFechaFin = DATEADD(day, @iFin, @fFechaActual);
    
			 END
			 ELSE BEGIN

				SET @fFechaInicial = DATEADD(MONTH, @iInicio, @fFechaActual);
				SET @fFechaFin = DATEADD(MONTH, @iFin, @fFechaActual);
    
			 END 

		  END
		  ELSE IF @sOperador = 'M' BEGIN

			 IF @sUnidad = 'D' BEGIN

				SET @fFechaInicial = DATEADD(day, @iInicio, @fFechaActual);
				SET @fFechaFin = DATEADD(day, 60, @fFechaActual);
    
			 END
			 ELSE BEGIN

				SET @fFechaInicial = DATEADD(MONTH, @iInicio, @fFechaActual);
				SET @fFechaFin = DATEADD(MONTH, 2, @fFechaActual);
    
			 END 

		  END

	   END
	   ELSE BEGIN

		  SET @fFechaInicial = DATEADD(day, 1, @fFechaActual);
		  SET @fFechaFin = DATEADD(day, 60, @fFechaActual);

	   END
	   
	   IF Object_Id('tempdb..#TempTurnosPrestadores') IS NOT NULL DROP TABLE [dbo].#TempTurnosPrestadores

	   CREATE TABLE #TempTurnosPrestadores(
		    IdPrestador		 VARCHAR(20),
		    Prestador			 VARCHAR(200),  
		    FechaO			 DATE,  
		    Fecha				 VARCHAR(10),  
		    Sede				 VARCHAR(200),
		    IdSede			 VARCHAR(10)  
	   )

	   INSERT INTO #TempTurnosPrestadores
	   SELECT TOP (@iTope) 
		  Prestador AS 'IdPrestador'
		  ,P.Nombre AS 'Prestador'
		  ,TP.Fecha AS 'FechaO'
		  ,CONVERT(VARCHAR(10),TP.Fecha, 103) AS 'Fecha'
		  ,PA.Descrip AS 'Sede'
		  ,PA.Codigo AS 'IdSede'
	   FROM dbo.TurnosPrestadores TP WITH(NOLOCK) 
		  INNER JOIN dbo.Prestadores P WITH(NOLOCK) ON TP.Prestador = P.Identificacion
		  INNER JOIN dbo.PuestoAtencion PA WITH(NOLOCK) ON TP.PuestoAtencion = PA.Codigo
		  INNER JOIN  @XmlConfiguracionMedAplicanApiCita.nodes('/Configuracion/Prestadores') AS T(c) ON TP.Prestador = T.c.query('.').value('(//IdPrestador)[1]', 'VARCHAR(20)')
	   WHERE TP.Especialidad = @sCodigoEspecialidad
		  AND ((@sIdSede IS NULL OR @sIdSede = '') OR  (PA.Codigo = @sIdSede))
		  AND Fecha BETWEEN @fFechaInicial AND @fFechaFin
	   GROUP BY Prestador, P.Nombre, TP.Fecha, PA.Descrip, PA.Codigo
	   ORDER BY TP.Fecha

	   IF NOT EXISTS(SELECT TOP 1 1 FROM #TempTurnosPrestadores) BEGIN 

		  INSERT INTO #TempTurnosPrestadores
		  SELECT TOP (@iTope) 
			 Prestador AS 'IdPrestador'
			 ,P.Nombre AS 'Prestador'
			 ,TP.Fecha AS 'FechaO'
			 ,CONVERT(VARCHAR(10),TP.Fecha, 103) AS 'Fecha'
			 ,PA.Descrip AS 'Sede'
			 ,PA.Codigo AS 'IdSede'
		  FROM dbo.TurnosPrestadores TP WITH(NOLOCK) 
			 INNER JOIN dbo.Prestadores P WITH(NOLOCK) ON TP.Prestador = P.Identificacion
			 INNER JOIN dbo.PuestoAtencion PA WITH(NOLOCK) ON TP.PuestoAtencion = PA.Codigo
			 INNER JOIN  @XmlConfiguracionMedAplicanApiCita.nodes('/Configuracion/Prestadores') AS T(c) ON TP.Prestador = T.c.query('.').value('(//IdPrestador)[1]', 'VARCHAR(20)')
		  WHERE TP.Especialidad = @sCodigoEspecialidad
			 AND ((@sIdSede IS NULL OR @sIdSede = '') OR  (PA.Codigo = @sIdSede))
			 AND Fecha > @fFechaInicial  
		  GROUP BY Prestador, P.Nombre, TP.Fecha, PA.Descrip, PA.Codigo
		  ORDER BY TP.Fecha

	   END

	   SELECT 
		   IdPrestador 
		  ,Prestador
		  ,Fecha
		  ,Sede
		  ,IdSede 
	   FROM #TempTurnosPrestadores WITH(NOLOCK)
	   ORDER BY FechaO

	   IF Object_Id('tempdb..#TempTurnosPrestadores') IS NOT NULL DROP TABLE [dbo].#TempTurnosPrestadores
 
    END
    IF @sAccion = 'ListarCuposDisponiblesFecha' BEGIN

	   SET @fFechaInicial = CONVERT(DATE, @sFecha, 112);
	   
	   IF Object_Id('tempdb..#TempCuposPrestador') IS NOT NULL DROP TABLE [dbo].#TempCuposPrestador
	   IF Object_Id('tempdb..#TempTurnosPrestador2') IS NOT NULL DROP TABLE [dbo].#TempTurnosPrestador2

	   SELECT  
		  TP.Prestador AS 'IdPrestador'
	   	  ,TP.PuestoAtencion AS 'IdSede'
	   	  ,TP.Id AS 'IdTurno'
		  ,TP.Duracion
		  ,TP.Concurrencia
		  ,TP.FechaInicial
		  ,TP.NumeroTurnos
		  ,TP.Especialidad
	   	  INTO #TempTurnosPrestador2
	   FROM dbo.TurnosPrestadores TP WITH(NOLOCK)
	   WHERE Especialidad = @sCodigoEspecialidad
	   	 AND TP.Prestador = @sIdPrestador
	   	 AND TP.PuestoAtencion = @sIdSede
	   	 AND Fecha = @fFechaInicial 

	   SELECT
		  TP.IdPrestador
	   	  ,TP.IdSede
	   	  ,TP.IdTurno
		  ,TP.Concurrencia
		  ,DATEADD(MINUTE, (Duracion * Numero), TP.FechaInicial) AS FechaCita 
		  ,CAST(0 AS INT) AS 'CitasAsignadas' 
		  ,TP.Especialidad
		  INTO #TempCuposPrestador
	   FROM #TempTurnosPrestador2 TP WITH(NOLOCK)
		  INNER JOIN gNumeros N WITH(NOLOCK) ON N.Numero IS NOT NULL
	   WHERE N.Numero < TP.NumeroTurnos 


	   UPDATE T
	   SET CitasAsignadas = (

						  SELECT COUNT(Id) 
						  FROM dbo.ConsultasMedicas CM WITH(NOLOCK) 
						  WHERE CM.Prestador = T.IdPrestador
							 AND CM.Localidad = T.IdSede
							 AND CM.Programada <> 0
							 AND CM.Especialidad = T.Especialidad
							 AND (CM.Cancelada IS NULL OR CM.Cancelada = 0)
							 AND CM.FechaAsignada = T. FechaCita
						)
	   FROM #TempCuposPrestador T

	   SELECT TP.IdPrestador
	   	  ,TP.IdSede
	   	  ,TP.IdTurno
		  ,TP.Concurrencia
		  ,TP.FechaCita  AS 'FechaHoraCita' 
		  ,TP.Especialidad 
		  ,CONVERT(VARCHAR(5),TP.FechaCita,108) AS 'HoraCita' 
		  ,CONVERT(VARCHAR(8),TP.FechaCita,112) AS 'FechaCita' 
		  ,RIGHT(CONVERT(VARCHAR(50), TP.FechaCita, 109), 2) AS 'Jornada' 
	   FROM #TempCuposPrestador TP
	   WHERE Concurrencia > CitasAsignadas

	   IF Object_Id('tempdb..#TempCuposPrestador') IS NOT NULL DROP TABLE [dbo].#TempCuposPrestador
	   IF Object_Id('tempdb..#TempTurnosPrestador2') IS NOT NULL DROP TABLE [dbo].#TempTurnosPrestador2
			 

    END

END