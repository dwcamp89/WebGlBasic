define ['gl', 'ModelViewMatrix', 'PerspectiveMatrix', 'glMatrix-0.9.5.min', 'ShaderProgramFactory'], (gl, mvMatrix, pMatrix, glMatrix, ShaderProgramFactory)->

	class Cube

		constructor: ->
			# Init positions
			@x = @y = @z = 0

			# Init rotation positions
			@xRot = @yRot = @zRot = 0

			# Create buffers
			@vertexPositionBuffer = gl.createBuffer()
			@vertexIndexBuffer = gl.createBuffer()
			@vertexTextureCoordBuffer = gl.createBuffer()

			# Initialize texturePPzp
			@texture = gl.createTexture()
			@texture.image = new Image()
			@texture.image.src = "images/nehe.gif"

			# Use => to call onload function to maintain correct context of "this" (=@)
			@texture.image.onload = =>
				handleLoadedTexture @texture

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
			

		# Private helper method to asynchronously handle texture img after it is loaded into memory
		handleLoadedTexture = (texture)->
			# bind the texture to the texture buffer
			gl.bindTexture gl.TEXTURE_2D, texture

			# Tell webGl to flip all textures about the y axis when loaded
			gl.pixelStorei gl.UNPACK_FLIP_Y_WEBGL, true

			# Load the image
			gl.texImage2D gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, texture.image

			# Set the scaling hints (use NEAREST for now since it is fast)
			gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST
			gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST

			# unbind texture buffer
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
			#vertexTextureCoordBuffer = gl.createBuffer() # todo rmv
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

		render : ->
			# Use this shader program
			gl.useProgram @shaderProgram.program

			mat4.perspective 45, gl.viewportWidth/gl.viewportHeight, 0.1, 100.0, pMatrix

			# Move to location of this object
			mat4.identity mvMatrix
			mat4.translate mvMatrix, [@x, @y, @z]

			# Rotate the object
			mat4.rotate mvMatrix, degToRad(@xRot), [1, 0, 0]
			mat4.rotate mvMatrix, degToRad(@yRot), [0, 1, 0]
			mat4.rotate mvMatrix, degToRad(@zRot), [0, 0, 1]

			# Set cube vertices
			gl.bindBuffer gl.ARRAY_BUFFER, @vertexPositionBuffer
			gl.vertexAttribPointer @shaderProgram.vertexPositionAttribute, @vertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0

			# Setup cube texture coordinate buffer
			gl.bindBuffer gl.ARRAY_BUFFER, @vertexTextureCoordBuffer
			gl.vertexAttribPointer @shaderProgram.textureCoordAttribute, @vertexTextureCoordBuffer.itemSize, gl.FLOAT, false, 0, 0

			# Set texture
			gl.activeTexture gl.TEXTURE0
			gl.bindTexture gl.TEXTURE_2D, @texture
			gl.uniform1i @shaderProgram.samplerUniform, 0

			# Set cube indeces
			gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, @vertexIndexBuffer

			# Set matrix uniforms
			gl.uniformMatrix4fv @shaderProgram.pMatrixUniform, false, pMatrix
			gl.uniformMatrix4fv @shaderProgram.mvMatrixUniform, false, mvMatrix

			# Draw cube
			gl.drawElements gl.TRIANGLES, @vertexIndexBuffer.numberOfItems, gl.UNSIGNED_SHORT, 0
			

		# Helper method to convert degrees to radians
		# todo consider moving to some other class/module
		degToRad = (degrees) ->
			degrees * Math.PI / 180.0

	{
		'getInstance' : ()-> 
			return new Cube()
	}
