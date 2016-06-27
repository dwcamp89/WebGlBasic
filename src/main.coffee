require.config({
	paths : {
		jquery : 'jquery.min'
		jqColorPicker : 'jqColorPicker.min'
	}
})

# Required JS libraries should be "imported" here by adding to the array
require ['glMatrix-0.9.5.min', 
			'ModelViewMatrix', 
			'PerspectiveMatrix', 
			'webgl-utils', 
			'WebGlConstants', 
			'GLContext', 
			'ShapeFactory',
			'jquery'
			'jqColorPicker'
		], (glMatrix, mvMatrix, pMatrix, webGlUtils, webGlConstants, glContext, ShapeFactory, jQuery, jqColorPicker)->

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

	Z_OFFSET = -20

	# parse rgba(1,2,3)
	parseRgbString = (rgbString)->
		rgb = mat3.create()
		trimmedRgbString = rgbString.substring(rgbString.indexOf('(') + 1, rgbString.length - 1)
		rgbArray = trimmedRgbString.split ','

		rgb.r = rgbArray[0] / 255.0
		rgb.g = rgbArray[1] / 255.0
		rgb.b = rgbArray[2] / 255.0

		rgb

	getAmbientLightColor = ()->
		parseRgbString jQuery('#ambientColor').css('background-color')
	getPointLightColor = ()->
		parseRgbString jQuery('#pointLightColor').css('background-color')

	ambientLightRgb = getAmbientLightColor()
	pointLightRgb = getPointLightColor()

	setAmbientLight = ()->
		ambientLightRgb = getAmbientLightColor()
	setPointLight = ()->
		pointLightRgb = getPointLightColor()
	

	# Color picker
	jQuery('#ambientColor').colorPicker({
		renderCallback : ()->
			setAmbientLight()
		forceAlpha : false
	})

	jQuery('#pointLightColor').colorPicker({
		renderCallback : ()->
			setPointLight()
		forceAlpha : false
	})

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
		mat4.translate mvMatrix.getMatrix(), [3, 0, 0]

		moonSphere = worldObjects[0]
		moonSphere.useLighting = document.getElementById('useLightingCheckbox').checked

		moonSphere.ambientLight.setRed ambientLightRgb.r
		moonSphere.ambientLight.setGreen ambientLightRgb.g
		moonSphere.ambientLight.setBlue ambientLightRgb.b

		moonSphere.pointLight.setRed pointLightRgb.r
		moonSphere.pointLight.setGreen pointLightRgb.g
		moonSphere.pointLight.setBlue pointLightRgb.b

		moonSphere.render()

	renderStar = ->
		star = worldObjects[1]

		star.r = pointLightRgb.r
		star.g = pointLightRgb.g
		star.b = pointLightRgb.b

		star.render()

	# Animate
	lastTime = 0
	animate = ->
		timeNow = new Date().getTime()
		if lastTime != 0
			elapsedTime = timeNow - lastTime

			moonAngle += 0.05 * elapsedTime

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