precision mediump float;

uniform sampler2D u_background;
uniform sampler2D u_texture0;
uniform sampler2D u_texture1;


varying vec2 v_texCoord;

vec2 bending(vec2 coord, vec2 center, float radius, float strength) {
    vec2 tcoord = coord;
    float dist = abs(distance(center.x, tcoord.x));
    
    if (dist < radius) {
        tcoord -= center;
        float percent = dist / radius;
        
        if (strength > 0.0) {
             tcoord.x *= mix(1.0, smoothstep(0.0, dist==0.0?99999.0:radius / dist, dist / radius), strength * 0.75);
        } else {
             tcoord.x *= mix(1.0, smoothstep(0.0, dist==0.0?99999.0:radius / dist, dist / radius), abs(strength) * 0.75);
        }
        tcoord.y += strength * radius * 0.25 * (1.0 + sin(  3.1415926 * (0.5 - percent) ));

        tcoord += center;
    }
    return tcoord;
}

mat3 squareToQuad(vec2 xy0, vec2 xy1, vec2 xy2, vec2 xy3) {
	vec2 d1 = xy1 - xy2;
	vec2 d2 = xy3 - xy2;
	vec2 d3 = xy0 - xy1 - d2;

	float det = d1.x * d2.y - d1.y * d2.x;
	float a = (d3.x * d2.y - d3.y * d2.x) / det;
	float b = (d1.x * d3.y - d1.y * d3.x) / det;

	return mat3(xy1 - xy0 + a * xy1, a,
		xy3 - xy0 + b * xy3, b,
		xy0, 1.0);
}

mat3 inverse(mat3 m) {
    float a = m[0][0], b = m[0][1], c = m[0][2];
    float d = m[1][0], e = m[1][1], f = m[1][2];
    float g = m[2][0], h = m[2][1], i = m[2][2];
    float det = a*e*i - a*f*h - b*d*i + b*f*g + c*d*h - c*e*g;
    return mat3(
        (e*i - f*h), (c*h - b*i), (b*f - c*e),
        (f*g - d*i), (a*i - c*g), (c*d - a*f),
        (d*h - e*g), (b*g - a*h), (a*e - b*d)
    ) / det;
}

mat3 perspective(vec2 before0, vec2 before1, vec2 before2, vec2 before3, vec2 after0, vec2 after1, vec2 after2, vec2 after3) {
	mat3 a = squareToQuad(after0, after1, after2, after3);
	mat3 b = squareToQuad(before0, before1, before2, before3);
	return inverse(a) * b;
}

float pattern(vec2 coord, vec2 center, float angle, float scale) {
	float s = sin(angle), c = cos(angle);
	vec2 tsize = vec2(1.0, 1.0);
    vec2 tex = coord * tsize - center;
    vec2 point = vec2(c * tex.x - s * tex.y, s * tex.x + c * tex.y) * scale;
    return (sin(point.x) * sin(point.y)) * 3.0;
}

vec4 dotmask(vec4 color, vec2 coord, vec2 center, float angle, float scale, vec3 colorized) {
	float average = (color.r + color.g + color.b) / 3.0;
	float val = average * 10.0 - 5.0 + pattern(coord, center, angle, scale);
	if( val > 3.0 ) {
		val = 3.0;
	}
	return vec4(vec3(val) * 0.2 +colorized * 0.8, color.a);
}

void main() {
	vec2 maskxy = vec2(0.578, 0.38);
	vec2 offset = maskxy + vec2(0.03, 0.08);
	float scale = 1.7;

	mat3 matrix = perspective(vec2(-0.1, 0.0), vec2(1.0, 0.0), vec2(0.0, 1.0), vec2(1.0, 1.0),
							  vec2(0.1, -0.05), vec2(0.99, 0), vec2(0.1, 1.1), vec2(1.0, 1.0));
	vec3 warp = matrix * vec3(v_texCoord, 1.0);
	vec2 coord = bending( (warp.xy / warp.z) * scale - offset, vec2(0.65, 0.5), 0.6, 0.2);

    vec4 color = texture2D(u_texture0, coord);
	color = dotmask(color, coord, vec2(0.5, 0.5), 5.0, 550.0, vec3(0.35, 0.2, 0.0));
    vec4 textureColor2 = texture2D(u_texture1, v_texCoord * scale - maskxy);

	vec2 area = offset / scale;

	vec4 back = texture2D(u_background, vec2(v_texCoord.x * 5.52/7.0 + 0.2, v_texCoord.y));
	if( v_texCoord.x < area.x || v_texCoord.x > (0.55 + area.x) || v_texCoord.y < area.y || v_texCoord.y > (0.53 + area.y) ) {
		gl_FragColor = back;
	} else {
		gl_FragColor = mix(color, textureColor2, textureColor2.a);
	}
}