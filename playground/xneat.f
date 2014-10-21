\ GB2312
// xneat.f  例舉 xneat wrapper 的應用。 

\ 上面這行用 // 註解是有目的的。 // 註解會變成最後一個新 word 的 help message, 
\ 而此時最後一個新 word 正是 xneat.f. xneat.f 讀進 jeforth 系統之後，檔案名 
\ xneat.f 本身會是一個 marker. 執行 marker 會把它本身以及其後的所有 words 
\ 都清除掉。所以 edit xneat.f 之後，可以跑一下 xneat.f 然後重新 include xneat.f 
\ 如此 系統比較清爽。

\ If vocabulary words are available then xneat words are to be under the xneat word-list.
' voc.f [if] 
  vocabulary xneat // ( -- ) Make xneat word-list be searched first, which is to set context="xneat".
  also xneat definitions 
[then]

s" global.XNScript = WScript.CreateObject('XNeat.Core')" js drop
\ Above line is failed in administrator mode, error message is,
\ JScript error : 無法創建名為「XNeat.Core」的對象。
\ So I guess JScript or XNeat do not allow running DLL in administrator mode.
s" global.XNScript " js constant XNScript

code test-XNScript.call ( -- ) \ XNeat example, call API MessageBox  
	XNScript.call("user32.dll" , "MessageBox", 0 , "Calling MessageBox API using XNScript.call", "XNeat Example", 0);
	end-code
	/// It works fine

s" global.User32 = XNScript.LoadDll('user32.dll')" js drop
s" global.User32 " js constant user32.dll

code test-User32.MessageBox ( -- ) \ Use User32.MessageBox to print something
	User32.MessageBox( 0 , "Calling MessageBox API using XNScript.Loaddll", "Example", 0);
	end-code
	/// It works fine

code mousexy ( -- x y ) \ Get mouse cursor position
	var Point = XNScript.Struct;
	Point.Add( "x" , "i32");
	Point.Add( "y" , "i32");
	User32.GetCursorPos(Point);
	stack.push(Point.x); 
	stack.push(Point.y); 
	end-code
	/// It works fine.
	
s" global.Kernel32 = XNScript.LoadDll('kernel32.dll')" js drop
s" global.Kernel32 " js constant kernel32.dll

code GetLocalTime ( -- SYSTEMTIME ) \ Try to use Kernel32
	var SYSTEMTIME = XNScript.Struct;
	SYSTEMTIME.Add("year" , "i16");
	SYSTEMTIME.Add("month" , "i16");
	SYSTEMTIME.Add("day" , "i16");
	SYSTEMTIME.Add("date" , "i16");
	SYSTEMTIME.Add("hour" , "i16");
	SYSTEMTIME.Add("minute" , "i16");
	SYSTEMTIME.Add("second" , "i16");
	SYSTEMTIME.Add("millisecond" , "i16");
	Kernel32.GetLocalTime(SYSTEMTIME);
	stack.push(SYSTEMTIME);
	end-code
	/// It works fine. SYSTEMTIME is a simple structure.
    /// e.g. this example prints "2013":
	/// GetLocalTime s" stack[stack.length-1].year" js . cr

code QueryPerformanceCounter ( -- ui64 ) \ Try to use Kernel32
	var LARGE_INTEGER = XNScript.Struct;
	LARGE_INTEGER.Add("low" , "ui32");
	LARGE_INTEGER.Add("high" , "ui32");
	Kernel32.QueryPerformanceCounter(LARGE_INTEGER);
	stack.push(LARGE_INTEGER.high*0x100000000 + LARGE_INTEGER.low);
	end-code
	/// It works fine. xneat does not support 64 bits so I have to recover that.
	/// : test 100 for QueryPerformanceCounter . cr next ; last execute

code QueryPerformanceFrequency ( -- ui64 ) \ Try to use Kernel32
	var LARGE_INTEGER = XNScript.Struct;
	LARGE_INTEGER.Add("low" , "ui32");
	LARGE_INTEGER.Add("high" , "ui32");
	Kernel32.QueryPerformanceFrequency(LARGE_INTEGER);
	stack.push(LARGE_INTEGER.high*0x100000000 + LARGE_INTEGER.low);
	end-code
	/// It works fine. xneat does not support 64 bits so I have to recover that.
	/// QueryPerformanceFrequency . cr shows 2337894 on LT73 Windows 8 session.
	
code GetTickCount ( -- ticks ) \ Get milliseconds elapsed since the system was started.
	stack.push(Kernel32.GetTickCount());
	end-code
	/// It works fine. : test 100 for GetTickCount . cr next ; last execute

code AttachConsole ( pid -- bool ) \ Attaches to the console of the specified process.
	stack.push(Kernel32.AttachConsole(stack.pop()));
	end-code
	
\ --------------------------------------- Not work yet ---------------------------------------------
code GetStdHandle ( nStdHandle -- handle ) \ Get handle of either stdinput, stdoutput, or stderr.
	var STD_INPUT_HANDLE = -10;
	var STD_OUTPUT_HANDLE = -11;
	var STD_ERROR_HANDLE = -12;
	stack.push(Kernel32.GetStdHandle(stack.pop()));
	stack.push(Kernel32.GetLastError());
	end-code
	/// Always return NULL(0) that means WSH does not have associated standard handles.
	/// If given with an invalid input i.e. -13, the return value is INVALID_HANDLE_VALUE (-1).
	
