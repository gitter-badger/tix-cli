#!/usr/bin/env node

var format = require('util')
  , path = require('path')
  , join = path.join

  , HOME = process.env.HOME || process.env.USERPROFILE
  , SSH_ROOT = join(HOME, '.ssh')
  , NPMRC_PATH = join(HOME, '.npmrc')

  , TIX_HOME = process.env.TIX_HOME || join(HOME, '.tix')
  , TIX_ETC_ROOT = join(TIX_HOME, 'etc')

  , TIX_LOCAL_ROOT = join(TIX_HOME, 'local')
  , TIX_LOCAL_BIN_ROOT = join(TIX_LOCAL_ROOT, 'bin')
  , TIX_LOCAL_NPM_ROOT = join(TIX_LOCAL_ROOT, 'npm')

  , TIX_SRC_ROOT = join(HOME, 'src')

  , TIX_SYNC_ROOT = join(TIX_HOME, 'sync')
  , TIX_SYNC_NET_ROOT = join(TIX_SYNC_ROOT, 'tixinc-net')
  , TIX_SYNC_JS_ROOT = join(TIX_SYNC_ROOT, 'tixinc-js')

  , TIX_BUILD_ROOT = join(TIX_HOME, 'build')
  , TIX_BUILD_NET_ROOT = join(TIX_BUILD_ROOT, 'tixinc-net')
  , TIX_BUILD_JS_ROOT = join(TIX_BUILD_ROOT, 'tixinc-js')

  , TIX_RELEASE_ROOT = join(TIX_HOME, 'release')
  , TIX_RELEASE_BIN_ROOT = join(TIX_RELEASE_ROOT, 'bin')
  , TIX_RELEASE_NET_ROOT = join(TIX_RELEASE_ROOT, 'tixinc-net')
  , TIX_RELEASE_JS_ROOT = join(TIX_RELEASE_ROOT, 'tixinc-js')

  , TIX_ARTIFACTS_ROOT = join(TIX_HOME, 'artifacts');

module.exports =
  { HOME: HOME
  , SSH_ROOT: SSH_ROOT
  , NPMRC_PATH: NPMRC_PATH
  , TIX_HOME: TIX_HOME
  , TIX_ETC_ROOT: TIX_ETC_ROOT
  , TIX_LOCAL_ROOT: TIX_LOCAL_ROOT
  , TIX_LOCAL_BIN_ROOT: TIX_LOCAL_BIN_ROOT
  , TIX_LOCAL_NPM_ROOT: TIX_LOCAL_NPM_ROOT
  , TIX_SRC_ROOT: TIX_SRC_ROOT
  , TIX_SYNC_ROOT: TIX_SYNC_ROOT
  , TIX_SYNC_NET_ROOT: TIX_SYNC_NET_ROOT
  , TIX_SYNC_JS_ROOT: TIX_SYNC_JS_ROOT
  , TIX_BUILD_ROOT: TIX_BUILD_ROOT
  , TIX_BUILD_NET_ROOT: TIX_BUILD_NET_ROOT
  , TIX_BUILD_JS_ROOT: TIX_BUILD_JS_ROOT
  , TIX_RELEASE_ROOT: TIX_RELEASE_ROOT
  , TIX_RELEASE_BIN_ROOT: TIX_RELEASE_BIN_ROOT
  , TIX_RELEASE_NET_ROOT: TIX_RELEASE_NET_ROOT
  , TIX_RELEASE_JS_ROOT: TIX_RELEASE_JS_ROOT
  , TIX_ARTIFACTS_ROOT: TIX_ARTIFACTS_ROOT
  }
