define ['GLContext', 'ModelViewMatrix', 'PerspectiveMatrix', 'glMatrix-0.9.5.min', 'ShaderProgramFactory'], (glContext, mvMatrix, pMatrix, glMatrix, ShaderProgramFactory)->

	# Cube that includes information for lighting
	class IlluminatedCube

		# Init handler to gl context
		gl = glContext.getSingleton()

		constructor: ->
			# Init positions
			@x = @y = @z = 0

			# Init rotation positions
			@xRot = @yRot = @zRot = 0

			# Init rotation speeds
			@xRotSpeed = @yRotSpeed = @zRotSpeed = 10

			# Init light directions
			@lightDirectionX = @lightDirectionY = -0.25
			@lightDirectionZ = -1.0

			# Init lighting flag
			@useLighting = true

			# Init blending flag
			@useBlending = false

			# Init alpha value
			@alpha = 1.0

			# Init light colors
			@ambientColor = [1.0, 1.0, 1.0]
			@directionalColor = [0.75, 0.5, 0.0]

			# Create buffers
			@vertexPositionBuffer = gl.createBuffer()
			@vertexIndexBuffer = gl.createBuffer()
			@vertexTextureCoordBuffer = gl.createBuffer()
			@vertexNormalBuffer = gl.createBuffer()

			# Get a shader program with the necessary vertex and fragment shaders
			@shaderProgram = ShaderProgramFactory.getInstance 'light1.vert', 'light1.frag'

			# Enable attribute for vertex position
			@shaderProgram.vertexPositionAttribute = gl.getAttribLocation @shaderProgram.program, 'aVertexPosition'
			gl.enableVertexAttribArray @shaderProgram.vertexPositionAttribute

			# Enable attribute for vertex normal
			@shaderProgram.vertexNormalAttribute = gl.getAttribLocation @shaderProgram.program, 'aVertexNormal'
			gl.enableVertexAttribArray @shaderProgram.vertexNormalAttribute

			# Enable attribute for texture coordinates
			@shaderProgram.textureCoordAttribute = gl.getAttribLocation @shaderProgram.program, 'aTextureCoord'
			gl.enableVertexAttribArray @shaderProgram.textureCoordAttribute

			# Get uniform locations
			@shaderProgram.pMatrixUniform = gl.getUniformLocation @shaderProgram.program, 'uPMatrix'
			@shaderProgram.mvMatrixUniform = gl.getUniformLocation @shaderProgram.program, 'uMVMatrix'
			@shaderProgram.samplerUniform = gl.getUniformLocation @shaderProgram.program, 'uSampler'
			@shaderProgram.useLightingUniform = gl.getUniformLocation @shaderProgram.program, 'uUseLighting'
			@shaderProgram.lightingDirectionUniform = gl.getUniformLocation @shaderProgram.program, 'uLightingDirection'
			@shaderProgram.directionLightingColorUniform = gl.getUniformLocation @shaderProgram.program, 'uDirectionalLightingColor'
			@shaderProgram.normalMatrixUniform = gl.getUniformLocation @shaderProgram.program, 'uNormalMatrix'
			@shaderProgram.ambientColorUniform = gl.getUniformLocation @shaderProgram.program, 'uAmbientColor'
			@shaderProgram.alphaUniform = gl.getUniformLocation @shaderProgram.program, 'uAlpha'

			# Init crateTexture
			@crateTexture = gl.createTexture()
			crateImage = new Image()
			@crateTexture.image = crateImage
			crateImage.onload = ()=>
				handleLoadedTexture(@crateTexture)
			crateImage.src = 'images/glass.gif'

		# Private helper method to asynchronously handle texture img after it is loaded into memory
		handleLoadedTexture = (texture)->
			gl.pixelStorei gl.UNPACK_FLIP_Y_WEBGL, true

			# 3rd image uses mipmapping for min filter
			gl.bindTexture gl.TEXTURE_2D, texture
			gl.texImage2D gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, texture.image
			gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR
			gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_NEAREST
			gl.generateMipmap gl.TEXTURE_2D

			# Unbind the texture
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


			# Normals buffer
			gl.bindBuffer gl.ARRAY_BUFFER, @vertexNormalBuffer

			vertexNormals = [
				# Front face
				0.0, 0.0, 1.0
				0.0, 0.0, 1.0
				0.0, 0.0, 1.0
				0.0, 0.0, 1.0

				# Back face
				0.0, 0.0, -1.0
				0.0, 0.0, -1.0
				0.0, 0.0, -1.0
				0.0, 0.0, -1.0

				# Top face
				0.0, 1.0, 0.0
				0.0, 1.0, 0.0
				0.0, 1.0, 0.0
				0.0, 1.0, 0.0

				# Bottom face
				0.0, -1.0, 0.0
				0.0, -1.0, 0.0
				0.0, -1.0, 0.0
				0.0, -1.0, 0.0

				# Right face
				1.0, 0.0, 0.0
				1.0, 0.0, 0.0
				1.0, 0.0, 0.0
				1.0, 0.0, 0.0

				# Left face
				-1.0, 0.0, 0.0
				-1.0, 0.0, 0.0
				-1.0, 0.0, 0.0
				-1.0, 0.0, 0.0
			]
			gl.bufferData gl.ARRAY_BUFFER, new Float32Array(vertexNormals), gl.STATIC_DRAW

			@vertexNormalBuffer.itemSize = 3
			@vertexNormalBuffer.numberOfItems = 24

		render : =>
			# Use this shader program
			gl.useProgram @shaderProgram.program

			mat4.perspective 45, gl.viewportWidth/gl.viewportHeight, 0.1, 100.0, pMatrix

			# Move to location of this object
			mat4.identity mvMatrix
			mat4.translate mvMatrix, [@x, @y, @z]

			# Rotate the object
			mat4.rotate mvMatrix, Math.toRadians(@xRot), [1, 0, 0]
			mat4.rotate mvMatrix, Math.toRadians(@yRot), [0, 1, 0]
			mat4.rotate mvMatrix, Math.toRadians(@zRot), [0, 0, 1]

			# Set cube vertices
			gl.bindBuffer gl.ARRAY_BUFFER, @vertexPositionBuffer
			gl.vertexAttribPointer @shaderProgram.vertexPositionAttribute, @vertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0

			# Setup cube texture coordinate buffer
			gl.bindBuffer gl.ARRAY_BUFFER, @vertexTextureCoordBuffer
			gl.vertexAttribPointer @shaderProgram.textureCoordAttribute, @vertexTextureCoordBuffer.itemSize, gl.FLOAT, false, 0, 0

			# Pass the cube normals
			gl.bindBuffer gl.ARRAY_BUFFER, @vertexNormalBuffer
			gl.vertexAttribPointer @shaderProgram.vertexNormalAttribute, @vertexNormalBuffer.itemSize, gl.FLOAT, false, 0, 0

			# Set lighting flag
			gl.uniform1i @shaderProgram.useLightingUniform, @useLighting

			# Set alpha
			gl.uniform1f @shaderProgram.alphaUniform, @alpha

			# Set blending
			if(@useBlending)
				gl.disable gl.DEPTH_TEST
				gl.enable gl.BLEND
				gl.blendFunc gl.SRC_ALPHA, gl.ONE # Blend function
			else
				gl.disable gl.BLEND
				gl.enable gl.DEPTH_TEST

			# If using lighting, pass the ambient color uniform and lighting direction to the shaders
			if(@useLighting)
				gl.uniform3f @shaderProgram.ambientColorUniform, @ambientColor[0], @ambientColor[1], @ambientColor[2]

				# Assemble lighting direction into a normalized 3d vector and pass to shaders uniform
				lightingDirection = [@lightDirectionX, @lightDirectionY, @lightDirectionZ]
				normalLightDirection = vec3.create()
				vec3.normalize lightingDirection, normalLightDirection # Normalize lightingDirection and pass the result into adjustedLightingDirection vector
				vec3.scale normalLightDirection, -1 # Multiply by -1
				gl.uniform3fv @shaderProgram.lightingDirectionUniform, normalLightDirection

				# Pass the directional light color to the shader
				gl.uniform3f @shaderProgram.directionLightingColorUniform, @directionalColor[0], @directionalColor[1], @directionalColor[2]

				# Pass to the shader the matrix used to transform the vertex normals
				normalMatrix = mat3.create()
				mat4.toInverseMat3 mvMatrix, normalMatrix
				mat3.transpose normalMatrix
				gl.uniformMatrix3fv @shaderProgram.normalMatrixUniform, false, normalMatrix

			# Set texture
			gl.activeTexture gl.TEXTURE0
			gl.bindTexture gl.TEXTURE_2D, @crateTexture
			gl.uniform1i @shaderProgram.samplerUniform, 0

			# Set cube indeces
			gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, @vertexIndexBuffer

			# Set matrix uniforms
			gl.uniformMatrix4fv @shaderProgram.pMatrixUniform, false, pMatrix
			gl.uniformMatrix4fv @shaderProgram.mvMatrixUniform, false, mvMatrix

			# Draw cube
			gl.drawElements gl.TRIANGLES, @vertexIndexBuffer.numberOfItems, gl.UNSIGNED_SHORT, 0

	{
		'getInstance' : ()-> 
			return new IlluminatedCube()
	}
