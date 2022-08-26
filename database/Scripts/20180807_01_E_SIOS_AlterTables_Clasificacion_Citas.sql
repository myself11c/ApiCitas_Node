

If NOT EXISTS (SELECT TOP 1 id FROM sysobjects WHERE id = object_id(N'[Administracion].[ClasificacionCitas]')  AND OBJECTPROPERTY(id, N'IsTable') = 1)
BEGIN 

    CREATE TABLE [Administracion].[ClasificacionCitas](
	    [IdClasificacionCita] [bigint] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	    [Codigo] [varchar](20) NOT NULL,
	    [Nombre] [varchar](100) NOT NULL,
	    [Descripcion] [varchar](200) NOT NULL,
	    [ColorFondo] [varchar](10) NOT NULL,
	    [Activo] [bit] NOT NULL
	) 

    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id de la clasificación de la cita' , @level0type=N'SCHEMA',@level0name=N'Administracion', @level1type=N'TABLE',@level1name=N'ClasificacionCitas', @level2type=N'COLUMN',@level2name=N'IdClasificacionCita'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de la clasificación de la cita' , @level0type=N'SCHEMA',@level0name=N'Administracion', @level1type=N'TABLE',@level1name=N'ClasificacionCitas', @level2type=N'COLUMN',@level2name=N'Codigo'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de clasificación de cita' , @level0type=N'SCHEMA',@level0name=N'Administracion', @level1type=N'TABLE',@level1name=N'ClasificacionCitas', @level2type=N'COLUMN',@level2name=N'Nombre'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción de clasificación de cita' , @level0type=N'SCHEMA',@level0name=N'Administracion', @level1type=N'TABLE',@level1name=N'ClasificacionCitas', @level2type=N'COLUMN',@level2name=N'Descripcion'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Color para identificar clasificación de cita' , @level0type=N'SCHEMA',@level0name=N'Administracion', @level1type=N'TABLE',@level1name=N'ClasificacionCitas', @level2type=N'COLUMN',@level2name=N'ColorFondo'
    EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado de clasificación de cita' , @level0type=N'SCHEMA',@level0name=N'Administracion', @level1type=N'TABLE',@level1name=N'ClasificacionCitas', @level2type=N'COLUMN',@level2name=N'Activo'

END
GO

If NOT EXISTS (SELECT TOP 1 id FROM sysobjects WHERE id = object_id(N'[Administracion].[ProceClasificacionCitas]')  AND OBJECTPROPERTY(id, N'IsTable') = 1)
BEGIN 

    CREATE TABLE [Administracion].[ProceClasificacionCitas](
	[IdProceClasificacionCita] [bigint] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[IdClasificacionCita] [bigint] NOT NULL,
	[IdProcedimiento] [nvarchar](6) NOT NULL 
	)

    ALTER TABLE [Administracion].[ProceClasificacionCitas]  WITH NOCHECK ADD FOREIGN KEY([IdClasificacionCita])
    REFERENCES [Administracion].[ClasificacionCitas] ([IdClasificacionCita])

    ALTER TABLE [Administracion].[ProceClasificacionCitas]  WITH NOCHECK ADD FOREIGN KEY([IdProcedimiento])
    REFERENCES [dbo].[Procedimientos] ([IdProcedimientos])

	   EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id de la relación de la clasificación de cita con el procedimiento' , @level0type=N'SCHEMA',@level0name=N'Administracion', @level1type=N'TABLE',@level1name=N'ProceClasificacionCitas', @level2type=N'COLUMN',@level2name=N'IdProceClasificacionCita'

	   EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id de la clasificación de cita' , @level0type=N'SCHEMA',@level0name=N'Administracion', @level1type=N'TABLE',@level1name=N'ProceClasificacionCitas', @level2type=N'COLUMN',@level2name=N'IdClasificacionCita'

	   EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id del procedimiento' , @level0type=N'SCHEMA',@level0name=N'Administracion', @level1type=N'TABLE',@level1name=N'ProceClasificacionCitas', @level2type=N'COLUMN',@level2name=N'IdProcedimiento'

END 

--SELECT * FROM [Administracion].[ClasificacionCitas]
--SELECT * FROM [Administracion].[ProceClasificacionCitas]
--DROP TABLE [Administracion].[ProceClasificacionCitas]
--DROP TABLE [Administracion].[ClasificacionCitas]
--ALTER TABLE [dbo].[TurnosPrestadores] DROP COLUMN ClasificacionCita
--ALTER TABLE [dbo].[ConsultasMedicas] DROP COLUMN ClasificacionCita
--ALTER TABLE [dbo].[ConsultasMedicas] DROP COLUMN FechaDeseada

ALTER TABLE [dbo].[TurnosPrestadores]
ADD ClasificacionCita BIGINT
GO

ALTER TABLE [dbo].[ConsultasMedicas]
ADD FechaDeseada DATETIME
GO

ALTER TABLE [dbo].[ConsultasMedicas]
ADD ClasificacionCita BIGINT
GO

ALTER TABLE [dbo].[TurnosPrestadores]  WITH NOCHECK ADD CONSTRAINT [FK_TurnosPrestadores_ClasificacionCitas] FOREIGN KEY(ClasificacionCita)
REFERENCES [Administracion].[ClasificacionCitas] ([IdClasificacionCita])
GO
ALTER TABLE [dbo].[ConsultasMedicas]  WITH NOCHECK ADD CONSTRAINT [FK_ConsultasMedicas_ClasificacionCitas] FOREIGN KEY(ClasificacionCita)
REFERENCES [Administracion].[ClasificacionCitas] ([IdClasificacionCita])
GO


