
	\ utf-8
	\ word.f  Microsoft Office Word automation by jeforth.3hta
	\ Excel 2013 developer reference           https://docs.microsoft.com/en-us/office/vba/api/overview/excel
	\ "Application Object (Word)"              https://docs.microsoft.com/en-us/office/vba/api/word.application

	\ Sample code of basics  
	\ 	https://docs.microsoft.com/zh-tw/previous-versions/office/troubleshoot/office-developer/automate-word-create-file-using-visual-basic
	
	include wsh.f

	s" word.f"			source-code-header
	
	: see-word 			( -- n ) \ List all winword.exe processes
						s" where name = 'wInWoRD.ExE'" see-process ;
	: kill-word 		( -- n ) \ Kill all winword.exe processes
						s" where name = 'winword.ExE'" kill-them ;
						/// Formal way is : word.app :: quit()
						
	\ 先查有幾個 word.application 在 running? 通常應該只有一個，如果是一個就用它, 如果超過一個
	\ 就警告, 如果沒有就開一個。 如果 word 沒有 install 的情形要跳過。
		\ 當 jeforth.3hta 已經在 run
		\ 此時 excel 又已經是 multiple 了，與其提供 rescan 命令不如讓 excel.f 重啟，目前就是這樣。
		\ 當要對 excel 工作時，最好臨時再 include excel.f 以收檢查之效且保證 excel.app object 有效。
		\ 因此 quit.f 不再主動 include excel.f 了。
	
	: word.app.count 	( -- count ) \ Winword.exe instance count, I can only handle 1. 
						s" where name = 'wiNwoRd.ExE'" count-process ;
						/// GetObject(,"word.application") returns an word.app object but 
						/// if there were multiple winword.app then we don't know which one is 
						/// it. Only one word.app is allowed is the workaround.
						
	null value word.app 	// ( -- obj ) The Word.Application object or undefined if no word exists.

						word.app.count 1 > [if] 
							cr cr ." W A R N I N G !   (from word.f)" cr cr
							." Multiple Word.Application are running, I can only handle one of them." cr 
							." The word I've got the handle should be high-lighted, you see that? Please use" cr 
							." that one or you'll have to use the 'kill-word' command to close all of them and" cr
							." then '--word.f-- include word.f' to restart me, the word.f module, again." cr cr
						[then]

						word.app.count [if] 
							\ 用這行就錯了! <vb> On Error Resume Next:Set wd=GetObject("","word.application"):vm.push(wd)</vb> 會開出新 Word.Application。
							<vb> On Error Resume Next:Set wd=GetObject(,"word.application"):vm.push(wd)</vb> \ 這行才是沿用既有的 Word.Application。
						[else]
							<vb> On Error Resume Next:Set wd=CreateObject("word.application"):vm.push(wd)</vb>						
						[then] to word.app \ 如果 word 沒有 install 會是 undefined。

	: isPDF? ( pathname_str -- bool ) \ Check the given pathname is it a .pdf file? 
		trim :> toLowerCase().slice(-4)==".pdf" ;

	: rename>docx ( pathname -- pathname.docx ) \ Rename to .docx 
		trim dup :> toLowerCase().lastIndexOf('.pdf') ( pathname end ) 
		swap ( end pathname) :> slice(0,pop())+".docx" ; 
		
	: pdf2docx ( <command-line> -- errorlevel ) \ convert pdf to docx 
		js> hta.commandLine dup ( line line ) :> lastIndexOf('pdf2docx') 8 + ( line n ) 
		swap :> slice(pop()) ( pathname )  
		dup isPDF? ( pathname y|n ) if ( pathname ) 
			trim dup rename>docx swap ( .docx .pdf )
			." Opening " dup . cr 
			word.app :> documents.open(FileName=pop(),ConfirmConversions=false,NoEncodingDialog=true,Revert=true) 
			." Converting ..." cr 
			( .docx document ) :: SaveAs2(FileName=pop())
			." Closing ..." cr 
			word.app :> ActiveDocument.close()
			0 \ errorlevel 0 == OK
			." OK! " cr 
		else
			s" Not a pdf file : " swap + js: alert(pop()) 
			1 \ errorlevel 1 == Failed 
		then bye ;
		/// Usage:
		///    3hta.bat include word.f pdf2docx d:\document\panel spec extraction\AUO abc-1234.pdf 
		/// Result:
		///    d:\document\panel spec extraction\AUO abc-1234.docx

	\ -- end of source code --

