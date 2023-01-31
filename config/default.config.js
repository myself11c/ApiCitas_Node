var config = {
  db: {
    user: '',
    password: '',
    server: '',
    database: ''
  },
  credenciales: {
    usuario: '',
    clave: ''
  },
  elasticsearch: {
    host: 'locahost:9200',
    log: 'trace',
    index : 'test'
  },
  application: {
    port: 8023,
    title: 'WebApi'
  }
};

module.exports = Object.freeze(config);
