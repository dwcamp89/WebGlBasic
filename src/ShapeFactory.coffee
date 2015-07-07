define ['Cube', 'Pyramid', 'TexturedCube', 'IlluminatedCube'], (Cube, Pyramid, TexturedCube, IlluminatedCube)->
	getShape: (type)->
		if type == 'Cube'
			return Cube.getInstance()
		else if type == 'Pyramid'
			return Pyramid.getInstance()
		else if type == 'TexturedCube'
			return TexturedCube.getInstance()
		else if type == 'IlluminatedCube'
			return IlluminatedCube.getInstance()
		else
			return null