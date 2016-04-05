	
	\ 參考資料
	\ ShellWindows object                https://msdn.microsoft.com/en-us/library/windows/desktop/bb773974(v=vs.85).aspx
	\ Windows Internet Explorer object   https://msdn.microsoft.com/library/aa752084(v=vs.85).aspx
	
	\ 好像有用
	\ Microsoft Edge Developer Guide	 https://msdn.microsoft.com/en-us/library/dn904191(v=vs.85).aspx
	\ Windows Internet Explorer Command Identifiers
	\	js> [document|element].execCommand("BrowseMode").
	\	Chrome document 也有 execCommand.
	
	\ shell.application :> windows() 即 ShellWindows. 
	\ ShellWindows 有可能是 File Explorer 或 Windows Internet Explorer,
	\ Control panel 也是 Network and Sharing Center 也是 Outlook 也出現
	\ 在 ShellWindows 裡面。用 "ie :> application ." or "list-sw-windows" 
	\ 察看即知。
	
	s" ie.f"	source-code-header

	: see-ie 			( -- count ) \ List all IE processes and return the count
						s" where name = 'iexplore.exe'" see-process ;
						/// iexplore.exe process 的個數意義不明，與 ShellWindows count 不同
						/// ，因為後者含 File Explorer，但不含 Windows 10 的 Edge。第一次 
						/// Run iexplore.exe 會跑出兩個 IE process 一主一副。
						
	: kill-ie 			( -- bodyCount ) \ Kill all iexplore.exe processes, return the count.
						<js> var f=confirm("Kill IEs are you sure? ShellWindows.count will not be reduced");f</jsV>
						if s" where name = 'iexplore.exe'" kill-them then ;
						/// (Win8) IE 被徹底用 processID 殺掉之後, ShellWindows :> count 
						/// 仍不會減去，因為它可能本來就是 null。總之非正常能使用。

	shell.application :> windows() 
	constant ShellWindows // ( -- obj ) Shell Windows (File Explorer & Internet Explorer) object.
		/// 這個 collection 就是所有的 IE 以及 File Explorer windows. ShellWindows :> count 就是
		/// 兩者頁面的總數。ShellWindows :> item(0,1,2,3...) 即 FE/IE objects (與 DOM window 不
		/// 同)。ShellWindows 本身沒有開啟 IE 頁面的功能。我本來以為 ShellWindows :> count >= 1 
		/// 時 ShellWindows :> item(0) 可以當作 default IE object 來操作，可是 item(0) 常常是 null! 
						
	\ IE run 起來有幾種方式
	\ 1. s" iexplore ibm.com" (fork) 當 ShellWindows.count==0 時必須用這個，那乾脆都用這個。
	\ 2. ShellWindows.item(0).navigate("url") 當 ShellWindows.count==0 時不能用。
	\ 3. GetObject("","InternetExplorer.Application") 取得一個沒有 document 的 IE object
	\ 4. CreateObject("InternetExplorer.Application") 用不著，咱禁用，不必研究。
	\ **Note** 有了 ShellWindows 可以隨時 access 所有的 FE/IE 頁面, 後三者都用不著了。
	
	: sw(i)				( i -- sw|null ) \ Get ShellWindow object of the indexed ShellWindow
						js> vm.g.ShellWindows.item(parseInt(pop())) ;
						/// IE,FE run 起來之前 sw 是 null 即 IE process 不存在。
						/// 若把 window 都關掉: 0 sw(i) :> document.parentWindow 
						/// :: close() 也會把 IE process 關掉, 0 sw(i) 就是 null。

	: list-sw-windows	( -- count ) \ List all sw windows' locationName and URL
						ShellWindows :> count ?dup if dup for dup r@ - ( COUNT i )
						dup . space ( COUNT i ) sw(i) ?dup if dup :> LocationName . space :> LocationURL . else ." Null" then cr
						next drop then ; last alias list
						/// 有可能是空的。
	
	\ 我不知道哪個 sw window 是 activated
	\ 以下命令固定用 ShellWindows.item(theIE) 來做 automation。
	
	0 value theIE // ( -- i ) Make ShellWindows.item(theIE) the default IE object.
	
	: sw 				( -- sw|null ) \ Get the ShellWindows.item(theIE) sw object
						js> vm.g.ShellWindows.item(parseInt(vm.g.theIE)) ;
						/// ShellWindows collection 有可能跳空，sw(0) 是 null 即使 sw(1)
						/// 有東西。 sw 存在,但沒有 connect 任何網址時 ReadyState 也是 4,
						/// 也有 document, 但是 document 裡 innerHTML 是 undefined，這樣
						/// 就 available 了, 可以 navigate() 了。sw 都是 null 時推薦用 
						/// s" iexplore" (fork) 把 IE 先 run 起來。High level 的 ie command 
						/// 會自動搞定這些。

	: isIE?				( object -- flag ) \ Is the object IE?
						dup if 
							js> typeof(tos())=="object" ( obj f )
							<js> pop(1).name.indexOf("Internet Explorer")!=-1</jsV> ( f f )
							and 
						else drop false then ;
						\ 必須用 "Internet Explorer" 判斷，因為 FE.name 有可能是中
						\ 文的 "檔案總管"。

	: ready				( -- ) \ Wait theIE to become ready
						1200 for ( total 120 sec which is 2 minutes ) 
							100 nap sw isIE? if
								sw :> ReadyState==4 if ( break ) r> drop 0 >r then
							then
						next ;
						/// ctrl-break if don't want to wait so long.
						
	: busy				( -- ) \ Wait  theIE to become not-busy
						1200 for ( total 120 sec which is 2 minutes ) 
							100 nap sw isIE? if
								sw :> busy if else ( break ) r> drop 0 >r then
							then
						next ;
						/// ctrl-break if don't want to wait so long.
						
	: check-IE			( -- ) \ NOP or abort if theIE is not available.
						sw isIE? if else drop beep 
						abort" Error! 'theIE' object is empty." 
						then ;

	: ie 				( -- ) \ Make sure sw points to theIE object which is alive
						sw isIE? if else
							<js> 
							for (var i=0; i<vm.g.ShellWindows.count; i++){
								if(vm.g.ShellWindows.item(i) && 
								   vm.g.ShellWindows.item(i).name.indexOf("Internet Explorer")!=-1){
									vm.g.theIE = i;
									break;
								}
							}
							if (i >= vm.g.ShellWindows.count){
								vm.g.theIE = i;
								dictate('s" iexplore about:blank" (fork)');
							}
							</js>
						then ;
						/// If there're an IE existing the first one will be theIE
						/// or open an about:blank page. So you need to check 'ready' 
						/// and 'busy' before using the IE object.

	: window			( -- window|null ) \ Get the ShellWindows.item(theIE) window object
						ie ready sw :> ReadyState if
							sw :> document.parentWindow
						else null then ;
						/// 疑問：sw.ReadyState 不是 0 就有 document 是真的嗎?
						/// 錯,FE 也有 ReadyState,正常是 4,要先確定是 IE。
						/// 只要是 IE 即使 navigate about:blank 出來的空頁也有 document。
						/// sw(i).ReadyState == 0 就不會有 document。
						/// 有 document 也不一定有 innerHTML 的內容，但一定有 parent 即 window。
						/// document :> constructor \ ==> undefined (undefined) 這是 FE。
						/// document :> constructor \ ==> [object HTMLDocument] (object) 這是 IE。
						
	: document			( -- obj ) \ Get ShellWindows.item(theIE).document object
						ie ready sw :> document ;
	: locationName		( -- "name" ) \ Get ShellWindows.item(theIE).locationName string
						ie ready sw :> locationName ;
	: locationUrl		( -- obj ) \ Get ShellWindows.item(theIE).locatonUrl string
						ie ready sw :> locationUrl ;
	: visible			( -- ) \ Make ShellWindows.item(theIE) visible
						sw :: visible=true ;
	: visible?			( -- flag ) \ Get ShellWindows.item(theIE).visible setting
						sw :> visible ;
	: (navigate)		( "url" flags -- ) \ Visit the URL
						ie ready sw :: navigate(pop(1),pop()) ;
						/// Flags : A combined number of following bits:
						/// 	navOpenInNewWindow = 0x1,
						/// 	navNoHistory = 0x2,
						/// 	navNoReadFromCache = 0x4,
						/// 	navNoWriteToCache = 0x8,
						/// 	navAllowAutosearch = 0x10,
						/// 	navBrowserBar = 0x20,
						/// 	navHyperlink = 0x40,
						/// 	navEnforceRestricted = 0x80,
						/// 	navNewWindowsManaged = 0x0100,
						/// 	navUntrustedForDownload = 0x0200,
						/// 	navTrustedForActiveX = 0x0400,
						/// 	navOpenInNewTab = 0x0800, it works
						/// 	navOpenInBackgroundTab = 0x1000,
						/// 	navKeepWordWheelText = 0x2000,
						/// 	navVirtualTab = 0x4000,
						/// 	navBlockRedirectsXDomain = 0x8000,
						/// 	navOpenNewForegroundTab = 0x10000
						
	: navigate			( <url> -- ) \ ShellWindows.item(theIE) to visit the URL
						BL word 0 (navigate) ;

	: remove-script-from-element ( element -- ) \ Through jQuery, the element will be modified.
						js> $("script",pop()) ( jqObject )
						<js>
							for (var i=0; i<tos().length; i++)
								tos()[i].parentNode.removeChild(tos()[i])
						</js>
						( jqObject ) drop ;
						/// The given element 可以是某個 IE 頁面，不一定在本地。
						/// Example:
						///   document js> $("*",pop())[0] ( IE web page ) 
						///   remove-script-from-element \ document's trimed now
						///   document :> body.innerHTML </o> \ No script trouble

	<comment>
	[x] jQuery 可以從 jeforth 伸手進 IE 網頁工作：
		\ jQuery 可以對 IE 網頁工作(而非侷限在 jeforth.hta 的 window 裡)
		\ 整個 IE 網頁 elements 存進一個 array 
			document <js> $("*",pop()).toArray() </jsV> constant a
			a :> length tib.
		\ 以下三個例子 work 但是寫法很多餘。當初怎麼想的,太拘泥於 
		\ jQuery(selector [,context]) 的形式，照下面這樣之所以會成功
		\ 我猜是因為 2nd arguement 無用，被正確地忽略了。
			a :> [0] a :> [9] js> $(pop(),pop()).first().click(function(){alert("abc")}) \ works
			a :> [0] a :> [9] js> $(pop(),pop()).removeAttr('style') \ it works
			a :> [0] a :> [9] js> $(pop(),pop()).css("background-color","yellow") \ works
		\ 以上的第三個為例，應該簡單寫成這樣：
			js: $(vm.g.a[1120]).css("background-color","pink")
		\ 整頁塗成黃色
			document <js> $("*",pop()).css("background","yellow") </js>
	[x] 利用 jQuery 鎖定目標，在 div 外框打上紅細線
		--> 複習一下, 不久前才搞懂的 jQuery 2nd argument, the 'context'。
			document js> $("div",pop()) constant page.jq \ 取得 jQuery object, 只限 <DIV>
			document js> $("*",pop()) constant page.jq \ 取得 jQuery object, 整個網頁
			page.jq :> [0].outerHTML </o> \ 在 jeforth.3hta outputbox 上顯示
			\ 我記得 page.jq :> [0] 是 query 結果的 root 整體。
			page.jq :> length . \ ==> 1 看有沒有東西
			page.jq :> [0] ce! ce \ ==> 用 jeforth.3hta element.f 來直接操作這個 IE 上的網頁。
		--> jquery 出來的東西裡有很多 <script> 如上經 </o> 顯示會有很多問題。
			如何把它們都去掉? 簡單：
			document js> $("script",pop()) constant script.jq \ ==> 成功 script.jq :> length \ ==> 19 (number)
			script.jq :> [0].outerHTML \ ==> 可查看 source code。
			19 [for] 19 r@ - script.jq :> [pop()] removeElement 100 nap [next] \ 全部刪除
			Bingo!!
			html5.f 裡有以前用 RegEx 方法寫的 remove-script, remove-select, remove-onmouse
			等，[x] 應該都改成用 jquery --> remove-script-from-element done.
		--> 這樣真的可以為某 element 加紅框了,但不知如何去除?
			\ myh2 :: setAttribute('style',"background-color:white;border: 1px ridge")
			\ style="background-color:red;border: 1px ridge"
			\ clearAttributes() \ remove all attributes
			\ myh2 :: clearAttributes()
			myh2 <js> pop().setAttribute('style',"background-color:white;border: 2px ridge red")</js>	
		--> 給全部 <DIV> 加上紅框
			document js> $("div",pop())[0] <js> pop().setAttribute('style',"background-color:white;border: 2px ridge red")</js>	
			\ [0] 是整頁,以上把整頁的快框弄成細紅線，個別 div 則無。改成 [1] 就僅第一個 div 打上紅線框。
			document <js> $("div",pop()).css("border","2px ridge red")</js>
			\ 以上從 css 下手把全部 div 都打上紅細線。
		--> remove it : document <js> $("div",pop())[0].removeAttribute('style')</js>
			\ 移除整頁外框的紅細線。
			
	[x] Click 到某個 element 的 event 處理方法,
		http://api.jquery.com/css/ 抄到這段 example 
		<script>
			$( "div" ).click(function() {
			  var html = [ "The clicked div has the following styles:" ];
			 
			  var styleProps = $( this ).css([
				"width", "height", "color", "background-color"
			  ]);
			  $.each( styleProps, function( prop, value ) {
				html.push( prop + ": " + value );
			  });
			 
			  $( "#result" ).html( html.join( "<br>" ) );
			});
		</script>
		\ 以上網友的範例改寫成 jeforth.3we 可直接執行的形式。
		\ 執行後任意 click 就會 show 出該 element 的 CSS properties,
		<js>
			$( "div" ).click(function() {
				type("The clicked div has the following styles:\n");
				var styleProps = $( this ).css([
					"width", "height", "color", "background-color"
				]);
				$.each( styleProps, function(prop,value) {
					type( prop + ":" + value + " ");
				});
				type("\n");
			});
		</js>
		--------------------------------------------------------
		\ 執行後對 theIE 網頁隨處 click 一下, 整頁每個 element 都打上紅細線。
		\ 原因是 bubbling (我想是這麼稱呼)
		
			document <js> 
				$("*",pop()).click(function(){
					$(this)
					.css("border","2px ridge red")
					.addClass("_selected_");
				});
			</js>
			
		\ 照這樣一 click 下去, 被 click 到的 element 以及它的 parents 全部都
		\ 被一一執行到。似乎像這樣類似氣泡向上擴散到 parents 上去叫做 bubbling? 
		\ 有了 flag 就可以終止 bubbling。不知這個方法好不好？ --> 不好 return(false) 即可

			false value flag // ( -- boolean ) 控制不讓 bubble 擴散上去的開關。
			document <js> 
				$("*",pop()).click(function(){
					if(vm.g.flag) return;
					$(this)
					.css("border","2px ridge red")
					.addClass("_selected_");
					vm.g.flag = true;
				});
			</js>
			
		\ 把打了紅框的 , 印出來看也證實。
		document <js> $("._selected_",pop()).each(function(){
			type("-------------------------\n");
			type($(this).html());
			type("\n");
		});
		</js>		
		調查整串都被 click 到的順序...由內而外。
		document <js> 
		$("*",pop()).click(function(){
			print(this.toString());
		});
		</js>
		[object HTMLParagraphElement] 由最內直接 click 到的 element 先 trigger。
		[object HTMLDivElement]
		[object HTMLBodyElement]
		[object HTMLHtmlElement] 最後一個 document 可以當作結尾。

		所以只要看到 flag 舉起來了就不執行即可。 ---> 成功!
		
		\ 過一會兒就把 flag 清掉, 以便連續選擇。
		document <js> 
		$("*",pop()).click(function(){
			if(vm.flag) {
				vm.g.setTimeout("vm.flag=false",500);
				return;
			}
			vm.flag = true;
			if($(this).hasClass("_selected_")){
				$(this)
				.removeClass("_selected_")
				.removeAttr('style');
				return;
			}
			$(this)
			.css("border","4px dashed red")
			.addClass("_selected_");
		});
		</js>
		
		\ 顯示選中的有幾個
		document js> $("._selected_",pop()).length .
		
		\ 把選中的都轉到 outputbox 來顯示。速度會很慢
		document <js> $("._selected_",pop()).each(function(){
			push($(this).html());
			execute("</o>");
		});
		</js>		
		
		\ 刪除所有選中的東西
		document <js> $("._selected_",pop()).each(function(){
			push(this);
			execute("removeElement");
		});
		</js>		
		
		\ 刪除所有【選中以外】的東西
		"" value selected 
		document <js> 
		var doc=pop();
		$("._selected_",doc).each(function(){
			vm.g.selected += $(this)[0].outerHTML;
		});
		doc.body.innerHTML = vm.g.selected;
		</js>		

		\ 想要把重複的 track item 都刪掉，但本程式會當，好像變成無窮迴路。
		<js>
			for (var i=0; i<vm.g.track.length; i++){
				for (var j=i+1; i<vm.g.track.length; j++) {
					if (vm.g.track[i]==vm.g.track[j]) vm.g.track.splice(j,1);
				}
			}
		</js>
		
		\ 改用 mouseenter mouseleave 取代會冒泡的 click。有效,但 parent 沒有 leave 就不會消失。
		document <js> var doc=pop();
		$("*",doc).mouseenter(function(){
			$(this).css("border","4px dashed red");
		});
		$("*",doc).mouseleave(function(){
			$(this).removeAttr('style');
		});
		</js>
		
		\ 改用 mouseenter mouseleave 取代會冒泡的 click。有效,但 parent 沒有 leave 就不會消失。
		\ 用 lastThing 記住收到 event 的 this, mouseenter 時一律清除 lastThing
		0 value theElement // ( -- element ) The recent hovered DOM element.
		document <js> var doc=pop();
			$("*",doc).mouseenter(function(){
				print("mouse enter "+ this); execute("cr");
				$(vm.g.theElement).removeAttr('style'); // 無須防呆
				$(this).css("border","4px dashed red");
				vm.g.theElement = this;
			});
			$("*",doc).mouseleave(function(){
				print("mouse leave"+ this); execute("cr");
				$(this).removeAttr('style');
			});
		</js>
		
		\ 想讀取 attached 網頁的 css 失敗
		js> $("#inputbox").css("background-Color") .s 成功
		js> $("div",vm.g.doc).css("background-Color") .s 失敗 JavaScript error : Unspecified error.
		js> $("div",vm.g.doc)[0].getAttribute("style") . 成功 所以是 jQuery 的問題 "border: 4px dashed yellow; background-color: yellow;" 
		
		\ 如果快速把 mouse 移到某 div 收到的 event 順序如下, 不照順序! 所以利用 lastThing 或 theElement 
		\ 去清前一個也不靈。
		\	mouse enter [object HTMLBodyElement]
		\	mouse enter [object HTMLHtmlElement]
		\	mouse enter [object HTMLDivElement]
		\ [x] 如果忽略 Body 跟 Html 也許就好了
		
		\ Push the recent node to private track array.
		\ [f]reeze command (70) to stop receiving mouseenter mouseleave, toggle.
		\ [<] [>] command (188,190) to move around hovered nodes.
		$(doc).keydown(function(e){
			e = (e) ? e : event; var keycode = (e.keyCode) ? e.keyCode : (e.which) ? e.which : false;
			switch(keycode) {
				case 70: /* f */
					print('f ');
					return(false); 
				case 188: /* < ,*/
					print('< ');
					return(false); 
				case 190: /* > . */
					print('> ');
					return(false); 
			}
			return (true); // pass down to following handlers 
		})
		
		
		\ -------------------------------------
		[] value track // ( -- [node,..] ) The history track array of visited DOM nodes
		0 value itrack // ( -- int ) index of the track array
		document <js> var doc=pop();
			$(doc).keydown(function(e){
				e = (e) ? e : event; var keycode = (e.keyCode) ? e.keyCode : (e.which) ? e.which : false;
				switch(keycode) {
					case 70: /* [f]reeze */
						print('f ');
						return(false); 
					case 83: /* [s]elect */
						print('f ');
						return(false); 
					case 188: /* < ,*/
						print('< ');
						return(false); 
					case 190: /* > . */
						print('> ');
						return(false); 
				}
				return (true); // pass down to following handlers 
			})
			$("*",doc).mouseenter(function(){
				print("Enter " + this.nodeName + ". ");
				$(vm.g.track[vm.g.track.length-1]).removeAttr('style'); // 無須防呆
				$(this).css("border","4px dashed red");
				vm.g.track.push(this);
				vm.g.itrack = vm.g.track.length-1;
			});
			$("*",doc).mouseleave(function(){
				print("Leave " + this.nodeName + ". ");
				$(this).removeAttr('style');
			});
		</js>
		
		\ -------------------------------------
		
		\ 完整功能 Hover 打紅框, Freeze, Select, Delete, Unselect, View, Clear
		\ 能用 [<][>] 倒退前進就不怕 event 順序不靈的問題。
		--- marker ---
		[] value track // ( -- [node,..] ) The history track array of visited DOM nodes
		0 value itrack // ( -- int ) index of the track array
		0 value freeze // ( -- boolean ) The freezing flag
		document <js> var doc=pop();
			var GoOn=false;
