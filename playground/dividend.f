\ 
\ jeforth.3ce 讀取「臺灣銀行」的「除權除息表」並比對歷史，如果有新的就發出 alert。
\ 應用 localStorage 貯存公司列表，所以關機重跑還是記得讀到過的公司。
\
\ 要手動先準備的部分
\ 1. open the data page 
\    > js: window.open("http://fund.bot.com.tw/z/ze/zeb/zeba.djhtm")
\ 2. open 3ce page
\ 3. Assign tabid
\    > list-tabs \ get tabid
\      228 除權除息表-依股號
\    > 228 tabid! \ setup tabid 

\ 看到這個 error 表示讀不到「臺灣銀行」的「除權除息表」網頁。
\ JavaScript error on word "stopSleeping" : Cannot read property '0' of undefined
	  
	: dump-all-<td>  ( -- ) \ Dump all <td> table cells of tabid target page
	  js> $("td").length ( length )
	  ?dup if dup for dup r@ - ( COUNT i ) 
		 >r
		 js> $("td")[rtos()].innerText \ cell value
		 js> $("td")[rtos()].getAttribute("class") dup if char _note_ + then
		 js> $("td")[rtos()].id dup if char _note_ + then
		 r>
		 ." index:" . ."  ID: " . ."  Class: " . space . cr \ the cr provides an important nap time 
	  ( COUNT ) next drop then ; 
	  /// Run on jeforth.3ce target page

	: dump-all-<tr>  ( -- ) \ Dump all <tr> table rows of tabid target page
	  js> $("tr").length ( length )
	  ?dup if dup for dup r@ - ( COUNT i ) 
		 >r
		 js> $("tr")[rtos()].outerHTML remove-script-from-HTML  remove-select-from-HTML \ row HTML
		 js> $("tr")[rtos()].getAttribute("class") dup if char _note_ + then
		 js> $("tr")[rtos()].id dup if char _note_ + then
		 r>
		 ." index:" . ."  ID: " . ."  Class: " . space </o> drop cr \ the cr provides an important nap time 
	  ( COUNT ) next drop then ; 
	  /// Run on jeforth.3ce target page
	
    : Refresh_the_target_page ( -- ) \ Refresh the tabid target page.
        tabid js: chrome.tabs.reload(pop())
        500 nap tabid tabs.get :> status!="complete" if
            1500 nap \ Do my best to allow the title to become available
            ." Still loading " tabid tabs.get :> title . space
            0 begin
                tabid tabs.get :> status=="complete" if 1+ then
                dup 5 > if ( TOS 餵給 until ) else \ 5 complete to make sure it's very ready.
                    char . . 300 nap false
                then
            until ."  done! " cr
        then ;
        /// Improve this if the target page is unstable then we need to timeout and retry.

    : find-next-company ( i -- i' ) \ Find next 已公布除權息日的公司 in 台銀除權除息表 return index or zero.
        s" var last_index = " swap + [compile] </ce> \ setup variable for the target page
        <ce>
        var next_index = 0;
        var array_td = document.getElementsByTagName("td");
        for (var i=last_index+1; i<array_td.length; i++){
            if (array_td[i].id == "oAddCheckbox") { // 臺灣銀行的除權除息表才有這個 id 
                next_index = i;
                break;
            }
        };
        next_index;
        </ceV> :> [0] ;

    : company-name ( i -- name ) \ Convert index of <td> to company name
        <ce> var array_td = document.getElementsByTagName("td"); </ce>
        char array_td[ swap + char ].innerText + 
        [compile] </ceV> :> [0] ;

    : get-company-hash ( -- hash count ) \ Get the company names of 台銀除權除息表。
        <ce> var array_td = document.getElementsByTagName("td");</ce>
        {} ( hash ) 0 ( count ) 0 ( index ) begin 
            find-next-company dup ( hash count idx' idx' ) 
        while 
            ( hash count idx' ) swap 1+ swap ( hash count++ idx' )
            dup company-name ( hash count++ idx' name )
            js: tos(3)[pop()]=true ( hash count++ idx' )
        repeat   ( hash count++ 0 ) drop ;

    : save-company-hash ( hash -- ) \ Save company hash to local storage key 'company-hash'.
        js> JSON.stringify(pop()) ( json )
        js: localStorage["company-hash"]=pop() ;
        /// localStorage["company-hash"] is JSON

    : restore-company-hash ( -- hash ) \ Read company hash from local storage key 'company-hash'.
        js> localStorage["company-hash"] 
        js> tos()==undefined if null else js> JSON.parse(pop()) then ;
        /// localStorage["company-hash"] is JSON

    : isSameHash ( h1 h2 -- boolean ) \ Compare two hash table
        <js> 
        var flag = true;
        for (var i in tos(1)){ // 兩頭各比一次
            if (tos()[i]!==true) flag = false;
            break;
        }; 
        for (var i in tos()){ // 兩頭各比一次
            if (tos(1)[i]!==true) flag = false;
            break;
        }; execute("2drop"); flag </jsV> ;

    : check_updated ( -- ) \ Check if 台銀除權除息表 is updated
        restore-company-hash ( hash0 ) obj>keys :> length if \ Init check
            now t.dateTime . ."  localStorage company hash = " restore-company-hash dup (see)
            get-company-hash drop dup -rot isSameHash if ( company-hash )
                drop ." , no update since the last check." cr
            else  ( company-hash )
                s" , something new updated. Check it out!" 
                dup . cr js: alert(pop())
                dup (see) save-company-hash
            then
        else 
            \ initialize
            get-company-hash drop save-company-hash
        then ;

\ Check every hour

    \ run: begin Refresh_the_target_page check_updated 1000 60 * 60 * nap again

<comment>

	\ Obloleted words
	
    : count_oAddCheckbox ( -- n ) \ Get the company count of 台銀除權除息表。
        0 ( count ) 0 ( index ) begin 
            find-next-company dup ( count idx' idx' ) 
        while 
            ( count idx' ) swap 1+ swap 
        repeat  ( count 0 ) drop ;
        /// Item count does not mean much, because the table cuts items 
        /// before yesterday.

    : check_oAddCheckbox_count ( -- ) \ Check if 台銀除權除息表 is updated <== obsoleted
        js> localStorage.oAddCheckbox_count ( init check ) if
            now t.dateTime . ."  localStorage.oAddCheckbox_count = " js> localStorage.oAddCheckbox_count .
            count_oAddCheckbox js> localStorage.oAddCheckbox_count int = if
                ." , no update since the last check." cr
            else
                s" , something new updated. Check it out!" 
                dup . cr js: alert(pop())
                count_oAddCheckbox js: localStorage.oAddCheckbox_count=pop()
            then
        else 
            \ initialize
            count_oAddCheckbox
            js: localStorage.oAddCheckbox_count=tos()
            js> localStorage.oAddCheckbox_count!=pop() if
                s" Error! Your browser does not support HTML5 localStorage." 
                dup . cr "msg"abort
            then
        then ;

</comment>
