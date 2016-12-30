\
\  Chipmunk demo : Balls
\

s" balls.f" source-code-header
true  constant privacy // ( -- true ) All words in this module are private"


<o> <canvas></canvas></o> constant canvas // ( -- element ) The canvas of this demo.
<h> 
	<script src="external-modules/chipmunk/cp.js"></script>
	<script src="external-modules/chipmunk/demo/demo.js"></script>
</h> drop

\ {} constant rock // ( -- obj ) The rock body in the chipmunk space
[] constant bodies // ( -- array ) \ Array of all bodies in the space

<js>

	// <script src="ball.js"></script>
	// <script>
	// (new Balls()).run();
	// </script>
	
	var Balls = function() {
		Demo.call(this);

		var space = this.space;
		space.iterations = 60;
		space.gravity = v(0, 0); // was -500
		space.sleepTimeThreshold = 0.5;
		space.collisionSlop = 0.5;

		this.addFloor();
		this.addWalls();
		
		
		var width = 50;
		var height = 60;
		var mass = width * height * 1/1000;
		var rock = space.addBody(new cp.Body(mass, cp.momentForBox(mass, width, height)));
		rock.setPos(v(500, 100));
		rock.setAngle(3.1416/4);
		rock.name = 'rock';
		var shape = space.addShape(new cp.BoxShape(rock, width, height));
		shape.setFriction(0.8);
		shape.setElasticity(0.3);
		vm[context].bodies.push(rock); 

		for (var i = 1; i <= 10; i++) {
			var radius = 20;
			mass = 3;
			var body = space.addBody(new cp.Body(mass, cp.momentForCircle(mass, 0, radius, v(0, 0))));
			body.setPos(v(200 + i, (2 * radius + 5) * i));
			body.name="ball#"+i;
			vm[context].bodies.push(body); 
			var circle = space.addShape(new cp.CircleShape(body, radius, v(0, 0)));
			circle.setElasticity(0.1);
			circle.setFriction(10);
		}
	/*
		atom.canvas.onmousedown = function(e) {
		  radius = 10;
		  mass = 3;
		  body = space.addBody(new cp.Body(mass, cp.momentForCircle(mass, 0, radius, v(0, 0))));
		  body.setPos(v(e.clientX, e.clientY));
		  circle = space.addShape(new cp.CircleShape(body, radius, v(0, 0)));
		  circle.setElasticity(0.5);
		  return circle.setFriction(1);
		};
	*/

		this.ctx.strokeStyle = "black";

		var ramp = space.addShape(new cp.SegmentShape(space.staticBody, v(100, 100), v(300, 200), 10));
		ramp.setElasticity(1);
		ramp.setFriction(1);
		ramp.setLayers(NOT_GRABABLE_MASK);
		ramp.name='ramp';
	};

	Balls.prototype = Object.create(Demo.prototype);

	addDemo('Balls', Balls);

	push(new Balls());
	
</js> constant Balls // ( -- cp_object ) cp demo program main object

cr 
.( help Balls )
help Balls
cr

.( Balls obj>keys . cr ) cr
Balls obj>keys . cr cr

.(( Balls :: run() )) cr
Balls :: run()

