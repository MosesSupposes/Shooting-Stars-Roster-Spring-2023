module.exports = {
  client: 'sqlite3',
  useDefaultAsNull: true,
  connection: {
    filename: "./roster.db3"
  },
  migrations: {
    directory: "./migrations"
  },
  seeds: {
    directory: "./seeds"
  }
}
