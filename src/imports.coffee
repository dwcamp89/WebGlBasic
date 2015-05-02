# Required JS libraries should be "imported" here by adding to the array
require ['glMatrix-0.9.5.min', 'webgl-utils', 'WebGlConstants', 'shader'], (glMatrix, webGlUtils, webGlConstants, shader)->
	config = {
		vertexShader : shader.vertex
		fragmentShader : shader.fragment
	}
	start(config)