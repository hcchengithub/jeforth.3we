
	\ quit.f for jeforth.3ce
	\
	\ QUIT is the traditional forth system's CLI loop. jeforth.f kernel is common for all
	\ applications. quit.f is the good place to define propritary features of each application.
	\  

	\ ------------------ Self-test of the jeforth.f kernel --------------------------------------
	js> tick('<selftest>').enabled=true;tick('<selftest>').buffer tib.insert
	js: tick('<selftest>').buffer="" \ recycle the memory

	\ 發現透過 rawgit.com 可以直接執行發佈在 GitHub 上的 jeforth.3htm
	\ 為了加快速度,以下都用絕對位址。避免讓 readTextFileAuto 順著 path
	\ 慢慢嘗試錯誤。

	include 3htm/f/jsc.f		    \ JavaScript debug console in 3htm/f
	include f/voc.f					\ voc.f is basic of forth language
	include 3htm/f/html5.f			\ html5.f is basic of jeforth.3htm
	
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
	
	include 3htm/f/element.f		\ HTML element manipulation
	include 3htm/f/platform.f		
	include f/mytools.f		
	include 3htm/f/editor.f

	\ ------------ End of jeforth.f -------------------
	js: kvm.screenbuffer=null \ turn off the logging
	.(  OK ) \ The first prompt after system start up.
	js: window.scrollTo(0,endofinputbox.offsetTop);inputbox.focus()


