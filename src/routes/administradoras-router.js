//Require----------------------------------------------------------------------
  var path = require('path');
  var administradoras = require('../handlers/administradoras-handler.js');

  module.exports = [
    {
        method: 'GET',
        path: '/apicitas/administradoras/listar',
        handler: administradoras.listar,
        config: {
            tags: ['api'],
            description: 'Lista las administradoras',
            auth: 'default'
        }
    }
  ];
