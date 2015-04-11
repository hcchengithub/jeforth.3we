
	\ transpiler.f  FigTaiwan Forthtranspiler porject
	
	<h> <script src='js/jefvm.v3.js'    ></script></h>
	<h> <script src='js/jefvm.v3_ext.js'></script></h>
	
	code {F8} ( "command line" -- ) \ Let Forth Transpiler to run the inputbox
		var cmd = inputbox.value;
		inputbox.value=""; 
		vm.exec(cmd) ;
		jump2endofinputbox.click();
		inputbox.focus();
		end-code
	
	
	
	