#!/usr/bin/env node
var fs = require('fs');
var http = require('http');
var ss = require('socketstream');

var argv = require('minimist')(process.argv.slice(2));

//var secureHeaders = require('./server/secure-headers.js');

var server;

//define assets for admin app
ss.client.define('main', {
  view: 'app.jade',
  css:  ['libs', 'app.styl'],
  code: ['libs', 'app'],
  tmpl: '*'
});

// serve main client on the root url
ss.http.route('/', function(req, res) {
  res.serveClient('main');
});

// code formatters
ss.client.formatters.add(require('ss-jade'));
ss.client.formatters.add(require('ss-stylus'));

ss.client.templateEngine.use(require('ss-hogan'));

// minimize and pack assets if you type: SS_ENV=production node app.js
// if (ss.env === 'production') ss.client.packAssets();

// start server
server = http.Server(ss.http.middleware);
if (argv.http) {
} else {
  if (argv.cert) {
    var fingerprint = require('./server/fingerprint');
  }

  var options = {
    key: fs.readFileSync(argv.key || 'server.key'),
    cert: fs.readFileSync(argv.cert || 'server.crt'),
    secureProtocol: 'TLSv1_method',
    ciphers: 'AES128-GCM-SHA256:RC4:HIGH:!MD5:!aNULL:!EDH',
    honorCipherOrder: true
  };

  //server = https.createServer(options, ss.http.middleware);
}

server.listen(8081);

//ss.http.middleware.append(secureHeaders({ https: !argv.http }));

// start socketstream
ss.start(server);

var price_feed = require('./server/price/feed');
