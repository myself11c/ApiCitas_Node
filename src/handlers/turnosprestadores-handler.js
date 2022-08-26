var config = require('../../config');
//Cliente Sql server
const sql = require('mssql')
//Async method
const co = require('co');

var sql_server = require('../helpers/sql-server.js');

var turnosprestadores = {
    
    buscarporespecialidad: function (request, reply) {
        try {
            var Param_CodigoEspecialidad = { name: "sCodigoEspecialidad", value: request.payload.sCodigoEspecialidad, type: "sql.Varchar", direction: "input" };
            var Param_IdSede = { name: "sIdSede", value: request.payload.sIdSede, type: "sql.Varchar", direction: "input" };
            var Param_IdPaciente = { name: "sIdPaciente", value: request.payload.sIdPaciente, type: "sql.Varchar", direction: "input" };
            var Param_Tope = { name: "iTope", value: request.payload.iTope, type: "sql.Int", direction: "input" };
            var Param_CitaEspecialista = { name: "bCitaEspecialista", value: request.payload.bCitaEspecialista, type: "sql.Bit", direction: "input" };
            var Param_Fecha = { name: "sFecha", value: request.payload.sFecha, type: "sql.Varchar", direction: "input" };
            var Param_Accion = { name: "sAccion", value: "ListarTurnosPrestadores", type: "sql.Varchar", direction: "input" };

            var params = [Param_CodigoEspecialidad, Param_IdSede, Param_IdPaciente, Param_Tope, Param_CitaEspecialista, 
                Param_Fecha, Param_Accion];

            sql_server.storedProcedure("ApiCitas.usp_TurnosPrestadores", params,  function (err, data) {
                let Response = {};
                
                if (typeof err == "undefined" || err == null) {
                    if(data.recordset != null && data.recordset.length>0){
                        Response.ListaTurnos = data.recordset;
                        Response.Error = false;
                        Response.Estado = 200;
                        Response.Mensaje = "Lista de turnos.";
                    }
                    else{
                        Response.ListaTurnos = null;
                        Response.Error = true;
                        Response.Estado = 404;
                        Response.Mensaje = "No existen turnos.";
                    }
                }else {
                    Response.ListaTurnos = null;
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

    buscarporfecha: function (request, reply) {
        try {
            var Param_CodigoEspecialidad = { name: "sCodigoEspecialidad", value: request.payload.sCodigoEspecialidad, type: "sql.Varchar", direction: "input" };
            var Param_IdSede = { name: "sIdSede", value: request.payload.sIdSede, type: "sql.Varchar", direction: "input" };
            var Param_IdPrestador = { name: "sIdPrestador", value: request.payload.sIdPrestador, type: "sql.Varchar", direction: "input" };
            var Param_Fecha = { name: "sFecha", value: request.payload.sFecha, type: "sql.Varchar", direction: "input" };
            var Param_Accion = { name: "sAccion", value: "ListarCuposDisponiblesFecha", type: "sql.Varchar", direction: "input" };

            var params = [Param_CodigoEspecialidad, Param_IdSede, Param_IdPrestador, Param_Fecha, Param_Accion];

            sql_server.storedProcedure("ApiCitas.usp_TurnosPrestadores", params,  function (err, data) {
                let Response = {};
                
                if (typeof err == "undefined" || err == null) {
                    if(data.recordset != null && data.recordset.length>0){
                        Response.ListaTurnos = data.recordset;
                        Response.Error = false;
                        Response.Estado = 200;
                        Response.Mensaje = "Lista de turnos.";
                    }
                    else{
                        Response.ListaTurnos = null;
                        Response.Error = true;
                        Response.Estado = 404;
                        Response.Mensaje = "No existen turnos.";
                    }
                }else {
                    Response.ListaTurnos = null;
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

module.exports = turnosprestadores;
