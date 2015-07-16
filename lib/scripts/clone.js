#!/usr/bin/env node

var log = require('./tools/log')('clone')
  , bash = require('./tools/bash')
  , async = require('async')
  , format = require('util').format
  , env = require('./env')
  , mkdirp = require('mkdirp')
  , argv = require('yargs')
    .usage('usage: $0 [-s/--sync] [-p/--path path] module')
    .option('s'
    , { alias: 'sync'
      , demand: true
      , default: false
      , describe: 'clone to sync root'
      , type: 'boolean'
      })
    .demand(1)
    .argv
  , module = argv._[0]
  , rootDirectory = getRootDirectory()
  , gitUrl = format('https://github.com/tixinc/%s', module)
  , gitClone = format('git clone %s', gitUrl)

function getRootDirectory() {
  if(argv.sync) return env.TIX_SYNC_ROOT
  if(argv.path) return argv.path
  return env.TIX_SRC_ROOT
}

mkdirp(rootDirectory, function(err) {
  if(err) log.error(err, 'error creating %s', rootDirectory)
  else {
    bash(gitClone, {cwd: rootDirectory})
      .then(cloned)
      .then(notCloned)
  }
})

function cloned(stdout) {
  log.info(stdout)
}

function notCloned(err) {
  log.error(err)
}

