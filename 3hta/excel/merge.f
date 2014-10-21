
s" merge.f" source-code-header

\  拼接 excel 表的欄位

	\ Get files , click OK
	variable eleTargetFile // ( -- element ) Input type=file element
	variable eleRefFile // ( -- element ) Input type=file element
	variable intTargetSheet // ( -- int ) Sheet number
	variable intRefSheet // ( -- int ) Sheet number
	variable objTargetWorkbook // ( -- workbook ) workbook object
	variable objRefWorkbook // ( -- workbook ) workbook object
	variable objTargetWorksheet // ( -- worksheet ) worksheet object
	variable objRefWorksheet // ( -- worksheet ) worksheet object
	variable eleInputTargetIndex // ( -- element ) Input type=text Target worksheet index column
	variable eleInputTargetDestColumn // ( -- element ) Input type=text Target worksheet destination column
	variable eleInputTargetFirstRow // ( -- element ) Input type=text Target worksheet first row
	variable eleInputRefIndex // ( -- element ) Input type=text reference worksheet index column
	variable eleInputRefData // ( -- element ) Input type=text reference worksheet data column
	
	: get-target-file ( -- ) \ Start from getting target file. Leaves the pathname <input> element.
		cr cr 
		." Target excel file " <o> <input type=file size=60 /></o> cr eleTargetFile !
		cr <o> <input 
			type=button 
			onclick="kvm.execute('select-target-worksheet')" 
			value="Next"
		></o> drop ."  Select the correct target worksheet ..." cr
		
		;
	: select-target-worksheet ( -- )
		excel.app js> pop().visible=true \ Need to see corresponding columns
		eleTargetFile @ js> pop().value open.xls dup objTargetWorkbook !
		workbook>sheets \ ( array ) Target workbook sheets' names array
		cr ." Select the correct worksheet : " <js>
			var sheets=pop();
			for(var i=0; i<sheets.length; i++){
				push(i+1+""); push("targetsheet"); execute("input.radio"); pop(); print(sheets[i]+"  ");
			}
		</js> cr
		." Index column (A,B,...) " <o> <input type=text size=1> </o> cr eleInputTargetIndex !
		." Destination column (A,B,...) " <o> <input type=text size=1> </o> cr eleInputTargetDestColumn !
		." First row (1,2,...) " <o> <input type=text size=1> </o> cr eleInputTargetFirstRow !
		cr <o> <input 
			type=button 
			onclick="kvm.execute('get-reference-file')" 
			value="Next"
		></o> drop ."  Get reference file ...." cr cr
		;
	: get-reference-file	( -- element ) \ Get reference file. Leaves the pathname <input> element.
		js> $('input[name=targetsheet]:checked').val() int intTargetSheet !
		intTargetSheet @ if else <js> alert("Don't forget to select the worksheet!") </js> exit then
		eleInputTargetIndex @ js> pop().value if else <js> alert("What's the target file index column?") </js> exit then
		eleInputTargetDestColumn @ js> pop().value if else <js> alert("What's the target file target column?") </js> exit then
		eleInputTargetFirstRow @ js> pop().value if else <js> alert("What's the target file first row# ?") </js> exit then
		." Reference excel file " <o> <input type=file size=60 /></o> cr eleRefFile !
		cr <o> <input 
			type=button 
			onclick="kvm.execute('select-reference-worksheet')" 
			value="Next"
		></o> drop ."   Select the correct reference worksheet ..." cr
		;
	: select-reference-worksheet ( -- )
		eleRefFile @ js> pop().value open.xls dup objRefWorkbook !
		workbook>sheets \ ( array ) Target workbook sheets' names array
		cr ." Select the correct worksheet : " <js>
			var sheets=pop();
			for(var i=0; i<sheets.length; i++){
				push(i+1+""); push("referencesheet"); execute("input.radio"); pop(); print(sheets[i]+"  ");
			}
		</js> cr
		." Index column (A,B,...) " <o> <input type=text size=1> </o> cr eleInputRefIndex !
		." Data column (A,B,...) " <o> <input type=text size=1> </o> cr cr eleInputRefData !
		<o> <input 
			type=button 
			onclick="kvm.execute('merge-column-to-target')" 
			value="GO!!"
			style="width:120px;height:40px;font-size:20px;"
		></o> drop cr cr
		;
	: merge-column-to-target ( -- ) 
		js> $('input[name=referencesheet]:checked').val() int intRefSheet !
		intRefSheet @ if else <js> alert("Don't forget to select the worksheet!") </js> exit then
		eleInputRefIndex @ js> pop().value if else <js> alert("What's the database file index column?") </js> exit then
		eleInputRefData @ js> pop().value if else <js> alert("What's the database file data column?") </js> exit then
		intTargetSheet @ int objTargetWorkbook @ js> pop().sheets(pop()) objTargetWorksheet !
		intRefSheet @ int objRefWorkbook @ js> pop().sheets(pop()) objRefWorksheet !
		\ 開始拼接 excel 表的欄位
		objRefWorksheet @ eleInputRefIndex @ js> pop().value eleInputRefData @ js> pop().value
		init-hash dup (see) ( hash-table )
		objTargetWorksheet @ eleInputTargetIndex @ js> pop().value eleInputTargetDestColumn @ js> pop().value 
		eleInputTargetFirstRow @ js> pop().value int hash>column 
		\ close workbooks
		\ objTargetWorkbook @ excel.close
		objRefWorkbook @ excel.close
		<o> D o n e !</o>
		;

		cr cr ." 拼接 excel 表的欄位。" cr
		." Look up reference excel file to add a column to target excel file." cr
		<o> <input 
			type=button 
			onclick="kvm.execute('get-target-file')" 
			value="S T A R T"
			style="width:120px;height:40px;font-size:20px;"
		></o> cr drop
