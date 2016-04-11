define ['GLContext', 'ModelViewMatrix', 'PerspectiveMatrix', 'glMatrix-0.9.5.min', 'ShaderProgramFactory', 'LightFactory'], (glContext, mvMatrix, pMatrix, glMatrix, ShaderProgramFactory, LightFactory)->

	# Constants
	NUMBER_OF_LATITUDE_BANDS = 30
	NUMBER_OF_LONGITUDE_BANDS = 30
	RADIUS = 2

	gl = glContext.getSingleton()

	class Sphere

		constructor : ->
			@x = @y = @z = 0
			
			@useLighting = false

			@ambientLight = LightFactory.getInstance 'AmbientLight'
			@directionalLight = LightFactory.getInstance 'DirectionalLight'
			@pointLight = LightFactory.getInstance 'PointLight'
			@pointLight.setX 0
			@pointLight.setZ -20

			@rotationMatrix = mat4.create()
			mat4.identity @rotationMatrix

			@texture = gl.createTexture()

			@vertexPositionBuffer = gl.createBuffer()
			@vertexTextureCoordinateBuffer = gl.createBuffer()
			@vertexNormalBuffer = gl.createBuffer()
			@vertexIndexBuffer = gl.createBuffer()

			@shaderProgram = initializeShader()
			@loadTexture()

		loadTexture : ->
			@texture.image = new Image()
			@texture.image.onload = ()=>
				handleLoadedTexture @texture
			@texture.image.src = "images/moon.gif"

		handleLoadedTexture = (loadedTexture)->
			gl.pixelStorei gl.UNPACK_FLIP_Y_WEBGL, true
			gl.bindTexture gl.TEXTURE_2D, loadedTexture
			gl.texImage2D gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, loadedTexture.image
			gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR
			gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_NEAREST
			gl.generateMipmap gl.TEXTURE_2D
			gl.bindTexture gl.TEXTURE_2D, null

		initializeShader = ()->
			shaderProgram = ShaderProgramFactory.getInstance 'sphere.vert', 'sphere.frag'
			
			shaderProgram.ambientColorUniform = gl.getUniformLocation shaderProgram.program, 		'uAmbientColor'

			shaderProgram.lightingDirectionUniform = gl.getUniformLocation shaderProgram.program, 	'uLightingDirection'
			shaderProgram.lightingColorUniform = gl.getUniformLocation shaderProgram.program, 		'uDirectionalColor'

			shaderProgram.samplerUniform = gl.getUniformLocation shaderProgram.program, 			'uSampler'

			shaderProgram.pMatrixUniform = gl.getUniformLocation shaderProgram.program, 			'uPMatrix'
			shaderProgram.mvMatrixUniform = gl.getUniformLocation shaderProgram.program, 			'uMVMatrix'

			shaderProgram.normalMatrixUniform = gl.getUniformLocation shaderProgram.program, 		'uNormalMatrix'
			shaderProgram.useLightingUniform = gl.getUniformLocation shaderProgram.program, 		'uUseLighting'

			shaderProgram.pointLightingColorUniform = gl.getUniformLocation shaderProgram.program, 	'uPointLightingColor'
			shaderProgram.pointLightingLocationUniform = gl.getUniformLocation shaderProgram.program,'uPointLightingLocation'

			shaderProgram.vertexPositionAttribute = gl.getAttribLocation shaderProgram.program, 	'aVertexPosition'
			gl.enableVertexAttribArray shaderProgram.vertexPositionAttribute

			shaderProgram.textureCoordinateAttribute = gl.getAttribLocation shaderProgram.program, 	'aTextureCoord'
			gl.enableVertexAttribArray shaderProgram.textureCoordinateAttribute

			shaderProgram.vertexNormalAttribute = gl.getAttribLocation shaderProgram.program, 		'aVertexNormal'
			gl.enableVertexAttribArray shaderProgram.vertexNormalAttribute

			shaderProgram

		initBuffers : ->
			normals = []
			vertexPositions = []
			textureCoordinates = []

			for latitude in [0..NUMBER_OF_LATITUDE_BANDS]
				theta = latitude * Math.PI / NUMBER_OF_LATITUDE_BANDS
				sinTheta = Math.sin theta
				cosTheta = Math.cos theta

				for longitude in [0..NUMBER_OF_LONGITUDE_BANDS]
					phi = longitude * 2 * Math.PI / NUMBER_OF_LONGITUDE_BANDS
					sinPhi = Math.sin phi
					cosPhi = Math.cos phi

					x = cosPhi * sinTheta
					y = cosTheta
					z = sinPhi * sinTheta
					u = 1 - (longitude / NUMBER_OF_LONGITUDE_BANDS)
					v = 1 - (latitude / NUMBER_OF_LATITUDE_BANDS)

					normals.push x
					normals.push y
					normals.push z

					textureCoordinates.push u
					textureCoordinates.push v

					vertexPositions.push (RADIUS * x)
					vertexPositions.push (RADIUS * y)
					vertexPositions.push (RADIUS * z)

			indeces = []
			for latitude in [0...NUMBER_OF_LATITUDE_BANDS]
				for longitude in [0...NUMBER_OF_LONGITUDE_BANDS]
					# todo - these are bad var names
					first = (latitude * (NUMBER_OF_LONGITUDE_BANDS + 1)) + longitude
					second = first + NUMBER_OF_LONGITUDE_BANDS + 1

					indeces.push first
					indeces.push second
					indeces.push first + 1

					indeces.push second
					indeces.push second + 1
					indeces.push first + 1

			gl.bindBuffer gl.ARRAY_BUFFER, @vertexNormalBuffer
			gl.bufferData gl.ARRAY_BUFFER, new Float32Array(normals), gl.STATIC_DRAW
			@vertexNormalBuffer.itemSize = 3
			@vertexNormalBuffer.numberOfItems = normals.length / 3

			gl.bindBuffer gl.ARRAY_BUFFER, @vertexTextureCoordinateBuffer
			gl.bufferData gl.ARRAY_BUFFER, new Float32Array(textureCoordinates), gl.STATIC_DRAW
			@vertexTextureCoordinateBuffer.itemSize = 2
			@vertexTextureCoordinateBuffer.numberOfItems = textureCoordinates / 2

			gl.bindBuffer gl.ARRAY_BUFFER, @vertexPositionBuffer
			gl.bufferData gl.ARRAY_BUFFER, new Float32Array(vertexPositions), gl.STATIC_DRAW
			@vertexPositionBuffer.itemSize = 3
			@vertexPositionBuffer.numberOfItems = vertexPositions / 3

			gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, @vertexIndexBuffer
			gl.bufferData gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(indeces), gl.STATIC_DRAW
			@vertexIndexBuffer.itemSize = 1
			@vertexIndexBuffer.numberOfItems = indeces.length

		render : =>
			gl.enable gl.DEPTH_TEST
			gl.disable gl.BLEND
			gl.useProgram @shaderProgram.program

			@setLightingUniforms()
			@setPosition()			
			@setTexture()
			@setVertexAttributes()
			@setMatrixUniforms()

			gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, @vertexIndexBuffer
			gl.drawElements gl.TRIANGLES, @vertexIndexBuffer.numberOfItems, gl.UNSIGNED_SHORT, 0

		setLightingUniforms : ()=>
			gl.uniform1i @shaderProgram.useLightingUniform, @useLighting

			if not @useLighting
				return

			gl.uniform3f @shaderProgram.ambientColorUniform, @ambientLight.getRed(), @ambientLight.getGreen(), @ambientLight.getBlue()
			gl.uniform3f @shaderProgram.pointLightingLocationUniform, @pointLight.getX(), @pointLight.getY(), @pointLight.getZ()
			gl.uniform3f @shaderProgram.pointLightingColorUniform, @pointLight.getRed(), @pointLight.getGreen(), @pointLight.getBlue()

		setPosition : ()=>
			mat4.translate mvMatrix.getMatrix(), [@x, @y, @z]
			mat4.multiply mvMatrix.getMatrix(), @rotationMatrix

		setTexture : ()=>
			gl.activeTexture gl.TEXTURE0
			gl.bindTexture gl.TEXTURE_2D, @texture
			gl.uniform1i @shaderProgram.samplerUniform, 0

		setVertexAttributes : ()=>
			gl.bindBuffer gl.ARRAY_BUFFER, @vertexPositionBuffer
			gl.vertexAttribPointer @shaderProgram.vertexPositionAttribute, @vertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0
			
			gl.bindBuffer gl.ARRAY_BUFFER, @vertexTextureCoordinateBuffer
			gl.vertexAttribPointer @shaderProgram.textureCoordinateAttribute, @vertexTextureCoordinateBuffer.itemSize, gl.FLOAT, false, 0, 0

			gl.bindBuffer gl.ARRAY_BUFFER, @vertexNormalBuffer
			gl.vertexAttribPointer @shaderProgram.vertexNormalAttribute, @vertexNormalBuffer.itemSize, gl.FLOAT, false, 0, 0


		setMatrixUniforms : ()=>
			gl.uniformMatrix4fv @shaderProgram.pMatrixUniform, false, pMatrix
			gl.uniformMatrix4fv @shaderProgram.mvMatrixUniform, false, mvMatrix.getMatrix()

			normalMatrix = mat3.create()
			mat4.toInverseMat3 mvMatrix.getMatrix(), normalMatrix
			mat3.transpose normalMatrix
			gl.uniformMatrix3fv @shaderProgram.normalMatrixUniform, false, normalMatrix

		animate : ->
			# do nothing

	{
		getInstance : ->
			new Sphere()
	}