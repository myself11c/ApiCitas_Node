//Require----------------------------------------------------------------------
  var path = require('path');
  var citas = require('../handlers/citas-handler.js');

  module.exports = [
    {
        method: 'GET',
        path: '/apicitas/citas/buscarporid/{id}',
        handler: citas.buscarporid,
        config: {
            tags: ['api'],
            description: 'Busca una cita por id',
            auth: 'default'
        }
    },
    {
      method: 'GET',
      path: '/apicitas/citas/validarultimacitaincumplida/{id}',
      handler: citas.validarultimacitaincumplida,
      config: {
          tags: ['api'],
          description: 'Valida la ultima cita incumplida',
          auth: 'default'
        }
    },
    {
        method: 'POST',
        path: '/apicitas/citas/historial',
        handler: citas.historial,
        config: {
            tags: ['api'],
            description: 'Deveuelve el listado de las citas de un paciente',
            auth: 'default'
        }
    },
    {
        method: 'POST',
        path: '/apicitas/citas/cancelar',
        handler: citas.cancelar,
        config: {
            tags: ['api'],
            description: 'Cancela la cita de un paciente',
            auth: 'default'
        }
    },
    {
        method: 'POST',
        path: '/apicitas/citas/insertar',
        handler: citas.insertar,
        config: {
            tags: ['api'],
            description: 'Cancela la cita de un paciente',
            auth: 'default'
        }
    }

];
