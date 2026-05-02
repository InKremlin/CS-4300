@group(0) @binding(0) var<uniform> res: vec2f;
@group(0) @binding(1) var<uniform> dt: f32;
@group(0) @binding(2) var<uniform> DA: f32;
@group(0) @binding(3) var<uniform> DB: f32;
@group(0) @binding(4) var<uniform> feed: f32;
@group(0) @binding(5) var<uniform> kill: f32;
@group(0) @binding(6) var<storage> a_in: array<f32>;
@group(0) @binding(7) var<storage, read_write> a_out: array<f32>;
@group(0) @binding(8) var<storage> b_in: array<f32>;
@group(0) @binding(9) var<storage, read_write> b_out: array<f32>;

fn index( x:i32, y:i32 ) -> u32 {
  let _res = vec2i(res);
  return u32( (y % _res.y) * _res.x + ( x % _res.x ) );
}

@compute
@workgroup_size(8,8)
fn cs( @builtin(global_invocation_id) _cell:vec3u ) {
  let cell = vec3i(_cell);
  let i = index(cell.x, cell.y);
  let normalized_x = f32(cell.x) / (res.x - 1.0);
  let normalized_y = f32(cell.y) / (res.y - 1.0);

  //get previous state
  let a = a_in[i];
  let b = b_in[i];

  // Laplacian
  let LaplacianHorizontalWeight = 0.12;
  let LaplacianVerticalWeight = 0.28;
  let LaplacianDiagonalWeight = 0.05;
  let lap_a = LaplacianDiagonalWeight * a_in[index(cell.x + 1, cell.y + 1)] +  
              LaplacianHorizontalWeight * a_in[index(cell.x + 1, cell.y)] +     
              LaplacianDiagonalWeight * a_in[index(cell.x + 1, cell.y - 1)] + 
              LaplacianVerticalWeight * a_in[index(cell.x, cell.y - 1)] +     
              LaplacianDiagonalWeight * a_in[index(cell.x - 1, cell.y - 1)] + 
              LaplacianHorizontalWeight * a_in[index(cell.x - 1, cell.y)] +     
              LaplacianDiagonalWeight * a_in[index(cell.x - 1, cell.y + 1)] + 
              LaplacianVerticalWeight * a_in[index(cell.x, cell.y + 1)] +     
              -1.0 * a;  // center

  let lap_b = LaplacianDiagonalWeight * b_in[index(cell.x + 1, cell.y + 1)] + 
              LaplacianHorizontalWeight * b_in[index(cell.x + 1, cell.y)] +     
              LaplacianDiagonalWeight * b_in[index(cell.x + 1, cell.y - 1)] + 
              LaplacianVerticalWeight * b_in[index(cell.x, cell.y - 1)] +     
              LaplacianDiagonalWeight * b_in[index(cell.x - 1, cell.y - 1)] + 
              LaplacianHorizontalWeight * b_in[index(cell.x - 1, cell.y)] +     
              LaplacianDiagonalWeight * b_in[index(cell.x - 1, cell.y + 1)] + 
              LaplacianVerticalWeight * b_in[index(cell.x, cell.y + 1)] +     
              -1.0 * b;  // center

  // Reaction terms
  let ab2 = a * b * b;
  let reaction_a = -ab2 + feed * (1.0 - a);
  let reaction_b = ab2 - (feed + kill) * b;

  // Update
  a_out[i] = a + dt * (DA * lap_a + reaction_a);
  b_out[i] = b + dt * (DB * lap_b + reaction_b);
}
