define [], ()->

	class Light
		constructor : ->
			@color = [0, 0, 0]

		getRed : =>
			return @color[0]

		getGreen : =>
			return @color[1]

		getBlue : =>
			return @color[2]

		setRed : (red)=>
			@color[0] = red or 0

		setGreen : (green)=>
			@color[1] = green or 0

		setBlue : (blue)=>
			@color[2] = blue or 0

	class DirectionalLight extends Light
		constructor : ->
			super()
			@direction = [0, 0, 0]

		getX : =>
			return @direction[0]

		getY : =>
			return @direction[1]

		getZ : =>
			return @direction[2]

		setX : (x)=>
			@direction[0] = x or 0

		setY : (y)=>
			@direction[1] = y or 0

		setZ : (z)=>
			@direction[2] = z or 0

	class PointLight extends Light
		constructor : ->
			super()
			@location = [0, 0, 0]

		getX : =>
			return @location[0]

		getY : =>
			return @location[1]

		getZ : =>
			return @location[2]

		setX : (x)=>
			@location[0] = x or 0

		setY : (y)=>
			@location[1] = y or 0

		setZ : (z)=>
			@location[2] = z or 0

	{
		getInstance : (lightType)->
			if lightType == 'DirectionalLight'
				return new DirectionalLight()
			else if lightType == 'PointLight'
				return new PointLight()
			else
				return new Light()
	}