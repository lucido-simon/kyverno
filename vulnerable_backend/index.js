const { exec } = require('child_process');

const server = require('express')();
server.use(require('body-parser').json());
server.use(require('cors')());

server.post('/', (req, res) => {
  console.log('Executing command: ' + req.body.command);
  exec(req.body.command)
    .stdout.on('data', (data) => {
      console.log('Sending response: ' + data);
      res.send(data);
    })
    .on('end', () => {
      res.end();
    });
});

server.get('/health', (req, res) => {
  res.send('OK');
});

console.log('Listening on port 3000');
server.listen(3000);
