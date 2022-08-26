var config = require('../../config');
//Cliente Sql server
const sql = require('mssql')
//Async method
const co = require('co');

var sql_server = require('../helpers/sql-server.js');

var pacientes = {
    
    buscarporid: function (request, reply) {
        try {
            
            var Param_Accion = { name: "sAccion", value: "BuscarDatosPacienteId", type: "sql.Varchar", direction: "input" };
            var Param_IdPaciente = { name: "sIdPaciente", value: request.params.id, type: "sql.Varchar", direction: "input" };
            
            var params = [Param_IdPaciente, Param_Accion];

            sql_server.storedProcedure("ApiCitas.usp_GestionPacientes", params, function (err, data) {
                let Response = {};
                
                if (typeof err == "undefined" || err == null) {
                    if(data.recordset.length>0){
                        Response.Paciente = data.recordset[0];
                        Response.Error = false;
                        Response.Estado = 200;
                        Response.Mensaje = "El paciente existe.";
                    }
                    else{
                        Response.Paciente = null;
                        Response.Error = true;
                        Response.Estado = 404;
                        Response.Mensaje = "El paciente no existe.";
                    }
                }else {
                    Response.Paciente= null;
                    Response.Error = true;
                    Response.Estado = 500;
                    Response.Mensaje = err.originalError.message;
                }

                return reply(Response).code(Response.Estado);
            });
        } 
        catch (e) {
            console.error('Error en pacientes-buscarporid handler:', e);
            return reply(e).code(500);
        }
    },

    buscar: function (request, reply) {
        try {

            var Param_NumeroIdentificacion = { name: "sNumeroIdentificacion", value: request.payload.sNumeroIdentificacion, type: "sql.Varchar", direction: "input" };
            var Param_TipoIdentificacion = { name: "sTipoIdentificacion", value: request.payload.sTipoIdentificacion, type: "sql.Varchar", direction: "input" };
            var Param_Accion = { name: "sAccion", value: "BuscarDatosPaciente", type: "sql.Varchar", direction: "input" };

            var params = [Param_NumeroIdentificacion, Param_TipoIdentificacion, Param_Accion];

            sql_server.storedProcedure("ApiCitas.usp_GestionPacientes", params, function (err, data) {
                let Response = {};
                
                if (typeof err == "undefined" || err == null) {
                    if(data.recordset.length>0){
                        Response.Paciente = data.recordset[0];
                        Response.Error = false;
                        Response.Estado = 200;
                        Response.Mensaje = "El paciente existe.";
                    }
                    else{
                        Response.Paciente = null;
                        Response.Error = true;
                        Response.Estado = 404;
                        Response.Mensaje = "El paciente no existe.";
                    }
                }else {
                    Response.Paciente= null;
                    Response.Error = true;
                    Response.Estado = 500;
                    Response.Mensaje = err.originalError.message;
                }

                return reply(Response).code(Response.Estado);
            });
        } 
        catch (e) {
            console.error('Error en pacientes-buscar handler:', e);
            return reply(e).code(500);
        }
    },

    validar: function (request, reply) {
        try {
            
            var Param_NumeroIdentificacion = { name: "sNumeroIdentificacion", value: request.payload.sNumeroIdentificacion, type: "sql.Varchar", direction: "input" };
            var Param_TipoIdentificacion = { name: "sTipoIdentificacion", value: request.payload.sTipoIdentificacion, type: "sql.Varchar", direction: "input" };
            var Param_Accion = { name: "sAccion", value: "ValidarPaciente", type: "sql.Varchar", direction: "input" };

            var params = [Param_NumeroIdentificacion, Param_TipoIdentificacion, Param_Accion];
           
            sql_server.storedProcedure("ApiCitas.usp_GestionPacientes", params, function (err, data) {
                let Response = {};
                
                if (typeof err == "undefined" || err == null) {
                    if(data.recordset.length>0){
                        Response.Paciente = data.recordset[0];
                        Response.Error = false;
                        Response.Estado = 200;
                        Response.Mensaje = "El paciente existe.";
                    }
                    else{
                        Response.Paciente = null;
                        Response.Error = true;
                        Response.Estado = 404;
                        Response.Mensaje = "El paciente no existe.";
                    }
                }else {
                    Response.Paciente= null;
                    Response.Error = true;
                    Response.Estado = 500;
                    Response.Mensaje = err.originalError.message;
                }

                return reply(Response).code(Response.Estado);
            });
        } 
        catch (e) {
            console.error('Error en pacientes-buscar handler:', e);
            return reply(e).code(500);
        }
        
    },

    insertar: function (request, reply) {
        try {

            var Param_TipoIdentificacion = { name: "sTipoIdentificacion", value: request.payload.sTipoIdentificacion, type: "sql.Varchar", direction: "input" };
            var Param_NumeroIdentificacion = { name: "sNumeroIdentificacion", value: request.payload.sNumeroIdentificacion, type: "sql.Varchar", direction: "input" };
            var Param_PrimerNombre = { name: "sPrimerNombre", value: request.payload.sPrimerNombre, type: "sql.Varchar", direction: "input" };
            var Param_SegundoNombre = { name: "sSegundoNombre", value: request.payload.sSegundoNombre, type: "sql.Varchar", direction: "input" };
            var Param_PrimerApellido = { name: "sPrimerApellido", value: request.payload.sPrimerApellido, type: "sql.Varchar", direction: "input" };
            var Param_SegundoApellido = { name: "sSegundoApellido", value: request.payload.sSegundoApellido, type: "sql.Varchar", direction: "input" };
            var Param_FechaNacimiento = { name: "sFechaNacimiento", value: request.payload.sFechaNacimiento, type: "sql.Varchar", direction: "input" };
            var Param_Direccion = { name: "sDireccion", value: request.payload.sDireccion, type: "sql.Varchar", direction: "input" };
            var Param_TelefonoResidencia = { name: "sTelefonoResidencia", value: request.payload.sTelefonoResidencia, type: "sql.Varchar", direction: "input" };
            var Param_Correo = { name: "sCorreo", value: request.payload.sCorreo, type: "sql.Varchar", direction: "input" };
            var Param_TelefonoCelular = { name: "sTelefonoCelular", value: request.payload.sTelefonoCelular, type: "sql.Varchar", direction: "input" };
            var Param_Sexo = { name: "sSexo", value: request.payload.sSexo, type: "sql.Varchar", direction: "input" };
            var Param_Accion = { name: "sAccion", value: "Insertar", type: "sql.Varchar", direction: "input" };

            var params = [Param_NumeroIdentificacion, Param_TipoIdentificacion, Param_PrimerNombre, Param_SegundoNombre, Param_PrimerApellido, Param_SegundoApellido,
                Param_FechaNacimiento, Param_Direccion, Param_TelefonoResidencia, Param_Correo, Param_TelefonoCelular, Param_Sexo, Param_Accion];

            sql_server.storedProcedure("ApiCitas.usp_GestionPacientes", params, function (err, data) {
                let Response = {};
                
                if (typeof err == "undefined" || err == null) {
                    if(data.recordset.length>0){
                        Response.Paciente = data.recordset[0];
                        Response.Error = false;
                        Response.Estado = 200;
                        Response.Mensaje = "Se ha guardado el paciente correctamente.";
                    }
                    else{
                        Response.Paciente = null;
                        Response.Error = true;
                        Response.Estado = 500;
                        Response.Mensaje = "Ha ocurrido un error al guardar el paciente.";
                    }
                }else {
                    Response.Paciente= null;
                    Response.Error = true;
                    Response.Estado = 500;
                    Response.Mensaje = err.originalError.message;
                }

                return reply(Response).code(Response.Estado);
            });
        } 
        catch (e) {
            console.error('Error en pacientes-buscar handler:', e);
            return reply(e).code(500);
        }
        
    },

    actualizar: function (request, reply) {
        try {
            console.log(request.payload);
            var Param_TipoIdentificacion = { name: "sTipoIdentificacion", value: request.payload.sTipoIdentificacion, type: "sql.Varchar", direction: "input" };
            var Param_NumeroIdentificacion = { name: "sNumeroIdentificacion", value: request.payload.sNumeroIdentificacion, type: "sql.Varchar", direction: "input" };
            var Param_PrimerNombre = { name: "sPrimerNombre", value: request.payload.sPrimerNombre, type: "sql.Varchar", direction: "input" };
            var Param_SegundoNombre = { name: "sSegundoNombre", value: request.payload.sSegundoNombre, type: "sql.Varchar", direction: "input" };
            var Param_PrimerApellido = { name: "sPrimerApellido", value: request.payload.sPrimerApellido, type: "sql.Varchar", direction: "input" };
            var Param_SegundoApellido = { name: "sSegundoApellido", value: request.payload.sSegundoApellido, type: "sql.Varchar", direction: "input" };
            var Param_FechaNacimiento = { name: "sFechaNacimiento", value: request.payload.sFechaNacimiento, type: "sql.Varchar", direction: "input" };
            var Param_Direccion = { name: "sDireccion", value: request.payload.sDireccion, type: "sql.Varchar", direction: "input" };
            var Param_TelefonoResidencia = { name: "sTelefonoResidencia", value: request.payload.sTelefonoResidencia, type: "sql.Varchar", direction: "input" };
            var Param_Correo = { name: "sCorreo", value: request.payload.sCorreo, type: "sql.Varchar", direction: "input" };
            var Param_TelefonoCelular = { name: "sTelefonoCelular", value: request.payload.sTelefonoCelular, type: "sql.Varchar", direction: "input" };
            var Param_Sexo = { name: "sSexo", value: request.payload.sSexo, type: "sql.Varchar", direction: "input" };
            var Param_Accion = { name: "sAccion", value: "Actualizar", type: "sql.Varchar", direction: "input" };
            var Param_IdPaciente = { name: "sIdPaciente", value: request.payload.iIdPaciente, type: "sql.Varchar", direction: "input" };

            var params = [Param_NumeroIdentificacion, Param_TipoIdentificacion, Param_PrimerNombre, Param_SegundoNombre, Param_PrimerApellido, Param_SegundoApellido,
                Param_FechaNacimiento, Param_Direccion, Param_TelefonoResidencia, Param_Correo, Param_TelefonoCelular, Param_Sexo, Param_Accion, Param_IdPaciente];

            sql_server.storedProcedure("ApiCitas.usp_GestionPacientes", params, function (err, data) {
                let Response = {};
                
                if (typeof err == "undefined" || err == null) {
                    Response.Paciente = data.recordset[0];
                    Response.Error = false;
                    Response.Estado = 200;
                    Response.Mensaje = "Se ha actualizado el paciente correctamente.";
                }else {
                    Response.Paciente= null;
                    Response.Error = true;
                    Response.Estado = 500;
                    Response.Mensaje = err.originalError.message;
                }

                return reply(Response).code(Response.Estado);
            });
        } 
        catch (e) {
            console.error('Error en pacientes-buscar handler:', e);
            return reply(e).code(500);
        }
        
    }
};

module.exports = pacientes;
