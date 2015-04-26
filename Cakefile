fs = require 'fs'

{print} = require 'sys'
{spawn, exec} = require 'child_process' # Use exec instead of spawn on Windows

build = (callback) ->
	
	# Use exec instead of spawn on Windows, put options directly in command
	# coffee = spawn 'coffee', ['-c', '-o', 'lib', 'src']
	# coffee = exec 'coffee', ['--compile', '--output', 'lib', 'src']
	coffee = exec 'coffee --compile --output lib src'
	
	coffee.stderr.on 'data', (data) ->
		process.stderr.write data.toString()
		process.exit()
	coffee.stdout.on 'data', (data) ->
		console.log data.toString()
		process.exit()
	coffee.on 'exit', (code) ->
		callback?() if code is 0
	
task 'build', 'Generic build lib/ from src/', ->
	build()