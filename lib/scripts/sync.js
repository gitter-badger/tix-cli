#!/usr/bin/env node

var log = require('./tools/log')('sync')
  , fork = require('child_process').fork
  , join = require('path').join
  , bash = require('./tools/bash')
  , async = require('async')
  , format = require('util').format
  , env = require('./env')
  , yargs = require('yargs')
    .usage('usage: $0 [-b branch] [-v version] module')
    .option('v'
    , {
      alias: 'version'
      , demand: true
      , describe: 'annotated version to sync'
      , type: 'string'
    })
    .option('b'
    , {
      alias: 'branch'
      , demand: true
      , default: 'master'
      , describe: 'which branch to sync'
      , type: 'string'
    })
    .demand(1)
  , module = argv._[ 0 ]
  , modulePath = join(env.TIX_SYNC_ROOT, module)
  , clonePath = join(__dirname, 'clone')
  , syncCommand = format('git fetch --all && git checkout --force %s', argv.version)


//** If parent script, yargs will parse the argv */
if (module.parent) {
  sync(process.argv)
}

module.exports = function (argv) {
  argv = yargs.parse(argv)

  function forkClone () {
    var child = fork(clonePath, [ '--sync', module ])
    child.on('message', function (out) {

    })
  }

  function sync () {
    bash(syncCommand, { cwd: modulePath })
      .then(synced)
      .then(notSynced)
  }

  function synced (stdout) {

  }

  function notSynced (error) {

  }
}

