
	\ utf-8
	\ excel.f  Microsoft Office Excel automation by jeforth.3hta
	\ Excel 2013 developer reference           http://msdn.microsoft.com/en-us/library/office/ee861528.aspx
	\ "Application Object (Excel)"             http://msdn.microsoft.com/en-us/library/office/ff194565(v=office.15).aspx
	\ VBA Language Reference                   http://msdn.microsoft.com/en-us/library/bb190882(v=office.11).aspx
	\ Microsoft Excel Visual Basic Reference   http://msdn.microsoft.com/en-us/library/aa272254(v=office.11).aspx
	\ Excel constants, e.g. xlUp = -4162, can be found in AutoIt UDF source code excel.au3.
	
	include wsh.f

	s" excel.f"			source-code-header
	
	: see-excel 		( -- n ) \ List all excel.exe processes
						s" where name = 'ExCeL.ExE'" see-process ;
	: kill-excel 		( -- n ) \ Kill all excel.exe processes
						s" where name = 'ExCeL.ExE'" kill-them ;
						
	\ 先查有幾個 excel.application 在 running? 通常應該只有一個，如果是一個就用它, 如果超過一個
	\ 就警告, 如果沒有就開一個。 [x] 如果 excel 沒有 install 的情形要跳過。
	
	{} value excel.app 	// ( -- obj ) The Excel.Application object or undefined if no excel exists.
						see-excel ( count ) 
						js> tos()>1 [if] 
							." Warning: Multiple Excel.Application are running." *debug* Multiple-Excel-error>>> 
						[then]
						( count ) [if] 
							\ 用這行就錯了! <vb> On Error Resume Next:Set xl=GetObject("","excel.application"):kvm.push(xl)</vb> 會開出新 Excel.Application。
							<vb> On Error Resume Next:Set xl=GetObject(,"excel.application"):kvm.push(xl)</vb> \ 這行才是沿用既有的 Excel.Application。
						[else]
							<vb> On Error Resume Next:Set xl=CreateObject("excel.application"):kvm.push(xl)</vb>						
						[then] to excel.app \ 如果 excel 沒有 install 會是 undefined。
						
	excel.app [if] \ excel existing

	: activeCell		excel.app :> ActiveCell ; // ( -- obj ) Get the ActiveCell object
						/// activeCell :> offset(0,1).formula tib.
	: activeSheet		excel.app :> ActiveSheet ; // ( -- obj ) Get the ActiveSheet object
						/// activeSheet :> name tib.
	: activeWorkbook	excel.app :> ActiveWorkbook ; // ( -- obj ) Get the ActiveWorkbook object
						/// activeWorkbook :> name tib.	
	: selection 		excel.app :> selection ; // ( -- obj ) Get the selected object ( a range object )
						/// selection :> count tib.
						/// selection :: item(123).value="hello" 
	
						<selftest>
							***** excel.app is like a constant it gets you the app object ........
							( ------------ Start to do anything --------------- )
							excel.app js> pop().Application.Application.Application.Application.name \ How many .Application ? It doesn't matter. 
							( ------------ done, start checking ---------------- )
							js> stack.slice(0) <js> ["Microsoft Excel"] </jsV> isSameArray >r dropall r>
							-->judge [if] <js> [
								'excel.app'
							] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
						</selftest>

	: openFileDialog ( -- "pathname" ) \ Get a pathname string through excel dialog.
						excel.app :> GetOpenFilename() ;
						/// Result like : "C:\Users\8304018\Downloads\收支明細.xlsx" (string)
						/// See also "pickFile" command in HTML5.f that is same thing but IE interface.
						/// Ex. openFileDialog open.xls constant myWorkbook

						
	: excel.visible 	( -- ) \ Make the excel.app visible
						excel.app js> pop().visible=true drop ;

	: excel.invisible 	( -- ) \ Make the excel.app invisible
						excel.app js> pop().visible=false drop ;
						
						<selftest>
							*** excel.visible excel.invisible ... 
							excel.invisible
							excel.app js> pop().visible false = \ true
							excel.visible
							excel.app js> pop().visible \ true true
							and ==>judge  [if] <js> [
								'excel.visible',
								'excel.invisible'
							] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
						</selftest>

	: new.xls           ( -- WorkBook ) \ Create a new excel workbook file object
						excel.app js> pop().Workbooks.Add ;
						/// Excel workbook proterties: name, parent, path, fullname, .. etc.
						/// mathods: close(), save(), saveas() .. etc.
						
						<selftest>
							***** new.xls gets workbook file object ....
							( ------------ Start to do anything --------------- )
							new.xls constant WORKBOOK // ( -- obj ) excel workbook
							WORKBOOK js> typeof(pop().name) \ something like 活頁簿1 or Workbook1
							( ------------ done, start checking ---------------- )
							js> stack.slice(0) <js> ['string'] </jsV> isSameArray >r dropall r>
							-->judge [if] <js> [
								'new.xls'
							] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
						</selftest>

	code excel.save     ( workbook -- ) \ Save workbook object to excel file
						push(pop().save());
						end-code

	: excel.save-as		( "path-name" worksheet|workbook -- boolean ) \ Save to excel file with the given path-name
						excel.app js> tos().DisplayAlerts \ save ( "path-name" workbook excel.app DisplayAlerts )
						js: tos(1).DisplayAlerts=false  ( "path-name" workbook excel.app DisplayAlerts )
						js> pop(2).SaveAs(pop(2),-4143) \ /* xlWorkbookNormal office 97&2003 compatible */ ( excel.app DisplayAlerts result)
						js: pop(2).DisplayAlerts=pop(1) \ restore
						;
						/// always save-as Office 97&2003 compatible format
						
						<selftest>
							***** excel.save-as saves workbook to file ....
							( ------------ Start to do anything --------------- )
							char . full-path char _selftest_.xls + constant 'selftest.xls' // ( -- pathname )
							'selftest.xls' WORKBOOK excel.save-as \ true
							( ------------ done, start checking ---------------- )
							js> stack.slice(0) <js> [true] </jsV> isSameArray >r dropall r>
							-->judge [if] <js> [
								'excel.save-as'
							] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
						</selftest>

	code open.xls       ( "pathname" -- workbook ) \ Open excel file get workbook object
						fortheval("excel.app");
						push(pop().Workbooks.open(pop()));
						end-code
						/// Ex. openFileDialog open.xls constant myWorkbook
						/// 

	code excel.close	( workbook -- flag ) \ close the excel file without saving.
						push(pop().close(false));
						end-code
						
						<selftest>
							***** excel.close closes the workbook ....
							( ------------ Start to do anything --------------- )
							WORKBOOK excel.close \ true
							'selftest.xls' open.xls constant WORKBOOK // ( -- obj ) excel workbook re-opened
							( ------------ done, start checking ---------------- )
							js> stack.slice(0) <js> [true] </jsV> isSameArray >r dropall r>
							-->judge [if] <js> [
								'excel.close','open.xls','excel.save'
							] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
						</selftest>

	: excel.close-all	( -- ) \ Close all excel file without saving.
						excel.app dup js> pop().workbooks.count
						( excel.app count ) <js>
							for (var i=0; i<tos(); i++) tos(1).workbooks(1).close(false);
						</js>
						2drop ;

	: auto 				( -- ) \ Setup auto recalculation 
						excel.app :> calculation=-4105 ;
						/// Check state: excel.app :> calculation -4105(auto) -4135(manual)
						
	: manual 			( -- ) \ Setup manual recalculation 
						excel.app :: calculation=-4135 ;
						/// Check state: excel.app :> calculation -4105(auto) -4135(manual)					
						
	: repeat() 			( -- ) \ Like the Excel hotkey Ctrl-y does, repeat last operation.
						excel.app :: repeat ;
						
	: xl.sendkeys		( "1~2~3~^d{F9}" -- ) \ Send keys to [the active application] through excel
						excel.app :: SendKeys(pop(),true) ; \ wait until the keys got processed
						/// see https://msdn.microsoft.com/EN-US/library/office/ff821075.aspx?f=255&MSPPError=-2147217396
						/// +Shift ^Ctrl %Alt {BACKSPACE}or{BS},{BREAK},{CAPSLOCK},{CLEAR},{DELETE} or {DEL},
						/// {DOWN},{END},{ENTER},{ESCAPE} or {ESC},{F1}{F15},{HELP},{HOME},{INSERT},{LEFT},
						/// {NUMLOCK},{PGDN},{PGUP},{RETURN},{RIGHT},{SCROLLLOCK},{TAB},{UP},~(Enter)
						
	: offset			( x y -- object ) \ Get cell object by offset(y,x) to the activeCell
						excel.app :> ActiveCell.offset(pop(),pop()) ;
						/// See 'range' object https://msdn.microsoft.com/EN-US/library/office/ff820947.aspx 
						/// 1 0 offset :> formula .	
						/// -1 -1 offset :: clear 
						
	: cell				( x y -- object ) \ Get cell object by (x,y) of the activeSheet
						excel.app :> activeSheet :> cells(pop(),pop()) ;
						///  Ex. 1 3 cell :> value .
						
	: goto				( x y -- ) \ The activated cell jump to (x,y)
						cell :: activate() ;

	: up 				0 -1 offset :: activate ; // ( -- ) Move the activeCell up.
	: down 				0  1 offset :: activate ; // ( -- ) Move the activeCell down.
	: left 			   -1  0 offset :: activate ; // ( -- ) Move the activeCell left.
	: right				1  0 offset :: activate ; // ( -- ) Move the activeCell right.
	: column			activeCell :> column ; // ( -- column ) Get column number of the activeCell.
	: row				activeCell :> row ; // ( -- row ) Get row number of the activeCell.
	: address 			activeCell :> address ; // ( -- "address" ) Get $A$1 address of the activeCell.
	: formula			activeCell :> formula ; // ( -- "formula" ) Get formula of the activeCell.
	: cell@				activeCell :> value ; // ( -- value ) Read value of the activeCell.
	: cell!          	activeCell :: value=pop() ; // ( value -- ) Write value to the activeCell.
	: up@ 				0 -1 offset :> value ; // ( -- value ) Read the cell up to the activeCell.
	: down@ 			0  1 offset :> value ; // ( -- value ) Read the cell down to the activeCell.
	: left@ 		   -1  0 offset :> value ; // ( -- value ) Read the cell left to the activeCell.
	: right@			1  0 offset :> value ; // ( -- value ) Read the cell right to the activeCell.
	: empty?			formula boolean not ; // ( -- boolean ) Is the activeCell empty?
	: non-value?		( -- boolean ) \ Doesn't the activeCell have a normal value?
						activeCell :> value
						js> typeof(tos())=="unknown" 
						js> typeof(pop(1))=="undefined" 
						or ;
						/// activeCell :> value 的 typeof() 如果是 "unknown" 者是非標準的 object 不一定
						/// 是問題但我把它當成是; 如果是 "undefined" 則屬 空格 #N/A #DIV/0 #VALUE! 等。
						
	: ?cell@			( -- value T/F ) \ Read value of the activeCell with flag idicates it's not empty #N/A #DIV/0 .. etc.
						empty? if false exit then non-value? if false else activeCell :> value true then ;
						/// 本命令是帶有成敗判斷的取值命令。

	\ 這裡提供的 excel iteration 由【判斷】,【執行】,【移動】加上 cut..rewind 或 <task>..</tasK> 所構成。
	\ 以下是【判斷】的部分需要定義的命令：
	: @?stop 			?cell@ if drop else stop then ; // ( -- ) Stop if the activeCell is not value
						/// Example, 一路往下只要【當格】有值就把它抄到右邊去:
						/// @?stop ( 判斷 )
						/// activeCell 1 0 offset :: value=pop() ( do )
						/// down ( 移位 ) 1 nap rewind ( 重複 )
						/// 上下左右當格的【判斷】都依賴這些 cell 有值，不然就
						/// 要用 i?stop 用 selection 或用 empty? ?stop。
	: ^?stop 			up ?cell@ down if drop else stop then ; // ( -- ) Stop if the up Cell is not value
						/// Example, 只要【上面】一列有值就把他抄下來:
						/// ^?stop ( 判斷 )
						/// 0 -1 offset cell! ( do )
						/// right ( 移位 ) 1 nap rewind ( 重複 )
						/// 上下左右當格的【判斷】都依賴這些 cell 有值，不然就
						/// 要用 i?stop 用 selection 或用 empty? ?stop。
	: <?stop 			left ?cell@ right if drop else stop then ; // ( -- ) Stop if the left Cell is not value
						/// Example, 只要【左邊】一行有值就把他抄過來:
						/// <?stop ( 判斷 ) 
						/// -1 0 offset cell! ( do )
						/// down ( 移位 ) 1 nap rewind ( 重複 )
						/// 上下左右當格的【判斷】都依賴這些 cell 有值，不然就
						/// 要用 i?stop 用 selection 或用 empty? ?stop。
	: >?stop 			right ?cell@ left if drop else stop then ; // ( -- ) Stop if the right Cell is not value
						/// Example, 只要【右邊】一行有值就把他抄過來:
						/// >?stop ( 判斷 )
						/// 1 0 offset cell! ( do ) 
						/// down ( 移位 ) 1 nap rewind ( 重複 )
						/// 上下左右當格的【判斷】都依賴這些 cell 有值，不然就
						/// 要用 i?stop 用 selection。
	: v?stop 			down ?cell@ up if drop else stop then ; // ( -- ) Stop if the down Cell is not value
						/// Example, 只要【下面】一列有值就把他抄上來:
						/// v?stop ( 判斷 )
						/// 0 1 offset cell! ( do )
						/// right ( 移位 ) 1 nap rewind ( 重複 )
						/// 上下左右當格的【判斷】都依賴這些 cell 有值，不然就
						/// 要用 i?stop 用 selection 或用 empty? ?stop。
	: i?stop 			( 0 -- 1,2,... ) \ Activate next cell or Stop and drop the i at the end.
						1+ dup selection :> count > if drop stop 
						else selection :: item(tos()).activate() then ; 
						/// Example, print selected cells:
						/// 0 cut ( 前置準備 ) 
						/// i?stop ( 【判斷】兼【移位】,留下 i ) 
						/// cell@ . space ( do )
						/// 1 nap rewind ( 重複 )
						/// 上下左右當格的【判斷】都依賴這些 cell 有值，不然就
						/// 要用 i?stop 用 selection。
						
	code get-sheet      ( sheet#|"sheet" workbook -- sheet ) \ Get Excel worksheet object where sheet# is either sheet number or name
						push(pop().worksheets(pop())) // accept both sheet# or sheet name
						end-code
						/// Worksheets("Sheet1").Activate

						<selftest>
							***** get-sheet gets worksheet object ....
							( ------------ Start to do anything --------------- )
								1 WORKBOOK get-sheet constant SHEET // ( -- sheet ) playground worksheet object
											   SHEET js> typeof(pop().name)
								// 2 WORKBOOK get-sheet js> typeof(pop().name)
								// 3 WORKBOOK get-sheet js> typeof(pop().name)
							( ------------ done, start checking ---------------- )
							js> stack.slice(0) <js> ['string'] </jsV> isSameArray >r dropall r>
							-->judge [if] <js> [
								'get-sheet'
							] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
						</selftest>

	code get-range      ( "a1:b2" worksheet -- range ) \ get a range
						push(pop().range(pop()));
						end-code

						<selftest>
							***** get-sheet gets worksheet object ....
							( ------------ Start to do anything --------------- )
								char a1:c3 SHEET get-range constant RANGE // ( -- range ) a range in worksheet
								RANGE js> pop().count
							( ------------ done, start checking ---------------- )
							js> stack.slice(0) <js> [9] </jsV> isSameArray >r dropall r>
							-->judge [if] <js> [
								'get-range'
							] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
						</selftest>

	code get-cell       ( column row sheet -- cell ) \ Get cell object
						push(pop().Cells(pop(),pop()))
						end-code
						
						<selftest>
							***** get-cell gets cell object ....
							( ------------ Start to do anything --------------- )
								1 1 SHEET get-cell constant CELL // ( -- cell ) excel cell A1 object
								CELL js> pop().count
							( ------------ done, start checking ---------------- )
							js> stack.slice(0) <js> [1] </jsV> isSameArray >r dropall r>
							-->judge [if] <js> [
								'get-cell'
							] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
						</selftest>

	code bottom         ( Column -- row# ) \ Get the bottom row# of the column
						push(pop().rows(65535).end(-4162).row) // xlUp = -4162
						end-code
						/// It's too stupid that takes a lot of time if going along down to row#65535
						/// example: sheet char pop().range("B:B") js bottom tib. \ ==> 160 (number)

	: column#>letter 	1- char A (ASCII) + ASCII>char ; // ( col# -- letter ) Get column letter, only support A~Z.
	: letter>column# 	(ASCII) char A (ASCII) - 1+ ; // ( letter -- col# ) Get column number, only support 1~26.
	code init-hash      ( sheet "columnKey" "columnValue"-- Hash ) \ get hash table from key-value columns
						var columnValue = pop(), columnKey = pop(), sheet = pop();
						var key = sheet.range(columnKey  +":"+columnKey);
						var val = sheet.range(columnValue+":"+columnValue);
						push(key); fortheval("bottom"); var bottom = pop();
						for (var i=1, hash={}; i<=bottom; i++) {
							if (key(i).value == undefined ) continue;
							hash[key(i).value] = val(i).value;
						}
						push(hash);
						end-code
						/// 應用: 
						/// 先到 Data Sheet 取得 key-value hash table:
						///     activeSheet char b ( index ) char e ( data ) 
						///     init-hash ( hashDataTable )
						/// 然後到 target Sheet 把資料貼上去:
						///     ( hashDataTable ) activeSheet char b ( index ) char z 
						///     ( target ) 4 ( top row# ) hash>column

	code hash>column	( Hash Sheet "colKey" "colValue" top-row# -- ) \ Fill out the colValue by look up hash with colKey
						var top=pop(), colValue=pop(), colKey=pop(), sheet=pop(), hash=pop();
						var key = sheet.range(colKey  +":"+colKey);
						var val = sheet.range(colValue+":"+colValue);
						push(key); fortheval("bottom"); var bottom = pop();
						for (var i=top; i<=bottom; i++) {
							if (key(i).value == undefined ) continue;
							val(i).value = hash[key(i).value];
						}
						end-code
						/// 應用: 
						/// 先到 Data Sheet 取得 key-value hash table:
						///     activeSheet char b ( index ) char e ( data ) 
						///     init-hash ( hashDataTable )
						/// 然後到 target Sheet 把資料貼上去:
						///     ( hashDataTable ) activeSheet char b ( index ) char z 
						///     ( target ) 4 ( top row# ) hash>column

	code workbook>sheets
						( workbook -- array ) \ Get array of all sheet names in a workbook
						var target = pop(), count = target.sheets.count, aa = [];
						for(var i=1; i<=count; i++) aa.push(target.sheets(i).name);
						push(aa);
						end-code

	code list-workbooks ( -- count ) \ List all opened workbooks under excel.app
						execute("excel.app");
						var excelapp = pop(),
							count = 0;
						push(count = excelapp.workbooks.count); push(excelapp.name);
						fortheval(". .(  has ) . .(  opened workbooks at this moment.) cr");
						for (var i=1; i<=excelapp.workbooks.count; i++){
							push(excelapp.workbooks(i).name); push(excelapp.workbooks(i).path); push(i);
							fortheval("3 .r space . char \\ . . cr");
						}
						push(count);
						end-code
						/// run list-workbooks any time to see recent excel.app's workbooks.
	[then] \ excel.app exists

	<comment>
	\ ================ How to open an Excel file ============================================
	\
	\ Key points of automation Excel file accessing ,
	\ 1. Excel's working directory is user\document, not the DOS box working directory.
	\ 2. The path string delimiter \ must be \\ or it will be failed sometimes.
	\ 3. VBscript's GetObject("file.xls") is also available for HTA. GetObject("file2.xls"), 
	\	 and double click file.xls are all using the *active* "Excel.Application" object. Excel must 
	\	 be in memory before using GetObject().
	\
	\ Open excel file 有兩種方式，
	\
	\   1。 Create a new Excel.Application object
	\		<js> push(new ActiveXObject("Excel.application")) </js> constant excel.app 
	\		<vb> set kvm.excel.app = CreateObject(...)' </vb>
	\       excel.app :> Workbooks.open("x:\\cooked.xls");
	\
	\   2。 Use the existing instance of Excel.Application object
	\		<vb> set kvm.excel.app = GetObject(,"Excel.Application") </vb> 
	\		<vb> set kvm.excel.app = GetObject("file.xls") </vb>
	\       <vb> set kvm.excel.app = GetObject("x:\\raw.xls") </vb>
	\       <vb> set kvm.excel.app = GetObject("x:\\cooked.xls") </vb>
	\
	\ 前者的 excel.app 獨立於電腦內其他 "Excel.application" instances，重複 open 同一個檔案的問題很
	\ 難解決。Internet 上有很多人在問，問不出好答案。因為要搜出所有的 "Excel.application" instances
	\ 來處理，已經難過頭了。所以要用後者才好，重複 open 時 excel 自己會跳出來禁止。因為 automation
	\ 對 excel file 所用的 Excel.Application 與 double click open excel file 是同一 handler. 證明如
	\ 下,
	\
	\    raw.xls js> pop().application.workbooks.count tib. \ ==> 1 (number)  Good, it's raw.xls
	\    Now open a.xls manually by double click it, and check again workbooks.count,
	\    raw.xls js> pop().application.workbooks.count tib. \ ==> 2 (number)  Shoooo!!! Bin Bin Bingo!!!!
	\    raw.xls js> pop().application.workbooks(2).name tib. \ ==> A.XLS (string)
	\
	\ [ ]	GetObject() 的缺點是，當 Excel 不存在 memory 裡時會出 error:
	\		"JScript error : Automation 服务器不能创建对象" 這可以用 On Error Resume Next 來避免
	\		error 此時取得的是 undefined 十分完美。
	\ [ ]	excel.app js> pop().quit() 之後再 double click open 的 excel file 似乎會變成去
	\		用另一個 excel.application instance?
	\
	\ ====================== path delimiter is always a problem ===============================
	\
	\ path delimiter 用 \ 還是用 \\ 看來要視給誰而定！ Excel 2010 的 save-as 要的是 Microsoft 的 \ 而且
	\ 不能用 \\ 也不能用 /， Excel 2003 可以接受用 / 或 \\，而 WScript 的 GetObject() 要的是 \\ 而且不能
	\ 用 \，這真是混亂！ 所以只好準備 >path/ >path\ >path\\ 來適應各種情況。
	\
	\ workbook.save-as accepts only \ as its path delimiter.
	\
	\     OK s" C:\Users\8304018\Documents\Dropbox\learnings\Forth\jeforth\JScript\cooked-raw.xls" constant cooked-file
	\     reDef cooked-file OK cooked-file raw.xls save-as tib.
	\     cooked-file raw.xls save-as tib. \ ==> true (boolean)
	\     OK
	\
	\ workbook.save-as does not accept / as its path delimiter, there's a little problem.
	\
	\     s" C:/Users/8304018/Documents/Dropbox/learnings/Forth/jeforth/JScript/cooked-raw.xls" constant cooked-file
	\     cooked-file raw.xls save-as tib.
	\
	\         ------------------- P A N I C ! -------------------------
	\         JScript error on word save-as next IP is 0 : Microsoft Excel 無法存取檔案 'C:\//Users/8304018/Docume
	\         nts/Dropbox/learnings/Forth/jeforth/JScript/5EEE0F10'。可能原因如下:
	\
	\         ? 檔案的名稱或路徑不存在。
	\         ? 其他程式正在使用檔案。
	\         ? 您嘗試儲存的活頁簿名稱與目前開啟的活頁簿名稱相同。
	\         TIB:cooked-file raw.xls save-as tib.
	\
	\         Abort at TIB position 27
	\         -------  [Yes] go on  [No] js console [Cancel] Terminate  -------
	\         cooked-file raw.xls save-as tib. \ ==> Wistron resolved Price (string)
	\
	\ workbook.save-as does not accept \\ as its path delimiter.
	\
	\     s" C:\\Users\\8304018\\Documents\\Dropbox\\learnings\\Forth\\jeforth\\JScript\\cooked-raw.xls" constant cooked-file
	\     cooked-file raw.xls save-as tib.
	\
	\         ------------------- P A N I C ! -------------------------
	\         JScript error on word save-as next IP is 0 : 檔案無法存取。請確定下列幾件事是否正確:
	\
	\         ? 確定所指定的檔案夾是否存在。
	\         ? 確定檔案夾不是唯讀。
	\         ? 確定檔案名稱不包含下列字元:  <  >  ?  [  ]  :  |  或  *。
	\         ? 確定檔案及路徑名稱不超過 218 個位元組。
	\         TIB:cooked-file raw.xls save-as tib.
	\
	\         Abort at TIB position 27
	\         -------  [Yes] go on  [No] js console [Cancel] Terminate  -------
	\         cooked-file raw.xls save-as tib. \ ==> Component level (string)
	\
	\         OK cooked-file cr . cr
	\         C:\\Users\\8304018\\Documents\\Dropbox\\learnings\\Forth\\jeforth\\JScript\\cooked-raw.xls
	\         OK
	\
	\ ================== Access excel worksheet programmatically =====================
	\
	\ Excel automation 裡最重要的 object 是 Range. 其他 Cells, Rows, Columns 等都傳回該 Range 的各種
	\ sub-range。當 sub-range 只有一格時, 即 range.count == 1 時, 可當作 scalar 使用，雖然它
	\ 仍為 Range object 如下，
	\
	\	activeSheet :> range("d3")          \ ==>  學雜費 (object)
	\	activeSheet :> range("d3").cells    \ ==>  學雜費 (object)
	\	activeSheet :> range("d3").columns  \ ==>  學雜費 (object)
	\	activeSheet :> range("d3").rows     \ ==>  學雜費 (object)
	\
	\ 由於 Item 是 Range 物件的 default property 因此可以緊接著在 Range() 或 sub-range 後面指定 (index),
	\ (Yrow,Xcolumn) 等。 所以 cells(index) cells(Yrow,Xcolumn) columns(index) rows(index) 等，其實是 
	\ cells.item(index) cells.item(Yrow,Xcolumn) 等等的簡寫。而且 index, Yrow, Xcolumn 在 excel 都是
	\ 1 based (而非0 based, 這對 forth 的 for...next 有益。). Range().item() 又傳回 Range，固然是因為
	\ item() 可能是 rows, columns 等 range，即使是一格也仍然是 range object.
	\
	\ 以下前三者是一樣的東西，後一例透過 value property 取得同一個值，以下馬上會提到。
	\
	\	activeSheet :> range("AC3")                \ ==> 22 (object)
	\	activeSheet :> range("AC3")(1)             \ ==> 22 (object)
	\	activeSheet :> range("AC3").item(1)        \ ==> 22 (object)
	\	activeSheet :> range("AC3").item(1).value  \ ==> 22 (number) 只有這個是 scalar
	\
	\	activeSheet :> range("D3")(2)          \ ==> 16100 (object) 本身的 index 是 1
	\	activeSheet :> range("D3").cells(2)    \ ==> 16100 (object) 本身的 index 是 1
	\	activeSheet :> range("D3").rows(2)     \ ==> 16100 (object) 本身的 index 是 1
	\	activeSheet :> range("D3").offset(1,0) \ ==> 16100 (object) 以上 3 個都是這個意思，注意 type 都是 object 
	\	activeSheet :> range("D3").columns(2)  \ ==> 午餐費 (object) 本身的 index 是 1
	\	activeSheet :> range("D3").offset(0,1) \ ==> 午餐費 (object) 以上這個是這個意思，注意 type 都是 object 
	\
	\ 以下是 Range 不只一格的情形 (range.count != 1)， Range object 本身沒有可直接看到的東西了。
	\
	\	activeSheet :> range("AC3:AD4") \ ==>  (object)
	\
	\ index row column 等，給 Item() 的 input arguments 不受 Range().count 的限制，這樣才好用。
	\
	\   activeSheet :> range("C10")(0)       \ ==> C9 (object) index 0 變成是「上」一格，因為 1 based.
	\	activeSheet :> range("C10").item(0)  \ ==> C9 (object)
	\   activeSheet :> range("C10").cells(0) \ ==> C9 (object)
	\ [ ] hcchen5600 2015/06/03 23:42:59 先複習到這裡
	\    TARGET char pop().range("AC3:AD4")(1)         js tib. ==> 22 (object)
	\    TARGET char pop().range("AC3:AD4").cells(1)   js tib. ==> 22 (object)
	\
	\    TARGET char pop().range("AC3:AD4")(-1)        js tib. ==> 12 (object)
	\    TARGET char pop().range("AC3:AD4").cells(-1)  js tib. ==> 12 (object)
	\
	\ expression.value 傳回或設定指定範圍的值。可讀寫的 Variant (VBScript) 資料型態。 如果指定的 Range 物件
	\ 是空的，則為預設值，傳回 Empty 值 (VBScript IsEmpty, JavaScript 則為 null)。如果 Range 物件包含多個儲
	\ 存格，則會傳回的一個 VBArray 數值陣列 (使用 VBScript IsArray 函數可檢測， JScript 則為 unknown type)。
	\ 所以 value 傳回的不一定是一個值，除了正規地用 range.count 判斷以外，看到 type 是 unknown 時可斷定它是
	\ 個 VBArray。JScript can access VBArray through these methods :dimensions(), getItem(i), lbound(),
	\ ubound(), and toArray(), where toArray() makes it a JavaScript array.
	\
	\   TARGET char pop().range("AB2:AC4").value.toArray() js tib. ==> 11,21,31,12,22,32 (array)
	\
	\ 這兩行等效，
	\
	\   TARGET char pop().range("AC3:AD4").value.toArray() js tib.       ==> 22,32,, (array)
	\   TARGET char pop().range("AC3:AD4").cells.value.toArray() js tib. ==> 22,32,, (array)
	\
	\ 用 range.count 檢查是否一格，
	\
	\   TARGET char pop().range("AC3:AD4").cells(-1).count js tib. ==> 1 (number)
	\   TARGET char pop().range("AC3:AD4").count js tib.           ==> 4 (number)
	\
	\ 單一格時的 value 是 scalar 而沒有 toArray() 可用，
	\
	\   TARGET char pop().range("AC3:AD4").cells(-1).value.toArray() js tib.
	\
	\     ------------------- P A N I C ! -------------------------
	\     JScript error : 物件不支援此屬性或方法
	\     TIB:TARGET char pop().range("AC3:AD4").cells(-1).value.toArray() js tib.
	\     Abort at TIB position 63
	\     -------  [Yes] go on  [No] js console [Cancel] Terminate  -------
	\
	\ Excel Constant Definitions For VBScript And JScript (entire list in my evernote)
	\   xlDown         =-4121 ( xlDown         )
	\   xlToLeft       =-4159 ( xlToLeft       )
	\   xlToRight      =-4161 ( xlToRight      )
	\   xlUp           =-4162 ( xlUp           )
	\   xlShiftDown    =-4121 ( xlShiftDown    )
	\   xlShiftToRight =-4161 ( xlShiftToRight )
	\   xlShiftToLeft  =-4159 ( xlShiftToLeft  )
	\   xlShiftUp      =-4162 ( xlShiftUp      )
	\   xlExcel9795    =0x2b  ( 43 xlExcel9795 )      see workbook.fileformat , Office 2012 : 無法取得類別 Workbook 的 SaveAs 屬性
	\   xlWorkbookNormal =-4143 ( xlWorkbookNormal )  see workbook.fileformat
	\
	\ -------------- Background Color of a range -----------------------------
	\
	\ js>obj2.interior.colorindex=6 // Yellow background
	\ Returned value of the statement is : 6  (number)
	\
	\ colorjs>obj2.interior.colorindex=-4142  // No color background
	\ Returned value of the statement is : -4142  (number)
	\
	\ colorjs>obj2.cells(2,1).interior.colorindex=-4142
	\ Returned value of the statement is : -4142  (number)
	\

	\ -------------- 實驗室開門 -------------------------------------------------------------------------

	' mylab [if]
	  char . full-path char target.xls path+name constant target-file // ( -- string ) full path name
	  target-file open.xls constant target.xls // ( -- obj ) workbook
	  target.xls s" pop().fullname" js tib.
	  1 target.xls get-sheet constant TARGET // ( -- obj ) worksheet
	  TARGET char tos().name js tib.

	  char . full-path char WKSRDCODE.xls path+name constant WKSRDCODE-file  // ( -- string ) full path name string
	  WKSRDCODE-file open.xls constant WKSRDCODE.xls // ( -- obj ) workbook
	  WKSRDCODE.xls s" pop().fullname" js tib.
	  char CODE WKSRDCODE.xls get-sheet constant CODE // ( -- obj ) worksheet
	  CODE char pop().name js tib.

	  excel.app s" pop().Workbooks.count" js tib.
	  excel.app s" pop().Workbooks(1).fullname" js tib.
	  excel.app s" pop().Workbooks(2).fullname" js tib.
	  char tos().range("AB2:AC4").Cells.item(1,1).cells.item(1).value=11 js tib.
	  char tos().range("AB2:AC4").Cells.item(1,2).cells.item(1).value=12 js tib.
	  char tos().range("AB2:AC4").Cells.item(2,1).cells.item(1).value=21 js tib.
	  char tos().range("AB2:AC4").Cells.item(2,2).cells.item(1).value=22 js tib.
	  char tos().range("AB2:AC4").Cells.item(3,1).cells.item(1).value=31 js tib.
	  char tos().range("AB2:AC4").Cells.item(3,2).cells.item(1).value=32 js tib.
	  char tos().range("AB2:AC4").item(1) js tib.
	  char tos().range("AB2:AC4").item(2) js tib.
	  char tos().range("AB2:AC4").item(3) js tib.
	  char tos().range("AB2:AC4").item(4) js tib.
	  char tos().range("AB2:AC4").item(5) js tib.
	  char tos().range("AB2:AC4").item(6) js tib.
	  char tos().range("AB2:AC4").item(1,1) js tib.
	  char tos().range("AB2:AC4").item(1,2) js tib.
	  char tos().range("AB2:AC4").item(2,1) js tib.
	  char tos().range("AB2:AC4").item(2,2) js tib.
	  char tos().range("AB2:AC4").item(3,1) js tib.
	  char tos().range("AB2:AC4").item(3,2) js tib.
	  char tos().range("AB2:AC4")(1,1) js tib.
	  char tos().range("AB2:AC4")(1,2) js tib.
	  char tos().range("AB2:AC4")(2,1) js tib.
	  char tos().range("AB2:AC4")(2,2) js tib.
	  char tos().range("AB2:AC4")(3,1) js tib.
	  char tos().range("AB2:AC4")(3,2) js tib.
	  char tos().range("AB2:AC4")(1) js tib.
	  char tos().range("AB2:AC4")(2) js tib.
	  char tos().range("AB2:AC4")(3) js tib.
	  char tos().range("AB2:AC4")(4) js tib.
	  char tos().range("AB2:AC4")(5) js tib.
	  char tos().range("AB2:AC4")(6) js tib.
	[then]

	  ------------------ 以下 try Range().name property  --------------------

		TARGET s' pop().range("ab2:ac3")' js constant ab2:ac3

		ab2:ac3 char pop().name          js tib. \ ==> "JScript error : 缺少 ';'"
		\ 錯誤訊息本來就常常不準。若故意嘗試去 print 不存在的 property 就會正確地說是 undefined.

		ab2:ac3 char pop().count         js tib. \ ==> 4 (number)
		ab2:ac3 char pop().name="ab2ac3" js tib. \ ==> ab2ac3 (string)
		ab2:ac3 char pop().name          js tib. \ ==> =名冊!$AB$2:$AC$3 (object) 注意！.name 是個 object.
		js>tos().range("rangeb2c3").name  ==> =名冊!$B$2:$C$3  (object)  注意！.name 是個 object.
		js>tos().range("rangeb2c3").name.name ==> rangeb2c3  (string) , .name.name 才是所給的 name
		js>tos().range("rangeb2c3").name.value ==> =名冊!$B$2:$C$3  (string) 這個 value 當做 .name 的 default 很實用。
		js>tos().range("rangeb2c3").count ==> 4  (number)
		js>tos().range("rangeb2c3").value.toArray() ==> 77,88,99,21,12,22  (array)

		js>b2c3.value ==> Oooops! 型態不符合 , here .value is a VBArray. systemtype() 不認得 VBArray。
		js>var b2c3 = stack[0].range("b2:c3") \ ==> undefined, 有時不要管 jsc 的回覆。b2c3 是個 Range() object, jsc 不認得。
		js>var xx = b2c3 ==>  undefined. 重複用 b2c3 賦值與 var xx 時 jsc 也是回覆 undefined. 這個可以不予理會。
		js>xx = b2c3     ==>  Oooops! 类型不匹配 , 因為 js>systemtype(b2c3) ==> Oooops! 类型不匹配
		js>xx.count      ==> 4  (number)  放心！ 效果沒問題
		js>var yy; yy = xx = b2c3 ==> Oooops! 类型不匹配 , 跟上面一樣
		js>var yy = xx = b2c3     ==> undefined. , 跟上面一樣, 反正 systemtype() 的結果就是這樣。
		js>yy.address           ==> $B$2:$C$3  (string)  可見其實效果沒錯。

	--------------------------------------------------------------------------------------------------------

		mysheet s' tos().Range("A5:E10").printout' js . cr            ==> 產生 filename.jnt Journal file
		mysheet s' tos().Range("A5:E10").printpreview' js . cr        ==> Hang up !!
		TARGET s' tos().Range("A5:E10").Address' js . cr              ==> $A$5:$E$10

	--------------------------------------------------------------------------------------------------------
		target.xls close
		WKSRDCODE.xls close

	-------  find the target range's upper-left corner ---------------------------------------

		hcchen5600 2013/03/26 14:35:44  find the target range's upper-left corner

		To find a cell, use Excel built in find() method. Don't use for-loop and compare, as shown below,
		that wastes too much time.

		Sheet  Range or Cells   Ragne operations      Result and comments
		------ ---------------- ----------------      -------------
		TARGET char tos().cells.count js tib. ==> 16777216 (number) ，"cells" 把 Sheet() 轉成 Range() 是必須的。
		TARGET char tos().cells.find('廠處') js tib. ==> 廠處 (object)
		TARGET char tos().cells.find('廠處').address js tib. ==> $A$5 (string)
		TARGET char tos().cells.find('員工代號') js tib. ==> 員工代號 (object)
		TARGET char tos().cells.find('員工代號').address js tib. ==> $C$5 (string)
		TARGET char tos().cells.find('K0711').address js tib. ==> $C$21 (string) , find first
		TARGET char tos().cells.find('K0711').find('K0711').address js tib. ==> $C$257 (string) , find next
		TARGET char tos().cells.find('K0711').address js tib. ==> $C$21 (string) , 從頭開始重新 find
		TARGET char tos().cells.find('K0711').find('K0711').address js tib. ==> $C$257 (string) ，重複結果

		code find-upper-left-ok ( sheet key -- range T|F ) \ Find the target position if it exists
			var key = pop();
			var sheet = pop();
			for (var i=1; i<=10000; i++) {
				var flag = (sheet.range("A1").item(i).value == key);
				if (flag) break;
			}
			if (flag) {
				push(sheet.range("A1").item(i));
				push(i);
			} else {
				push(false);
			}
			end-code
			/// tos(1).row tos(1).column is the found position
		TARGET s" 廠處" find-upper-left-ok .s
		s" tos(1).row   " js . cr
		s" tos(1).column" js . cr

		code find-upper-left ( sheet key -- range T|F ) \ Find the target position if it exists
			var key = pop();
			var sheet = pop();
			for (var c=1; c<=26; c++) {
				for (var r=1; r<=20; r++) {
					var flag = (sheet.range("A1").item(r,c).value == key);
					if (flag) break;
				}
				if (flag) break;
			}
			if (flag) {
				push(sheet.range("A1").item(r,c));
				push(true);
			} else {
				push(false);
			}
			end-code
			/// tos(1).row tos(1).column is the found position

		TARGET s" 廠處" find-upper-left .s
		s" tos(1).row   " js . cr
		s" tos(1).column" js . cr


	\ -----------------  10 ways to reference Excel workbooks and sheets using VBA  -------------------------
	\ evernote:///view/2472143/s22/a9dbdd6e-d71c-4b5b-b607-9a75afb9a065/a9dbdd6e-d71c-4b5b-b607-9a75afb9a065/

	\ ActiveWorkbook : takes place without additional information, such as the workbook’s name, path, and so on.
	excel.app js> pop().name tib. \ ==> Microsoft Excel (string)
	excel.app js> pop().ActiveWorkbook.path tib. \ ==> X: (string)
	excel.app js> pop().ActiveWorkbook.name tib. \ ==> WKSRDCODE.xls (string)
	excel.app js> pop().ActiveWorkbook.close tib. \ ==> true (boolean) , a dialog box asks do you want to save before close.

	\ Close all workbooks
	excel.app js> pop().Workbooks.Close tib. \ ==> true (boolean) close all workbooks

	\ ActiveSheet, sheet.name, and sheet._codename
	excel.app js> pop().ActiveSheet.name tib. \ ==> CODE (string)
	excel.app js> pop().ActiveSheet._CodeName="WKSRDCODE" tib. \ ==> Microsoft Excel (object) JScript error : 缺少 ';'
	excel.app js> pop().ActiveSheet._CodeName tib. \ ==>  (string) sheet._CodeName 只能透過 VBA IDE 進去改 property.
	excel.app js> pop().ActiveSheet._CodeName tib. \ ==> WKSRDCODE (string) 改成功了
	excel.app js> pop().ActiveSheet._codename tib. \ ==> Sheet2 (string)
	excel.app js> pop().ActiveSheet.name tib. \ ==> CODE backup (string)
	excel.app js> pop().sheets(1).name tib. \ ==> CODE (string)
	excel.app js> pop().sheets(1)._codename tib. \ ==> WKSRDCODE (string)

	\ ----------------------------------- Play with formula --------------------------------------
	CODE js> pop().range("I156").formula tib. \ ==>  (string)  It was empty, a NULL.
	CODE js> pop().range("I156").formula=11223344 tib. \ ==> 11223344 (number)
	CODE js> pop().range("I156").formula="abcde" tib. \ ==> abcde (string)
	CODE js> pop().range("I156").formula='=CONCATENATE(B156,"==",C156)' tib. \ ==> =CONCATENATE(B156,"==",C156) (string)
	CODE js> pop().range("I156").formula tib. \ ==> =G156 (string)

	\ ----------------------------------- Play with copy paste ------------------------------------
	\ 此範例將 Sheet1 中 A1:D4 儲存格的公式複製到 Sheet2 中 E5:H8 儲存格中。
	\ Worksheets("Sheet1").Range("A1:D4").Copy destination:=Worksheets("Sheet2").Range("E5") ==> destination:= 用 JavaScript 不知如何表達

	CODE js> pop().range("G160").copy(destination:pop().range("I160")) tib. ==>JScript error : 缺少 ')' destination:= 用 JavaScript 不知如何表達
	CODE js> pop().range("G160").copy           tib. \ ==> true (boolean) 先把東西抓進 clipboard
	CODE js> pop().range("A166").select         tib. \ ==> true (boolean) 用 range 做好選擇
	CODE js> pop().range("I160:C168").select    tib. \ ==> true (boolean) 用 range 做好選擇
	CODE js> pop().range("I160").paste          tib. \ ==> undefined (undefined) 這樣寫不對！直接用 sheet.paste 下達。
	CODE js> pop().paste                        tib. \ ==> true (boolean) 由 sheet 層面下達 paste 命令。

	--------------------------------------------------

	hcchen5600 2013/03/26 17:57:24  How to get an hash table from excel worksheet?

	TARGET s" pop().Areas.count" js . cr
	TARGET s" pop().Columns(1).Value" js . cr

	Range("B2:C3").Columns(1).Value = 0

	 OK TARGET char pop().columns(1)(1)(1) js tib.
	TARGET char pop().columns(1)(1)(1) js tib. ==>  (object)
	 OK TARGET char pop().columns(1)(1)(1)(1) js tib.
	TARGET char pop().columns(1)(1)(1)(1) js tib. ==>  (object)
	 OK TARGET char pop().columns(1)(1)(1)(1).address js tib.
	TARGET char pop().columns(1)(1)(1)(1).address js tib. ==> $A:$A (string)
	 OK TARGET char pop().columns(1).cells(1).address js tib.
	TARGET char pop().columns(1).cells(1).address js tib. ==> $A$1 (string)
	 OK TARGET char pop().columns(1).cells(1) js tib.
	TARGET char pop().columns(1).cells(1) js tib. ==> origin (object)
	 OK .s
	empty  OK TARGET char pop().range("AA9:AC11).columns(1).address js tib.

	------------------- P A N I C ! -------------------------
	JScript error : 未结束的字符串常量
	TIB:TARGET char pop().range("AA9:AC11).columns(1).address js tib.
	Abort at TIB position 56
	-------  [Yes] go on  [No] js console [Cancel] Terminate  -------
	TARGET char pop().range("AA9:AC11).columns(1).address js tib. ==>  (object)
	 OK TARGET char pop().range("AA9:AC11").columns(1).address js tib.
	TARGET char pop().range("AA9:AC11").columns(1).address js tib. ==> $AA$9:$AA$11 (string)
	 OK TARGET char pop().range("AA9:AC11").columns(1).count js tib.
	TARGET char pop().range("AA9:AC11").columns(1).count js tib. ==> 1 (number)
	 OK TARGET char pop().range("AA9:AC11").cells.count js tib.
	TARGET char pop().range("AA9:AC11").cells.count js tib. ==> 9 (number)
	 OK TARGET char pop().range("AA9:AC11").columns.count js tib.
	TARGET char pop().range("AA9:AC11").columns.count js tib. ==> 3 (number)
	 OK TARGET char pop().range("AA9:AC11").columns.count js tib.

	 OK   TARGET char tos().name js . cr                        ==> 名冊
	 OK TARGET s' pop().Areas.count' js . cr                ==> JScript error : 'pop().Areas.count' 为 null 或不是对象
	 OK TARGET s' pop().Areas' js .s                        ==> 0:  undefined (undefined) , 要有 Range 才有 Areas
	 OK TARGET s' pop().Range("A1").Areas' js .s            ==> 0:  (object) , 要有 Range 才有 Areas
	 OK TARGET s' pop().Range("A1").Areas.count' js .s  ==> 0:  1 (number)
	 OK TARGET s' pop().Range("A1").Columns(1)' js .s       ==> 5:  undefined (object) , A1 is undefined so far.
	 OK TARGET s' pop().Range("A1").item(1)' js .s      ==> 2:  undefined (object) , A1
	 OK s' tos().item(1).value = 123' js .s                     ==> stack 裡的東西都顯示 A1 之值，發生有趣的現象！
		  0:        123 (object)
		  1:        123 (object)
		  2:        123 (object)
		  3:        123 (number)
	 OK drop drop drop .s
		  0:        123 (object)
	 OK s' tos(0).cells(2,1).value = 321' js .s
		  0:        123 (object)
		  1:        321 (number)
	 OK dropall
	 OK TARGET s' pop().Cells(1,1)' js . cr             ==> 123
	 OK TARGET s' pop().Cells(2,1)' js . cr             ==> 321

	 OK TARGET s' pop().Range("A1").Columns(1)' js .s           ==> 1: 123 (object)
	 OK TARGET s' pop().Range("A1").Columns(2)' js .s           ==> 2: undefined (object) , 右邊一行
	 OK TARGET s' pop().Range("A1").Columns(1).item(1)' js .s   ==> 3: 123 (object)
	 OK TARGET s' pop().Range("A1").Columns(1).item(2)' js .s   ==> 4: undefined (object) , 右邊一行
	 OK TARGET s' pop().Range("A1").Columns(1).item(2,1)' js .s ==> 5: JScript error : 缺少 ';'
	 OK TARGET s' pop().Range("A1").Columns(1).item(2).row' js .s ==> 6:        1 (number)
	 OK TARGET s' pop().Range("A1").Columns(1).item(2).column' js .s ==> 7:        2 (number)
	 OK TARGET s' pop().Range("A1").Columns(0).item(2).column' js .s ==> JScript error : 缺少 ';'
	 OK TARGET s' pop().Range("A1").Columns(1).item(1).column' js .s ==> 8:        1 (number)
	 OK TARGET s' pop().Range("A1").Columns(1).item(1).row' js .s    ==> 9:        1 (number)
	 OK TARGET s' pop().Range("A1").Columns(1).item(2).row' js .s    => 10:        1 (number)
	 OK TARGET s' pop().Range("A1").Columns(1).item(2).column' js .s ==>11:        2 (number)
	 OK TARGET s' pop().Range("A1").Columns(1).column' js .s           ==>12:        1 (number)
	 OK TARGET s' pop().Range("A1").Columns(1).row' js .s              ==>13:        1 (number)
	 OK TARGET s' pop().Range("A1").Columns(2).row' js .s              ==>14:        1 (number)
	 OK TARGET s' pop().Range("A1").Columns(2).column' js .s           ==>15:        2 (number)
	 OK dropall
	 OK TARGET s' pop().Range("A1:B2").Columns(2).row' js .s       ==> 3:        1 (number)
	 OK TARGET s' pop().Range("A1:B2").Columns(2).column' js .s  ==> 2:        2 (number)
	 OK TARGET s' pop().Range("A1:B2").Columns(2).count' js .s   ==> 6:        1 (number)
	 OK TARGET s' pop().Range("A1:B2").Columns(2).value' js .s   ==> 4:         (unknown) 有東西，但不知是啥東西
	 ==> 傳回或設定指定範圍的值。可讀寫的 Variant 資料型態。expression.Value(RangeValueDataType)
		 xlRangeValueDefault   如果指定的 Range 物件是空的，則為預設值，傳回 Empty 值 (可用 IsEmpty 函數檢測這種情況)。如
		 果 Range 物件包含多個儲存格，則會傳回的一個數值陣列 (使用 IsArray 函數可檢測到這種情況)。可讀/寫的 Variant 資料型態。
	 ==> 所以 value 傳回的不一定是一個值，看到 type 是 unknown 時，可能是因為它是個 VBArray 之故。

	 OK TARGET s' pop().Range("A1:B2").Columns(2).item(1)' js .s ==> 0:         (object) Item 屬性傳回 Range 物件

	 OK TARGET s' pop().Range("A1:B2").Columns(2)' js .s           ==> 1:         (object) 傳回一個 Range 物件，此物件代表指定範圍中的欄。唯讀。
	 OK TARGET s' pop().Range("A1:B2").Columns(2).item(1)' js .s ==> 7:         (object)
	 OK TARGET s' pop().Range("A1:B2").Columns(2).item(4)' js .s ==> 8:         (object)
	 OK TARGET s' pop().Range("A1:B2").Columns(2).item(2)' js .s ==> 4:         (object)
	 OK TARGET s' pop().Range("A1:B2").item(2)' js .s              ==> 5:        undefined (object)
	 OK TARGET s' pop().Range("A1:B2").item(4)' js .s              ==> 6:        22 (object)
	 OK TARGET s' pop().Range("A1:B2").rows(2)' js .s              ==> 9:         (object)
	 OK TARGET s' pop().Range("A1:B2").rows(2).columns(1)' js .s ==> 0:        321 (object)
	 OK TARGET s' pop().Range("A1:B2").rows(2).columns(2)' js .s ==> 1:        22 (object)
	 OK TARGET s' pop().Range("A1:B2").columns(2).rows(2)' js .s ==> 2:        22 (object)
	 OK TARGET s' pop().Range("A1:B2").Columns(2).item(2).column' js .s => 5:        3 (number)
	 OK TARGET s' pop().Range("A1").columns(2).rows(2)' js .s      ==> 3:        22 (object)
	 OK
	OK dropall
	OK TARGET s' pop().Range("A1:B2").cells(1,1) = 11' js . cr
	1
	OK TARGET s' pop().Range("A1:B2").cells(1,2) = 12' js . cr
	2
	OK TARGET s' pop().Range("A1:B2").cells(2,1) = 21' js . cr
	1
	OK TARGET s' pop().Range("A1:B2").cells(2,2)' js . cr
	2
	OK ARGET s' pop().Range("A1:B2").Columns(2).item(1)' js . cr

	------------------ P A N I C ! -------------------------
	rror! ARGET unknown.
	IB:ARGET s' pop().Range("A1:B2").Columns(2).item(1)' js . cr
	bort at TIB position 5
	------  [Yes] go on  [No] js console [Cancel] Terminate  -------

	------------------ P A N I C ! -------------------------
	Script error : 'pop()' 为 null 或不是对象
	IB:ARGET s' pop().Range("A1:B2").Columns(2).item(1)' js . cr
	bort at TIB position 58
	------  [Yes] go on  [No] js console [Cancel] Terminate  -------
	ndefined
	OK TARGET s' pop().Range("A1:B2").Columns(2).item(1)' js . cr

	------------------ P A N I C ! -------------------------
	Script error on word . next IP is 0 : 类型不匹配
	IB:TARGET s' pop().Range("A1:B2").Columns(2).item(1)' js . cr

	bort at TIB position 61
	------  [Yes] go on  [No] js console [Cancel] Terminate  -------

	OK TARGET s' pop().Range("A1:B2").Columns(2)' js . cr

	------------------ P A N I C ! -------------------------
	Script error on word . next IP is 0 : 类型不匹配
	IB:TARGET s' pop().Range("A1:B2").Columns(2)' js . cr

	bort at TIB position 53
	------  [Yes] go on  [No] js console [Cancel] Terminate  -------

	OK TARGET s' pop().Range("A1:B2").Columns(1)' js . cr

	------------------ P A N I C ! -------------------------
	Script error on word . next IP is 0 : 类型不匹配
	IB:TARGET s' pop().Range("A1:B2").Columns(1)' js . cr

	bort at TIB position 53
	------  [Yes] go on  [No] js console [Cancel] Terminate  -------

	OK TARGET s' pop().Range("A1:B2").Columns(1)' js .s
		 0:         (object)
	OK TARGET s' pop().Range("A1:B2").Columns(2)' js .s
		 0:         (object)
		 1:         (object)
	OK TARGET s' pop().Range("A1:B2").Columns(2)' js .s dropall
		 0:         (object)
		 1:         (object)
		 2:         (object)
	OK TARGET s' pop().Range("A1:B2").Columns(2)' js .s dropall
		 0:         (object)
	OK TARGET s' pop().Range("A1:B2").Columns(2).item(1)' js .s dropall
		 0:         (object)
	OK

	hcchen5600 2013/03/27 19:09:31
	 OK TARGET char tos().columns(1).value="col1" js . cr .s    ==> 可以整行都填一個值
		  0:         (object)
		  1:        "col1" (string)
	 OK TARGET char pop().columns(1).value js . cr .s           ==> JScript error : 型態不符合
	 OK TARGET char pop().columns(1).value js .s                ==> 0: (unknown) , 它是個什麼？Type unknown.

	 OK TARGET char pop().cells(10000,1).value js .s drop   ==> 0:        "col1" (string)
	 OK TARGET char pop().cells(65536,1).value js .s drop   ==> 0:        "col1" (string)
	 OK TARGET char pop().cells(65537,1).value js .s drop   ==> JScript error : 必須要有 ';'

	 OK TARGET char pop().columns(1).count js . cr .s       ==> 1 , 他說 columns(1) 的行數是 1
	 OK TARGET char pop().columns.count js . cr .s          ==> 256 , 他說這張 worksheet 的行數是 256

	 OK TARGET s' pop().Range("B2:C3").Columns(2).value' js .s   ==> 4:         (unknown) VBArray
	 ==> 傳回或設定指定範圍的值。可讀寫的 Variant 資料型態。expression.Value(RangeValueDataType)
		 xlRangeValueDefault   如果指定的 Range 物件是空的，則為預設值，傳回 Empty 值 (可用 IsEmpty 函數檢測這種情況)。如
		 果 Range 物件包含多個儲存格，則會傳回的一個數值陣列 (使用 IsArray 函數可檢測到這種情況)。可讀/寫的 Variant 資料型態。
	 ==> 所以 value 傳回的不一定是一個值，看到 type 是 unknown 時，可能是因為它是個 VBArray 之故。Yes!!!
	 OK TARGET s' pop().Range("B2:C3").Columns(2).value' js VBArray char pop().toArray() js . ==> 12,22 OK

	 OK TARGET s' pop().Range("B2:C3").value' js VBArray s' pop().toArray()' js . ==> 11,21,12,22 OK
	 OK TARGET s' VBArray(pop().range("B2:C3").value).toArray()' js . ==> 11,21,12,22 OK

	\s --------------------- older study ---------------------------------------------------------------
	\ s" pop().worksheets(pop()).select()" js drop <=== 結果是 Class Worksheet 的 Select 方法失敗。我猜是因為 automation 的情況下 select() 沒有意義。
	\ s" pop().ActiveSheet" js <== 既然 select() 沒有意義，Active 也不必了
	\ hcchen5600 2013/03/26 11:03:00 後續發現，
	\ Visual Basic for Applications
	\ Worksheets("Sheet1").Activate
	\   'Can't select unless the sheet is active
	\ Selection.Offset(3, 1).Range("A1").Select  <====

	\ function runA()
	\ {
	\    var i=1,j=1,a=0;
	\   for(i=1;i<4;i++)
	\     { a=0;
	\       for(j=1;j<5;j++)
	\       {
	\        a=a+oSheetA.Cells(i,j).value
	\       }
	\      oSheetB.Cells(i,4).value=a;
	\     }
	\ }        oSheetA

	function runB()
	{
		var j=0;
		for(j=1;j<4;j++)
		  {
		   oSheetB.Cells(j,1).value =  year;
		   oSheetB.Cells(j,2).value =  month;
		  }
	}

	\s
	\ function Main()
	\ {
	\   runA();
	\   runB();
	\   oSheetB.SaveAs(Outpath+"B.xls");
	\   oWB.Close(savechanges=false);
	\   oWA.Close(savechanges=false);
	\   WScript.Echo ("My work has finished!");
	\ }

	Main();
	\s

	code tib.  ( thing -- ) \ pring TIB(0, ntib) and the thing
		systemtype(tib.slice(0, ntib) + " ==> " + stack.pop() + "\n");
		end-code

	-----------------------------------------------------------------------------------------------

	code row.sum ( count col row sheet|cell|range -- sum ) \ Demo, get sum of an excel row
		fortheval("cell"); // ( count cell )
		var origine = pop().cells(1,1);
		var count = pop();
		var sum = 0;
		for (var col=1; col <= count; col++) {
			sum += origine(1,col);
		}
		push(sum);
		end-code

	code colume.sum ( count col row sheet|cell|range -- sum ) \ Demo, get sum of an excel colume
		fortheval("cell"); // ( count cell )
		var origine = pop().cells(1,1);
		var count = pop();
		var sum = 0;
		for (var row=1; row <= count; row++) {
			sum += origine(row,1);
		}
		push(sum);
		end-code



	function CreateNamesArray(){var saNames = [1,2,3,4,5,6,7,8,9];return saNames;}


	function CreateNamesArray()
	{  // Create an array to set multiple values at once.
	  var saNames = [1,2,3,4,5,6,7,8,9];
	  // saNames(0, 0) = "John"
	  // saNames(0, 1) = "Smith"
	  // saNames(1, 0) = "Tom"
	  // saNames(1, 1) = "Brown"
	  // saNames(2, 0) = "Sue"
	  // saNames(2, 1) = "Thomas"
	  // saNames(3, 0) = "Jane"
	  // saNames(3, 1) = "Jones"
	  // saNames(4, 0) = "Adam"
	  // saNames(4, 1) = "Johnson"
	  return saNames;
	}

	: GetIPAddress ( -- ) \ Get (all) IP Addresses
					s" where IPEnabled = true" objEnumWin32_NetworkAdapterConfiguration >r
					begin
						r@ s' pop().atEnd()' js if r> drop exit then
						r@ s' pop().item().IPAddress' js
						r@ s' pop().moveNext()' js drop \ This is the way to iterate all network cards which may be multiple in this computer.
					again ;


	TARGET char pop().Range("AB2:AB4") js constant r1
	TARGET char pop().Range("AE2:AE4") js constant r2
	r2 r1 TARGET char pop().Union(pop(),pop()) js tib.



	WKSRDCODE.xls char pop().name           js tib. ==> WKSRDCODE.xls (string)
	WKSRDCODE.xls char pop().sheets(1).name     js tib. ==> CODE (string)

	CODE char pop().name js tib.
	CODE char pop().columns(2).count js tib.
	CODE char pop().range("B:B").count js tib.

	code bottom         ( Column -- row# ) \ Get the bottom row# of the column
						push(pop().rows(65535).end(-4162).row) // xlUp = -4162
						end-code
						/// It's too stupid that takes a lot of time if going along down to row#65535

	CODE char pop().range("B:B") js bottom tib. \ ==> 160 (number)

	code init-hash      ( sheet "columnKey" "columnValue"-- Hash ) \ get hash table from excel sheet
						var columnValue = pop(), columnKey = pop(), sheet = pop();
						var key = sheet.range(columnKey  +":"+columnKey);
						push(key); fortheval("bottom"); var bottom = pop();
						var val = sheet.range(columnValue+":"+columnValue);
						var hash = {};
						for (var i=1; i<=bottom; i++) {
							if (debug)javascriptConsole(111,i,key,val,bottom);
							if (key(i).value == undefined ) continue;
							hash[key(i).value] = val(i).value;
						}
						push(hash);
						end-code

	CODE char B char D init-hash (see)

	for (var i=0; i<key.count; i++) { if (key(i).value == undefined ) continue; hash[key(i).value] = val(i).value; }

	var xlDown                        =-4121      ;// from enum XlDirection
	var xlToLeft                      =-4159      ;// from enum XlDirection
	var xlToRight                     =-4161      ;// from enum XlDirection
	var xlUp                          =-4162      ;// from enum XlDirection
	const xlShiftDown                 =-4121      ' from enum XlInsertShiftDirection
	const xlShiftToRight              =-4161      ' from enum XlInsertShiftDirection
	var xlShiftToLeft                 =-4159      ;// from enum XlDeleteShiftDirection
	var xlShiftUp                     =-4162      ;// from enum XlDeleteShiftDirection

	sheet.range("b:b").rows(65536).end(-4162).address



	\ -----------------  10 ways to reference Excel workbooks and sheets using VBA  -------------------------
	\ evernote:///view/2472143/s22/a9dbdd6e-d71c-4b5b-b607-9a75afb9a065/a9dbdd6e-d71c-4b5b-b607-9a75afb9a065/

	\ ActiveWorkbook : takes place without additional information, such as the workbook’s name, path, and so on.
	excel.app js> pop().name tib. \ ==> Microsoft Excel (string)
	excel.app js> pop().ActiveWorkbook.path tib. \ ==> X: (string)
	excel.app js> pop().ActiveWorkbook.name tib. \ ==> WKSRDCODE.xls (string)
	excel.app js> pop().ActiveWorkbook.close tib. \ ==> true (boolean) , a dialog box asks do you want to save before close.

	\ Close all workbooks
	excel.app js> pop().Workbooks.Close tib. \ ==> true (boolean) close all workbooks

	\ ActiveSheet, sheet.name, and sheet._codename
	excel.app js> pop().ActiveSheet.name tib. \ ==> CODE (string)
	excel.app js> pop().ActiveSheet._CodeName="WKSRDCODE" tib. \ ==> Microsoft Excel (object) JScript error : 缺少 ';'
	excel.app js> pop().ActiveSheet._CodeName tib. \ ==>  (string) sheet._CodeName 只能透過 VBA IDE 進去改 property.
	excel.app js> pop().ActiveSheet._CodeName tib. \ ==> WKSRDCODE (string) 改成功了
	excel.app js> pop().ActiveSheet._codename tib. \ ==> Sheet2 (string)
	excel.app js> pop().ActiveSheet.name tib. \ ==> CODE backup (string)
	excel.app js> pop().sheets(1).name tib. \ ==> CODE (string)
	excel.app js> pop().sheets(1)._codename tib. \ ==> WKSRDCODE (string)

	\ ----------------------------------- Play with formula --------------------------------------
	CODE js> pop().range("I156").formula tib. \ ==>  (string)  It was empty, a NULL.
	CODE js> pop().range("I156").formula=11223344 tib. \ ==> 11223344 (number)
	CODE js> pop().range("I156").formula="abcde" tib. \ ==> abcde (string)
	CODE js> pop().range("I156").formula='=CONCATENATE(B156,"==",C156)' tib. \ ==> =CONCATENATE(B156,"==",C156) (string)
	CODE js> pop().range("I156").formula tib. \ ==> =G156 (string)

	\ ----------------------------------- Play with copy paste ------------------------------------
	\ 此範例將 Sheet1 中 A1:D4 儲存格的公式複製到 Sheet2 中 E5:H8 儲存格中。
	\ Worksheets("Sheet1").Range("A1:D4").Copy destination:=Worksheets("Sheet2").Range("E5") ==> destination:= 用 JavaScript 不知如何表達

	CODE js> pop().range("G160").copy(destination:pop().range("I160")) tib. ==>JScript error : 缺少 ')' destination:= 用 JavaScript 不知如何表達
	CODE js> pop().range("G160").copy           tib. \ ==> true (boolean) 先把東西抓進 clipboard
	CODE js> pop().range("A166").select         tib. \ ==> true (boolean) 用 range 做好選擇
	CODE js> pop().range("I160:C168").select    tib. \ ==> true (boolean) 用 range 做好選擇
	CODE js> pop().range("I160").paste          tib. \ ==> undefined (undefined) 這樣寫不對！直接用 sheet.paste 下達。
	CODE js> pop().paste                        tib. \ ==> true (boolean) 由 sheet 層面下達 paste 命令。


	 char .\cooked raw.xls save-as tib.
	 raw.xls js> pop().name tib.
	 raw.xls close tib.

	 OK js> GetObject("","Excel.application") constant xls <======================= bingo!
	 OK xls js> pop().name
	 OK .
	Microsoft Excel OK xls js> pop().worksheets.count tib.
	xls js> pop().worksheets.count tib. \ ==> 1 (number)
	 OK xls js> pop().worksheets(1).name tib.
	xls js> pop().worksheets(1).name tib. \ ==> 90OK0JB5105340W (string)
	 OK xls js> pop().workbooks.count
	 OK .
	1 OK xls js> pop().workbooks(1).name tib.
	xls js> pop().workbooks(1).name tib. \ ==> cooked.xls (string)   constant xls <======================= bingo! was opened by GetObject

	strange , open cooked.xls a.xls both ok, but not raw.xls why ?????
	js> GetObject("x:/raw.xls") constant raw.xls tib. <==== "x:\raw.xls" does not work, must be "x:/raw.xls". But this is also strange.
	ahhhhh! after js> GetObject("","Excel.application") constant xls , excel pops an error box says raw.xls not found, that's the problem!!!

	 OK raw.xls js> pop().name tib. \ ==> undefined (undefined)  or may be it has opened alreay, excel sometimes doesn't popup error box!!
	raw.xls js> pop().name tib. \ ==> raw.xls (string)
	 OK raw.xls js> pop().application tib.
	raw.xls js> pop().application tib. \ ==> Microsoft Excel (object)
	 OK
	====> log out first and see . . . .


	[x] Study issues of opeing raw.xls
		Key points are,
		1.  Excel's working directory is user\document, not the DOS box working directory.
		2.  The path string delimiter \ must be \\ because JavaScript is like C language they treats \ as
		    an excape character in a string.
			js> GetObject("raw.xls") constant raw.xls tib. ===> Excel error box popup, says "找不到 'raw.xls'。
									請檢查檔名是否有拼錯，或是檔案位置是否正確。", should be x:/raw.xls I guess.
			OK js> GetObject(".\\raw.xls") constant raw.xls tib.
		3. 	etObject("file1.xls"), GetObject("file2.xls"), and double click file3.xls are all using the
			ame "Excel.Application" handler.
				raw.xls js> pop().application.workbooks.count tib. \ ==> 1 (number)  Good, it's raw.xls
				Now open a.xls manually by double click it, and check again workbooks.count,
				raw.xls js> pop().application.workbooks.count tib. \ ==> 2 (number)  Shoooo!!! Bin Bin Bingo!!!!
				raw.xls js> pop().application.workbooks(2).name tib. \ ==> A.XLS (string)
			So, I don't need to afraid of re-opening an excel file now. Simply use GetObject() correctly.





	殺掉 excel in task manager, if exists, then do it again and again, results are same. Simply x:/raw.xls is needed.

	Retry with "x:\raw.xls" ......

	   js> GetObject("x:\raw.xls") constant raw.xls tib.  \ ==> undefined (undefined)
	   ------------------- P A N I C ! -------------------------
	   JScript error :
	   TIB:js> GetObject("x:\raw.xls") constant raw.xls tib.
	   Abort at TIB position 27
	   -------  [Yes] go on  [No] js console [Cancel] Terminate  -------

	The result is like a garbage file pathname like x:dssdfsdfdsf and there's no Excel file not found popup error message as above.
	So, "raw.xls" itself is strange. Because a.xls seems ok .... Nope, same as garbage filename. So now try "x:/raw.xls" . . . .

	   js> GetObject("x:/raw.xls") constant raw.xls tib. \ ==> undefined (undefined)

	Seems ok? Yes. I am sure "x:\filename.xls" works fine with Workbooks.open(). So \ or / depends on
	Workbooks.open() or GetObject(). The fore one is excel and the rear one is JavaScript? No no no!!
	The \ must be \\ instead, that simple. Also, the "raw.xls" implies using the default directory which
	is user\document not the DOS box's working directory.

	   js> GetObject("raw.xls") constant raw.xls tib. \ ==> undefined (undefined)
	   raw.xls js> pop().path tib. \ ==> D:\hcchen (string)

	 OK js> GetObject("x:\\raw.xls") constant raw.xls tib.
	 reDef raw.xlsjs> GetObject("x:\\raw.xls") constant raw.xls tib. \ ==> undefined (undefined)

	   raw.xls js> pop().name tib. \ ==> raw.xls (string)  Bingo!!

	Now let's see the excel.app's .application.workbooks.count

	   raw.xls js> pop().application.workbooks.count tib. \ ==> 1 (number)  Good, it's raw.xls

	Now open a.xls manually by double click it, and check again workbooks.count,

	   raw.xls js> pop().application.workbooks.count tib. \ ==> 2 (number)  Shoooo!!! Bin Bin Bingo!!!!
	   raw.xls js> pop().application.workbooks(2).name tib. \ ==> A.XLS (string) Great, so automation uses the same excel.app.

	So, I don't need to afraid of re-opening an excel file now. Simply use GetObject() correctly.




	js> GetObject("x:\raw.xls") constant raw.xls tib.

	------------------- P A N I C ! -------------------------
	JScript error :
	TIB:js> GetObject("x:\raw.xls") constant raw.xls tib.
	Abort at TIB position 27
	-------  [Yes] go on  [No] js console [Cancel] Terminate  -------
	 reDef raw.xlsjs> GetObject("x:\raw.xls") constant raw.xls tib. \ ==> undefined (undefined)
	 OK
	 OK
	 OK
	 OK
	 OK
	 OK js> GetObject("x:/raw.xls") constant raw.xls tib.
	 reDef raw.xlsjs> GetObject("x:/raw.xls") constant raw.xls tib. \ ==> undefined (undefined)
	 OK raw.xls js> pop().name tib.
	raw.xls js> pop().name tib. \ ==> raw.xls (string)
	 OK raw.xls js> pop().application tib.
	raw.xls js> pop().application tib. \ ==> Microsoft Excel (object)
	 OK

	 OK js> GetObject(".\\raw.xls") constant raw.xls tib.
	 reDef raw.xlsjs> GetObject(".\\raw.xls") constant raw.xls tib. \ ==> undefined (undefined)
	 OK raw.xls js> pop().path tib.
	raw.xls js> pop().path tib. \ ==> D:\hcchen (string)
	 OK

	----------------------- Usage guides --------------------------------------------------------------------------

	[x] Specify the number of Sheets In New Workbook. Default is 3, change it to 1.
		excel.app :> SheetsInNewWorkbook tib. \ ==> 3 (number)
		excel.app :> SheetsInNewWorkbook=1 tib. \ ==> 1 (number
		excel.app :> SheetsInNewWorkbook tib. \ ==> 1 (number)

	[x] copy sheet to another file
		\ 將 boyce.xls 的 sheet(1) copy 到 emc.xls 的 sheet(1) 之前
		emc.xls boyce.xls js> pop().sheets(1).copy(pop().sheets(1))
		emc.xls boyce.xls js> pop().sheets(1).copy(pop().sheets(1))

	[x] excel.app usages 	
		Application Object (Excel) http://msdn.microsoft.com/en-us/library/office/ff194565.aspx
		> excel.app :> name tib. \ ==> Microsoft Excel (string)
		> excel.app :> width tib. \ ==> 971 (number)
		> excel.app :> height tib. \ ==> 523 (number)
		> excel.app :> DisplayFullScreen \ ==> false (boolean)
		> excel.app :: DisplayFullScreen=true
		> excel.app :> DisplayFullScreen \ ==> true (boolean)  按一下 Esc key 恢復正常。

	[x]	如果把 excel 都殺光光 by 
			s" where name = 'exceL.exe'" kill-them
		此後用到 excel.app 就會 error：
			JavaScript error : The remote server machine does not exist or is unavailable
		那就只好在重新產生一次, 乾脆自動化:
			excel.app :> name s"Microsoft Excel" [if] [else]
			char Excel.Application ActiveXObject to excel.app [then]
		==> excel.app 改良後，不會有空 object 的問題了。我還是無法抓現有的 excel process 轉成
			excel application object 來控制。所以檔案都要用這個 excel.app 來開啟。
			
	[x]	跳出 Open file diaglog 選 file 傳回 pathname
		> excel.app <js> pop().GetOpenFilename()</jsV> \ ==> "C:\Users\8304018\Downloads\收支明細.xlsx" (string)
		excel.app :> GetOpenFilename() ==> "C:\Users\8304018\Downloads\收支明細.xlsx" (string)
		
	[x]	How to get recent workbook, worksheet, cell ?	
		[x] Click one of the two excel and try:
			excel.app :> ActiveWorkbook.name \ ==> Utility Model.xls (string)
			excel.app :> ActiveWorkbook.name \ ==> WKS_201405_DL績效_0519_1W0P00.xls (string)
			--> So the "ActiveWorkbook" property works file
			--> excel.app :> ActiveWorkbook.sheets.count \ ==> 1 or 2 after added one, work fine too.
		[x] ActiveSheet 也通了：
			excel.app :> ActiveWorkbook.ActiveSheet.name \ ==> 工作表3 (string)
		[x]	ActiveCell 不知該怎麼用？ ==> Resolved!
			excel.app :> ActiveWorkbook.ActiveSheet.ActiveRange \ ==> undefined (undefined)
			excel.app :> ActiveWorkbook.ActiveSheet.ActiveCell \ ==> undefined (undefined)
			==>	機會來了！ excel.app :> ActiveCell \ ==> undefined (object) <-- 注意到不同了嗎？ Bingo.
				https://msdn.microsoft.com/en-us/library/office/ff834673.aspx
				excel.app :> ActiveCell.value \ ==> 123 (number)
				excel.app :> ActiveCell.column \ ==> 1 (number)
				excel.app :> ActiveCell.row \ ==> 1 (number)
		Bingo!! 可以任意取得 ActiveCell 來操作了：
		==>	excel.app :> ActiveCell.formula.replace(/TW/,"TE") excel.app :> ActiveCell.formula=pop()

		
	[x] How to activate a specific workbook?
		> myWorkbook :> name \ ==> Utility Model.xls (string)
		> myWorkbook2 :> name \ ==> 2013-12-16剩餘特休統計.xlsx (string)
		> s" WshShell.AppActivate " char "2013-12-16" + </vb>
		> s" WshShell.AppActivate " char "Utility" + </vb>
		> s" WshShell.AppActivate " char "2013-12-16" + </vb>
		> s" WshShell.AppActivate " char "Utility" + </vb> 3000 nap
	
	[x] 用 sendkeys 來操作 excel 
		先取得 workbook.name 然後 Activate 過去 然後才可以 sendkeys 所以
		用 <vb> WshShell.SendKeys "..." </vb> 即可，兩者無異。
		==> 用不著， activeCell offset range activate 等命令夠用了。
		==> See above "How to activate a specific workbook?"
	
	
	[ ] 這個檔案 S7/downloads/WKS_201405_DL績效_0519_1W0P00.xls (string) 很奇怪，它的 sheet1 不能 access!
		但 sheets.count	正常：
			> excel.app :> ActiveWorkbook.sheets(1).name tib.
			JavaScript error : Unknown runtime error
			> excel.app :> ActiveWorkbook.sheets.count .
			1 OK 
		新加的 sheets 就可以 access：
			> excel.app :> ActiveWorkbook.sheets(4).name tib.
			excel.app :> ActiveWorkbook.sheets(4).name \ ==> 工作表3 (string)

	[ ] 研究 3hta 的 localStorage 看能不能用來存 excel 的 application object (或 workbook object 也可以)

	[x]	Selection property 屬於 excel application object 其值為 selected object 也是 range 的一種。
		好不容易才找到： https://msdn.microsoft.com/EN-US/library/office/ff840834.aspx
			excel.app :> selection .s \ ==> [object Object] (object)
		Mark B2:D4 一塊 3x3 區域即成 excel.app :> selection 的 range:
			excel.app :> selection.offset(0,0).count \ ==> 9
		offset 只是參考座標，不影響 selected object 的區域
			excel.app :> selection.offset(1,1).count \ ==> 9  
		示範各種 Access 的方法：
			excel.app :> selection.offset(1,1).range("a1").item(1).value \ ==> c3 (string)
			excel.app :> selection.offset(1,1).range("a1").item(1) \ ==> c3 (object)
			excel.app :> selection.offset(1,1).range("a1") \ ==> c3 (object)
			excel.app :> selection.range("a1") \ ==> b2 (object)
			excel.app :> selection.item(1) \ ==> b2 (object)
			excel.app :> selection.item(9) \ ==> d4 (object)
			excel.app :> selection.item(9).value \ ==> d4 (string)

	
	</comment>





