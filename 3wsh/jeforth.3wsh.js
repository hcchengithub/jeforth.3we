
// UTF-8 without BOM 如果有 BOM 就會跑出： "Microsoft JScript compilation error: Syntax error"

// 
// jeofrth.3wsh.js											hcchen5600 2014/12/14 15:16:19 
// Usage: cscript.exe jeofrth.3wsh.js cr .' Hello World!!' cr bye
//
var global = this;
var WshShell = WScript.CreateObject('WScript.Shell');
var fso = new ActiveXObject("Scripting.FileSystemObject");
// use ADO instead of fso, because fso can't access utf-8. http://www.w3schools.com/asp/ado_ref_stream.asp 
var ado = new ActiveXObject("ADODB.Stream");
var writeTextFile = function(pathname,data) { // Write string to text file.
	var objStream = ado;
	try{objStream.Close()}catch(err){}
	objStream.CharSet="utf-8"
	objStream.Open();
	objStream.WriteText(data); // option: adWriteChar=0(default), adWriteLine=1(\r\n)
	objStream.SaveToFile(pathname,2) // adSaveCreateOverWrite=2, adSaveCreateNotExist=1(can't overwite)
	objStream.Close()
}
var readTextFile = function(pathname) {
	var strData, objStream = ado;
	try{objStream.Close()}catch(err){}
	objStream.CharSet = "utf-8";
	objStream.Open();
	objStream.LoadFromFile(pathname);
	strData = objStream.ReadText();
	objStream.Close();
	return(strData);
}
eval(readTextFile(".\\kernel\\jeforth.js"));
// global.kvm = kvm;
kvm.stdin = WScript.StdIn;
kvm.stdout = WScript.StdOut;
kvm.WshShell = WshShell;
kvm.fso = fso;
kvm.ado = ado;
kvm.host = global;
kvm.appname = "jeforth.3wsh";
kvm.path = ["dummy", "kernel", "f", "3wsh/f", "3wsh", "playground"];

var print = kvm.print = function (s) { 
			try {
				var ss = s + ''; // Print-able test to avoid error 'JavaScript error on word "." : invalid data'
			} catch(err) {
				var ss = Object.prototype.toString.apply(s);
			}
			if(kvm.screenbuffer!=null) kvm.screenbuffer += ss; // 填 null 就可以關掉。
			kvm.stdout.Write(ss);
		}; 
kvm.version = "1.00";
kvm.greeting = function(){
			print("j e f o r t h . 3 w s h -- r"+kvm.version+'\n');
			print("Source code http://github.com/hcchengithub/jeforth.3we\n");
			return(parseFloat(kvm.version));
		}; 
kvm.greeting();

kvm.readTextFile = readTextFile;
kvm.writeTextFile = writeTextFile;
kvm.bye = function(n){WScript.Quit(n)}
kvm.debug = false;
kvm.screenbuffer = "";
kvm.prompt = "OK";

for (var i=0,argv=[],args=WScript.Arguments, argc=args.Unnamed.length; i<argc; i++){
	argv.push(args.Unnamed(i));
}
kvm.argv = argv; 
kvm.base = 10;
kvm.jsc = {prompt:""};
kvm.jsc.help = readTextFile('.\\3wsh\\f\\jsc.hlp');
kvm.jsc.xt = readTextFile('.\\3wsh\\f\\jsc.js');

// kvm.clearScreen = function(){console.log('\033c')} // '\033c' or '\033[2J' http://stackoverflow.com/questions/9006988/node-js-on-windows-how-to-clear-console
// kvm.beep
// kvm.inputbox
// kvm.EditMode
// kvm.forthConsoleHandler
// kvm.plain
// kvm.cmdhistory
// kvm.process
// kvm.BinaryStream
// kvm.BinaryFile
// kvm.objWMIService
// kvm.cv
// kvm.stdio = require('readline').createInterface({input: process.stdin,output: process.stdout});
// kvm.stdio.on('line', function (cmd){kvm.fortheval(cmd);kvm.print(' '+kvm.prompt+' ')});
// kvm.stdio.setPrompt(' '+kvm.prompt+' ',4);
kvm.init();
kvm.fortheval(kvm.readTextFile('kernel\\jeforth.f')+kvm.readTextFile('3wsh\\f\\quit.f'));
// kvm.fortheval(kvm.readTextFile('kernel\\jeforth.f'));
for(;;){
	var cmd = kvm.stdin.ReadLine();
	kvm.fortheval(cmd);
	kvm.print(' '+kvm.prompt+' ')
}



