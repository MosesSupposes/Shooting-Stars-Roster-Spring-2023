/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.up = function(knex) {
  return knex.schema.createTable('roster', table => {
    table.increments();
    table.string('name').notNullable();
    table.string('jerseyNumber').nullable();
    table.string('phoneNumber').notNullable();
    table.string('primaryRole').notNullable();
    table.string('backupRole').nullable();

  });
};

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.down = function(knex) {
  return knex.schema.dropTableIfExists('roster');
};