if(vm.debug){vm.jsc.prompt='1111';eval(vm.jsc.xt)}
			
			$(doc).keydown(function(e){
				e = (e) ? e : event; var keycode = (e.keyCode) ? e.keyCode : (e.which) ? e.which : false;
				switch(keycode) {
					case 67: /* [c]lear */
						for(var i=0; i<vm.g.track.length; i++){
							$(vm.g.track[i])
							.removeAttr('style')
							.removeClass("_selected_");
						}
						return(!GoOn); 
					case 68: /* [d]elete the highlighted node */
						push(vm.g.track[vm.g.itrack]);
						execute("removeElement");
						return(!GoOn); 
					case 70: /* [f]reeze */
						vm.g.freeze = !vm.g.freeze;
						type("The freezing flag : " + vm.g.freeze); execute("cr");
						return(!GoOn); 
					case 83: /* [s]elect */
						$(vm.g.track[vm.g.itrack])
						.removeAttr('style')
						.css("border","2px solid lime")
						.addClass("_selected_");
						return(!GoOn); 
					case 85: /* [u]nselect */
						$(vm.g.track[vm.g.itrack])
						.removeAttr('style')
						.removeClass("_selected_");
						return(!GoOn); 
					case 86: /* [v]iew selected nodes */
						for(var i=0; i<vm.g.track.length; i++){
							$(vm.g.track[i]).removeAttr('style');
							if($(vm.g.track[i]).hasClass("_selected_"))
								$(vm.g.track[i]).css("border","2px solid lime");
						}
						return(!GoOn); 
					case 188: /* < , */
						$(vm.g.track[vm.g.itrack]).removeAttr('style'); // 無須防呆
						vm.g.itrack = Math.max(0,vm.g.itrack-1);
						$(vm.g.track[vm.g.itrack]).css("border","4px dashed red");						
						return(!GoOn); 
					case 190: /* > . */
						$(vm.g.track[vm.g.itrack]).removeAttr('style'); // 無須防呆
						vm.g.itrack = Math.min(vm.g.track.length-1,vm.g.itrack+1);
						$(vm.g.track[vm.g.itrack]).css("border","4px dashed red");						
						return(!GoOn); 
				}
				return (!GoOn);
			});
