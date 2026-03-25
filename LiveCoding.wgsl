@fragment 
fn fs( @builtin(position) pos : vec4f ) -> @location(0) vec4f {
  // create normalized position coordinates in range 0-1
  var p : vec2f = pos.xy / res;
  let frequency = 10.;
  let thickness = 0.4;

var r: f32 = 0.;
var g: f32 = 0.;
var b: f32 = 0.;

//color and shape
if(frame < 4800){
	p.x += cos( p.y * frequency + (frame/240.) * 1.5 ) * .5 - .5;
	p.x += cos( p.x * frequency + (frame/240.) * 1.5 ) * .5 - .5;
	b = 0.5;
}

else if(frame < 9600){
	p.x += sin( p.y * frequency + (frame/240.) * 1.5 ) * .5 - .5;
	p.x += sin( p.x * frequency + (frame/240.) * 1.5 ) * .5 - .5;
	r = 0.7;
	g = 0.7;
	b = 0.;
}

else if(frame < 19200){
	p.x += tan( p.y * frequency + (frame/240.) * 1.5 ) * .5 - .5; 
	p.x += tan( p.x * frequency + (frame/240.) * 1.5 ) * .5 - .5; 
	r = 0.;
	b = 0.;
	g = 0.;}

var color = 0.5 + abs( thickness / p.x ) * 0.5 - 0.2;
var last = lastframe( rotate( uvN( pos.xy ), seconds()/960. ) );
var now = vec4f(color + r, color + g, color + b, 1.);
var out = now * .02 + last * .95;

//feedback trigger
if(frame < 2400){
	out = now;
}

else if(frame < 9600){
	last = lastframe( rotate (uvN( pos.xy ), seconds()/960.) );
	out = now * .02 + last * .95;
}

else if(frame < 12000){
	last = lastframe( rotate (uvN( pos.xy ), seconds()/960.) );
	out = now * (.01 + (frame - 12000)/(14400 - 12000)) + last * (1 - (frame - 12000)/(14400 - 12000));
}

else if(frame < 14400){
	last = lastframe( rotate (uvN( pos.xy ), seconds()/960.) );
	out = now * (1.01 - (frame - 14400)/(19200 - 14400)) + last * (.01 + (frame - 14400)/(19200- 14400));
}

else if(frame < 19200){
	last = lastframe( rotate (uvN( pos.xy ), seconds()/960.) );
	out = now * .02 + last * .95;
}


	return select( 1.-out, out, mouse.z == 0.);
}