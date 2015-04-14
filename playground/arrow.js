function init() {
    // Common code for using Box2D object.
    var b2Vec2 = Box2D.Common.Math.b2Vec2;
    var b2AABB = Box2D.Collision.b2AABB;
    var b2BodyDef = Box2D.Dynamics.b2BodyDef;
    var b2Body = Box2D.Dynamics.b2Body;
    var b2FixtureDef = Box2D.Dynamics.b2FixtureDef;
    var b2Fixture = Box2D.Dynamics.b2Fixture;
    var b2World = Box2D.Dynamics.b2World;
    var b2PolygonShape = Box2D.Collision.Shapes.b2PolygonShape;
    var b2DebugDraw = Box2D.Dynamics.b2DebugDraw;
    
    // Get canvas for drawing.
    var canvas = document.getElementById("canvas");
    var canvasPosition = getElementPosition(canvas);
    var context = canvas.getContext("2d");
    
    // World constants.
    var worldScale = 30;
    var dragConstant=0.05;
    var dampingConstant = 2;
    var world = new b2World(new b2Vec2(0, 10),true);
    
    // document.addEventListener("mousedown",onMouseDown);
	canvas.onmousedown = onMouseDown;
    debugDraw();             
    window.setInterval(update,1000/60);

    // Create bottom wall
    createBox(640,30,320,480,b2Body.b2_staticBody,null);
    // Create top wall
    createBox(640,30,320,0,b2Body.b2_staticBody,null);
    // Create left wall
    createBox(30,480,0,240,b2Body.b2_staticBody,null);
    // Create right wall
    createBox(30,480,640,240,b2Body.b2_staticBody,null);
    
    function onMouseDown(e){
        var evt = e||window.event;
        // createArrow(e.clientX-canvasPosition.x,e.clientY-canvasPosition.y);
        createArrow(e.offsetX,e.offsetY);
		if(kvm.debug){kvm.jsc.prompt='222>>>';eval(kvm.jsc.xt)}
    }

    function createArrow(pX,pY) {
        // Set the left corner as the original point.
        var angle = Math.atan2(pY-450, pX);

        // Define the shape of arrow.
        var vertices = [];
        vertices.push(new b2Vec2(-1.4,0));
		vertices.push(new b2Vec2(0,-0.1));
		vertices.push(new b2Vec2(0.6,0));
    	vertices.push(new b2Vec2(0,0.1));

        var bodyDef = new b2BodyDef;
        bodyDef.type = b2Body.b2_dynamicBody;
        bodyDef.position.Set(40/worldScale,400/worldScale);
        bodyDef.userData = "Arrow";

        var polygonShape = new b2PolygonShape;
        polygonShape.SetAsVector(vertices,4);

        var fixtureDef = new b2FixtureDef;
        fixtureDef.density = 1.0;
        fixtureDef.friction = 0.5;
        fixtureDef.restitution = 0.5;
        fixtureDef.shape = polygonShape;
        
        var body = world.CreateBody(bodyDef);
        body.CreateFixture(fixtureDef);

        // Set original state of arrow.
        body.SetLinearVelocity(new b2Vec2(20*Math.cos(angle), 20*Math.sin(angle)));
        body.SetAngle(angle);
        body.SetAngularDamping(dampingConstant);
    }

    function createBox(width,height,pX,pY,type,data) {
        var bodyDef = new b2BodyDef;
        bodyDef.type = type;
        bodyDef.position.Set(pX/worldScale,pY/worldScale);
        bodyDef.userData=data;

        var polygonShape = new b2PolygonShape;
        polygonShape.SetAsBox(width/2/worldScale,height/2/worldScale);

        var fixtureDef = new b2FixtureDef;
        fixtureDef.density = 1.0;
        fixtureDef.friction = 0.5;
        fixtureDef.restitution = 0.5;
        fixtureDef.shape = polygonShape;
        
        var body=world.CreateBody(bodyDef);
        body.CreateFixture(fixtureDef);
    }
    
    function debugDraw() {
        var debugDraw = new b2DebugDraw();
        debugDraw.SetSprite(document.getElementById("canvas").getContext("2d"));
        debugDraw.SetDrawScale(worldScale);
        debugDraw.SetFillAlpha(0.5);
        debugDraw.SetLineThickness(1.0);
        debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
        world.SetDebugDraw(debugDraw);
    }
    
    function update() { 
        world.Step(1/60,10,10);
        world.ClearForces();

        for(var b = world.m_bodyList; b != null; b = b.m_next){
           if(b.GetUserData() === "Arrow") {
                    updateArrow(b);
                }
        }
        
        world.DrawDebugData();
    }

    function updateArrow(arrowBody) {
        // Calculate arrow's fligth speed.
        var flightSpeed = Normalize2(arrowBody.GetLinearVelocity());

        // Calculate arrow's pointing direction.
        var bodyAngle = arrowBody.GetAngle();
        var pointingDirection = new b2Vec2(Math.cos(bodyAngle), -Math.sin(bodyAngle));

        // Calculate arrow's flighting direction and normalize it.
        var flightAngle = Math.atan2(arrowBody.GetLinearVelocity().y,arrowBody.GetLinearVelocity().x);
        var flightDirection = new b2Vec2(Math.cos(flightAngle), Math.sin(flightAngle));

        // Calculate dot production.
        var dot = b2Dot( flightDirection, pointingDirection );
        var dragForceMagnitude = (1 - Math.abs(dot)) * flightSpeed * flightSpeed * dragConstant * arrowBody.GetMass();
        var arrowTailPosition = arrowBody.GetWorldPoint(new b2Vec2( -1.4, 0 ) );
        arrowBody.ApplyForce( new b2Vec2(dragForceMagnitude*-flightDirection.x,dragForceMagnitude*-flightDirection.y), arrowTailPosition );
    }

    function b2Dot(a, b) {
        return a.x * b.x + a.y * b.y;
    }

    function Normalize2(b) {
        return Math.sqrt(b.x * b.x + b.y * b.y);
    }

    //http://js-tut.aardon.de/js-tut/tutorial/position.html
    function getElementPosition(element) {
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

};

