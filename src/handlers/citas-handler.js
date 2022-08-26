var config = require('../../config');
//Cliente Sql server
const sql = require('mssql')
//Async method
const co = require('co');

var sql_server = require('../helpers/sql-server.js');

var citas = {
    
    buscarporid: function (request, reply) {
        try {
            var Param_IdCita = { name: "iIdCita", value: request.params.id, type: "sql.Varchar", direction: "input" };
            var Param_Accion = { name: "sAccion", value: "ConsultarCita", type: "sql.Varchar", direction: "input" };

            var params = [Param_IdCita, Param_Accion];

            sql_server.storedProcedure("ApiCitas.usp_GestionCitas", params, function (err, data) {
                let Response = {};
                
                if (typeof err == "undefined" || err == null) {
                    if(data.recordset.length>0){
                        Response.Cita = data.recordset[0];
                        Response.Error = false;
                        Response.Estado = 200;
                        Response.Mensaje = "La cita existe.";
                    }
                    else{
                        Response.Cita = null;
                        Response.Error = true;
                        Response.Estado = 404;
                        Response.Mensaje = "La cita no existe.";
                    }
                }else {
                    Response.Cita = null;
                    Response.Error = true;
                    Response.Estado = 500;
                    Response.Mensaje = err.originalError.message;
                }

                return reply(Response).code(Response.Estado);
            });
        } 
        catch (e) {
            console.error('Error en citas-buscarporid handler:', e);
            return reply(e).code(500);
        }
    },

    validarultimacitaincumplida: function (request, reply) {
        try {
            var Param_IdPaciente = { name: "sIdPaciente", value: request.params.id, type: "sql.Varchar", direction: "input" };
            var Param_Accion = { name: "sAccion", value: "ValidarUltimaCitaIncumplida", type: "sql.Varchar", direction: "input" };

            var params = [Param_IdPaciente, Param_Accion];

            sql_server.storedProcedure("ApiCitas.usp_GestionCitas", params, function (err, data) {
                let Response = {};
                
                if (typeof err == "undefined" || err == null) {
                    if(data.recordset.length>0){
                        Response.Cita = data.recordset[0];
                        Response.Error = false;
                        Response.Estado = 200;
                        Response.Mensaje = "Tiene citas incumplidas.";
                    }
                    else{
                        Response.Cita = null;
                        Response.Error = true;
                        Response.Estado = 404;
                        Response.Mensaje = "No tiene citas incumplidas.";
                    }
                }else {
                    Response.Cita = null;
                    Response.Error = true;
                    Response.Estado = 500;
                    Response.Mensaje = err.originalError.message;
                }

                return reply(Response).code(Response.Estado);
            });
        } 
        catch (e) {
            console.error('Error en citas-buscarporid handler:', e);
            return reply(e).code(500);
        }
    },

    historial: function (request, reply) {
        try {
            var Param_IdPaciente = { name: "sIdPaciente", value: request.payload.sIdPaciente, type: "sql.Varchar", direction: "input" };
            var Param_Vigentes = { name: "bVigentes", value: request.payload.bVigente, type: "sql.Bit", direction: "input" };
            var Param_Accion = { name: "sAccion", value: "ConsultarHistorial", type: "sql.Varchar", direction: "input" };

            var params = [Param_IdPaciente, Param_Vigentes, Param_Accion];

            sql_server.storedProcedure("ApiCitas.usp_GestionCitas", params,  function (err, data) {
                let Response = {};
                
                if (typeof err == "undefined" || err == null) {
                    if(data.recordset != null && data.recordset.length>0){
                        Response.ListaCitas = data.recordset;
                        Response.Error = false;
                        Response.Estado = 200;
                        Response.Mensaje = "El paciente tiene citas.";
                    }
                    else{
                        Response.ListaCitas = null;
                        Response.Error = true;
                        Response.Estado = 404;
                        Response.Mensaje = "El paciente no tiene citas.";
                    }
                }else {
                    Response.ListaCitas = null;
                    Response.Error = true;
                    Response.Estado = 500;
                    Response.Mensaje = err.originalError.message;
                }

                return reply(Response).code(200);
            });
        } 
        catch (e) {
            console.error('Error en sedes-listar handler:', e);
            return reply(e).code(500);
        }
    },

    cancelar: function (request, reply) {
        try {
            var Param_IdCita= { name: "iIdCita", value: request.payload.iIdCita, type: "sql.Int", direction: "input" };
            var Param_Accion = { name: "sAccion", value: "Cancelar", type: "sql.Varchar", direction: "input" };

            var params = [Param_IdCita, Param_Accion];

            sql_server.storedProcedure("ApiCitas.usp_GestionCitas", params,  function (err, data) {
                let Response = {};
                
                if (typeof err == "undefined" || err == null) {
                    Response.ListaCitas = null;
                    Response.Error = false;
                    Response.Estado = 200;
                    Response.Mensaje = "Se ha cancelado la cita correctamente.";
                   
                }else {
                    Response.ListaCitas = null;
                    Response.Error = true;
                    Response.Estado = 500;
                    Response.Mensaje = err.originalError.message;
                }

                return reply(Response).code(Response.Estado);
            });
        } 
        catch (e) {
            console.error('Error en sedes-listar handler:', e);
            return reply(e).code(500);
        }
    },

    insertar: function (request, reply) {
        try {
            var Param_IdPaciente = { name: "sIdPaciente", value: request.payload.sIdPaciente, type: "sql.Varchar", direction: "input" };
            var Param_IdAdministradora = { name: "sIdAdministradora", value: request.payload.sIdAdministradora, type: "sql.Varchar", direction: "input" };
            var Param_IdTurnos= { name: "iIdTurnos", value: request.payload.iIdTurnos, type: "sql.Int", direction: "input" };
            var Param_FechaCita = { name: "sFechaCita", value: request.payload.sFechaCita, type: "sql.Varchar", direction: "input" };
            var Param_Regimen = { name: "sRegimen", value: request.payload.sRegimen, type: "sql.Varchar", direction: "input" };
            var Param_CitaEspecializada = { name: "bCitaEspecializada", value: request.payload.bCitaEspecializada, type: "sql.Bit", direction: "input" };
            var Param_TipoAtencion = { name: "sTipoAtencion", value: request.payload.sTipoAtencion, type: "sql.Varchar", direction: "input" };
            var Param_Accion = { name: "sAccion", value: "Insertar", type: "sql.Varchar", direction: "input" };

            var params = [Param_IdPaciente, Param_IdAdministradora, Param_IdTurnos, Param_FechaCita, Param_Regimen, Param_CitaEspecializada, 
                Param_TipoAtencion, Param_Accion];

            sql_server.storedProcedure("ApiCitas.usp_GestionCitas", params,  function (err, data) {
                let Response = {};
                
                if (typeof err == "undefined" || err == null) {
                    if(data.recordset.length>0){
                        Response.Cita = data.recordset[0];
                        Response.Error = false;
                        Response.Estado = 200;
                        Response.Mensaje = "Se ha guardado la cita correctamente.";
                    }
                    else{
                        Response.Cita = null;
                        Response.Error = true;
                        Response.Estado = 500;
                        Response.Mensaje = "Hubo un error al guardar la cita.";
                    }
                }else {
                    Response.Cita = null;
                    Response.Error = true;
                    Response.Estado = 500;
                    Response.Mensaje = err.originalError.message;
                }

                return reply(Response).code(Response.Estado);
            });
        } 
        catch (e) {
            console.error('Error en sedes-listar handler:', e);
            return reply(e).code(500);
        }
    }

};

module.exports = citas;
