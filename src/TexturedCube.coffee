define ['GLContext', 'ModelViewMatrix', 'PerspectiveMatrix', 'glMatrix-0.9.5.min', 'ShaderProgramFactory'], (glContext, mvMatrix, pMatrix, glMatrix, ShaderProgramFactory)->

	class TexturedCube

		# Init handler to gl context
		gl = glContext.getSingleton()

		###
			gl.NEAREST 					# 9728
			gl.LINEAR 					# 9729
			gl.NEAREST_MIPMAP_NEAREST 	# 9984
			gl.LINEAR_MIPMAP_NEAREST 	# 9985
			gl.NEAREST_MIPMAP_LINEAR 	# 9986
			gl.LINEAR_MIPMAP_LINEAR 	# 9987
		###

		# List of minification filters
		MIN_FILTERS = [gl.NEAREST, gl.LINEAR, gl.NEAREST_MIPMAP_NEAREST, gl.LINEAR_MIPMAP_NEAREST, gl.NEAREST_MIPMAP_LINEAR, gl.LINEAR_MIPMAP_LINEAR]

		# List of magnification filters
		MAG_FILTERS = [gl.NEAREST, gl.LINEAR]

		constructor: ->
			# Init positions
			@x = @y = @z = 0

			# Init rotation positions
			@xRot = @yRot = @zRot = 0

			# Init rotation speeds
			@xRotSpeed = @yRotSpeed = @zRotSpeed = 10

			# Filter number
			@filter = 0#FILTER_NEAREST
			@minFilter = gl.NEAREST
			@magFilter = gl.NEAREST

			# Create buffers
			@vertexPositionBuffer = gl.createBuffer()
			@vertexIndexBuffer = gl.createBuffer()
			@vertexTextureCoordBuffer = gl.createBuffer()

			# Get a shader program with the necessary vertex and fragment shaders
			@shaderProgram = ShaderProgramFactory.getInstance 'texture.vert', 'texture.frag'

			# Enable attribute for vertex position
			@shaderProgram.vertexPositionAttribute = gl.getAttribLocation @shaderProgram.program, 'aVertexPosition'
			gl.enableVertexAttribArray @shaderProgram.vertexPositionAttribute

			# Enable attribute for texture coordinates
			@shaderProgram.textureCoordAttribute = gl.getAttribLocation @shaderProgram.program, 'aTextureCoord'
			gl.enableVertexAttribArray @shaderProgram.textureCoordAttribute

			# Get uniform locations
			@shaderProgram.pMatrixUniform = gl.getUniformLocation @shaderProgram.program, 'uPMatrix'
			@shaderProgram.mvMatrixUniform = gl.getUniformLocation @shaderProgram.program, 'uMVMatrix'
			@shaderProgram.samplerUniform = gl.getUniformLocation @shaderProgram.program, 'uSampler'

			# Init crateTextures to empty map
			@crateTextures = {}

			# Init textures
			@initTextures()

		initTextures : ()->
			# Create the image
			crateImage = new Image()

			i = 0
			while i < MAG_FILTERS.length
				@crateTextures[MAG_FILTERS[i]] = {}
				j = 0
				while j < MIN_FILTERS.length
					texture = gl.createTexture()
					texture.image = crateImage
					texture.magFilter = MAG_FILTERS[i]
					texture.minFilter = MIN_FILTERS[j]
					@crateTextures[MAG_FILTERS[i]][MIN_FILTERS[j]] = texture
					j++
				i++

			crateImage.onload = ()=>
				this.handleLoadedTextures()

			crateImage.src = 'images/crate.gif'

		# Private helper method to asynchronously handle texture img after it is loaded into memory
		handleLoadedTextures : ()->
			gl.pixelStorei gl.UNPACK_FLIP_Y_WEBGL, true

			for magFilter, textureList of @crateTextures
				for minFilter, texture of @crateTextures[magFilter]
					gl.bindTexture gl.TEXTURE_2D, texture
					gl.texImage2D gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, texture.image
					gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, texture.magFilter
					gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, texture.minFilter
					if (texture.minFilter != gl.NEAREST && texture.minFilter != gl.LINEAR) 
						gl.generateMipmap gl.TEXTURE_2D

			# Clear the texture in use
			gl.bindTexture gl.TEXTURE_2D, null

		initBuffers: ->
			# Cube vertices
			gl.bindBuffer gl.ARRAY_BUFFER, @vertexPositionBuffer
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
			@vertexPositionBuffer.itemSize = 3
			@vertexPositionBuffer.numberOfItems = 24


			# Set texture coordinates
			gl.bindBuffer gl.ARRAY_BUFFER, @vertexTextureCoordBuffer
			textureCoords = [
				# Front face
				0.0, 0.0,
				1.0, 0.0,
				1.0, 1.0,
				0.0, 1.0,

				# Back face
				1.0, 0.0,
				1.0, 1.0,
				0.0, 1.0,
				0.0, 0.0,

				# Top face
				0.0, 1.0,
				0.0, 0.0,
				1.0, 0.0,
				1.0, 1.0,

				# Bottom face
				1.0, 1.0,
				0.0, 1.0,
				0.0, 0.0,
				1.0, 0.0,

				# Right face
				1.0, 0.0,
				1.0, 1.0,
				0.0, 1.0,
				0.0, 0.0,

				# Left face
				0.0, 0.0,
				1.0, 0.0,
				1.0, 1.0,
				0.0, 1.0,
			]
			
			gl.bufferData gl.ARRAY_BUFFER, new Float32Array(textureCoords), gl.STATIC_DRAW
			@vertexTextureCoordBuffer.itemSize = 2
			@vertexTextureCoordBuffer.numItems = 24


			# Indeces buffer
			gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, @vertexIndexBuffer

			elemVertices = [
				0, 1, 2,      0, 2, 3     # Front face
			    4, 5, 6,      4, 6, 7     # Back face
			    8, 9, 10,     8, 10, 11   # Top face
			    12, 13, 14,   12, 14, 15  # Bottom face
			    16, 17, 18,   16, 18, 19  # Right face
			    20, 21, 22,   20, 22, 23  # Left face
			]
			gl.bufferData gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(elemVertices), gl.STATIC_DRAW

			# Set buffer metadata
			@vertexIndexBuffer.itemSize = 3
			@vertexIndexBuffer.numberOfItems = 36

		render : =>
			# Use this shader program
			gl.useProgram @shaderProgram.program

			# Move to location of this object
			mat4.identity mvMatrix.getMatrix()
			mat4.translate mvMatrix.getMatrix(), [@x, @y, @z]

			# Rotate the object
			mat4.rotate mvMatrix.getMatrix(), Math.toRadians(@xRot), [1, 0, 0]
			mat4.rotate mvMatrix.getMatrix(), Math.toRadians(@yRot), [0, 1, 0]
			mat4.rotate mvMatrix.getMatrix(), Math.toRadians(@zRot), [0, 0, 1]

			# Set cube vertices
			gl.bindBuffer gl.ARRAY_BUFFER, @vertexPositionBuffer
			gl.vertexAttribPointer @shaderProgram.vertexPositionAttribute, @vertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0

			# Setup cube texture coordinate buffer
			gl.bindBuffer gl.ARRAY_BUFFER, @vertexTextureCoordBuffer
			gl.vertexAttribPointer @shaderProgram.textureCoordAttribute, @vertexTextureCoordBuffer.itemSize, gl.FLOAT, false, 0, 0

			# Set texture
			gl.activeTexture gl.TEXTURE0
			gl.bindTexture gl.TEXTURE_2D, @crateTextures[@magFilter][@minFilter]
			gl.uniform1i @shaderProgram.samplerUniform, 0

			# Set cube indeces
			gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, @vertexIndexBuffer

			# Set matrix uniforms
			gl.uniformMatrix4fv @shaderProgram.pMatrixUniform, false, pMatrix
			gl.uniformMatrix4fv @shaderProgram.mvMatrixUniform, false, mvMatrix.getMatrix()

			# Draw cube
			gl.drawElements gl.TRIANGLES, @vertexIndexBuffer.numberOfItems, gl.UNSIGNED_SHORT, 0

		animate : =>
			# do nothing

		setMinFilter : (minFilter) ->
			@minFilter = minFilter

		setMagFilter : (magFilter) ->
			@magFilter = magFilter

	{
		'getInstance' : ()-> 
			return new TexturedCube()
	}
