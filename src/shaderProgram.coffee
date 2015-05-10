define ['WebGlConstants', 'gl', 'shader'], (webGlConstants, gl, shader)->

	# Retrieve shader
	getShader = (shaderObj) ->
		newShader = null
		if shaderObj.type == "FRAGMENT"
			newShader = gl.createShader gl.FRAGMENT_SHADER
		else if shaderObj.type == "VERTEX"
			newShader = gl.createShader gl.VERTEX_SHADER
		else
			return null

		gl.shaderSource newShader, shaderObj.src
		gl.compileShader newShader

		if !gl.getShaderParameter newShader, gl.COMPILE_STATUS
			alert gl.getShaderInfoLog newShader
			console.log gl.getShaderInfoLog newShader
			return null

		# return the shader
		newShader
	
	# Get shaders
	fragmentShader = getShader shader.fragment
	vertexShader = getShader shader.vertex
	
	shaderProgram = gl.createProgram()

	gl.attachShader shaderProgram, fragmentShader
	gl.attachShader shaderProgram, vertexShader
	gl.linkProgram shaderProgram
	
	if !gl.getProgramParameter shaderProgram, gl.LINK_STATUS
		console.log webGlConstants.ERROR_MESSAGES.UNABLE_TO_INITIALIZE_SHADERS
		alert webGlConstants.ERROR_MESSAGES.UNABLE_TO_INITIALIZE_SHADERS
	
	# Use the program
	gl.useProgram shaderProgram
	
	# Enable attributes
	shaderProgram.vertexPositionAttribute = gl.getAttribLocation shaderProgram, "aVertexPosition"
	gl.enableVertexAttribArray shaderProgram.vertexPositionAttribute
	
	shaderProgram.vertexColorAttribute = gl.getAttribLocation shaderProgram, "aVertexColor"
	gl.enableVertexAttribArray shaderProgram.vertexColorAttribute

	# Set uniform locations
	shaderProgram.pMatrixUniform = gl.getUniformLocation shaderProgram, "uPMatrix"
	shaderProgram.mvMatrixUniform = gl.getUniformLocation shaderProgram, "uMVMatrix"

	# Return the shader program
	shaderProgram