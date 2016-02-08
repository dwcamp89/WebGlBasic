define ['GLContext', 'ModelViewMatrix', 'PerspectiveMatrix', 'glMatrix-0.9.5.min', 'ShaderProgramFactory'], (glContext, mvMatrix, pMatrix, glMatrix, ShaderProgramFactory)->

	class Pyramid

		# Init handler to gl context
		gl = glContext.getSingleton()

		constructor: ->
			# Init positions
			@x = @y = @z = 0

			# Init rotation positions
			@xRot = @yRot = @zRot = 0

			# Create buffers
			@vertexPositionBuffer = gl.createBuffer()
			@vertexColorBuffer = gl.createBuffer()

			# Get the shader program
			@shaderProgram = ShaderProgramFactory.getInstance('basic2.vert', 'basic2.frag')

			# Enable attributes
			@shaderProgram.vertexPositionAttribute = gl.getAttribLocation @shaderProgram.program, 'aVertexPosition'
			gl.enableVertexAttribArray @shaderProgram.program, @shaderProgram.vertexPositionAttribute

			# Enable vertex color attribute
			@shaderProgram.vertexColorAttribute = gl.getAttribLocation @shaderProgram.program, 'aVertexColor'
			gl.enableVertexAttribArray @shaderProgram.program, @shaderProgram.vertexColorAttribute

			# Get uniform locations
			@shaderProgram.pMatrixUniform = gl.getUniformLocation @shaderProgram.program, 'uPMatrix'
			@shaderProgram.mvMatrixUniform = gl.getUniformLocation @shaderProgram.program, 'uMVMatrix'

		initBuffers: ->
			# Vertex locations
			gl.bindBuffer gl.ARRAY_BUFFER, @vertexPositionBuffer
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
			@vertexPositionBuffer.itemSize = 3
			@vertexPositionBuffer.numberOfItems = 12

			
			# Vertex colors
			gl.bindBuffer gl.ARRAY_BUFFER, @vertexColorBuffer
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
			]
			gl.bufferData gl.ARRAY_BUFFER, new Float32Array(colors), gl.STATIC_DRAW

	        # Set color buffer metadata
			@vertexColorBuffer.itemSize = 4
			@vertexColorBuffer.numberOfItems = 12

		render : ->
			# Use this object's shader program
			gl.useProgram @shaderProgram.program

			mat4.perspective 45, gl.viewportWidth/gl.viewportHeight, 0.1, 100.0, pMatrix

			# Move to location of this object
			mat4.identity mvMatrix
			mat4.translate mvMatrix, [@x, @y, @z]

			# Rotate the object
			mat4.rotate mvMatrix, Math.toRadians(@xRot), [1, 0, 0]
			mat4.rotate mvMatrix, Math.toRadians(@yRot), [0, 1, 0]
			mat4.rotate mvMatrix, Math.toRadians(@zRot), [0, 0, 1]

			# Set pyramid vertices
			gl.bindBuffer gl.ARRAY_BUFFER, @vertexPositionBuffer
			gl.vertexAttribPointer @shaderProgram.vertexPositionAttribute, @vertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0
			
			# Set cube colors
			gl.bindBuffer gl.ARRAY_BUFFER, @vertexColorBuffer
			gl.vertexAttribPointer @shaderProgram.vertexColorAttribute, @vertexColorBuffer.itemSize, gl.FLOAT, false, 0, 0

			# Set matrix uniforms
			gl.uniformMatrix4fv @shaderProgram.pMatrixUniform, false, pMatrix
			gl.uniformMatrix4fv @shaderProgram.mvMatrixUniform, false, mvMatrix

			# Draw cube
			gl.drawArrays gl.TRIANGLES, 0, @vertexPositionBuffer.numberOfItems

	{
		'getInstance' : ()-> 
			return new Pyramid()
	}
