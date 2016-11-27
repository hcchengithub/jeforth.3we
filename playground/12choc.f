\
\  12choc.f -- A simulation of the 12 coins problem
\

marker --12choc.f--
vocabulary 12choc.f 
also 12choc.f definitions

cls <text> 
    <style>
        .center {
            text-align:center;
        }
        #canvas-container {
           width: 100%;
           text-align:center;
        }
        canvas {
           display: inline;
        }        
    </style>
    <h1 class=center> A simulation of the 12 coin problem</h1>
    <h3 class=center> Find the defect chocolate with the floating sponge in the bucket</h3>
    <div id="canvas-container"><canvas>Your browser doesn't support canvas</canvas></div>
    /* canvas must be defined before chipmunk modules */
    <script src="external-modules/chipmunk/cp.js"></script>
    <script src="external-modules/chipmunk/demo/demo.js"></script>
</text> /*remove*/ </o> drop 

{} constant bb // ( -- obj ) Study the bb. Now I know it's a simple object of 4 corners. 
			   /// For the bucket in this example.
{} constant water // ( -- obj ) water is a sensor shape
[] constant choc // ( -- array ) The 12 chocolates
{} constant sponge // ( -- obj ) The floating balance scale
0 value standard // ( -- n ) The standard weight of chocolates
0 value lighter // ( -- n ) The lighter chocolates' weight
0 value heavier // ( -- n ) The heavier chocolates' weight
30 constant choc_size // ( -- n ) Chocolate size

