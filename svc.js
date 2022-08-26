var Service = require('node-windows').Service;
 
// Create a new service object
var svc = new Service({
  description: 'API-CITAS-NODEJS-PRODUCCION',
  name:'API-CITAS-NODEJS-PRODUCCION',
  script: 'C:\\ApiCitas_NodeJS\\server.js'
});
 
// Listen for the "install" event, which indicates the
// process is available as a service.
svc.on('install',function(){
  svc.start();
  console.log('The service exists: ', svc.exists);
  if(svc.exists) {
    console.log('install complete.');
  }else {
    console.log('install error .');
  }

});

svc.on('error',function(){
  svc.start();
  console.log('The service exists: ', svc.exists);
  console.log('The service exists: ', svc);
  if(svc.exists) {
    console.log('install complete.');
  }else {
    console.log('install error .');
  }

});
 
svc.install();