<comment>
\	\ ================ How to open an Excel file ============================================
\	\
\	\ Key points of automation Excel file accessing ,
\	\ 1. Excel's working directory is user\document, not the DOS box working directory.
\	\ 2. The path string delimiter \ must be \\ or it will be failed sometimes.
\	\ 3. VBscript's GetObject("file.xls") is also available for HTA. GetObject("file2.xls"), 
\	\	 and double click file.xls are all using the *active* "Excel.Application" object. Excel must 
\	\	 be in memory before using GetObject().
\	\
\	\ Open excel file 有兩種方式，
\	\
\	\   1。 Create a new Excel.Application object
\	\		<js> push(new ActiveXObject("Excel.application")) </js> constant excel.app 
\	\		<vb> set vm.excel.app = CreateObject(...)' </vb>
\	\       excel.app :> Workbooks.open("x:\\cooked.xls");
\	\
\	\   2。 Use the existing instance of Excel.Application object
\	\		<vb> set vm.excel.app = GetObject(,"Excel.Application") </vb> 
\	\		<vb> set vm.excel.app = GetObject("file.xls") </vb>
\	\       <vb> set vm.excel.app = GetObject("x:\\raw.xls") </vb>
\	\       <vb> set vm.excel.app = GetObject("x:\\cooked.xls") </vb>
\	\
\	\ 前者的 excel.app 獨立於電腦內其他 "Excel.application" instances，重複 open 同一個檔案的問題很
\	\ 難解決。Internet 上有很多人在問，問不出好答案。因為要搜出所有的 "Excel.application" instances
\	\ 來處理，已經難過頭了。所以要用後者才好，重複 open 時 excel 自己會跳出來禁止。因為 automation
\	\ 對 excel file 所用的 Excel.Application 與 double click open excel file 是同一 handler. 證明如
\	\ 下,
\	\
\	\    raw.xls js> pop().application.workbooks.count tib. \ ==> 1 (number)  Good, it's raw.xls
\	\    Now open a.xls manually by double click it, and check again workbooks.count,
\	\    raw.xls js> pop().application.workbooks.count tib. \ ==> 2 (number)  Shoooo!!! Bin Bin Bingo!!!!
\	\    raw.xls js> pop().application.workbooks(2).name tib. \ ==> A.XLS (string)
\	\
\	\ [ ]	GetObject() 的缺點是，當 Excel 不存在 memory 裡時會出 error:
\	\		"JScript error : Automation 服务器不能创建对象" 這可以用 On Error Resume Next 來避免
\	\		error 此時取得的是 undefined 十分完美。
\	\ [ ]	excel.app js> pop().quit() 之後再 double click open 的 excel file 似乎會變成去
\	\		用另一個 excel.application instance?
\	\

word.app :> FileConverters.count --> 4(number)  \ there are 4 converters
> word.app :> FileConverters(1).Path -->
word.app :> FileConverters(1).Path --> C:\Program Files\Common Files\Microsoft Shared\TEXTCONV(string)
 OK 
> word.app :> FileConverters(0).Path -->  \ start from 1 not 0 
JavaScript error : 集合中所需的成員不存在。
Panic jsc>
 > reset
 OK 
word.app :> FileConverters(1).Path --> C:\Program Files\Common Files\Microsoft Shared\TEXTCONV(string)
word.app :> FileConverters(2).Path --> C:\Program Files\Common Files\Microsoft Shared\TEXTCONV(string)
word.app :> FileConverters(3).Path --> C:\Program Files\Common Files\Microsoft Shared\TEXTCONV(string)
word.app :> FileConverters(4).Path --> {A5C79653-FC73-46ee-AD3E-B64C01268DAA}(string)
word.app :> FileConverters(1).FormatName --> 復原任何檔案的文字(string)
word.app :> FileConverters(1).classname --> Recover(string)
word.app :> FileConverters(1).Extensions --> *(string)
word.app :> FileConverters(2).FormatName --> WordPerfect 6.x(string)
word.app :> FileConverters(2).classname --> WordPerfect6x(string)
word.app :> FileConverters(2).Extensions --> wpd doc(string)
word.app :> FileConverters(3).FormatName --> WordPerfect 5.x(string)
word.app :> FileConverters(3).classname --> WrdPrfctDos(string)
word.app :> FileConverters(3).Extensions --> doc(string)
word.app :> FileConverters(4).FormatName --> PDF Files(string)
word.app :> FileConverters(4).classname --> IFDP(string)
word.app :> FileConverters(4).Extensions --> pdf(string)

	> word.app :> FileConverters
	<js>
	FileConverters = pop()
	for (i=1; i<=FileConverters.count; i++) 
		type("FileConverters(" + i + ") " + FileConverters(i).classname + "\n")
	</js>
	> FileConverters(1) Recover
	> FileConverters(2) WordPerfect6x
	> FileConverters(3) WrdPrfctDos
	> FileConverters(4) IFDP
 
