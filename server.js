//Require----------------------------------------------------------------------
global.config = require('./config'); //Config Settings
const Hapi = require('hapi');
const requireDir = require('require-dir');
const inert = require('inert');
var api_autorizador = require('./src/handlers/autorizador-handler.js');

const server = new Hapi.Server();

// Create a server with a host and port
server.connection({
    port: global.config.application.port,
    routes: {
      cors: true,
      payload: {
        maxBytes: 16384
      },
      security: {
        hsts: {
          maxAge: 15552000,
          includeSubdomains: true
        },
        xframe: true,
        xss: true,
        noOpen: false,
        noSniff: true
      },
    }
});

const scheme = function (server, options) {

    return {
        api: {
            settings: {
                x: 5
            }
        },
        authenticate: function (request, reply) {
            api_autorizador.autenticar(request, reply);
        }
    };
};

server.auth.scheme('autorizador', scheme);
server.auth.strategy('default', 'autorizador');

//Registering Plugins
server.register([inert], function (err) {

  //Validar el error
  if (err) {server.log('An error ocurred trying to Register the plugins' + err);}

  //Routes
  var routes = requireDir('./src/routes');
  for (var route in routes) {
    server.route(routes[route]);
  }
});

// Start the server
server.start((err) => {
  if (err) {throw err;}
  console.info('Servidor corriendo en el puerto:', global.config.application.port);
});
