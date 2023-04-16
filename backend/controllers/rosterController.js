const RosterModel = require('../models/roster');

const controller = {
  async getFullRoster(req, res) {
    return RosterModel.getFullRoster()
      .then(teammates => res.status(200).json(teammates))
      .catch(err => res.status(404).json(
        { error: { message: 'The roster is currently empty. Add some teammates.' } }
      ));
  },

  getTeammateInfo(req, res) {
    return RosterModel.findById(req.params.id)
      .then(teammate => res.status(200).json(teammate))
      .catch(err => res.status(404).json(
        { error: { message: `Unable to find the teammate with the ID of ${req.params.id}` } }
      ));
  },

  addNewTeammate(req, res) {
    return RosterModel.addNewTeammate(req.body)
      .then(newlyAddedTeammate => res.status(201).json(newlyAddedTeammate))
      .catch(err => {
        console.log('hapo', err);
        return res.status(400).json({ error: { message: 'The provided request was invalid. Ensure the JSON body reflects the schema and try again.' } })
      });
  },

  updateTeammateInfo(req, res) {
    return RosterModel.updateTeammateInfo(req.params.id, req.body)
      .then(updatedTeammateInfo => res.status(200).json(updatedTeammateInfo))
      .catch(err => res.status(400).json(
        { error: { message: 'The provided request body was invalid. Ensure the JSON body reflects the schema and try again. ' } }
      ));
  },

  removeTeammate(req, res) {
    return RosterModel.removeTeammate(req.params.id)
      .then(() => res.status(200).json({ message: "Successfully removed the member from the roster." }))
      .catch(err => res.status(400).json(
        { error: { message: `Unable to remove the member from the roster. The identifier ${req.params.id} is invalid` } }
      ));
  }

};

module.exports = controller;
