
	\ SimpleMDE - Markdown Editor

	s" md.f"		source-code-header

	: mde-include ( -- ok? ) \ Inclde MDE editor 
		js> typeof(SimpleMDE)!="function" if
			<text>
			/*
			<link rel="stylesheet" href="https://cdn.jsdelivr.net/simplemde/latest/simplemde.min.css"> 
			<script src="https://cdn.jsdelivr.net/simplemde/latest/simplemde.min.js"></script>
			*/
			<link href="http://cdn.bootcss.com/simplemde/1.10.0/simplemde.min.css" rel="stylesheet">
			<script src="http://cdn.bootcss.com/simplemde/1.10.0/simplemde.min.js"></script>
			</text> /*remove*/ </h> drop 
		then
		false ( assume include failed )  
		( seconds * 1000 / nap ) js> 60*1000/200 for 
			js> typeof(SimpleMDE)=="function" if 
				r> drop 0 >r \ break the loop
				drop true ( include OK )
			else 
				200 nap ." ." \ wait a while
			then 
		next ;
		/// Now window.SimpleMDE() is available
		
    : (md.parent) ( node -- md ) \ Get the parent MDEditor object of the given node/element.
        js> $(pop()).parents('.md')[0] ( md ) ;
		
    : md.file ( btn -- ) \ Get a file pathname through GUI, not loaded yet.
		(md.parent) ( md )
		pickFile trim ( md pathname )
		js: $('.mdpathname',tos(1))[0].value=pop() ( md )
		js: inputbox.blur();window.scrollTo(0,pop().offsetTop-50) ;
		
    : md.load ( btn -- ) \ Load the pathname to MDE
		(md.parent) ( md )
		js> tos().mde.isPreviewActive() if 
			\ If is in preview mode then can't see the loaded article untill turn
			\ off the preview. Don't want to confuse user.
			<js> alert("Please turn off the preview mode.")</js> 
		then
		js> $('.mdpathname',tos())[0].value trim ( md pathname )
		readTextFile ( md article ) js: pop(1).mde.value(pop()) ;

    : md.save ( btn -- ) \ Save the article to pathname
		(md.parent) ( md )
		js> tos().mde.value() ( md article )
		js> $('.mdpathname',pop(1))[0].value trim ( article pathname )
		writeTextFile ; 

    : md.close ( btn -- ) \ Close the entire MDEditor DIV
		<js> confirm("Confirm the closing?")</jsV> if 
			(md.parent) ( md ) removeElement
		else drop then ;

	: md.div(init-buttons) ( md -- ) \ Initialize buttons of the MDEditor DIV element
        <js> $(".mdfile", tos())[0].onclick =function(e){push(this);execute("md.file" );return(false)}</js>
        <js> $(".mdload", tos())[0].onclick =function(e){push(this);execute("md.load" );return(false)}</js>
        <js> $(".mdsave", tos())[0].onclick =function(e){push(this);execute("md.save" );return(false)}</js>
        <js> $(".mdclose",tos())[0].onclick =function(e){push(this);execute("md.close");return(false)}</js>
		;
	
	code md.div(init-editor) ( md -- ) \ Initialize the SimpleMDE instance on the DIV element
		// ( md )
		var textarea = $(".mdtextarea",tos())[0];
		var mde = new SimpleMDE({
			element: textarea,
			autofocus: true,
			autosave: {
				enabled: true,
				uniqueId: "MyUniqueID",
				delay: 1000,
			},
			// blockStyles: {
			// 	bold: "__",
			// 	italic: "_"
			// },
			// forceSync: true,
			// hideIcons: ["guide", "heading"],
			// indentWithTabs: false,
			initialValue: "Hello world!",
			insertTexts: {
				horizontalRule: ["", "\n\n-----\n\n"],
				image: ["![](http://", ")"],
				link: ["[", "](http://)"],
				table: ["", "\n\n| Column 1 | Column 2 | Column 3 |\n| -------- | -------- | -------- |\n| Text     | Text      | Text     |\n\n"],
			},
			// lineWrapping: false,
			// parsingConfig: {
			// 	allowAtxHeaderWithoutSpace: true,
			// 	strikethrough: false,
			// 	underscoresBreakWords: true,
			// },
			placeholder: "Type here...",
			// previewRender: function(plainText) {
			// 	return customMarkdownParser(plainText); // Returns HTML from a custom parser
			// },
			// previewRender: function(plainText, preview) { // Async method
			// 	setTimeout(function(){
			// 		preview.innerHTML = customMarkdownParser(plainText);
			// 	}, 250);
            // 
			// 	return "Loading...";
			// },
			// promptURLs: true,
			// renderingConfig: {
			// 	singleLineBreaks: false,
			// 	codeSyntaxHighlighting: true,
			// },
			// shortcuts: {
			// 	drawTable: "Cmd-Alt-T"
			// },
			showIcons: [
				"code", 
				"table", 
				"strikethrough", 
				"quote", 
				"clean-block", 
				"horizontal-rule",
				],
			tabSize: 4,
			// status: false,
			// status: ["autosave", "lines", "words", "cursor"], // Optional usage
			// status: ["autosave", "lines", "words", "cursor", {
			// 	className: "keystrokes",
			// 	defaultValue: function(el) {
			// 		this.keystrokes = 0;
			// 		el.innerHTML = "0 Keystrokes";
			// 	},
			// 	onUpdate: function(el) {
			// 		el.innerHTML = ++this.keystrokes + " Keystrokes";
			// 	}
			// }], // Another optional usage, with a custom status bar item that counts keystrokes
			// toolbar: false,
			// toolbarTips: false,
			spellChecker: false // 會使讀取時反應很慢，很長一段時間文章只出現一小部分，恐引 User 會誤會。
		}); 
		pop().mde = mde;
		end-code
		/// md.mde is the SimpleMDE object of this instance.
	
    : md.div ( -- md ) \ Create a SimpleMDE window, return the md DIV.
		mde-include not ?abort" Fatal! SimpleMDE are not included."
        <text> <div class=md> /* md is the [M]ark [D]own Editor */
            <style type="text/css">
                .md .mdbox {  /* The width setting needs a box */
					width:80%;
					border:1px solid black; 
					color:black; /* font color */
					font-family: Microsoft Yahei;
					font-size: 20px; /* 合理 */
					padding:20px; /* 合理，頁面四周留白, border 到文字的距離 */ 
				}
				.md .mdpathname { font-size: 1em; width:20em;}
				.md .CodeMirror, .md .CodeMirror-scroll {
					min-height: 200px;
				}
				.md .CodeMirror {
					height: 450px;
				}				
            </style>
            <div class=mdbox>
				Markdown Editor - <a href="https://simplemde.com"> SimpleMDE </a>&nbsp; 
				<input type=button value='File' class=mdfile>
				<input type=text class=mdpathname placeholder="path/file name"></input>
				<input type=button value='Load' class=mdload>
				<input type=button value='Save' class=mdsave>
				<input type=button value='Close' class=mdclose>
				<textarea class=mdtextarea></textarea>
			</div>
		</div></text> /*remove*/ </o> ( md ) 
        dup md.div(init-buttons) dup js> $(".console3we")[0] insertBefore ( md )
		dup md.div(init-editor) ( md )
		js: inputbox.blur();window.scrollTo(0,tos().offsetTop-50) ( md ) ; 
		/// TOS is the DIV of the entire MDEditor. We need it so as to give the pathname.

	: md ( <pathname> -- ) \ Edit the given Markdown article
		md.div ( md )
		char \n|\r word trim ( md pathname ) 
		js: $('.mdpathname',tos(1))[0].value=pop() ( md )
		js> $('.mdpathname',pop())[0] md.load ;
		/// Change font-size
        ///   js> $(".mdbox").css("font-size","18px");$(".mdbox").css("font-size") tib.
		/// Change font-family
        ///   <js> $(".mdbox").css("font-family","courier");$(".mdbox").css("font-family")</jsV> tib.
        ///   <js> $(".mdbox").css("font-family","Microsoft Yahei");$(".mdbox").css("font-family")</jsV> tib.
		/// Change SimpleMDE window height
		///   js> $(".CodeMirror").css("height","550px");$(".CodeMirror").css("height") tib.
	
