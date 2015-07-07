// Generated by CoffeeScript 1.9.0
(function() {
  define(['gl', 'shaderSrcs'], function(gl, shaderSrcs) {
    var getInstance;
    getInstance = function(vertexShaderName, fragmentShaderName) {
      var fragmentShader, fragmentShaderSrc, programInstance, shaderProgram, vertexShader, vertexShaderSrc;
      vertexShader = gl.createShader(gl.VERTEX_SHADER);
      vertexShader.compileSuccess = false;
      fragmentShader = gl.createShader(gl.FRAGMENT_SHADER);
      fragmentShader.compileSuccess = false;
      shaderProgram = gl.createProgram();
      shaderProgram.linkSuccess = false;
      programInstance = {
        'vertexShader': vertexShader,
        'fragmentShader': fragmentShader,
        'program': shaderProgram
      };
      vertexShaderSrc = shaderSrcs[vertexShaderName];
      gl.shaderSource(vertexShader, vertexShaderSrc);
      gl.compileShader(vertexShader);
      if (!gl.getShaderParameter(vertexShader, gl.COMPILE_STATUS)) {
        console.log("Unable to compile vertex shader " + vertexShaderName + ".");
        return programInstance;
      }
      vertexShader.compileSuccess = true;
      fragmentShaderSrc = shaderSrcs[fragmentShaderName];
      gl.shaderSource(fragmentShader, fragmentShaderSrc);
      gl.compileShader(fragmentShader);
      fragmentShader.compileSuccess = true;
      if (!gl.getShaderParameter(fragmentShader, gl.COMPILE_STATUS)) {
        console.log(gl.getShaderParameter(fragmentShader, gl.COMPILE_STATUS));
        console.log("Unable to compile fragment shader " + fragmentShaderName + ".");
        console.log(gl.getShaderInfoLog(fragmentShader));
        return programInstance;
      }
      gl.attachShader(shaderProgram, vertexShader);
      gl.attachShader(shaderProgram, fragmentShader);
      gl.linkProgram(shaderProgram);
      if (!gl.getProgramParameter(shaderProgram, gl.LINK_STATUS)) {
        console.log("Unable to link shader program with " + vertexShaderName + " and " + fragmentShaderName + ".");
        return programInstance;
      }
      shaderProgram.linkSuccess = true;
      return programInstance;
    };
    return {
      'getInstance': getInstance
    };
  });

}).call(this);