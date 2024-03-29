IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[ApiCitas].[GestionPacientes]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [ApiCitas].[GestionPacientes]
GO

IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[ApiCitas].[usp_GestionPacientes]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [ApiCitas].[usp_GestionPacientes]
GO

CREATE PROCEDURE [ApiCitas].[usp_GestionPacientes](
     @sAccion				VARCHAR(50)
    ,@sTipoIdentificacion     VARCHAR(5)    = NULL
    ,@sNumeroIdentificacion   VARCHAR(20)   = NULL
    ,@sPrimerNombre			VARCHAR(50)   = NULL
    ,@sSegundoNombre		VARCHAR(50)   = NULL
    ,@sPrimerApellido		VARCHAR(50)   = NULL
    ,@sSegundoApellido		VARCHAR(50)   = NULL
    ,@sFechaNacimiento		VARCHAR(10)   = NULL
    ,@sDireccion			VARCHAR(80)   = NULL
    ,@sTelefonoResidencia	VARCHAR(20)   = NULL
    ,@sCorreo				VARCHAR(20)   = NULL
    ,@sTelefonoCelular		VARCHAR(20)   = NULL
    ,@sIdPaciente			VARCHAR(8)    = NULL
    ,@sSexo				VARCHAR(1)    = NULL

)
AS BEGIN 

    /*
		----------------------------------------------------------------------------
		Nombre:			[ApiCitas].[usp_GestionPacientes]
		----------------------------------------------------------------------------
		Tipo:			Procedimiento almacenado
		creación:		     2018 JUL 09
		Desarrollador:		Victor Alfonso Cardona Hernandez
		Proposito:		Crud de pacientes
		Parámetros:		@sAccion				 --> Indica el bloque del SP que se ejecutara
						,@sTipoIdentificacion	 --> Tipo de identificacion del paciente
						,@sNumeroIdentificacion   --> Número de identificacion del paciente
						,@sPrimerNombre		 --> Primer nombre del paciente	  
						,@sSegundoNombre		 --> Segundo nombre del paciente
						,@sPrimerApellido		 --> Primer apellido del paciente
						,@sSegundoApellido		 --> Primer apellido del paciente
						,@sFechaNacimiento		 --> Fecha de nacimento la cadena debe ser con formato 120 -- YYYY-MM-DD
						,@sDireccion			 --> Dirección del paciente
						,@sTelefonoResidencia	 --> Número del teléfono de residencia del paciente
						,@sCorreo				 --> Dirección del correo electronico del paciente
						,@sTelefonoCelular		 --> Número del teléfono celular del paciente
						,@sIdPaciente			 --> Id consecutivo del paciente
						,@sSexo				 --> Sexo del paciente
		----------------------------------------------------------------------------
		-- Salidas:
		----------------------------------------------------------------------------
			Según el parametro @sAccion:

			 --ValidarPaciente		--> Id del pacinente indicando que este existe en la bd
			 --BuscarDatosPaciente	--> Datos del paciente siempre ycuando los datos ingresados sean correctos
			 --BuscarDatosPacienteId	--> Datos del paciente siempre ycuando los datos ingresados sean correctos
			 --Insertar			--> El id del nuevo paciente

		----------------------------------------------------------------------------
		-- Modificaciones
		----------------------------------------------------------------------------
	-- Pruebas y Ejemplos
*/ 
 

    DECLARE @sError VARCHAR(MAX)
    DECLARE @fFechaNacimiento DATE 

    BEGIN TRY

	   IF @sAccion = 'ValidarPaciente' BEGIN

		  SELECT TOP 1 
		  'Pacientes'						AS 'table_name',
		  Id AS 'IdPaciente'
		  FROM dbo.Pacientes WITH(NOLOCK)
		  WHERE Identificacion = @sNumeroIdentificacion
			 AND TipoID = @sTipoIdentificacion
	   
	   END -- FIN ELSE IF @sAccion = 'ValidarPaciente' BEGIN

	   ELSE IF @sAccion = 'BuscarDatosPaciente' BEGIN

		  SELECT TOP 1 
			'Pacientes'						AS 'table_name',
			 Id								 AS 'IdPaciente'
			 ,Nom1Afil						 AS 'PrimerNombre'
			 ,Nom2Afil						 AS 'SegundoNombre'
			 ,Ape1Afil						 AS 'PrimerApellido'
			 ,Ape2Afil						 AS 'SegundoApellido'  
			 ,DirAfil							 AS 'Direccion'
			 ,TelRes							 AS 'TelefonoResidencia'
			 ,CONVERT(VARCHAR(10), FechaNac, 120)	 AS 'FechaNacimiento'
			 ,TipoID							 AS 'TipoIdentificacion'
			 ,Identificacion					 AS 'NumeroIdentificacion'
			 ,TelCel							 AS 'TelefonoCelular'
			 ,Email							 AS 'Correo'
			 ,Sexo							 AS 'Sexo'
		  FROM dbo.Pacientes WITH(NOLOCK)
		  WHERE Identificacion = @sNumeroIdentificacion 
			 AND TipoID = @sTipoIdentificacion

	   END -- FIN ELSE IF @sAccion = 'BuscarDatosPaciente' BEGIN

	   ELSE IF @sAccion = 'BuscarDatosPacienteId' BEGIN

		  SELECT TOP 1 
			'Pacientes'						AS 'table_name'
			 ,Id								 AS 'IdPaciente'
			 ,Nom1Afil						 AS 'PrimerNombre'
			 ,Nom2Afil						 AS 'SegundoNombre'
			 ,Ape1Afil						 AS 'PrimerApellido'
			 ,Ape2Afil						 AS 'SegundoApellido'  
			 ,DirAfil							 AS 'Direccion'
			 ,TelRes							 AS 'TelefonoResidencia'
			 ,CONVERT(VARCHAR(10), FechaNac, 120)	 AS 'FechaNacimiento'
			 ,TipoID							 AS 'TipoIdentificacion'
			 ,Identificacion					 AS 'NumeroIdentificacion'
			 ,TelCel							 AS 'TelefonoCelular'
			 ,Email							 AS 'Correo'
			 ,Sexo							 AS 'Sexo'
		  FROM dbo.Pacientes WITH(NOLOCK)
		  WHERE Id = @sIdPaciente

	   END -- FIN ELSE IF @sAccion = 'BuscarDatosPacienteId' BEGIN

	   ELSE IF @sAccion = 'Insertar' BEGIN

		  IF EXISTS(
		  
			 SELECT TOP 1 Id AS 'IdPaciente'
			 FROM dbo.Pacientes WITH(NOLOCK)
			 WHERE Identificacion = @sNumeroIdentificacion
				AND TipoID = @sTipoIdentificacion
		  
		  ) BEGIN

			 RAISERROR('Ya existe un paciente con el número y tipo de identificación ingresados, por favor verifique.',16,1);
			 RETURN
		  END
	    
		  SET @fFechaNacimiento = CONVERT(DATE, @sFechaNacimiento, 120);

		  SELECT @sIdPaciente = MAX(CAST(Id AS BIGINT)) + 1 FROM dbo.Pacientes WITH(NOLOCK)

		  INSERT INTO dbo.Pacientes 
			 (
				Nom1Afil						
				,Nom2Afil						
				,Ape1Afil						
				,Ape2Afil						
				,DirAfil						
				,TelRes							
				,FechaNac	
				,TipoID							
				,Identificacion					
				,TelCel							
				,Email							
				,Id			
				,Activo	
				,Sexo		
			 )
		  VALUES
			 (
				@sPrimerNombre	
				,@sSegundoNombre	
				,@sPrimerApellido	
				,@sSegundoApellido
				,@sDireccion
				,@sTelefonoResidencia
				,@fFechaNacimiento
				,@sTipoIdentificacion
				,@sNumeroIdentificacion
				,@sTelefonoCelular
				,@sCorreo
				,@sIdPaciente
				, 1
				,@sSexo
			 )

		  IF @@ROWCOUNT > 0 BEGIN

			 SELECT 'Pacientes' AS 'table_name',
					@sIdPaciente AS 'IdPaciente'

		  END
		  ELSE BEGIN

			 RAISERROR('No se guardó el paciente.',16,1);
		  
		  END

	   END -- FIN ELSE IF @sAccion = 'Insertar' BEGIN

	   ELSE IF @sAccion = 'Actualizar' BEGIN
		  
			UPDATE dbo.Pacientes  
			SET Nom1Afil		 = ISNULL(@sPrimerNombre , Nom1Afil)	
				,Nom2Afil		 = ISNULL(@sSegundoNombre , Nom2Afil)	
				,Ape1Afil		 = ISNULL(@sPrimerApellido , Ape1Afil)	
				,Ape2Afil		 = ISNULL(@sSegundoApellido , Ape2Afil)
				,DirAfil		 = ISNULL(@sDireccion , DirAfil)
				,TelRes		 = ISNULL(@sTelefonoResidencia , TelRes)
				,FechaNac		 = ISNULL(@fFechaNacimiento , FechaNac)
				,TelCel		 = ISNULL(@sTelefonoCelular , TelCel)
				,Email		 = ISNULL(@sCorreo , Email)
				,TipoID		 = ISNULL(@sTipoIdentificacion , TipoID)
				,Identificacion = ISNULL(@sNumeroIdentificacion , Identificacion)
				,Sexo		 = ISNULL(@sSexo , Sexo)
			WHERE Id = @sIdPaciente OR (Identificacion = @sNumeroIdentificacion AND TipoID = @sTipoIdentificacion)
		  
		  IF @@ROWCOUNT > 0 BEGIN

			 SELECT 'Pacientes' AS 'table_name', 'Actualización exitosa.' AS 'Resp'

		  END
		  ELSE BEGIN

			 RAISERROR('No se actualizó el paciente.',16,1);
		  
		  END
		   
	   END -- FIN ELSE IF @sAccion = 'Actualizar' BEGIN

	   --ELSE IF @sAccion = 'ActualizarId' BEGIN

		  --UPDATE dbo.Pacientes  
		  --SET Nom1Afil		  = ISNULL(@sPrimerNombre , Nom1Afil)	
			 --,Nom2Afil	  = ISNULL(@sSegundoNombre , Nom2Afil)	
			 --,Ape1Afil	  = ISNULL(@sPrimerApellido , Ape1Afil)	
			 --,Ape2Afil	  = ISNULL(@sSegundoApellido , Ape2Afil)
			 --,DirAfil		  = ISNULL(@sDireccion , DirAfil)
			 --,TelRes		  = ISNULL(@sTelefonoResidencia , TelRes)
			 --,FechaNac	  = ISNULL(@fFechaNacimiento , FechaNac)
			 --,TelCel		  = ISNULL(@sTelefonoCelular , TelCel)
			 --,Email		  = ISNULL(@sCorreo , Email)
			 --,TipoID		  = ISNULL(@sTipoIdentificacion , TipoID)
			 --,Identificacion = ISNULL(@sNumeroIdentificacion , Identificacion)
		  --WHERE Id = @sIdPaciente

		  --IF @@ROWCOUNT > 0 BEGIN

			 --SELECT 'Pacientes' AS 'table_name', 'Actualización exitosa.' AS 'Resp'

		  --END
		  --ELSE BEGIN

			 --RAISERROR('No se actualizó el paciente.',16,1);
		  
		  --END

	   --END -- FIN ELSE IF @sAccion = 'Actualizar' BEGIN

    END TRY
    BEGIN CATCH  
		
		SET @sError = ERROR_MESSAGE();
		RAISERROR(@sError,16,1);

    END CATCH

END