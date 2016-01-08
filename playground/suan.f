	\ The "multitaskjavascripteforth" porject 
	vocabulary multitaskjavascripteforth 
	also multitaskjavascripteforth definitions
	
	<h> <script src="playground/multitaskjavascripteforth/jeForthVM.js"></script></h> 
		drop \ The script element has no use for anything.
	<js> push(new jeForthVM())</js> 
		value vm // ( -- obj ) The "multitaskjavascripteforth" Virtual Machine.
	vm :: type=print
	code {F1} ( -- ) \ Let the "multitaskjavascripteforth" VM to run the inputbox
		var cmd = inputbox.value;
		inputbox.value=""; 
		kvm.cmdhistory.push(cmd);
		g.vm.exec(cmd) ;
		window.scrollTo(0,endofinputbox.offsetTop);
		inputbox.focus();
		push(false);
		end-code
		
	\ jefvm0.html demo
	<text> 
		code 印出 function(){	//++ jeforth_word . ( n -- )
		  type(' '+dStk.pop())	// pop n from stack and type it
		} end-code
		code 加 function(){	//++ jeforth_word + ( a b -- a+b )
		  var b=dStk.pop()	// pop b from stack
		  dStk[dStk.length-1]+=b// add b to top of stack
		} end-code
		code 字串 function(){	//++ jeforth_word token ( -- t )
		  dStk.push(nxtTkn())	// push next token to stack
		} end-code
	</text> js: g.vm.exec(pop())

	\ jefvm1.html demo 'default'
	<text> 
		code .s function(){
			for (var i=0; i<dStk.length; i++) type('['+dStk[i]+'('+typeof(dStk[i])+')]');
		} end-code
		code immediate function () {	 // 定義 指令 immediate
		  lstWrd.immediate=1		 // 使 最後定義的指令 在高階編譯狀態 也能執行
		} end-code
		code // function () { var n,t	 // 定義 指令 // (雙斜線) 忽略 源碼字串 到列尾
		  iTib += (n= (t=tib.substr(iTib)).indexOf('\n') )>=0 ? n : t.length
		} end-code immediate		 // 使 雙斜線 指令 在高階編譯狀態 也能執行

		// // // // // // // // // // // // // // // // // // // // // // // //	//
		//		請 先 讀 此 說 明	R E A D M E   F I R S T			//
		// // // // // // // // // // // // // // // // // // // // // // // //	//
		//   此 極簡符式系統 很原始, 剛啟動時 只有 主要指令 code, 相關說明 簡述如下	//
		// A 此例 先用 code 定義 符式指令 immediate 及 雙斜線, 希定義 雙斜線 用作註解	//	
		//   注意! 雙斜線 後必須 空格, 這樣 接下來的源碼字串 就會當作 註解 直到列尾		//
		// B 用 code 定義的 是所謂 符式低階指令, 以 javascript 匿名 function 描述動作	//
		// C code 語法: 其後是 指令名稱 接下來到 end-code 是 不含參數的 匿名 function	//
		//   符式系統 的 指令名稱 通常 沒有限制 可以是 不含空格及跳格的 任何字串		//
		//   符式指令 間 通常都用 堆疊 dStk 互傳資訊, 不需透過 function 參數 傳資訊	//
		//   匿名 function 依循 javascript 語法, 雙斜線 到列尾 的字串 原來就用作註解	//
		//   只是 這樣的註解 僅限 function 內, 為使 code 定義外 也能 用作註解 特此定義	//
		// D 注意! code 之後 若為字串 function 乃特例, 此 function 並不當作 指令名稱	//
		//   這時 從 function 到 end-code 前 直接用來 定義 javascript 含名 function	//
		//   依 javascript 語法 也可宣告參數, 這些 function 可被 符式低階指令 呼叫	//
		//   但注意! 呼叫時 需前置 VM. 例如: 定義了 xxx(str) 可用 VM.xxx('hello') 呼叫	//
		// E 後續 用 code 所定義 冒號 : 及 分號 ; 倆指令 乃特別用來以定義 符式高階指令	//
		//   冒號指令 接 空格 然後才是 新指令名稱, 之後 就可用 已定義 符式指令 描述動作	//
		//   直到 分號指令 為止, 其間包括用 雙斜線 指令 接 空格 直到列尾的字串 當作註解	//
		// F 游標在 標題 輸入格 按 向上 或 向下 鍵, 可檢視 該標題 對應 內容 (含測試源碼)	//
		// G 游標在 標題 輸入格 按 Enter鍵 或 直接點 evaluate 按鈕, 可看 源碼解譯 結果	//
		// H 清 標題 01 topics 內容 點 saveText 按 F5 (google 瀏覽器重載網頁) 即恢復原	//
		//   topics 並且恢復 每標題 所對應 原始內容 (含測試源碼)			//
		// I 按 F12 (google 瀏覽器網頁追蹤) 進入 javascript 除錯視窗, 到 jeforthVM.js	//
		//   檔尾 dbg function 設斷點, 然後 					//
		//   在 text area 程式碼 插入 dbg 指令 點 evalute, 執行到 dbg 即可進行追蹤除錯	//
		// J 下面 debug 指令 讓 源碼隨後指令 執行前先印出 "debugging" (可到 dbg 設斷點)	//
		// // // // // // // // // // // // // // // // // // // // // // // //	//
		code debug function() {	// 定義 指令 debug ( <指令名稱> -- )
		  var token=nxtTkn()	// 從 隨後源碼 取 token (以空格區隔的下一個字串)
		  var z=fndWrd(token)	// 取 所對應 指令位址 [vid,wid]
		  if (z) {
			if (0>debugged.indexOf(z=z.join())) // 如果 不在 待追蹤指令陣列
			  debugged.push(z)			// 將 指令位址 加入 待追蹤指令陣列
			else
			  print(z+' already in debugged')	// 已在 待追蹤指令陣列
		  } else
			  abort('debug '+token+' undefined')// 沒有 所對應 符式指令 資訊
		} end-code
		code find function () { // 定義 指令 find ( <指令名稱> -- 指令位址 )
		  dStk.push( fndWrd( nxtTkn() ) )	// 隨後源碼 指令名稱 的 指令位址 上堆疊
		} end-code
		code ' function () { // 定義 指令 ' ( <指令名稱> -- 指令位址 )
		  var z, t
		  var z=fndWrd(t=nxtTkn())	// 隨後源碼 指令名稱 的 指令位址 z
		  if (z) dStk.push(z)		// 若找到 z 就放上堆疊
		  else abort(t+' not found')	// 否則 就 abort
		} end-code
		code alias function () { // 定義 指令 alias ( 指令位址 <指令別名> -- )
		  var w=zWrd(dStk.pop())	// 取 已定義指令 w
		  newWrd(nxtTkn(),w.xt)	// 定義 隨後源碼 指令別名
		  if (w.src)         lstWrd.src		=w.src		// 高階源碼
		  if (w.compileOnly) lstWrd.compileOnly	=w.compileOnly	// 在高階編譯狀態 才執行
		  if (w.immediate)   lstWrd.immediate	=w.immediate	// 在高階編譯狀態 能執行
		  if (w.wrds)        lstWrd.wrds	=w.wrds	// 詞彙指令陣列
		  if (w.index)  lstWrd.index	=w.index	// 詞彙指令索引
		} end-code
		code : function () { // 定義 指令 : ( <指令名稱> -- ) 開始 高階指令的定義
		  src		= ''			// 高階指令 源碼
		  hSrc		= iTib-2		// 高階指令 源碼字串起點
		  hName		= nxtTkn()		// 高階指令 名稱
		  hXt		= compiledCode.length 	// 高階指令 編碼起點
		  compiling	= 1			// 高階指令 編譯狀態 進入
		} end-code
		code compileOnly function () { // 定義 指令 compileOnly ( -- )
		  lstWrd.compileOnly=1		// 使 最後定義指令 高階編譯狀態 才編碼
		} end-code
		code ret function () { // 定義 指令 ret ( -- ) 結束被呼叫的 高階指令
		  ip=rStk.pop()		// 從 return stack 取出 ip
		} end-code compileOnly	// 使 ret 在高階編譯狀態 才編碼
		code doLit function () { // 定義 指令 doLit ( -- n ) 將 隨後編碼 n 放上堆疊
		  var n=compiledCode[ip++]	// 取 ip 所指 編碼 n
		  dStk.push(n)			// 將 n 放上堆疊
		} end-code compileOnly		// 使 doLit 在高階編譯狀態 才編碼
		code ; function () { // 定義 指令 ; ( -- ) 結束 高階指令的定義
		  compileCode("ret")			// 編譯 ret 為 高階指令 內碼
		  compiling=0				// 高階指令 編譯狀態 結束
		  var src=tib.substring(hSrc,iTib)	// 源碼字串
		  newWrd(hName,hXt,src)		// 以 名稱 內碼起點 原碼字串 定義 高階指令
		} end-code compileOnly immediate	// 使 ; 在高階編譯狀態 才編碼 能執行
		code + function () { // 定義 指令 + ( a b -- a+b ) 加法 可為數字 或 字串
		  var x=dStk.pop(); dStk[dStk.length-1]+=x
		} end-code
		code - function () { // 定義 指令 - ( a b -- a-b ) 減法
		  var x=dStk.pop(); dStk[dStk.length-1]-=x
		} end-code
		code * function () { // 定義 指令 * ( a b -- a*b ) 乘法
		  var x=dStk.pop(); dStk[dStk.length-1]*=x
		} end-code
		code / function () { // 定義 指令 / ( a b -- a/b ) 除法
		  var x=dStk.pop(); dStk[dStk.length-1]/=x
		} end-code
		code % function () { // 定義 指令 % ( a b -- a%b ) 餘數
		  var x=dStk.pop(); dStk[dStk.length-1]%=x
		} end-code
		code . function () { // 定義 指令 . ( n -- ) 列印 n 可為 數字, 字串, 陣列
		  print(" "+dStk.pop())
		} end-code
		code dup function () { // 定義 指令 dup ( n -- n n )
		  dStk.push(dStk[dStk.length-1])
		} end-code
		code .s function () { // 定義 指令 .s ( -- ) 檢視 堆疊數值
		  print(' '+(dStk.join(' ')||'empty'))
		} end-code
		code wrds function () { // 定義 wrds 檢視 所有 指令名稱 (可能重複)
		  var v=vocs[context[0]]
		  print('\n '+v.wrds.map(	// 從 wrds 陣列 針對每個指令 w
			function(w){return w?w.name:''}	// 取其 名稱
		  ).join(' '))			// 列印
		} end-code
		wrds // 檢視 所有 指令名稱
		code uniquewrds function () { // 定義 uniquewrds 檢視 所有 指令名稱 (不重複)
		  var v=vocs[context[0]], t='\n ', w
		  for(w in v.index)	// 從 index 物件 針對每個指令 w
			t+=' '+w			// 採用	空格 區隔
		  print(t)			// 列印
		} end-code
		uniquewrds // 檢視 所有 指令名稱 (不重複)
		: sq	// 定義 sq 計算 堆頂數值 的平方
		  dup	// 複製	堆頂數值
		  *	// 相乘
		;	// 結束	定義
		5 sq .	// 列印出 5 平方 ==> 25
		' alias alias 同義
		' sq 同義 平方
		' .  同義 印出
		5 平方 印出
		: 2sq	// 定義 2sq 計算 堆頂數值 平方的 2 倍
		  sq	// 計算	堆頂數值 的平方
		  2 *	// 取其	2 倍
		;	// 結束	定義
		3 2sq . // 列印出 3 平方的2倍 ==> 18
		' 2sq 同義 平方的2倍
		3 平方的2倍 印出
		
		code char function () { // 定義 char 取隨後 token 字串的 起首字符
		  var c=nxtTkn().substr(0,1)	// 隨後	token 的 起首字符
		  if(compiling)			// 檢視	是否 編譯狀態
			compileCode('doLit',c)	// 若是	編譯狀態 就將 doLit 及 字符 編碼
		  else dStk.push(c)		// 否則	就將 字符 放上堆疊
		} end-code immediate		// 宣告	char 編譯狀態 能執行
		char a .	// 列印	字符 a
		: a char a . ;	// 定義	a 列印出 字符 a
		a		// 列印	字符 a
		code see function () { // 定義 see 檢視 指定名稱 指令 的定義源碼
		  var msg		// 輸出	字串
		  var name=nxtTkn()	// 隨後	token 當作 指令名稱
		  var z=fndWrd(name)
		  if (z) {		// 檢視	記錄 id 的陣列 是否存在
			z=z.split(',').map(function(x){return parseInt(x)})
			var v=vocs[z[0]], w=v.wrds[z[1]] // 取其 word
			if (w.src)		// 檢視	高階定義源碼 是否存在
			msg=':'+w.src	// 若是	輸出字串 用 高階定義源碼
			else
			msg='code '+name// 否則	字串 接 指令名稱
			+' '+w.xt	//	字串 接 低階定義源碼
			+' end-'	//	字串 接 'end-'
			+'code'		//	字串 接 'code'
			if (w.compileOnly)	// 檢視	是否 compileOnly
			  msg+=' compileOnly'	// 字串	加接 compileOnly
			if (w.immediate  )	// 檢視	是否 immediate
			  msg+=' immediate'		// 字串	加接 immediate
		  } else
			  msg=name+' undefined'	// 字串	顯示 未定義
		  print('\n'+msg)		// 列印	字串
		} end-code
		see see	// 檢視 指令 see 的定義源碼
		see a	// 檢視 指令 a   定義源碼
		see 2sq	// 檢視 指令 2sq 的定義源碼
		see ;	// 檢視 指令 ;   的定義源碼
		code (abort") function () {
		  abort(compiledCode[ip++])
		} end-code compileOnly
		code abort" function () {
		  var msg=nxtTkn('"')
		  if (compiling) compileCode('(abort")',msg)
		  else abort(msg)
		} end-code compileOnly immediate
		// abort" 1st testing the word abort"
		// : x abort" 2nd testing the word abort" ; x
		code function xxx (x) { // 定義 javascript function xxx (並非 定義 指令 xxx)
		  print(x+' is running')
		} end-code
		// see xxx	// 檢視 字串 xxx 的定義源碼 ==> undefined
		code yyy function () {	// 定義 指令 zzz
		  VM.xxx(' yyy')		// 呼叫 javascript function xxx (帶 參數)
		} end-code
		yyy // 呼叫 javascript function xxx(' yyy') 印出 'yyy is running'
		code (do) function () { // ( bgn lmt -- )
		  var bgn=dStk.pop()
		  rStk.push(dStk.pop()), rStk.push(bgn)
		} end-code compileOnly
		code (loop) function () {
		  var t=rStk.length-1, s=t-1
		  if (rStk[s]>++rStk[t]) {
			ip=compiledCode[ip]
			return
		  }
		  ip++, rStk.pop(), rStk.pop()
		} end-code compileOnly
		code do function () {
		  compileCode('(do)')
		  dStk.push(compiledCode.length)
		} end-code immediate compileOnly
		code loop function () {
		  compileCode('(loop)',dStk.pop())
		} end-code immediate compileOnly
		code r@ function () {
		  dStk.push(rStk[rStk.length-1])
		} end-code
		' r@ alias i
		code j function () {
		  dStk.push(rStk[rStk.length-3])
		} end-code
		code (.") function () {
		  print(compiledCode[ip++])
		} end-code compileOnly
		code ." function () {
		  compileCode('(.")',nxtTkn('"'))
		} end-code compileOnly immediate
		code emit function () { // ( charCode -- )
		  var p=RegExp(String.fromCharCode(60),g)
		  print( String.fromCharCode(dStk.pop()).replace(p,'&lt;') )
		} end-code
		code cr function () {
		  cr()
		} end-code
		code drop function () { // ( n -- )
		  dStk.length--
		} end-code
		code .r function () { // ( n w -- )
		  var w=dStk.pop(), s=dStk.pop().toString(base)
		  print('         '.substr(0,w-s.length)+s)
		} end-code
		: x1 ." 9*9 table using do-loop"
		  10 1
		  do cr 10 1
			 do j i * 3 .r
			 loop
		  loop
		;
		x1
		code >r function () {
		  rStk.push(dStk.pop())
		} end-code compileOnly
		code r> function () {
		  dStk.push(rStk.pop())
		} end-code compileOnly
		code for function () {
		  compileCode('>r'), dStk.push(compiledCode.length)
		} end-code compileOnly immediate
		code (next) function () {
		  var rTop=--rStk[rStk.length-1]
		  if (0>rTop) {
			ip++, rStk.length--
			return
		  }
		  ip=compiledCode[ip]
		} end-code compileOnly
		code next function () {
		  compileCode('(next)',dStk.pop())
		} end-code compileOnly immediate
		: x2 ." 9*9 table using for-next" 8
		  for 9 r@ - cr 8
			  for dup 9 r@ - * 3 .r
			  next drop
		  next
		;
		x2
		code zbranch function () {
		  if (dStk.pop()) ip++
		  else ip=compiledCode[ip]
		} end-code compileOnly
		code branch function () {
		  ip=compiledCode[ip]
		} end-code compileOnly
		code if function () {
		  compileCode('zbranch')
		  dStk.push(compiledCode.length)
		  compile(-1)
		} end-code compileOnly immediate
		code else function () {
		  compiledCode[dStk.pop()]=compiledCode.length+2
		  compileCode('branch')
		  dStk.push(compiledCode.length)
		  compile(-1)
		} end-code compileOnly immediate
		code then function () {
		  compiledCode[dStk.pop()]=compiledCode.length
		} end-code compileOnly immediate
		: x3 dup . ."  is "
		  if ." non-"
		  then ." zero" ;
		0 x3
		5 x3
		: x4 dup . ."  is "
		  if ." non-zero"
		  else ." zero"
		  then ;
		0 x4
		5 x4
		code begin function () {
		  dStk.push(compiledCode.length)
		} end-code compileOnly immediate
		' ret alias exit
		code again function () {
		  compileCode('branch',dStk.pop())
		} end-code compileOnly immediate
		code until function () {
		  compileCode('zbranch',dStk.pop())
		} end-code compileOnly immediate
		code while function () {
		  compileCode('zbranch')
		  dStk.push(compiledCode.length)
		  compile(-1)
		} end-code compileOnly immediate
		code repeat function () {
		  var w=dStk.pop()
		  compileCode('branch',dStk.pop())
		  compiledCode[w]=compiledCode.length
		} end-code compileOnly immediate
		' ret alias exit
		code 1- function () {
		  dStk[dStk.length-1]--
		} end-code
		code 2- function () {
		  dStk[dStk.length-1]-=2
		} end-code
		code 1+ function () {
		  dStk[dStk.length-1]++
		} end-code
		code 2+ function () {
		  dStk[dStk.length-1]+=2
		} end-code
		code ?dup function () {
		  var top=dStk[dStk.length-1]
		  if (top)
			dStk.push(top)
		} end-code
		code changeName function () {
		  var v=vocs[current], ws=v.wrds
		  ws[ws.length].name=nxtTkn()
		} end-code
		code xxx function () {
		  var top=dStk.pop()
		  dStk[dStk.length-1]=top>dStk[dStk.length-1]
		} end-code
		: x5 9
		  begin ?dup
		  while dup . 1-
		  repeat ;
		x5 // 印出 9 8 7 6 5 4 3 2 1
		code $" function () { // 定義 $"  取源碼字串直到 "
		  var s=nxtTkn('"')
		  if (compiling) compileCode('doLit',s)
		  else dStk.push(s)
		} end-code
		$" abc" $" def" + . // 印出 abcdef
		code = function () {
		  dStk.push(dStk.pop()===dStk.pop())
		} end-code
		: x6 9 begin dup . 1- dup -1 = until ;
		x6 // 印出 9 8 7 6 5 4 3 2 1 0

		// ////////////////////////// basic01 ////////////////////////////
		code . function(){ // [0,4] . ( n -- ) 從堆疊 取出 n 列印
		// ////////////////////////////////////////////////////////////////////////
		// 注意 系統啟動時 只認得指令 code, 這 code 可定義隨後 任意字串 為新指令		//
		// 隨後直到 end-code 前的字串 為 這新指令 所要執行的 匿名 js function		//
		// 雙斜線後 直到列尾的文字 是 js function 的 內部註解語法, 不能在外部使用		//
		// 首列 [0,4] 表示 所定義的 指令位址 為 vocs[0].wrds[4] 可簡寫為 0,4		//
		// 首列 圓括號內雙減號語法 表示 執行 這指令 前後的 堆疊狀況 (從堆疊 取出 n 列印)	//
		// 這裡 從堆疊取的 n 可為 字串、浮點數、整數, 而 整數 還可用 不同進制 印出		//
		// end-code 之後 1 2 3 . . . 表示 依序 輸入 3 個整數 後 連續執行 3 次 印出	//
		// 注意 先印出的 應該是 3, 然後 印出 2, 最後印出的 是 1				//
		// ////////////////////////////////////////////////////////////////////////
		  var n=dStk.pop(); print(' '+(n%1===0 && base!==10 ? n.toString(base) :n))
		  // //////////////////////////////////////////////////////////////////////
		  // dStk 為 資料堆疊, n%1===0 檢視 n 是否整數, base 為 整數 解讀/列印 進制基數
		  // print 先印出 空格 再印出 n (若)
		  // //////////////////////////////////////////////////////////////////////
		} end-code
		1 2 3 . . .
		code + function(){ // [0,5] + ( a b -- c ) 堆疊 取出 a b 相加 將結果 c 放回
		// ////////////////////////////////////////////////////////////////////////
		// end-code 之後 1 2 3 + + . 會將 2 3 相加 然後將 1 5 相加 最後印出 6
		// ////////////////////////////////////////////////////////////////////////
		  var b=dStk.pop(); dStk[dStk.length-1]+=b
		} end-code
		1 2 3 + + .
		code $" function(){ // [0,6] $" ( <str>" -- s ) 空格後到 " 前字串 s 放堆疊
		// ////////////////////////////////////////////////////////////////////////
		// end-code 之後 $" abc" $" def" + . 會將 字串 abc 與 def 相加 印出 abcedf
		// ////////////////////////////////////////////////////////////////////////
		  dStk.push(nxtTkn('"'))
		} end-code
		$" abc" $" def" + .
		code - function(){ // [0,7] - ( a b -- c ) 堆疊 取出 a b 相減 將結果 c 放回
		// ////////////////////////////////////////////////////////////////////////
		// end-code 之後 15.5 2.5 - . 會 印出 13
		// ////////////////////////////////////////////////////////////////////////
		  var n=dStk.pop(); dStk[dStk.length-1]-=n
		} end-code
		15.5 2.5 - .
		code * function(){ // [0,8] * ( a b -- c ) 堆疊 取 a b 相乘 將結果 c 放回
		// ////////////////////////////////////////////////////////////////////////
		// end-code 之後 10 3 * . 會 印出 30
		// ////////////////////////////////////////////////////////////////////////
		  var n=dStk.pop(); dStk[dStk.length-1]*=n
		} end-code
		10 3 * .
		code / function(){ // [0,9] / ( a b -- c ) 堆疊 取 a b 相除 將結果 c 放回
		// ////////////////////////////////////////////////////////////////////////
		// end-code 之後 10 3 / . 會 印出 3.3333333333333335
		// ////////////////////////////////////////////////////////////////////////
		  var n=dStk.pop(); dStk[dStk.length-1]/=n
		} end-code
		10 3 / .
		code % function(){ // [0,10] % ( a b -- c ) 對 a 取 b 的餘數 結果 為 c
		// ////////////////////////////////////////////////////////////////////////
		// end-code 之後 10 3 / . 會 印出 30
		// ////////////////////////////////////////////////////////////////////////
		  var n=dStk.pop(); dStk[dStk.length-1]%=n
		} end-code
		13 3 % .
		code hex function(){ // [0,11] hex ( -- ) 用 十六進制 解讀/列印 整數
		// ////////////////////////////////////////////////////////////////////////
		// end-code 之後 128 hex . 會將 十進制 的 128 用 十六進制 列印為 80
		// ////////////////////////////////////////////////////////////////////////
		  base=16
		} end-code
		128 hex .
		code decimal function(){ // [0,12] decimal ( -- ) 用 10 進制 解讀/列印 整數
		// ////////////////////////////////////////////////////////////////////////
		// end-code 之後 100 decimal . 會將 十六進制 的 100 用 十進制 列印為 256
		// ////////////////////////////////////////////////////////////////////////
		  base=10
		} end-code
		100 decimal .
		// ////////////////////////// basic02 ////////////////////////////
		1 2 3 . . .
		1 2 3 + + .
		$" abc" $" def" + .
		15.5 2.5 - .
		10 3 * .
		10 3 / .
		13 3 % .
		128 hex .
		100 decimal .
		// ////////////////////////// jsFunctionTest ////////////////////////////
		code function yyy(msg) {
		  print(msg)
		} end-code
		code xxx function() {
		  VM.yyy(' hello') ///// 注意前置 VM.
		} end-code
		xxx
		code swap function(){ 
		  var b=dStk.pop(), a=dStk.pop();
		  dStk.push(b);
		  dStk.push(a);
		} end-code
		code precise-time(mS) function(){dStk.push((new Date()).getTime())} end-code
		: speed-test 0 swap for 1+ next ;
		code space function(){type(" ")} end-code
		precise-time(mS) 1000000 speed-test . space precise-time(mS) swap - . 
		
	</text>  js: g.vm.exec(pop()) \s				
		// ////////////////////////// vocTest ////////////////////////////
		code immediate function () {	// 定義 指令 immediate
		  lstWrd.immediate=1		// 使 最後定義的指令 在高階編譯狀態 能執行
		} end-code
		code // function () { var n,t	// 定義 指令 // (雙斜線) 忽略源碼字串到 列尾
		  iTib += at(tib.substr(iTib),'\n')
		} end-code immediate		// 使 雙斜線 指令 在高階編譯狀態 能執行
		// /////////// wrds preload ( include previous 2 wrds /////////////// //
		code debug function() {	// 定義 指令 debug ( <指令名稱> -- )
		  var tkn=nxtTkn()	// 從 隨後源碼 取 tkn (以空格區隔的下一個字串)
		  var z=fndWrd(tkn)	// 取 所對應 指令位址 [vid,wid]
		  if (z) {
			if (0>debugged.indexOf(z=z.join())) // 如果 不在 待追蹤指令陣列
			  debugged.push(z)			// 將 指令位址 加入 待追蹤指令陣列
			else
			  print(z+' already in debugged')	// 已在 待追蹤指令陣列
		  } else
			  abort('debug '+tkn+' undefined')// 沒有 所對應 符式指令 資訊
		} end-code
		code ' function () { // 定義 指令 ' ( <指令名稱> -- 指令位址 )
		  var z, t
		  var z=fndWrd(t=nxtTkn())	// 取 隨後源碼 指令名稱 的 指令位址 z
		  if (z) dStk.push(z)		// 若找到 z 就放上堆疊
		  else abort(t+' not found')	// 否則 就 abort
		} end-code
		code alias function () { // 定義 指令 alias ( 指令位址 <指令別名> -- )
		  var w=zWrd(dStk.pop())	// 取 已定義指令 w
		  newWrd(nxtTkn(),w.xt)	// 定義 隨後源碼 指令別名
		  if (w.src)         lstWrd.src	 	=w.src		// 高階源碼
		  if (w.compileOnly) lstWrd.compileOnly	=w.compileOnly	// 在高階編譯狀態 才執行
		  if (w.immediate)   lstWrd.immediate	=w.immediate	// 在高階編譯狀態 能執行
		  if (w.wrds)       lstWrd.wrds	=w.wrds	// 詞彙指令陣列
		  if (w.index)  lstWrd.index	=w.index	// 詞彙指令索引
		} end-code
		' // alias \
		code words function(){ // 定義 指令 wrds ( -- ) 列印 當前詞彙 所有 指令名稱
		  var v=vocs[context[0]]
		  print('\nin '+v.name+' have wrds:\n '+v.wrds.map(	// 列印 每個指令
			function(w){return w?w.name:''}			// 其 名稱
		  ).join(' '))						// 以 空格 區隔
		} end-code
		code : function () { // 定義 指令 : ( <指令名稱> -- ) 開始 高階指令的定義
		  src		= ''			// 高階指令 源碼
		  hSrc		= iTib-2		// 高階指令 源碼字串起點
		  hName		= nxtTkn()		// 高階指令 名稱
		  hXt		= compiledCode.length 	// 高階指令 編碼起點
		  compiling	= 1			// 高階指令 編譯狀態 進入
		} end-code
		code compileOnly function () { // 定義 指令 compileOnly ( -- )
		  lstWrd.compileOnly=1		// 使 最後定義指令 高階編譯狀態 才編碼
		} end-code
		code ret function () { // 定義 指令 ret ( -- ) 結束被呼叫的 高階指令
		  ip=rStk.pop()		// 從 return stack 取出 ip
		} end-code compileOnly	// 使 ret 在高階編譯狀態 才編碼
		code doLit function () { // 定義 指令 doLit ( -- n ) 將 隨後編碼 n 放上堆疊
		  var n=compiledCode[ip++]	// 取 ip 所指 編碼 n
		  dStk.push(n)			// 將 n 放上堆疊
		} end-code compileOnly		// 使 doLit 在高階編譯狀態 才編碼
		code ; function () { // 定義 指令 ; ( -- ) 結束 高階指令的定義
		  compileCode("ret")			// 編譯 ret 為 高階指令 內碼
		  compiling=0				// 高階指令 編譯狀態 結束
		  var src=tib.substring(hSrc,iTib)	// 源碼字串
		  newWrd(hName,hXt,src)		// 以 名稱 內碼起點 原碼字串 定義 高階指令
		} end-code compileOnly immediate	// 使 ; 在高階編譯狀態 才編碼 能執行
		// //////////////////////// vocabulary test ////////////////////////// //
		code vocabulary function(){ var v, i, vid, w
		  v=vocs[current], i=v.wrds.length, vid=vocs.length
		  newWrd(nxtTkn(),eval('(function(){context[0]='+vid+'})')) // add new word
		  w=v.wrds[i], w.vid=vid, w.wrds=[0], w.index={}
		  vocs.push(w) // add new vocabulary
		} end-code immediate
		code definitions function(){
		  current=context[0]
		} end-code
		code also function () {
		  context.unshift(context[0])
		} end-code
		code previous function () {
		  context.shift()
		} end-code
		vocabulary voc1 // 定義 詞彙 voc1
		vocabulary voc2 // 定義 詞彙 voc2
		vocabulary voc3 // 定義 詞彙 voc3
		voc1 definitions
		code a1 function () {
		  print(' a1 in voc1')
		} end-code
		code b1 function () {
		  print(' b1 in voc1')
		} end-code
		code c1 function () {
		  print(' c1 in voc1')
		} end-code
		voc2 definitions
		code a22 function () {
		  shwWrn(' a22 in voc2')
		} end-code
		code b22 function () {
		  shwWrn(' b22 in voc2')
		} end-code
		code c22 function () {
		  shwWrn(' c22 in voc2')
		} end-code
		voc3 definitions
		code a333 function () {
		  shwErr(' a333 in voc3')
		} end-code
		code b333 function () {
		  shwErr(' b333 in voc3')
		} end-code
		code c333 function () {
		  shwErr(' c333 in voc3')
		} end-code
		voc1 words
		voc2 words
		voc3 words
		voc2 definitions
		code a1 function () {
		  shwWrn(' a1 in voc2')
		} end-code
		voc1 a1 also
		voc2 b22 a1
		voc3 c333 a1
		previous voc3 a1
		// ////////////////////////// multiTask ////////////////////////////
		code immediate function(){// 定義 指令 immediate		( -- )
		  lstWrd.immediate=1			// 使 最後定義的指令 在高階編譯狀態 能執行
		} end-code
		code compileOnly function(){// 定義 指令 compileOnly	( -- )
		  lstWrd.compileOnly=1			// 使 最後定義的指令 在高階編譯狀態 才執行
		} end-code
		code // function(){ var n,t// 定義 指令 // (雙斜線) 忽略源碼字串到 列尾
		  iTib += (n= (t=tib.substr(iTib)).indexOf('\n') )>=0 ? n : t.length
		} end-code immediate			// 使 雙斜線 指令 在高階編譯狀態 能執行
		// ////////////////////////////////////////////////////////////////////////
		code : function(){// 定義 指令 : ( <指令名稱> -- ) 開始 高階指令的定義
		  src		= ''			// 高階指令 源碼
		  hSrc		= iTib-2		// 高階指令 源碼字串起點
		  hName		= nxtTkn()		// 高階指令 名稱
		  hXt		= compiledCode.length 	// 高階指令 編碼起點
		  compiling	= 1			// 高階指令 編譯狀態 進入
		} end-code
		code ret function(){// 定義 指令 ret ( -- ) 結束被呼叫的 高階指令
		  ip=rStk.pop()				// 從 return stack 取出 ip
		} end-code compileOnly			// 使 ret 在高階編譯狀態 才編碼
		code ; function () {			// 定義 指令 ; ( -- ) 結束 高階指令的定義
		  compileCode("ret")			// 編譯 ret 為 高階指令 內碼
		  compiling=0				// 高階指令 編譯狀態 結束
		  var src=tib.substring(hSrc,iTib)	// 源碼字串
		  newWrd(hName,hXt,src)			// 以 名稱 內碼起點 原碼字串 定義 高階指令
		} end-code compileOnly immediate	// 使 ; 在高階編譯狀態 才編碼 能執行
		// ////////////////////////////////////////////////////////////////////////
		code directOut function(){
		  VM.directOut.checked=true
		} end-code
		code bufferOut function(){
		  VM.directOut.checked=false
		} end-code
		code start function(){//( <指令> -- )// 隨後 高階指令 設為要起動的 工作
		  time0=new Date()
		  VM.directOut.checked=true
		  while(z=fndWrd( nxtTkn() )) { 	// 搜尋指令位址 z
			tsks.push(z)
			var w=zWrd(z) 			// 取得指令資訊 w
			if (w.src) { 			// 若是 高階指令
			   setTimeout(eval(
			  '(function(){resumeTask('+	// 以 resumeTask 為 起動涵式
			  JSON.stringify({
				 rStk:[ip],dStk:[],z:z,ip:w.xt// 設定 起動工作 所需資訊
			  })+')})'
			   ),10), waiting=1			// 10 毫秒後起動
			   if (tracing)			// 若要顯示 追蹤檢視資訊
				  print('\n'+digits(new Date()-time0,6)+' set to resumeTask '
					 +z+' '+w.name+' '+w.xt+' after 10 ms')
			} else
			   abort(z+' '+w.name+' not high level to start')
		  }
		} end-code
		code function ms(n){
		  var z=compiledCode[ip++]		// 從 隨後內碼 取 指定位址
		  setTimeout(eval(
			 '(function(){resumeTask('+		// 以 resumeTask 為 起動涵式
			 JSON.stringify({
				rStk:rStk,dStk:dStk,z:z,ip:ip	// 設定 接續工作 所需資訊
			 })+')})'
		  ),n), waiting=1			// n 毫秒後起動
		  if (tracing)				// 若要顯示 追蹤檢視資訊
			 print('\n'+digits(new Date()-time0,6)+' set to resumeTask '
				  +z+' '+zWrd(z).name+' '+ip+' after '+n+' ms')
		} end-code
		code function resumeAt(t){
		  n = t-(new Date()-time0)
		  var z=compiledCode[ip++]		// 從 隨後內碼 取 指定位址
		  setTimeout(eval(
			 '(function(){resumeTask('+		// 以 resumeTask 為 起動涵式
			 JSON.stringify({
				rStk:rStk,dStk:dStk,z:z,ip:ip	// 設定 接續工作 所需資訊
			 })+')})'
		  ),n), waiting=1			// n 毫秒後起動
		  if (tracing)				// 若要顯示 追蹤檢視資訊
			 print('\n'+digits(new Date()-time0,6)+' set to resumeTask '
				  +z+' '+zWrd(z).name+' '+ip+' at '+t+' ms')
		} end-code
		code (resumeAt) function(){ //( t -- )
		  VM.resumeAt( dStk.pop() )
		} end-code compileOnly
		code resumeAt function(){ //( t -- )// 暫停工作 (n 毫秒後接續執行 iTib 所指 隨後源碼)
		  if (compiling) {			// 若是 編議狀態
			 compileCode('(resumeAt)',		// 將 (ms) 編為內碼
				current+','+
				vocs[current].wrds.length	// 當前正定義的指令 隨後 也編為內碼
			 ); return
		  }
		  var n=dStk.pop()-( new Date()-time0 )	// 從 堆頂 取出 t 計算 n
		  setTimeout(eval(
			 '(function(){resumeExec('+		// 以 resumeExec 為 起動涵式
			 iTib+')})'				// 設定 接續工作 源碼位址
		  ),n), waiting=1			// n 毫秒後 接續
		  if (tracing)				// 若要顯示 追蹤檢視資訊
			 print('\n'+digits(new Date()-time0,6)+' set to resumeExec '
				  +iTib+' after '+n+' ms')
		} end-code immediate
		code (ms) function(){ //( n -- )// 暫停工作 (n 毫秒後 接續執行 ip 所指 隨後內碼)
		  VM.ms( dStk.pop() )
		} end-code compileOnly
		code ms function(){ //( n -- )// 暫停工作 (n 毫秒後接續執行 iTib 所指 隨後源碼)
		  if (compiling) {			// 若是 編議狀態
			 compileCode('(ms)',		// 將 (ms) 編為內碼
				current+','+
				vocs[current].wrds.length	// 當前正定義的指令 隨後 也編為內碼
			 ); return
		  }
		  var n=dStk.pop()			// 從 堆頂 取出 n
		  setTimeout(eval(
			 '(function(){resumeExec('+		// 以 resumeExec 為 起動涵式
			 iTib+')})'				// 設定 接續工作 源碼位址
		  ),n), waiting=1			// n 毫秒後 接續
		  if (tracing)				// 若要顯示 追蹤檢視資訊
			 print('\n'+digits(new Date()-time0,6)+' set to resumeExec '
				  +iTib+' after '+n+' ms')
		} end-code immediate
		// ////////////////////////////////////////////////////////////////////////
		code (for) function(){
		  rStk.push(dStk.pop())
		} end-code
		code for function(){
		  compileCode('(for)'), dStk.push(compiledCode.length)
		} end-code compileOnly immediate
		code (next) function () {
		  if ( 0 > (--rStk[rStk.length-1]) )
			 ip++, rStk.length--
		  else
			 ip=compiledCode[ip]
		} end-code compileOnly
		code next function () {
		  compileCode('(next)',dStk.pop())
		} end-code compileOnly immediate
		code r@ function () {
		  dStk.push(rStk[rStk.length-1])
		} end-code
		code doLit function(){// 定義 指令 doLit ( -- n ) 將 隨後內碼 n 放上堆疊
		  var n=compiledCode[ip++]	// 取 ip 所指 內碼 n
		  dStk.push(n)			// 將 n 放上堆疊
		} end-code compileOnly		// 使 doLit 在高階編譯狀態 才編碼
		code + function(){
		  var x=dStk.pop(); dStk[dStk.length-1]+=x
		} end-code
		code - function(){
		  var x=dStk.pop(); dStk[dStk.length-1]-=x
		} end-code
		code * function(){
		  var x=dStk.pop(); dStk[dStk.length-1]*=x
		} end-code
		code $" function(){// 定義 $"  取源碼字串直到 " (雙引號)
		  var s=nxtTkn('"')
		  if (compiling) compileCode('doLit',s)
		  else dStk.push(s)
		} end-code immediate
		code . function(){// 定義 . ( n -- ) 印出 堆頂 數字 或 字串
		  print(' '+dStk.pop())
		} end-code
		code (.) function(){// 定義 (.) 列印 隨後內碼
		  print(compiledCode[ip++])
		} end-code compileOnly
		code ." function(){// 定義 ." 列印源碼字串直到 " (雙引號)
		  var s=nxtTkn('"')
		  if (compiling)
			 compileCode('(.)',s)
		  else print(s)
		} end-code immediate
		code cr function(){// 定義 cr 印出 列尾
		  print('\n')
		} end-code
		// ////////////////////////////////////////////////////////////////////////
		code debug function(){ //( <指令名稱> -- )// 追加 隨後指令名稱 到 待追蹤陣列
		  while(token=nxtTkn()){
			if (z=fndWrd(token)){
			   debugged.push(z)
			   print('\nadd '+token+' to debugged')
			} else
			   showErr('\n'+token+' undefined to debug')
		  }
		} end-code
		code unbug function(){//( <指令名稱> -- )	// 從 待追蹤陣列 刪除 隨後指令名稱
		  while(token=nxtTkn()){ var i
			if (i=debugged.indexOf(token)) {
			   debugged=debugged.slice(0,i).concat(debugged.slice(i+1))
			   print('\nremove '+token+' from debugged')
			} else
			   showErr('\n'+token+' not in debbuged')
		  }
		} end-code
		// ////////////////////////// multiTask1 ////////////////////////////
		: task1 2 for 3000 ms $" <1" r@ + $" >" + . next ."  <1Done>" ;
		: task2 1 for $" {2" r@ + $" }" + . 4000 ms next ."  {2Done}" ;
		task1 task2
		start task1 task2
		: taskA 7 for 8 r@ - 1000 * resumeAt $" [a" r@ + $" ]" + . next
		  ."  [aDone]" ;
		: taskB 3 for $" (b" r@ + $" )" + . 4 r@ - 2000 * resumeAt next
		  ."  (bDone)" ;
		dbg start taskA taskB
	