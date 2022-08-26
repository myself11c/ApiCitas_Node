CREATE PROCEDURE [usp_Test_SubApplications]
   @SubApplicationId VARCHAR(50) = NULL
AS
BEGIN

	SELECT * FROM aspnet_SubApplications WHERE (SubApplicationId =@SubApplicationId OR @SubApplicationId IS NULL)  ORDER BY Nombre
	
END