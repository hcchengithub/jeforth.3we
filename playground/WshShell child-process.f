

: (exec)		( "command-line" -- objWshScriptExec ) \ Runs an application in a child command-shell.
				<js> WshShell.Exec(pop()) </js> ;
				/// The returned WshScriptExec Object provides access to the StdIn/StdOut/StdErr streams.
				

 OK char calc (exec) \ The Windows built-in calculater is opened.
 OK .s
      0: undefined (object)
 OK constant objCalc
 OK objCalc js> pop().name tib. \ ==> undefined (undefined)
 OK objCalc js> pop().caption tib. \ ==> undefined (undefined)
 OK jsinclude json2.js dropall objCalc js> JSON.stringify(pop()) .s
      0: {} (string)
 OK objCalc js> pop().Status tib. \ ==> 0 (number) \ The Windows built-in calculater is still there.
 OK objCalc js> pop().Status tib. \ ==> 1 (number) \ The Windows built-in calculater is closed.
 OK objCalc js> pop().Terminate() tib. \ ==> undefined (undefined) \ The caculater get closed as anticipated
 OK objCalc js> pop().Status tib. \ ==> 1 (number)
 OK objCalc js> pop().StdIn.Write("123") tib. \ ==> undefined (undefined)
 OK objCalc js> pop().StdOut.AtEndOfStream tib. \ ==> true (boolean) This statement doesn't return untill forced the calc.exe to end.
 OK objCalc js> pop().StdOut.ReadAll() tib. \ ==>  (string)
 OK objCalc js> pop().StdErr.AtEndOfStream tib. \ ==> true (boolean) This statement doesn't return untill forced the calc.exe to end.
 OK objCalc js> pop().StdErr.ReadAll() tib. \ ==>  (string)

<str> cscript jeforth.js </str> (exec) constant jeforth
jeforth js> pop().Status tib. \ ==> 0 (number)
jeforth js> pop().StdOut.ReadAll() tib. 
\ This statement doesn't return until I terminated the cscritpt session in TaskManager.
\ Then it dumps the entire jeforth.js screen. At that moment jeforth already terminated.
\ So I should not use .StdOut.ReadAll(), try .StdOut.Read(1)

jeforth js> pop().StdOut.AtEndOfStream tib.
jeforth js> pop().StdOut.ReadLine() tib. 
jeforth js> pop().Status tib.
jeforth js> pop().StdIn.Write("bye\n") tib.
jeforth js> pop().Status tib.

: screen ( -- ) \ Get child process' screen
	jeforth inline 
	var jeforth = pop();
	jeforth.StdOut.AtEndOfStream 
	jeforth.StdOut.ReadLine() tib. 



reDef objCalc
 OK objCalc js> pop().StdIn.Write("123") tib.
objCalc js> pop().StdIn.Write("123") tib. \ ==> undefined (undefined)
 OK


while (oExec.Status != 1)
     WScript.Sleep(100);







