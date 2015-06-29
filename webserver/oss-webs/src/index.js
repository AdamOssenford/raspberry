var express = require('express');
var os = require("os");

var app = express();
var hostname = os.hostname();

app.get('/', function (req, res) {
  res.send('<html><body>Hello from Node.js container ' + hostname + '<br><br>');
  res.send('<img src=http://pbs.twimg.com/profile_images/528203613013671936/NK9eucge_normal.jpeg></body></html>');
});

app.listen(80);
console.log('Running on http://localhost');
