//Require----------------------------------------------------------------------
  var path = require('path');
  var api_aplicaciones = require('../handlers/aplicaciones-handler.js');
  
  module.exports = [
    
    //RUTAS DE EJEMPLO:
    {
        method: 'GET',
        path: '/ping',
        handler: function (request, reply) {
            let Response = {};
            Response.Error = false;
            Response.Estado = 200;
            Response.Mensaje = "Pong";
            return reply(Response);
            //return reply('Pong');
        },
        config: {
            tags: ['api'],
            description: 'Main purpose of this service is to return Pong'
            
        }
        //Example: http://localhost:8023/ping
    },
    {
      method: 'GET',
      path: '/pang',
      handler: function (request, reply) {
          let Response = {};
          Response.Error = false;
          Response.Estado = 200;
          Response.Mensaje = "Pong";
          return reply(Response);
          //return reply('Pong');
      },
      config: {
          tags: ['api'],
          description: 'Main purpose of this service is to return Pong'
          
      }
      //Example: http://localhost:8023/ping
  }

  ];
