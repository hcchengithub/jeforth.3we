<comment>

	hcchen5600 2015/03/24 18:41:30 
	CSDN raymondcode 大作： [HTML5]使用Box2dWeb模拟飞行箭矢 http://blog.csdn.net/raymondcode/article/details/8684222
	在 jeforth.3htm 上幾乎直接 ok。只把下列原 .HTML source 所需要的 HTML5 canvas 準備好，串接 ~.js 的路徑即可。

	<html>  
		<head>  
		<title>Box2DWeb Test</title>  
			<script type="text/javascript" src="js/Box2dWeb-2.1.a.3.min.js"></script>  
			<script type="text/javascript" src="js/game.js"></script>  
		</head>  
	
		<body onload="init();">  
			<canvas id="canvas" width="640" height="480" style="background-color:#333333;"></canvas>  
		</body>  
	</html>  

</comment>

	<o> <canvas id="canvas" width="640" height="480" style="background-color:#333333;"></canvas></o> constant mycv // ( -- obj ) canvas for Box2dWeb
	<h> <script type="text/javascript" src="js/box2dweb/Box2dWeb-2.1.a.3.min.js"></script></h> constant Box2dWeb // ( -- obj ) The Box2dWeb.js script element

\ Box2dWeb.js 採用如上 <tag> 的方式 include 進來，很自然，有如 jQuery 從 index.html 裡加載，等效。
\ 但是 game.js 卻不很適合這樣 include, 因為要在裡面放 jsc Break-Point "if(kvm.debug){kvm.jsc.prompt='msg';eval(kvm.jsc.xt)}" 以
\ 便 debg 而如果用 <tag> 的方式，就會定義在 jeforth 之外，因而享受不到 jsc 的好處。例如 execute('(see)') 這樣的小工具都不能用。
\ 連 print() 也變成 window.print()，趣味盡失。
\ 所以原 <h> <script type="text/javascript" src="playground/game.js"></script></h> constant game.js // ( -- obj ) The game.js script element
\ 要改成下列方法，

	char game.js readTextFileAuto <text>
		init();
	</text> + js: eval(pop())


