# Required JS libraries should be "imported" here by adding to the array
require ['glMatrix-0.9.5.min', 'webgl-utils', 'WebGlConstants', 'gl', 'ShapeFactory'], (glMatrix, webGlUtils, webGlConstants, gl, ShapeFactory)->

	# Colored pyramid
	pyramid = null

	# Textured cube
	cube = null

	# Helper method to initialize shape buffers
	initBuffers = ->
		# Initialize pyramid and buffers
		pyramid = ShapeFactory.getShape('Pyramid')
		pyramid.initBuffers()

		# Initialize cube and buffers
		cube = ShapeFactory.getShape('IlluminatedCube')
		cube.initBuffers()

	# Draw the scene
	drawScene = ->
		if pMatrix == null
			pMatrix = mat4.create()

		gl.viewport 0, 0, gl.viewportWidth, gl.viewportHeight
		gl.clear gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT
		
		mat4.perspective 45, gl.viewportWidth/gl.viewportHeight, 0.1, 100.0, pMatrix

		# Draw pyramid
		pyramid.render()

		# Draw cube
		cube.render()


	# Animate
	lastTime = 0
	animate = ->
		timeNow = new Date().getTime()
		if lastTime != 0
			elapsed = timeNow - lastTime

			# Rotate the pyramid
			pyramid.yRot += (90 * elapsed) / 1000.0

			# Check whether or not to use lighting
			cube.useLighting = document.getElementById('UseLightingCheckbox').checked

			# Check the ambient color
			cube.ambientColor[0] = document.getElementById('AmbientColorXInput').value or 0.0
			cube.ambientColor[1] = document.getElementById('AmbientColorYInput').value or 0.0
			cube.ambientColor[2] = document.getElementById('AmbientColorZInput').value or 0.0

			# Check the directional light direction
			cube.lightDirectionX = document.getElementById('DirectionalLightXInput').value or 0.0
			cube.lightDirectionY = document.getElementById('DirectionalLightYInput').value or 0.0
			cube.lightDirectionZ = document.getElementById('DirectionalLightZInput').value or 0.0

			# Check the directional light color
			cube.directionalColor[0] = document.getElementById('DirectionalLightRInput').value or 0.0
			cube.directionalColor[1] = document.getElementById('DirectionalLightGInput').value or 0.0
			cube.directionalColor[2] = document.getElementById('DirectionalLightBInput').value or 0.0

			# Update textured cube position
			cube.xRot += (cube.xRotSpeed * elapsed) / 1000.0
			cube.yRot += (cube.yRotSpeed * elapsed) / 1000.0
			cube.zRot += (cube.zRotSpeed * elapsed) / 1000.0

		lastTime = timeNow


	# Tick for animation
	tick = ->
		requestAnimFrame(tick)
		handleKeys()
		drawScene()
		animate()

	currentlyPressedKeys = {}
	handleKeyDown = (event)->
		currentlyPressedKeys[event.keyCode] = true

		# Tick the filter number if user presses f
		if(String.fromCharCode(event.keyCode) == 'F')
			console.log 'F'
			cube.tickFilter()

	handleKeyUp = (event)->
		currentlyPressedKeys[event.keyCode] = false

	handleKeys = ()->
		# Page up => zoom in
		if currentlyPressedKeys[33]
			cube.z += 0.5

		# Page down => zoom out
		if currentlyPressedKeys[34]
			cube.z -= 0.5

		# Left => slow Y rotation
		if currentlyPressedKeys[37]
			cube.yRotSpeed -= 1

		# Right => speed up Y rotation
		if currentlyPressedKeys[39]
			cube.yRotSpeed += 1

		# Up => slow X rotation
		if currentlyPressedKeys[38]
			cube.xRotSpeed -= 1

		# Down => speed up X rotation
		if currentlyPressedKeys[40]
			cube.xRotSpeed += 1

	# START
	start = ->
		initBuffers()

		# Only continue if gl was initialized
		if gl
			gl.clearColor 0.0, 0.0, 0.0, 1.0
			gl.enable gl.DEPTH_TEST
			gl.depthFunc gl.LEQUAL
			gl.clear gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT

		# Move the pyramid
		pyramid.x = 3.0
		pyramid.y = 2.0
		pyramid.z = -10.0

		# Move the cube back 8 units initially
		cube.z = -8.0

		# Set the key event handlers
		document.onkeydown = handleKeyDown
		document.onkeyup = handleKeyUp

		tick()

	# Entry point
	start()