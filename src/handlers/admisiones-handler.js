var config = require('../../config');
//Cliente Sql server
const sql = require('mssql')
//Async method
const co = require('co');

var sql_server = require('../helpers/sql-server.js');

var admisiones = {
    
    buscarporid: function (request, reply) {
        try {
            var Param_IdPaciente = { name: "IdPaciente", value: request.params.IdPaciente, type: "sql.Varchar", direction: "input" };

            var params = [Param_IdPaciente];

            sql_server.storedProcedure("ApiCitas.ConsultarCitasHoy", params, function (err, data) {
                let Response = {};
               // console.log(JSON.stringify(data));
                if (typeof err == "undefined" || err == null) {
                    if(data.recordset.length>0){
                         Response.Cita = data.recordset;
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

                return reply(Response).code(200);
            });
        } 
        catch (e) {
            console.error('Error en admisiones-buscarporid handler:', e);
            return reply(e).code(500);
        }
    },

    InformarCita: function (request, reply) {
        try {
            var Param_IdPaciente = { name: "IdServicio", value: request.params.IdServicio, type: "sql.Varchar", direction: "input" };

            var params = [Param_IdPaciente];

            sql_server.storedProcedure("ApiCitas.InformarCita", params, function (err, data) {
                let Response = {};
               // console.log(JSON.stringify(data));
                if (typeof err == "undefined" || err == null) {
                    if(data.recordset.length>0){
                         Response.Cita = data.recordset;
                         Response.Error = false;
                         Response.Estado = 200;
                         Response.Mensaje = "Informado.";
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

                return reply(Response).code(200);
            });
        } 
        catch (e) {
            console.error('Error en admisiones-informarcitas handler:', e);
            return reply(e).code(500);
        }
    },
};

module.exports = admisiones;
