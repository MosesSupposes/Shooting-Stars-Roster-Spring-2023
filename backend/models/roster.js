const db = require('../data/dbConfig')

const model = {
  getFullRoster() {
    return db('roster');
  },

  findById(id) {
    return db('roster').where({ id });
  },

  async addNewTeammate(teammate) {
    const [id] = await db('roster').insert(teammate, 'id');
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
