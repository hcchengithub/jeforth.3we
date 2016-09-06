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
	
	vocabulary box2dweb-arrow.f also box2dweb-arrow.f definitions
	
	cls <o> <h3>Click any where in the box below . . .</h3></o> drop
	
	<o> 
	<canvas id="canvas" width="640" height="480" style="background-color:#333333;"></canvas> 
	</o> constant canvas // ( -- obj ) canvas for Box2dWeb

	<h> 
	<script type="text/javascript" src="js/box2dweb/Box2dWeb-2.1.a.3.min.js"></script> 
	</h> constant Box2dWeb // ( -- obj ) The Box2dWeb.js script element

	<h> 
	<script type="text/javascript" src="playground/arrow.js"></script>
	</h> constant arrow.js // ( -- obj ) The arrow.js script element
	
	\ arrow.js pushes the world to data stack during initial
	constant world // ( -- obj ) Box2Dweb world
	code b2Vec2 ( x y -- objVector ) \ Convert x,y to vector
		var v = new Box2D.Common.Math.b2Vec2(pop(1),pop());
		push(v);
		end-code

	\ arrow0 :: SetAngle(-Math.PI/2)
	\ 0 30 b2Vec2 arrow6 :: SetLinearVelocity(pop())
