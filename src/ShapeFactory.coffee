define ['Cube', 'Pyramid', 'TexturedCube', 'IlluminatedCube', 'Star'], (Cube, Pyramid, TexturedCube, IlluminatedCube, Star)->
	getShape: (type)->
		if type == 'Cube'
			return Cube.getInstance()
		else if type == 'Pyramid'
			return Pyramid.getInstance()
		else if type == 'TexturedCube'
			return TexturedCube.getInstance()
		else if type == 'IlluminatedCube'
			return IlluminatedCube.getInstance()
		else if type == 'Star'
			return Star.getInstance()
		else
			return null