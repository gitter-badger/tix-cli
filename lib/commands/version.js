#!/usr/bin/env node


/**
 * clone module -s
 * git fetch
 * git fetch --tags
 * git checkout -q --force origin/{branch}
 * if latest -> git describe --abbrev=0
 * else ->
 *    git tag -l | sort -r -n -t. -k1,1 -k2,2 -k3,3 | head -n {count}
 *    git log origin/{branch} --abbrev-commit --pretty=oneline --max-count={count}
 */

var log = require('./tools/log')('version')
  , bash = require('./tools/bash')
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