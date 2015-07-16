#!/usr/bin/env node

exports.bash = bash
bash.Q = bashQ

var Q = require('q')
  , cp = require('child_process')
  , exec = cp.exec
  , execSync = cp.execSync


function bash(command, opts, cb) {
  if(typeof opts === 'function') {
    cb = opts;
    opts = {};
  }
  opts.encoding = 'utf-8'
  exec('bash -c "' + command + '"', opts, function (err, stdout, stderr) {
    cb(err, stdout)
  })
}

function bashQ(command, opts) {
  var deferred = Q.defer()
  bash(command, opts, function(err, stdout) {
    if(err) deferred.reject(err)
    else deferred.resolve(stdout)
  })
  return deferred.promise
}
