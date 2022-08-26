var config = require('../../config');
//Cliente Sql server
const sql = require('mssql')
//Async method
const co = require('co');

var sql_server = require('../helpers/sql-server.js');

var especialidades = {

    listar: function (request, reply) {
        try {
            var params = [];
            sql_server.storedProcedure("ApiCitas.usp_EspecialidadesConsultar", params,  function (err, data) {
                let Response = {};
                
                if (typeof err == "undefined" || err == null) {
                    if(data.recordset != null && data.recordset.length>0){
                        Response.ListaEspecialidades = data.recordset;
                        Response.Error = false;
                        Response.Estado = 200;
                        Response.Mensaje = "Lista de especialidades.";
                    }
                    else{
                        Response.ListaEspecialidades = null;
                        Response.Error = true;
                        Response.Estado = 404;
                        Response.Mensaje = "No existen especialidades.";
                    }
                }else {
                    Response.ListaEspecialidades = null;
                    Response.Error = true;
                    Response.Estado = 500;
                    Response.Mensaje = err.originalError.message;
                }

                return reply(Response).code(Response.Estado);
            });
        } 
        catch (e) {
            console.error('Error en especialidades-listar handler:', e);
            return reply(e).code(500);
        }
    }
};

module.exports = especialidades;
