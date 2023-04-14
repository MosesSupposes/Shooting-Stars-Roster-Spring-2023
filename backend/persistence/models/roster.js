const db = require('../dbConfig')

const model = {
  getFullRoster() {
    return db('roster');
  },

  findById(id) {
    return db('roster').where({ id });
  },

  findByJersey(jerseyNumber) {
    return db('roster').where({ jersey: jerseyNumber });
  },

  findByName(name) {
    return db('roster').where({ name });
  },

  async addNewTeammate(teammateInfo) {
    const [id] = await db('roster').insert(teammateInfo, 'id');
    return db('roster').where({ id });
  },

  async updateTeammateInfo(id, newTeammateInfo) {
    await db('roster').where({ id }).update(newTeammateInfo);
    return this.findById(id);
  },

  removeTeammate(id) {
    return db('resource').where({ id }).delete()
  }

}


module.exports = model;
