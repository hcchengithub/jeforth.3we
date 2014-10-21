
s" merge2.f" source-code-header

\  拼接 excel 表的欄位

	\ js> idTargetFile		( -- element ) Input type=file element
	\ js> idTargetIndex		( -- element ) Input type=text Target worksheet index column
	\ js> idTargetColumn	( -- element ) Input type=text Target worksheet destination column
	\ js> idTargetFirstRow	( -- element ) Input type=text Target worksheet first row
	0 value objTargetWorkbook	// ( -- workbook ) workbook object
	0 value intTargetSheet		// ( -- int ) Sheet number
	0 value objTargetWorksheet	// ( -- worksheet ) worksheet object
	\ js> idRefFile			( -- element ) Input type=file element
	\ js> idRefIndex 		( -- element ) Input type=text reference worksheet index column
	\ js> idRefColumn		( -- element ) Input type=text reference worksheet data column
	0 value objRefWorkbook 		// ( -- workbook ) workbook object
	0 value intRefSheet 		// ( -- int ) Sheet number
	0 value objRefWorksheet		// ( -- worksheet ) worksheet object

	<h>	<style></style></h> constant tableStyle // ( -- eleStyle ) The style element of my questionnaire table
	s" table, th, td {border: 1px solid black;border-collapse: collapse;margin-left: 50px;padding:12px;}" tableStyle js: pop().innerHTML=pop()
	\ 故意用這手法來定義 Style, 表示它可以 be changed dynamically.

	<o> <p><table><caption>Table.1 Target excel file</caption>
	  <tr>
		<th>Required information</th>
		<th>Your answer</th>
	  </tr>
	  <tr>
		<td>Target excel file</td>
		<td><input id=idTargetFile type=file size=60 onchange="kvm.execute('show-target-worksheet')" /></td>
	  </tr>
	  <tr>
		<td>Select target worksheet</td>
		<td><div id=idDivTargetSheet></div></td>
	  </tr>
	  <tr>
		<td>Index column</td>
		<td><input id=idTargetIndex type=text size=1> conlumn letter(s) (A,B,...,AA,AB...)</td>
	  </tr>
	  <tr>
		<td>Destination column</td>
		<td><input id=idTargetColumn type=text size=1> conlumn letter(s) (A,B,...,AA,AB...)</td>
	  </tr>
	  <tr>
		<td>First row</td>
		<td><input id=idTargetFirstRow type=text size=1> number of the first data row (1,2,...)</td>
	  </tr>
	</table></o> drop

	<o> <p><table><caption>Table.2 Reference excel file</caption>
	  <tr>
		<th>Required information</th>
		<th>Your answer</th>
	  </tr>
	  <tr>
		<td>Reference excel file</td>
		<td><input id=idRefFile type=file size=60 onchange="kvm.execute('show-reference-worksheet')" /></td>
	  </tr>
	  <tr>
		<td>Select reference worksheet</td>
		<td><div id=idDivRefSheet></div></td>
	  </tr>
	  <tr>
		<td>Index column</td>
		<td><input id=idRefIndex type=text size=1> conlumn letter(s) (A,B,...,AA,AB...)</td>
	  </tr>
	  <tr>
		<td>Data column</td>
		<td><input id=idRefColumn type=text size=1> conlumn letter(s) (A,B,...,AA,AB...)</td>
	  </tr>
	</table></o> drop
	
	<o> <p><input 
		type=button 
		onclick="kvm.execute('merge-column-to-target')" 
		value="GO!!"
		style="width:120px;height:40px;font-size:20px;margin-left: 50px;"
	></o> drop
	
	: show-target-worksheet ( -- )
		excel.app js: pop().visible=true \ Need to see corresponding columns
		js> idTargetFile.value open.xls dup to objTargetWorkbook
		workbook>sheets \ ( array ) Target workbook sheets' names array
		<js>
			var sheets=pop();
			idDivTargetSheet.innerHTML=""; 
			for(var i=0; i<sheets.length; i++){
				push(i+1+""); // value of a radio button
				push("targetsheet"); // group name of those radio buttons
				execute("input.radio"); // ( -- eleRadioButton )
				idDivTargetSheet.appendChild(pop());
				idDivTargetSheet.innerHTML += sheets[i]+" ";
			}
			document.getElementsByName("targetsheet").item(0).checked=true; // Default first work sheet
		</js> ;
		
	: show-reference-worksheet ( -- )
		excel.app js: pop().visible=true \ Need to see corresponding columns
		js> idRefFile.value open.xls dup to objRefWorkbook
		workbook>sheets \ ( array ) Reference workbook sheets' names array
		<js>
			var sheets=pop();
			idDivRefSheet.innerHTML=""; 
			for(var i=0; i<sheets.length; i++){
				push(i+1+""); // value of a radio button
				push("referencesheet"); // group name of those radio buttons
				execute("input.radio"); // ( -- eleRadioButton )
				idDivRefSheet.appendChild(pop());
				idDivRefSheet.innerHTML += sheets[i]+" ";
			}
			document.getElementsByName("referencesheet").item(0).checked=true; // Default first work sheet
		</js> ;
		
	: merge-column-to-target ( -- ) 
	
		\ Check target file info
		js> $('input[name=targetsheet]:checked').val() int to intTargetSheet
		intTargetSheet if else <js> alert("Don't forget to select the target worksheet!") </js> exit then
		js> idTargetIndex.value if else <js> alert("What's the target file index column?") </js> exit then
		js> idTargetColumn.value if else <js> alert("What's the target file target column?") </js> exit then
		js> idTargetFirstRow.value if else <js> alert("What's the target file first row# ?") </js> exit then
		intTargetSheet objTargetWorkbook js> pop().sheets(pop()) to objTargetWorksheet
		
		\ Check reference file info
		js> $('input[name=referencesheet]:checked').val() int to intRefSheet
		intRefSheet if else <js> alert("Don't forget to select the reference worksheet!") </js> exit then
		js> idRefIndex.value if else <js> alert("What's the reference file index column?") </js> exit then
		js> idRefColumn.value if else <js> alert("What's the reference file data column?") </js> exit then
		intRefSheet objRefWorkbook js> pop().sheets(pop()) to objRefWorksheet
		
		\ 開始拼接 excel 表的欄位
		objRefWorksheet js> idRefIndex.value js> idRefColumn.value
		init-hash dup (see) ( hash-table )
		objTargetWorksheet js> idTargetIndex.value js> idTargetColumn.value 
		js> idTargetFirstRow.value int hash>column 
		objRefWorkbook excel.close
		<o> D o n e !</o>
		;
