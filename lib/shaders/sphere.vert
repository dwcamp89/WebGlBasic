attribute vec3 aVertexPosition;
attribute vec3 aVertexNormal;
attribute vec2 aTextureCoord;

uniform mat4 uMVMatrix;
uniform mat4 uPMatrix;
uniform mat3 uNormalMatrix;

uniform vec3 uAmbientColor;

uniform vec3 uLightingDirection;
uniform vec3 uDirectionalColor;

uniform vec3 uPointLightingLocation;
uniform vec3 uPointLightingColor;

uniform bool uUseLighting;

varying vec2 vTextureCoord;
varying vec3 vLightWeighting;

void main(void) {
	vec4 mvPosition = uMVMatrix * vec4(aVertexPosition, 1.0);
	gl_Position = uPMatrix * mvPosition;
	vTextureCoord = aTextureCoord;

	if(!uUseLighting) {
		vLightWeighting = vec3(1.0, 1.0, 1.0);
	}
	else {
		vec3 transformedNormal = uNormalMatrix * aVertexNormal;
		vec3 lightDirection = normalize(uPointLightingLocation - mvPosition.xyz);
		float directionalLightWeighting = max(dot(transformedNormal, lightDirection), 0.0);
		vLightWeighting = uAmbientColor + uPointLightingColor * directionalLightWeighting;
	}
}