module.exports = function(name) {
  return require('bunyan').createLogger({ name: name })
}