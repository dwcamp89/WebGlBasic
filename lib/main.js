// Generated by CoffeeScript 1.9.0
(function() {
  require.config({
    paths: {
      jquery: 'jquery.min',
      jqColorPicker: 'jqColorPicker.min'
    }
  });

  require(['glMatrix-0.9.5.min', 'ModelViewMatrix', 'PerspectiveMatrix', 'webgl-utils', 'WebGlConstants', 'GLContext', 'ShapeFactory', 'jquery', 'jqColorPicker'], function(glMatrix, mvMatrix, pMatrix, webGlUtils, webGlConstants, glContext, ShapeFactory, jQuery, jqColorPicker) {
    var DOWN, LEFT, PAGE_DOWN, PAGE_UP, RIGHT, UP, Z_OFFSET, ambientLightRgb, animate, drawScene, getAmbientLightColor, getPointLightColor, gl, initBuffers, initWorldObjects, lastTime, moonAngle, parseRgbString, pointLightRgb, renderMoonSphere, renderStar, setAmbientLight, setPointLight, start, tick, worldObjects;
    gl = glContext.getSingleton();
    worldObjects = [];
    PAGE_UP = 33;
    PAGE_DOWN = 34;
    LEFT = 37;
    RIGHT = 39;
    UP = 38;
    DOWN = 40;
    moonAngle = 0;
    Z_OFFSET = -20;
    parseRgbString = function(rgbString) {
      var rgb, rgbArray, trimmedRgbString;
      rgb = mat3.create();
      trimmedRgbString = rgbString.substring(rgbString.indexOf('(') + 1, rgbString.length - 1);
      rgbArray = trimmedRgbString.split(',');
      rgb.r = rgbArray[0] / 255.0;
      rgb.g = rgbArray[1] / 255.0;
      rgb.b = rgbArray[2] / 255.0;
      return rgb;
    };
    getAmbientLightColor = function() {
      return parseRgbString(jQuery('#ambientColor').css('background-color'));
    };
    getPointLightColor = function() {
      return parseRgbString(jQuery('#pointLightColor').css('background-color'));
    };
    ambientLightRgb = getAmbientLightColor();
    pointLightRgb = getPointLightColor();
    setAmbientLight = function() {
      return ambientLightRgb = getAmbientLightColor();
    };
    setPointLight = function() {
      return pointLightRgb = getPointLightColor();
    };
    jQuery('#ambientColor').colorPicker({
      renderCallback: function() {
        return setAmbientLight();
      },
      forceAlpha: false
    });
    jQuery('#pointLightColor').colorPicker({
      renderCallback: function() {
        return setPointLight();
      },
      forceAlpha: false
    });
    Math.toRadians = function(degrees) {
      return degrees * Math.PI / 180.0;
    };
    initWorldObjects = function() {
      var moonSphere, star;
      moonSphere = ShapeFactory.getShape('Sphere');
      worldObjects.push(moonSphere);
      star = ShapeFactory.getShape('Star');
      star.zoom = Z_OFFSET;
      return worldObjects.push(star);
    };
    initBuffers = function() {
      var worldObject, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = worldObjects.length; _i < _len; _i++) {
        worldObject = worldObjects[_i];
        _results.push(worldObject.initBuffers());
      }
      return _results;
    };
    drawScene = function() {
      gl.viewport(0, 0, gl.viewportWidth, gl.viewportHeight);
      gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
      gl.enable(gl.BLEND);
      mat4.perspective(45, gl.viewportWidth / gl.viewportHeight, 0.1, 100.0, pMatrix);
      mat4.identity(mvMatrix.getMatrix());
      renderMoonSphere();
      return renderStar();
    };
    renderMoonSphere = function() {
      var moonSphere;
      mat4.translate(mvMatrix.getMatrix(), [0, 0, Z_OFFSET]);
      mat4.rotate(mvMatrix.getMatrix(), Math.toRadians(moonAngle), [0, 1, 0]);
      mat4.translate(mvMatrix.getMatrix(), [3, 0, 0]);
      moonSphere = worldObjects[0];
      moonSphere.useLighting = document.getElementById('useLightingCheckbox').checked;
      moonSphere.ambientLight.setRed(ambientLightRgb.r);
      moonSphere.ambientLight.setGreen(ambientLightRgb.g);
      moonSphere.ambientLight.setBlue(ambientLightRgb.b);
      moonSphere.pointLight.setRed(pointLightRgb.r);
      moonSphere.pointLight.setGreen(pointLightRgb.g);
      moonSphere.pointLight.setBlue(pointLightRgb.b);
      return moonSphere.render();
    };
    renderStar = function() {
      var star;
      star = worldObjects[1];
      star.r = pointLightRgb.r;
      star.g = pointLightRgb.g;
      star.b = pointLightRgb.b;
      return star.render();
    };
    lastTime = 0;
    animate = function() {
      var elapsedTime, timeNow;
      timeNow = new Date().getTime();
      if (lastTime !== 0) {
        elapsedTime = timeNow - lastTime;
        moonAngle += 0.05 * elapsedTime;
      }
      return lastTime = timeNow;
    };
    tick = function() {
      requestAnimFrame(tick);
      drawScene();
      return animate();
    };
    start = function() {
      initWorldObjects();
      initBuffers();
      if (gl) {
        gl.clearColor(0.0, 0.0, 0.0, 1.0);
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
      }
      return tick();
    };
    return start();
  });

}).call(this);
