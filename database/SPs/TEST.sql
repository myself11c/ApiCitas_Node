EXEC [ApiCitas].[usp_GestionCitas]

	@sAccion = 'Cancelar'
	
	,@iIdCita  = 5811

EXEC [ApiCitas].[usp_GestionCitas]

	@sAccion = 'ConsultarCita'
	
	,@iIdCita  = 5811


EXEC [ApiCitas].[usp_GestionCitas]
	 @sAccion			= 'Insertar' 
	,@sIdPaciente		= '10002'	
	,@sIdAdministradora = '3831'
	,@iIdTurnos			= 12917
	,@sFechaCita		= '20180810 08:30' 
	,@sRegimen			= 'C' 
	,@bCitaEspecializada = 1

SELECT * FROM [dbo].[TurnosPrestadores] AS TP where id = 12917
SELECT * FROM [dbo].admConfiguracion AS TP where Codigo = 'EspeciConsulAPiCita'
SELECT * FROM [dbo].Procedimientos WHERE CodProce = '890201'

SELECT TOP 1 A.VlrXml
		FROM [dbo].[admConfiguracion] A WITH(NOLOCK) 
		WHERE Codigo = 'PlanDefAPiCita'  