word.app :> UserName --> H.C. Chen/WHQ/Wistron(string)
 
[ ] https://docs.microsoft.com/en-us/office/vba/api/word.saveas2

https://docs.microsoft.com/en-us/office/vba/api/word.application.activedocument
word.app :> Documents.Count --> 0(number)
> see-word
 string   Name;                       WINWORD.EXE
 uint32   ProcessId;                  30724
 string   Caption;                    WINWORD.EXE
 string   CommandLine;                "C:\Program Files\Microsoft Office\Root\Office16\WINWORD.EXE" /Automation -Embedding
 string   CreationClassName;          Win32_Process
 datetime CreationDate;               20220705152349.294941+480
 string   CSCreationClassName;        Win32_ComputerSystem
 string   CSName;                     TPEA90107673
 string   Description;                WINWORD.EXE
 string   ExecutablePath;             C:\Program Files\Microsoft Office\Root\Office16\WINWORD.EXE
 uint16   ExecutionState;             null
 string   Handle;                     30724
 uint32   HandleCount;                1038
 datetime InstallDate;                null
 uint64   KernelModeTime;             5625000
 uint32   MaximumWorkingSetSize;      1380
 uint32   MinimumWorkingSetSize;      200
 string   OSCreationClassName;        Win32_OperatingSystem
 string   OSName;                     Microsoft Windows 10 專業版|C:\Windows|\Device\Harddisk0\Partition3
 uint64   OtherOperationCount;        5716
 uint64   OtherTransferCount;         239367
 uint32   PageFaults;                 32097
 uint32   PageFileUsage;              42956
 uint32   ParentProcessId;            1648
 uint32   PeakPageFileUsage;          43424
 uint64   PeakVirtualSize;            2204107444224
 uint32   PeakWorkingSetSize;         109364
 uint32   Priority = NULL;            8
 uint64   PrivatePageCount;           43986944
 uint32   QuotaNonPagedPoolUsage;     47
 uint32   QuotaPagedPoolUsage;        1226
 uint32   QuotaPeakNonPagedPoolUsage; 53
 uint32   QuotaPeakPagedPoolUsage;    1253
 uint64   ReadOperationCount;         342
 uint64   ReadTransferCount;          1384064
 uint32   SessionId;                  1
 string   Status;                     null
 datetime TerminationDate;            null
 uint32   ThreadCount;                17
 uint64   UserModeTime;               7031250
 uint64   VirtualSize;                2204088795136
 string   WindowsVersion;             10.0.19044
 uint64   WorkingSetSize;             110444544
 uint64   WriteOperationCount;        6
 uint64   WriteTransferCount;         27020
word.app :> Documents.Count --> 1(number)
word.app :> Documents.Count --> 1(number)
word.app :> Documents.Count --> 2(number)   \ we have 2 documents in word now 
word.app :> ActiveDocument --> filtered_1. Lynx & Serval_CS21 Product_Spec-Rev D_20201125-20201126 sign by NEC Sugimoto-san.pdf(object)
word.app :> ActiveDocument.close() --> undefined(undefined)  \ .close() method returns nothing 
word.app :> ActiveDocument.close() --> undefined(undefined) \ do the .close() again , so two documents are both closed
> word.app :> ActiveDocument --> \ there's no active document now , indeed !!
JavaScript error : 因為沒有開啟文件，所以無法使用這個指令。
Panic jsc>
 > reset
 OK 
word.app :> Documents.Count --> 0(number)   \ correct !! it's zero 

