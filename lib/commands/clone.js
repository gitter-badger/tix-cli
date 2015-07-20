#!/usr/bin/env node

/**
 * Runs the following commands for a module within the sync root directory
 * clone {module}
 * git fetch --all
 * if argv.version -> git checkout --force {version}
 * else -> git checkout {branch}
 * @module clone
 */

module.exports = clone
clone.Q = cloneQ
clone.sync = cloneSync

if (!module.parent) clone.sync(process.argv)

var logger = require('./tools/log')
  , bash = require('./tools/bash')
  , join = require('path').join
  , async = require('async')
  , format = require('util').format
  , env = require('./env')
  , mkdirp = require('mkdirp')
  , yargs = require('yargs')
    .usage('usage: $0 [-s/--sync] [-p/--path] [-b/--branch] [-v/--version] module')
    .option('s'
    , { alias: 'sync'
      , demand: true
      , default: false
      , describe: 'clone to sync root'
      , type: 'boolean'
    }
  )
    .option('p'
    , { alias: 'path'
      , demand: false
      , describe: 'path to clone directory'
      , type: 'string'
    }
  )
    .option('b'
    , { alias: 'branch'
      , demand: true
      , default: 'master'
      , describe: 'the branch to checkout'
      , type: 'string'
    }
  )
    .option('v'
    , { alias: 'version'
      , demand: false
      , describe: 'the annotated version to checkout'
      , type: 'string'
    }
  )
    .demand(1)
  , commands =
    { clone: function (url) { return format('git clone %s', url) }
    , fetch: function () { return 'git fetch --all' }
    , checkout: function (argv) {
      return argv.version ?
        format('git checkout -f %s', argv.version) :
        format('git checkout %s', argv.branch)
      }
    }
  , messages =
    { cloneFinished: 'clone step finished'
    , fetchFinished: 'fetch step finished'
    , checkoutFinished: 'checkout step finished'
    , errorOccurred: 'an error occurred during clone.js execution'
    }

function clone (args, cb) {
  var ctx = buildContext(args)
  logger('clone', function (err, log) {
    if (err) onError(err)
    else {
      mkdirp(rootDirectory, function (err) {
        if (err) onError(err)
        else _clone()
      })

      function _clone () {
        bash.Q(commands.clone(ctx.url), ctx.rootDirectory)
          .then(onClone).then(onError)
      }

      function onClone (stdout) {
        log.info(stdout, messages.cloneFinished)
        bash.Q(commands.fetch(), ctx.moduleDirectory)
          .then(onFetch).then(onError)
      }

      function onFetch (stdout) {
        log.info(stdout, messages.fetchFinished)
        bash.Q(commands.checkout(ctx.argv), ctx.moduleDirectory)
          .then(onCheckout).then(onError)
      }

      function onCheckout (stdout) {
        log.info(stdout, messages.checkoutFinished)
        cb()
      }

      function onError (err) {
        log.error(err, messages.errorOccurred)
        cb(err)
      }
    }
  })
}

function cloneQ (args) {
  return Q.nfbind(clone)(args)
}

function cloneSync (args) {
  var ctx = buildContext(args)
    , stdout = ''
    , log = logger.sync('clone')

  try {
    mkdirp.sync(ctx.rootDirectory)
    stdout = bash.sync(commands.clone(ctx.url), ctx.rootDirectory)
    log.info(stdout, messages.cloneFinished)
    stdout = bash.sync(commands.fetch(), ctx.moduleDirectory)
    log.info(stdout, messages.fetchFinished)
    stdout = bash.sync(commands.checkout(ctx.argv), ctx.moduleDirectory)
    log.info(stdout, messages.checkoutFinished)
  } catch (err) {
    log.error(err, messages.errorOccurred)
    throw err
  }
}

function buildContext (args) {
  var argv = yargs.parse(args)
    , module = argv._[ 0 ]
    , rootDirectory = getRootDirectory()

  return  { argv: argv
          , module: module
          , url: format('https://github.com/tixinc/%s', module)
          , rootDirectory: rootDirectory
          , moduleDirectory: join(rootDirectory, module)
          }

  function getRootDirectory () {
    if (argv.sync) return env.TIX_SYNC_ROOT
    if (argv.path) return argv.path
    return env.TIX_SRC_ROOT
  }
}
