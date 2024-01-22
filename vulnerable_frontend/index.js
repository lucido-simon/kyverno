const { exec } = require('child_process');

const server = require('express')();

const backend = process.env.BACKEND || 'http://localhost:3000';
const frontend = process.env.FRONTEND || 'http://localhost:8080';

server.use(require('body-parser').json());
server.use(require('cors')());

server.get('/', (req, res) => {
  res.send(`<!DOCTYPE html>
  <html lang="en">
    <head>
      <meta charset="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title>Document</title>
    </head>
    <body>
      <h1>Vulnerable linux command line !</h1>
      <h2>Enter your command:</h2>
      <input type="text" id="command" name="command" />
      <button id="submit">Submit</button>
      <div id="result"></div>
      <script>
        const submit = document.getElementById('submit');
        const command = document.getElementById('command');
        const result = document.getElementById('result');
  
        submit.addEventListener('click', () => {
          fetch('${frontend}', {
            method: 'POST',
            body: JSON.stringify({ command: command.value }),
            headers: {
              'Content-Type': 'application/json',
            },
          }).then((res) => {
            res.text().then((text) => {
              result.innerHTML = text;
            });
          });
        });
      </script>
    </body>
  </html>`);
});

server.post('/', (req, res) => {
  console.log('Forwarding request to vulnerable backend');
  fetch(backend, {
    method: 'POST',
    body: JSON.stringify({ command: req.body.command }),
    headers: {
      'Content-Type': 'application/json',
    },
  }).then((backendRes) =>
    backendRes.body
      .getReader()
      .read()
      .then(({ value }) => res.send(new TextDecoder().decode(value))),
  );
});

console.log('Listening on port 8080');
server.listen(8080);
