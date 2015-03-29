\
\  chipmunk.js demo program 'Pyramid Stack' play'ed on jeforth.3we
\  hcchen5600 2015/03/27 15:34:21 	
\

char chipmunk-js-pyramidstack.f source-code-header

er 
<text>
\
\  chipmunk.js demo program 'Pyramid Stack' play'ed on jeforth.3we
\  hcchen5600 2015/03/27 15:34:21 	
\
	您正在執行的 (可能) 是：
	
		http://www.figtaiwan.org/project/jeforth/jeforth.3we-master/index.html?include_chipmunk-js-pyramidstack.f
	
	我已經把 chipmunk.js 整包都放好在 js/chipmunk.js 處，可以開始來玩了。您可能想看它的 source code
	且在 local computer 上試跑它的 demo 請往 金城老使指點的 Github 去 download。從它的 demo 裡隨便
	找一個來看 ~.html 檔，人家怎麼開始玩的？ 例如 js/chipmunk.js/demo/PyramidStack.html 內容是：
	
		<canvas></canvas>
		<script src="../cp.js"></script>
		<script src="demo.js"></script>
		<script src="PyramidStack.js"></script>
		<script>
		(new PyramidStack()).run();
		</script> 
	
	這麼簡單！那 jeforth.3we 肯定手動就可以 run 得起來，照實際位置改一下路徑，變成：
	
		<canvas></canvas>
		<script src="js/chipmunk.js/cp.js"></script>
		<script src="js/chipmunk.js/demo/demo.js"></script>
		<script src="js/chipmunk.js/demo/PyramidStack.js"></script>
		<script>
		(new PyramidStack()).run();
		</script> 
	
	當然 jeforth.3we 不認得 HTML tags, 請用 <o> ... </o> 把以上整段包起來, jeforth.3we 就知道要把它
	丟給 DOM 去處理。如下：
	
		<o>
		<canvas></canvas>
		<script src="js/chipmunk.js/cp.js"></script>
		<script src="js/chipmunk.js/demo/demo.js"></script>
		<script src="js/chipmunk.js/demo/PyramidStack.js"></script>
		<script>
		(new PyramidStack()).run();
		</script> 
		</o> drop
	
	<o>..</o> 的意思是「把這塊 HTML tags 放進 outputbox div 裡去，傳回最後一個 element」。請嘗試在 
	jeforth.3we 的 inputbox（畫面上灰灰的那一橫條）輸入：

		<o> <h1>Hello</h1><h3>world!!</h3></o>

	看看 jeforth.3we 的 outputbox 上有何結果（大大的 Hello 略小的 world!!）。然後查看 data stack .s 
	看到 [object HTMLHeadingElement] (object) 正是以上 <h3>world!!</h3> 的 object 本身。下達 ce! ( 
	意思是：current element 設成 TOS 這個) 然後下 ce 命令 (意思是： view current element) 就可以看到
	是它沒錯。以上是 <o>..</o> 的簡介。回到主題，把上面包裝好的 chipmunk.js demo 程式 PyramidStack 
	整段 copy - paste 到 jeforth.3we 的 inputbox 執行即見效果。（如果 demo 已經在跑了則請省略。）
	
	以上先達陣了，接下來可以懷著十成把握愉快地把 JavaScript source code 適度地消化成 forth 然後可以鑽
	進去玩。原始程式加掛的 cp.js 是「物理引擎」, demo.js 是作者的通用工具, 這兩個一般該放進 HTML 的 
	<header>, 最後一個 PyramidStack.js 則是我們感興趣的地方，如果再交給 DOM 用 <script> 去 include 我
	們就沒啥好玩了。jeforth.3we 有 <js> ... </js> 命令可派上用場，把 PyramidStack.js 檔案整個放進它裡
	面去，效果跟用 <script> 去 include 差不多，但 <script> 進來的東西是掛在 DOM 的 window 下為 global
	而 <js> ... </js> 是用 eval() 執行其中的程式碼，若最後沒有地方收留它的東西，結果就會蒸發掉。經觀
	察 PyramidStack.js 的工作就是定義出一個 PyramidStack constructor 出來。我們在 <js>..</js> 加一行:

		push(new PyramidStack());
	
	用該 constructor 去 new 一個 PyramidStack 出來放在 TOS 傳回 forth。隨後的：
	
		constant PyramidStack // ( -- cp_object ) cp demo program main object
		
	把 TOS 裡的 PyramidStack 指定成為同名的 forth constant, 之後的 // string 賦予它 help messages 可試
	驗 help PyramidStack 即見之。得到這個 object 之後可以用 jeforth.3we 的 obj>keys 命令瞧瞧它裡面有些
	什麼內容：
	
		PyramidStack obj>keys .
		
	好玩的東西很多，其中有一個 'run' method 即原程式用來執行的方法。我們也可以照樣執行它：
	
		PyramidStack :: run()
	
	就把原 demo 程式給跑起來了！還多出好多可以探險的東西可慢慢欣賞。 。 。 。

		cr 
		.( help PyramidStack )
		help PyramidStack 
		cr

		.( PyramidStack obj>keys . cr ) cr
		PyramidStack obj>keys . cr cr

		.(( PyramidStack :: run() )) cr
		PyramidStack :: run()

		.(( PyramidStack :: space.sleepTimeThreshold=60 \ 我們可以把手身進去修改。。。叫他不要太早 sleep  )) cr
		PyramidStack :: space.sleepTimeThreshold=60

		.(( 然後用 rewinding TIB 把 50 號物體搞成一個小瘋子，每秒亂跳一下，看到它了嗎？ )) cr
		cut
		PyramidStack :> space.bodies[50].getPos() js: push(tos().y);push(pop(1).x)
		PyramidStack :: space.bodies[50].setPos(v(pop()+Math.random()*6-3,pop()+Math.random()*30))
		1000 nap rewind
	
</text> . <o> <hr></o> drop

<o> <canvas></canvas></o> constant canvas // ( -- element ) The canvas of this demo.
<h> <script src="js/chipmunk.js/cp.js"></script><script src="js/chipmunk.js/demo/demo.js"></script></h> drop

<js>
	// <script src="js/chipmunk.js/demo/PyramidStack.js"></script>
	// <script>
	// (new PyramidStack()).run();
	// </script> 

	/* Copyright (c) 2007 Scott Lembcke
	 * 
	 * Permission is hereby granted, free of charge, to any person obtaining a copy
	 * of this software and associated documentation files (the "Software"), to deal
	 * in the Software without restriction, including without limitation the rights
	 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	 * copies of the Software, and to permit persons to whom the Software is
	 * furnished to do so, subject to the following conditions:
	 * 
	 * The above copyright notice and this permission notice shall be included in
	 * all copies or substantial portions of the Software.
	 * 
	 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	 * SOFTWARE.
	 */
	 
	var PyramidStack = function() {
		Demo.call(this);

		var space = this.space;
		//space.iterations = 30;
		space.gravity = v(0, -100);
		space.sleepTimeThreshold = 0.5;
		space.collisionSlop = 0.5;

		var body, staticBody = space.staticBody;
		var shape;
		
		this.addFloor();
		this.addWalls();
		
		// Add lots of boxes.
		for(var i=0; i<14; i++){
			for(var j=0; j<=i; j++){
				body = space.addBody(new cp.Body(1, cp.momentForBox(1, 30, 30)));
				body.setPos(v(j*32 - i*16 + 320, 540 - i*32));
				
				shape = space.addShape(new cp.BoxShape(body, 30, 30));
				shape.setElasticity(0);
				shape.setFriction(0.8);
			}
		}
		
		// Add a ball to make things more interesting
		var radius = 15;
		body = space.addBody(new cp.Body(10, cp.momentForCircle(10, 0, radius, v(0,0))));
		body.setPos(v(320, radius+5));

		shape = space.addShape(new cp.CircleShape(body, radius, v(0,0)));
		shape.setElasticity(0);
		shape.setFriction(0.9);
	};

	PyramidStack.prototype = Object.create(Demo.prototype);

	PyramidStack.prototype.update = function(dt)
	{
		var steps = 3;
		dt /= steps;
		for (var i = 0; i < 3; i++){
			this.space.step(dt);
		}
	};

	addDemo('Pyramid Stack', PyramidStack);
	push(new PyramidStack());
</js> constant PyramidStack // ( -- cp_object ) cp demo program main object

cr 
.( help PyramidStack )
help PyramidStack 
cr

.( PyramidStack obj>keys . cr ) cr
PyramidStack obj>keys . cr cr

.(( PyramidStack :: run() )) cr
PyramidStack :: run()

.(( PyramidStack :: space.sleepTimeThreshold=60 \ 我們可以把手身進去修改。。。叫他不要太早 sleep  )) cr
PyramidStack :: space.sleepTimeThreshold=60

