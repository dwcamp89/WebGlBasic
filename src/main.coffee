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

	moonAngle = 0
	starAngle = 180

	Z_OFFSET = -20

	# Add method to convert degrees to radians to Math module
	Math.toRadians = (degrees)->
		degrees * Math.PI / 180.0

	initWorldObjects = ->
		moonSphere = ShapeFactory.getShape 'Sphere'
		worldObjects.push moonSphere

		star = ShapeFactory.getShape 'Star'
		star.zoom = Z_OFFSET

		worldObjects.push star

	# Helper method to initialize shape buffers
	initBuffers = ->
		for worldObject in worldObjects
			worldObject.initBuffers()

	# Draw the scene
	drawScene = ->
		gl.viewport 0, 0, gl.viewportWidth, gl.viewportHeight
		gl.clear gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT
		gl.enable gl.BLEND
		
		mat4.perspective 45, gl.viewportWidth/gl.viewportHeight, 0.1, 100.0, pMatrix
		mat4.identity mvMatrix.getMatrix()

		renderMoonSphere()
		renderStar()

	renderMoonSphere = ->
		mat4.translate mvMatrix.getMatrix(), [0, 0, Z_OFFSET]

		mat4.rotate mvMatrix.getMatrix(), Math.toRadians(moonAngle), [0, 1, 0]
		mat4.translate mvMatrix.getMatrix(), [5, 0, 0]

		moonSphere = worldObjects[0]
		moonSphere.useLighting = document.getElementById('useLightingCheckbox').checked

		moonSphere.ambientLight.setRed document.getElementById('ambientRedInput').value
		moonSphere.ambientLight.setGreen document.getElementById('ambientGreenInput').value
		moonSphere.ambientLight.setBlue document.getElementById('ambientBlueInput').value

		moonSphere.pointLight.setRed document.getElementById('pointLightRedInput').value
		moonSphere.pointLight.setGreen document.getElementById('pointLightGreenInput').value
		moonSphere.pointLight.setBlue document.getElementById('pointLightBlueInput').value

		moonSphere.render()

	renderStar = ->
		starAngleInRadians = Math.toRadians starAngle

		star = worldObjects[1]
		star.angle = starAngle

		star.r = document.getElementById('pointLightRedInput').value
		star.g = document.getElementById('pointLightGreenInput').value
		star.b = document.getElementById('pointLightBlueInput').value

		star.render()

	# Animate
	lastTime = 0
	animate = ->
		timeNow = new Date().getTime()
		if lastTime != 0
			elapsedTime = timeNow - lastTime

			moonAngle += 0.05 * elapsedTime
			starAngle += 0.05 * elapsedTime

		lastTime = timeNow


	# Tick for animation
	tick = ->
		requestAnimFrame(tick)
		drawScene()
		animate()

	# START
	start = ->
		initWorldObjects()
		initBuffers()

		# Only continue if gl was initialized
		if gl
			gl.clearColor 0.0, 0.0, 0.0, 1.0
			gl.clear gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT

		tick()

	# Entry point
	start()