// Generated by CoffeeScript 1.9.0
(function() {
  define(['Cube', 'Pyramid', 'TexturedCube', 'IlluminatedCube', 'Star', 'Sphere'], function(Cube, Pyramid, TexturedCube, IlluminatedCube, Star, Sphere) {
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
        } else if (type === 'Star') {
          return Star.getInstance();
        } else if (type === 'Sphere') {
          return Sphere.getInstance();
        } else {
          return null;
        }
      }
    };
  });

}).call(this);
