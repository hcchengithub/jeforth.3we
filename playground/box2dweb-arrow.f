	<comment>

		hcchen5600 2015/03/24 18:41:30 
		CSDN raymondcode 大作： [HTML5]使用Box2dWeb模拟飞行箭矢
		http://blog.csdn.net/raymondcode/article/details/8684222
		在 jeforth.3htm 上幾乎直接 ok。只把下列原 .HTML source 所
		需要的 HTML5 canvas 準備好，串接 ~.js 的路徑即可。

		<html>  
			<head>  
			<title>Box2DWeb Test</title>  
				<script type="text/javascript" src="js/Box2dWeb-2.1.a.3.min.js"></script>  
				<script type="text/javascript" src="js/arrow.js"></script>  
			</head>  
		
			<body onload="init();">  
				<canvas id="canvas" width="640" height="480" style="background-color:#333333;"></canvas>  
			</body>  
		</html>  

	</comment>

	vocabulary arrow.f also arrow.f definitions

	cls <o> <h3>Click any where in the box below . . .</h3></o> drop
	<o> <canvas id="canvas" width="640" height="480" style="background-color:#333333;"></canvas></o> constant mycv // ( -- obj ) canvas for Box2dWeb
	<h> <script type="text/javascript" src="js/box2dweb/Box2dWeb-2.1.a.3.min.js"></script></h> constant Box2dWeb // ( -- obj ) The Box2dWeb.js script element

	\ 原 game.js 改寫成 jeforth 如下：

	\ Common code for using Box2D object.
	js> Box2D.Common.Math.b2Vec2				value b2Vec2 			\ var b2Vec2 = Box2D.Common.Math.b2Vec2;
	js> Box2D.Collision.b2AABB                  value b2AABB 			\ var b2AABB = Box2D.Collision.b2AABB;
	js> Box2D.Dynamics.b2BodyDef               	value b2BodyDef 		\ var b2BodyDef = Box2D.Dynamics.b2BodyDef;
	js> Box2D.Dynamics.b2Body                  	value b2Body 			\ var b2Body = Box2D.Dynamics.b2Body;
	js> Box2D.Dynamics.b2FixtureDef            	value b2FixtureDef 	    \ var b2FixtureDef = Box2D.Dynamics.b2FixtureDef;
	js> Box2D.Dynamics.b2Fixture               	value b2Fixture 		\ var b2Fixture = Box2D.Dynamics.b2Fixture;
	js> Box2D.Dynamics.b2World                 	value b2World 		    \ var b2World = Box2D.Dynamics.b2World;
	js> Box2D.Collision.Shapes.b2PolygonShape	value b2PolygonShape	\ var b2PolygonShape = Box2D.Collision.Shapes.b2PolygonShape;
	js> Box2D.Dynamics.b2DebugDraw             	value b2DebugDraw 	    \ var b2DebugDraw = Box2D.Dynamics.b2DebugDraw;
	
	\ World constants.
	30		value worldScale 		
	0.05	value dragConstant		
	2		value dampingConstant 	
	<js> push(new g.b2World(new g.b2Vec2(0, 10),true))</js>	value world 			

	<js>
		g.onMouseDown = function (e){
			var evt = e||window.event;
			g.createArrow(e.offsetX,e.offsetY);
		}

		g.createArrow = function (pX,pY) {
			// Set the left corner as the original point.
			var angle = Math.atan2(pY-450, pX);

			// Define the shape of arrow.
			var vertices = [];
			vertices.push(new g.b2Vec2(-1.4,0));
			vertices.push(new g.b2Vec2(0,-0.1));
			vertices.push(new g.b2Vec2(0.6,0));
			vertices.push(new g.b2Vec2(0,0.1));

			var bodyDef = new g.b2BodyDef;
			bodyDef.type = g.b2Body.b2_dynamicBody;
			bodyDef.position.Set(40/g.worldScale,400/g.worldScale);
			bodyDef.userData = "Arrow";

			var polygonShape = new g.b2PolygonShape;
			polygonShape.SetAsVector(vertices,4);

			var fixtureDef = new g.b2FixtureDef;
			fixtureDef.density = 1.0;
			fixtureDef.friction = 0.5;
			fixtureDef.restitution = 0.5;
			fixtureDef.shape = polygonShape;
			
			var body = g.world.CreateBody(bodyDef);
			body.CreateFixture(fixtureDef);

			// Set original state of arrow.
			body.SetLinearVelocity(new g.b2Vec2(20*Math.cos(angle), 20*Math.sin(angle)));
			body.SetAngle(angle);
			body.SetAngularDamping(g.dampingConstant);
			return(body);
		}

		g.createBox = function (width,height,pX,pY,type,data) {
			var bodyDef = new g.b2BodyDef;
			bodyDef.type = type;
			bodyDef.position.Set(pX/g.worldScale,pY/g.worldScale);
			bodyDef.userData=data;

			var polygonShape = new g.b2PolygonShape;
			polygonShape.SetAsBox(width/2/g.worldScale,height/2/g.worldScale);

			var fixtureDef = new g.b2FixtureDef;
			fixtureDef.density = 1.0;
			fixtureDef.friction = 0.5;
			fixtureDef.restitution = 0.5;
			fixtureDef.shape = polygonShape;
			
			var body=g.world.CreateBody(bodyDef);
			body.CreateFixture(fixtureDef);
		}
		
		g.debugDraw = function () {
			var debugDraw = new g.b2DebugDraw();
			debugDraw.SetSprite(document.getElementById("canvas").getContext("2d"));
			debugDraw.SetDrawScale(g.worldScale);
			debugDraw.SetFillAlpha(0.5);
			debugDraw.SetLineThickness(1.0);
			debugDraw.SetFlags(g.b2DebugDraw.e_shapeBit | g.b2DebugDraw.e_jointBit);
			g.world.SetDebugDraw(debugDraw);
		}
		
		g.update = function () { 
			g.world.Step(1/60,10,10);
			g.world.ClearForces();

			for(var b = g.world.m_bodyList; b != null; b = b.m_next){
			   if(b.GetUserData() === "Arrow") {
						g.updateArrow(b);
					}
			}
			
			g.world.DrawDebugData();
		}

		g.updateArrow = function (arrowBody) {
			// Calculate arrow's fligth speed.
			var flightSpeed = g.Normalize2(arrowBody.GetLinearVelocity());

			// Calculate arrow's pointing direction.
			var bodyAngle = arrowBody.GetAngle();
			var pointingDirection = new g.b2Vec2(Math.cos(bodyAngle), -Math.sin(bodyAngle));

			// Calculate arrow's flighting direction and normalize it.
			var flightAngle = Math.atan2(arrowBody.GetLinearVelocity().y,arrowBody.GetLinearVelocity().x);
			var flightDirection = new g.b2Vec2(Math.cos(flightAngle), Math.sin(flightAngle));

			// Calculate dot production.
			var dot = g.b2Dot( flightDirection, pointingDirection );
			var dragForceMagnitude = (1 - Math.abs(dot)) * flightSpeed * flightSpeed * g.dragConstant * arrowBody.GetMass();
			var arrowTailPosition = arrowBody.GetWorldPoint(new g.b2Vec2( -1.4, 0 ) );
			arrowBody.ApplyForce( new g.b2Vec2(dragForceMagnitude*-flightDirection.x,dragForceMagnitude*-flightDirection.y), arrowTailPosition );
		}

		g.b2Dot = function (a, b) {
			return a.x * b.x + a.y * b.y;
		}

		g.Normalize2 = function (b) {
			return Math.sqrt(b.x * b.x + b.y * b.y);
		}

		//http://js-tut.aardon.de/js-tut/tutorial/position.html
		g.getElementPosition = function (element) {
			var elem=element, tagname="", x=0, y=0;
			while((typeof(elem) == "object") && (typeof(elem.tagName) != "undefined")) {
				y += elem.offsetTop;
				x += elem.offsetLeft;
				tagname = elem.tagName.toUpperCase();
				if(tagname == "BODY"){
					elem=0;
				}
				if(typeof(elem) == "object"){
					if(typeof(elem.offsetParent) == "object"){
						elem = elem.offsetParent;
					}
				}
			}
			return {x: x, y: y};
		}
	</js>

	\ Get canvas for drawing.
	js> g.getElementPosition(canvas) 	value canvasPosition
	js> canvas.getContext("2d")			value context

	\ Create bottom wall
	js: g.createBox(640,30,320,480,g.b2Body.b2_staticBody,null);
	\ Create top wall
	js: g.createBox(640,30,320,0,g.b2Body.b2_staticBody,null);
	\ Create left wall
	js: g.createBox(30,480,0,240,g.b2Body.b2_staticBody,null);
	\ Create right wall
	js: g.createBox(30,480,640,240,g.b2Body.b2_staticBody,null);
	
	\ document.addEventListener("mousedown",onMouseDown);
	js: canvas.onmousedown=g.onMouseDown
	js: g.debugDraw()
	js: setInterval(g.update,1000/60);

	<comment>
	
	[x]	Compare the two cases:

		Without Box2Dweb-arrow.f
		js> window obj>keys .
		["top","window","location",... snip ...]

		Included Box2Dweb-arrow.f
		js> window obj>keys .
		["top","window","location",... snip ...]

		<js>
		var pool = ["top","window","location","external","chrome","document","$","jQuery","kvm","script1428912357997","f","speechSynthesis","webkitStorageInfo","indexedDB","webkitIndexedDB","crypto","localStorage","sessionStorage","applicationCache","CSS","performance","console","devicePixelRatio","styleMedia","parent","opener","frames","self","defaultstatus","defaultStatus","status","name","length","closed","pageYOffset","pageXOffset","scrollY","scrollX","screenTop","screenLeft","screenY","screenX","innerWidth","innerHeight","outerWidth","outerHeight","frameElement","clientInformation","navigator","toolbar","statusbar","scrollbars","personalbar","menubar","locationbar","history","screen","ondeviceorientation","ondevicemotion","postMessage","close","blur","focus","onautocompleteerror","onautocomplete","ontouchstart","ontouchmove","ontouchend","ontouchcancel","onunload","onstorage","onpopstate","onpageshow","onpagehide","ononline","onoffline","onmessage","onlanguagechange","onhashchange","onbeforeunload","onwaiting","onvolumechange","ontoggle","ontimeupdate","onsuspend","onsubmit","onstalled","onshow","onselect","onseeking","onseeked","onscroll","onresize","onreset","onratechange","onprogress","onplaying","onplay","onpause","onmousewheel","onmouseup","onmouseover","onmouseout","onmousemove","onmouseleave","onmouseenter","onmousedown","onloadstart","onloadedmetadata","onloadeddata","onload","onkeyup","onkeypress","onkeydown","oninvalid","oninput","onfocus","onerror","onended","onemptied","ondurationchange","ondrop","ondragstart","ondragover","ondragleave","ondragenter","ondragend","ondrag","ondblclick","oncuechange","oncontextmenu","onclose","onclick","onchange","oncanplaythrough","oncanplay","oncancel","onblur","onabort","onwheel","onwebkittransitionend","onwebkitanimationstart","onwebkitanimationiteration","onwebkitanimationend","ontransitionend","onsearch","getSelection","print","stop","open","alert","confirm","prompt","find","moveBy","moveTo","resizeBy","resizeTo","matchMedia","getComputedStyle","getMatchedCSSRules","requestAnimationFrame","cancelAnimationFrame","webkitRequestAnimationFrame","webkitCancelAnimationFrame","webkitCancelRequestAnimationFrame","captureEvents","releaseEvents","btoa","atob","setTimeout","clearTimeout","setInterval","clearInterval","scrollBy","scrollTo","scroll","TEMPORARY","PERSISTENT","webkitRequestFileSystem","webkitResolveLocalFileSystemURL","openDatabase","addEventListener","removeEventListener","dispatchEvent"];
		var added = ["top","window","location","external","chrome","document","$","jQuery","kvm","script1428911778743","f","Box2D","Vector","Vector_a2j_Number","i","speechSynthesis","webkitStorageInfo","indexedDB","webkitIndexedDB","crypto","localStorage","sessionStorage","applicationCache","CSS","performance","console","devicePixelRatio","styleMedia","parent","opener","frames","self","defaultstatus","defaultStatus","status","name","length","closed","pageYOffset","pageXOffset","scrollY","scrollX","screenTop","screenLeft","screenY","screenX","innerWidth","innerHeight","outerWidth","outerHeight","frameElement","clientInformation","navigator","toolbar","statusbar","scrollbars","personalbar","menubar","locationbar","history","screen","ondeviceorientation","ondevicemotion","postMessage","close","blur","focus","onautocompleteerror","onautocomplete","ontouchstart","ontouchmove","ontouchend","ontouchcancel","onunload","onstorage","onpopstate","onpageshow","onpagehide","ononline","onoffline","onmessage","onlanguagechange","onhashchange","onbeforeunload","onwaiting","onvolumechange","ontoggle","ontimeupdate","onsuspend","onsubmit","onstalled","onshow","onselect","onseeking","onseeked","onscroll","onresize","onreset","onratechange","onprogress","onplaying","onplay","onpause","onmousewheel","onmouseup","onmouseover","onmouseout","onmousemove","onmouseleave","onmouseenter","onmousedown","onloadstart","onloadedmetadata","onloadeddata","onload","onkeyup","onkeypress","onkeydown","oninvalid","oninput","onfocus","onerror","onended","onemptied","ondurationchange","ondrop","ondragstart","ondragover","ondragleave","ondragenter","ondragend","ondrag","ondblclick","oncuechange","oncontextmenu","onclose","onclick","onchange","oncanplaythrough","oncanplay","oncancel","onblur","onabort","onwheel","onwebkittransitionend","onwebkitanimationstart","onwebkitanimationiteration","onwebkitanimationend","ontransitionend","onsearch","getSelection","print","stop","open","alert","confirm","prompt","find","moveBy","moveTo","resizeBy","resizeTo","matchMedia","getComputedStyle","getMatchedCSSRules","requestAnimationFrame","cancelAnimationFrame","webkitRequestAnimationFrame","webkitCancelAnimationFrame","webkitCancelRequestAnimationFrame","captureEvents","releaseEvents","btoa","atob","setTimeout","clearTimeout","setInterval","clearInterval","scrollBy","scrollTo","scroll","TEMPORARY","PERSISTENT","webkitRequestFileSystem","webkitResolveLocalFileSystemURL","openDatabase","addEventListener","removeEventListener","dispatchEvent"];
		for (var i=0; i<added.length; i++){
			for (var j=0; j<pool.length; j++){
				var found = false;
				if (added[i]==pool[j]){
					found = true;
					break;
				}
			}
			if (!found) print(added[i]+'\n');
		}
		</js>

		結果確定多出了這幾個東西：
			script1428911778743   <===== should be Box2dWeb-2.1.a.3.min.js I guess. No! it's an integer 1.
			Box2D ==> obj>keys ==> inherit,generateCallback,NVector,is,parseUInt,Collision,Common,Dynamics OK 
			Vector ==> Vector(x,y) function returns [x,y]
			Vector_a2j_Number 
			i
	[ ]	g.debugDraw() 一定得鮮跑一次, 否則之後的 g.update() 也無效。[ ] why?
	[ ] body 只管給初始條件 create 出來，然後不必去管它。故原程式都沒有用 variable 保留牆、矢等的 object。
	[ ] g.createBox , g.createArrow() 可見得 body 需要哪些初始值。

	</comment>


