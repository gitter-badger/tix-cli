var Q = require('q')
  , exec = require('child_process').exec

module.exports = function bash(command, opts) {
  var deferred = Q.defer()
  opts = opts || {}
  opts.encoding = 'utf-8'
  exec('bash -c "' + command + '"', opts, function (err, stdout, stderr) {
    if (err) deferred.reject(err)
    else deferred.resolve(stdout)
  })
  return deferred.promise;
}
