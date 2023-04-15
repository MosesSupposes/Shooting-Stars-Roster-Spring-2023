const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const db = require('./persistence/dbConfig');

const server = express();

server.use(express.json());
server.use(helmet);
server.use(cors);

server.get('/api/roster', function(req, res, next) {

});

server.get('/api/roster/:id', function(req, res, next) {

});

server.post('/api/roster', function(req, res, next) {
  const { name } = request.params;

  return res.status(201).send();
});

server.put('/api/roster/:id', function(req, res, next) {
  const { name } = request.params;

  return res.status(200).send();
});

server.delete('/api/roster/:id', function(req, res, next) {
  const { name } = request.params;

  return res.status(200).send();
});

server.use(function notFound(req, res, next) {
  const error = new Error('Resource not found.');
  error.status = 404;
  return next(error);
})

server.use(function errorHandler(error, req, res, next) {
  error.status = error.status || 500;
  error.message = error.message || 'Internal server error.';

  return res
    .status(err.status)
    .json({ error: { message: error.message } });
})

module.exports = server;
