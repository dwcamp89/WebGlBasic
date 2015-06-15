define ['Cube', 'Pyramid'], (Cube, Pyramid)->
	getShape: (type)->
		if type == 'Cube'
			return Cube.getInstance()
		else if type == 'Pyramid'
			return Pyramid.getInstance()
		else
			return null