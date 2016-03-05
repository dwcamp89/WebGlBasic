define ['WebGlConstants'], (webGlConstants)->

	# Get the canvas by ID
	canvas = document.getElementById webGlConstants.CANVAS_ID

	# Init web gl context
	try
		gl = canvas.getContext webGlConstants.WEB_GL_CONTEXT_NAME
		gl = gl ? (canvas.getContext webGlConstants.EXPERIMENTAL_WEB_GL_CONTEXT_NAME)
		gl.viewportWidth = canvas.width
		gl.viewportHeight = canvas.height
	catch error
		console.log 'error initializing webgl'
		console.log e.message
	
	# If gl was not successfully initialized, give up
	if !gl
		alert 'Unable to initialize WebGL. Your browser may not support it.'
		gl = null;
	
	# Return the gl object
	{
		getSingleton : ()-> return gl
		getCanvas : ()-> return canvas
	}
