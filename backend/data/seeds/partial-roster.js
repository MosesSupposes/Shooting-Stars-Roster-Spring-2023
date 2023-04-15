/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> } 
 */
exports.seed = async function(knex) {
  // Deletes ALL existing entries
  await knex('roster').del()
  await knex('roster').insert([
    { id: 1, name: 'Moses', jerseyNumber: '8', phoneNumber: '9293897608', primaryRole: 'SF', backupRole: 'PF' },
    { id: 2, name: 'Michael', jerseyNumber: '6', phoneNumber: '(612) 986-5405', primaryRole: 'SF', backupRole: 'SG' },
  ]);
};