code test-Kernel32.SetConsoleTitle ( -- ) \ Try Kernel32.dll
	var title = XNScript.Struct;
	title.Add("buffer" , "t", 1024);
	title.buffer = "hello";
	stack.push(Kernel32.SetConsoleTitle(title, 1024));
	stack.push(Kernel32.GetLastError());
	end-code
	/// It doesn't work

code test-Kernel32.GetConsoleTitle ( -- ) \ Try Kernel32.dll
	var title = XNScript.Struct;
	title.Add("buffer" , "t", 1024);
	stack.push(Kernel32.GetConsoleTitle(title, 1024));
	stack.push(title.buffer);
	stack.push(Kernel32.GetLastError());
	end-code
	/// always get ""

code test-Kernel32.GetConsoleOriginalTitle ( -- ) \ Try Kernel32.dll
	var title = XNScript.Struct;
	title.Add("buffer" , "t", 1024);
	title.buffer = "lalalalal";
	stack.push(Kernel32.GetConsoleOriginalTitle(title, 1024));
	stack.push(title.buffer);
	stack.push(Kernel32.GetLastError());
	end-code
	/// always get ""
	
\s
s" global.WinIO = XNScript.LoadDll('winio32.dll')" js drop

code InitializeWinIo ( -- ) \ InitializeWinIo
	stack.push(WinIO.InitializeWinIo());
	end-code
	/// The below problem is, I believe, due to the DOS box is not administrator.
    /// js>WinIO.InitializeWinIo()
    /// Oooops! 对象不支持此属性或方法	
	/// I hope WinIO.InstallWinIoDriver() can install WinIO32.sys or WinIO64.sys and therefore allow none-Admin DOS box to use it.



\s

var hWnd = XNScript.Call ( "user32.dll", "GetForegroundWindow" );
var CmdPointer = XNScript.Call( "kernel32.dll", "GetCommandLine" );
XNScript.Call( "User32.dll", "MessageBox", 0, CmdPointer , "Example", 0);


CmdPointer = XNScript.CallInWindow( hWnd, "kernel32.dll", "GetCommandLine" )

var User32 = XNScript.LoadDll( "user32.dll" );
User32.MessageBox( 0 , "Calling MessageBox API using XNScript.Loaddll", "Example", 0);

-------------------------------------------------------

Example: XNScript.Loaddll as equivalent to XNScript.CallInWindow


var XNScript = WScript.CreateObject("XNeat.Core");
var hWnd = XNScript.Call ("User32.dll","GetForegroundWindow");
var User32InWnd = XNScript.LoadDll( "user32.dll" , hWnd );
var Kernel32InWnd = XNScript.LoadDll( "kernel32.dll" , hWnd );
CmdPointer = Kernel32InWnd.GetCommandLine
User32InWnd.MessageBox( 0, CmdPointer , "Example", 0);


-------------------------------------

// Sometimes you need to call win32 API that requires a pointer to struct, here comes the need to XNScript.Struct.
// For example to create a win32 Point Struct

var XNScript = WScript.CreateObject("XNeat.Core");
var Point = XNScript.Struct;
Point.add("x", "i32");
Point.add("y", "i32");

// as you can see we first create an empty Struct. then we start adding fields using the Add method
// The first parameter is the field name
// The second parameter is the field type which could be
// "ui32" for unsigned 32 bit
// "ui16" for unsigned 16 bit
// "ui8" for unsigned 8 bit
// "i32" for signed 32 bit
// "i16" for signed 16 bit
// "i8" for signed 8 bit
// "t" for ascii string
// "w" for unicode string
// for "t" & "w" fileds there exsits another parameter for the size
// Below are some examples that show the using of Win32 StructDim XNScript
// Set XNScript = WScript.CreateObject("XNeat.Core")

var User32 = XNScript.LoadDll( "user32.dll" );
var Point = XNScript.Struct;
Point.Add( "x" , "i32");
Point.Add( "y" , "i32");
User32.GetCursorPos(Point);
systemtype("Mouse x Position = " + Point.x + "\n"); 
systemtype("Mouse y Position = " + Point.y + "\n");

// This example gets the cursor position of the mouse using GetCursorPos API then display it.Dim XNScript
// Set XNScript = WScript.CreateObject("XNeat.Core")

Dim User32
Set User32 = XNScript.LoadDll( "user32.dll" )

Dim hWnd
hWnd = User32.GetForegroundWindow

Dim Caption
Set Caption = XNScript.Struct
Caption.Add "buffer" , "t", 1024

User32.GetWindowText hWnd, Caption, 1023

MsgBox Caption.buffer,0, "Foreground Window Caption"

In the above sample we see the using of ascii string and GetWindowText API to get the caption of the foreground windowDim XNScript
Set XNScript = WScript.CreateObject("XNeat.Core")

Dim User32
Set User32 = XNScript.LoadDll( "user32.dll" )

Dim hWnd
hWnd = User32.GetForegroundWindow

Dim szPath
Set szPath = XNScript.Struct
szPath.add "buffer", "t" , 1024 
XNScript.CallInWindow CLng(hWnd) , "kernel32.dll", "GetModuleFileName", 0, szPath, 1023

MsgBox szPath.buffer,0, "Foreground Window Path"

Another sample that shows the path of the Foreground Window.







