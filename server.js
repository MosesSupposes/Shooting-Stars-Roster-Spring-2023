const express = require('express');
const db = require('./persistence/dbConfig');

const server = express();

server.use(express.json());

server.post('/api/add-teammate/:name', function(req, res, next) {
  const { name } = request.params;

  res.status(201).send();
});

server.put('/api/remove-teammate/:name', function(req, res, next) {
  const { name } = request.params;

  res.status(200).send();
});

server.delete('/api/update-teammate-info/:name', function(req, res, next) {
  const { name } = request.params;

  res.status(200).send();
});


