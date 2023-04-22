const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const db = require('./data/dbConfig');
const RosterController = require('./controllers/rosterController');

const server = express();

server.use(express.json());
server.use(helmet());
server.use(cors({ origin: 'https://shooting-stars-spring-2023.netlify.app/'}))

server.get('/api/roster', RosterController.getFullRoster);

server.get('/api/roster/:id', RosterController.getTeammateInfo);

server.post('/api/roster', RosterController.addNewTeammate);

server.put('/api/roster/:id', RosterController.updateTeammateInfo);

server.delete('/api/roster/:id', RosterController.removeTeammate);

server.use(function notFound(req, res, next) {
  const error = new Error('Resource not found.');
  error.status = 404;
  return next(error);
})

server.use(function errorHandler(error, req, res, next) {
  error.status = error.status || 500;
  error.message = error.message || 'Internal server error.';

  return res
    .status(error.status)
    .json({ error: { message: error.message } });
})

module.exports = server;
