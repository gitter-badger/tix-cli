#!/usr/bin/env node

var log = require('bunyan').createLogger({name: 'tix-version'})
  , argv = require('yargs')
  .usage('usage: $0 [-l] [-b branch] [-c count] module')
  .option('b',  { alias: 'branch'
                , demand: false
                , default: 'master'
                , describe: 'the branch to find version of'
                , type: 'string'
                })
  .option('c',  { alias: 'count'
                , demand: false
                , default: 10
                , describe: 'number of recent versions to get'
                , type: 'number'
                })
  .option('l',  { alias: 'latest'
                , demand: true
                , default: false
                , describe: 'get latest annotated version'
                , type: 'boolean'
                })
  .argv


if(_.length === 0) {
  log.error('must pass module to get versions for')

}