\ 故意開了兩個 files  
word.app :> Documents(1).Activate() --> undefined(undefined)   \ .activate() method 沒有 return value 
word.app :> Documents(2).Activate() --> undefined(undefined)
word.app :> Documents(2).name --> filtered_B156ZAN03^M8_HW_0A_^MPre^Mfunctional^Mspec^MV0.1^M(X00)^M-2020-03-27^Mfor^MDell_47R3H.pdf.docx(string)
word.app :> Documents(1).name --> filtered_B133QAN03 0 HW0A Pre-Functional Spec_ Lenovo_1110_V3.pdf(string)
word.app :> ActiveDocument.name --> filtered_B133QAN03 0 HW0A Pre-Functional Spec_ Lenovo_1110_V3.pdf(string)
> word.app :> Documents(2).Activate -->
JavaScript error : 'Activate' 不是屬性。
word.app :> ActiveDocument.name --> filtered_B156ZAN03^M8_HW_0A_^MPre^Mfunctional^Mspec^MV0.1^M(X00)^M-2020-03-27^Mfor^MDell_47R3H.pdf.docx(string)
word.app :> Documents.Count --> 2(number)

word.app :> Documents(1).SaveAs2(FileName="1.docx") --> undefined(undefined) \ no return value, saved to c:\Users\8304018\Documents\1.docx 
word.app :> Documents.Count --> 2(number) \ still 2, the .pdf document has been converted to .docx 

s" d:\OneDrive\Documents\Jupyter Notebooks\Vendor spec parsing\Panel spec extraction\data\training_data.csv"
s" d:\OneDrive\Documents\Jupyter Notebooks\Vendor spec parsing\Storage\temp\filtered_Cyborg XC0MJ_B160QAN01_HW_0A_ functional spec V01 (A00) - 2021-04-01 for Dell_Final.pdf"
word.app :> documents.open(FileName=pop())
word.app :> documents.open(FileName=pop(),ConfirmConversions=true)

s" d:\OneDrive\Documents\Jupyter Notebooks\Vendor spec parsing\Storage\temp\filtered_Cyborg XC0MJ_B160QAN01_HW_0A_ functional spec V01 (A00) - 2021-04-01 for Dell_Final.pdf"
word.app :> documents.open(FileName=pop(),ConfirmConversions=false)
word.app :> Documents(1).SaveAs2(FileName="1.docx") \ no return value, saved to c:\Users\8304018\Documents\1.docx 
word.app :> ActiveDocument.close() \ .close() method returns nothing 

s" d:\OneDrive\Documents\Jupyter Notebooks\Vendor spec parsing\Storage\temp\filtered_Cyborg XC0MJ_B160QAN01_HW_0A_ functional spec V01 (A00) - 2021-04-01 for Dell_Final.pdf    "
word.app :> documents.open(FileName=pop(),ConfirmConversions=false,NoEncodingDialog=true,Revert=true)
word.app :> Documents(1).SaveAs2(FileName="1.docx") \ no return value, saved to c:\Users\8304018\Documents\1.docx
word.app :> ActiveDocument.close() \ .close() method returns nothing 

s" d:\OneDrive\Documents\Jupyter Notebooks\Vendor spec parsing\Storage\temp\filtered_Cyborg XC0MJ_B160QAN01_HW_0A_ functional spec V01 (A00) - 2021-04-01 for Dell_Final.pdf    "
js> pop() :> trim().toLowerCase().lastIndexOf('.pdf') --> 165(number)
js> pop() :> slice(0,165) --> d:\OneDrive\Documents\Jupyter Notebooks\Vendor spec parsing\Storage\temp\filtered_Cyborg XC0MJ_B160QAN01_HW_0A_ functional spec V01 (A00) - 2021-04-01 for Dell_Final(string)

js> hta.commandLine --> "D:\GitHub\jeforth.3hta\jeforth.hta"  nop \ s" d:\OneDrive\Documents\Jupyter Notebooks\Vendor spec parsing\Storage\temp\filtered_Cyborg XC0MJ_B160QAN01_HW_0A_ functional spec V01 (A00) - 2021-04-01 for Dell_Final.pdf    "(string)
 OK 

> include word.f
word.app :> Documents.Count --> 1(number)
word.app :> Documents(1) --> filtered_B133UAN01.2 Functional Spec_1104Y20_Lenovo.docx(object)
> word.app :> Documents(1) value doc // ( -- Word Document ) 
doc --> filtered_B133UAN01.2 Functional Spec_1104Y20_Lenovo.docx(object)
doc :> tables --> [object Object](object)
doc :> tables.count --> 1(number)
doc :> tables(1).columns.count --> 3(number)  \ correct !
doc :> tables(1).rows.count --> 31(number)    \ super correct !!!! 因分頁被切割的 table 也能正確視為一個！

