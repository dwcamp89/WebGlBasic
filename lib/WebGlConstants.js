(function(window, document){
	if(!window.WebGLConstants) {
		window.WebGLConstants = {};
		
		// I forgot what these are for...
		WebGLConstants['WEB_GL_CONTEXT_NAME'] = 'webgl';
		WebGLConstants['EXPERIMENTAL_WEB_GL_CONTEXT_NAME'] = 'experimental-webgl';
		
		WebGLConstants['CANVAS_ID'] = 'theCanvas'; // Id of the canvas element to be used
		
		// ERROR MESSAGES
		WebGLConstants['ERROR_MESSAGES'] = {};
		WebGLConstants['ERROR_MESSAGES']['UNABLE_TO_INITIALIZE_SHADERS'] = "Could not initialize shaders!";
		
		// Add more as necessary
	}
})(this, this.document);