//Require----------------------------------------------------------------------
  var path = require('path');
  var turnosprestadores = require('../handlers/turnosprestadores-handler.js');

  module.exports = [
    {
        method: 'POST',
        path: '/apicitas/turnosprestadores/buscarporespecialidad',
        handler: turnosprestadores.buscarporespecialidad,
        config: {
            tags: ['api'],
            description: 'Busca los turnos de los prestadores filtrando por la especialidad',
            auth: 'default'
        }
    },
    {
      method: 'POST',
      path: '/apicitas/turnosprestadores/buscarporfecha',
      handler: turnosprestadores.buscarporfecha,
      config: {
          tags: ['api'],
          description: 'Busca los turnos de los prestadores filtrando por una fecha',
          auth: 'default'
      }
  }
  ];
