// Generated by CoffeeScript 1.9.0
(function() {
  define(['Cube', 'Pyramid', 'TexturedCube', 'IlluminatedCube'], function(Cube, Pyramid, TexturedCube, IlluminatedCube) {
    return {
      getShape: function(type) {
        if (type === 'Cube') {
          return Cube.getInstance();
        } else if (type === 'Pyramid') {
          return Pyramid.getInstance();
        } else if (type === 'TexturedCube') {
          return TexturedCube.getInstance();
        } else if (type === 'IlluminatedCube') {
          return IlluminatedCube.getInstance();
        } else {
          return null;
        }
      }
    };
  });

}).call(this);