.(( 然後用 rewinding TIB 把 50 號物體搞成一個小瘋子，每秒亂跳一下，看到它了嗎？ )) cr
cut
PyramidStack :> space.bodies[50].getPos() js: push(tos().y);push(pop(1).x)
PyramidStack :: space.bodies[50].setPos(v(pop()+Math.random()*6-3,pop()+Math.random()*30))
1000 nap rewind

<comment>

	以下是我亂玩 PyramidStack 的畫面，有參考價值 hcchen5600 2015/03/27 19:57:49 

	PyramidStack obj>keys .
	space,remainder,fps,mouse,simulationTime,drawTime,canvas2point,point2canvas,mouseBody,running,maxArbiters,maxContacts,mouseJoint,update,canvas,ctx,width,height,scale,drawInfo,draw,run,benchmark,stop,step,addFloor,addWalls 
	OK PyramidStack :> space (see)
	[object Object]
	  stamp :  35781
	  curr_dt :  0.005555555555555556
	  bodies :  [object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object]
	  rousedBodies :  
	  sleepingComponents :  [object Object],[object Object],[object Object]
	  staticShapes :  [object Object]
	  activeShapes :  [object Object]
	  arbiters :  
	  contactBuffersHead :  [object Null]
	  cachedArbiters :  [object Object]
	  constraints :  
	  locked :  0
	  collisionHandlers :  [object Object]
	  defaultHandler :  [object Object]
	  postStepCallbacks :  
	  iterations :  10
	  gravity :  [object Object]
	  damping :  1
	  idleSpeedThreshold :  0
	  sleepTimeThreshold :  0.5
	  collisionSlop :  0.5
	  collisionBias :  0.001797010299914434
	  collisionPersistence :  3
	  enableContactGraph :  [object Boolean]
	  staticBody :  [object Object]
	  collideShapes :  function(a, b){
					var space = space_;

					// Reject any of the simple cases
					if(
							// BBoxes must overlap
							//!bbIntersects(a.bb, b.bb)
							!(a.bb_l <= b.bb_r && b.bb_l <= a.bb_r && a.bb_b <= b.bb_t && b.bb_b <= a.bb_t)
							// Don't collide shapes attached to the same body.
							|| a.body === b.body
							// Don't collide objects in the same non-zero group
							|| (a.group && a.group === b.group)
							// Don't collide objects that don't share at least on layer.
							|| !(a.layers & b.layers)
					) return;

					var handler = space.lookupHandler(a.collision_type, b.collision_type);

					var sensor = a.sensor || b.sensor;
					if(sensor && handler === defaultCollisionHandler) return;

					// Shape 'a' should have the lower shape type. (required by cpCollideShapes() )
					if(a.collisionCode > b.collisionCode){
							var temp = a;
							a = b;
							b = temp;
					}

					// Narrow-phase collision detection.
					//cpContact *contacts = cpContactBufferGetArray(space);
					//int numContacts = cpCollideShapes(a, b, contacts);
					var contacts = collideShapes(a, b);
					if(contacts.length === 0) return; // Shapes are not colliding.
					//cpSpacePushContacts(space, numContacts);

					// Get an arbiter from space.arbiterSet for the two shapes.
					// This is where the persistant contact magic comes from.
					var arbHash = hashPair(a.hashid, b.hashid);
					var arb = space.cachedArbiters[arbHash];
					if (!arb){
							arb = space.cachedArbiters[arbHash] = new Arbiter(a, b);
					}

					arb.update(contacts, handler, a, b);

					// Call the begin function first if it's the first step
					if(arb.state == 'first coll' && !handler.begin(arb, space)){
							arb.ignore(); // permanently ignore the collision until separation
					}

					if(
							// Ignore the arbiter if it has been flagged
							(arb.state !== 'ignore') &&
							// Call preSolve
							handler.preSolve(arb, space) &&
							// Process, but don't add collisions for sensors.
							!sensor
					){
							space.arbiters.push(arb);
					} else {
							//cpSpacePopContacts(space, numContacts);

							arb.contacts = null;

							// Normally arbiters are set as used after calling the post-solve callback.
							// However, post-solve callbacks are not called for sensors or arbiters rejected from pre-solve.
							if(arb.state !== 'ignore') arb.state = 'normal';
					}

					// Time stamp the arbiter so we know it was used recently.
					arb.stamp = space.stamp;
			}
	  getCurrentTimeStep :  function() { return this.curr_dt; }
	  setIterations :  function(iter) { this.iterations = iter; }
	  isLocked :  function()
	{
			return this.locked;
	}
	  addCollisionHandler :  function(a, b, begin, preSolve, postSolve, separate)
	{
			assertSpaceUnlocked(this);
					
			// Remove any old function so the new one will get added.
			this.removeCollisionHandler(a, b);
			
			var handler = new CollisionHandler();
			handler.a = a;
			handler.b = b;
			if(begin) handler.begin = begin;
			if(preSolve) handler.preSolve = preSolve;
			if(postSolve) handler.postSolve = postSolve;
			if(separate) handler.separate = separate;

			this.collisionHandlers[hashPair(a, b)] = handler;
	}
	  removeCollisionHandler :  function(a, b)
	{
			assertSpaceUnlocked(this);
			
			delete this.collisionHandlers[hashPair(a, b)];
	}
	  setDefaultCollisionHandler :  function(begin, preSolve, postSolve, separate)
	{
			assertSpaceUnlocked(this);

			var handler = new CollisionHandler();
			if(begin) handler.begin = begin;
			if(preSolve) handler.preSolve = preSolve;
			if(postSolve) handler.postSolve = postSolve;
			if(separate) handler.separate = separate;

			this.defaultHandler = handler;
	}
	  lookupHandler :  function(a, b)
	{
			return this.collisionHandlers[hashPair(a, b)] || this.defaultHandler;
	}
	  addShape :  function(shape)
	{
			var body = shape.body;
			if(body.isStatic()) return this.addStaticShape(shape);
			
			assert(!shape.space, "This shape is already added to a space and cannot be added to another.");
			assertSpaceUnlocked(this);
			
			body.activate();
			body.addShape(shape);
			
			shape.update(body.p, body.rot);
			this.activeShapes.insert(shape, shape.hashid);
			shape.space = this;
					
			return shape;
	}
	  addStaticShape :  function(shape)
	{
			assert(!shape.space, "This shape is already added to a space and cannot be added to another.");
			assertSpaceUnlocked(this);
			
			var body = shape.body;
			body.addShape(shape);

			shape.update(body.p, body.rot);
			this.staticShapes.insert(shape, shape.hashid);
			shape.space = this;
			
			return shape;
	}
	  addBody :  function(body)
	{
			assert(!body.isStatic(), "Static bodies cannot be added to a space as they are not meant to be simulated.");
			assert(!body.space, "This body is already added to a space and cannot be added to another.");
			assertSpaceUnlocked(this);
			
			this.bodies.push(body);
			body.space = this;
			
			return body;
	}
	  addConstraint :  function(constraint)
	{
			assert(!constraint.space, "This shape is already added to a space and cannot be added to another.");
			assertSpaceUnlocked(this);
			
			var a = constraint.a, b = constraint.b;

			a.activate();
			b.activate();
			this.constraints.push(constraint);
			
			// Push onto the heads of the bodies' constraint lists
			constraint.next_a = a.constraintList; a.constraintList = constraint;
			constraint.next_b = b.constraintList; b.constraintList = constraint;
			constraint.space = this;
			
			return constraint;
	}
	  filterArbiters :  function(body, filter)
	{
			for (var hash in this.cachedArbiters)
			{
					var arb = this.cachedArbiters[hash];

					// Match on the filter shape, or if it's null the filter body
					if(
							(body === arb.body_a && (filter === arb.a || filter === null)) ||
							(body === arb.body_b && (filter === arb.b || filter === null))
					){
							// Call separate when removing shapes.
							if(filter && arb.state !== 'cached') arb.callSeparate(this);
							
							arb.unthread();

							deleteObjFromList(this.arbiters, arb);
							//this.pooledArbiters.push(arb);
							
							delete this.cachedArbiters[hash];
					}
			}
	}
	  removeShape :  function(shape)
	{
			var body = shape.body;
			if(body.isStatic()){
					this.removeStaticShape(shape);
			} else {
					assert(this.containsShape(shape),
							"Cannot remove a shape that was not added to the space. (Removed twice maybe?)");
					assertSpaceUnlocked(this);
					
					body.activate();
					body.removeShape(shape);
					this.filterArbiters(body, shape);
					this.activeShapes.remove(shape, shape.hashid);
					shape.space = null;
			}
	}
	  removeStaticShape :  function(shape)
	{
			assert(this.containsShape(shape),
					"Cannot remove a static or sleeping shape that was not added to the space. (Removed twice maybe?)");
			assertSpaceUnlocked(this);
			
			var body = shape.body;
			if(body.isStatic()) body.activateStatic(shape);
			body.removeShape(shape);
			this.filterArbiters(body, shape);
			this.staticShapes.remove(shape, shape.hashid);
			shape.space = null;
	}
	  removeBody :  function(body)
	{
			assert(this.containsBody(body),
					"Cannot remove a body that was not added to the space. (Removed twice maybe?)");
			assertSpaceUnlocked(this);
			
			body.activate();
	//        this.filterArbiters(body, null);
			deleteObjFromList(this.bodies, body);
			body.space = null;
	}
	  removeConstraint :  function(constraint)
	{
			assert(this.containsConstraint(constraint),
					"Cannot remove a constraint that was not added to the space. (Removed twice maybe?)");
			assertSpaceUnlocked(this);
			
			constraint.a.activate();
			constraint.b.activate();
			deleteObjFromList(this.constraints, constraint);
			
			constraint.a.removeConstraint(constraint);
			constraint.b.removeConstraint(constraint);
			constraint.space = null;
	}
	  containsShape :  function(shape)
	{
			return (shape.space === this);
	}
	  containsBody :  function(body)
	{
			return (body.space == this);
	}
	  containsConstraint :  function(constraint)
	{
			return (constraint.space == this);
	}
	  uncacheArbiter :  function(arb)
	{
			delete this.cachedArbiters[hashPair(arb.a.hashid, arb.b.hashid)];
			deleteObjFromList(this.arbiters, arb);
	}
	  eachBody :  function(func)
	{
			this.lock(); {
					var bodies = this.bodies;
					
					for(var i=0; i<bodies.length; i++){
							func(bodies[i]);
					}
					
					var components = this.sleepingComponents;
					for(var i=0; i<components.length; i++){
							var root = components[i];
							
							var body = root;
							while(body){
									var next = body.nodeNext;
									func(body);
									body = next;
							}
					}
			} this.unlock(true);
	}
	  eachShape :  function(func)
	{
			this.lock(); {
					this.activeShapes.each(func);
					this.staticShapes.each(func);
			} this.unlock(true);
	}
	  eachConstraint :  function(func)
	{
			this.lock(); {
					var constraints = this.constraints;
					
					for(var i=0; i<constraints.length; i++){
							func(constraints[i]);
					}
			} this.unlock(true);
	}
	  reindexStatic :  function()
	{
			assert(!this.locked, "You cannot manually reindex objects while the space is locked. Wait until the current query or step is complete.");
			
			this.staticShapes.each(function(shape){
					var body = shape.body;
					shape.update(body.p, body.rot);
			});
			this.staticShapes.reindex();
	}
	  reindexShape :  function(shape)
	{
			assert(!this.locked, "You cannot manually reindex objects while the space is locked. Wait until the current query or step is complete.");
			
			var body = shape.body;
			shape.update(body.p, body.rot);
			
			// attempt to rehash the shape in both hashes
			this.activeShapes.reindexObject(shape, shape.hashid);
			this.staticShapes.reindexObject(shape, shape.hashid);
	}
	  reindexShapesForBody :  function(body)
	{
			for(var shape = body.shapeList; shape; shape = shape.next){
					this.reindexShape(shape);
			}
	}
	  useSpatialHash :  function(dim, count)
	{
			throw new Error('Spatial Hash not implemented.');
			
			var staticShapes = new SpaceHash(dim, count, null);
			var activeShapes = new SpaceHash(dim, count, staticShapes);
			
			this.staticShapes.each(function(shape){
					staticShapes.insert(shape, shape.hashid);
			});
			this.activeShapes.each(function(shape){
					activeShapes.insert(shape, shape.hashid);
			});
					
			this.staticShapes = staticShapes;
			this.activeShapes = activeShapes;
	}
	  activateBody :  function(body)
	{
			assert(!body.isRogue(), "Internal error: Attempting to activate a rogue body.");
			
			if(this.locked){
					// cpSpaceActivateBody() is called again once the space is unlocked
					if(this.rousedBodies.indexOf(body) === -1) this.rousedBodies.push(body);
			} else {
					this.bodies.push(body);

					for(var i = 0; i < body.shapeList.length; i++){
							var shape = body.shapeList[i];
							this.staticShapes.remove(shape, shape.hashid);
							this.activeShapes.insert(shape, shape.hashid);
					}
					
					for(var arb = body.arbiterList; arb; arb = arb.next(body)){
							var bodyA = arb.body_a;
							if(body === bodyA || bodyA.isStatic()){
									//var contacts = arb.contacts;
									
									// Restore contact values back to the space's contact buffer memory
									//arb.contacts = cpContactBufferGetArray(this);
									//memcpy(arb.contacts, contacts, numContacts*sizeof(cpContact));
									//cpSpacePushContacts(this, numContacts);
									
									// Reinsert the arbiter into the arbiter cache
									var a = arb.a, b = arb.b;
									this.cachedArbiters[hashPair(a.hashid, b.hashid)] = arb;
									
									// Update the arbiter's state
									arb.stamp = this.stamp;
									arb.handler = this.lookupHandler(a.collision_type, b.collision_type);
									this.arbiters.push(arb);
							}
					}
					
					for(var constraint = body.constraintList; constraint; constraint = constraint.nodeNext){
							var bodyA = constraint.a;
							if(body === bodyA || bodyA.isStatic()) this.constraints.push(constraint);
					}
			}
	}
	  deactivateBody :  function(body)
	{
			assert(!body.isRogue(), "Internal error: Attempting to deactivate a rogue body.");
			
			deleteObjFromList(this.bodies, body);
			
			for(var i = 0; i < body.shapeList.length; i++){
					var shape = body.shapeList[i];
					this.activeShapes.remove(shape, shape.hashid);
					this.staticShapes.insert(shape, shape.hashid);
			}
			
			for(var arb = body.arbiterList; arb; arb = arb.next(body)){
					var bodyA = arb.body_a;
					if(body === bodyA || bodyA.isStatic()){
							this.uncacheArbiter(arb);
							
							// Save contact values to a new block of memory so they won't time out
							//size_t bytes = arb.numContacts*sizeof(cpContact);
							//cpContact *contacts = (cpContact *)cpcalloc(1, bytes);
							//memcpy(contacts, arb.contacts, bytes);
							//arb.contacts = contacts;
					}
			}
					
			for(var constraint = body.constraintList; constraint; constraint = constraint.nodeNext){
					var bodyA = constraint.a;
					if(body === bodyA || bodyA.isStatic()) deleteObjFromList(this.constraints, constraint);
			}
	}
	  processComponents :  function(dt)
	{
			var sleep = (this.sleepTimeThreshold !== Infinity);
			var bodies = this.bodies;

			// These checks can be removed at some stage (if DEBUG == undefined)
			for(var i=0; i<bodies.length; i++){
					var body = bodies[i];
					
					assertSoft(body.nodeNext === null, "Internal Error: Dangling next pointer detected in contact graph.");
					assertSoft(body.nodeRoot === null, "Internal Error: Dangling root pointer detected in contact graph.");
			}

			// Calculate the kinetic energy of all the bodies
			if(sleep){
					var dv = this.idleSpeedThreshold;
					var dvsq = (dv ? dv*dv : vlengthsq(this.gravity)*dt*dt);
			
					for(var i=0; i<bodies.length; i++){
							var body = bodies[i];

							// Need to deal with infinite mass objects
							var keThreshold = (dvsq ? body.m*dvsq : 0);
							body.nodeIdleTime = (body.kineticEnergy() > keThreshold ? 0 : body.nodeIdleTime + dt);
					}
			}

			// Awaken any sleeping bodies found and then push arbiters to the bodies' lists.
			var arbiters = this.arbiters;
			for(var i=0, count=arbiters.length; i<count; i++){
					var arb = arbiters[i];
					var a = arb.body_a, b = arb.body_b;
			
					if(sleep){        
							if((b.isRogue() && !b.isStatic()) || a.isSleeping()) a.activate();
							if((a.isRogue() && !a.isStatic()) || b.isSleeping()) b.activate();
					}
					
					a.pushArbiter(arb);
					b.pushArbiter(arb);
			}
			
			if(sleep){
					// Bodies should be held active if connected by a joint to a non-static rouge body.
					var constraints = this.constraints;
					for(var i=0; i<constraints.length; i++){
							var constraint = constraints[i];
							var a = constraint.a, b = constraint.b;
							
							if(b.isRogue() && !b.isStatic()) a.activate();
							if(a.isRogue() && !a.isStatic()) b.activate();
					}
					
					// Generate components and deactivate sleeping ones
					for(var i=0; i<bodies.length;){
							var body = bodies[i];
							
							if(componentRoot(body) === null){
									// Body not in a component yet. Perform a DFS to flood fill mark 
									// the component in the contact graph using this body as the root.
									floodFillComponent(body, body);
									
									// Check if the component should be put to sleep.
									if(!componentActive(body, this.sleepTimeThreshold)){
											this.sleepingComponents.push(body);
											for(var other = body; other; other = other.nodeNext){
													this.deactivateBody(other);
											}
											
											// deactivateBody() removed the current body from the list.
											// Skip incrementing the index counter.
											continue;
									}
							}
							
							i++;
							
							// Only sleeping bodies retain their component node pointers.
							body.nodeRoot = null;
							body.nodeNext = null;
					}
			}
	}
	  activateShapesTouchingShape :  function(shape){
			if(this.sleepTimeThreshold !== Infinity){
					this.shapeQuery(shape, function(shape, points) {
							shape.body.activate();
					});
			}
	}
	  pointQuery :  function(point, layers, group, func)
	{
			var helper = function(shape){
					if(
							!(shape.group && group === shape.group) && (layers & shape.layers) &&
							shape.pointQuery(point)
					){
							func(shape);
					}
			};

			var bb = new BB(point.x, point.y, point.x, point.y);
			this.lock(); {
					this.activeShapes.query(bb, helper);
					this.staticShapes.query(bb, helper);
			} this.unlock(true);
	}
	  pointQueryFirst :  function(point, layers, group)
	{
			var outShape = null;
			this.pointQuery(point, layers, group, function(shape) {
					if(!shape.sensor) outShape = shape;
			});
			
			return outShape;
	}
	  nearestPointQuery :  function(point, maxDistance, layers, group, func)
	{
			var helper = function(shape){
					if(!(shape.group && group === shape.group) && (layers & shape.layers)){
							var info = shape.nearestPointQuery(point);

							if(info.d < maxDistance) func(shape, info.d, info.p);
					}
			};

			var bb = bbNewForCircle(point, maxDistance);

			this.lock(); {
					this.activeShapes.query(bb, helper);
					this.staticShapes.query(bb, helper);
			} this.unlock(true);
	}
	  nearestPointQueryNearest :  function(point, maxDistance, layers, group)
	{
			var out;

			var helper = function(shape){
					if(!(shape.group && group === shape.group) && (layers & shape.layers) && !shape.sensor){
							var info = shape.nearestPointQuery(point);

							if(info.d < maxDistance && (!out || info.d < out.d)) out = info;
					}
			};

			var bb = bbNewForCircle(point, maxDistance);
			this.activeShapes.query(bb, helper);
			this.staticShapes.query(bb, helper);

			return out;
	}
	  segmentQuery :  function(start, end, layers, group, func)
	{
			var helper = function(shape){
					var info;
					
					if(
							!(shape.group && group === shape.group) && (layers & shape.layers) &&
							(info = shape.segmentQuery(start, end))
					){
							func(shape, info.t, info.n);
					}
					
					return 1;
			};

			this.lock(); {
					this.staticShapes.segmentQuery(start, end, 1, helper);
					this.activeShapes.segmentQuery(start, end, 1, helper);
			} this.unlock(true);
	}
	  segmentQueryFirst :  function(start, end, layers, group)
	{
			var out = null;

			var helper = function(shape){
					var info;
					
					if(
							!(shape.group && group === shape.group) && (layers & shape.layers) &&
							!shape.sensor &&
							(info = shape.segmentQuery(start, end)) &&
							(out === null || info.t < out.t)
					){
							out = info;
					}
					
					return out ? out.t : 1;
			};

			this.staticShapes.segmentQuery(start, end, 1, helper);
			this.activeShapes.segmentQuery(start, end, out ? out.t : 1, helper);
			
			return out;
	}
	  bbQuery :  function(bb, layers, group, func)
	{
			var helper = function(shape){
					if(
							!(shape.group && group === shape.group) && (layers & shape.layers) &&
							bbIntersects2(bb, shape.bb_l, shape.bb_b, shape.bb_r, shape.bb_t)
					){
							func(shape);
					}
			};
			
			this.lock(); {
					this.activeShapes.query(bb, helper);
					this.staticShapes.query(bb, helper);
			} this.unlock(true);
	}
	  shapeQuery :  function(shape, func)
	{
			var body = shape.body;

			//var bb = (body ? shape.update(body.p, body.rot) : shape.bb);
			if(body){
					shape.update(body.p, body.rot);
			}
			var bb = new BB(shape.bb_l, shape.bb_b, shape.bb_r, shape.bb_t);

			//shapeQueryContext context = {func, data, false};
			var anyCollision = false;
			
			var helper = function(b){
					var a = shape;
					// Reject any of the simple cases
					if(
							(a.group && a.group === b.group) ||
							!(a.layers & b.layers) ||
							a === b
					) return;
					
					var contacts;
					
					// Shape 'a' should have the lower shape type. (required by collideShapes() )
					if(a.collisionCode <= b.collisionCode){
							contacts = collideShapes(a, b);
					} else {
							contacts = collideShapes(b, a);
							for(var i=0; i<contacts.length; i++) contacts[i].n = vneg(contacts[i].n);
					}
					
					if(contacts.length){
							anyCollision = !(a.sensor || b.sensor);
							
							if(func){
									var set = new Array(contacts.length);
									for(var i=0; i<contacts.length; i++){
											set[i] = new ContactPoint(contacts[i].p, contacts[i].n, contacts[i].dist);
									}
									
									func(b, set);
							}
					}
			};

			this.lock(); {
					this.activeShapes.query(bb, helper);
					this.staticShapes.query(bb, helper);
			} this.unlock(true);
			
			return anyCollision;
	}
	  addPostStepCallback :  function(func)
	{
			assertSoft(this.locked,
					"Adding a post-step callback when the space is not locked is unnecessary. " +
					"Post-step callbacks will not called until the end of the next call to cpSpaceStep() or the next query.");

			this.postStepCallbacks.push(func);
	}
	  runPostStepCallbacks :  function()
	{
			// Don't cache length because post step callbacks may add more post step callbacks
			// directly or indirectly.
			for(var i = 0; i < this.postStepCallbacks.length; i++){
					this.postStepCallbacks[i]();
			}
			this.postStepCallbacks = [];
	}
	  lock :  function()
	{
			this.locked++;
	}
	  unlock :  function(runPostStep)
	{
			this.locked--;
			assert(this.locked >= 0, "Internal Error: Space lock underflow.");

			if(this.locked === 0 && runPostStep){
					var waking = this.rousedBodies;
					for(var i=0; i<waking.length; i++){
							this.activateBody(waking[i]);
					}

					waking.length = 0;

					this.runPostStepCallbacks();
			}
	}
	  makeCollideShapes :  function()
	{
			// It would be nicer to use .bind() or something, but this is faster.
			var space_ = this;
			return function(a, b){
					var space = space_;

					// Reject any of the simple cases
					if(
							// BBoxes must overlap
							//!bbIntersects(a.bb, b.bb)
							!(a.bb_l <= b.bb_r && b.bb_l <= a.bb_r && a.bb_b <= b.bb_t && b.bb_b <= a.bb_t)
							// Don't collide shapes attached to the same body.
							|| a.body === b.body
							// Don't collide objects in the same non-zero group
							|| (a.group && a.group === b.group)
							// Don't collide objects that don't share at least on layer.
							|| !(a.layers & b.layers)
					) return;

					var handler = space.lookupHandler(a.collision_type, b.collision_type);

					var sensor = a.sensor || b.sensor;
					if(sensor && handler === defaultCollisionHandler) return;

					// Shape 'a' should have the lower shape type. (required by cpCollideShapes() )
					if(a.collisionCode > b.collisionCode){
							var temp = a;
							a = b;
							b = temp;
					}

					// Narrow-phase collision detection.
					//cpContact *contacts = cpContactBufferGetArray(space);
					//int numContacts = cpCollideShapes(a, b, contacts);
					var contacts = collideShapes(a, b);
					if(contacts.length === 0) return; // Shapes are not colliding.
					//cpSpacePushContacts(space, numContacts);

					// Get an arbiter from space.arbiterSet for the two shapes.
					// This is where the persistant contact magic comes from.
					var arbHash = hashPair(a.hashid, b.hashid);
					var arb = space.cachedArbiters[arbHash];
					if (!arb){
							arb = space.cachedArbiters[arbHash] = new Arbiter(a, b);
					}

					arb.update(contacts, handler, a, b);

					// Call the begin function first if it's the first step
					if(arb.state == 'first coll' && !handler.begin(arb, space)){
							arb.ignore(); // permanently ignore the collision until separation
					}

					if(
							// Ignore the arbiter if it has been flagged
							(arb.state !== 'ignore') &&
							// Call preSolve
							handler.preSolve(arb, space) &&
							// Process, but don't add collisions for sensors.
							!sensor
					){
							space.arbiters.push(arb);
					} else {
							//cpSpacePopContacts(space, numContacts);

							arb.contacts = null;

							// Normally arbiters are set as used after calling the post-solve callback.
							// However, post-solve callbacks are not called for sensors or arbiters rejected from pre-solve.
							if(arb.state !== 'ignore') arb.state = 'normal';
					}

					// Time stamp the arbiter so we know it was used recently.
					arb.stamp = space.stamp;
			};
	}
	  arbiterSetFilter :  function(arb)
	{
			var ticks = this.stamp - arb.stamp;

			var a = arb.body_a, b = arb.body_b;

			// TODO should make an arbiter state for this so it doesn't require filtering arbiters for
			// dangling body pointers on body removal.
			// Preserve arbiters on sensors and rejected arbiters for sleeping objects.
			// This prevents errant separate callbacks from happenening.
			if(
					(a.isStatic() || a.isSleeping()) &&
					(b.isStatic() || b.isSleeping())
			){
					return true;
			}

			// Arbiter was used last frame, but not this one
			if(ticks >= 1 && arb.state != 'cached'){
					arb.callSeparate(this);
					arb.state = 'cached';
			}

			if(ticks >= this.collisionPersistence){
					arb.contacts = null;

					//cpArrayPush(this.pooledArbiters, arb);
					return false;
			}

			return true;
	}
	  step :  function(dt)
	{
			// don't step if the timestep is 0!
			if(dt === 0) return;

			assert(vzero.x === 0 && vzero.y === 0, "vzero is invalid");

			this.stamp++;

			var prev_dt = this.curr_dt;
			this.curr_dt = dt;

		var i;
		var j;
		var hash;
			var bodies = this.bodies;
			var constraints = this.constraints;
			var arbiters = this.arbiters;

			// Reset and empty the arbiter lists.
			for(i=0; i<arbiters.length; i++){
					var arb = arbiters[i];
					arb.state = 'normal';

					// If both bodies are awake, unthread the arbiter from the contact graph.
					if(!arb.body_a.isSleeping() && !arb.body_b.isSleeping()){
							arb.unthread();
					}
			}
			arbiters.length = 0;

			this.lock(); {
					// Integrate positions
					for(i=0; i<bodies.length; i++){
							bodies[i].position_func(dt);
					}

					// Find colliding pairs.
					//this.pushFreshContactBuffer();
					this.activeShapes.each(updateFunc);
					this.activeShapes.reindexQuery(this.collideShapes);
			} this.unlock(false);

			// Rebuild the contact graph (and detect sleeping components if sleeping is enabled)
			this.processComponents(dt);

			this.lock(); {
					// Clear out old cached arbiters and call separate callbacks
					for(hash in this.cachedArbiters) {
							if(!this.arbiterSetFilter(this.cachedArbiters[hash])) {
									delete this.cachedArbiters[hash];
							}
					}

					// Prestep the arbiters and constraints.
					var slop = this.collisionSlop;
					var biasCoef = 1 - Math.pow(this.collisionBias, dt);
					for(i=0; i<arbiters.length; i++){
							arbiters[i].preStep(dt, slop, biasCoef);
					}

					for(i=0; i<constraints.length; i++){
							var constraint = constraints[i];

							constraint.preSolve(this);
							constraint.preStep(dt);
					}

					// Integrate velocities.
					var damping = Math.pow(this.damping, dt);
					var gravity = this.gravity;
					for(i=0; i<bodies.length; i++){
							bodies[i].velocity_func(gravity, damping, dt);
					}

					// Apply cached impulses
					var dt_coef = (prev_dt === 0 ? 0 : dt/prev_dt);
					for(i=0; i<arbiters.length; i++){
							arbiters[i].applyCachedImpulse(dt_coef);
					}

					for(i=0; i<constraints.length; i++){
							constraints[i].applyCachedImpulse(dt_coef);
					}

					// Run the impulse solver.
					for(i=0; i<this.iterations; i++){
							for(j=0; j<arbiters.length; j++){
									arbiters[j].applyImpulse();
							}

							for(j=0; j<constraints.length; j++){
									constraints[j].applyImpulse();
							}
					}

					// Run the constraint post-solve callbacks
					for(i=0; i<constraints.length; i++){
							constraints[i].postSolve(this);
					}

					// run the post-solve callbacks
					for(i=0; i<arbiters.length; i++){
							arbiters[i].handler.postSolve(arbiters[i], this);
					}
			} this.unlock(true);
	}
	 OK 
	 OK PyramidStack :> space.bodies .
	[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object] OK PyramidStack :> space.bodies.length .
	55 OK PyramidStack :> space.bodies[54] .
	[object Object] OK PyramidStack :> space.bodies[54] (see) \ PyramidStack :: space.bodies[54].setPos(v(30,30))
	[object Object]
	  p :  [object Object]
	  vy :  -14419.943338207034
	  vx :  -221.46100995567792
	  f :  [object Object]
	  w :  1.2985412210793767
	  t :  0
	  v_limit :  Infinity
	  w_limit :  Infinity
	  v_biasy :  0
	  v_biasx :  0
	  w_bias :  0
	  space :  [object Object]
	  shapeList :  [object Object]
	  arbiterList :  [object Null]
	  constraintList :  [object Null]
	  nodeRoot :  [object Null]
	  nodeNext :  [object Null]
	  nodeIdleTime :  0
	  m :  1
	  m_inv :  1
	  i :  150
	  i_inv :  0.006666666666666667
	  rot :  [object Object]
	  a :  215.24701472204214
	  sanityCheck :  function(){}
	  getPos :  function() { return this.p; }
	  getVel :  function() { return new Vect(this.vx, this.vy); }
	  getAngVel :  function() { return this.w; }
	  isSleeping :  function()
	{
			return this.nodeRoot !== null;
	}
	  isStatic :  function()
	{
			return this.nodeIdleTime === Infinity;
	}
	  isRogue :  function()
	{
			return this.space === null;
	}
	  setMass :  function(mass)
	{
			assert(mass > 0, "Mass must be positive and non-zero.");

			//activate is defined in cpSpaceComponent
			this.activate();
			this.m = mass;
			this.m_inv = 1/mass;
	}
	  setMoment :  function(moment)
	{
			assert(moment > 0, "Moment of Inertia must be positive and non-zero.");

			this.activate();
			this.i = moment;
			this.i_inv = 1/moment;
	}
	  addShape :  function(shape)
	{
			this.shapeList.push(shape);
	}
	  removeShape :  function(shape)
	{
			// This implementation has a linear time complexity with the number of shapes.
			// The original implementation used linked lists instead, which might be faster if
			// you're constantly editing the shape of a body. I expect most bodies will never
			// have their shape edited, so I'm just going to use the simplest possible implemention.
			deleteObjFromList(this.shapeList, shape);
	}
	  removeConstraint :  function(constraint)
	{
			// The constraint must be in the constraints list when this is called.
			this.constraintList = filterConstraints(this.constraintList, this, constraint);
	}
	  setPos :  function(pos)
	{
			this.activate();
			this.sanityCheck();
			// If I allow the position to be set to vzero, vzero will get changed.
			if (pos === vzero) {
					pos = cp.v(0,0);
			}
			this.p = pos;
	}
	  setVel :  function(velocity)
	{
			this.activate();
			this.vx = velocity.x;
			this.vy = velocity.y;
	}
	  setAngVel :  function(w)
	{
			this.activate();
			this.w = w;
	}
	  setAngleInternal :  function(angle)
	{
			assert(!isNaN(angle), "Internal Error: Attempting to set body's angle to NaN");
			this.a = angle;//fmod(a, (cpFloat)M_PI*2.0f);

			//this.rot = vforangle(angle);
			this.rot.x = Math.cos(angle);
			this.rot.y = Math.sin(angle);
	}
	  setAngle :  function(angle)
	{
			this.activate();
			this.sanityCheck();
			this.setAngleInternal(angle);
	}
	  velocity_func :  function(gravity, damping, dt)
	{
			//this.v = vclamp(vadd(vmult(this.v, damping), vmult(vadd(gravity, vmult(this.f, this.m_inv)), dt)), this.v_limit);
			var vx = this.vx * damping + (gravity.x + this.f.x * this.m_inv) * dt;
			var vy = this.vy * damping + (gravity.y + this.f.y * this.m_inv) * dt;

			//var v = vclamp(new Vect(vx, vy), this.v_limit);
			//this.vx = v.x; this.vy = v.y;
			var v_limit = this.v_limit;
			var lensq = vx * vx + vy * vy;
			var scale = (lensq > v_limit*v_limit) ? v_limit / Math.sqrt(lensq) : 1;
			this.vx = vx * scale;
			this.vy = vy * scale;

			var w_limit = this.w_limit;
			this.w = clamp(this.w*damping + this.t*this.i_inv*dt, -w_limit, w_limit);

			this.sanityCheck();
	}
	  position_func :  function(dt)
	{
			//this.p = vadd(this.p, vmult(vadd(this.v, this.v_bias), dt));

			//this.p = this.p + (this.v + this.v_bias) * dt;
			this.p.x += (this.vx + this.v_biasx) * dt;
			this.p.y += (this.vy + this.v_biasy) * dt;

			this.setAngleInternal(this.a + (this.w + this.w_bias)*dt);

			this.v_biasx = this.v_biasy = 0;
			this.w_bias = 0;

			this.sanityCheck();
	}
	  resetForces :  function()
	{
			this.activate();
			this.f = new Vect(0,0);
			this.t = 0;
	}
	  applyForce :  function(force, r)
	{
			this.activate();
			this.f = vadd(this.f, force);
			this.t += vcross(r, force);
	}
	  applyImpulse :  function(j, r)
	{
			this.activate();
			apply_impulse(this, j.x, j.y, r);
	}
	  getVelAtPoint :  function(r)
	{
			return vadd(new Vect(this.vx, this.vy), vmult(vperp(r), this.w));
	}
	  getVelAtWorldPoint :  function(point)
	{
			return this.getVelAtPoint(vsub(point, this.p));
	}
	  getVelAtLocalPoint :  function(point)
	{
			return this.getVelAtPoint(vrotate(point, this.rot));
	}
	  eachShape :  function(func)
	{
			for(var i = 0, len = this.shapeList.length; i < len; i++) {
					func(this.shapeList[i]);
			}
	}
	  eachConstraint :  function(func)
	{
			var constraint = this.constraintList;
			while(constraint) {
					var next = constraint.next(this);
					func(constraint);
					constraint = next;
			}
	}
	  eachArbiter :  function(func)
	{
			var arb = this.arbiterList;
			while(arb){
					var next = arb.next(this);

					arb.swappedColl = (this === arb.body_b);
					func(arb);

					arb = next;
			}
	}
	  local2World :  function(v)
	{
			return vadd(this.p, vrotate(v, this.rot));
	}
	  world2Local :  function(v)
	{
			return vunrotate(vsub(v, this.p), this.rot);
	}
	  kineticEnergy :  function()
	{
			// Need to do some fudging to avoid NaNs
			var vsq = this.vx*this.vx + this.vy*this.vy;
			var wsq = this.w * this.w;
			return (vsq ? vsq*this.m : 0) + (wsq ? wsq*this.i : 0);
	}
	  activate :  function()
	{
			if(!this.isRogue()){
					this.nodeIdleTime = 0;
					componentActivate(componentRoot(this));
			}
	}
	  activateStatic :  function(filter)
	{
			assert(this.isStatic(), "Body.activateStatic() called on a non-static body.");
			
			for(var arb = this.arbiterList; arb; arb = arb.next(this)){
					if(!filter || filter == arb.a || filter == arb.b){
							(arb.body_a == this ? arb.body_b : arb.body_a).activate();
					}
			}
			
			// TODO should also activate joints!
	}
	  pushArbiter :  function(arb)
	{
			assertSoft((arb.body_a === this ? arb.thread_a_next : arb.thread_b_next) === null,
					"Internal Error: Dangling contact graph pointers detected. (A)");
			assertSoft((arb.body_a === this ? arb.thread_a_prev : arb.thread_b_prev) === null,
					"Internal Error: Dangling contact graph pointers detected. (B)");
			
			var next = this.arbiterList;
			assertSoft(next === null || (next.body_a === this ? next.thread_a_prev : next.thread_b_prev) === null,
					"Internal Error: Dangling contact graph pointers detected. (C)");

			if(arb.body_a === this){
					arb.thread_a_next = next;
			} else {
					arb.thread_b_next = next;
			}

			if(next){
					if (next.body_a === this){
							next.thread_a_prev = arb;
					} else {
							next.thread_b_prev = arb;
					}
			}
			this.arbiterList = arb;
	}
	  sleep :  function()
	{
			this.sleepWithGroup(null);
	}
	  sleepWithGroup :  function(group){
			assert(!this.isStatic() && !this.isRogue(), "Rogue and static bodies cannot be put to sleep.");
			
			var space = this.space;
			assert(space, "Cannot put a rogue body to sleep.");
			assert(!space.locked, "Bodies cannot be put to sleep during a query or a call to cpSpaceStep(). Put these calls into a post-step callback.");
			assert(group === null || group.isSleeping(), "Cannot use a non-sleeping body as a group identifier.");
			
			if(this.isSleeping()){
					assert(componentRoot(this) === componentRoot(group), "The body is already sleeping and it's group cannot be reassigned.");
					return;
			}
			
			for(var i = 0; i < this.shapeList.length; i++){
					this.shapeList[i].update(this.p, this.rot);
			}
			space.deactivateBody(this);
			
			if(group){
					var root = componentRoot(group);
					
					this.nodeRoot = root;
					this.nodeNext = root.nodeNext;
					this.nodeIdleTime = 0;
					
					root.nodeNext = this;
			} else {
					this.nodeRoot = this;
					this.nodeNext = null;
					this.nodeIdleTime = 0;
					
					space.sleepingComponents.push(this);
			}
			
			deleteObjFromList(space.bodies, this);
	}
	 OK 
	 OK PyramidStack :> space.bodies[54].p (see)
	[object Object]
	  x :  -33148.6472820235
	  y :  -1037134.7168522858
	  add :  function(v2)
	{
			this.x += v2.x;
			this.y += v2.y;
			return this;
	}
	  sub :  function(v2)
	{
			this.x -= v2.x;
			this.y -= v2.y;
			return this;
	}
	  neg :  function()
	{
			this.x = -this.x;
			this.y = -this.y;
			return this;
	}
	  mult :  function(s)
	{
			this.x *= s;
			this.y *= s;
			return this;
	}
	  project :  function(v2)
	{
			this.mult(vdot(this, v2) / vlengthsq(v2));
			return this;
	}
	  rotate :  function(v2)
	{
			this.x = this.x * v2.x - this.y * v2.y;
			this.y = this.x * v2.y + this.y * v2.x;
			return this;
	}
	 OK 
	 OK 
	 OK PyramidStack :> space.bodies[54].f (see)
	[object Object]
	  x :  0
	  y :  0
	  add :  function(v2)
	{
			this.x += v2.x;
			this.y += v2.y;
			return this;
	}
	  sub :  function(v2)
	{
			this.x -= v2.x;
			this.y -= v2.y;
			return this;
	}
	  neg :  function()
	{
			this.x = -this.x;
			this.y = -this.y;
			return this;
	}
	  mult :  function(s)
	{
			this.x *= s;
			this.y *= s;
			return this;
	}
	  project :  function(v2)
	{
			this.mult(vdot(this, v2) / vlengthsq(v2));
			return this;
	}
	  rotate :  function(v2)
	{
			this.x = this.x * v2.x - this.y * v2.y;
			this.y = this.x * v2.y + this.y * v2.x;
			return this;
	}
	 OK 
	 OK PyramidStack :> space.bodies[54].shapeList (see)
	[object Object]
	  0 :  [object Object]
	 OK PyramidStack :> space.bodies[54].shapeList[0] (see)
	[object Object]
	  verts :  -15,-15,-15,15,15,15,15,-15
	  tVerts :  -33132.94600546985,-1037148.9811403713,-33162.91157010898,-1037150.4181288393,-33164.34855857715,-1037120.4525642003,-33134.382993938016,-1037119.0155757322
	  planes :  [object Object],[object Object],[object Object],[object Object]
	  tPlanes :  [object Object],[object Object],[object Object],[object Object]
	  type :  poly
	  body :  [object Object]
	  bb_t :  -1037119.0155757322
	  bb_r :  -33132.94600546985
	  bb_b :  -1037150.4181288393
	  bb_l :  -33164.34855857715
	  hashid :  28
	  sensor :  [object Boolean]
	  e :  0
	  u :  0.8
	  surface_v :  [object Object]
	  collision_type :  0
	  group :  0
	  layers :  -1
	  space :  [object Object]
	  collisionCode :  2
	  setVerts :  function(verts, offset)
	{
			assert(verts.length >= 4, "Polygons require some verts");
			assert(typeof(verts[0]) === 'number',
							'Polygon verticies should be specified in a flattened list (eg [x1,y1,x2,y2,x3,y3,...])');

			// Fail if the user attempts to pass a concave poly, or a bad winding.
			assert(polyValidate(verts), "Polygon is concave or has a reversed winding. Consider using cpConvexHull()");
			
			var len = verts.length;
			var numVerts = len >> 1;

			// This a pretty bad way to do this in javascript. As a first pass, I want to keep
			// the code similar to the C.
			this.verts = new Array(len);
			this.tVerts = new Array(len);
			this.planes = new Array(numVerts);
			this.tPlanes = new Array(numVerts);
			
			for(var i=0; i<len; i+=2){
					//var a = vadd(offset, verts[i]);
					//var b = vadd(offset, verts[(i+1)%numVerts]);
					var ax = verts[i] + offset.x;
					 var ay = verts[i+1] + offset.y;
					var bx = verts[(i+2)%len] + offset.x;
					var by = verts[(i+3)%len] + offset.y;

					// Inefficient, but only called during object initialization.
					var n = vnormalize(vperp(new Vect(bx-ax, by-ay)));

					this.verts[i  ] = ax;
					this.verts[i+1] = ay;
					this.planes[i>>1] = new SplittingPlane(n, vdot2(n.x, n.y, ax, ay));
					this.tPlanes[i>>1] = new SplittingPlane(new Vect(0,0), 0);
			}
	}
	  transformVerts :  function(p, rot)
	{
			var src = this.verts;
			var dst = this.tVerts;
			
			var l = Infinity, r = -Infinity;
			var b = Infinity, t = -Infinity;
			
			for(var i=0; i<src.length; i+=2){
					//var v = vadd(p, vrotate(src[i], rot));
					var x = src[i];
					 var y = src[i+1];

					var vx = p.x + x*rot.x - y*rot.y;
					var vy = p.y + x*rot.y + y*rot.x;

					//console.log('(' + x + ',' + y + ') -> (' + vx + ',' + vy + ')');
					
					dst[i] = vx;
					dst[i+1] = vy;

					l = min(l, vx);
					r = max(r, vx);
					b = min(b, vy);
					t = max(t, vy);
			}

			this.bb_l = l;
			this.bb_b = b;
			this.bb_r = r;
			this.bb_t = t;
	}
	  transformAxes :  function(p, rot)
	{
			var src = this.planes;
			var dst = this.tPlanes;
			
			for(var i=0; i<src.length; i++){
					var n = vrotate(src[i].n, rot);
					dst[i].n = n;
					dst[i].d = vdot(p, n) + src[i].d;
			}
	}
	  cacheData :  function(p, rot)
	{
			this.transformAxes(p, rot);
			this.transformVerts(p, rot);
	}
	  nearestPointQuery :  function(p)
	{
			var planes = this.tPlanes;
			var verts = this.tVerts;
			
			var v0x = verts[verts.length - 2];
			var v0y = verts[verts.length - 1];
			var minDist = Infinity;
			var closestPoint = vzero;
			var outside = false;
			
			for(var i=0; i<planes.length; i++){
					if(planes[i].compare(p) > 0) outside = true;
					
					var v1x = verts[i*2];
					var v1y = verts[i*2 + 1];
					var closest = closestPointOnSegment2(p.x, p.y, v0x, v0y, v1x, v1y);
					
					var dist = vdist(p, closest);
					if(dist < minDist){
							minDist = dist;
							closestPoint = closest;
					}
					
					v0x = v1x;
					v0y = v1y;
			}
			
			return new NearestPointQueryInfo(this, closestPoint, (outside ? minDist : -minDist));
	}
	  segmentQuery :  function(a, b)
	{
			var axes = this.tPlanes;
			var verts = this.tVerts;
			var numVerts = axes.length;
			var len = numVerts * 2;
			
			for(var i=0; i<numVerts; i++){
					var n = axes[i].n;
					var an = vdot(a, n);
					if(axes[i].d > an) continue;
					
					var bn = vdot(b, n);
					var t = (axes[i].d - an)/(bn - an);
					if(t < 0 || 1 < t) continue;
					
					var point = vlerp(a, b, t);
					var dt = -vcross(n, point);
					var dtMin = -vcross2(n.x, n.y, verts[i*2], verts[i*2+1]);
					var dtMax = -vcross2(n.x, n.y, verts[(i*2+2)%len], verts[(i*2+3)%len]);

					if(dtMin <= dt && dt <= dtMax){
							// josephg: In the original C code, this function keeps
							// looping through axes after finding a match. I *think*
							// this code is equivalent...
							return new SegmentQueryInfo(this, t, n);
					}
			}
	}
	  valueOnAxis :  function(n, d)
	{
			var verts = this.tVerts;
			var m = vdot2(n.x, n.y, verts[0], verts[1]);
			
			for(var i=2; i<verts.length; i+=2){
					m = min(m, vdot2(n.x, n.y, verts[i], verts[i+1]));
			}
			
			return m - d;
	}
	  containsVert :  function(vx, vy)
	{
			var planes = this.tPlanes;
			
			for(var i=0; i<planes.length; i++){
					var n = planes[i].n;
					var dist = vdot2(n.x, n.y, vx, vy) - planes[i].d;
					if(dist > 0) return false;
			}
			
			return true;
	}
	  containsVertPartial :  function(vx, vy, n)
	{
			var planes = this.tPlanes;
			
			for(var i=0; i<planes.length; i++){
					var n2 = planes[i].n;
					if(vdot(n2, n) < 0) continue;
					var dist = vdot2(n2.x, n2.y, vx, vy) - planes[i].d;
					if(dist > 0) return false;
			}
			
			return true;
	}
	  getNumVerts :  function() { return this.verts.length / 2; }
	  getVert :  function(i)
	{
			return new Vect(this.verts[i * 2], this.verts[i * 2 + 1]);
	}
	  collisionTable :  ,,function(poly1, poly2)
	{
			var mini1 = findMSA(poly2, poly1.tPlanes);
			if(mini1 == -1) return NONE;
			var min1 = last_MSA_min;
			
			var mini2 = findMSA(poly1, poly2.tPlanes);
			if(mini2 == -1) return NONE;
			var min2 = last_MSA_min;
			
			// There is overlap, find the penetrating verts
			if(min1 > min2)
					return findVerts(poly1, poly2, poly1.tPlanes[mini1].n, min1);
			else
					return findVerts(poly1, poly2, vneg(poly2.tPlanes[mini2].n), min2);
	}
	  draw :  function(ctx, scale, point2canvas)
	{
			ctx.beginPath();

			var verts = this.tVerts;
			var len = verts.length;
			var lastPoint = point2canvas(new cp.Vect(verts[len - 2], verts[len - 1]));
			ctx.moveTo(lastPoint.x, lastPoint.y);

			for(var i = 0; i < len; i+=2){
					var p = point2canvas(new cp.Vect(verts[i], verts[i+1]));
					ctx.lineTo(p.x, p.y);
			}
			ctx.fill();
			ctx.stroke();
	}
	  setElasticity :  function(e) { this.e = e; }
	  setFriction :  function(u) { this.body.activate(); this.u = u; }
	  setLayers :  function(layers) { this.body.activate(); this.layers = layers; }
	  setSensor :  function(sensor) { this.body.activate(); this.sensor = sensor; }
	  setCollisionType :  function(collision_type) { this.body.activate(); this.collision_type = collision_type; }
	  getBody :  function() { return this.body; }
	  active :  function()
	{
	// return shape->prev || (shape->body && shape->body->shapeList == shape);
			return this.body && this.body.shapeList.indexOf(this) !== -1;
	}
	  setBody :  function(body)
	{
			assert(!this.active(), "You cannot change the body on an active shape. You must remove the shape from the space before changing the body.");
			this.body = body;
	}
	  cacheBB :  function()
	{
			return this.update(this.body.p, this.body.rot);
	}
	  update :  function(pos, rot)
	{
			assert(!isNaN(rot.x), 'Rotation is NaN');
			assert(!isNaN(pos.x), 'Position is NaN');
			this.cacheData(pos, rot);
	}
	  pointQuery :  function(p)
	{
			var info = this.nearestPointQuery(p);
			if (info.d < 0) return info;
	}
	  getBB :  function()
	{
			return new BB(this.bb_l, this.bb_b, this.bb_r, this.bb_t);
	}
	  style :  function() {
	  var body;
	  if (this.sensor) {
		return "rgba(255,255,255,0)";
	  } else {
		body = this.body;
		if (body.isSleeping()) {
		  return "rgb(50,50,50)";
		} else if (body.nodeIdleTime > this.space.sleepTimeThreshold) {
		  return "rgb(170,170,170)";
		} else {
		  return styles[this.hashid % styles.length];
		}
	  }
	}
	 OK 
	 OK PyramidStack :> space.bodies[54].shapeList[0].body (see)
	[object Object]
	  p :  [object Object]
	  vy :  -14419.943338207034
	  vx :  -221.46100995567792
	  f :  [object Object]
	  w :  1.2985412210793767
	  t :  0
	  v_limit :  Infinity
	  w_limit :  Infinity
	  v_biasy :  0
	  v_biasx :  0
	  w_bias :  0
	  space :  [object Object]
	  shapeList :  [object Object]
	  arbiterList :  [object Null]
	  constraintList :  [object Null]
	  nodeRoot :  [object Null]
	  nodeNext :  [object Null]
	  nodeIdleTime :  0
	  m :  1
	  m_inv :  1
	  i :  150
	  i_inv :  0.006666666666666667
	  rot :  [object Object]
	  a :  215.24701472204214
	  sanityCheck :  function(){}
	  getPos :  function() { return this.p; }
	  getVel :  function() { return new Vect(this.vx, this.vy); }
	  getAngVel :  function() { return this.w; }
	  isSleeping :  function()
	{
			return this.nodeRoot !== null;
	}
	  isStatic :  function()
	{
			return this.nodeIdleTime === Infinity;
	}
	  isRogue :  function()
	{
			return this.space === null;
	}
	  setMass :  function(mass)
	{
			assert(mass > 0, "Mass must be positive and non-zero.");

			//activate is defined in cpSpaceComponent
			this.activate();
			this.m = mass;
			this.m_inv = 1/mass;
	}
	  setMoment :  function(moment)
	{
			assert(moment > 0, "Moment of Inertia must be positive and non-zero.");

			this.activate();
			this.i = moment;
			this.i_inv = 1/moment;
	}
	  addShape :  function(shape)
	{
			this.shapeList.push(shape);
	}
	  removeShape :  function(shape)
	{
			// This implementation has a linear time complexity with the number of shapes.
			// The original implementation used linked lists instead, which might be faster if
			// you're constantly editing the shape of a body. I expect most bodies will never
			// have their shape edited, so I'm just going to use the simplest possible implemention.
			deleteObjFromList(this.shapeList, shape);
	}
	  removeConstraint :  function(constraint)
	{
			// The constraint must be in the constraints list when this is called.
			this.constraintList = filterConstraints(this.constraintList, this, constraint);
	}
	  setPos :  function(pos)
	{
			this.activate();
			this.sanityCheck();
			// If I allow the position to be set to vzero, vzero will get changed.
			if (pos === vzero) {
					pos = cp.v(0,0);
			}
			this.p = pos;
	}
	  setVel :  function(velocity)
	{
			this.activate();
			this.vx = velocity.x;
			this.vy = velocity.y;
	}
	  setAngVel :  function(w)
	{
			this.activate();
			this.w = w;
	}
	  setAngleInternal :  function(angle)
	{
			assert(!isNaN(angle), "Internal Error: Attempting to set body's angle to NaN");
			this.a = angle;//fmod(a, (cpFloat)M_PI*2.0f);

			//this.rot = vforangle(angle);
			this.rot.x = Math.cos(angle);
			this.rot.y = Math.sin(angle);
	}
	  setAngle :  function(angle)
	{
			this.activate();
			this.sanityCheck();
			this.setAngleInternal(angle);
	}
	  velocity_func :  function(gravity, damping, dt)
	{
			//this.v = vclamp(vadd(vmult(this.v, damping), vmult(vadd(gravity, vmult(this.f, this.m_inv)), dt)), this.v_limit);
			var vx = this.vx * damping + (gravity.x + this.f.x * this.m_inv) * dt;
			var vy = this.vy * damping + (gravity.y + this.f.y * this.m_inv) * dt;

			//var v = vclamp(new Vect(vx, vy), this.v_limit);
			//this.vx = v.x; this.vy = v.y;
			var v_limit = this.v_limit;
			var lensq = vx * vx + vy * vy;
			var scale = (lensq > v_limit*v_limit) ? v_limit / Math.sqrt(lensq) : 1;
			this.vx = vx * scale;
			this.vy = vy * scale;

			var w_limit = this.w_limit;
			this.w = clamp(this.w*damping + this.t*this.i_inv*dt, -w_limit, w_limit);

			this.sanityCheck();
	}
	  position_func :  function(dt)
	{
			//this.p = vadd(this.p, vmult(vadd(this.v, this.v_bias), dt));

			//this.p = this.p + (this.v + this.v_bias) * dt;
			this.p.x += (this.vx + this.v_biasx) * dt;
			this.p.y += (this.vy + this.v_biasy) * dt;

			this.setAngleInternal(this.a + (this.w + this.w_bias)*dt);

			this.v_biasx = this.v_biasy = 0;
			this.w_bias = 0;

			this.sanityCheck();
	}
	  resetForces :  function()
	{
			this.activate();
			this.f = new Vect(0,0);
			this.t = 0;
	}
	  applyForce :  function(force, r)
	{
			this.activate();
			this.f = vadd(this.f, force);
			this.t += vcross(r, force);
	}
	  applyImpulse :  function(j, r)
	{
			this.activate();
			apply_impulse(this, j.x, j.y, r);
	}
	  getVelAtPoint :  function(r)
	{
			return vadd(new Vect(this.vx, this.vy), vmult(vperp(r), this.w));
	}
	  getVelAtWorldPoint :  function(point)
	{
			return this.getVelAtPoint(vsub(point, this.p));
	}
	  getVelAtLocalPoint :  function(point)
	{
			return this.getVelAtPoint(vrotate(point, this.rot));
	}
	  eachShape :  function(func)
	{
			for(var i = 0, len = this.shapeList.length; i < len; i++) {
					func(this.shapeList[i]);
			}
	}
	  eachConstraint :  function(func)
	{
			var constraint = this.constraintList;
			while(constraint) {
					var next = constraint.next(this);
					func(constraint);
					constraint = next;
			}
	}
	  eachArbiter :  function(func)
	{
			var arb = this.arbiterList;
			while(arb){
					var next = arb.next(this);

					arb.swappedColl = (this === arb.body_b);
					func(arb);

					arb = next;
			}
	}
	  local2World :  function(v)
	{
			return vadd(this.p, vrotate(v, this.rot));
	}
	  world2Local :  function(v)
	{
			return vunrotate(vsub(v, this.p), this.rot);
	}
	  kineticEnergy :  function()
	{
			// Need to do some fudging to avoid NaNs
			var vsq = this.vx*this.vx + this.vy*this.vy;
			var wsq = this.w * this.w;
			return (vsq ? vsq*this.m : 0) + (wsq ? wsq*this.i : 0);
	}
	  activate :  function()
	{
			if(!this.isRogue()){
					this.nodeIdleTime = 0;
					componentActivate(componentRoot(this));
			}
	}
	  activateStatic :  function(filter)
	{
			assert(this.isStatic(), "Body.activateStatic() called on a non-static body.");
			
			for(var arb = this.arbiterList; arb; arb = arb.next(this)){
					if(!filter || filter == arb.a || filter == arb.b){
							(arb.body_a == this ? arb.body_b : arb.body_a).activate();
					}
			}
			
			// TODO should also activate joints!
	}
	  pushArbiter :  function(arb)
	{
			assertSoft((arb.body_a === this ? arb.thread_a_next : arb.thread_b_next) === null,
					"Internal Error: Dangling contact graph pointers detected. (A)");
			assertSoft((arb.body_a === this ? arb.thread_a_prev : arb.thread_b_prev) === null,
					"Internal Error: Dangling contact graph pointers detected. (B)");
			
			var next = this.arbiterList;
			assertSoft(next === null || (next.body_a === this ? next.thread_a_prev : next.thread_b_prev) === null,
					"Internal Error: Dangling contact graph pointers detected. (C)");

			if(arb.body_a === this){
					arb.thread_a_next = next;
			} else {
					arb.thread_b_next = next;
			}

			if(next){
					if (next.body_a === this){
							next.thread_a_prev = arb;
					} else {
							next.thread_b_prev = arb;
					}
			}
			this.arbiterList = arb;
	}
	  sleep :  function()
	{
			this.sleepWithGroup(null);
	}
	  sleepWithGroup :  function(group){
			assert(!this.isStatic() && !this.isRogue(), "Rogue and static bodies cannot be put to sleep.");
			
			var space = this.space;
			assert(space, "Cannot put a rogue body to sleep.");
			assert(!space.locked, "Bodies cannot be put to sleep during a query or a call to cpSpaceStep(). Put these calls into a post-step callback.");
			assert(group === null || group.isSleeping(), "Cannot use a non-sleeping body as a group identifier.");
			
			if(this.isSleeping()){
					assert(componentRoot(this) === componentRoot(group), "The body is already sleeping and it's group cannot be reassigned.");
					return;
			}
			
			for(var i = 0; i < this.shapeList.length; i++){
					this.shapeList[i].update(this.p, this.rot);
			}
			space.deactivateBody(this);
			
			if(group){
					var root = componentRoot(group);
					
					this.nodeRoot = root;
					this.nodeNext = root.nodeNext;
					this.nodeIdleTime = 0;
					
					root.nodeNext = this;
			} else {
					this.nodeRoot = this;
					this.nodeNext = null;
					this.nodeIdleTime = 0;
					
					space.sleepingComponents.push(this);
			}
			
			deleteObjFromList(space.bodies, this);
	}
	 OK 
	PyramidStack :: space.sleepTimeThreshold=60
	cut
	PyramidStack :> space.bodies[1].getPos() js: push(tos().y);push(pop(1).x)
	PyramidStack :: space.bodies[1].setPos(v(pop()+Math.random()*6-3,pop()+Math.random()*6-3))
	100 nap rewind

</comment>