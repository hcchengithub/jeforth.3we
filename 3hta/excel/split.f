\  ------------ 把一張 Excel 表按各部門拆分成多個檔案 ----------------------------

s" split.f" source-code-header

	\ objSourceWorksheet    ( -- worksheet ) sheet(source)
	\ js> idKeyColumn.value	( -- 'column' )	 部門俗稱欄 		
	\ js> idFirstRow.value	( -- row# )		 部門俗稱欄top    	
	\ js> idTitleRows.value	( -- "row:row" ) 標題列    			
	\ keyColumnBottom		( -- row# )		 部門俗稱欄bottom
	\ keyHashTable			( -- hash )		 部門俗稱表

	\ js> idSourceFile		( -- element ) Input type=file element
	\ js> idKeyColumn		( -- element ) Input type=text source worksheet key column
	\ js> idTitleRows		( -- element ) Input type=text source worksheet title row(s)
	\ js> idFirstRow		( -- element ) Input type=text source worksheet data first row
	0 value objSourceWorkbook	// ( -- workbook ) workbook object
	0 value intSourceSheet		// ( -- int ) Sheet number
	0 value objSourceWorksheet	// ( -- worksheet ) worksheet object, was sheet(source)
	0 value 標題列數 			// ( -- n ) Count of title rows
	0 value keyColumnBottom		// ( -- row# ) The row number of the last row at the bottom
	0 value keyHashTable		// ( -- hash-table ) {<name>:count,...}
	
	<h>	<style></style></h> constant tableStyle // ( -- eleStyle ) The style element of my questionnaire table
	s" table, th, td {border: 1px solid black;border-collapse: collapse;margin-left: 50px;padding:12px;}" tableStyle js: pop().innerHTML=pop()

	<o> <p><table><caption>Table.1 Source excel file</caption>
	  <tr>
		<th>Required information</th>
		<th>Your answer</th>
	  </tr>
	  <tr>
		<td>Source excel file</td>
		<td><input id=idSourceFile type=file size=60 onchange="kvm.execute('show-source-worksheet')" /></td>
	  </tr>
	  <tr>
		<td>Select source worksheet</td>
		<td><div id=idDivSourceSheet></div></td>
	  </tr>
	  <tr>
		<td>Key column</td>
		<td><input id=idKeyColumn type=text size=1> conlumn letter(s) (A,B .. AA,AB ...)</td>
	  </tr>
	  <tr>
		<td>Title rows</td>
		<td><input id=idTitleRows type=text size=2> from:to row numbers (1:2,3:5 .. etc)</td>
	  </tr>
	  <tr>
		<td>First row</td>
		<td><input id=idFirstRow type=text size=1> number of the first data row (1,2,...)</td>
	  </tr>
	  <tr>
		<td><input type=button onclick="kvm.execute('列出key欄成員')" value="Test"></td>
		<td><Div id=idCheckKeyColumn></Div></td>
	  </tr>
	</table></o> drop
	
	<o> <p><input 
		type=button 
		onclick="kvm.execute('split-groups-of-rows-to-excel-files')" 
		value="GO!!"
		style="width:120px;height:40px;font-size:20px;margin-left: 50px;"
	></o> drop

	: show-source-worksheet ( -- )
		excel.app js: pop().visible=true \ Need to see corresponding columns
		js> idSourceFile.value open.xls dup to objSourceWorkbook
		workbook>sheets \ ( -- array ) Source workbook sheets' names array
		<js>
			var sheets=pop();
			idDivSourceSheet.innerHTML=""; 
			for(var i=0; i<sheets.length; i++){
				push(i+1+""); // value of a radio button
				push("sourcesheet"); // group name of those radio buttons
				execute("input.radio"); // ( -- eleRadioButton )
				idDivSourceSheet.appendChild(pop());
				idDivSourceSheet.innerHTML += sheets[i]+" ";
			}
			document.getElementsByName("sourcesheet").item(0).checked=true; // Default first work sheet
		</js> 
	;

	: check ( -- sthWrong? ) \ Check the input completeness of Source Sheet,Key Column.
		true ( Yes, something wrong )
		js> $('input[name=sourcesheet]:checked').val() int to intSourceSheet
		intSourceSheet if else <js> alert("Don't forget to select the source worksheet!") </js> exit then
		js> idKeyColumn.value if else <js> alert("What's the key column?") </js> exit then
		intSourceSheet objSourceWorkbook js> pop().sheets(pop()) to objSourceWorksheet
		js> idKeyColumn.value objSourceWorksheet js> pop().columns(pop()) bottom to keyColumnBottom ( -- row# )
		js> idTitleRows.value if else <js> alert("What're the title rows?") </js> exit then
		js> idTitleRows.value objSourceWorksheet js> pop().rows(pop()).count to 標題列數 ( -- n )
		js> idFirstRow.value if else <js> alert("What's the target file first row?") </js> exit then
		drop false ;
		/// Define intSourceSheet objSourceWorksheet keyColumnBottom and 標題列數 if everything is fine.
	
	: 列出key欄成員 ( -- ) \ Event handler of the [Test] button.
		check if exit then objSourceWorksheet keyColumnBottom
		<js>
			var column = pop(1).columns(idKeyColumn.value);
			var members = {}, count=pop();
			for ( var i=parseInt(idFirstRow.value); i<=count; i++ ){
				members[column.rows(i).value]=1;
			}
			idCheckKeyColumn.innerHTML="";
			for ( var i in members){
				if(idCheckKeyColumn.innerHTML=="") idCheckKeyColumn.innerHTML = i;
				else idCheckKeyColumn.innerHTML += ", "+i;
			}
		</js> ; 
		
	: keyColumn>hash ( -- hash ) \ 把 keyColumn 整理成 hash table {<name>:count,...}
		js> idKeyColumn.value  objSourceWorksheet  js> idFirstRow.value  keyColumnBottom 
		<js>
			var bottomRow=pop(), firstRow=parseInt(pop()), worksheet=pop(), keyCol=pop();
			var column=worksheet.range(keyCol+":"+keyCol);
			var hash = {};
			for ( var i=firstRow; i<=bottomRow; i++ ){
				hash[column(i).value] = (hash[column(i).value] == undefined) ? 1 : hash[column(i).value] + 1;
			} 
			push(hash); // return value of the <js>..<//js> section
		</js> ; 

	: 建立各部門的worksheet ( -- ) \ Works on objSourceWorkbook
		objSourceWorksheet  標題列數  js> idTitleRows.value  objSourceWorkbook  keyHashTable 
		<js>
			for (var i in tos() ) {
				var newsheet = tos(1).sheets.add;
				newsheet.name = i;
				tos(4).rows(tos(2)).copy;
				newsheet.paste(newsheet.rows("1:"+tos(3)));
			}
		</jsN> 5 drops 
	;

	: 分發總表到各部門的worksheet ( -- )
		js> idKeyColumn.value  objSourceWorkbook  objSourceWorksheet  js> idFirstRow.value  keyColumnBottom
		<js>
			var rowEnd=pop(), rowStart=parseInt(pop()), sheet=pop(), workbook=pop(), dept_name_column_letter=pop();
			var dept_name_Column = sheet.columns(dept_name_column_letter+':'+dept_name_column_letter);
			for (var row=rowStart; row<=rowEnd; row++){
				var worksheet_name = dept_name_Column.rows(row).value;
				var tgt_worksheet = workbook.sheets(worksheet_name);
				sheet.rows(row).copy;
				push(tgt_worksheet.columns(dept_name_column_letter)); fortheval("bottom"); var tgt_row=pop()+1;
				tgt_worksheet.paste(tgt_worksheet.rows(tgt_row));
			}
		</js> ;

	: 各部門的worksheet存成xls檔 ( -- )
		excel.app dup js> pop().workbooks.count 1+  \ new workbook's ID 
		objSourceWorkbook js> pop().path  
		( excel.app )  ( workbook# )  ( path )  objSourceWorkbook  keyHashTable
		<js>
			for (var i in tos() ) {
				var pathname = tos(2) + "\\" + i + ".xls";
				tos(1).worksheets(i).copy; /* copy the worksheet to a new xls file in memory */
				var workbook = tos(4).workbooks(tos(3));
				push(workbook); push(pathname); 
				fortheval("over excel.save-as swap excel.close and [if] [else] char Panic>> *debug* [then]");
			}
		</js> 5 drops ;
		
	: split-groups-of-rows-to-excel-files ( -- ) 
		check if exit then
		keyColumn>hash to keyHashTable
		建立各部門的worksheet
		beep ." Now wait! 分發總表 to each worksheet takes a lot of time." cr 10 sleep
		分發總表到各部門的worksheet
		各部門的worksheet存成xls檔
		\ objSourceWorkbook excel.close drop
		<o> D o n e !</o> drop ;

<comment>
	分發總表到各部門的worksheet takes too much time. 
	I don't want to use JSON because I want to copy the format also.
	I hope batch would help. Which is to copy all rows to array and then paste
	each array to their worksheet.
</comment>
