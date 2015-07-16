#!/usr/bin/env node

/**
 * Runs the following commands for a module within the sync root directory
 * clone <module>
 * git fetch --all
 * git checkout --force <version>
 * @module sync
 */
module.exports = sync

var log = require('./tools/log')('sync')
  , Q = require('q')
  , join = require('path').join
  , bash = require('./tools/bash')
  , async = require('async')
  , format = require('util').format
  , env = require('./env')
  , yargs = require('yargs')
    .usage('usage: $0 [-b branch] [-v version] module')
    .option('v'
    , { alias: 'version'
      , demand: true
      , describe: 'annotated version to sync'
      , type: 'string'
    })
    .option('b'
    , { alias: 'branch'
      , demand: true
      , default: 'master'
      , describe: 'which branch to sync'
      , type: 'string'
    })
    .demand(1)
  , module = argv._[ 0 ]
  , clone = require('./clone')
  , modulePath = join(env.TIX_SYNC_ROOT, module)


function sync (args, cb) {
  var argv = yargs.parse(args)
    , gitSync = format('git fetch --all && git checkout --force %s', argv.version)

  bash(gitSync, { cwd: modulePath })
    .then(function (stdout) {
      cb(null, )

    })
    .then(notSynced)

  function synced (stdout) {
    deferred.resolve(stdout)
  }

  function notSynced (err) {
    deferred.reject(err)
  }

  return deferred.promise
}

function _sync (args) {
  var argv = yargs.parse(process.argv)
    ,
    }

  /** if run from script, process argv */
  if ( module.parent ) _sync(process.argv)