<js>

	// <canvas></canvas>
	// <script src="../cp.js"></script>
	// <script src="demo.js"></script>
	// <script src="buoyancy.js"></script>
	// <script>
	// (new Buoyancy()).run();
	// </script>

	var FLUID_DENSITY = 0.0003;
	var FLUID_DRAG = 2.0;

	var Buoyancy = function() {
		Demo.call(this);

		var space = this.space;
		space.iterations = 30;
		space.gravity = cp.v(0,-500);
		space.sleepTimeThreshold = Infinity;
		space.collisionSlop = 0.5;

		var staticBody = space.staticBody;

		// Create segments around the edge of the screen.
		// left wall of the space. Keep things in the wall to avoid falling out.
		var wall_top = 350;
		var wall_right = 760;
		
		// left wall
		var shape = space.addShape( new cp.SegmentShape(staticBody, cp.v(0,0), cp.v(0,wall_top), 0.0));
		shape.setElasticity(1.0);
		shape.setFriction(1.0);
		shape.setLayers(NOT_GRABABLE_MASK);

		// right wall
		shape = space.addShape( new cp.SegmentShape(staticBody, cp.v(wall_right,0), cp.v(wall_right,wall_top), 0.0));
		shape.setElasticity(1.0);
		shape.setFriction(1.0);
		shape.setLayers(NOT_GRABABLE_MASK);

		// bottom
		shape = space.addShape( new cp.SegmentShape(staticBody, cp.v(0,0), cp.v(wall_right,0), 0.0));
		shape.setElasticity(1.0);
		shape.setFriction(1.0);
		shape.setLayers(NOT_GRABABLE_MASK);

		// ceiling 
		// shape = space.addShape( new cp.SegmentShape(staticBody, cp.v(0,wall_top), cp.v(wall_right,wall_top), 0.0));
		// shape.setElasticity(1.0);
		// shape.setFriction(1.0);
		// shape.setLayers(NOT_GRABABLE_MASK);

		// {
			// Add the edges of the bucket
			//                 l    b    r    t
			var bb = new cp.BB(140, 65, 630, 200);   
			vm.g.bb = bb; // [x] study the bb
				// > bb (see)
				// {
				//    "l": 20,  left
				//    "b": 40,	bottom
				//    "r": 420,	right
				//    "t": 240	top
				// } OK 
				// 所以 cp.BB 是矩形 (稱作 box) 四角的參數
			
			var radius = 5.0; // 水缸的厚度

			// Left side
			shape = space.addShape( new cp.SegmentShape(staticBody, cp.v(bb.l, bb.b), cp.v(bb.l, bb.t), radius));
			shape.setElasticity(1.0);
			shape.setFriction(1.0);
			shape.setLayers(NOT_GRABABLE_MASK);

			shape = space.addShape( new cp.SegmentShape(staticBody, cp.v(bb.r, bb.b), cp.v(bb.r, bb.t), radius));
			shape.setElasticity(1.0);
			shape.setFriction(1.0);
			shape.setLayers(NOT_GRABABLE_MASK);

			shape = space.addShape( new cp.SegmentShape(staticBody, cp.v(bb.l, bb.b), cp.v(bb.r, bb.b), radius));
			shape.setElasticity(1.0);
			shape.setFriction(1.0);
			shape.setLayers(NOT_GRABABLE_MASK);

			// Add the sensor for the water.
			// [x] 去掉這一段 code 水就不見了!
			shape = space.addShape( new cp.BoxShape2(staticBody, bb) );
			shape.setSensor(true);
			shape.setCollisionType(1);
			shape.setFriction(1); // [ ] 變成冰時,希望不要滑動
			vm.g.water = shape; // [x] study the water shape
				// > water obj>keys .
				// verts,tVerts,planes,tPlanes,type,body,bb_t,bb_r,bb_b,bb_l,hashid,sensor,e,u,surface_v,
				// collision_type,group,layers,space,collisionCode,setVerts,transformVerts,transformAxes,
				// cacheData,nearestPointQuery,segmentQuery,valueOnAxis,containsVert,containsVertPartial,
				// getNumVerts,getVert,collisionTable,draw,setElasticity,setFriction,setLayers,setSensor,
				// setCollisionType,getBody,active,setBody,cacheBB,update,pointQuery,getBB,style OK 			
		// }

		// { 大塊的海綿
			var width = 450.0;
			var height = 70.0;
			var mass = 0.3*FLUID_DENSITY*width*height;
			var moment = cp.momentForBox(mass, width, height);

			body = space.addBody( new cp.Body(mass, moment));
			body.setPos( cp.v(bb.l+(bb.r-bb.l)/2, bb.b+height/2));
			body.setVel( cp.v(0, -100));
			body.setAngVel( 1 );
			// [ ] keep parameters that I don't yet know how to read back
			vm.g.sponge = body;
			vm.g.sponge.width = width;
			vm.g.sponge.height = height;
			vm.g.sponge.mass = mass;
			
			// 本 body 大塊海綿若不加進 shape 是看不見的
			shape = space.addShape( new cp.BoxShape(body, width, height));
			shape.setFriction(0.8);
		// }
		
		// { 12 chocolates 
			width = vm.g.choc_size;
			height = width;
			mass = 2.5*FLUID_DENSITY*width*height;
			
			for (var i=0; i<12; i++) {
				moment = cp.momentForBox(mass, width, height);

				body = space.addBody( new cp.Body(mass, moment));
				body.setPos(cp.v(50, 80));
				body.setVel(cp.v(0, -200));
				body.setAngVel(1);
				// body.mass = mass; // [x] body.m is its mass.

				shape = space.addShape(new cp.BoxShape(body, width, height));
				shape.setFriction(0.8);
				vm.g.choc.push(body);
			}
		// }

		space.addCollisionHandler( 1, 0, null, this.waterPreSolve, null, null);
	};

	Buoyancy.prototype = Object.create(Demo.prototype);

	Buoyancy.prototype.update = function(dt)
	{
		var steps = 3;
		dt /= steps;
		for (var i = 0; i < 3; i++){
			this.space.step(dt);
		}
	};

	Buoyancy.prototype.waterPreSolve = function(arb, space, ptr) {
		var shapes = arb.getShapes();
		var water = shapes[0];
		var poly = shapes[1];

		var body = poly.getBody();

		// Get the top of the water sensor bounding box to use as the water level.
		var level = water.getBB().t;

		// Clip the polygon against the water level
		var count = poly.getNumVerts();

		var clipped = [];

		var j=count-1;
		for(var i=0; i<count; i++) {
			var a = body.local2World( poly.getVert(j));
			var b = body.local2World( poly.getVert(i));

			if(a.y < level){
				clipped.push( a.x );
				clipped.push( a.y );
			}

			var a_level = a.y - level;
			var b_level = b.y - level;

			if(a_level*b_level < 0.0){
				var t = Math.abs(a_level)/(Math.abs(a_level) + Math.abs(b_level));

				var v = cp.v.lerp(a, b, t);
				clipped.push(v.x);
				clipped.push(v.y);
			}
			j=i;
		}

		// Calculate buoyancy from the clipped polygon area
		var clippedArea = cp.areaForPoly(clipped);

		var displacedMass = clippedArea*FLUID_DENSITY;
		var centroid = cp.centroidForPoly(clipped);
		var r = cp.v.sub(centroid, body.getPos());

		var dt = space.getCurrentTimeStep();
		var g = space.gravity;

		// Apply the buoyancy force as an impulse.
		body.applyImpulse( cp.v.mult(g, -displacedMass*dt), r);

		// Apply linear damping for the fluid drag.
		var v_centroid = cp.v.add(body.getVel(), cp.v.mult(cp.v.perp(r), body.w));
		var k = 1; //k_scalar_body(body, r, cp.v.normalize_safe(v_centroid));
		var damping = clippedArea*FLUID_DRAG*FLUID_DENSITY;
		var v_coef = Math.exp(-damping*dt*k); // linear drag
	//	var v_coef = 1.0/(1.0 + damping*dt*cp.v.len(v_centroid)*k); // quadratic drag
		body.applyImpulse( cp.v.mult(cp.v.sub(cp.v.mult(v_centroid, v_coef), v_centroid), 1.0/k), r);

		// Apply angular damping for the fluid drag.
		var w_damping = cp.momentForPoly(FLUID_DRAG*FLUID_DENSITY*clippedArea, clipped, cp.v.neg(body.p));
		body.w *= Math.exp(-w_damping*dt* (1/body.i));

		return true;
	};

	addDemo('Buoyancy', Buoyancy);
	push(new Buoyancy());
	
