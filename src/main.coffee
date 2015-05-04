# Required JS libraries should be "imported" here by adding to the array
require ['glMatrix-0.9.5.min', 'webgl-utils', 'WebGlConstants', 'shader'], (glMatrix, webGlUtils, webGlConstants, shader)->

	# Handle to gl context object
	gl = null

	# Model matrices
	mvMatrix = null
	pMatrix = null

	# Shapes
	triangleVertexPositionBuffer = null
	triangleVertexColorBuffer = null
	squareVertexPositionBuffer = null
	squareVertexColorBuffer = null

	# Shader program and shaders
	shaderProgram = null
	vertexShader = null
	fragmentShader = null

	# Helper method to initialize GL object
	initWebGL = (canvas) ->
		try
			gl = canvas.getContext webGlConstants.WEB_GL_CONTEXT_NAME
			gl = gl ? (canvas.getContext webGlConstants.EXPERIMENTAL_WEB_GL_CONTEXT_NAME)
			gl.viewportWidth = canvas.width
			gl.viewportHeight = canvas.height
		catch error
			console.log 'error initializing webgl'
			console.log e.message
		
		# If gl was not successfully initialized, give up
		if !gl
			alert 'Unable to initialize WebGL. Your browser may not support it.'
			gl = null;
		
		# Return the gl object
		gl

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

	# Helper method to init shader programs
	initPrograms = ->
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
		
		# 
		shaderProgram.vertexPositionAttribute = gl.getAttribLocation shaderProgram, "aVertexPosition"
		gl.enableVertexAttribArray shaderProgram.vertexPositionAttribute
		
		shaderProgram.vertexColorAttribute = gl.getAttribLocation shaderProgram, "aVertexColor"
		gl.enableVertexAttribArray shaderProgram.vertexColorAttribute

		shaderProgram.pMatrixUniform = gl.getUniformLocation shaderProgram, "uPMatrix"
		shaderProgram.mvMatrixUniform = gl.getUniformLocation shaderProgram, "uMVMatrix"

	# Helper method to initialize shape buffers
	initBuffers = ->
		# Init triangle
		triangleVertexPositionBuffer = gl.createBuffer()

		gl.bindBuffer gl.ARRAY_BUFFER, triangleVertexPositionBuffer
		vertices = [
			0.0, 1.0, 0.0
			-1.0, -1.0, 0.0
			1.0, -1.0, 0.0
		]
		gl.bufferData gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW

		
		# Set vertices metadata
		triangleVertexPositionBuffer.itemSize = 3
		triangleVertexPositionBuffer.numberOfItems = 3

		# Set triangle color
		triangleVertexColorBuffer = gl.createBuffer()
		gl.bindBuffer gl.ARRAY_BUFFER, triangleVertexColorBuffer
		colors = [
			1.0, 0.0, 0.0, 1.0
			0.0, 1.0, 0.0, 1.0
			0.0, 0.0, 1.0, 1.0
		]

		gl.bufferData gl.ARRAY_BUFFER, new Float32Array(colors), gl.STATIC_DRAW
		triangleVertexColorBuffer.itemSize = 4
		triangleVertexColorBuffer.numberOfItems = 3
		
		squareVertexPositionBuffer = gl.createBuffer()
		gl.bindBuffer gl.ARRAY_BUFFER, squareVertexPositionBuffer
		vertices = [
			1.0,  1.0,  0.0
			-1.0,  1.0,  0.0
			1.0, -1.0,  0.0
			-1.0, -1.0,  0.0
		]
		
		gl.bufferData gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW
		
		squareVertexPositionBuffer.itemSize = 3
		squareVertexPositionBuffer.numberOfItems = 4

		# Set square color
		squareVertexColorBuffer = gl.createBuffer()
		gl.bindBuffer gl.ARRAY_BUFFER, squareVertexColorBuffer

		colors = [
			0.5, 0.5, 1.0, 0.5
			0.5, 0.5, 1.0, 1.0
			0.5, 0.5, 1.0, 1.0
			0.5, 0.5, 1.0, 1.0
		]

		gl.bufferData gl.ARRAY_BUFFER, new Float32Array(colors), gl.STATIC_DRAW
		squareVertexColorBuffer.itemSize = 4
		squareVertexColorBuffer.numberOfItems = 4

	setMatrixUniforms = ->
		gl.uniformMatrix4fv shaderProgram.pMatrixUniform, false, pMatrix
		gl.uniformMatrix4fv shaderProgram.mvMatrixUniform, false, mvMatrix

	# Draw the scene
	drawScene = ->
		gl.viewport 0, 0, gl.viewportWidth, gl.viewportHeight
		gl.clear gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT
		
		mat4.perspective 45, gl.viewportWidth/gl.viewportHeight, 0.1, 100.0, pMatrix
		mat4.identity mvMatrix # Move camera to center
		mat4.translate mvMatrix, [-1.5, 0.0, -7.0]

		# Set triangle vertices
		gl.bindBuffer gl.ARRAY_BUFFER, triangleVertexPositionBuffer
		gl.vertexAttribPointer shaderProgram.vertexPositionAttribute, triangleVertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0
		
		# Set triangle colors
		gl.bindBuffer gl.ARRAY_BUFFER, triangleVertexColorBuffer
		gl.vertexAttribPointer shaderProgram.vertexColorAttribute, triangleVertexColorBuffer.itemSize, gl.FLOAT, false, 0, 0

		# Draw triangle
		setMatrixUniforms()
		gl.drawArrays gl.TRIANGLES, 0, triangleVertexPositionBuffer.numberOfItems

		# Move camera
		mat4.translate mvMatrix, [3.0, 0.0, 0.0]

		# Set square vertices
		gl.bindBuffer gl.ARRAY_BUFFER, squareVertexPositionBuffer
		gl.vertexAttribPointer shaderProgram.vertexPositionAttribute, squareVertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0
		
		# Set square colors
		gl.bindBuffer gl.ARRAY_BUFFER, squareVertexColorBuffer
		gl.vertexAttribPointer shaderProgram.vertexColorAttribute, squareVertexColorBuffer.itemSize, gl.FLOAT, false, 0, 0

		# Draw square
		setMatrixUniforms()
		gl.drawArrays gl.TRIANGLE_STRIP, 0, squareVertexPositionBuffer.numberOfItems

	# START
	start = ->
		mvMatrix = mat4.create()
		pMatrix = mat4.create()

		# Get the canvas by ID
		canvas = document.getElementById webGlConstants.CANVAS_ID
		
		gl = initWebGL canvas
		
		initPrograms()
		initBuffers()
		
		# Only continue if gl was initialized
		if gl
			gl.clearColor 0.0, 0.0, 0.0, 1.0
			gl.enable gl.DEPTH_TEST
			gl.depthFunc gl.LEQUAL
			gl.clear gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT
		
		drawScene()

	# Entry point
	start()