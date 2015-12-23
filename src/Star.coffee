define ['GLContext', 'ModelViewMatrix', 'PerspectiveMatrix', 'glMatrix-0.9.5.min', 'ShaderProgramFactory'], (glContext, mvMatrix, pMatrix, glMatrix, ShaderProgramFactory)->

	# Definition of Star class
	class Star

		# Init handler to gl context
		gl = glContext.getSingelton()

	constructor : ->
		@angle = 0
		@distance = 0
		@rotationSpeed = 0

	initBuffers : ->

	render : =>

	# Set RGB values each to random
	randomizeColors : ()->
		@r = Math.random()
		@g = Math.random()
		@b = Math.random()

		# Twinkle colors here

	# Return a module that provides factory method for Star object
	{
		getInstance : ()-> return new Star()
	}