</js> constant Buoyancy // ( -- cp_object ) cp demo program main object

\ Hide the Demo guage board
    js: Demo.prototype.drawInfo.hide=true 

\ choc weight
	choc :> [2].m ( standard mass ) to standard
	0.14 to lighter
	standard 2 * to heavier 

\ Drag and drop chocolates is fun but using below commands are more efficient    

    0 constant vel_limit // ( -- n ) Don't move when dropping to sponge
    0 constant angVel_limit // ( -- n ) Don't rotate when dropping to sponge
    code calm ( i -- ) \ Reduce choc's horizantal speed and rotation when dropping to sponge
        var i=pop(), choc=vm.g.choc;
        var v = choc[i].getVel(); 
        v.x = Math.min(Math.abs(v.x), vm.g.vel_limit) * Math.sign(v.x);
        var w = choc[i].getAngVel();
        w = Math.min(Math.abs(w), vm.g.angVel_limit) * Math.sign(w);
        choc[i].setVel(v); 
        choc[i].setAngle(w);
        end-code

    : drop-choc-left ( i -- ) \ Drop choc[i] on the left edge of the sponge
        {} sponge :> getPos() ( i o p )
        js: tos(1).x=tos().x-vm.g.sponge.width/2+vm.g.choc_size/2
        js: tos(1).y=pop().y+vm.g.choc_size*8 ( i o )
        choc :: [tos(1)].setPos(pop())  ( i ) calm ;
        
    : drop-choc-right ( i -- ) \ Drop choc[i] on the right edge of the sponge
        {} sponge :> getPos() ( i o p )
        js: tos(1).x=tos().x+vm.g.sponge.width/2-vm.g.choc_size/2;
        js: tos(1).y=pop().y+vm.g.choc_size*8 ( i o )
        choc :: [tos(1)].setPos(pop()) ( i ) calm ;

    1200 value wait	// ( -- n ) Delay time, mS
    
    : hold< ( -- ) \ Hold the sponge to avoid shaking 
        sponge :: w_limit=0 ;
    : >hold ( -- ) \ Unhold the sponge to allow natural behavior 
        sponge :: w_limit=Infinity ;

    [] constant L [] constant R 
    : left:right ( len -- ) \ 1 2 3 4 5 6 7 8 => 1 5 2 6 3 7 4 8 where len is 4 in this example
        L :: splice(0,Infinity) R :: splice(0,Infinity) \ clear the two temp array
        >r r@ for R :: push(pop()) next r@ for L :: push(pop()) next 
        r> for L :> pop() R :> pop() next ;
    
    : home ( -- ) \ The sponge and chocs all go home, reset their positions.
        bb sponge choc <js>
            var choc = pop(); // array of all chocs
            var sponge = pop();
            var bb = pop(); // the bucket's vertices 
            for(var i=0; i<12; i++) {
                choc[i].setPos(cp.v(40,40));
                choc[i].setVel(cp.v(0,0));
            }
            sponge.setPos(cp.v(bb.l+(bb.r - bb.l)/2, bb.b+(bb.t-bb.b)/2))
            sponge.setAngVel(0); 
            sponge.setAngle(0);
        </js> 1000 nap ;
    : 6:6 ( 8 numbers -- ) \ Put 6 chocs on each side
        6 left:right home 
        hold< 6 for drop-choc-right drop-choc-left wait nap next >hold ;

    : 5:5 ( 8 numbers -- ) \ Put 5 chocs on each side
        5 left:right home
        hold< 5 for drop-choc-right drop-choc-left wait nap next >hold ;

    : 4:4 ( 8 numbers -- ) \ Put 4 chocs on each side
        4 left:right home
        hold< 4 for drop-choc-right drop-choc-left wait nap next >hold ;

    : 3:3 ( 6 numbers -- ) \ Put 3 chocs on each side
        3 left:right home
        hold< 3 for drop-choc-right drop-choc-left wait nap next >hold ;

    : 2:2 ( 4 numbers -- ) \ Put 2 chocs on each side
        2 left:right home
        hold< 2 for drop-choc-right drop-choc-left wait nap next >hold ;

    : 1:1 ( 2 numbers -- ) \ Put 1 choc on each side
        home hold< drop-choc-right drop-choc-left wait nap >hold ;

