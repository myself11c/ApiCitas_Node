const defaults = require('./default.config');

const config = {
  db: {
    user: '',
    password: '',
    server: '',
    database: ''
  },
  credenciales: {
    usuario: 'juan_marrugo',
    clave: 'jm1_xxxx'
  },
  elasticsearch: {
    host: 'DESKTOP-8TO7QTI:9200',
    log: 'trace',
    index : 'test'
  },
  application: {
    port: 8023,
    title: 'WorkShop WebApi'
  }
};

module.exports = Object.freeze(Object.assign({}, defaults, config));
