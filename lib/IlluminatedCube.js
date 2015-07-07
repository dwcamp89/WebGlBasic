// Generated by CoffeeScript 1.9.0
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(['gl', 'ModelViewMatrix', 'PerspectiveMatrix', 'glMatrix-0.9.5.min', 'ShaderProgramFactory'], function(gl, mvMatrix, pMatrix, glMatrix, ShaderProgramFactory) {
    var IlluminatedCube;
    IlluminatedCube = (function() {
      var degToRad, handleLoadedTexture;

      function IlluminatedCube() {
        this.render = __bind(this.render, this);
        var crateImage;
        this.x = this.y = this.z = 0;
        this.xRot = this.yRot = this.zRot = 0;
        this.xRotSpeed = this.yRotSpeed = this.zRotSpeed = 10;
        this.lightDirectionX = this.lightDirectionY = -0.25;
        this.lightDirectionZ = -1.0;
        this.useLighting = true;
        this.ambientColor = [1.0, 1.0, 1.0];
        this.directionalColor = [0.75, 0.5, 0.0];
        this.vertexPositionBuffer = gl.createBuffer();
        this.vertexIndexBuffer = gl.createBuffer();
        this.vertexTextureCoordBuffer = gl.createBuffer();
        this.vertexNormalBuffer = gl.createBuffer();
        this.shaderProgram = ShaderProgramFactory.getInstance('light1.vert', 'light1.frag');
        this.shaderProgram.vertexPositionAttribute = gl.getAttribLocation(this.shaderProgram.program, 'aVertexPosition');
        gl.enableVertexAttribArray(this.shaderProgram.vertexPositionAttribute);
        this.shaderProgram.vertexNormalAttribute = gl.getAttribLocation(this.shaderProgram.program, 'aVertexNormal');
        gl.enableVertexAttribArray(this.shaderProgram.vertexNormalAttribute);
        this.shaderProgram.textureCoordAttribute = gl.getAttribLocation(this.shaderProgram.program, 'aTextureCoord');
        gl.enableVertexAttribArray(this.shaderProgram.textureCoordAttribute);
        this.shaderProgram.pMatrixUniform = gl.getUniformLocation(this.shaderProgram.program, 'uPMatrix');
        this.shaderProgram.mvMatrixUniform = gl.getUniformLocation(this.shaderProgram.program, 'uMVMatrix');
        this.shaderProgram.samplerUniform = gl.getUniformLocation(this.shaderProgram.program, 'uSampler');
        this.shaderProgram.useLightingUniform = gl.getUniformLocation(this.shaderProgram.program, 'uUseLighting');
        this.shaderProgram.lightingDirectionUniform = gl.getUniformLocation(this.shaderProgram.program, 'uLightingDirection');
        this.shaderProgram.directionLightingColorUniform = gl.getUniformLocation(this.shaderProgram.program, 'uDirectionalLightingColor');
        this.shaderProgram.normalMatrixUniform = gl.getUniformLocation(this.shaderProgram.program, 'uNormalMatrix');
        this.shaderProgram.ambientColorUniform = gl.getUniformLocation(this.shaderProgram.program, 'uAmbientColor');
        this.crateTexture = gl.createTexture();
        crateImage = new Image();
        this.crateTexture.image = crateImage;
        crateImage.onload = (function(_this) {
          return function() {
            return handleLoadedTexture(_this.crateTexture);
          };
        })(this);
        crateImage.src = 'images/crate.gif';
      }

      handleLoadedTexture = function(texture) {
        gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true);
        gl.bindTexture(gl.TEXTURE_2D, texture);
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, texture.image);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_NEAREST);
        gl.generateMipmap(gl.TEXTURE_2D);
        return gl.bindTexture(gl.TEXTURE_2D, null);
      };

      IlluminatedCube.prototype.initBuffers = function() {
        var elemVertices, textureCoords, vertexNormals, vertices;
        gl.bindBuffer(gl.ARRAY_BUFFER, this.vertexPositionBuffer);
        vertices = [-1.0, -1.0, 1.0, 1.0, -1.0, 1.0, 1.0, 1.0, 1.0, -1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, 1.0, -1.0, 1.0, 1.0, -1.0, 1.0, -1.0, -1.0, -1.0, 1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, 1.0, -1.0, -1.0, 1.0, -1.0, 1.0, -1.0, -1.0, 1.0, 1.0, -1.0, -1.0, 1.0, 1.0, -1.0, 1.0, 1.0, 1.0, 1.0, -1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, -1.0, 1.0, 1.0, -1.0, 1.0, -1.0];
        gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW);
        this.vertexPositionBuffer.itemSize = 3;
        this.vertexPositionBuffer.numberOfItems = 24;
        gl.bindBuffer(gl.ARRAY_BUFFER, this.vertexTextureCoordBuffer);
        textureCoords = [0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0];
        gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(textureCoords), gl.STATIC_DRAW);
        this.vertexTextureCoordBuffer.itemSize = 2;
        this.vertexTextureCoordBuffer.numItems = 24;
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.vertexIndexBuffer);
        elemVertices = [0, 1, 2, 0, 2, 3, 4, 5, 6, 4, 6, 7, 8, 9, 10, 8, 10, 11, 12, 13, 14, 12, 14, 15, 16, 17, 18, 16, 18, 19, 20, 21, 22, 20, 22, 23];
        gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(elemVertices), gl.STATIC_DRAW);
        this.vertexIndexBuffer.itemSize = 3;
        this.vertexIndexBuffer.numberOfItems = 36;
        gl.bindBuffer(gl.ARRAY_BUFFER, this.vertexNormalBuffer);
        vertexNormals = [0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0];
        gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertexNormals), gl.STATIC_DRAW);
        this.vertexNormalBuffer.itemSize = 3;
        return this.vertexNormalBuffer.numberOfItems = 24;
      };

      IlluminatedCube.prototype.render = function() {
        var lightingDirection, normalLightDirection, normalMatrix;
        gl.useProgram(this.shaderProgram.program);
        mat4.perspective(45, gl.viewportWidth / gl.viewportHeight, 0.1, 100.0, pMatrix);
        mat4.identity(mvMatrix);
        mat4.translate(mvMatrix, [this.x, this.y, this.z]);
        mat4.rotate(mvMatrix, degToRad(this.xRot), [1, 0, 0]);
        mat4.rotate(mvMatrix, degToRad(this.yRot), [0, 1, 0]);
        mat4.rotate(mvMatrix, degToRad(this.zRot), [0, 0, 1]);
        gl.bindBuffer(gl.ARRAY_BUFFER, this.vertexPositionBuffer);
        gl.vertexAttribPointer(this.shaderProgram.vertexPositionAttribute, this.vertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0);
        gl.bindBuffer(gl.ARRAY_BUFFER, this.vertexTextureCoordBuffer);
        gl.vertexAttribPointer(this.shaderProgram.textureCoordAttribute, this.vertexTextureCoordBuffer.itemSize, gl.FLOAT, false, 0, 0);
        gl.bindBuffer(gl.ARRAY_BUFFER, this.vertexNormalBuffer);
        gl.vertexAttribPointer(this.shaderProgram.vertexNormalAttribute, this.vertexNormalBuffer.itemSize, gl.FLOAT, false, 0, 0);
        gl.uniform1i(this.shaderProgram.useLightingUniform, this.useLighting);
        if (this.useLighting) {
          gl.uniform3f(this.shaderProgram.ambientColorUniform, this.ambientColor[0], this.ambientColor[1], this.ambientColor[2]);
          lightingDirection = [this.lightDirectionX, this.lightDirectionY, this.lightDirectionZ];
          normalLightDirection = vec3.create();
          vec3.normalize(lightingDirection, normalLightDirection);
          vec3.scale(normalLightDirection, -1);
          gl.uniform3fv(this.shaderProgram.lightingDirectionUniform, normalLightDirection);
          gl.uniform3f(this.shaderProgram.directionLightingColorUniform, this.directionalColor[0], this.directionalColor[1], this.directionalColor[2]);
          normalMatrix = mat3.create();
          mat4.toInverseMat3(mvMatrix, normalMatrix);
          mat3.transpose(normalMatrix);
          gl.uniformMatrix3fv(this.shaderProgram.normalMatrixUniform, false, normalMatrix);
        }
        gl.activeTexture(gl.TEXTURE0);
        gl.bindTexture(gl.TEXTURE_2D, this.crateTexture);
        gl.uniform1i(this.shaderProgram.samplerUniform, 0);
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.vertexIndexBuffer);
        gl.uniformMatrix4fv(this.shaderProgram.pMatrixUniform, false, pMatrix);
        gl.uniformMatrix4fv(this.shaderProgram.mvMatrixUniform, false, mvMatrix);
        return gl.drawElements(gl.TRIANGLES, this.vertexIndexBuffer.numberOfItems, gl.UNSIGNED_SHORT, 0);
      };

      degToRad = function(degrees) {
        return degrees * Math.PI / 180.0;
      };

      return IlluminatedCube;

    })();
    return {
      'getInstance': function() {
        return new IlluminatedCube();
      }
    };
  });

}).call(this);