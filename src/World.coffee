define ['GLContext', 'ModelViewMatrix', 'PerspectiveMatrix', 'glMatrix-0.9.5.min', 'ShaderProgramFactory'], (glContext, mvMatrix, pMatrix, glMatrix, ShaderProgramFactory)->

	# Constants
	POSITION_X_VALUE = 0
	POSITION_Y_VALUE = 1
	POSITION_Z_VALUE = 2
	TEXTURE_X_VALUE = 3
	TEXTURE_Y_VALUE = 4

	gl = glContext.getSingleton()

	class World
		constructor : ->
			@pitch = 0
			@deltaPitch = 0
			@yaw = 0
			@deltaYaw = 0
			@x = 0
			@y = 0.4
			@z = 0
			@speed = 0
			@readyToRender = false

			@worldVertexPositionBuffer = gl.createBuffer()
			@worldVertexTextureCoordinateBuffer = gl.createBuffer()

			@initializeShader()

			@texture = gl.createTexture()
			@loadTexture()

		initializeShader : ->
			@shaderProgram = ShaderProgramFactory.getInstance 'texture.vert', 'texture.frag'

			@shaderProgram.textureCoordinateAttribute = gl.getAttribLocation @shaderProgram.program, 'aTextureCoord'
			gl.enableVertexAttribArray @shaderProgram.textureCoordinateAttribute

			@shaderProgram.vertexPositionAttribute = gl.getAttribLocation @shaderProgram.program, 'aVertexPosition'
			gl.enableVertexAttribArray @shaderProgram.vertexPositionAttribute

			@shaderProgram.samplerUniform = gl.getUniformLocation @shaderProgram.program, 'uSampler'
			@shaderProgram.pMatrixUniform = gl.getUniformLocation @shaderProgram.program, 'uPMatrix'
			@shaderProgram.mvMatrixUniform = gl.getUniformLocation @shaderProgram.program, 'uMVMatrix'

		loadTexture : ->
			@texture.image = new Image()
			@texture.image.onload = ()=>
				handleLoadedTexture @texture
			@texture.image.src = 'images/mud.gif'

		handleLoadedTexture = (texture)->
			gl.pixelStorei gl.UNPACK_FLIP_Y_WEBGL, true
			gl.bindTexture gl.TEXTURE_2D, texture
			gl.texImage2D gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, texture.image
			gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR
			gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR
			gl.bindTexture gl.TEXTURE_2D, null

		loadWorld : ->
			getWorldRequest = new XMLHttpRequest()
			getWorldRequest.open 'GET', 'world.txt'
			getWorldRequest.onreadystatechange =()=>
				if getWorldRequest.readyState == 4
					@handleLoadedWorld(getWorldRequest.responseText)
			getWorldRequest.send()

		handleLoadedWorld : (worldVertexText)->
			worldVertexStrings = worldVertexText.split "\n"
			vertexCount = 0
			vertexPositions = []
			vertexTextureCoordinates = []

			for i in [0..worldVertexStrings.length]
				vertex = parseVertexStringToVertex worldVertexStrings[i]
				if vertex.length >= 5 && vertex[POSITION_X_VALUE] != "//"
					vertexPositions.push parseFloat(vertex[POSITION_X_VALUE])
					vertexPositions.push parseFloat(vertex[POSITION_Y_VALUE])
					vertexPositions.push parseFloat(vertex[POSITION_Z_VALUE])

					vertexTextureCoordinates.push parseFloat(vertex[TEXTURE_X_VALUE])
					vertexTextureCoordinates.push parseFloat(vertex[TEXTURE_Y_VALUE])

					vertexCount += 1

			gl.bindBuffer gl.ARRAY_BUFFER, @worldVertexPositionBuffer
			gl.bufferData gl.ARRAY_BUFFER, new Float32Array(vertexPositions), gl.STATIC_DRAW
			@worldVertexPositionBuffer.itemSize = 3
			@worldVertexPositionBuffer.numberOfItems = vertexCount

			gl.bindBuffer gl.ARRAY_BUFFER, @worldVertexTextureCoordinateBuffer
			gl.bufferData gl.ARRAY_BUFFER, new Float32Array(vertexTextureCoordinates), gl.STATIC_DRAW
			@worldVertexTextureCoordinateBuffer.itemSize = 2
			@worldVertexTextureCoordinateBuffer.numberOfItems = vertexCount

			@readyToRender = true

			document.getElementById("loadingText").textContent = ""

		parseVertexStringToVertex = (vertexLine) ->
			if !vertexLine? then return []
			vertexLine.replace(/^\s+/, "").split(/\s+/)

		isReadyToRender : =>
			@readyToRender

		render : =>
			if not @isReadyToRender()
				return

			gl.useProgram @shaderProgram.program

			gl.enable gl.DEPTH_TEST

			mat4.rotate mvMatrix, Math.toRadians(-@pitch), [1, 0, 0]
			mat4.rotate mvMatrix, Math.toRadians(-@yaw), [0, 1, 0]
			mat4.translate mvMatrix, [-@x, -@y, -@z]

			gl.activeTexture gl.TEXTURE0
			gl.bindTexture gl.TEXTURE_2D, @texture
			gl.uniform1i @shaderProgram.samplerUniform, 0

			gl.bindBuffer gl.ARRAY_BUFFER, @worldVertexTextureCoordinateBuffer
			gl.vertexAttribPointer @shaderProgram.textureCoordinateAttribute, @worldVertexTextureCoordinateBuffer.itemSize, gl.FLOAT, false, 0, 0

			gl.bindBuffer gl.ARRAY_BUFFER, @worldVertexPositionBuffer
			gl.vertexAttribPointer @shaderProgram.vertexPositionAttribute, @worldVertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0

			@setMatrixUniforms()

			gl.drawArrays gl.TRIANGLES, 0, @worldVertexPositionBuffer.numberOfItems

		setMatrixUniforms : ()=>
			gl.uniformMatrix4fv @shaderProgram.pMatrixUniform, false, pMatrix
			gl.uniformMatrix4fv @shaderProgram.mvMatrixUniform, false, mvMatrix
			
		animate : (timeElapsed)->
			@yaw += @deltaYaw
			@pitch += @deltaPitch

			if @speed == 0
				return
			@x -= ( Math.sin ( Math.toRadians(@yaw) ) ) * @speed * timeElapsed
			@z -= ( Math.cos ( Math.toRadians(@yaw) ) ) * @speed * timeElapsed

	# TODO - perhaps this should be a singleton?
	{
		getInstance : ->
			return new World()
	}