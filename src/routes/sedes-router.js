//Require----------------------------------------------------------------------
  var path = require('path');
  var sedes = require('../handlers/sedes-handler.js');

  module.exports = [
    {
        method: 'GET',
        path: '/apicitas/sedes/listar',
        handler: sedes.listar,
        config: {
            tags: ['api'],
            description: 'Lista las sedes configuradas',
            auth: 'default'
        }
    }
  ];
