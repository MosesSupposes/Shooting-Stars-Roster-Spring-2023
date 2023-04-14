const knex = require('knex');

let config;
if (proces.ENV == "prod") {
  config = require('../knexfile').prod;
} else {
  config = require('../knexfile').development;
}

module.exports = knex(config);
