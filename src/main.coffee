# Required JS libraries should be "imported" here by adding to the array
require ['glMatrix-0.9.5.min', 
			'ModelViewMatrix', 
			'PerspectiveMatrix', 
			'webgl-utils', 
			'WebGlConstants', 
			'GLContext', 
			'ShapeFactory', 
			'Star',
			'World'
		], (glMatrix, mvMatrix, pMatrix, webGlUtils, webGlConstants, glContext, ShapeFactory, Star, World)->

	# Get the gl context
	gl = glContext.getSingleton()

	world = World.getInstance()
	worldObjects = []

	# Constant number of stars
	numberOfStars = 50

	# For handling keypress events
	PAGE_UP = 33
	PAGE_DOWN = 34
	LEFT = 37
	RIGHT = 39
	UP = 38
	DOWN = 40

	# Add method to convert degrees to radians to Math module
	Math.toRadians = (degrees)->
		degrees * Math.PI / 180.0

	initWorldObjects = ->
		return

	# Helper method to initialize shape buffers
	initBuffers = ->
		for worldObject in worldObjects
			worldObject.initBuffers()

	# Draw the scene
	drawScene = ->
		gl.viewport 0, 0, gl.viewportWidth, gl.viewportHeight
		gl.clear gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT

		if not world.isReadyToRender()
			return
		
		mat4.perspective 45, gl.viewportWidth/gl.viewportHeight, 0.1, 100.0, pMatrix
		mat4.identity mvMatrix

		world.render()

		# Draw all worldObjects
		for object in worldObjects
			object.render()	

	# Animate
	lastTime = 0
	animate = ->
		timeNow = new Date().getTime()
		if lastTime != 0
			elapsedTime = timeNow - lastTime

			world.animate(elapsedTime)

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
		if currentlyPressedKeys[PAGE_UP]
			world.deltaPitch = 0.6
		else if currentlyPressedKeys[PAGE_DOWN]
			world.deltaPitch = -0.6
		else
			world.deltaPitch = 0.0

		if currentlyPressedKeys[LEFT]
			world.deltaYaw = 0.6
		else if currentlyPressedKeys[RIGHT]
			world.deltaYaw = -0.6
		else
			world.deltaYaw = 0.0

		if currentlyPressedKeys[UP]
			world.speed = 0.003
		else if currentlyPressedKeys[DOWN]
		 	world.speed = -0.003
		else
			world.speed = 0.0

	# START
	start = ->
		initWorldObjects()
		initBuffers()
		world.loadWorld()

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