doc :> paragraphs.count --> 132(number)
doc :> paragraphs(1) --> [object Object](object)
doc :> Paragraphs(1).Range.Start -->  0
doc :> Paragraphs(1).Range.End   --> 23
doc :> Paragraphs(2).Range.start --> 23(number)
doc :> Paragraphs(2).Range.End --> 49(number)
doc :> range(0,23) --> \ 查看 paragraph 1 


3 >x
x@ doc :> Paragraphs(pop()).Range.Start
x@ doc :> Paragraphs(pop()).Range.End
( start end ) doc :> range(pop(1),pop(0)) -->
xdrop


> .s
      0:           0           0h (number)
      1:          23          17h (number)
      2: Product Specifica (object)
 OK 
> doc :> range(0,23)
 OK 
> .s
      0:           0           0h (number)
      1:          23          17h (number)
      2: Product Specifica (object)
      3: Product Specification   (object)



列印出所有 sentences 
> doc <js>
doc = pop()
for (i=1; i <= doc.sentences.count; i++) type(doc.sentences(i)+"\n")
</js>

: test 
	<js> 
	dictate("word.app :> FileConverters(1).FormatName -->") 
	dictate("word.app :> FileConverters(1).classname  -->") 
	dictate("word.app :> FileConverters(1).Extensions -->") 
	dictate("word.app :> FileConverters(2).FormatName -->") 
	dictate("word.app :> FileConverters(2).classname  -->") 
	dictate("word.app :> FileConverters(2).Extensions -->") 
	dictate("word.app :> FileConverters(3).FormatName -->") 
	dictate("word.app :> FileConverters(3).classname  -->") 
	dictate("word.app :> FileConverters(3).Extensions -->") 
	dictate("word.app :> FileConverters(4).FormatName -->") 
	dictate("word.app :> FileConverters(4).classname  -->") 
	dictate("word.app :> FileConverters(4).Extensions -->") 
	dictate("word.app :> UserName -->                       ")
	dictate("word.app :> Documents.Count -->                ")
	dictate("word.app :> Documents.Add() ( objNewDocument1 ) --> ") 
	dictate("word.app :> Documents.Add() ( objNewDocument2 ) --> ") 
	dictate("word.app :> ActiveDocument.name -->            ")
	dictate("word.app :> ActiveDocument.close() -->         ")
	dictate("word.app :> Documents(1).name -->              ")
	word.app :> Documents(1).Activate() -->

	
	</js>
	<text>
    word.app :> documents.open(FileName=pathname,ConfirmConversions=false,NoEncodingDialog=true,Revert=true)
    word.app :> Documents(1).SaveAs2(FileName="1.docx") \ no return value, saved to c:\Users\8304018\Documents\1.docx
    word.app :> ActiveDocument.close() \ .close() method returns nothing 
	
	\ This snippet shows the specified paragraph
		( paragraph number --> ) 9 >x
		x@ doc :> Paragraphs(pop()).Range.Start
		x@ doc :> Paragraphs(pop()).Range.End
		( start end ) doc :> range(pop(1),pop(0)) -->
		xdrop

	</text>
;

\ This snippet works! copy target table from one document to another 
	word.app :> Documents(2).name --> filtered_B133UAN01.2 Functional Spec_1104Y20_Lenovo.docx(string)
	word.app :> Documents(1).name --> 文件1(string)
	> word.app :> Documents(1) value newdoc
	newdoc :> ActiveWindow.Panes.count --> 1(number)
	\ 手工點選 winword.exe table 左上角全選，然後來 jeforth 執行這兩行，真的就把 table copy 過去了
	   doc :> ActiveWindow.Panes(1).Selection.Copy()  --> undefined(undefined) 沒有傳回值
	newdoc :> ActiveWindow.Panes(1).Selection.paste()  --> undefined(undefined) 沒有傳回值

