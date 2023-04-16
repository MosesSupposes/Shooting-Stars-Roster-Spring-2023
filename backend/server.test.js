// const db = require('./data/dbConfig');
// const request = require('supertest');
// const server = require('./server');
//
// const newTeammate = { name: 'Moses', jerseyNumber: '8', phoneNumber: '9293897608', primaryRole: 'SF', backupRole: 'PF' }
//
// describe('endpoints', () => {
//
//   test('GET /api/roster | should return a list of teammates', async () => {
//     let teammates = await request(server).get('/api/roster');
//     expect(teammates.body).toHaveLength(0);
//
//     await request(server).post('/api/roster').send(newTeammate);
//     const teammatesAfterPost = await request(server).post('/api/roster').send({ ...newTeammate, name: 'Michael' });
//     expect(teammatesAfterPost.body).toHaveLength(2);
//   });
//
//   test('POST /api/roster | should add a teammate to the roster', async () => {
//     const teammatesBeforePost = await request(server).get('/api/roster');
//     expect(teammatesBeforePost.body).toHaveLength(0);
//
//     await request(server).post('/api/roster').send(newTeammate);
//
//     const teammatesAfterPost = await request(server).get('/api/roster');
//     expect(teammatesAfterPost.body).toHaveLength(1);
//   });
//
// });
