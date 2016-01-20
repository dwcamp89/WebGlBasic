define ['GLContext', 'shaderSrcs'], (glContext, shaderSrcs)->

	# Init handler to gl context
	gl = glContext.getSingleton()

	getInstance = (vertexShaderName, fragmentShaderName)->
		# Initialize the shaders and program
		vertexShader = gl.createShader gl.VERTEX_SHADER
		vertexShader.compileSuccess = false
		fragmentShader = gl.createShader gl.FRAGMENT_SHADER
		fragmentShader.compileSuccess = false
		shaderProgram = gl.createProgram()
		shaderProgram.linkSuccess = false

		# Collect the shaders and program into the object to be returned
		programInstance = {
			'vertexShader' : vertexShader
			'fragmentShader' : fragmentShader
			'program' : shaderProgram
		}

		# Set and compile vertes shader source code
		vertexShaderSrc = shaderSrcs[vertexShaderName]
		gl.shaderSource vertexShader, vertexShaderSrc
		gl.compileShader vertexShader

		# Check the compile status of the vertex shader
		if !gl.getShaderParameter vertexShader, gl.COMPILE_STATUS
			console.log "Unable to compile vertex shader #{vertexShaderName}."
			console.log gl.getShaderInfoLog vertexShader
			return programInstance

		# Set the vertex shader's compile success to true
		vertexShader.compileSuccess = true

		# Set and compile fragment shader source code
		fragmentShaderSrc = shaderSrcs[fragmentShaderName]
		gl.shaderSource fragmentShader, fragmentShaderSrc
		gl.compileShader fragmentShader

		# Set the fragment shader's compiel success to true
		fragmentShader.compileSuccess = true

		# Check the compile status of the fragment shader
		if !gl.getShaderParameter fragmentShader, gl.COMPILE_STATUS
			console.log gl.getShaderParameter fragmentShader, gl.COMPILE_STATUS
			console.log "Unable to compile fragment shader #{fragmentShaderName}."
			console.log gl.getShaderInfoLog fragmentShader
			return programInstance

		gl.attachShader shaderProgram, vertexShader
		gl.attachShader shaderProgram, fragmentShader
		gl.linkProgram shaderProgram

		# Check the link status of the program
		if !gl.getProgramParameter shaderProgram, gl.LINK_STATUS
			console.log "Unable to link shader program with #{vertexShaderName} and #{fragmentShaderName}."
			return programInstance

		shaderProgram.linkSuccess = true

		return programInstance

	console 

	# Return an object with getInstance method
	return {
		'getInstance' : getInstance
	}