\ Selection 
	
	word.app :> ActiveDocument.select() --> undefined(undefined) \ 把整個 doc 都 mark 起來 
	
	doc :> ActiveWindow.Selection.Cut() 
	JavaScript error : 此方法或屬性無法使用，因為物件是空的。
	doc :> ActiveWindow.Selection.Cut() \ mark 好一段文字再來執行，成功！傳回 undefined 沒有傳回值。

	word.app :> selection value selection // ( -- obj ) Word Selection object 跟定當前 active document 
	word.app :> selection.type --> 2(number) \ 當前 active doc 選中一小段 text 或跨多種 types 
	word.app :> selection.type --> 1(number) \ 當前 active doc 沒有 selection 
	word.app :> selection.type --> 5(number) \ 當前 active doc 選中整個 table 
	word.app :> selection.type --> 4(number) \ 當前 active doc 選中 table 內幾個 cells 

\ selection.Collapse()
	word.app :> selection.Collapse()  \ cursor 跳到 selection 的開頭
	word.app :> selection.Collapse(1) \ cursor 跳到 selection 的開頭
	word.app :> selection.Collapse(0) \ cursor 跳到 selection 的結尾
	word.app :> selection.Collapse(dddirection=0) \ cursor 跳到 selection 的結尾
								   ^^^^^^^^^^^^ 亂寫都無所謂，只認位置。	
	word.app :> ActiveDocument.select() word.app :> selection.Collapse(0) \ 跳到整篇最後面
						\ 如果是為了剔除其他的只留下 tables 用 paragraphs(paragraphs.count-1) 更直接。
						
								   
\ 把 sentence 改掉
	s" Material below is confidential." word.app :> ActiveDocument.Sentences(2).Text=pop()

\ 插入 a string 到 word 後面
	word.app :> ActiveDocument.Words(1).select() \ select 1st word 
	word.app :> selection.Collapse(0) \ 跳到 word 結尾。
	s" (This is a test.) "  word.app :> ActiveDocument.Words(1).Text=pop() \ 白跳了，整個 word 都被改掉。
	s" (This is a test.) "  word.app :> selection :: InsertAfter(pop()) \ 用 selection.InsertAfter() 就對了
	s" (This is a test.) "  word.app :> ActiveDocument.Words(1).InsertAfter(pop()) \ 這一行抵上面全部

\ 取得 table object 
	word.app :> ActiveDocument.tables.count --> 1(number)
	word.app :> ActiveDocument.tables(1).range --> PIN NO. ... (object)
 

打算建新 doc 然後把 table copy 過去, 藉此清除 table 以外的東西
https://www.thespreadsheetguru.com/blog/2014/5/22/copy-paste-an-excel-table-into-microsoft-word-with-vba

> word.app :> Documents.Add() 
> .s
      0: 文件1 (object)
> value newDoc // ( -- doc ) my new word document in memory


	'Copy Excel Table Range
	  tbl.Copy

	'Paste Table into MS Word
	  myDoc.Paragraphs(1).Range.PasteExcelTable _
		LinkedToExcel:=False, _
		WordFormatting:=False, _
		RTF:=False

	'Autofit Table so it fits inside Word Document
	  Set WordTable = myDoc.Tables(1)
	  WordTable.AutoFitBehavior (wdAutoFitWindow)

這篇練習 failed at bookmark \EndOfDoc is unknown 
https://docs.microsoft.com/zh-tw/previous-versions/office/troubleshoot/office-developer/automate-word-create-file-using-visual-basic

newdoc :> range().end 
newdoc :> range(pop()-1).paste()

\ This experiment gets Good news!! simply put new table after the last table merges them into one table!!!
	specdoc :> tables.count --> 31(number)  \ spec has 31 tables 
	specdoc :> tables(8).range.copy() \ copy a table from the spec
	newdoc :> range().end ( int ) \ get the position number of the end of the document 
	newdoc :> range(pop()-1).paste() \ paste the above table to end of the document 
	specdoc :> tables.count --> 31(number) \ source no change
	newdoc :> tables.count --> 1(number) \ only one table on the target document! why? Because merged into one!!
	newdoc :> tables(1).delete() \ try to delete the ONE table and it's true the multiple table in one is deleted at once. 

\ This experiment cut() the table > clear the doc > paste() the table back so as to keep only the table.
	newdoc :> tables(1).range.cut() \ cut the table to clipboard
	newdoc :> range().delete() \ delete the entire document 
	newdoc :> range().paste() \ restore the table so as to clean the document only keeps the table


</comment>