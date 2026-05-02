@group(0) @binding(0) var<uniform> res:   vec2f;
@group(0) @binding(1) var<storage> a: array<f32>;
@group(0) @binding(2) var<storage> b: array<f32>;

@fragment 
fn fs( @builtin(position) pos : vec4f ) -> @location(0) vec4f {
  let x = u32(pos.x);
  let y = u32(pos.y);
  let width = u32(res.x);
  let idx = y * width + x;
  let val = b[ idx ];
  return vec4f( val, val, val, 1.);
}
