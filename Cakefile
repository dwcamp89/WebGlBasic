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


task 'buildShaders', 'Build shader src into requirejs module shader.js', ->
	console.log 'Copy shader source code to shader module'

	# Read fragment shader into buffer
	fragmentShaderFileName = 'basic.frag'
	try
		fragmentShaderSrcBuffer = fs.readFileSync "lib/shaders/#{fragmentShaderFileName}"
	catch error
		console.log 'No fragment shader found. Using basic.frag instead.'
		fragmentShaderSrcBuffer = fs.readFileSync 'lib/shaders/basic.frag'

	# Get src as string from buffer (replace all line returns)
	fragmentSrc = fragmentShaderSrcBuffer.toString().replace /(\r\n|\r|\n)/g, ''


	# Read vertex shader into buffer
	vertexShaderFileName = 'basic.vert'
	try
		vertexShaderSrcBuffer = fs.readFileSync "lib/shaders/#{vertexShaderFileName}"
	catch error
		console.log 'No vertex shader found. Using basic.vert instead.'
		vertexShaderSrcBuffer = fs.readFileSync 'lib/shaders/basic.vert'

	# Get src as string from buffer (replace all line returns)
	vertexSrc = vertexShaderSrcBuffer.toString().replace /(\r\n|\r|\n)/g, ''

	# Write shader src code into define file (double quotes required to use coffee string replace)
	shaderSrc = "
		define([], function() {
			return {
				fragment : {
					src : '#{fragmentSrc}',
					type : 'FRAGMENT'
				},
				vertex : {
					src : '#{vertexSrc}',
					type : 'VERTEX'
				}
			};
		});
	"

	# Write the shader src to shader.js
	fs.writeFileSync 'lib/shader.js', shaderSrc