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
		cube = ShapeFactory.getShape('Cube')
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

			# Update textured cube position
			cube.xRot += (90 * elapsed) / 1000.0
			cube.yRot += (90 * elapsed) / 1000.0
			cube.zRot += (90 * elapsed) / 1000.0

		lastTime = timeNow


	# Tick for animation
	tick = ->
		requestAnimFrame(tick)
		drawScene()
		animate()

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
		pyramid.x = 2.0
		pyramid.z = -8.0

		# Move the cube back 10 units
		cube.x = -2.0
		cube.z = -8.0

		
		tick()

	# Entry point
	start()