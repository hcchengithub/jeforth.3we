
	\ quit.f equivalent 
	
	: readTextFileAuto ( "pathname" -- "text" ) \ Read text file from jeforth.3ce host page.
		s" s' " swap + s" ' readTextFileAuto " + \ command line 以下讓 Extention page (the host page) 執行
		s" {} js: tos().forth='stopSleeping' js: tos().tos=pop() " + \ host side packing the message object
		s" message->tabid " + \ host commands after resume from file I/O
		js: chrome.runtime.sendMessage({forth:pop()}) 
		10000 sleep ;   

	: test1 ( -- "text" ) \ experiment : Read text file from jeforth.3ce host page.
		s" s' 3hta.bat' readTextFileAuto {} js: tos().forth='version' message->tabid "
		js: chrome.runtime.sendMessage({forth:pop()}) 
		10000 sleep ;   
		/// ok, 'version' really run on target page. Next step try to send something to target page.
		
	: test2 ( -- "text" ) \ experiment : Read text file from jeforth.3ce host page.
		s" s' 3hta.bat' readTextFileAuto {} js: tos().forth='version' js: tos().tos=1122334455 message->tabid"
		js: chrome.runtime.sendMessage({forth:pop()}) 
		10000 sleep ;   
		/// Ok! Target page stack become [1122334455, 3.1 (TOS)] as anticipated.
		/// the file has read too. But a 239 appear in host stack unexpectedly.
		/// try manual do the same thing on host.
		
	s' 3hta.bat' readTextFileAuto {} js: tos().tos=5566 <js> tos().forth='version .s' </js>  message->tabid		
	\ This line works fine 
		
	: readTextFileAuto ( "pathname" -- "text" ) \ Read text file from jeforth.3ce host page.
		s" s' " swap + s" ' readTextFileAuto .s " + \ command line 以下讓 Extention page (the host page) 執行
		s" {} js: tos().forth='stopSleeping' js: tos().tos=pop(1) " + \ host side packing the message object
		s" message->tabid " + \ host commands after resume from file I/O
		js: chrome.runtime.sendMessage({forth:pop()}) 
		10000 sleep ;   
stop
	
	js> tick('<selftest>').enabled=true;tick('<selftest>').buffer tib.insert
	js: tick('<selftest>').buffer="" \ recycle the memory

	char f/voc.f (install)
	char 3htm/f/html5.f (install)
	<text>
		char body <e> 
			<div id=console3ce class=ce3>
			<style>
				.ce3 {
					color:black;
					word-wrap:break-word;
					border: 1px ridge;
					background:#F0F0F0;
					padding:20px;
				}
				.ce3 div {
					font: 20px "courier new";
				}
				.ce3 textarea {
					width:100%;
					font: 20px "courier new";
					padding:4px;
					border: 0px solid;
					background:#BBBBBB;
				}
			</style>
			<div id=outputbox>this is the outputbox</div>
			<textarea id=inputbox>I am the inputbox id is inputbox</textarea>
			</div>
		</e> drop				
	</text> (dictate)
	char 3htm/f/element.f (install)


: readTextFileAuto ( "pathname" -- "text" ) \ Read text file from jeforth.3ce package.
    s" <text> " swap + s" </text> readTextFileAuto" + \ command line 以下讓 Extention page 執行
    <js> 
		chrome.runtime.sendMessage(
			{isCommand:true,text:pop()},
			function(result){
				type("readTextFileAuto responded\n"+result);
				push(result);
				execute('stopSleeping')
			}
		)
	</js>
    1000000 sleep ;




\ quit.f for jeforth.3ce
\
\ QUIT is the traditional forth system's CLI loop. jeforth.f kernel is common for all
\ applications. quit.f is the good place to define propritary features of each application.
\  

: cr         	( -- ) \ 到下一列繼續輸出 *** 20111224 sam
	js: type("\n") 1 nap js: window.scrollTo(0,endofinputbox.offsetTop);inputbox.focus() ;
	/// redefined in quit.f, 1 nap 使輸出流暢。
	/// Focus the display around the inputbox.
	\ 早一點 redefine 以便流暢 include 諸 ~.f 時的 selftest messages.

\ ------------------ Get args from URL -------------------------------------------------------
js> location.href constant url // ( -- 'url' ) jeforth.3htm url entire command line 
url :> split("?")[1] value args // ( -- 'args' ) jeforth.3htm args
args [if] char %20 args + :> split('%') <js>
for (var ss="",i=1; i<tos().length; i++){
// %20 is space and also many others need to be translated 
ss += String.fromCharCode("0x"+tos()[i].slice(0,2)) + tos()[i].slice(2);
};ss
</jsV> nip to args [then]
// Facebook always turn space to + that we need to support _ as space. 
args ?dup [if] <js> pop().replace(/_/g," ") </jsV> to args [then]

\ ------------------ Self-test of the jeforth.f kernel --------------------------------------
\ Do the jeforth.f self-test only when there's no command line. How to see command line is
\ application dependent. 
\

args [if] \ jobs to do, disable self-test.
js: tick('<selftest>').enabled=false
[else] \ no job, do the self-test.
js> tick('<selftest>').enabled=true;tick('<selftest>').buffer tib.insert
[then] 
js: tick('<selftest>').buffer="" \ recycle the memory

\ 發現透過 rawgit.com 可以直接執行發佈在 GitHub 上的 jeforth.3htm
\ 為了加快速度,以下都用絕對位址。避免讓 readTextFileAuto 順著 path
\ 慢慢嘗試錯誤。

include 3htm/f/jsc.f		    \ JavaScript debug console in 3htm/f
include f/voc.f					\ voc.f is basic of forth language
include 3htm/f/html5.f			\ html5.f is basic of jeforth.3htm
include 3htm/f/element.f		\ HTML element manipulation
include 3htm/f/platform.f		
include f/mytools.f		
include 3htm/f/editor.f
include 3ce/ce.f

\ ----------------- run the command line -------------------------------------
args tib.insert

\ ------------ End of jeforth.f -------------------
js: kvm.screenbuffer=null \ turn off the logging
.(  OK ) \ The first prompt after system start up.
js: window.scrollTo(0,endofinputbox.offsetTop);inputbox.focus()