if(vm.debug){vm.jsc.prompt='2222';eval(vm.jsc.xt)}
			$("*",doc).mouseenter(function(){
				type("Enter " + this.nodeName + ". ");
				if (vm.g.freeze) return;
				$(vm.g.track[vm.g.itrack]).removeAttr('style'); // 無須防呆
				if (vm.g.track[vm.g.track.length-1]!=this) vm.g.track.push(this);
				vm.g.itrack = vm.g.track.length-1;
				$(vm.g.track[vm.g.itrack]).css("border","4px dashed red");						
			});
if(vm.debug){vm.jsc.prompt='3333';eval(vm.jsc.xt)}

			$("*",doc).mouseleave(function(){
				type("Leave " + this.nodeName + ". ");
				if (vm.g.freeze) return;
				$(this).removeAttr('style'); // 無須防呆
			});
if(vm.debug){vm.jsc.prompt='4444';eval(vm.jsc.xt)}

		</js>
	
	</comment>	
	
	<comment>	
		--------------------------------------------------------
		改寫成 click 任何東西都把它 hide , <ESC> 或 Ctrl-Z toggle 回來。
		--> 這個不成功, 手伸到 IE 去有些 jQuery 功能就不靈了：
			js: $(vm.g.a[1120]).hide() \ ==> JavaScript error : Unspecified error.
		--> [ ] 實驗在本地用 $(select,context) 形式看行不行？

	</comment>	
	
	<comment>	
		Study HTML <article> </article> tag

		阮兄，说句题外话。你的版式似乎对阅读器的支持不是很好，例如Safari的Reader，经过实验估
		计是p元素太多，但没有突出文章主体，话说只要把文章内容放在article标签里就好了。<=== 我
		可以用 jeforth.3hta ie.f 來幫網頁加 artical tag 試試看！

		teven 说：
		引用阮一峰的发言：
		加了一个article标签，好像解决了。
		但是为什么作者和日期信息，都会被省略呢……
		是用<time>标签定义日期吗？
		试试这个，阮兄
		<article>
		　　<header>
		　　　　<h1>title</h1>
		　　　　<p>Date：<time　pubdate="pubdate">7/09/2012</time></p>
		　　　　<p>Posted　by:　steven</p>
		　　</header>
		　　<footer>
		　　　　<p>Copyright</p>
		　　</footer>
		< /article>
	</comment>	
	<comment>	
		\ Study ShellWindows
		\ Example of _NewEnum from https://msdn.microsoft.com/en-us/library/windows/desktop/bb773972(v=vs.85).aspx
			<vb>
				set objShellWindows = vm.g.ShellWindows ' it's a constant
				if (not objShellWindows is nothing) then
					dim objEnumItems
					for each objEnumItems in objShellWindows ' it's good to use M$ things in M$ way.
						vm.type(objEnumItems+", ") ' File Explorer, Internet Explorer,  OK 
					next
				end if
			</vb>
		\ 靠!咱只要一行就可以搞定：	
			<js>
				for (var i=0; i<vm.g.ShellWindows.count; i++) type(vm.g.ShellWindows.item(i)+", ");
				\ File Explorer, Internet Explorer,  OK 
			</js>
		\ ShellWindows object 包括所有的 File Explorer, Internet Explorer instances. 別無他用, 
		\ 所以很單純只有 count, item() 兩個 member。
		
	</comment>	
	<comment>	
		\ Study Windows Internet Explorer object   https://msdn.microsoft.com/library/aa752084(v=vs.85).aspx
		\ Use ShellWindows (or sw) to get IE object. But sw gets *not* only IE but also FE. Tell by sw.name.

			0 sw(i) :> name \ ==> File Explorer (string) or 檔案總管 (string)
			1 sw(i) :> name \ ==> Internet Explorer (string) 在中文系統亦同

		\ IE object events
		\ Below command lines works 但都是一下達就馬上 alert 了，不知道 event 啥？最後給他亂打一通，居然也
		\ alert 了! 可見用法存疑。
			eleBody :: attachEvent("BeforeNavigate",alert("123")) 
			js> inputbox :: attachEvent("BeforeNavigate",alert("234")) 
			js> inputbox :: attachEvent("WindowResize",alert("345")) 
			js> inputbox :: attachEvent("WindowResdfsdsfdssize",alert("345"))
		\ [ ] So, don't know how to hook an event to IE object and why these events are 
		\	  appearing here in IE object document.
		
		\ IE object methods
			[x] sw :: GoBack() 
			[x] sw :: GoForward() 
			[x] sw :: GoHome() 
			[ ] sw :: navigate
		
	</comment>
	<comment>
		\ for 3ce target page
		\ 完整功能 Hover 打紅框, Freeze, Select, Delete, Unselect, View, Clear
		\ 能用 [<][>] 倒退前進就不怕 event 順序不靈的問題。
		--- marker ---
		[] value track // ( -- [node,..] ) The history track array of visited DOM nodes
		0 value itrack // ( -- int ) index of the track array
		0 value freeze // ( -- boolean ) The freezing flag
		<js> 
			var GoOn=false;
			
			$(document).keydown(function(e){
				e = (e) ? e : event; var keycode = (e.keyCode) ? e.keyCode : (e.which) ? e.which : false;
				switch(keycode) {
					case 67: /* [c]lear */
						for(var i=0; i<vm.g.track.length; i++){
							$(vm.g.track[i])
							.removeAttr('style')
							.removeClass("_selected_");
						}
						return(false); 
					case 68: /* [d]elete the highlighted node */
						push(vm.g.track[vm.g.itrack]);
						execute("removeElement");
						return(false); 
					case 70: /* [f]reeze */
						vm.g.freeze = !vm.g.freeze;
						type("The freezing flag : " + vm.g.freeze); execute("cr");
						return(false); 
					case 83: /* [s]elect */
						$(vm.g.track[vm.g.itrack])
						.removeAttr('style')
						.css("border","2px solid lime")
						.addClass("_selected_");
						return(false); 
					case 85: /* [u]nselect */
						$(vm.g.track[vm.g.itrack])
						.removeAttr('style')
						.removeClass("_selected_");
						return(false); 
					case 86: /* [v]iew selected nodes */
						for(var i=0; i<vm.g.track.length; i++){
							$(vm.g.track[i]).removeAttr('style');
							if($(vm.g.track[i]).hasClass("_selected_"))
								$(vm.g.track[i]).css("border","2px solid lime");
						}
						return(false); 
					case 188: /* < , */
						$(vm.g.track[vm.g.itrack]).removeAttr('style'); // 無須防呆
						vm.g.itrack = Math.max(0,vm.g.itrack-1);
						$(vm.g.track[vm.g.itrack]).css("border","4px dashed red");						
						return(false); 
					case 190: /* > . */
						$(vm.g.track[vm.g.itrack]).removeAttr('style'); // 無須防呆
						vm.g.itrack = Math.min(vm.g.track.length-1,vm.g.itrack+1);
						$(vm.g.track[vm.g.itrack]).css("border","4px dashed red");						
						return(false); 
				}
				return (true);
			});
			$("*").mouseenter(function(){
				type("Enter " + this.nodeName + ". ");
				if (vm.g.freeze) return;
				$(vm.g.track[vm.g.itrack]).removeAttr('style'); // 無須防呆
				if (vm.g.track[vm.g.track.length-1]!=this) vm.g.track.push(this);
				vm.g.itrack = vm.g.track.length-1;
				$(vm.g.track[vm.g.itrack]).css("border","4px dashed red");						
			});

			$("*").mouseleave(function(){
				type("Leave " + this.nodeName + ". ");
				if (vm.g.freeze) return;
				$(this).removeAttr('style'); // 無須防呆
			});

		</js>	
	</comment>




