module.exports = {
  development: {
    client: 'sqlite3',
    connection: {
      filename: "./persistence/roster.sqlite"
    },
    migrations: {
      tableName: "./persistence/migrations/dev"
    },
    seeds: {
      directory: "./persistence/seeds/dev"
    }

  },
  prod: {
    client: 'sqlite3',
    connection: {
      filename: "./persistence/roster.prod.sqlite"
    },
    migrations: {
      tableName: "./persistence/migrations/prod"
    },
    seeds: {
      directory: "./persistence/seeds/prod"
    }

  }
}
