\ ^4 ^5
\ utf-8	
\ 透過【富邦e01】研究台股所需要的 excel tools
\ 台銀的除權除息表 http://fund.bot.com.tw/z/ze/zeb/zeb.djhtm

	include excel.f
	include ie.f

	s" money.f" source-code-header

	\ Table style
	<h>
	<style>
		table, tbody, tr, td, th {
				border: 1px ridge;
		}
	</style>
	</h>

	\ Computer dependent constants
	( ASRock desktop @ home ) char DESKTOP-Q94AC8A char %computername% env@ = [if]
		char c:\Users\hcche\Documents\stock\ [then]
	( DOH7 ) char WKS-38EN3477 char %computername% env@ = [if]
		char c:\Users\8304018.WKSCN\Dropbox\learnings\Stock\ [then]
	( S7 ) char WKS-38EN3476 char %computername% env@ = [if]
		char c:\Users\8304018\Dropbox\learnings\Stock\ [then]
	constant stockPath // ( -- "path" ) stock\
	stockPath char data\ + constant dataPath // ( -- "path" ) stock\data\
	stockPath char fubon_e01.json + readTextFile parse constant fubon_e01  // ( -- {hash} ) ^5 Stock ID : name, date, time, price, dividend, yieldrate, volumn

	js> [6457,8027] constant category_TE // ( -- [...] ) These Stock's formula is =XQFAP|Quote!'6457.TE-Name' not .TW-Name.

