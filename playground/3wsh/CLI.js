
// UTF-8 without BOM 如果有 BOM 就會跑出： "Microsoft JScript compilation error: Syntax error"

// use ADO instead of fso, because fso can't access utf-8. http://www.w3schools.com/asp/ado_ref_stream.asp 
var ado = new ActiveXObject("ADODB.Stream");
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
var stdin = WScript.StdIn;
var stdout = WScript.StdOut;
stdout.Write(" %%%%%%%%% A simple CLI by JScript %%%%%%%%%%%\n" + readTextFile("3wsh\\CLI.js"));
for(;;){
	var cmd = stdin.ReadLine();
	if(cmd!="exit") stdout.Write("What's " + cmd + ' ?\n');
	else WScript.Quit(0);  // Terminate 
}

for (var i=0,argv=[],args=WScript.Arguments, argc=args.Unnamed.length; i<argc; i++){
	argv.push(args.Unnamed(i));
}

// 這些暫時都沒用到
// var fso = new ActiveXObject("Scripting.FileSystemObject");
// var fo = fso.OpenTextFile("3wsh\\CLI.js", 1); // ForReading = 1, ForWriting = 2, ForAppending = 8, TristateUseDefault = -2, TristateTrue = -1, TristateFalse = 0; // JScript 裡的 switch constants.
// var WshShell = WScript.CreateObject('WScript.Shell'); // common tool
// WScript.echo(123)
// WshShell.Popup("message", 0, 'Title', 48+3);
// var writeTextFile = function(pathname,data) { // Write string to text file.
// 	var objStream = ado;
// 	try{objStream.Close()}catch(err){}
// 	objStream.CharSet="utf-8"
// 	objStream.Open();
// 	objStream.WriteText(data); // option: adWriteChar=0(default), adWriteLine=1(\r\n)
// 	objStream.SaveToFile(pathname,2) // adSaveCreateOverWrite=2, adSaveCreateNotExist=1(can't overwite)
// 	objStream.Close()
// }
