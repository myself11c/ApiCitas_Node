//Require----------------------------------------------------------------------
  var path = require('path');
  var admisiones = require('../handlers/admisiones-handler.js');

  module.exports = [
    {
        method: 'GET',
        path: '/apicitas/admisiones/buscarporid/{IdPaciente}',
        handler: admisiones.buscarporid,
        config: {
            tags: ['api'],
            description: 'Busca citas del dia de hoy por id de paciente',
            auth: 'default'
        }
    },
    
    {
        method: 'GET',
        path: '/apicitas/admisiones/InformarCita/{IdServicio}',
        handler: admisiones.InformarCita,
        config: {
            tags: ['api'],
            description: 'Informa la cita  por el id del servicio',
            auth: 'default'
        }
    },
    /*{
      method: 'GET',
      path: '/apicitas/admisiones/validarultimacitaincumplida/{id}',
      handler: admisiones.validarultimacitaincumplida,
      config: {
          tags: ['api'],
          description: 'Valida la ultima cita incumplida',
          auth: 'default'
        }
    },
    {
        method: 'POST',
        path: '/apicitas/admisiones/historial',
        handler: admisiones.historial,
        config: {
            tags: ['api'],
            description: 'Deveuelve el listado de las citas de un paciente',
            auth: 'default'
        }
    },
    {
        method: 'POST',
        path: '/apicitas/admisiones/cancelar',
        handler: admisiones.cancelar,
        config: {
            tags: ['api'],
            description: 'Cancela la cita de un paciente',
            auth: 'default'
        }
    },
    {
        method: 'POST',
        path: '/apicitas/admisiones/insertar',
        handler: admisiones.insertar,
        config: {
            tags: ['api'],
            description: 'Cancela la cita de un paciente',
            auth: 'default'
        }
    }*/

];
