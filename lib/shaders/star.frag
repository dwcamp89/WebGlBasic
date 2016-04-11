precision mediump float;

varying vec2 vTextureCoord;

uniform sampler2D uSampler;
uniform vec3 uColor;

void average(in vec3 color, out float colorAverage) {
	colorAverage = (color.r + color.g + color.b) / 3.0;
}

void adjustBrightnessByLocation(inout vec4 fragmentColor, in vec2 textureLocation) {
	float distanceFromTextureCenter = distance(textureLocation, vec2(0.5, 0.5));
	float adjustedDistance = distanceFromTextureCenter * 4.0 + 1.0;
	float distanceBasedBrightnessAdjustor = 1.0 / pow(adjustedDistance, 2.0);
	vec4 distanceWeightedColor = vec4(
		distanceBasedBrightnessAdjustor, 
		distanceBasedBrightnessAdjustor, 
		distanceBasedBrightnessAdjustor, 
		0.0
	);
	fragmentColor += distanceWeightedColor;
}

void main(void) {
	vec2 textureLocation = vec2(vTextureCoord.s, vTextureCoord.t);
    vec4 textureColor = texture2D(uSampler, textureLocation);

    float averageWeightedAlpha = 0.0;
    average(textureColor.rgb, averageWeightedAlpha);

    vec4 fragmentColor = textureColor * vec4(uColor, averageWeightedAlpha);
    adjustBrightnessByLocation(fragmentColor, textureLocation);
    gl_FragColor = fragmentColor;
}