\ Auxiliary tools

    : view ( -- ) \ See all chocolates' weight
        choc <js>
            var choc = pop();
            for(var i=0; i<12; i++){
                type("Chocolate #" + i + " mass " + round(choc[i].m));
                type(" x:" + round(choc[i].p.x) + " y:" + round(choc[i].p.y) + "\n");
            }
            function round(n){
                return(Math.round(n*1000)/1000)
            }
        </js> ;

    : freeze ( -- ) \ Freeze the water
        water :: setSensor(false) ;
        
    : unfreeze ( -- ) \ Unfreeze the ice
        water :: setSensor(true) ;

    : replay ( -- ) \ Reassign the defect choc and all chocs go home
        <js>
            for(var i=0; i<12; i++){
                vm.g.choc[i].setMass(vm.g.standard);
                vm.g.choc[i].w_limit = 0.5; 
                // [ ] was Infinit, body.w is the 角速度 Anglular Velocity
                // 改小一點不要讓它亂打轉。
            }
        </js>
        random 2 * int if heavier else lighter then ( defect_weight ) 
        random 12 * int ( defect_weight i ) 
        choc :: [pop()].setMass(pop()) \ Set mass or weight of the defect chocolate
        ;

    : yo ( i -- ) \ Let the choc jump so we know which is it
        choc :: [tos()].setVel({x:0,y:200}) \ Jump the choc
        choc :: [tos()].w_limit=Infinity
        choc :: [pop()].setAngVel(30) \ Rotate the choc
        ;

    Buoyancy :: run() replay
