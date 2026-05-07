@group(0) @binding(0) var<uniform> res:   vec2f;
@group(0) @binding(1) var<storage> state: array<f32>;

@fragment 
fn fs( @builtin(position) pos : vec4f ) -> @location(0) vec4f {
  let idx = u32(pos.y) * u32(res.x) + u32(pos.x);
  let v = state[ idx ];
  
  var color = vec3f(0.0);
  
  if (v < 0.25) {
    let t = v * 4.0;
    color = mix(vec3f(0.02, 0.02, 0.1), vec3f(0.1, 0.2, 0.5), t);
  } else if (v < 0.5) {
    let t = (v - 0.25) * 4.0;
    color = mix(vec3f(0.1, 0.2, 0.5), vec3f(0.2, 0.8, 0.9), t);
  } else if (v < 0.75) {
    let t = (v - 0.5) * 4.0;
    color = mix(vec3f(0.2, 0.8, 0.9), vec3f(1.0, 0.9, 0.3), t);
  } else {
    let t = (v - 0.75) * 4.0;
    color = mix(vec3f(1.0, 0.9, 0.3), vec3f(1.0, 1.0, 1.0), t);
  }
  
  return vec4f(color, 1.0);
}
