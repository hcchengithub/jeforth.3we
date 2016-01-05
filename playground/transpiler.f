
	\ transpiler.f  FigTaiwan Forthtranspiler porject
	
	<h> <script src='js/jefvm.v3.js'    ></script></h> drop
	<h> <script src='js/jefvm.v3_ext.js'></script></h> drop
	
	code {F8} ( "command line" -- ) \ Let Forth Transpiler to run the inputbox
		var cmd = inputbox.value;
		inputbox.value=""; 
		vm.exec(cmd) ;
		window.scrollTo(0,endofinputbox.offsetTop);
		inputbox.focus();
		end-code
	
	
	
	