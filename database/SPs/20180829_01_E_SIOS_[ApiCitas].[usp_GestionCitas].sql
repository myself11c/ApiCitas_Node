IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[ApiCitas].[usp_GestionCitas]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [ApiCitas].[usp_GestionCitas]
GO

CREATE PROCEDURE [ApiCitas].[usp_GestionCitas](

	@sAccion VARCHAR(50) 
	,@sIdPaciente VARCHAR(8) = NULL
	,@sIdAdministradora VARCHAR(20) = NULL
	,@iIdTurnos BIGINT = NULL
	,@sFechaCita VARCHAR(14) = NULL 
	,@sRegimen VARCHAR(1) = NULL 
	,@bCitaEspecializada BIT = 0 
	,@bVigentes BIT = 0 
	,@iIdCita BIGINT = NULL
	,@sTipoAtencion VARCHAR(2) = NULL

)
AS
BEGIN

    /*
		----------------------------------------------------------------------------
		Nombre:			[ApiCitas].[usp_GestionCitas]
		----------------------------------------------------------------------------
		Tipo:			Procedimiento almacenado
		creación:		     2018 JUL 09
		Desarrollador:		Victor Alfonso Cardona Hernandez
		Proposito:		Crud de pacientes
		Parámetros:		@sAccion				 --> Indica el bloque del SP que se ejecutara
						,@sIdPaciente			 --> Id consecutivo del paciente
						,@sIdAdministradora		 --> Id consecutivo de la administradora del paciente paciente
						,@iIdTurnos			 --> Id consecutivo del turno del prestador del caul se escoge el cupo a asignar
						,@sFechaCita			 --> Fecha en al que se asignara la cita (20180810 08:30 --> yyyyMMdd HH:mm)
						,@sRegimen			 --> Identificador del regimen del paciente  (Contributivo --> C, Subsiciado --> S, Otro --> O)
						,@bCitaEspecializada      --> Indica si la disponibilidad del prestador que se quiere buscar es por especialista(1) - o No (0)
						,@bVigentes			 --> Indica si en el bloque del historial del pacoente se mostraran todas las citas (bVigentes = 0) o solo las que estan vigentes (bVigentes = 1) que aun no se han cuplido y no han sido canceladas
						,@iIdCita				 --> Id consecutivo que se sele asigna a la cita al registrarse 
						,@sTipoAtencion		 --> Indica el tipo de atencion esto es para obtener el plan
						 
		----------------------------------------------------------------------------
		-- Salidas:
		----------------------------------------------------------------------------
			Según el parametro @sAccion:

			 --Insertar			--> Datos de la cita que se acaba de insertar 
			 --ConsultarCita		--> Datos de la cita a la cual pertenece el id recibido por el SP
			 --ConsultarHistorial	--> Lista de las citas del paciente
			 --Cancelar			--> Ok si no hay error

		----------------------------------------------------------------------------
		-- Modificaciones
		----------------------------------------------------------------------------
	     -- Pruebas y Ejemplos
		  --@sAccion: Cancelar  
		   EXEC [ApiCitas].[usp_GestionCitas] 
			  @sAccion = 'Cancelar'
			  ,@iIdCita = 19862

		  --@sAccion: ConsultarCita  
		   EXEC [ApiCitas].[usp_GestionCitas] 
			  @sAccion = 'ConsultarCita'
			  ,@iIdCita = 19862

		  --@sAccion: ConsultarHistorial  (Historial) 
		   EXEC [ApiCitas].[usp_GestionCitas] 
			  @sAccion = 'ConsultarHistorial'
			  ,@sIdPaciente = '10002'
			  ,@bVigentes = 0

		  --@sAccion: ConsultarHistorial  (Vigentes) 
		   EXEC [ApiCitas].[usp_GestionCitas] 
			  @sAccion = 'ConsultarHistorial'
			  ,@sIdPaciente = '10002'
			  ,@bVigentes = 1

		  --@sAccion: Insertar  
		  EXEC [ApiCitas].[usp_GestionCitas]
		    @sAccion			 = 'Insertar' 
		   ,@sIdPaciente		 = '10002'	
		   ,@sIdAdministradora	 = '3831'
		   ,@iIdTurnos			 = 12917
		   ,@sFechaCita		 = '20180810 08:30' 
		   ,@sRegimen			 = 'C' 
		   ,@bCitaEspecializada	 = 1

		   --@sAccion: ConsultarHistorial  (Historial) 
		   EXEC [ApiCitas].[usp_GestionCitas] 
			  @sAccion = 'ValidarUltimaCitaIncumplida'
			  ,@sIdPaciente = '10002'


    */  

	DECLARE @iIdClasificacionCita BIGINT = NULL
	DECLARE @fFechaAsignada DATETIME = NULL
	DECLARE @fFechaActual DATE = NULL
	DECLARE @sIdProcedimiento VARCHAR(20) = NULL
	DECLARE @sIdEspecialidad VARCHAR(20) = NULL
	DECLARE @sIdPrestador VARCHAR(20) = NULL
	DECLARE @sIdPuestoAtencion VARCHAR(20) = NULL
	DECLARE @sIdConsultorio VARCHAR(20) = NULL
	DECLARE @sCodigoConsultorio VARCHAR(20) = NULL
	DECLARE @sNombreConsultorio VARCHAR(20) = NULL
	DECLARE @xmlConfiguracionConsultas XML = NULL
	DECLARE @xmlConfiguracionPlanes XML = NULL
	DECLARE @bCitaPrimeraVez BIT = 1
	DECLARE @iIdPlan BIGINT = NULL 
	DECLARE @iConcurrencia  INT = NULL
	DECLARE @sCupoDisponible  VARCHAR(1) = NULL
	DECLARE @sConsecutivoCita  VARCHAR(20) = NULL
	DECLARE @sCodigoMedioSolicitud  VARCHAR(20) = NULL
	DECLARE @sCodigoTipoConsulta  VARCHAR(20) = NULL
	DECLARE @sCodigoTipoCita  VARCHAR(20) = NULL
	DECLARE @sCodigoMotivoCancelacionCita  VARCHAR(20) = NULL
	DECLARE @sError  VARCHAR(MAX) = NULL
	DECLARE @sIdentificacion  VARCHAR(20) = NULL

	--Variables validación por frecuencia de servicios
     DECLARE @sSexo CHAR(1) = NULL,
		  @sErrorValidacion VARCHAR(MAX) = ''
     DECLARE @dtConfigFrec TABLE (IdProcedimiento NVARCHAR(6), UnidadFrecuencia CHAR(3), Frecuencia INT, AdmPlan INT, FechaInicio DATETIME, Validado BIT)
     DECLARE @IdProcedimiento NVARCHAR(6),
		  @NombreProcedimiento VARCHAR(MAX),
		  @UnidadFrecuencia CHAR(3),
		  @NumeroCitas INT,
		  @Frecuencia INT,
		  @AdmPlan INT,
		  @fFechaInicial DATETIME  
		   
    IF @sAccion = 'Insertar' BEGIN

	   BEGIN TRY
		
		  SET @fFechaAsignada = CONVERT(DATETIME,@sFechaCita,112);

		  IF @fFechaAsignada < GETDATE() BEGIN

			 RAISERROR('No se puede asignar la cita con una fecha anterior a la fecha y hora actual.',16,1);

		  END
	    
		  IF NOT EXISTS
		  (
			 SELECT TOP 1 Id 
			 FROM dbo.ConsultasMedicas WITH(NOLOCK)
			 WHERE Paciente = @sIdPaciente 
			    AND FechaAsignada = @fFechaAsignada
			    AND ((Cancelada = 0) OR (Cancelada IS NULL)) 
		  )
		  BEGIN
		
			 -- Obtener la clasificación de cita asociada al turno
			 SELECT TOP 1 @iIdClasificacionCita = TP.ClasificacionCita 
				,@sIdEspecialidad = TP.Especialidad
				,@sIdPrestador = TP.Prestador
				,@sIdPuestoAtencion = TP.PuestoAtencion
				,@sIdConsultorio = TP.idConsultorio
				,@iConcurrencia = TP.Concurrencia
				,@sCodigoConsultorio = C.Codigo
				,@sNombreConsultorio = C.Nombre
			 FROM [dbo].[TurnosPrestadores] AS TP WITH(NOLOCK) 
				LEFT JOIN dbo.Consultorios AS C WITH(NOLOCK) ON C.idConsultorio = TP.idConsultorio
			 WHERE TP.Id = @iIdTurnos

			  --Sexo del paciente
        		 SELECT	TOP 1
        	  	    @sSexo = P.Sexo
			    ,@sIdentificacion = P.Identificacion
        		 FROM	[dbo].[Pacientes] AS P WITH(NOLOCK)
        		 WHERE	P.Id = @sIdPaciente
		  
			 --Validar si es de control o primera vez
			 IF EXISTS(

				SELECT TOP 1 1 
				FROM dbo.ConsultasMedicas CM WITH(NOLOCK) 
				WHERE Paciente = @sIdPaciente 
		  		    AND ((Cancelada = 0) OR (Cancelada IS NULL)) 
		  		    AND @sIdEspecialidad =  CM.Especialidad
				    AND Atendido <> 0

			 ) BEGIN
				SET @bCitaPrimeraVez = 0;
			 END

			 SELECT TOP 1 @sCodigoMedioSolicitud = Codigo
			 FROM dbo.gVentanaSimPle WITH(NOLOCK)
			 WHERE VentanaId = 'MedSolitCitas' 
				AND Activo <> 0 
				AND ((Nombre LIKE '%Internet%') OR (Nombre LIKE '%web%'))

			 IF @sCodigoMedioSolicitud IS NULL BEGIN

				INSERT INTO dbo.gVentanaSimPle (Nombre,Codigo,Tag, Activo,VentanaId)
				VALUES('Internet','MS999',0,1,'MedSolitCitas')

				SET @sCodigoMedioSolicitud = 'MS999';

			 END

			 IF @bCitaEspecializada = 0 BEGIN

				SELECT TOP 1 @sCodigoTipoConsulta = Codigo
				FROM dbo.gVentanaSimPle WITH(NOLOCK)
				WHERE VentanaId='TiposConsultas' 
				    AND Activo <> 0 
				    AND ((Nombre LIKE '%MEDICINA GENERAL%'))  

				IF @sCodigoTipoConsulta IS NULL BEGIN 

				    INSERT INTO dbo.gVentanaSimPle (Nombre,Codigo,Tag, Activo,VentanaId)
				    VALUES('MEDICINA GENERAL','TC999',0,1,'TiposConsultas')

				    SET @sCodigoTipoConsulta = 'TC999';

				END

			 END
			 ELSE BEGIN

				SELECT TOP 1 @sCodigoTipoConsulta = Codigo
				FROM dbo.gVentanaSimPle WITH(NOLOCK)
				WHERE VentanaId='TiposConsultas' 
				    AND Activo <> 0 
				    AND ((Nombre LIKE '%MEDICINA ESPECIALIZADA%'))  

				IF @sCodigoTipoConsulta IS NULL BEGIN 

				    INSERT INTO dbo.gVentanaSimPle (Nombre,Codigo,Tag, Activo,VentanaId)
				    VALUES('MEDICINA ESPECIALIZADA','TC998',0,1,'TiposConsultas')

				    SET @sCodigoTipoConsulta = 'TC998'; 

				END

			 END

			 IF @bCitaPrimeraVez = 1 BEGIN 

				SELECT TOP 1 @sCodigoTipoCita = Codigo
				FROM dbo.gVentanaSimPle WITH(NOLOCK)
				WHERE VentanaId='TiposCitas' 
				    AND Activo <> 0 
				    AND ((Nombre LIKE '%PrimeraVez%'))  
			 
			 END
			 ELSE BEGIN

				SELECT TOP 1 @sCodigoTipoCita = Codigo
				FROM dbo.gVentanaSimPle WITH(NOLOCK)
				WHERE VentanaId='TiposCitas' 
				    AND Activo <> 0 
				    AND ((Nombre LIKE '%Control%') OR (Nombre LIKE '%Seguimiento%') )  
				ORDER BY Nombre
				  
			 END

			 --Obtener la configuración de las consultas por primera vez o control
			 SELECT TOP 1 @xmlConfiguracionConsultas = A.VlrXml
			 FROM [dbo].[admConfiguracion] A WITH(NOLOCK) 
			 WHERE Codigo = 'EspeciConsulAPiCita'  

			 IF @xmlConfiguracionConsultas IS NULL BEGIN
		  	    RAISERROR('No es posible asignar la cita, no se pudo obtener la configuración de las consultas por especialidades.',16,1);
			 END

			 SELECT  TOP 1  @sIdProcedimiento = CASE 
												WHEN @bCitaPrimeraVez = 1 THEN T.c.query('.').value('(//IdConsultaPrimeraVez)[1]', 'VARCHAR(20)')  
												WHEN @bCitaPrimeraVez = 0 THEN T.c.query('.').value('(//IdConsultaControl)[1]', 'VARCHAR(20)')  
										    END
			 FROM  @xmlConfiguracionConsultas.nodes('/Configuracion/EspecialidadConsultas') AS T(c)
			 WHERE T.c.query('.').value('(//IdEspecialidad)[1]', 'VARCHAR(20)') = @sIdEspecialidad

			 IF @sIdProcedimiento IS NULL BEGIN
		  	    RAISERROR('No es posible asignar la cita, no se pudo obtener la consulta con la que se asignara la cita.',16,1);
			 END
			 --FIN Obtener la configuración de las consultas por primera vez o control

			 --Obtener la configuración de los planes
			 SELECT TOP 1 @xmlConfiguracionPlanes = A.VlrXml
			 FROM [dbo].[admConfiguracion] A WITH(NOLOCK) 
			 WHERE Codigo = 'PlanDefAPiCita'  

			 IF @xmlConfiguracionPlanes IS NULL BEGIN
		  	    RAISERROR('No es posible asignar la cita, no se pudo obtener la configuración de los planes para la asignación de la cita.',16,1);
			 END

			 SELECT  TOP 1  @iIdPlan =  T.c.query('.').value('(//IdPlan)[1]', 'BIGINT')  
			 FROM  @xmlConfiguracionPlanes.nodes('/Configuracion/AdministradorasRegimenPlan') AS T(c)
			 WHERE T.c.query('.').value('(//IdAdministradora)[1]', 'VARCHAR(20)') = @sIdAdministradora
				AND T.c.query('.').value('(//IdRegimen)[1]', 'VARCHAR(20)') = @sRegimen
				AND T.c.query('.').value('(//IdTipoAtencion)[1]', 'VARCHAR(20)') = @sTipoAtencion

			 IF @iIdPlan IS NULL BEGIN
		  	    RAISERROR('No es posible asignar la cita, no se pudo obtener el plan con la que se asignara la cita.',16,1);
			 END
			 --FIN Obtener la configuración de los planes
		  
			 -- Si el turno tiene clasificación de citas asociado valida los procedimientos
			 IF (@iIdClasificacionCita IS NOT NULL)
			 BEGIN

				IF EXISTS
				(
			 	    SELECT  TOP 1
			 		    'Existe'
			 	    FROM    [Administracion].[ProceClasificacionCitas] AS PCC WITH(NOLOCK)
			 	    WHERE   PCC.IdClasificacionCita = @iIdClasificacionCita 
				)
				BEGIN
			 
			 		--Validar si los procedimientos agregados no corresponden con la clasificación de cita asociada al turno
			 	    IF EXISTS
			 	    (
			 		   SELECT  TOP 1
			 				  'Existe'
			 		   FROM    [Administracion].[ProceClasificacionCitas] AS PCC WITH(NOLOCK) 
			 		   WHERE   PCC.IdProcedimiento IS NULL
			 			  AND @sIdProcedimiento = PCC.IdProcedimiento 
			 			  AND PCC.IdClasificacionCita = @iIdClasificacionCita 
			 	    )
			 	    BEGIN
			 		    RAISERROR('No es posible asignar la cita, debido a que existen consultas o procedimientos que no estan asociados a la clasificación de cita configurada al turno. Por favor verifique',16,1)
			 		    RETURN
				    END
				END

			 END
			 
			 --Verificar restricción de frecuencia por servicio 
			 IF EXISTS (SELECT TOP 1 'Existe' FROM [dbo].[admConfiguracion] WITH(NOLOCK) WHERE Codigo = 'HabResOrdFreSer' AND VlrBit = 1) BEGIN
        		   
				--Consultar configuración
				INSERT INTO @dtConfigFrec
				SELECT  PSF.IdProcedimiento,
				    CASE 
					   WHEN PSF.UnidadFrecuencia = 'M' THEN 'Mes'
					   WHEN PSF.UnidadFrecuencia = 'D' THEN 'Dia'
					   ELSE 'Año'
				    END,
				    PSF.Frecuencia,
				    PSF.IdPlan,
				    CASE 
					   WHEN PSF.UnidadFrecuencia = 'M' THEN DATEADD(MONTH,-1, GETDATE())
					   WHEN PSF.UnidadFrecuencia = 'D' THEN DATEADD(DAY,-1, GETDATE())
					   ELSE DATEADD(YEAR,-1, GETDATE())
				    END,
				    0
				FROM	[Contratacion].[relPlanServiciosFrencuencias] AS PSF WITH(NOLOCK) 
				WHERE	PSF.Sexo IN (@sSexo,'A')
				    AND PSF.IdProcedimiento = @sIdProcedimiento
				    AND PSF.IdPlan = @iIdPlan
				  
				--Validar configuración
				WHILE ((SELECT TOP 1 COUNT(*) FROM @dtConfigFrec WHERE Validado = 0) > 0) BEGIN
			 									
				    --Obtener registro	   
				    SELECT  TOP 1
					   @IdProcedimiento = C.IdProcedimiento,
					   @NombreProcedimiento = P.DESCRIP,
					   @Frecuencia = Frecuencia,
					   @UnidadFrecuencia = UnidadFrecuencia,
					   @AdmPlan = AdmPlan,
					   @fFechaInicial = FechaInicio
				    FROM	   @dtConfigFrec AS C
					   INNER JOIN [dbo].[Procedimientos] AS P WITH(NOLOCK) ON C.IdProcedimiento = P.IdProcedimientos
				    WHERE   C.Validado = 0
						
				    --Consultar frecuencia
				    SELECT  @NumeroCitas = COUNT(CM.Id)
				    FROM    [dbo].[ConsultasMedicas] AS CM WITH(NOLOCK)
					  INNER JOIN [dbo].[relConsMedProce] AS RP WITH(NOLOCK) ON CM.Id = RP.IdConsulta
				    WHERE   RP.IdProce = @IdProcedimiento
					  AND CM.IdPlan = @AdmPlan
					  AND CM.Paciente = @sIdPaciente
					  AND (CM.FechaAsignada BETWEEN @fFechaInicial AND GETDATE())
						
				    --Validacion de frecuencia
				    IF (ISNULL(@NumeroCitas,0) >= @Frecuencia) BEGIN

					   SET @sErrorValidacion = @sErrorValidacion + '*. No se puede ordenar el servicio ' + @NombreProcedimiento + ' debido a que ha excedido su frencuencia (' + CAST(@Frecuencia AS VARCHAR) + ' al ' + @UnidadFrecuencia +').' + CHAR(13)
				
				    END
						
				    --Actualizar registro  
				    UPDATE  @dtConfigFrec
				    SET Validado = 1
				    WHERE   IdProcedimiento = @IdProcedimiento
					 
				END
            		  
				--Mostrar error de validación
				IF (@sErrorValidacion <> '') BEGIN

				    RAISERROR(@sErrorValidacion,16,1)
				    RETURN

				END

			 END

			 SELECT @sCupoDisponible = (CASE WHEN Asignados < @iConcurrencia THEN '1' ELSE '0' END)
			 FROM (
			 
				SELECT COUNT(CM.Id) AS Asignados 
				FROM dbo.ConsultasMedicas CM WITH(NOLOCK)
				WHERE FechaAsignada   = @fFechaAsignada 
				    AND CM.Prestador = @sIdPrestador 
				    AND CM.Especialidad = @sIdEspecialidad 
				    AND ((Cancelada = 0) OR (Cancelada IS NULL)) 

			 )D
			
			 -- Si hay disponibilidad Insertarlas
			 IF (ISNULL(@sCupoDisponible,'')='' OR @sCupoDisponible='1') BEGIN
			 
				BEGIN TRANSACTION
				
				    EXEC [dbo].[paConsecutivoRetorno] @Modo = 'A',@Codigo = 'CITAS' , @devolver = 0,  @Retorno = @sConsecutivoCita OUTPUT
					 
				    INSERT INTO dbo.ConsultasMedicas (	Localidad, 
												    Codigo, 
												    Ciclo, 
												    Cantidad, 
												    MedioSolicitud, 
												    Programada, 
												    TipoCita, 
												    IdPaciente,
												    FechaSolicitada, 
												    FechaAsignada, 
												    Prestador,
												    Especialidad, 
												    Consultorio, 
												    idPlan,
												    TipoConsulta,
												    Autorizacion,
												    Adm,
												    Paciente, 
												    Observacion, 
												    IdTurno, 
												    idConsultorio,
												    FechaDeseada,
												    ClasificacionCita,
												    CodigoProgramaPyP
												    ,UsuarioRegistro
												    )

								 
				    VALUES (  
						  @sIdPuestoAtencion 
						  , @sConsecutivoCita 
						  , 1 
						  , 1 
						  , @sCodigoMedioSolicitud
						  , 1
						  , @sCodigoTipoCita
						  , @sIdentificacion 
						  , GETDATE()
						  , @fFechaAsignada 
						  , @sIdPrestador
						  , @sIdEspecialidad
						  , @sCodigoConsultorio
						  , @iIdPlan
						  , @sCodigoTipoConsulta
						  , '' 
						  , @sIdAdministradora
						  , @sIdPaciente 
						  , '' 
						  , @iIdTurnos 
						  , @sIdConsultorio
						  , @fFechaAsignada
						  , @iIdClasificacionCita
						  , NULL
						  , 'Api'
				    )

				    IF @@ROWCOUNT = 0 BEGIN
					   RAISERROR('Error no se guardo la asignación de la cita.',16,1)
				    END
				    ELSE BEGIN 

					   SET @iIdCita = SCOPE_IDENTITY()

					   INSERT INTO dbo.relConsMedProce(IdConsulta,IdProce) 	
					   SELECT @iIdCita, @sIdProcedimiento

					   --- ASIGNACION DEL PLAN AL PACIENTE SI NO LO TIENE
					   IF NOT EXISTS ( 
						  SELECT TOP 1 1 
						  FROM dbo.relPlanPaci WITH(NOLOCK) 
						  WHERE PlanAdm = @iIdPlan 
							 AND Paciente = @sIdPaciente
					   ) BEGIN

						    INSERT INTO dbo.relPlanPaci(PlanAdm,Paciente,Administradora) 
						    VALUES (@iIdPlan,@sIdPaciente,@sIdAdministradora)	
							
					   END

					   --20140529 rcorrea se agrega un top para colocar limite de datos que como objetico solo tomara el nombre del consultorio y que se buscara de forma decendente para optener siempre el último y evitar recorre tantos registros historicos
					   SELECT TOP 1 @sConsecutivoCita AS 'ConsecutivoCita'
						  , @iIdCita AS 'IdCita' 
						  , @sCodigoConsultorio + ' - ' + ISNULL(@sNombreConsultorio,'') AS 'Consultorio'
						  , CONVERT(VARCHAR(10), @fFechaAsignada, 103) + ' ' + CONVERT(VARCHAR(8), @fFechaAsignada, 108) AS 'FechaAsignada'

				    END
							
				    COMMIT TRANSACTION
			 
			    END 
			    ELSE BEGIN
				    RAISERROR('No hay cupo disponible en este horario por favor verifique',16,1)
			    END

		    END 
		    ELSE BEGIN
			    RAISERROR('El Paciente ya posee una cita asignada en la fecha seleccionada, por favor verifique.',16,1)
		    END

	   END TRY
	   BEGIN CATCH  
	   				
	   		WHILE @@TRANCOUNT > 0
	   		BEGIN
	   			ROLLBACK TRANSACTION;
	   		END
	   		
	   		SET @sError = ERROR_MESSAGE();
	   		RAISERROR(@sError,16,1);

	   END CATCH

    END
    ELSE IF @sAccion = 'ConsultarCita' BEGIN

	   SELECT TOP 1
		    CM.Id AS 'IdCita',
		    CONVERT(VARCHAR(10), FechaAsignada, 103) + ' ' + CONVERT(VARCHAR(8), FechaAsignada, 108) AS 'Fecha',
		    PA.Descrip AS 'Sede',
		    P.Nombre AS 'Prestador',
		    E.Descrip AS 'Especialidad',
		    ISNULL(Pro.Descrip,'') AS ProgramaPyP,
		    (
			 CASE
			    WHEN Cancelada = 1 THEN 'SI'
			    WHEN Cancelada = 0 OR
				    ISNULL(Cancelada, '') = '' THEN 'NO'
			 END
		    ) AS Cancelada,
		    (
			 CASE
			    WHEN Atendido = 1 THEN 'SI'
			    WHEN (Atendido = 0 OR
				    ISNULL(Atendido, '') = '') AND
				    GETDATE() < FechaAsignada THEN '-'
			    WHEN (Atendido = 0 OR
				    ISNULL(Atendido, '') = '') THEN 'NO'
			 END
		    ) AS Atendido,
		    (
			 CASE
			    WHEN Multado = 1 THEN 'SI'
			    WHEN (Multado = 0 OR
				    ISNULL(Multado, '') = '') AND
				    GETDATE() < FechaAsignada THEN '-'
			    WHEN (Multado = 0 OR
				    ISNULL(Multado, '') = '') THEN 'NO'
			 END
		    ) AS Multado,
		    CM.Autorizacion AS [Autorizacion],
		    ISNULL(CM.UsuarioRegistro,'') AS UsuarioRegistro,
		    ISNULL(CM.UsuarioCancelacion,'') AS UsuarioCancelacion
		    ,PR.Descrip AS 'Consulta'
	    FROM dbo.ConsultasMedicas CM WITH (NOLOCK)
		    INNER JOIN dbo.relConsMedProce RC WITH (NOLOCK) ON CM.Id = RC.IdConsulta
		    INNER JOIN dbo.Procedimientos PR WITH (NOLOCK) ON RC.IdProce = PR.IdProcedimientos
		    INNER JOIN dbo.Especialidades E WITH (NOLOCK) ON E.Codigo = CM.Especialidad
		    INNER JOIN dbo.Prestadores P WITH (NOLOCK) ON P.Identificacion = CM.Prestador
		    LEFT JOIN dbo.PuestoAtencion PA WITH (NOLOCK) ON PA.Codigo = CM.Localidad
		    LEFT JOIN dbo.Programas Pro WITH (NOLOCK) ON Pro.Codigo=CM.CodigoProgramaPyP
	    WHERE CM.Id = @iIdCita

    END
    ELSE IF @sAccion = 'ConsultarHistorial' BEGIN

	   SELECT
		    CM.Id AS 'IdCita',
		    CONVERT(VARCHAR(10), FechaAsignada, 103) + ' ' + CONVERT(VARCHAR(8), FechaAsignada, 108) AS 'Fecha',
		    PA.Descrip AS 'Sede',
		    P.Nombre AS 'Prestador',
		    E.Descrip AS 'Especialidad',
		    ISNULL(Pro.Descrip,'') AS ProgramaPyP,
		    (
			 CASE
			    WHEN Cancelada = 1 THEN 'SI'
			    WHEN Cancelada = 0 OR
				    ISNULL(Cancelada, '') = '' THEN 'NO'
			 END
		    ) AS Cancelada,
		    (
			 CASE
			    WHEN Atendido = 1 THEN 'SI'
			    WHEN (Atendido = 0 OR
				    ISNULL(Atendido, '') = '') AND
				    GETDATE() < FechaAsignada THEN '-'
			    WHEN (Atendido = 0 OR
				    ISNULL(Atendido, '') = '') THEN 'NO'
			 END
		    ) AS Atendido,
		    (
			 CASE
			    WHEN Multado = 1 THEN 'SI'
			    WHEN (Multado = 0 OR
				    ISNULL(Multado, '') = '') AND
				    GETDATE() < FechaAsignada THEN '-'
			    WHEN (Multado = 0 OR
				    ISNULL(Multado, '') = '') THEN 'NO'
			 END
		    ) AS Multado,
		    CM.Autorizacion AS [Autorizacion],
		    ISNULL(CM.UsuarioRegistro,'') AS UsuarioRegistro,
		    ISNULL(CM.UsuarioCancelacion,'') AS UsuarioCancelacion
	    FROM dbo.ConsultasMedicas CM WITH (NOLOCK)
		    INNER JOIN dbo.Especialidades E WITH (NOLOCK) ON E.Codigo = CM.Especialidad
		    INNER JOIN dbo.Prestadores P WITH (NOLOCK) ON P.Identificacion = CM.Prestador
		    LEFT JOIN dbo.PuestoAtencion PA WITH (NOLOCK) ON PA.Codigo = CM.Localidad
		    LEFT JOIN dbo.Programas Pro WITH (NOLOCK) ON Pro.Codigo=CM.CodigoProgramaPyP
	    WHERE CM.Paciente = @sIdPaciente
		  AND ((@bVigentes = 0) OR  ((@bVigentes = 1) AND (Cancelada = 0 OR Cancelada IS NULL) AND FechaAsignada > GETDATE()))
	    ORDER BY FechaAsignada DESC

    END
    ELSE IF @sAccion = 'Cancelar' BEGIN

	   SELECT TOP 1 @sCodigoMedioSolicitud = Codigo
	   FROM dbo.gVentanaSimPle WITH(NOLOCK)
	   WHERE VentanaId = 'MedSolitCitas' 
		AND Activo <> 0 
		AND ((Nombre LIKE '%Internet%') OR (Nombre LIKE '%web%'))

	   IF @sCodigoMedioSolicitud IS NULL BEGIN

	   	 INSERT INTO dbo.gVentanaSimPle (Nombre,Codigo,Tag, Activo,VentanaId)
	   	 VALUES('Internet','MS999',0,1,'MedSolitCitas')

	   	 SET @sCodigoMedioSolicitud = 'MS999';

	   END

	   SET @sCodigoMotivoCancelacionCita = 'MC01'

	   IF NOT EXISTS(SELECT TOP 1 1 FROM dbo.gVentanaSimPle WITH(NOLOCK)  WHERE Codigo = 'MC01' AND VentanaId like 'MotiCancCitas') BEGIN

		  INSERT INTO dbo.gVentanaSimPle (Nombre,Codigo,Tag, Activo,VentanaId)
		  VALUES('PACIENTE NO PUEDE ASISTIR','MC01',0,1,'MotiCancCitas')

	   END

	   SET @fFechaInicial = GETDATE();

	   EXEC[dbo].[paCancelacionCitas]
		@Id = @iIdCita,
		@Cancelada = 1,
		@FechaCancelacion = @fFechaInicial,
		@MotivoCancelacion = @sCodigoMotivoCancelacionCita,
		@ObservacionCancelacion = 'Cancelado por medio de la Api',
		@PersonaCancelacion = 'API',
		@MedioCancelacion = @sCodigoMedioSolicitud

	   IF @@ROWCOUNT > 0 BEGIN
		  SELECT 'OK' AS 'Resp'
	   END
	   ELSE BEGIN
		  RAISERROR('Error, No se elimino la cita.',16,1);
	   END

    END
    ELSE IF @sAccion = 'ValidarUltimaCitaIncumplida' BEGIN

	   SET @fFechaActual = GETDATE();
	   --Se obtiene la última cita del paciente  
	   SELECT TOP 1 @iIdCita = Id 
	   FROM dbo.ConsultasMedicas WITH(NOLOCK)
	   WHERE Paciente = @sIdPaciente
		  AND FechaAsignada < @fFechaActual
	   ORDER BY FechaAsignada DESC

	   IF @iIdCita IS NOT NULL BEGIN--//Si no se encuantran puese desr que el al paciente no se le ha asignado ninguna cita y si que el flujo normal

		  SELECT TOP 1
			 CM.Id AS 'IdCita',
			 CONVERT(VARCHAR(10), FechaAsignada, 103) + ' ' + CONVERT(VARCHAR(8), FechaAsignada, 108) AS 'Fecha',
			 PA.Descrip AS 'Sede',
			 P.Nombre AS 'Prestador',
			 E.Descrip AS 'Especialidad',
			 ISNULL(Pro.Descrip,'') AS ProgramaPyP,
			 (
				CASE
				   WHEN Cancelada = 1 THEN 'SI'
				   WHEN (Cancelada = 0 OR Cancelada IS NULL) THEN 'NO'
				END
			 ) AS Cancelada,
			 (
				CASE
				   WHEN Atendido = 1 THEN 'SI'
				   WHEN (Atendido = 0 OR Atendido IS NULL) THEN 'NO'
				END
			 ) AS Atendido,
			 (
				CASE
				   WHEN Multado = 1 THEN 'SI'
				   WHEN (Multado = 0 OR
					   ISNULL(Multado, '') = '') AND
					   GETDATE() < FechaAsignada THEN '-'
				   WHEN (Multado = 0 OR
					   ISNULL(Multado, '') = '') THEN 'NO'
				END
			 ) AS Multado,
			 CM.Autorizacion AS [Autorizacion],
			 ISNULL(CM.UsuarioRegistro,'') AS UsuarioRegistro,
			 ISNULL(CM.UsuarioCancelacion,'') AS UsuarioCancelacion
			 ,PR.Descrip AS 'Consulta'
		   FROM dbo.ConsultasMedicas CM WITH (NOLOCK)
			   INNER JOIN dbo.relConsMedProce RC WITH (NOLOCK) ON CM.Id = RC.IdConsulta
			   INNER JOIN dbo.Procedimientos PR WITH (NOLOCK) ON RC.IdProce = PR.IdProcedimientos
			   INNER JOIN dbo.Especialidades E WITH (NOLOCK) ON E.Codigo = CM.Especialidad
			   INNER JOIN dbo.Prestadores P WITH (NOLOCK) ON P.Identificacion = CM.Prestador
			   LEFT JOIN dbo.PuestoAtencion PA WITH (NOLOCK) ON PA.Codigo = CM.Localidad
			   LEFT JOIN dbo.Programas Pro WITH (NOLOCK) ON Pro.Codigo=CM.CodigoProgramaPyP
		   WHERE CM.Id = @iIdCita
			 AND ((CM.Cancelada IS NULL) OR (CM.Cancelada = 0))
			 AND ((CM.Atendido IS NULL) OR (CM.Atendido = 0))
	   
	   END

    END

END

