# Required JS libraries should be "imported" here by adding to the array
require ['glMatrix-0.9.5.min', 'ModelViewMatrix', 'PerspectiveMatrix', 'webgl-utils', 'WebGlConstants', 'GLContext', 'ShapeFactory', 'Star'], (glMatrix, mvMatrix, pMatrix, webGlUtils, webGlConstants, glContext, ShapeFactory, Star)->

	# Get the gl context
	gl = glContext.getSingleton()

	# World objects
	worldObjects = []

	# Constant number of stars
	numberOfStars = 50

	# Add method to convert degrees to radians to Math module
	Math.toRadians = (degrees)->
		degrees * Math.PI / 180.0

	initWorldObjects = ->
		worldObjects = (getNewStarObject(i) for i in [0...numberOfStars])

	getNewStarObject = (count)->
		newStarObject = ShapeFactory.getShape 'Star'

		# Set initial parameters
		newStarObject.distance = (count / numberOfStars) * 5.0
		newStarObject.rotationSpeed = (count / numberOfStars)

		newStarObject

	# Helper method to initialize shape buffers
	initBuffers = ->
		for worldObject in worldObjects
			worldObject.initBuffers()

	# Draw the scene
	drawScene = ->
		gl.viewport 0, 0, gl.viewportWidth, gl.viewportHeight
		gl.clear gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT
		
		mat4.perspective 45, gl.viewportWidth/gl.viewportHeight, 0.1, 100.0, pMatrix

		gl.blendFunc gl.SRC_ALPHA, gl.ONE
		gl.enable gl.BLEND

		mat4.identity mvMatrix

		# Draw all worldObjects
		for object in worldObjects
			object.render()	

	# Animate
	lastTime = 0
	animate = ->
		# Set the twinkle flag
		Star.setTwinkle document.getElementById('useTwinkleCheckbox').checked

		timeNow = new Date().getTime()
		if lastTime != 0
			elapsedTime = timeNow - lastTime

			# Animate each world object
			for worldObject in worldObjects
				worldObject.animate elapsedTime

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
		if currentlyPressedKeys[33]
			for worldObject in worldObjects
				worldObject.zoom += 2

		# Page down => zoom out
		if currentlyPressedKeys[34]
			for worldObject in worldObjects
				worldObject.zoom -= 2

		# Up => Rotate in positive x direction
		if currentlyPressedKeys[38]
			for worldObject in worldObjects
				worldObject.tilt += 2

		# Down => Rotate in negative x direction
		if currentlyPressedKeys[40]
			for worldObject in worldObjects
				worldObject.tilt -= 2

	# START
	start = ->
		initWorldObjects()
		initBuffers()

		# Only continue if gl was initialized
		if gl
			gl.clearColor 0.0, 0.0, 0.0, 1.0
			gl.clear gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT

		# Set the key event handlers
		document.onkeydown = handleKeyDown
		document.onkeyup = handleKeyUp

		tick()

	# Entry point
	start()