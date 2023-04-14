module.exports = {
  client: 'sqlite3',
  useDefaultAsNull: true,
  connection: {
    filename: "./persistence/roster.db3"
  },
  migrations: {
    tableName: "./persistence/migrations"
  },
  seeds: {
    directory: "./persistence/seeds"
  }
}
