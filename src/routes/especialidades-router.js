//Require----------------------------------------------------------------------
  var path = require('path');
  var especialidades = require('../handlers/especialidades-handler.js');

  module.exports = [
    {
        method: 'GET',
        path: '/apicitas/especialidades/listar',
        handler: especialidades.listar,
        config: {
            tags: ['api'],
            description: 'Lista las especialidades',
            auth: 'default'
        }
    }
  ];
