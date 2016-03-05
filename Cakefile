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


# Get the shader source code
getShaderSrc = (shaderFileName)->
	# Read the file synchronously
	try
		shaderSrcBuffer = fs.readFileSync "lib/shaders/#{shaderFileName}"
	catch error
		console.log "No shader found by name #{shaderFileName}"

	# Get src as string from buffer (replace all line returns)
	shaderSrcCode = shaderSrcBuffer.toString().replace /(\r\n|\r|\n)/g, ''
	return  shaderSrcCode

buildShaders = ->
	console.log 'buildShaders2'
	shaderSrcMap = {}

	# TODO - determine list dynamically from lib/shaders
	shaderFileNames = [
		'basic.vert', 'basic.frag', 
		'basic2.vert', 'basic2.frag', 
		'texture.vert', 'texture.frag', 
		'light1.vert', 'light1.frag',
		'star.vert', 'star.frag',
		'sphere.vert', 'sphere.frag'
	]

	# Iterate through all shader files, adding the source code to shaderSrcs map object
	shaderSrcMap[shaderFileName] = getShaderSrc(shaderFileName) for shaderFileName in shaderFileNames

	console.log shaderSrcMap
	# Turn shaderSrcs JS object into a string
	shaderSrcsString = JSON.stringify(shaderSrcMap)

	shaderSrcsJs = "
		define(function() {
			return #{shaderSrcsString}
		});
	"


	fs.writeFileSync 'lib/shaderSrcs.js', shaderSrcsJs

	
task 'build', 'Generic build lib/ from src/', ->
	build()

task 'buildShaders', 'Build shader src into requirejs module shaderSrcs.js', ->
	buildShaders()

task 'buildAll', 'Build lib and shaders.', ->
	build()
	buildShaders()

task 'watch', 'Watch for changes and build shaders and lib folder', (callback)->
	coffee = exec 'coffee --watch --compile --output lib src'

	coffee.stderr.on 'data', (data) ->
		process.stderr.write data.toString()
	coffee.stdout.on 'data', (data) ->
		console.log data.toString()