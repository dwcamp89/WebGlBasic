define ['GLContext', 'ModelViewMatrix', 'PerspectiveMatrix', 'glMatrix-0.9.5.min', 'ShaderProgramFactory'], (glContext, mvMatrix, pMatrix, glMatrix, ShaderProgramFactory)->

	# Singleton handler to the shader program using star shaders
	shaderProgram = ShaderProgramFactory.getInstance 'star.vert', 'star.frag'

	twinkle = false

	# Definition of Star class
	class Star

		# Init handler to gl context
		gl = glContext.getSingleton()

		constructor : ->
			@angle = 0 # angle about y-axis
			@distance = 0
			@rotationSpeed = 0
			@tilt = 90
			@spin = 0 # angle about the z-axis
			@zoom = -15

			# Declare buffers
			@starVertexTextureCoordinateBuffer = gl.createBuffer()
			@starVertexPositionBuffer = gl.createBuffer()

			# Init shader program attributes
			shaderProgram.vertexPositionBuffer = gl.getAttribLocation shaderProgram.program, 'aVertexPosition'
			gl.enableVertexAttribArray shaderProgram.vertexPositionBuffer

			shaderProgram.textureCoordAttribute = gl.getAttribLocation shaderProgram.program, 'aTextureCoord'
			gl.enableVertexAttribArray shaderProgram.textureCoordAttribute

			# Init shader program uniforms
			shaderProgram.pMatrixUniform = gl.getUniformLocation shaderProgram.program, 'uPMatrix'
			shaderProgram.mvMatrixUniform = gl.getUniformLocation shaderProgram.program, 'uMVMatrix'
			shaderProgram.samplerUniform = gl.getUniformLocation shaderProgram.program, 'uSampler'
			shaderProgram.colorUniform = gl.getUniformLocation shaderProgram.program, 'uColor'

			# Initialize the star texture
			@starTexture = gl.createTexture()
			@starTexture.image = new Image()
			@starTexture.image.onload = ()=>
				this.handleLoadedTexture()
			@starTexture.image.src = 'images/Star.gif'

			# Initialize random color
			this.randomizeColors()

		# Asynchronous function to load star texture
		handleLoadedTexture : ()->
			gl.pixelStorei gl.UNPACK_FLIP_Y_WEBGL, true
			gl.bindTexture gl.TEXTURE_2D, @starTexture
			gl.texImage2D gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, this.starTexture.image

			# Use linear filtering
			gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR
			gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR

			# Unbind texture2d
			gl.bindTexture gl.TEXTURE_2D, null

		initBuffers : ->
			gl.bindBuffer gl.ARRAY_BUFFER, @starVertexPositionBuffer
			vertices = [
				-1.0, -1.0, 0.0
				1.0, -1.0, 0.0
				-1.0, 1.0, 0.0
				1.0, 1.0, 0.0
			]
			gl.bufferData gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW
			@starVertexPositionBuffer.itemSize = 3
			@starVertexPositionBuffer.numberOfItems = 4

			gl.bindBuffer gl.ARRAY_BUFFER, @starVertexTextureCoordinateBuffer
			textureCoordinates = [
				0.0, 0.0
				1.0, 0.0
				0.0, 1.0
				1.0, 1.0
			]
			gl.bufferData gl.ARRAY_BUFFER, new Float32Array(textureCoordinates), gl.STATIC_DRAW
			@starVertexTextureCoordinateBuffer.itemSize = 2
			@starVertexTextureCoordinateBuffer.numberOfItems = 4


		# Function to update position and angles
		animate : (elapsedTime)=>
			# do nothing

		render : =>
			gl.enable gl.BLEND
			gl.blendFunc gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA

			gl.useProgram shaderProgram.program
			mvMatrix.pushMatrix()

			mat4.identity mvMatrix.getMatrix()
			mat4.translate mvMatrix.getMatrix(), [0.0, 0.0, @zoom]
			mat4.rotate mvMatrix.getMatrix(), Math.toRadians(@tilt), [1.0, 0.0, 0.0]

			# Move to postion of this star
			mat4.rotate mvMatrix.getMatrix(), Math.toRadians(@angle), [0.0, 1.0, 0.0]
			mat4.translate mvMatrix.getMatrix(), [@distance, 0.0, 0.0]

			# Rotate back to face the viewer/camer
			mat4.rotate mvMatrix.getMatrix(), Math.toRadians(@angle * -1.0), [0.0, 1.0, 0.0]
			mat4.rotate mvMatrix.getMatrix(), Math.toRadians(@tilt * -1.0), [1.0, 0.0, 0.0]

			# Draw star in twinkle color
			if twinkle
				gl.uniform3f shaderProgram.colorUniform, @twinkleR, @twinkleG, @twinkleB
				@drawStar()

			# Rotate about z-axis
			mat4.rotate mvMatrix.getMatrix(), Math.toRadians(@spin), [0.0, 0.0, 1.0]

			# Draw star in main color
			gl.uniform3f shaderProgram.colorUniform, @r, @g, @b
			@drawStar()

			mvMatrix.popMatrix()

		# Set RGB values each to random
		randomizeColors : ()->
			@r = Math.random()
			@g = Math.random()
			@b = Math.random()

			# Twinkle colors here
			@twinkleR = Math.random()
			@twinkleG = Math.random()
			@twinkleB = Math.random()

		drawStar : ()=>
			# Activate and bind star texture
			gl.activeTexture gl.TEXTURE0
			gl.bindTexture gl.TEXTURE_2D, @starTexture
			gl.uniform1i shaderProgram.samplerUniform, 0

			gl.bindBuffer gl.ARRAY_BUFFER, @starVertexTextureCoordinateBuffer
			gl.vertexAttribPointer shaderProgram.textureCoordAttribute, @starVertexTextureCoordinateBuffer.itemSize, gl.FLOAT, false, 0, 0

			gl.bindBuffer gl.ARRAY_BUFFER, @starVertexPositionBuffer
			gl.vertexAttribPointer shaderProgram.vertexPositionBuffer, @starVertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0

			# Set matrix uniforms
			gl.uniformMatrix4fv shaderProgram.pMatrixUniform, false, pMatrix
			gl.uniformMatrix4fv shaderProgram.mvMatrixUniform, false, mvMatrix.getMatrix()

			gl.drawArrays gl.TRIANGLE_STRIP, 0, @starVertexPositionBuffer.numberOfItems

	# Return a module that provides factory method for Star object
	# and setter for class-level twinkle flag
	{
		getInstance : ()-> return new Star()
		setTwinkle : (newTwinkle)->
			twinkle = newTwinkle
	}