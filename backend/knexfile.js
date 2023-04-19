module.exports = {
  client: 'sqlite3',
  useDefaultAsNull: true,
  connection: {
    filename: "./roster.db3"
  },
  migrations: {
    directory: "./data/migrations"
  },
  seeds: {
    directory: "./data/seeds"
  }
}
