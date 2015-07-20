module.exports = logger
logger.Q = loggerQ
logger.sync = loggerSync

if(!module.parent) logger.sync(process.argv)

var bunyan = require('bunyan')
  , Q = require('q')
  , resolve = require('path').resolve
  , mkdirp = require('mkdirp')
  , format = require('util').format

function logger(name, logDirectory, cb) {
  logDirectory = resolve(logDirectory || '../logs')
  mkdirp(logDirectory, function(err) {
    if(err) cb(err)
    else cb(null, createLogger(name, logDirectory))
  })
}

function loggerQ(name, logDirectory) {
  return Q.nfbind(logger)(name, logDirectory)
}

function loggerSync(name, logDirectory) {
  logDirectory = resolve(logDirectory || '../logs')
  mkdirp.sync(logDirectory)
  return createLogger(name, logDirectory)
}

function createLogger (name, logDirectory) {
  return require('bunyan').createLogger(
    { name: name
    , streams:  [ stdOutLogger()
                , rotatingFileLogger(format('%s.log', name), logDirectory)
                ]
    })
}

function stdOutLogger () {
  return  { "level": "info"
          , "stream": process.stdout
          }
}

function rotatingFileLogger (filename, logDirectory) {
  return  { "type": "rotating-file"
          , "path": join(logDirectory, filename)
          , "period": "1d"
          , "count": 3
          }
}