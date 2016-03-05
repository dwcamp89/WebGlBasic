# Required JS libraries should be "imported" here by adding to the array
require ['glMatrix-0.9.5.min', 
			'ModelViewMatrix', 
			'PerspectiveMatrix', 
			'webgl-utils', 
			'WebGlConstants', 
			'GLContext', 
			'ShapeFactory'
		], (glMatrix, mvMatrix, pMatrix, webGlUtils, webGlConstants, glContext, ShapeFactory)->

	# Get the gl context
	gl = glContext.getSingleton()

	worldObjects = []

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
		moonSphere = ShapeFactory.getShape 'Sphere'
		moonSphere.z = -6
		worldObjects.push moonSphere

	# Helper method to initialize shape buffers
	initBuffers = ->
		for worldObject in worldObjects
			worldObject.initBuffers()

	# Draw the scene
	drawScene = ->
		gl.viewport 0, 0, gl.viewportWidth, gl.viewportHeight
		gl.clear gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT
		
		mat4.perspective 45, gl.viewportWidth/gl.viewportHeight, 0.1, 100.0, pMatrix
		mat4.identity mvMatrix

		moonSphere = worldObjects[0]

		useLighting = document.getElementById('useLightingCheckbox').checked
		moonSphere.useLighting = useLighting

		moonSphere.ambientLight.setRed document.getElementById('ambientRedInput').value
		moonSphere.ambientLight.setGreen document.getElementById('ambientGreenInput').value
		moonSphere.ambientLight.setBlue document.getElementById('ambientBlueInput').value

		moonSphere.directionalLight.setX document.getElementById('directionalXInput').value
		moonSphere.directionalLight.setY document.getElementById('directionalYInput').value
		moonSphere.directionalLight.setZ document.getElementById('directionalZInput').value

		moonSphere.directionalLight.setRed document.getElementById('directionalRedInput').value
		moonSphere.directionalLight.setGreen document.getElementById('directionalGreenInput').value
		moonSphere.directionalLight.setBlue document.getElementById('directionalBlueInput').value

		# Draw all worldObjects
		for object in worldObjects
			object.render()	

	# Animate
	lastTime = 0
	animate = ->
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
		drawScene()
		animate()

	mouseDown = false
	lastMouseX = lastMouseY = null

	handleMouseUp = ()->
		mouseDown = false

	handleMouseMove = (event)->
		if not mouseDown
			return

		newX = event.clientX
		deltaX = newX - lastMouseX

		newY = event.clientY
		deltaY = newY - lastMouseY

		newRotationMatrix = mat4.create()
		mat4.identity newRotationMatrix
		mat4.rotate newRotationMatrix, (Math.toRadians deltaX / 10), [0, 1, 0]
		mat4.rotate newRotationMatrix, (Math.toRadians deltaY / 10), [1, 0, 0]

		sphere = worldObjects[0]
		mat4.multiply newRotationMatrix, sphere.rotationMatrix, sphere.rotationMatrix

		lastMouseX = newX
		lastMouseY = newY

	handleMouseDown = (event)->
		mouseDown = true
		lastMouseX = event.clientX
		lastMouseY = event.clientY

	# START
	start = ->
		initWorldObjects()
		initBuffers()

		# Only continue if gl was initialized
		if gl
			gl.clearColor 0.0, 0.0, 0.0, 1.0
			gl.clear gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT

		# Set the key event handlers
		document.onmouseup = handleMouseUp
		document.onmousemove = handleMouseMove
		glContext.getCanvas().onmousedown = handleMouseDown

		tick()

	# Entry point
	start()