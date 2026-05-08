import { default as seagulls } from './gulls.js'

const WORKGROUP_SIZE = 64,
      NUM_AGENTS = 256,
      DISPATCH_COUNT = [NUM_AGENTS/WORKGROUP_SIZE,1,1],
      GRID_SIZE = 2,
      STARTING_AREA = .3

const W = Math.round( window.innerWidth  / GRID_SIZE ),
      H = Math.round( window.innerHeight / GRID_SIZE )

const render_shader = seagulls.constants.vertex + `
@group(0) @binding(0) var<storage> pheromones: array<f32>;
@group(0) @binding(1) var<storage> render: array<f32>;

@fragment 
fn fs( @builtin(position) pos : vec4f ) -> @location(0) vec4f {
  let grid_pos = floor( pos.xy / ${GRID_SIZE}.);
  
  let pidx = grid_pos.y  * ${W}. + grid_pos.x;
  let p = pheromones[ u32(pidx) ];
  let v = render[ u32(pidx) ];

  let vantColor    = vec3(0., 1., 0.);

  let pheromoneCol = vec3(1., 0.3, 1.);

  let vantOrPhero = select( pheromoneCol * p, vantColor, v == 1. );
  let out = select( vec3(0.,0.,0.), vantOrPhero, p != 0. || v == 1. );
  return vec4f(out, 1.);

}`

const compute_shader =`
struct Vant {
  pos: vec2f,
  dir: f32,
  flag: f32
}

@group(0) @binding(0) var<storage, read_write> vants: array<Vant>;
@group(0) @binding(1) var<storage, read_write> pheremones: array<f32>;
@group(0) @binding(2) var<storage, read_write> render: array<f32>;

fn pheromoneIndex( vant_pos: vec2f ) -> u32 {
  let width = ${W}.;
  return u32( abs( vant_pos.y % ${H}. ) * width + vant_pos.x );
}

@compute
@workgroup_size(${WORKGROUP_SIZE},1,1)

fn cs(@builtin(global_invocation_id) cell:vec3u)  {
  let pi2   = ${Math.PI*2}; 
  var vant:Vant  = vants[ cell.x ];

  let pIndex    = pheromoneIndex(vant.pos);
  let pheromone = pheremones[pIndex];

  let pi2_local = pi2;


  let sensorDist = 5.0;
  let turnSpeed   = 0.30;

  let rightDir   = vec2f(sin((vant.dir + 0.25) * pi2), cos((vant.dir + 0.25) * pi2));

  let leftDir    = -rightDir;

  let rightPos   = vant.pos + rightDir * sensorDist;
  let leftPos    = vant.pos + leftDir  * sensorDist;

  let rightIdx   = pheromoneIndex(rightPos);
  let leftIdx    = pheromoneIndex(leftPos);

  let rightP     = pheremones[rightIdx];
  let leftP      = pheremones[leftIdx];


  let sideDiff = leftP - rightP;
  let sideDir  = select(-1.0, 1.0, sideDiff > 0.0);
  let followSign = select(-1.0, 1.0, vant.flag == 0.);
  vant.dir += sideDir * followSign * turnSpeed;


  let hasPhero = pheromone != 0.;

  let turnStrong = 0.45;
  let turnWeak   = 0.20;


  if(hasPhero) {
    let baseTurn = select(turnStrong, -turnStrong, vant.flag != 0.);
    vant.dir += baseTurn + select(-turnWeak, turnWeak, vant.flag == 0.);
    pheremones[ pIndex ] = 0.;
  } else {
    let baseTurn = select(-turnWeak, turnStrong, vant.flag == 0.);
    vant.dir += baseTurn;
    pheremones[pIndex] = 1.;
  }


  let wobble = 0.12 * sin((vant.pos.x + vant.pos.y) * 0.17 + vant.dir * 3.1);
  vant.dir += wobble;


  let dir = vec2f(sin(vant.dir * pi2), cos(vant.dir * pi2));
  
  vant.pos = round(vant.pos + dir); 

  vants[cell.x] = vant;
  

  render[pIndex] = 1.;
}`
 
const NUM_PROPERTIES = 4

const pheromones   = new Float32Array(W*H)
const vants_render = new Float32Array(W*H)
const vants        = new Float32Array(NUM_AGENTS * NUM_PROPERTIES)


const offset = .5 - STARTING_AREA / 2
for( let i = 0; i < NUM_AGENTS * NUM_PROPERTIES; i+= NUM_PROPERTIES) {
  vants[ i ]   = Math.floor((offset+Math.random()*STARTING_AREA) * W)
  vants[ i+1 ] = Math.floor((offset+Math.random()*STARTING_AREA) * H)
  vants[ i+2 ] = 0
  vants[ i+3 ] = Math.round(Math.random() )

}

const sg = await seagulls.init()
const pheromones_b = sg.buffer( pheromones )
const vants_b  = sg.buffer(vants)
const render_b = sg.buffer(vants_render)

const render = await sg.render({
  shader: render_shader,
  data:[
    pheromones_b,
    render_b
  ],
})

const compute = sg.compute({
  shader: compute_shader,
  data:[
    vants_b,
    pheromones_b,
    render_b
  ],
  onframe() {render_b.clear()},
  dispatchCount:DISPATCH_COUNT
})

sg.run( compute, render )