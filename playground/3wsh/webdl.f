
	\ 即使是 http-test.f 如果目標是 www.ibm.com 在 3wsh 也是不 work 的。
	\ Usage:
	\     jeforth.3wsh.bat /url:http://www.ibm.com /filename:1.txt include webdl.f
	\ 

	
	js> kvm.appname=="jeforth.3wsh"||kvm.appname=="jeforth.3hta"
	[if] [else] ." Support jeforth.3wsh and jeforth.3hta only" cr bye [then]

	js> kvm.fso constant fso // ( -- obj ) WSH Scripting.FileSystemObject
	js> kvm.ado constant ado // ( -- obj ) WSH ADODB.Stream
	<js> new ActiveXObject("Microsoft.XMLHTTP")</jsV> constant http // ( -- obj ) Microsoft.XMLHTTP object
	
	0 value url // ( -- string ) URL
	0 value filename // ( -- string ) filename in URL 
	0 value start // ( -- int ) 文件寫入開始位置
	
	: input ( -- ) \ specify url and filename
		[ js> kvm.appname=="jeforth.3wsh" ] [if]
			js> WScript.fullname.slice(-11)=="cscript.exe" if else
				." Script host must be cscript.exe." cr bye
			then
			args :> named("url") ?dup if
				to url
			else
				." Command line argument /url:<url> is missing." cr
				." Usage: cscript jeforth.3wsh.bat /url:<url> /filename:<filename> include webdl.f" cr 
				bye
			then
			args :> named("filename") ?dup if else
				url :> match(/.*\/(.*)/)[1] 
			then to filename
		[else]
			[ js> kvm.appname=="jeforth.3hta" ] [if]
				\ s" http://localhost:8888/playground/2.html"	to url
				s" http://www.ibm.com"	to url
				\ url :> match(/.*\/(.*)/)[1] to filename
				s" 1.txt" to filename
			[then]
		[then]
		filename fso :> fileexists(pop()) if 				\ 判斷要下載的文件是否已經存在
			filename fso :> getfile(pop()).size to start   	\ 存在，以當前文件大小作為開始位置'
		else
			filename fso :: createtextfile(pop()).close()   \ 新建該文件
		then
	; last execute
	
	: arm ( -- ) \ Start a transfering piece
		url http :: open("GET",pop(),true) \ 這裡用異步方式調用 HTTP
		\ start http :: setRequestHeader("Range","bytes="+tos()+"-"+(pop()+1024))   \ 斷點續傳的奧秘就在這裡
		\ http :: setRequestHeader("Content-Type:","application/octet-stream")
		http :: send() \ 構造完數據包就開始發送
	;

	\ for i=1 to 120                       '循環等待'
	\    if http :> readyState=3 then showplan()    '狀態3表示開始接收數據，顯示進度'
	\    if http.readystate=4 then exit for       '狀態4表示數據接受完成'
	\    wscript.sleep 500                 '等待500ms'
	\ next

	\ if not http.readystate=4 then die("Timeout.")   '1分鐘還沒下完20k？超時！'
	\ if http.status>299 then die("Error: "&http.status&" "&http.statustext) '不是吧，又出錯？'
	\ if not http.status=206 then die("Server Not Support Partial Content.") '服務器不支持斷點續傳'

	: 斷點續傳 ( -- ) \ 繼續傳。。。
		http :> getAllResponseHeaders() . cr 
		ado :: type=1								\ 數據流類型設為 byte
		ado :: open()	
		filename ado :: loadFromFile(pop())			\ 打開文件
		start ado :: position=pop()             	\ 設置文件指針初始位置
		." http :> responseBody : " cr
		http :> responseBody .s
		js> tos()==undefined if http :> responseText . then
		\ ado :: write("abc")							\ 寫入數據
		ado :: write(pop())							\ 寫入數據
		\ Arguments are of the wrong type, are out of acceptable range, or are in conflict with one another.
		\  HTTP: Error 12029 connecting to www.microsoft.com: A connection with the server could not be established 
		filename ado :: saveToFile(pop(),2)			\ 覆蓋保存
		ado :: close()
		http :> getResponseHeader("Content-Range")	\ 獲得http頭中的 "Content-Range" ( -- range )
		js> tos()=="" if ." Can not get range."	cr then \ 沒有它就不知道下載完了沒有   ( -- range )
		js> pop().match(/(\d+)-(\d+)\/(\d+)/)		\ ( -- [range,123,456,789]) Content-Range是類似123-456/789的樣子'
													\ 123是開始位置，456是結束位置 789是文件總字節數
		js> 1==tos()[3]-pop()[2] if					\ 結束位置比總大小少1就表示傳輸完成了
			." Done" cr bye
		then
		start 1024 + to start              			\ 否則再下載 20k 20480
		arm 										\ 繼續傳。。。
	;

	: statusChanged ( -- ) \ http status
		." XMLHTTP readyState changed : " http :> readyState dup . cr
		4 = if
			." XMLHTTP :> status : " http :> status dup . cr
			\ XMLHTTP :> status : 12029
			dup 206 = if ." Server does not support Partial Content. 不支持斷點續傳。" cr bye then
			299 <= if
				斷點續傳
			else
				." Problem retrieving XMLHTTP data:" http :> statusText . cr
			then
		then 
	;	

	: run 
		http :: onReadyStateChange=function(){execute("statusChanged")}
		arm
		." Connectting..." cr   \ 好戲剛剛開始
	;
	
	<comment>
		http :: onreadystatechange=function(){execute("statusChanged")}
		: statusChanged ( -- ) \ XMLHTTP status
		." XMLHTTP readyState changed : " http :> readyState . cr
		http :> readyState 4 = if
		http :> status dup ." http :> status : " . cr
		200 = if
		http :> responseText .
		else
		." Problem retrieving XMLHTTP data:" http :> statusText . cr
		then
		then ;
		http :: open("GET","http://www.ibm.com",true);
		http :: send(null);
	</comment>
