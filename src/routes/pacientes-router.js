//Require----------------------------------------------------------------------
  var path = require('path');
  var pacientes = require('../handlers/pacientes-handler.js');

  module.exports = [
    {
        method: 'GET',
        path: '/apicitas/pacientes/buscarporid/{id}',
        handler: pacientes.buscarporid,
        config: {
            tags: ['api'],
            description: 'Busca un paciente por su id',
            auth: 'default',
        }
    },
    {
      method: 'POST',
      path: '/apicitas/pacientes/buscar',
      handler: pacientes.buscar,
      config: {
          tags: ['api'],
          description: 'Busca un paciente por su identificación y tipo de identificación',
          auth: 'default'
      }
    },
    {
      method: 'POST',
      path: '/apicitas/pacientes/validar',
      handler: pacientes.validar,
      config: {
          tags: ['api'],
          description: 'Valida un paciente por su identificación y tipo de identificación',
          auth: 'default'
      },
    },
    {
      method: 'POST',
      path: '/apicitas/pacientes/insertar',
      handler: pacientes.insertar,
      config: {
          tags: ['api'],
          description: 'Inserta un paciente',
          auth: 'default'
      },
    },
    {
      method: 'POST',
      path: '/apicitas/pacientes/actualizar',
      handler: pacientes.actualizar,
      config: {
          tags: ['api'],
          description: 'Actualiza un paciente',
          auth: 'default'
      },
    }
];
