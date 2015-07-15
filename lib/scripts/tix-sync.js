#!/usr/bin/env node

var log = require('bunyan').createLogger({name: 'tix-sync'})
  , exec = require('child_process').exec
  , async = require('async')
  , format = require('util').format
  , modules = [ 'tixinc-net', 'tixinc-js' ]
  , versions = {}
  , buildOutput = {}
  , argv = require('yargs')
  .usage('usage: $0 [-l] [-c configuration] [-j js-version] [-n net-version]')
  .option('c',  { alias: 'configuration'
                , demand: true
                , default: 'Dev'
                , describe: 'The configuration to build (Debug, Dev, Test, Release)'
                , type: 'string'
                })
  .option('l',  { alias: 'latest'
                , demand: true
                , default: false
                , describe: 'Deploy latest annotated versions of all projects'
                , type: 'boolean'
                })
  .argv

if(argv.latest) {
  log.info('latest (-l) flag specified, getting the latest annotated tagged versions')
  async.each( modules
            , getVersion
            , function(err) {
                if(err) log.error(err, 'error occurred getting versions')
                else {
                  log.info(versions, 'found latest versions')
                  build()
                }
            })
}

function build() {
  log.info('building project')
  async.each( ['tixinc-net'] //modules
            , buildModule
            , function(err) {
              if(err) log.error(err, 'error occurred building modules')
              else {
                log.info(buildOutput, 'finished building modules')
              }
            })
}

function buildJs() {

}

function syncModule() {

}

function getVersion(module, cb) {
  bash('revisions -l ' + module, function(ver) {
    versions[module] = ver.replace(/\n/, '')
    cb()
  })
}

function buildModule(module, cb) {
  if(module === 'tixinc-net') {
    bash( format('build-net -v "%s" -c "%s" -V 12.0', versions['tixinc-net'], argv.c)
        , recordBuild
        )
  } else {
    bash( format('build-js -v "%s" -c "%s" -C', versions['tixinc-js'], argv.c.toLowerCase())
        , recordBuild
        )
  }

  function recordBuild(output) {
    buildOutput[module] = output
    cb()
  }
}


function bash(command, cb) {
  exec('bash -c "' + command + '"', { encoding: 'utf-8'}, function(err, stdout, stderr) {
    if(err) log.error(err)
    else cb(stdout)
  })
}


