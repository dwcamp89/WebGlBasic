# Required JS libraries should be "imported" here by adding to the array
require ['glMatrix-0.9.5.min', 'PerspectiveMatrix', 'webgl-utils', 'WebGlConstants', 'GLContext', 'ShapeFactory'], (glMatrix, pMatrix, webGlUtils, webGlConstants, glContext, ShapeFactory)->

	# Get the gl context
	gl = glContext.getSingleton()

	# Cube object
	cube = null

	# Helper method to initialize shape buffers
	initBuffers = ->
		# Initialize cube and buffers
		cube = ShapeFactory.getShape('TexturedCube')
		cube.initBuffers()

	# Draw the scene
	drawScene = ->
		gl.viewport 0, 0, gl.viewportWidth, gl.viewportHeight
		gl.clear gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT
		
		mat4.perspective 45, gl.viewportWidth/gl.viewportHeight, 0.1, 100.0, pMatrix

		# Draw cube
		cube.render()


	# Animate
	lastTime = 0
	animate = ->
		timeNow = new Date().getTime()
		if lastTime != 0
			elapsed = timeNow - lastTime

			# Set the cube alpha value

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

	handleKeyUp = (event)->
		currentlyPressedKeys[event.keyCode] = false

	handleKeys = ()->
		# Page up => zoom in
		if currentlyPressedKeys[65]
			cube.z += 0.5

		# Page down => zoom out
		if currentlyPressedKeys[83]
			cube.z -= 0.5

		# Left => slow Y rotation
		if currentlyPressedKeys[68]
			cube.yRotSpeed -= 1

		# Right => speed up Y rotation
		if currentlyPressedKeys[70]
			cube.yRotSpeed += 1

	# START
	start = ->
		initBuffers()

		# Only continue if gl was initialized
		if gl
			gl.clearColor 0.0, 0.0, 0.0, 1.0
			gl.enable gl.DEPTH_TEST
			gl.depthFunc gl.LEQUAL
			gl.clear gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT

		# Move the cube back 8 units initially
		cube.z = -8.0

		# Set the key event handlers
		document.onkeydown = handleKeyDown
		document.onkeyup = handleKeyUp

		document.getElementById('min-nearest').onclick = () ->
			cube.setMinFilter gl.NEAREST

		document.getElementById('min-linear').onclick = () ->
			cube.setMinFilter gl.LINEAR

		document.getElementById('min-nearest-mipmap-nearest').onclick = () ->
			cube.setMinFilter gl.NEAREST_MIPMAP_NEAREST

		document.getElementById('min-linear-mipmap-nearest').onclick = () ->
			cube.setMinFilter gl.LINEAR_MIPMAP_NEAREST

		document.getElementById('min-nearest-mipmap-linear').onclick = () ->
			cube.setMinFilter gl.NEAREST_MIPMAP_LINEAR

		document.getElementById('min-linear-mipmap-linear').onclick = () ->
			cube.setMinFilter gl.LINEAR_MIPMAP_LINEAR

		document.getElementById('mag-nearest').onclick = ()->
			cube.setMagFilter gl.NEAREST

		document.getElementById('mag-linear').onclick = ()->
			cube.setMagFilter gl.LINEAR

		# Kick off tick for animation
		tick()

	# Entry point
	start()