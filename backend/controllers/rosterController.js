const RosterModel = require('../models/roster');

const Controller = {
  getFullRoster(req, res) {
    RosterModel.getFullRoster()
      .then(teammates => res.status(200).json(teammates)
      ).catch(err => res.status(404).json(
        { error: { message: 'The roster is currently empty. Add some teammates.' } }
      ));
  },

  getTeammateInfo(req, res) {
    RosterModel.findById(req.params.id)
      .then(teammate => res.status(200).json(teammate))
      .catch(err => res.status(404).json(
        { error: { message: `Unable to find the teammate with the ID of ${req.params.id}` } }
      ));
  },

  addNewTeammate(req, res) {
    RosterModel.addNewTeammate(req.body)
      .then(newlyAddedTeammate => res.status(201).json(newlyAddedTeammate))
      .catch(err => res.status(400).json(
        { error: { message: 'The provided request was invalid. Ensure the JSON body reflects the schema and try again.' } }
      ));
  },

  updateTeammateInfo(req, res) {
    RosterModel.updateTeammateInfo(req.params.id, req.body)
      .then(updatedTeammateInfo => res.status(200).json(updatedTeammateInfo))
      .catch(err => res.status(400).json(
        { error: { message: 'The provided request body was invalid. Ensure the JSON body reflects the schema and try again. ' } }
      ));
  },

  removeTeammate(req, res) {
    RosterModel.removeTeammate(req.params.id)
      .then(() => res.status(200).json({ message: "Successfully removed the member from the roster." }))
      .catch(err => res.status(400).json(
        { error: { message: `Unable to remove the member from the roster. The identifier ${req.param.id} is invalid` } }
      ));
  }

}




  ;

module.exports = Controller;

//     static async deleteMember(req, res) {
//         const [err, count] = await withCatch( ResourceModel.destroy(req.params.id) )
//
//         if (err) res.status(500).json({error: { message: 'Internal server error.'}})  
//         else res.status(200).json({ success: "Successfully removed the member. "})
//     }