excel.app [if] \ excel exists
	: DDE>value ( -- ) \ Convert the cell from its DDE formula to the recent value if it's not #N/A
		?cell@ if cell! then ;
		/// 透過 DDE 從 E01 拉值過來很花時間,也不穩定，連 StockID 都常有 #N/A 出現。
		/// 以 e01 Worksheet 為例，其中很多值都是固定的，沒有必要一直去重抓。本命令
		/// 把當格固定下來變成 value 而如果是 #N/A 的則保留其 formula。
		/// 研究發現: #N/A, 空格子, #DIV/0! 等這些用 activeCell :> value tib. 來看
		/// 都是 undefined (undefined) 可藉以判斷。
		/// 要讓 DDE 重抓資料的 excel 操作方式:【資料】>【全部重新整理】。
		/// o 把要把 formula 改成 value 的部分 mark 起來，一次全改好: 
		/// 	manual 0 cut i?stop DDE>value 1 nap rewind auto
		/// o 隨便 activate 在 e01 worksheet 裡任意地方。一口氣加工所有指定的行:
		///   manual 3 ( column# ) 4 goto cut DDE>value down empty? ?stop 1 nap rewind
		///    4 ( column# ) 4 goto cut DDE>value down empty? ?stop 1 nap rewind
		///   11 ( column# ) 4 goto cut DDE>value down empty? ?stop 1 nap rewind
		///   12 ( column# ) 4 goto cut DDE>value down empty? ?stop 1 nap rewind
		///   13 ( column# ) 4 goto cut DDE>value down empty? ?stop 1 nap rewind
		///   14 ( column# ) 4 goto cut DDE>value down empty? ?stop 1 nap rewind auto
		///
	
	: to-DDE-formula ( -- ) \ 把當格的 stockID 依據最上方一行的 title 改成對應的 DDE 公式。
		char =XQFAP|Quote!' \ 富邦 e01 DDE formula 長得像這樣 =XQFAP|Quote!'1104.TW-Time'
		cell@ ( -- formula stockID ) + char .TW- + 
		column 1 cell :> value ( -- formula title ) + char ' + ( -- formula )
		activeCell :: formula=pop() ;
		/// 想要在 e01 worksheet 裡增列一行時使用，記得先在要轉換的地方先填好 stock ID.
		/// 往下重複完成一整行: 
		/// manual cut to-DDE-formula down empty? ?stop 1 nap rewind auto
	
	: DDE-formula ( -- ) \ ActiveCell 在一列最左邊的 stockID 上，自動向右設定全部 DDE 公式。
		activeCell :> column 1 cell :> value ( formula )
		dup :> indexOf("|Quote!'")==-1 ?abort" ActiveCell at wrong position, wrong formula see TOS."
		activeCell :> column ( x )
		activeCell :> row ( y )
		activeCell :> value ( -- formula x y id )
		<js>
		var id=pop(), y=pop(), x=pop(), formula=pop();
		for (var i=1;; i++) {
			var ss = formula + id + '.'; // StockID
			for (var category='TW',j=0; j<g.category_TE.length; j++){
				if(id==g.category_TE[j]) category='TE';
			}
			ss += category + '-'; // category TW or TE
			push(x+i);fortheval("1 cell :> value"); // ( -- title-Name of the column )
			ss += tos() + "'"; // complete the formula ( -- title-Name of the column )
			if(!pop()) break; // stop if the title-name of the column has come to an end
			push(i);fortheval("0 offset");pop().formula=ss;
		}
		</js> ;
		/// Usage: 
		/// 1. activeCell at the first StockID in the "e01" worksheet,
		/// 2. manual ' DDE-formula repeat-down auto

	: interested ( -- ) \ ActiveCell 在最上方的 ID 上，自動抄左邊的 DDE 像下到底。
		1 ( i=1... ) 0 0 offset :> value ( i ID )
		begin ( i ID )
			-1 js> tos(2) ( i id -1 i ) offset :> formula ?dup ( i id F|formula formula )
		while 
			:> replace(/'.+\./,"'"+tos()+".") ( i id formula' ) 
			0 js> tos(3) offset :: formula=pop() ( i id )
		js: push(pop(1)+1,0) ( i++ ) repeat ( i id )
		2drop ;
		/// Usage: 
		/// 1. activeCell at the StockID on top of the interested stock column in interested.xlsx file
		/// 2. manual interested auto <-- 若忘了用 manula .. auto 保護起來，會變得很慢很慢。
		///    manual ' interested repeat-right auto
		
	: repeat-right ( cmd -- ) \ if (activeCell.value) then do the given forth 'cmd' then move right and repeat
		dup :> constructor!=Word ?abort" The given command (the TOS) is not a forth word."
		begin ( cmd ) 0 0 offset :> value!=undefined while 
			dup execute 
			1 0 offset :: activate 
		repeat drop ;
		/// manual ' interested repeat-right auto
		
	: ctrl<- ( -- ) \ 把右邊一格的 "8942森鉅" 抄過來變成 "8942"
		1 0 offset :> value ?dup if 
			<js> pop().replace(/(^( |\t)*)|(( |\t)*$)/g,'')</jsV> \ remove 頭尾 white spaces
			:> match(/^\d+/) int \ 只抓開頭的數字
			0 0 offset :: value=pop() 
		else	
			0 0 offset :: clear() \ 令 activeCell 清除，表示右邊一格沒東西。
		then ;
		/// 整個做完了的線索 0 0 offset :> value==undefined is true 
		/// Usage: manual ' ctrl<- repeat-down auto
		
	: remove"\r\n" ( {clipboard} -- {clipboard}' ) \ Remove \r\n from clipboard
		js> clipboardData.getData("text")
		:> replace(/\r\n/g,"")
		js: clipboardData.setData("text",pop()) ;
		/// 從網頁上 copy 表格下來 paste to excel 往往發現 title row 不對，因為
		/// 其中有 \r\n 之故。先 copy 好資料，跑一下本 command 然後去 excel paste
		/// 即可，隨後再轉貼別地方。用 multiplicity 在兩台電腦間來回處理無誤。

	: repeat-down ( 'Word -- ) \ Do the given forth 'Word then if (activeCell.value) go down and repeat
		dup :> constructor!=Word ?abort" The given command is not a forth word."
		begin dup execute 
		0 0 offset :> value!=undefined while 
		0 1 offset :: activate repeat drop ;
		/// 應用一、把右邊一格的 "8942森鉅" 抄過來變成 "8942", 往「下」重複到右邊沒有了為止。
		///   1. activeCell at the index column which is at the left side of the
		///      table which was copy-pasted from 元大除權除息表網站，
		///   2. manual ' ctrl<- repeat-down auto
		/// 應用二、設定整張表的 DDE formula，
		///   1. activeCell at the first StockID in the "e01" worksheet,
		///   2. manual ' DDE-formula repeat-down auto
		/// 用 <task> 是比較理想的方式
	
	: do-them ( 'Word -- ) \ Do the same thing to all cells in the selection.
		dup :> constructor!=Word ?abort" The given command is not a forth word."
		selection js> tos().count ( -- 'Word objSelection count ) 
		dup ." Total: " . ."  items." cr ( -- 'Word objSelection count )
		js: push(tos()+1,0) for dup r@ - ( -- 'Word objSelection count+1 i=1,2,3..count )
			js: tos(2).item(pop()).activate() \ move to selection.item(i)
			( -- 'Word objSelection count+1 ) js> tos(2) execute
		next 3 drops ;
		/// Usage: 
		/// 1. Mark an area.
		/// 2. Run: manual ' <word> do-them auto
		/// The word should be stack balanced, leaves nothing.

	: float-them ( -- ) \ Convert selection to float or skip them.
		selection ( obj ) <js>
			var selection=pop();
			print("Total:"+selection.count+" items.\n");
			for (var i=1; i<=selection.count; i++){
				var vv = selection.item(i).value;
				if(typeof(vv)=="unknown") {
					print("Item " + i + " at "+selection.item(i).address+" is unksnon!\n");
					continue;
				}
				if(isNaN(vv)) {
					print("Item " + i + " at "+selection.item(i).address+" value " + vv + " is NaN!\n");
					continue;
				}
				selection.item(i).value=parseFloat(vv);
			}
		</js> ;
		/// Usage: 
		/// 1. Mark an area.
		/// 2. Run: manual float-them auto
		
	: yellow-them ( "$A$1 $B$135" -- ) \ Mark given cells with yellow color
		<js> ("dummy "+pop()+" dummy").split(/\s+/).slice(1,-1)</jsV> ( array )
		( array ) js> tos().length for ( array )
			( array ) js> tos().pop() ( array' "$A$1" )
			activeSheet :: range(pop()).interior.colorindex=6
		next ( array ) drop ;
		/// 先 mark 配息日欄，然後執行： 
		/// ( 含#NA! ) manual 0 cut i?stop value-it 1 nap rewind auto
		/// 把有日期的都由參考公式轉成 value 並取得所有新格子的座標，接著
		/// 用 <text> $A$1 $B$135 ... </text> yellow-them 把新格子都塗上顏色。
		
	<comment> ^5 
		\ 手動 copy-paste 存檔 stockPath\fubon_e01.json, stock2015.xls 裡 e01 資料有更新再做一次就好。
		\ 富邦 e01 DDE 到 excel, 從 excel 抓股價、股息股利、殖利率，存成 fubon_e01.json 
		\ 打開 Stock2015.xls WorkSheet 與 e01 同步。避免進入任何一格的 edit mode。
		activeSheet char b char e init-hash constant id_date // ( -- hash ) Stock id : Trading date
		activeSheet char b char f init-hash constant id_time // ( -- hash ) Stock id : Trading time
		activeSheet char b char g init-hash constant id_price // ( -- hash ) Stock id : price
		activeSheet char b char n init-hash constant id_dividend // ( -- hash ) Stock id : dividend
		activeSheet char b char o init-hash constant id_yieldrate // ( -- hash ) Stock id : Yield Rate
		activeSheet char b char i init-hash constant id_volumn // ( -- hash ) Stock id : Volumn
		activeSheet char b char d init-hash constant id_name // ( -- hash ) Stock id : Name
		<js> 
			var tt = {};
			for (var i in g.id_price){
				tt[i] = {};
				tt[i].price = g.id_price[i];
				tt[i].date = g.id_date[i];
				tt[i].time = g.id_time[i];
				tt[i].dividend = g.id_dividend[i];
				tt[i].yieldrate = g.id_yieldrate[i];
				tt[i].volumn = g.id_volumn[i];
				tt[i].name = g.id_name[i];
			} 
			push(tt);
		</js> constant fubon_e01 // ( -- {hash} ) ^5 Stock ID : name, date, time, price, dividend, yieldrate, volumn
		fubon_e01 stringify stockPath char fubon_e01.json + writeTextFile
	^5 </comment>	
	
[then] \ excel exists
	
	: dividend-table ( -- "html" ) \ 上網讀取 台灣銀行 除權除息表-依股號
		\ ShellWindows :> count if
		\ 	ShellWindows :> count 1- window(i)
		\ 	:: open("http://fund.bot.com.tw/z/ze/zeb/zeba.djhtm","_top") 
		\ 	\ 不用這個 window object, 它總是【沒有使用權限】【存取被拒】。
		\ else
			<vb> Set ie = GetObject("","InternetExplorer.Application"):kvm.push(ie)</vb> \ ( -- obj ) Internet Explorer object
			:: Navigate("http://fund.bot.com.tw/z/ze/zeb/zeba.djhtm","_top")
		\ then
		begin 100 nap ShellWindows :> count 1- ie(i) :> ReadyState 4 = char . . until cr
		ShellWindows :> count 1- window(i) \ 又要重抓
		ShellWindows :> count 1- ie(i) :: visible=true 
		:> document.getElementById('SysJustIFRAMEDIV')
		:> innerHTML 
		:> replace(/\n/mg,"_cr_")	\ replace cr with _cr_ makes below operations easier
		:> replace(/<script.*?script>/g,"")		\ remove all <script>
		:> replace(/<select.*?select>/g,"")		\ remove all <select>
		:> replace(/<br>/g,"")					\ remove all <br>
		:> replace(/.*<form/g,"<form")			\ remove before <form>
		:> replace(/<form.*?valign="top">/,"")	\ remove <form to the outer <table>
		:> replace(/<tbody>.*?<\/tr>/,"<tbody>")		\ remove the caption row
		:> replace(/<\/form>.*/g,"")					\ remove after </form>
		:> replace(/<\/table>.*?<\/table>/,"</table>")	\ remove the end of the outer <table>
		:> replace(/_cr_/g,"\n") ;
		/// Usage:
		/// <h> <script src="js/jquery.tabletojson.js"></script> </h> drop
		/// dividend-table </o> js> $('#oMainTable').tableToJSON() constant dividend-table.json
		
	: 裁剪 ( "html" -- "html'" ) \ 只取 content start ~ content end 之間的部分
		:> replace(/\n/mg,"_cr_")	\ replace cr with _cr_ makes below operations easier
		\ 這兩個用不著 remove-script remove-onmouse，以下的更精準。
		<js> pop().replace(/.*content start\s*-+>/g,"")</jsV>
		<js> pop().replace(/<!-+\s*content end.*/g,"")</jsV>
		:> replace(/_cr_/g,"\n") ;
		/// Ex. cls dataPath char 4703_dividend.htm + readTextFile 裁剪 </o>
	
	15000 constant yahoo-wait-time // ( -- mS ) Wait some time to avoid pissing up yahoo.
	
	<js> 
		[2227,2331,5508,2597,5225,5356,4113,4930,5015,6431,6177,1808,3666,5522,6168,6188,4542,6186,5464,2493,2545,
		3032,6203,2104,5603,5371,6241,2107,5511,6298,2542,6185,3315,6292,2377,2489,2520,3291,1715,9912,8271,6189,3078,
		3209,5251,2402,3312,5514,3056,2537,2841,2024,6265,2302,2890,2030] 
	</jsV> constant 高配息2015/6/19表 // ( -- array ) ["StockId"...}

	<text> 
		navigate https://tw.stock.yahoo.com/d/s/{info}_{id}.html 
		yahoo-wait-time nap ready not-busy document :> body.innerHTML 裁剪 
		dataPath char {name}_{id}_{info}.htm + writeTextFile 
	</text> constant command-pattern-for-yahoo
		
	: 保證有IE ( -- ) \ Make sure ShellWindows.item(0) exists
		available? if else s" iexplore" (fork) then ."  IE Starting up " begin char - . 100 nap available? until space ;

	\ 我記得 Yahoo 會統計你的行為，太過分的就會被暫停。這是一個例子，所以下列命令
	\ 不直接執行，而是產生命令行或稱 macro。把所有 macro 蒐集起來，慢慢讓 </task> 
	\ 去執行，萬一遇阻，還可以手動從適當位置讓它繼續。
	
	: 公司資料 ( "id" -- "macro" ) \ 上 yahoo 讀取該表格。寫進檔案。
		fubon_e01 :> [tos()].name ( id name )
		command-pattern-for-yahoo :> replace(/{info}/mg,"company") 
		:> replace(/{name}/mg,pop()) :> replace(/{id}/mg,pop()) ;
		/// Usage: 1110 公司資料 </task> 讀取資料，存進 the data folder。
	: 營收盈餘 ( "id" -- "macro" ) \ 上 yahoo 讀取該表格。寫進檔案。
		fubon_e01 :> [tos()].name ( id name )
		command-pattern-for-yahoo :> replace(/{info}/mg,"earning") 
		:> replace(/{name}/mg,pop()) :> replace(/{id}/mg,pop()) ;
		/// Usage: 1110 營收盈餘 </task> 讀取資料，存進 the data folder。
	: 股利政策 ( "id" -- "macro" ) \ 上 yahoo 讀取該表格。寫進檔案。
		fubon_e01 :> [tos()].name ( id name )
		command-pattern-for-yahoo :> replace(/{info}/mg,"dividend") 
		:> replace(/{name}/mg,pop()) :> replace(/{id}/mg,pop()) ;
		/// Usage: 1110 股利政策 </task> 讀取資料，存進 the data folder。
	: 每股盈餘 ( "id" -- "macro" ) \ 上 yahoo 讀取該表格。寫進檔案。 
		fubon_e01 :> [tos()].name ( id name ) <text> 
		( 每股盈餘 ) navigate https://tw.screener.finance.yahoo.net/screener/check.html?symid={id} 
		yahoo-wait-time nap ready not-busy document :> body.innerHTML 裁剪 dataPath 
		char {name}_{id}_EPS.htm + writeTextFile 
		</text> :> replace(/{name}/mg,pop()) :> replace(/{id}/mg,pop()) ;
		/// Usage: 1110 每股盈餘 </task> 讀取資料，存進 the data folder。
		
	: 公司報表 ( id -- ) \ 列出這家公司的資料 ^4
		\ 公司簡介
		( id ) fubon_e01 :> [tos()].name 2dup ( id name id name ) 
		char _ + swap + char _company.htm + ( id name filename ) dataPath swap + ( id name pathname )
		( id name pathname ) readTextFile ?dup if 
			</o> drop js> $("table") ( id name table ) 
		else 
			abort" Error! No such file exits yet." ( id name )
		then
		 ( id name table ) cr cr swap . space over . cr ( id table )
		\ table 2 
			js: g.t=2
			js> tos()[g.t].cells[30].innerHTML.replace(/[\n\s]*/g,"").replace(/<.*?>/mg,"") . space
			js> tos()[g.t].cells[31].innerHTML.replace(/[\n\s]*/g,"").replace(/<.*?>/mg,"") . cr
			js> tos()[g.t].cells[24].innerHTML.replace(/[\n\s]*/g,"").replace(/<.*?>/mg,"") . space
			js> tos()[g.t].cells[25].innerHTML.replace(/[\n\s]*/g,"").replace(/<.*?>/mg,"") . space
			." , "
			fubon_e01 :> [tos(1)].date . space 
			fubon_e01 :> [tos(1)].time . space
			fubon_e01 :> [tos(1)].price      ." price " . ." , "
			fubon_e01 :> [tos(1)].volumn     ." volumn " . ." , "
			fubon_e01 :> [tos(1)].yieldrate  ." yieldrate " . cr
			js> tos()[g.t].cells[6].innerHTML.replace(/[\n\s]*/g,"").replace(/<.*?>/mg,"")  . space
			js> tos()[g.t].cells[7].innerHTML.replace(/[\n\s]*/g,"").replace(/<.*?>/mg,"")  . cr
			js> tos()[g.t].cells[10].innerHTML.replace(/[\n\s]*/g,"").replace(/<.*?>/mg,"") . space
			js> tos()[g.t].cells[11].innerHTML.replace(/[\n\s]*/g,"").replace(/<.*?>/mg,"") . cr
		\ table 4
			js: g.t=4
			js> tos()[g.t].cells[2].innerHTML.replace(/[\n\s]*/g,"").replace(/<.*?>/mg,"")  . space
			js> tos()[g.t].cells[3].innerHTML.replace(/[\n\s]*/g,"").replace(/<.*?>/mg,"")  . cr
			js> tos()[g.t].cells[4].innerHTML.replace(/[\n\s]*/g,"").replace(/<.*?>/mg,"") . space
			js> tos()[g.t].cells[5].innerHTML.replace(/[\n\s]*/g,"").replace(/<.*?>/mg,"") . cr
		\ table 3
			js: g.t=3
			js> tos()[g.t].innerHTML.replace().replace() </o> drop
			js> tos()[g.t].rows[1].cells[3].innerHTML float 
			js> tos(1)[g.t].rows[2].cells[3].innerHTML float +
			js> tos(1)[g.t].rows[3].cells[3].innerHTML float +
			js> tos(1)[g.t].rows[4].cells[3].innerHTML float +
			." 最新四季每股盈餘總共 " . cr
		\ end
			:: remove() \ 移除整個 table 讓出 $("table") 給下一網頁。 ( id )
		\ 股利政策	
		( id ) fubon_e01 :> [tos()].name 2dup ( id name id name ) 
		char _ + swap + char _dividend.htm + ( id name filename ) dataPath swap + ( id name pathname )
		( id name pathname ) readTextFile ?dup if 
			</o> drop js> $("table") ( id name table ) 
		else 
			abort" Error! No such file exits yet." ( id name )
		then ( id name table ) nip ( id table )
		\ table 3
			js: g.t=3
			js> tos()[g.t].innerHTML </o> drop
		\ end
			:: remove() \ 移除整個 table 讓出 $("table") 給下一網頁。 ( id )
		\ 營運績效	
		( id ) fubon_e01 :> [tos()].name 2dup ( id name id name ) 
		char _ + swap + char _earning.htm + ( id name filename ) dataPath swap + ( id name pathname )
		( id name pathname ) readTextFile ?dup if 
			</o> drop js> $("table") ( id name table ) 
		else 
			abort" Error! No such file exits yet." ( id name )
		then ( id name table ) nip ( id table )
		\ table 6
			js: g.t=6
			js> tos()[g.t].innerHTML.replace(/width=".+?"/mg,"") </o> drop
		\ table 10                                              
			js: g.t=10                                          
			js> tos()[g.t].innerHTML.replace(/width=".+?"/mg,"") </o> drop
		\ table 13                                              
			js: g.t=13                                          
			js> tos()[g.t].innerHTML.replace(/width=".+?"/mg,"") </o> drop
		\ end
			:: remove() drop \ 移除整個 table, 結束。
		;
		
	<comment> ^4
		高配息2015/6/19表 :> slice(0) ( array )
		cut dup :> shift() ?dup [if] ( array id )
		( array id ) 公司報表 ( array )
		[else]  \ 高配息2015/6/19表 pop 完了 ( array )
			drop stop
		[then] \ repeat ( array )
		1 nap rewind
	^4 </comment>
	<comment> ^3
		\ DOM 的 cells method 也很好用，一口氣把整頁所有的表格都讀進來。
		\ 整批抓好的網頁讀進來，融入 outputbox。
		cls dropall
		6431 dup fubon_e01 :> [tos()].name ( id name ) char _ + swap + char _company.htm + ( pathname ) dataPath swap + 
		dup . readTextFile </o> drop js> $("table") <js>
			for (var t=2; t<tos().length; t++){ // all tables
				print("---- Table " + t + ' ----\n');
					for (var c=0; c<tos()[t].cells.length; c++){ // all cells
					print(c + " " + tos()[t].cells[c].innerHTML.replace(/[\n\s]*/g,"").replace(/<.*?>/mg,"") + '\n');
				}
			}
		</js>  :: remove() \ 移除整個 table 讓出 $("table") 給下一網頁。
		dup fubon_e01 :> [tos()].name ( id name ) char _ + swap + char _dividend.htm + ( pathname ) dataPath swap + 
		dup . readTextFile </o> drop js> $("table") <js>
			for (var t=3; t<tos().length; t++){ // all tables
				print("---- Table " + t + ' ----\n');
					for (var c=0; c<tos()[t].cells.length; c++){ // all cells
					print(c + " " + tos()[t].cells[c].innerHTML.replace(/[\n\s]*/g,"").replace(/<.*?>/mg,"") + '\n');
				}
			}
		</js>  :: remove() \ 移除整個 table 讓出 $("table") 給下一網頁。
		fubon_e01 :> [tos()].name ( id name ) char _ + swap + char _earning.htm + ( pathname ) dataPath swap + 
		dup . readTextFile </o> drop js> $("table") <js>
			var tt=[6,10,13]; for (var i in tt){ // all tables
				var t = tt[i];
				print("---- Table " + t + ' ----\n');
					for (var c=0; c<tos()[t].cells.length; c++){ // all cells
					print(c + " " + tos()[t].cells[c].innerHTML.replace(/[\n\s]*/g,"").replace(/<.*?>/mg,"") + '\n');
				}
			}
		</js>  :: remove() \ 移除整個 table 讓出 $("table") 給下一網頁。
	^3 </comment>
	
	<comment> ^2
		\ 準備好 Table to JSON 
		<h> <script src="js/jquery.tabletojson.js"></script></h> drop
		\ 讀取已經存進電腦的表格。利用 HTA 本身加上 jQuery 可以很方便地萃取特定的 table，
		\ 再利用 DOM 的 table 命令讀取表格很容易。
		
		\ 整批抓好的網頁讀進來，融入 outputbox。
		6431 fubon_e01 :> [tos()].name ( id name ) char _ + swap + char _company.htm + ( pathname ) dataPath swap + readTextFile constant source
		\ js> $("table").length . \ 此後利用 DOM+jQuery 操作很容易，例如查看總共有多少表格。
		\ 經由手動操作，確定哪個表格是咱感興趣的:
		\ cls source </o> ( 重置整筆資料 ) js> $("table")[0].innerHTML </o> ( see 各個 table )
		\ cls source </o> ( 重置整筆資料 ) js> $("table")[1].innerHTML </o> ( see 各個 table )
		\ cls source </o> ( 重置整筆資料 ) js> $("table")[2].innerHTML </o> ( see 各個 table ) 
		\ 如果表格結構很簡單，可以用現成的 plugin 轉成 JSON。
		\ cls source </o> js> $("table")[3] js> $(pop()).tableToJSON() 
		\ 不規律的表格則直接讀取個別的 cells:
		cls source </o> drop js> $("table")[3] \ </o>
		dup :> rows[0].cells[1].innerHTML tib. \ ==> 最新四季每股盈餘  (string)
		dup :> rows[1].cells[2].innerHTML tib. \ ==> 104第1季 (string)
		dup :> rows[1].cells[3].innerHTML float tib. \ ==> -0.68 (number)
		dup :> rows[2].cells[2].innerHTML tib. \ ==> 103第4季 (string)
		dup :> rows[2].cells[3].innerHTML float tib. \ ==> -0.57 (number)
		dup :> rows[3].cells[2].innerHTML tib. \ ==> 103第3季 (string)
		dup :> rows[3].cells[3].innerHTML float tib. \ ==> 0.22 (number)
		dup :> rows[4].cells[2].innerHTML tib. \ ==> 103第2季 (string)
		dup :> rows[4].cells[3].innerHTML float tib. \ ==> 1.65 (number)
		dup :> rows[0].cells[2].innerHTML tib. \ ==> 最近四年每股盈餘 (string)
		dup :> rows[1].cells[4].innerHTML tib. \ ==> 103年 (string)
		dup :> rows[1].cells[5].innerHTML float tib. \ ==> 1.84 (number)
		dup :> rows[2].cells[4].innerHTML tib. \ ==> 102年 (string)
		dup :> rows[2].cells[5].innerHTML float tib. \ ==> 3.52 (number)
		dup :> rows[3].cells[4].innerHTML tib. \ ==> 101年 (string)
		dup :> rows[3].cells[5].innerHTML float tib. \ ==> 2.51 (number)
		dup :> rows[4].cells[4].innerHTML tib. \ ==> 100年 (string)
		dup :> rows[4].cells[5].innerHTML float tib. \ ==> 1.13 (number)
		dup :> rows[5].cells[0].innerHTML tib. \ ==> 股東權益報酬率 (string)
		dup :> rows[5].cells[1].innerHTML tib. \ ==> -2.48% (string)
		    :> rows[5].cells[2].innerHTML  :> match(/^(.+):\s+(.*)元/) "" tib.
			js> tos()[1] tib. \ ==> 每股淨值 (string)
			js> pop()[2] float tib. \ ==> 26.76 (number)
		( cls source </o> ) js> $("table")[2] \ .innerHTML </o> 
		dup :> rows[0].cells[1].innerHTML.replace(/[\s\n]+/,"","") tib. \ ==> 股東會及103年配股  (string)
		dup :> rows[1].cells[2].innerHTML tib. \ ==> 現金股利 (string)
		dup :> rows[1].cells[3].innerHTML float tib. \ ==> 2.5 (number)
		dup :> rows[2].cells[2].innerHTML tib. \ ==> 股票股利 (string)
		dup :> rows[2].cells[3].innerHTML float tib. \ ==> NaN (number)
		dup :> rows[3].cells[2].innerHTML tib. \ ==> 盈餘配股 (string)
		dup :> rows[3].cells[3].innerHTML float tib. \ ==> NaN (number)
		dup :> rows[4].cells[2].innerHTML tib. \ ==> 公積配股 (string)
		dup :> rows[4].cells[3].innerHTML float tib. \ ==> NaN (number)
		dup :> rows[5].cells[2].innerHTML tib. \ ==> 股東會日期 (string)
		dup :> rows[5].cells[3].innerHTML tib. \ ==> 104/06/22 (string)
		    :> rows[7].cells[1].innerHTML ( 股本 ) tib. \ ==> 4.56億 (string)		
		( cls source </o> ) js> $("table")[4] \ .innerHTML \ </o>
		dup :> rows[1].cells[0].innerHTML tib. \ ==> 除權日期 (string)
		dup :> rows[1].cells[1].innerHTML tib. \ ==> - (string)
		dup :> rows[1].cells[2].innerHTML tib. \ ==> 除息日期 (string)
		    :> rows[1].cells[3].innerHTML tib. \ ==> - (string)		
		
	^2 </comment> 
	
	<comment> ^1
	[ ] 這一段要展開, 裁剪 要擴充	
		保證有IE 
		<js> 
			[2227,2331,5508,2597,5225,5356,4113,4930,5015,6431,6177,1808,3666,5522,6168,6188,4542,6186,5464,2493,2545,
			3032,6203,2104,5603,5371,6241,2107,5511,6298,2542,6185,3315,6292,2377,2489,2520,3291,1715,9912,8271,6189,3078,
			3209,5251,2402,3312,5514,3056,2537,2841,2024,6265,2302,2890,2030] 
		</jsV> constant 高配息2015/6/19表 // ( -- array ) ["StockId"...}
		cut 高配息2015/6/19表 :> shift() ?dup [if]
		( id ) fubon_e01 :> [tos()].name ( id name )
		<text> \ 公司資料　營收盈餘 　股利政策　申報轉讓 ^1
		( 公司資料 ) navigate https://tw.stock.yahoo.com/d/s/company_{id}.html  60000 nap ready not-busy
		document :> body.innerHTML 裁剪 dataPath char {name}_{id}_company.htm + writeTextFile
		( 營收盈餘 ) navigate https://tw.stock.yahoo.com/d/s/earning_{id}.html  60000 nap ready not-busy
		document :> body.innerHTML 裁剪 dataPath char {name}_{id}_earning.htm + writeTextFile
		( 股利政策 ) navigate https://tw.stock.yahoo.com/d/s/dividend_{id}.html 60000 nap ready not-busy
		document :> body.innerHTML 裁剪 dataPath char {name}_{id}_dividend.htm + writeTextFile
		( 每股盈餘 )  navigate https://tw.screener.finance.yahoo.net/screener/check.html?symid={id} 60000 nap ready not-busy
		document :> body.innerHTML 裁剪 dataPath char {name}_{id}_EPS.htm + writeTextFile
		</text> :> replace(/{name}/mg,pop()) :> replace(/{id}/mg,pop()) </task>
		[else]  \ 高配息2015/6/19表 pop 完了
			stop
		[then] \ repeat
		1 nap rewind
		
		保證有IE 
		\ 展開所有的命令 含【每股盈餘】
		高配息2015/6/19表 :> slice(0) "" ( 開始: table string )
		cut  ( table string ) js> tos(1).shift() ( table string id ) ?dup [if] ( table string id )
		dup ( table string id id ) 公司資料 ( table string id string ) js: push(pop(2)+pop())
		( table id string ) over ( table id string id ) 營收盈餘 ( table id string string ) + 
		over ( table id string id ) 股利政策 ( table id string string ) + swap ( table string id ) 
		每股盈餘 + ( 重複: table string ) [else] nip stop ( 結果: string ) [then]
		( 繞回重來: table string ) 1 nap rewind 
		\ 檢查命令沒錯, 即可下達 </task> 執行。

		保證有IE 
		\ 展開所有的命令，不含【每股盈餘】因為該頁容易停頓。
		高配息2015/6/19表 :> slice(0) "" ( 開始: table string )
		cut  ( table string ) js> tos(1).shift() ( table string id ) ?dup [if] ( table string id )
		dup ( table string id id ) 公司資料 ( table string id string ) js: push(pop(2)+pop())
		( table id string ) over ( table id string id ) 營收盈餘 ( table id string string ) + 
		over ( table id string id ) 股利政策 ( table id string string ) + nip ( 重複: table string ) 
		[else] nip stop ( 結果: string ) [then] ( 繞回重來: table string ) 1 nap rewind 
		\ 檢查命令沒錯, 即可下達 </task> 執行。
		
		
	[ ] 然後一長列讓它跑,看到哪裡有問題,要有充分的資訊,最好 log 一個進度表.
	
	以上成功!
		[ ] 能不能在等一段時間後強制 stop 該等網頁? 因為資料已經到手，其他都是廣告。 
		[x] 進一步抓出所要的 table . . . . 
			--> content start ~ content end 之間的就是了。
			--> 成功
			: 裁剪 ( "html" -- "html'" ) \ 只取 content start ~ content end 之間的部分
				:> replace(/\n/mg,"_cr_")	\ replace cr with _cr_ makes below operations easier
				\ 這兩個用不著 remove-script remove-onmouse，以下的更精準。
				<js> pop().replace(/.*content start\s*-+>/g,"")</jsV>
				<js> pop().replace(/<!-+\s*content end.*/g,"")</jsV>
				:> replace(/_cr_/g,"\n") ;
				/// Ex. cls dataPath char 4703_dividend.htm + readTextFile 裁剪 </o>
	^1 </comment>	

	<comment> 
		從富邦 http://www.fubon-ebroker.com 網頁,先找到我要的 經營績效 表格，透過 Chrome F12 debugger 去 COPY 該 table element 即得如下 HTML：
		這個地方非常深邃，
		比較直接的網址 http://fubon-ebrokerdj.fbs.com.tw/SmartNavi3.asp?A=$^$^B$^BA$^BA]DJHTM&B=1
		原始資料 證券櫃檯買賣中心 s" iexplore http://www.tpex.org.tw/web/index.php?l=zh-tw" (fork)
		台灣證券交易所 除權除息 http://www.twse.com.tw/ch/trading/exchange/TWT48U/genpage/Report201506/TWT48USTKNO.php?chk_date=104/06/16&Sort_kind=STKNO
	</comment>	
	
	<comment>	
		\ 上網讀取 台灣銀行 除權除息表-依股號 http://fund.bot.com.tw/z/ze/zeb/zeba.djhtm  the form id='SysJustIFRAMEDIV'
		<task>
		list-ie-windows cr
		ShellWindows :> count [if] 
			ShellWindows :> count 1- window(i)
			:: open("http://fund.bot.com.tw/z/ze/zeb/zeba.djhtm","_top")
			\ 不用這個 window object, 它總是【沒有使用權限】【存取被拒】。
		[else] 
			<vb> Set ie = GetObject("","InternetExplorer.Application"):kvm.push(ie)</vb> // ( -- obj ) Internet Explorer object
			:: Navigate("http://fund.bot.com.tw/z/ze/zeb/zeba.djhtm","_top")
		[then] 
		cut 100 nap ShellWindows :> count 1- ie(i) :> ReadyState 4 != char . . ?rewind
		ShellWindows :> item(0) :: visible=true 
		\ 10000 nap ( 等個十秒鐘夠了吧! )
		ShellWindows :> count 1- window(i) \ 又要重抓
		:> document.getElementById('SysJustIFRAMEDIV')
		:> innerHTML 
		:> replace(/\n/mg,"_cr_")	\ replace cr with _cr_ makes below operations easier
		:> replace(/<script.*?script>/g,"")		\ remove all <script>
		:> replace(/<select.*?select>/g,"")		\ remove all <select>
		:> replace(/<br>/g,"")					\ remove all <br>
		:> replace(/.*<form/g,"<form")			\ remove before <form>
		:> replace(/<form.*?valign="top">/,"")	\ remove <form to the outer <table>
		:> replace(/<tbody>.*?<\/tr>/,"<tbody>")		\ remove the caption row
		:> replace(/<\/form>.*/g,"")					\ remove after </form>
		:> replace(/<\/table>.*?<\/table>/,"</table>")	\ remove the end of the outer <table>
		:> replace(/_cr_/g,"\n")
		. \ </o>
		</task>
	</comment>
	
	<comment>	
		\ 上網讀取 元大寶來 彼得林區 the form id='SysJustIFRAMEDIV'
		<text> http://www.yuanta.com.tw/pages/content/Frame.aspx?Node=c90a3ca2-82c6-4ab4-bd4c-2c72665f0ec8</text> value url
		<text> </text> value tableId 
		<task>
		list-ie-windows cr
		ShellWindows :> count [if] 
			ShellWindows :> count 1- window(i)
			:: open(g.url,"_top")
			\ 不用這個 window object, 它總是【沒有使用權限】【存取被拒】。
		[else] 
			<vb> Set ie = GetObject("","InternetExplorer.Application"):kvm.push(ie)</vb> // ( -- obj ) Internet Explorer object
			:: Navigate(g.url,"_top")
		[then] 
		cut 100 nap ShellWindows :> count 1- ie(i) :> ReadyState 4 != char . . ?rewind
		ShellWindows :> item(0) :: visible=true 
		\ 10000 nap ( 等個十秒鐘夠了吧! )
		ShellWindows :> count 1- window(i) \ 又要重抓
		:> document.getElementById('SysJustIFRAMEDIV')
		:> innerHTML 
		:> replace(/\n/mg,"_cr_")	\ replace cr with _cr_ makes below operations easier
		:> replace(/<script.*?script>/g,"")		\ remove all <script>
		:> replace(/<select.*?select>/g,"")		\ remove all <select>
		:> replace(/<br>/g,"")					\ remove all <br>
		:> replace(/.*<form/g,"<form")			\ remove before <form>
		:> replace(/<form.*?valign="top">/,"")	\ remove <form to the outer <table>
		:> replace(/<tbody>.*?<\/tr>/,"<tbody>")		\ remove the caption row
		:> replace(/<\/form>.*/g,"")					\ remove after </form>
		:> replace(/<\/table>.*?<\/table>/,"</table>")	\ remove the end of the outer <table>
		:> replace(/_cr_/g,"\n")
		. \ </o>
		</task>
	</comment>
	
	<comment>		
		
		<text>
		\ Feature I. Convert stock name list to stock ID list
		\ Usage:
		\ 	1. Edit the below "stock name list".
		\	2. include money.f run "stock-name-list isolate-stock-id ."
		\	3. copy-paste the generated stock ID list to the excel file.
		
		\ Feature II.  Convert a Stock ID list to Fubon e01 excel automation formulas.
		\ Usage:
		\ 	1. Edit the below Stock ID list.
		\	2. include money.f run "cooked-formulas char formulas.txt writeTextFile"
		\	3. copy-paste the generated "jeforth.3we\formulas.txt" to the excel file.
		
		</text>
		
		\ Convert stock name list to stock ID list
			<text>
				1264德麥
				1590F-亞德
			</text> :> split('\n') \ Convert lines to an array
			constant stock-name-list // ( -- ["stock"] ) Like [4703揚華,912398友佳,8066來思達,...]
			code isolate-stock-id ( ["stock"] -- "string" ) \ Convert stock name list to stock id list
				var aa=pop(), bb="", ss="";
				for (var i=0; i<aa.length; i++){
					ss = aa[i].replace(/(^( |\t)*)|(( |\t)*$)/g,''); // remove 頭尾 white spaces
					if (ss=="") continue;
					ss = ss.match(/^\d+/)
					bb += ss + '\n';
				}
				push(bb); end-code
				/// Usage: stock-name-list isolate-stock-id er .
				
		\ Stock ID list
			<text>
				2916
				5388
				6457
				8027
			</text> :> split('\n') \ Convert lines to an array
			code trim-white-spaces(temp) ( array -- array' ) \ Remove leading/tailing white spaces and empty lines
				var aa=pop(), bb=[], ss="";
				for (var i=0; i<aa.length; i++){
					ss = aa[i].replace(/(^( |\t|\r)*)|(( |\t|\r)*$)/g,''); // remove 頭尾 white spaces
					if (ss=="") continue;
					bb.push(ss);
				}
				push(bb); end-code last execute (forget) 
			constant stocks // ( -- ["stockId"...] ) Stock ID's in an array
		\ The formula raw string
			<text> =XQFAP|Quote!'<id>.TW-ID'
			=XQFAP|Quote!'<id>.TW-Name'
			=XQFAP|Quote!'<id>.TW-Time'
			=XQFAP|Quote!'<id>.TW-Price'
			=XQFAP|Quote!'<id>.TW-Volume'
			=XQFAP|Quote!'<id>.TW-TotalVolume'
			=XQFAP|Quote!'<id>.TW-High'
			=XQFAP|Quote!'<id>.TW-Low'</text> :> replace(/\s+/g,'\t') CR +
			constant formula // ( -- 'string' ) Excel formula of the "e01" worksheet.
			
		: cooked-formulas ( -- "formulas" ) \ Print formula lines with <id> replaced by stock ID.
			"" stocks :> slice(0) dup :> length ( -- ss [id] length ) for 
				js> tos().pop() ( -- ss [id] id )
				formula :> replace(/<id>/g,pop()) ( -- ss [id] formula' )
				rot swap + swap 
			next drop ;
			/// Usage: cooked-formulas char formulas.txt writeTextFile
		
		fubon e01 all DDE formula
			1	2	3	4	5	6	7	8	9	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32	33	34	35	36	37	38	39	40	41	42	43	44	45	46	47	48	49	50	51	52	53	54	55	56	57	58	59	60	61	62	63	64	65	66	67	68	69	70	71	72	73	74	75	76	77	78	79	80	81	82	83	84	85	86	87	88	89	90	91	92	93	94	95	96	97	98	99	100	101	102	103	104	105	106	107	108	109	110	111	112	113	114	115	116	117	118	119	120	121	122	123	124	125	126	127	128	129	130	131	132	133	134	135	136	137	138	139	140	141	142	143	144	145	146	147	148	149	150	151	152	153	154	155	156	157	158	159	160	161	162	163	164	165	166	167	168	169	170	171	172	173	174	175	176	177	178	179	180	181	182	183	184	185	186	187	188	189	190	191	192	193	194	195	196	197	198
			代碼	商品	交易日期	時間	買進	賣出	成交	漲跌	漲幅%	振幅%	單量	總量	委買	委賣	最高	最低	開盤	昨收	均價	漲停	跌停	內盤	外盤	內外盤比%	內外盤比圖	前一	前二	前三	前四	昨量	盤後量	買進一	買進二	買進三	買進四	買進五	賣出一	賣出二	賣出三	賣出四	賣出五	委買一	委買二	委買三	委買四	委買五	總委買	委賣一	委賣二	委賣三	委賣四	委賣五	總委賣	累計委買	累委買筆	委買均	累計委賣	累委賣筆	委賣均	累計成交	累成交筆	成交均	內盤家	外盤家	上漲家	下跌家	平盤家	漲停家	跌停家	上漲量	下跌量	平盤量	幣別	銀行	銀行名稱	外匯價	前匯價	RS%	RSL	Beta	一週%	一月%	一季%	半年%	一年%	YTD%	公司動態	產業地位	未平倉	未平倉變化	結算價	基差	價差	內含值	時間價值	歷史波動率%	履約率%	理論價	Delta	Gamma	Theta	Vega	Rho	隱含波動率%	買賣價差	買賣價差%	隱含履約率%	量P/C	倉P/C	保證金	權利金	累買成筆	累賣成筆	成交值	成交比重%	存續期間	代碼	商品	中文簡稱	中文全名	英文簡稱	英文全名	交易單位	類型	標的股	執行比例	履約價	限制價	最後交易日	到期日	剩餘日	內含價值	價內外%	有效槓桿比例	買進隱含波動率%	賣出隱含波動率%	標的價格	標的漲跌	標的漲幅%	波動率差額	市值	淨利	盈餘	盈餘(單)	盈餘(4)	盈餘(累)	營收	營收(12)	營收期增率%	營收年增率%	每股淨值	毛利率%	營益率%	稅後淨利率%	每股營收	ROE%	營業利益成長率%	稅前淨利成長率%	稅後淨利成長率%	PE(市盈率)	PB(市淨率)	資產報酬率%	流動比率%	速動比率%	負債比率%	利息保障倍數	應收帳款週轉率%	存貨週轉率%	固定資產週轉率%	總資產週轉率%	員工平均營業額	淨值週轉率%	現金股利	股票股利	現金+股票股利	現金流量	應收帳款	上市日期	委比	委買賣差	換手率%	量比	股數	股本	殖利率%	溢價率%	損益兩平	暫停交易時間	恢復交易時間	暫緩收盤	發行財務費用	流通在外張數	流通在外比率%	現股距回收價%	財務費用(日)	財務費用率%	試算買價	試算賣價
			=XQFAP|Quote!'2597.TW-ID'	=XQFAP|Quote!'2597.TW-Name'	=XQFAP|Quote!'2597.TW-TradingDate'	=XQFAP|Quote!'2597.TW-Time'	=XQFAP|Quote!'2597.TW-Bid'	=XQFAP|Quote!'2597.TW-Ask'	=XQFAP|Quote!'2597.TW-Price'	=XQFAP|Quote!'2597.TW-PriceChange'	=XQFAP|Quote!'2597.TW-PriceChangeRatio'	=XQFAP|Quote!'2597.TW-Amplitude'	=XQFAP|Quote!'2597.TW-Volume'	=XQFAP|Quote!'2597.TW-TotalVolume'	=XQFAP|Quote!'2597.TW-BestBidSize'	=XQFAP|Quote!'2597.TW-BestAskSize'	=XQFAP|Quote!'2597.TW-High'	=XQFAP|Quote!'2597.TW-Low'	=XQFAP|Quote!'2597.TW-Open'	=XQFAP|Quote!'2597.TW-PreClose'	=XQFAP|Quote!'2597.TW-AvgPrice'	=XQFAP|Quote!'2597.TW-UpLimit'	=XQFAP|Quote!'2597.TW-DownLimit'	=XQFAP|Quote!'2597.TW-InSize'	=XQFAP|Quote!'2597.TW-OutSize'	=XQFAP|Quote!'2597.TW-InOutRatioNumber'	=XQFAP|Quote!'2597.TW-InOutRatio'	=XQFAP|Quote!'2597.TW-PrePrice1'	=XQFAP|Quote!'2597.TW-PrePrice2'	=XQFAP|Quote!'2597.TW-PrePrice3'	=XQFAP|Quote!'2597.TW-PrePrice4'	=XQFAP|Quote!'2597.TW-PreTotalVolume'	=XQFAP|Quote!'2597.TW-PostSize'	=XQFAP|Quote!'2597.TW-BestBid1'	=XQFAP|Quote!'2597.TW-BestBid2'	=XQFAP|Quote!'2597.TW-BestBid3'	=XQFAP|Quote!'2597.TW-BestBid4'	=XQFAP|Quote!'2597.TW-BestBid5'	=XQFAP|Quote!'2597.TW-BestAsk1'	=XQFAP|Quote!'2597.TW-BestAsk2'	=XQFAP|Quote!'2597.TW-BestAsk3'	=XQFAP|Quote!'2597.TW-BestAsk4'	=XQFAP|Quote!'2597.TW-BestAsk5'	=XQFAP|Quote!'2597.TW-BestBidSize1'	=XQFAP|Quote!'2597.TW-BestBidSize2'	=XQFAP|Quote!'2597.TW-BestBidSize3'	=XQFAP|Quote!'2597.TW-BestBidSize4'	=XQFAP|Quote!'2597.TW-BestBidSize5'	=XQFAP|Quote!'2597.TW-FiveBidSize'	=XQFAP|Quote!'2597.TW-BestAskSize1'	=XQFAP|Quote!'2597.TW-BestAskSize2'	=XQFAP|Quote!'2597.TW-BestAskSize3'	=XQFAP|Quote!'2597.TW-BestAskSize4'	=XQFAP|Quote!'2597.TW-BestAskSize5'	=XQFAP|Quote!'2597.TW-FiveAskSize'	=XQFAP|Quote!'2597.TW-TotalBidContract'	=XQFAP|Quote!'2597.TW-TotalBidSize'	=XQFAP|Quote!'2597.TW-TotalEachBidSize'	=XQFAP|Quote!'2597.TW-TotalAskContract'	=XQFAP|Quote!'2597.TW-TotalAskSize'	=XQFAP|Quote!'2597.TW-TotalEachAskSize'	=XQFAP|Quote!'2597.TW-TotalMakeContract'	=XQFAP|Quote!'2597.TW-TotalMakeSize'	=XQFAP|Quote!'2597.TW-TotalEachMakeSize'	=XQFAP|Quote!'2597.TW-InNo'	=XQFAP|Quote!'2597.TW-OutNo'	=XQFAP|Quote!'2597.TW-UpStk'	=XQFAP|Quote!'2597.TW-DownStk'	=XQFAP|Quote!'2597.TW-EqualStk'	=XQFAP|Quote!'2597.TW-UpLimitStk'	=XQFAP|Quote!'2597.TW-DownLimitStk'	=XQFAP|Quote!'2597.TW-UpVolume'	=XQFAP|Quote!'2597.TW-DownVolume'	=XQFAP|Quote!'2597.TW-EqualVolume'	=XQFAP|Quote!'2597.TW-FX'	=XQFAP|Quote!'2597.TW-BankID'	=XQFAP|Quote!'2597.TW-BankName'	=XQFAP|Quote!'2597.TW-CurrencyPrice'	=XQFAP|Quote!'2597.TW-PreCurrencyPrice'	=XQFAP|Quote!'2597.TW-StockRS'	=XQFAP|Quote!'2597.TW-StockRSL'	=XQFAP|Quote!'2597.TW-Beta'	=XQFAP|Quote!'2597.TW-WeekReturn'	=XQFAP|Quote!'2597.TW-MonthReturn'	=XQFAP|Quote!'2597.TW-QuarterReturn'	=XQFAP|Quote!'2597.TW-HalfYearReturn'	=XQFAP|Quote!'2597.TW-YearReturn'	=XQFAP|Quote!'2597.TW-YTDReturn'	=XQFAP|Quote!'2597.TW-CompanyNews'	=XQFAP|Quote!'2597.TW-CompanyPos'	=XQFAP|Quote!'2597.TW-OI'	=XQFAP|Quote!'2597.TW-OIChange'	=XQFAP|Quote!'2597.TW-SettlePrice'	=XQFAP|Quote!'2597.TW-BaseDif'	=XQFAP|Quote!'2597.TW-PriceDiff'	=XQFAP|Quote!'2597.TW-InnerValue'	=XQFAP|Quote!'2597.TW-TimeValue'	=XQFAP|Quote!'2597.TW-Volatility'	=XQFAP|Quote!'2597.TW-ExeProb'	=XQFAP|Quote!'2597.TW-TheoryPrice'	=XQFAP|Quote!'2597.TW-Delta'	=XQFAP|Quote!'2597.TW-Gamma'	=XQFAP|Quote!'2597.TW-Theta'	=XQFAP|Quote!'2597.TW-Vega'	=XQFAP|Quote!'2597.TW-Rho'	=XQFAP|Quote!'2597.TW-ImplyVolatility'	=XQFAP|Quote!'2597.TW-BidAskPriceDiff'	=XQFAP|Quote!'2597.TW-BidAskPriceDiffRatio'	=XQFAP|Quote!'2597.TW-ImplyExeProb'	=XQFAP|Quote!'2597.TW-VolumePCR'	=XQFAP|Quote!'2597.TW-OIPCR'	=XQFAP|Quote!'2597.TW-Guarantee'	=XQFAP|Quote!'2597.TW-OptionPremium'	=XQFAP|Quote!'2597.TW-$TotalBidMatchTx'	=XQFAP|Quote!'2597.TW-$TotalAskMatchTx'	=XQFAP|Quote!'2597.TW-Value'	=XQFAP|Quote!'2597.TW-StockValueRatio'	=XQFAP|Quote!'2597.TW-PersistPeriod'	=XQFAP|Quote!'2597.TW-ID'	=XQFAP|Quote!'2597.TW-Name'	=XQFAP|Quote!'2597.TW-CName'	=XQFAP|Quote!'2597.TW-CFName'	=XQFAP|Quote!'2597.TW-EName'	=XQFAP|Quote!'2597.TW-EFName'	=XQFAP|Quote!'2597.TW-TradeLotSize'	=XQFAP|Quote!'2597.TW-WCPType'	=XQFAP|Quote!'2597.TW-WBaseSymbol'	=XQFAP|Quote!'2597.TW-WRatio'	=XQFAP|Quote!'2597.TW-WContractPrice'	=XQFAP|Quote!'2597.TW-CeilingPrice'	=XQFAP|Quote!'2597.TW-WLastTradeDate'	=XQFAP|Quote!'2597.TW-WContractDate'	=XQFAP|Quote!'2597.TW-WRemainDate'	=XQFAP|Quote!'2597.TW-WInnerValue'	=XQFAP|Quote!'2597.TW-WInOutRatio'	=XQFAP|Quote!'2597.TW-WLeverRatio'	=XQFAP|Quote!'2597.TW-WBidImplyVolatility'	=XQFAP|Quote!'2597.TW-WAskImplyVolatility'	=XQFAP|Quote!'2597.TW-WBasePrice'	=XQFAP|Quote!'2597.TW-WBasePriceChange'	=XQFAP|Quote!'2597.TW-WBasePriceChangeRatio'	=XQFAP|Quote!'2597.TW-VolatilityDiff'	=XQFAP|Quote!'2597.TW-MarketValue'	=XQFAP|Quote!'2597.TW-NetProfit'	=XQFAP|Quote!'2597.TW-Profit'	=XQFAP|Quote!'2597.TW-ProfitSingle'	=XQFAP|Quote!'2597.TW-ProfitFourSeason'	=XQFAP|Quote!'2597.TW-ProfitAcc'	=XQFAP|Quote!'2597.TW-NetSales'	=XQFAP|Quote!'2597.TW-AccumulatedRevenue'	=XQFAP|Quote!'2597.TW-TFXRatio'	=XQFAP|Quote!'2597.TW-MonthlyNetSalesYoY'	=XQFAP|Quote!'2597.TW-StockNetValue'	=XQFAP|Quote!'2597.TW-ProfitMargin'	=XQFAP|Quote!'2597.TW-OperatingProfitRatio'	=XQFAP|Quote!'2597.TW-NetProfitMargin'	=XQFAP|Quote!'2597.TW-RevenuePerShare'	=XQFAP|Quote!'2597.TW-ROE'	=XQFAP|Quote!'2597.TW-OperIncomeGrowthRate'	=XQFAP|Quote!'2597.TW-PreTaxIncomeGrowthRate'	=XQFAP|Quote!'2597.TW-NetIncomeGrowthRate'	=XQFAP|Quote!'2597.TW-PERatio'	=XQFAP|Quote!'2597.TW-PBRatio'	=XQFAP|Quote!'2597.TW-ReturnOnAssets'	=XQFAP|Quote!'2597.TW-CurrentRatio'	=XQFAP|Quote!'2597.TW-QuickRatio'	=XQFAP|Quote!'2597.TW-LiabilityRatio'	=XQFAP|Quote!'2597.TW-TimesInterestEarne'	=XQFAP|Quote!'2597.TW-ReceivablesTurnoverRatio'	=XQFAP|Quote!'2597.TW-InventoryTurnoverRatio'	=XQFAP|Quote!'2597.TW-FixedAssetTurnoverRatio'	=XQFAP|Quote!'2597.TW-TotalAssetTurnoverRatio'	=XQFAP|Quote!'2597.TW-EmployeeAvgTurnover'	=XQFAP|Quote!'2597.TW-EquityTurnoverRatio'	=XQFAP|Quote!'2597.TW-CashDividend'	=XQFAP|Quote!'2597.TW-StockDividend'	=XQFAP|Quote!'2597.TW-CashAndStockDividend'	=XQFAP|Quote!'2597.TW-CashFlow'	=XQFAP|Quote!'2597.TW-AccountsReceivable'	=XQFAP|Quote!'2597.TW-ListingDate'	=XQFAP|Quote!'2597.TW-BidAskSizeRatio'	=XQFAP|Quote!'2597.TW-BidAskDiff'	=XQFAP|Quote!'2597.TW-TurnoverRatio'	=XQFAP|Quote!'2597.TW-VolumeRatio'	=XQFAP|Quote!'2597.TW-Shared'	=XQFAP|Quote!'2597.TW-Capital'	=XQFAP|Quote!'2597.TW-CashDividendYieldRate'	=XQFAP|Quote!'2597.TW-PremiumRate'	=XQFAP|Quote!'2597.TW-BreakEven'	=XQFAP|Quote!'2597.TW-PauseTradingTime'	=XQFAP|Quote!'2597.TW-RestoreTradingTime'	=XQFAP|Quote!'2597.TW-DelayTradeState'	=XQFAP|Quote!'2597.TW-FinancialCosts'	=XQFAP|Quote!'2597.TW-OutstandingSize'	=XQFAP|Quote!'2597.TW-OutstandingRate'	=XQFAP|Quote!'2597.TW-RecoveryRate'	=XQFAP|Quote!'2597.TW-FinancialCostDay'	=XQFAP|Quote!'2597.TW-FinancialCostYear'	=XQFAP|Quote!'2597.TW-CalcBid'	=XQFAP|Quote!'2597.TW-CalcAsk'
			0000000 =XQFAP|Quote!'2597.TW-ID,Name,TradingDate,Time,Bid,Ask,Price,PriceChange,PriceChangeRatio,Amplitude'
			0000001 =XQFAP|Quote!'2597.TW-Volume,TotalVolume,BestBidSize,BestAskSize,High,Low,Open,PreClose,AvgPrice,UpLimit'
			0000002 =XQFAP|Quote!'2597.TW-DownLimit,InSize,OutSize,InOutRatioNumber,InOutRatio,PrePrice1,PrePrice2,PrePrice3,PrePrice4,PreTotalVolume'
			0000003 =XQFAP|Quote!'2597.TW-PostSize,BestBid1,BestBid2,BestBid3,BestBid4,BestBid5,BestAsk1,BestAsk2,BestAsk3,BestAsk4'
			0000004 =XQFAP|Quote!'2597.TW-BestAsk5,BestBidSize1,BestBidSize2,BestBidSize3,BestBidSize4,BestBidSize5,FiveBidSize,BestAskSize1,BestAskSize2,BestAskSize3'
			0000005 =XQFAP|Quote!'2597.TW-BestAskSize4,BestAskSize5,FiveAskSize,TotalBidContract,TotalBidSize,TotalEachBidSize,TotalAskContract,TotalAskSize,TotalEachAskSize,TotalMakeContract'
			0000006 =XQFAP|Quote!'2597.TW-TotalMakeSize,TotalEachMakeSize,InNo,OutNo,UpStk,DownStk,EqualStk,UpLimitStk,DownLimitStk,UpVolume'
			0000007 =XQFAP|Quote!'2597.TW-DownVolume,EqualVolume,FX,BankID,BankName,CurrencyPrice,PreCurrencyPrice,StockRS,StockRSL,Beta'
			0000008 =XQFAP|Quote!'2597.TW-WeekReturn,MonthReturn,QuarterReturn,HalfYearReturn,YearReturn,YTDReturn,CompanyNews,CompanyPos,OI,OIChange'
			0000009 =XQFAP|Quote!'2597.TW-SettlePrice,BaseDif,PriceDiff,InnerValue,TimeValue,Volatility,ExeProb,TheoryPrice,Delta,Gamma'
			0000010 =XQFAP|Quote!'2597.TW-Theta,Vega,Rho,ImplyVolatility,BidAskPriceDiff,BidAskPriceDiffRatio,ImplyExeProb,VolumePCR,OIPCR,Guarantee'
			0000011 =XQFAP|Quote!'2597.TW-OptionPremium,$TotalBidMatchTx,$TotalAskMatchTx,Value,StockValueRatio,PersistPeriod,ID,Name,CName,CFName'
			0000012 =XQFAP|Quote!'2597.TW-EName,EFName,TradeLotSize,WCPType,WBaseSymbol,WRatio,WContractPrice,CeilingPrice,WLastTradeDate,WContractDate'
			0000013 =XQFAP|Quote!'2597.TW-WRemainDate,WInnerValue,WInOutRatio,WLeverRatio,WBidImplyVolatility,WAskImplyVolatility,WBasePrice,WBasePriceChange,WBasePriceChangeRatio,VolatilityDiff'
			0000014 =XQFAP|Quote!'2597.TW-MarketValue,NetProfit,Profit,ProfitSingle,ProfitFourSeason,ProfitAcc,NetSales,AccumulatedRevenue,TFXRatio,MonthlyNetSalesYoY'
			0000015 =XQFAP|Quote!'2597.TW-StockNetValue,ProfitMargin,OperatingProfitRatio,NetProfitMargin,RevenuePerShare,ROE,OperIncomeGrowthRate,PreTaxIncomeGrowthRate,NetIncomeGrowthRate,PERatio'
			0000016 =XQFAP|Quote!'2597.TW-PBRatio,ReturnOnAssets,CurrentRatio,QuickRatio,LiabilityRatio,TimesInterestEarne,ReceivablesTurnoverRatio,InventoryTurnoverRatio,FixedAssetTurnoverRatio,TotalAssetTurnoverRatio'
			0000017 =XQFAP|Quote!'2597.TW-EmployeeAvgTurnover,EquityTurnoverRatio,CashDividend,StockDividend,CashAndStockDividend,CashFlow,AccountsReceivable,ListingDate,BidAskSizeRatio,BidAskDiff'
			0000018 =XQFAP|Quote!'2597.TW-TurnoverRatio,VolumeRatio,Shared,Capital,CashDividendYieldRate,PremiumRate,BreakEven,PauseTradingTime,RestoreTradingTime,DelayTradeState'
			0000019 =XQFAP|Quote!'2597.TW-FinancialCosts,OutstandingSize,OutstandingRate,RecoveryRate,FinancialCostDay,FinancialCostYear,CalcBid,CalcAsk'

		[ ]	每隔一段時間抓一下所有公司的除權除息日,這要花一點時間。能不能自動化?
		[x]	0 0 offset 都改成 activeCell 
		[ ] 因為 improve 得很頻繁，有必要寫個 self-test。
		[ ] DDE>value 跟 value-it 很像,好像重複了?
		[ ] money.f 自動抓 Yahoo 資料還要加上歷年【每股盈餘】的頁面。

	</comment>