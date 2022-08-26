var config = require('../../config');
//Cliente Sql server
const sql = require('mssql')
//Async method
const co = require('co');

var sql_server = require('../helpers/sql-server.js');


var autorizador = {
    
    autenticar: function (request, reply) {
            try {
                let Response = {};
                if(!request.headers.authorization)
                {
                    Response.Error = true;
                    Response.Estado = 401;
                    Response.Mensaje = "Debe definir la autenticación.";
                    return reply(Response).code(401).type('application/json').header("Access-Control-Allow-Origin", "*");
                }

                // verify auth credentials
                const base64Credentials =  request.headers.authorization.split(' ')[1];
                const credentials = Buffer.from(base64Credentials, 'base64').toString('ascii');
                const [username, password] = credentials.split(':');

                if(username != global.config.credenciales.usuario || password != global.config.credenciales.clave){
                    Response.Error = true;
                    Response.Estado = 401;
                    Response.Mensaje = "El usuario o la clave de autenticación son incorrectos.";
                    return reply(Response).code(401).type('application/json').header("Access-Control-Allow-Origin", "*");
                }

                return reply.continue({ credentials: { validacion: "OK" } });
            } 
            catch (e) {
                console.error('Error en autorizador-validar_token handler:', e);
                return reply(e).code(500).type('application/json').header("Access-Control-Allow-Origin", "*");
            }
    }
};

module.exports = autorizador;
