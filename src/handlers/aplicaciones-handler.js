var config = require('../../config');
//Cliente Sql server
const sql = require('mssql')
//Async method
const co = require('co');

sql_server = require('../helpers/sql-server.js');


var api_aplicaciones = {
    query: function (request, reply) {
        return co(function* () {
            try {
                sql_server.query('SELECT TOP 5 * FROM SIGERIS', function (err, data) {
                    
                    if (typeof err !== "undefined" && err !== null) {
                        return reply({ err }).code(500).type('application/json');
                    }

                return reply(data).code(200).type('application/json');
                });
            } 
            catch (e) {
                console.error('Error en api_aplicaciones-query handler:', e);
                return reply(e).code(500).type('application/json');
            }
        });
    },

    execprocedure: function (request, reply) {
        return co(function* () {
            try {
                sql_server.storedProcedure(request.payload.storedProcedure, request.payload.params, function (err, data) {
                    
                    if (typeof err !== "undefined" && err !== null) {
                        return reply({ err }).code(500).type('application/json');
                    }

                    return reply(data).code(200).type('application/json');
                });
            } 
            catch (e) {
                console.error('Error en api_aplicaciones-execprocedure handler:', e);
                return reply(e).code(500).type('application/json');
            }
        });
    }

};

module.exports = api_aplicaciones;
