define ['glMatrix-0.9.5.min'], (glMatrix)->
	modelViewMatrix = mat4.create()

	# Internal stack of previous matrices
	modelViewMatrixStack = []

	pushMatrix = ->
		copy = mat4.create()
		mat4.set modelViewMatrix, copy
		modelViewMatrixStack.push copy

	popMatrix = ->
		if modelViewMatrixStack.size == 0
			throw "Invalid Pop Matrix"
		modelViewMatrix = modelViewMatrixStack.pop()

	# Return reference to the actual matrix
	modelViewMatrix
