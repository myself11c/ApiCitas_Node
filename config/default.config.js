var config = {
  db: {
    user: 'API_CITAS_NODE',
    password: 'API_CITAS_NODE',
    server: 'data.caminosips.com',
    database: 'SIOS_NUEVO'
  },
  credenciales: {
    usuario: 'caminosips',
    clave: 'Bhu8Nji9Mko0'
  },
  elasticsearch: {
    host: 'locahost:9200',
    log: 'trace',
    index : 'test'
  },
  application: {
    port: 8023,
    title: 'Tiserium WebApi'
  }
};

module.exports = Object.freeze(config);
