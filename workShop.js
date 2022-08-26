//Require----------------------------------------------------------------------
global.config = require('./config'); //Config Settings
const Hapi = require('hapi');


// Create a server with a host and port
const server = new Hapi.Server();
server.connection({
    port: global.config.application.port
});


// Add the route
server.route({
    method: 'GET',
    path: '/ping',
    handler: function (request, reply) {
        return reply('Pong');
    }
});

// Add the route
server.route({
    method: 'GET',
    path: '/hello/{nombre}',
    handler: function (request, reply) {
        return reply('Hola ' + request.params.nombre);
    }
});


// Add the route
server.route({
    method: 'POST',
    path: '/hello2',
    handler: function (request, reply) {
        return reply({ "statusCode": 200, "error": "Good Request", "mensaje": "Hola " + request.payload.nombre }).code(200).type('application/json');
    }
});

// Add the route
server.route({
    method: 'POST',
    path: '/hello3',
    handler: function (request, reply) {
        return reply({ "statusCode": 200, "error": "Good Request", "mensaje": "Hola " + request.query.nombre }).code(200).type('application/json');
    }
});


// Start the server
server.start((err) => {
    if (err) { throw err; }
    console.info('Servidor corriendo en el puerto:', global.config.application.port);
});