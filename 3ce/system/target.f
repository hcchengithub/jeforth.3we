
	\ quit.f for jeforth.3ce target page
	\
	\ QUIT is the traditional forth system's CLI loop. jeforth.f kernel is common for all
	\ applications. quit.f is the good place to define proprietary features of each application.
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

	vocabulary target.f also target.f definitions
	
	js: if($(".console3we").length)$(".console3we").remove() \ remove existing forth console

	\ console3we outputbox 有需要, 很多 words 都需要它, 所以即使不
	\ 想讓 console3we 干擾 target page 的畫面也得用藏的而不是完全沒有。
	\ js> $(".console3we")[0].style.visibility="hidden" or "collapse"
	\ js> $(".console3we")[0].style.visibility="visible"
	
	char body <e> 
		<div class=console3we style="visibility:visible">
		<style>
			.console3we {
				color:black;
				word-wrap:break-word;
				border: 1px ridge;
				background:#F0F0F0;
				padding:20px;
			}
			.console3we div {
				font: 20px "courier new";
			}
			.console3we textarea {
				width:100%;
				font: 20px "courier new";
				padding:4px;
				border: 0px solid;
				background:#BBBBBB;
			}
		</style>
		<div id=header>
			<div style="font-family:verdana;">
				<b><div class=appname style="letter-spacing:16px;color:#555555;">appname</div></b>
				<div style="color:#40B3DF;">
				Revision <span id=rev style="background-color:#B4009E;color:#ffffff;">rev</span><br>
				Source code http://github.com/hcchengithub/jeforth.3we<br>
				Program path <span id=location>location</span><br>
				</div>
			</div>
		</div>
		<div id="outputbox"></div>
		<textarea id="inputbox" cols=100 rows=1></textarea>
		<span id=endofinputbox></span>
		</div>
	</e> drop				
	
	js> vm.type    value host.type // ( -- function ) work on target page type to host
	null ( dummy ) value target.type // ( -- function ) Target page type to outputbox

	<js>
		$('#rev').html(vm.version); // also .commandLine, .applicationName, ...
		$('#location').html(window.location.toString()); // it's built-in in DOM
		$('.appname').html(vm.appname); // 一次填好所有 appname
		
		// To enable target page console3we, 
		//     vm.type = target_type;
		//     js: $(".console3we")[0].style.visibility="visible"
		// To disable target page console3we, 
		//     vm.type = host.type;
		//     js: $(".console3we")[0].style.visibility="hidden"
		
		// vm.type() is the master typing or printing function.
		// The type() called in code ... end-code is defined in the kernel jeforth.js.
		// target_type(s) types to the target page outputbox, instead of to the host page 
		// that may be the popup page or a 3ce extension page.
		function target_type(s) { 
			try {
				var ss = s + ''; // Print-able test
			} catch(err) {
				ss = Object.prototype.toString.apply(s);
			}
			if(vm.screenbuffer!=null) vm.screenbuffer += ss; // 填 null 就可以關掉。
			if(vm.selftest_visible) $('#outputbox').append(vm.plain(ss)); 
		}
		vm.g["target.type"] = target_type;

		// onkeydown,onkeypress,onkeyup
		// event.shiftKey event.ctrlKey event.altKey event.metaKey
		// KeyCode test page http://www.asquare.net/javascript/tests/KeyCode.html
		function target_onkeydown(e) {
			// Initial version defined in 3ce/system/quit.f
			e = (e) ? e : event; var keyCode = (e.keyCode) ? e.keyCode : (e.which) ? e.which : false;
			switch(keyCode) {
				case 13: /* Enter */
					var cmd = inputbox.value; // w/o the '\n' character ($10). 
					inputbox.value = ""; // 少了這行，如果壓下 Enter 不放，就會變成重複執行。
					vm.forthConsoleHandler(cmd);
					return(false); 
			}
			return (true); // pass down to following handlers 
		}
		// 這個 keybaord handler 很兇地強塞給 document.onkeydown 可能會 conflict 
		// with target page's original settings, 但這樣做最簡單。下面的 platform.f 還會
		// 在條件成熟後用更完整的 keyboard handler 重新設定。
		document.onkeydown = target_onkeydown; 	
	</js>
	
		
	// 因為 console3we 不用時會 hidden 所以 console-host 切換時只需切換 display 如
	// 果切換 keyboard handler 是多此一舉。
	: console-host ( -- ) \ Target page console switch to host 3ce extension pages.
		cr ." Target page display switch to 3ce extension pages." cr
		host.type js: vm.type=pop() 
		js: $(".console3we")[0].style.visibility="collapse" \ 用 "collapse" 希望收掉留下的空間但同 "hidden" 無效
		;
	: console-target ( -- ) \ Target page console use local outputbox and inputbox.
		cr ." Target page display switch to local outputbox." cr
		target.type js: vm.type=pop() 
		js: $(".console3we")[0].style.visibility="visible"
		;
	last execute
	
	: cr ( -- ) \ 到下一列繼續輸出 *** 20111224 sam
		js: type("\n") 1 nap js: vm.scroll2inputbox();inputbox.focus() ;
		/// redefined in quit.f, 1 nap 使輸出流暢。
		/// Focus the display around the inputbox.
	
	include 3htm/f/element.f		\ HTML element manipulation
	include 3htm/f/platform.f		
	

	code run-inputbox ( -- ) \ Used in onKeyDown event handler.
		// 當命令來自 local 就把 display 切回 local target page
	    if(tick("target.type")) vm.type = vm.g["target.type"];
		var cmd = inputbox.value; // w/o the '\n' character ($10).
		inputbox.value = ""; // 少了這行，如果壓下 Enter 不放，就會變成重複執行。
		vm.cmdhistory.push(cmd);
		vm.forthConsoleHandler(cmd);
		end-code
		/// modified by 3ce target.f to auto switch dispaly back to local.
	
	include f/mytools.f		
	include 3htm/f/editor.f
	include 3htm/f/ls.f

	\ ------------ End of target.f -------------------
	js: vm.screenbuffer=null \ turn off the logging
	js: vm.scroll2inputbox();inputbox.focus()