<comment>

	[x] execute the word does not work. But run on interpret mode always ok. Why?
		--> including the ~.js takes time. Use a napping loop to wait for its readiness.
	  
	[x] Even when it's not work, check the elements of link and script, they are existing:
		js> $("head")[0] ce! ce 09 ce@ :> outerHTML .  ( the SimpleMDE CSS )
		js> $("head")[0] ce! ce 10 ce@ :> outerHTML .  ( the SimpleMDE .js )
		--> Use BootCDN.cn will be better.

	[x] include, create MDE object, create textarea, launch MDE instance ... works! But the 
		thing is strange. <-- Because it's in jeforth's .console3we <DIV> ! Should not. 
		Should be outside of .console3we.
		(@ 3nw) 改照抄 official demo page 上的 resource 也行, 但是問題還是一樣。
		可見是 jeforth 的 style 造成的問題。 <-- 對, 但解法應如上。
		[x] 下一步, 3nw 的 style 反璞歸真, 或限制範圍。


	\ Include SimpleMDE

		<h>
		< link rel="stylesheet" href="https://cdn.jsdelivr.net/simplemde/latest/simplemde.min.css"> 
		< script src="https://cdn.jsdelivr.net/simplemde/latest/simplemde.min.js"></script>
		</h> drop
		js> typeof(SimpleMDE) tib. \ ==> function (string) so it has been installed

	\ Create a textarea

		cls <o> <textarea id=simplemde ></textarea></o> js> outputbox insertBefore

	\ Launch SimpleMDE on the above textarea

		<js> 
		var simplemde = new SimpleMDE({element: document.getElementById("simplemde")}); 
		simplemde 
		</jsV> 
		constant simplemde

	\ Test, set the content

		simplemde <js> pop().value("This text will appear in the editor"); </js>

	\ Test, get the content

		simplemde :> value() \ ==> # This text will appear in the editor (string)


	\ Include SimpleMDE

		<h>
		<link href="//cdn.bootcss.com/simplemde/1.10.0/simplemde.min.css" rel="stylesheet">
		<script src="//cdn.bootcss.com/simplemde/1.10.0/simplemde.min.js"></script>
		</h> drop
		js> typeof(SimpleMDE) \ ==> function (string) so it has been installed

	\ Create a textarea

		cls <o> <textarea id=simplemde ></textarea></o> js> outputbox insertBefore

	\ Launch SimpleMDE on the above textarea

		<js> var simplemde = new SimpleMDE({element: document.getElementById("simplemde")}); simplemde </jsV> constant simplemde

	stop

	[/] Try 3htm with localhost , the Error is : "require is not defined"
		(1) Run local host : webserver.bat
		(2) Run jeforth.3htm through http://localhost:8888 or http://localhost:8888/index.html 
		(3) Run 
			<h>
			<link rel="stylesheet" href="http://localhost:8888/src/css/simplemde.css">
			<script src="http://localhost:8888/src/js/simplemde.js"></script>
			</h>
			---> JavaScript error on word "doElement" : require is not defined
		==> 不必自己架設 server , just use CDN library.

	[ ] \ jeforth.3ce can not do this 
		<h>
		< link rel="stylesheet" href="http://localhost:8888/src/css/simplemde.css">
		< script src="http://localhost:8888/src/js/simplemde.js"></script>
		</h>

		\s

		jquery-1.11.2.js:9831 Refused to load the script 
		'http://localhost:8888/src/js/simplemde.js?_=1462251960943' 
		because it violates the following Content Security Policy directive: 
		"script-src 'self' 'unsafe-eval'".

		\s
		char http://localhost:8888/src/js/simplemde.js readTextFile . \ ==> works fine

	[ ] require('codemirror') not found, add %NODEJSHOME%\node_modules\simplemde\node_modules
		to NODE_PATH as below can resolve this.
		---- 3nw.bat ----
		if a%COMPUTERNAME%==aWKS-38EN3476     set NODEJSHOME=C:\Program Files\nodejs
		if a%COMPUTERNAME%==aWKS-4AEN0404     set NODEJSHOME=C:\Program Files\nodejs
		set NODE_PATH=%NODEJSHOME%\node_modules;%NODEJSHOME%\node_modules\simplemde\node_modules
		start nw ../jeforth.3we %1 %2 %3 %4 %5 %6 %7 %8 %9
		-----------------
		
		

	\ Word does not work, mde-include not ok yet, but interpret mode works fine


	.( Include SimpleMDE.js )

		js> typeof(SimpleMDE)!="function" [if]
			<h>
			<link rel="stylesheet" href="https://cdn.jsdelivr.net/simplemde/latest/simplemde.min.css"> 
			<script src="https://cdn.jsdelivr.net/simplemde/latest/simplemde.min.js"></script>
			</h> drop 
		[then]
		false ( assume include failed )  
		30 ( seconds ) [for] 
			js> typeof(SimpleMDE)=="function" [if] 
				r> drop 0 >r \ break the loop
				drop true ( include OK )
			[else] 
				20 nap ." ." \ wait a while
			[then] 
		[next] 
		[if] ."  Done. " [else] ."  Error! Failed to include SimpleMDE! [then] cr

	.( Create the required textarea for SimpleMDE ) cr

		<o> <textarea id=simplemde ></textarea></o> 
		js> $(".console3we")[0] insertBefore

	.( Launch SimpleMDE on the above textarea ) cr

		<js> 
		var simplemde = new SimpleMDE({element: document.getElementById("simplemde")}); 
		simplemde 
		</jsV> 
		constant simplemde

	.( Load README.md ) cr

		char README.md readTextFile
		simplemde :: value(pop())
		
	\ Above interpret procedure works fine.
</comment>