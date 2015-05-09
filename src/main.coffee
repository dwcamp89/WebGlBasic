# Required JS libraries should be "imported" here by adding to the array
require ['glMatrix-0.9.5.min', 'webgl-utils', 'WebGlConstants', 'shader'], (glMatrix, webGlUtils, webGlConstants, shader)->

	# Handle to gl context object
	gl = null

	# Model matrices
	mvMatrix = null
	pMatrix = null
	mvMatrixStack = []

	# Shapes
	triangleVertexPositionBuffer = null
	triangleVertexColorBuffer = null
	rTri = null
	squareVertexPositionBuffer = null
	squareVertexColorBuffer = null
	rSquare = null

	# 3d shapes
	pyramidVertexPositionBuffer = null
	pyramidVertexColorBuffer = null
	rPyramid = 0
	cubeVertexPositionBuffer = null
	cubeVertexColorBuffer = null
	cubeVertexIndexBuffer = null
	rCube = 0

	# Shader program and shaders
	shaderProgram = null
	vertexShader = null
	fragmentShader = null

	mvPushMatrix = ->
		copy = mat4.create()
		mat4.set mvMatrix, copy
		mvMatrixStack.push copy

	mvPopMatrix = ->
		if mvMatrixStack.size == 0
			throw "Invalid Pop Matrix"
		mvMatrix = mvMatrixStack.pop()

	degToRad = (degrees) ->
		return degrees * Math.PI / 180.0


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
		# Init pyramid position buffer
		pyramidVertexPositionBuffer = gl.createBuffer()

		gl.bindBuffer gl.ARRAY_BUFFER, pyramidVertexPositionBuffer
		vertices = [
	        # Front face
	         0.0,  1.0,  0.0
	        -1.0, -1.0,  1.0
	         1.0, -1.0,  1.0
	        # Right face
	         0.0,  1.0,  0.0
	         1.0, -1.0,  1.0
	         1.0, -1.0, -1.0
	        # Back face
	         0.0,  1.0,  0.0
	         1.0, -1.0, -1.0
	        -1.0, -1.0, -1.0
	        # Left face
	         0.0,  1.0,  0.0
	        -1.0, -1.0, -1.0
	        -1.0, -1.0,  1.0
	    ]
		gl.bufferData gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW

		# Set buffer metadata
		pyramidVertexPositionBuffer.itemSize = 3
		pyramidVertexPositionBuffer.numberOfItems = 12

		# Set pyramid color buffer
		pyramidVertexColorBuffer = gl.createBuffer()
		gl.bindBuffer gl.ARRAY_BUFFER, pyramidVertexColorBuffer
		colors = [
	        # Front face
	        1.0, 0.0, 0.0, 1.0
	        0.0, 1.0, 0.0, 1.0
	        0.0, 0.0, 1.0, 1.0
	        # Right face
	        1.0, 0.0, 0.0, 1.0
	        0.0, 0.0, 1.0, 1.0
	        0.0, 1.0, 0.0, 1.0
	        # Back face
	        1.0, 0.0, 0.0, 1.0
	        0.0, 1.0, 0.0, 1.0
	        0.0, 0.0, 1.0, 1.0
	        # Left face
	        1.0, 0.0, 0.0, 1.0
	        0.0, 0.0, 1.0, 1.0
	        0.0, 1.0, 0.0, 1.0
	    ];
		gl.bufferData gl.ARRAY_BUFFER, new Float32Array(colors), gl.STATIC_DRAW

		# Set buffer metadata
		pyramidVertexColorBuffer.itemSize = 4
		pyramidVertexColorBuffer.numberOfItems = 12


		# Cube vertices
		cubeVertexPositionBuffer = gl.createBuffer()
		gl.bindBuffer gl.ARRAY_BUFFER, cubeVertexPositionBuffer
		vertices = [
	      # Front face
	      -1.0, -1.0,  1.0
	       1.0, -1.0,  1.0
	       1.0,  1.0,  1.0
	      -1.0,  1.0,  1.0

	      # Back face
	      -1.0, -1.0, -1.0
	      -1.0,  1.0, -1.0
	       1.0,  1.0, -1.0
	       1.0, -1.0, -1.0

	      # Top face
	      -1.0,  1.0, -1.0
	      -1.0,  1.0,  1.0
	       1.0,  1.0,  1.0
	       1.0,  1.0, -1.0

	      # Bottom face
	      -1.0, -1.0, -1.0
	       1.0, -1.0, -1.0
	       1.0, -1.0,  1.0
	      -1.0, -1.0,  1.0

	      # Right face
	       1.0, -1.0, -1.0
	       1.0,  1.0, -1.0
	       1.0,  1.0,  1.0
	       1.0, -1.0,  1.0

	      # Left face
	      -1.0, -1.0, -1.0
	      -1.0, -1.0,  1.0
	      -1.0,  1.0,  1.0
	      -1.0,  1.0, -1.0
	    ];
		gl.bufferData gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW
		
		# Set buffer metadata
		cubeVertexPositionBuffer.itemSize = 3
		cubeVertexPositionBuffer.numberOfItems = 24


		# Set cube color
		cubeVertexColorBuffer = gl.createBuffer()
		gl.bindBuffer gl.ARRAY_BUFFER, cubeVertexColorBuffer
		colors = [
			[1.0, 0.0, 0.0, 1.0]     # Front face
			[1.0, 1.0, 0.0, 1.0]     # Back face
			[0.0, 1.0, 0.0, 1.0]     # Top face
			[1.0, 0.5, 0.5, 1.0]     # Bottom face
			[1.0, 0.0, 1.0, 1.0]     # Right face
			[0.0, 0.0, 1.0, 1.0]     # Left face
		]

		# unpack colors
		unpackedColors = []
		for colorList in colors
			for j in [0, 1, 2, 3]
				unpackedColors = unpackedColors.concat colorList

		gl.bufferData gl.ARRAY_BUFFER, new Float32Array(unpackedColors), gl.STATIC_DRAW

		# Set buffer metadata
		cubeVertexColorBuffer.itemSize = 4
		cubeVertexColorBuffer.numberOfItems = 24

		# Cube indeces
		cubeVertexIndexBuffer = gl.createBuffer()
		gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, cubeVertexIndexBuffer

		vertices = [
			0, 1, 2,      0, 2, 3     # Front face
		    4, 5, 6,      4, 6, 7     # Back face
		    8, 9, 10,     8, 10, 11   # Top face
		    12, 13, 14,   12, 14, 15  # Bottom face
		    16, 17, 18,   16, 18, 19  # Right face
		    20, 21, 22,   20, 22, 23  # Left face
		]
		gl.bufferData gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(vertices), gl.STATIC_DRAW

		# Set buffer metadata
		cubeVertexIndexBuffer.itemSize = 3
		cubeVertexIndexBuffer.numberOfItems = 36

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

		mvPushMatrix()
		mat4.rotate mvMatrix, degToRad(rPyramid), [1, 0, 0]

		# Set pyramid vertices
		gl.bindBuffer gl.ARRAY_BUFFER, pyramidVertexPositionBuffer
		gl.vertexAttribPointer shaderProgram.vertexPositionAttribute, pyramidVertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0
		
		# Set pyramid colors
		gl.bindBuffer gl.ARRAY_BUFFER, pyramidVertexColorBuffer
		gl.vertexAttribPointer shaderProgram.vertexColorAttribute, pyramidVertexColorBuffer.itemSize, gl.FLOAT, false, 0, 0

		# Draw pyramid
		setMatrixUniforms()
		gl.drawArrays gl.TRIANGLES, 0, pyramidVertexPositionBuffer.numberOfItems

		mvPopMatrix()

		# Move camera
		mat4.translate mvMatrix, [3.0, 0.0, 0.0]

		mvPushMatrix()
		mat4.rotate mvMatrix, degToRad(rCube), [1, 1, 1]

		# Set cube vertices
		gl.bindBuffer gl.ARRAY_BUFFER, cubeVertexPositionBuffer
		gl.vertexAttribPointer shaderProgram.vertexPositionAttribute, cubeVertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0
		
		# Set cube colors
		gl.bindBuffer gl.ARRAY_BUFFER, cubeVertexColorBuffer
		gl.vertexAttribPointer shaderProgram.vertexColorAttribute, cubeVertexColorBuffer.itemSize, gl.FLOAT, false, 0, 0

		# Set cube indeces
		gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, cubeVertexIndexBuffer

		# Draw cube
		setMatrixUniforms()
		gl.drawElements gl.TRIANGLES, cubeVertexIndexBuffer.numberOfItems, gl.UNSIGNED_SHORT, 0

		mvPopMatrix()


	# Animate
	lastTime = 0
	animate = ->
		timeNow = new Date().getTime()
		if lastTime != 0
			elapsed = timeNow - lastTime
			rPyramid += 90 * elapsed / 1000.0
			rCube += 90 * elapsed / 1000.0
		lastTime = timeNow


	# Tick for animation
	tick = ->
		requestAnimFrame(tick)
		drawScene()
		animate()

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
		
		#drawScene()
		tick()

	# Entry point
	start()