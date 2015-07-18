#!/usr/bin/env node

module.exports = bash
bash.Q = bashQ
bash.sync = bashSync

if(!module.parent) bash.sync(process.argv)

var Q = require('q')
  , cp = require('child_process')
  , exec = cp.exec
  , execSync = cp.execSync
  , format = require('util').format

function bash(command, opts, cb) {
  if(typeof opts === 'function') {
    cb = opts;
    opts = {};
  }
  opts = normalizeOpts(opts, cb)
  exec(wrapCommand(command), opts, cb)
}

function bashQ(command, opts) {
  return Q.nfbind(bash)(command, opts)
}

function bashSync(command, opts) {
  opts = normalizeOpts(opts)
  return execSync(wrapCommand(command), opts)
}

function normalizeOpts(opts) {
  /** convenience to allow opts to be set as common param current working directory */
  if(typeof opts === 'string') {
    opts = { cwd: opts }
  }
  opts = opts || {}
  opts.encoding = 'utf-8'
}

function wrapCommand(command) {
  return format('bash -c "%s"', command)
}