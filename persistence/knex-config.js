const knex = require('knex')({
  client: 'sqlite3',
  connection: {
    filename: "./roster.sqlite"
  },
  migrations: {
    tableName: "migrations"
  }
});

export default knex
