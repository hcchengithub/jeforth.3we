	\ 沿著 key column 把 hash 裡的 data 添加到指定 column 格上。用途: 疊加 W10W 庫長期借用的解釋。
	\ W10W 庫存原始 database 資料有多欄，嘗試用 barcode 欄當作 key, 讀取料號、Borrower、解釋
	\ 給人員名單加上單位俗稱等欄位。
	\ 用部門代碼查部門
	\ 讀取 excel index(key)-value paris 當成 database 存成 .json 檔。(建立 departmentcode.json)
	\ 分析一 index (or key) 對應多值的情形
	\ 分析【人臉識別】資料, 看某人的上下班時間軌跡。
	\ 把 W10W PMCS 庫存的 Days/U.Rate 緊接其右分置兩欄。
	
	include excel.f

	s" work.f" source-code-header
	
	\ 讀取 departmentcode.json
	char departmentcode.json readTextFileAuto parse constant departmentcode // ( -- departmentcode ) The hash table.

	\ 用部門代碼查部門
		code lookup ( hash key -- value ) \ Lookup the hash table that has partial keys with the full key
			(function(hash,index){ // 查表 return hash[index] or undefined
				for(var i=index.toUpperCase(); i.length>=2; i=i.slice(0,-1)){
					var v = hash[i];
					if(typeof(v)!="undefined") break;
				}
				push(v);
			})(pop(1),pop()); end-code
			/// see-departments' building block.
			/// see-departments 1mm
			
		: (see-dept) ( "deptCode" -- ) \ See the department info 用部門代碼查出某一部門
		    dup . cr
			char DEPT      dup . char : . space js> g.departmentcode[pop()] over lookup . cr
			char DEPT2     dup . char : . space js> g.departmentcode[pop()] over lookup . cr
			char Boss      dup . char : . space js> g.departmentcode[pop()] over lookup . cr
			char Assistant dup . char : . space js> g.departmentcode[pop()] over lookup . cr
			char Site      dup . char : . space js> g.departmentcode[pop()] over lookup . cr
			char BG        dup . char : . space js> g.departmentcode[pop()] over lookup . cr
			char BD        dup . char : . space js> g.departmentcode[pop()] over lookup . cr
			char WKSRD     dup . char : . space js> g.departmentcode[pop()] over lookup . cr
			char JamesYu   dup . char : . space js> g.departmentcode[pop()] over lookup . cr
			char Payroll   dup . char : . space js> g.departmentcode[pop()] over lookup . cr
			drop ;
			/// Usage: 
			/// 	char 1s0k00 (see-dept) \ See the specified department.
			///     see-departments 1s \ See all similar departments.
			
			
		[] value lookup2_results // ( -- array ) lookup2's result, an array of matched keys.
		: lookup2 ( hash key -- ) \ Get all possible keys to lookup2_results
			[] to lookup2_results
			over obj>keys ( hash key keys )
			dup :> length ?dup if dup for dup r@ - ( hash key keys length i )
				<js>
					if(tos(2)[tos()].length >= tos(3).length) {
						if(tos(2)[tos()].slice(0,tos(3).length).toUpperCase()==tos(3).toUpperCase()) 
							g.lookup2_results.push(tos(2)[tos()]);
					}
				</js>
				drop
			( hash key keys length ) next drop then 
			( hash key keys ) 3 drops ;
			/// departmentcode :> DEPT2 char mb lookup2	
			
		: see-departments ( <deptCode> -- ) \ See all possible department info 用部門代碼查部門
			BL word ( key ) departmentcode :> DEPT swap ( hash key ) lookup2
			lookup2_results dup :> length ( array length )
			?dup if dup for dup r@ - ( array length i ) 
				dup . char : . cr
				js> tos(2)[pop()] (see-dept) cr
			( array length ) next drop then drop ;
			/// Usage: 
			/// 	char 1s0k00 (see-dept) \ See the specified department.
			///     see-departments 1s \ See all similar departments.
			
			
	<comment>	
	\ 讀取 excel index(key)-value paris 當成 database 存成 .json 檔。(建立 departmentcode.json)
	\ 原始 database 資料 departments.xlsx 有多欄，最左邊是 key 右邊各欄是 value。
	\ 把 focus 放在左上角的 key 頂，指定 offset# column 執行，產生 hash table object。
	\ 建立【部門代碼資料庫】departmentcode.json
		s" Make sure focus at the top of the excel table index column." js> confirm(pop()) not ?stop
		 1 init-hash2 constant BG
		 2 init-hash2 constant BD
		 3 init-hash2 constant DEPT // 大部門
		 4 init-hash2 constant DEPT2 // 部門細分
		 5 init-hash2 constant JamesYu // 是否在 JamesYu 組織下
		 6 init-hash2 constant Payroll
		 7 init-hash2 constant Site
		 8 init-hash2 constant Boss
		 9 init-hash2 constant Assistant
		10 init-hash2 constant WKSRD // is WKS RD? yes/no
		js> h={BG:{},BD:{},DEPT:{},DEPT2:{},JamesYu:{},Payroll:{},Site:{},Boss:{},Assistant:{},WKSRD:{}}; 
		constant hash
		<js>
		for ( var i in g.DEPT ){
			g.hash.BG[i] = g.BG[i];
			g.hash.BD[i] = g.BD[i];
			g.hash.DEPT[i] = g.DEPT[i];
			g.hash.DEPT2[i] = g.DEPT2[i];
			g.hash.JamesYu[i] = g.JamesYu[i];
			g.hash.Payroll[i] = g.Payroll[i];
			g.hash.Site[i] = g.Site[i];
			g.hash.Boss[i] = g.Boss[i];
			g.hash.Assistant[i] = g.Assistant[i];
			g.hash.WKSRD[i] = g.WKSRD[i];
		}
		</js> 
		hash stringify char departmentcode.json writeTextFile \ Save the hash table
	
	\ 給人員名單加上單位俗稱等欄位。
		departmentcode constant hash \ alias
		\ hash :> DEPT (see) \ see the DEPT hash
		\ hash :> DEPT2 (see) \ see the DEPT2 hash
		\ hash :> Payroll (see) \ see the Payroll hash
		manual
		hash :> DEPT      activeSheet char c ( index ) char i ( destinaton ) 2 ( row ) hash>column2 100 nap
		hash :> DEPT2     activeSheet char c ( index ) char j ( destinaton ) 2 ( row ) hash>column2 100 nap
		hash :> BG        activeSheet char c ( index ) char k ( destinaton ) 2 ( row ) hash>column2 100 nap
		hash :> BD        activeSheet char c ( index ) char l ( destinaton ) 2 ( row ) hash>column2 100 nap
		hash :> JamesYu   activeSheet char c ( index ) char m ( destinaton ) 2 ( row ) hash>column2 100 nap
		hash :> Payroll   activeSheet char c ( index ) char n ( destinaton ) 2 ( row ) hash>column2 100 nap
		hash :> Site      activeSheet char c ( index ) char o ( destinaton ) 2 ( row ) hash>column2 100 nap
		hash :> Boss      activeSheet char c ( index ) char p ( destinaton ) 2 ( row ) hash>column2 100 nap
		hash :> Assistant activeSheet char c ( index ) char q ( destinaton ) 2 ( row ) hash>column2 100 nap
		hash :> WKSRD     activeSheet char c ( index ) char n ( destinaton ) 2 ( row ) hash>column2 100 nap
		auto
	</comment>	
	
	<comment>	
	\ hcchen5600 2015/07/01 21:18:23 
	\ 分析一 index (or key) 對應多值的情形
	\ 為了分析大家回覆的 Michelle 表, 其中有一部門好幾個主管的, 把它製作成 JSON database
	\ 來方便處理。Run 以下得到 michelle.json or hash。 
		{} value hash
		"" value dept
		"" value boss
		"" value sis
		"" value site
		"" value nick
		"" value JamesYu
		cut
		\ 先取部門代碼
		@?stop cell@ remove-leading-ending-white-spaces to dept
		\ init 沒見過的部門
			<js>
			if (!g.hash[g.dept]) {
				g.hash[g.dept] = {};
				g.hash[g.dept]["主管"]={}; // name:count
				g.hash[g.dept]["秘書"]={}; // name:count
				g.hash[g.dept]["上班地"]={}; // name:count
				g.hash[g.dept]["部門俗稱"]={}; // name:count
				g.hash[g.dept]["JamesYu"]={}; // name:count
			}
			</js>
		\ 這個部門代碼同一列有所有資料
			2 ( x ) 0 ( y ) offset :> value remove-leading-ending-white-spaces to boss
			3 ( x ) 0 ( y ) offset :> value remove-leading-ending-white-spaces to sis
			4 ( x ) 0 ( y ) offset :> value remove-leading-ending-white-spaces to site
			5 ( x ) 0 ( y ) offset :> value remove-leading-ending-white-spaces to nick
			7 ( x ) 0 ( y ) offset :> value remove-leading-ending-white-spaces to JamesYu
		\ . . . 都掛進這個 部門 的 object
			boss    [if] js> g.hash[g.dept]["主管"]     js: tos()[g.boss]=tos()[g.boss]+1||1       drop [then]
			sis     [if] js> g.hash[g.dept]["秘書"]     js: tos()[g.sis]=tos()[g.sis]+1||1         drop [then]
			site    [if] js> g.hash[g.dept]["上班地"]   js: tos()[g.site]=tos()[g.site]+1||1       drop [then]
			nick    [if] js> g.hash[g.dept]["部門俗稱"] js: tos()[g.nick]=tos()[g.nick]+1||1       drop [then]
			JamesYu [if] js> g.hash[g.dept]["JamesYu"]  js: tos()[g.JamesYu]=tos()[g.JamesYu]+1||1 drop [then]
		\ 繼續下一列
		down
		1 nap
		rewind
		hash stringify char michelle.json writeTextFile
	\ 以下分析兩個主管等情況
		char michelle.json readTextFileAuto parse constant hash // ( -- obj ) Get the database of Michelle.xls
		> hash :> ["FMZ300"]["主管"] stringify . \ ==> {"Roy Zhu":9,"George Chou":1} OK 
		> hash :> ["FMZ300"]["主管"] memberCount . \ ==> 2 OK 
		> hash memberCount . \ ==> 272 OK 
		\ 列出所有【主管】超過一個以上的部門
			<js>
				for (var i in g.hash) {
					push(i);
					fortheval('hash :> [pop()]["主管"] memberCount 1 >');
					if(pop()) print(i+'\n');
				}
			</js>
			\ 1CK0K0
			\ 1DM600
			\ 1DM700
			\ 1DRZ00
			\ 1DRZ20
			\ 1DRZ30
			\ FMZ200
			\ FMZ300
			\ V0CZ00
		\ 列出所有【部門俗稱】超過一個以上的部門
			<js>
				for (var i in g.hash) {
					push(i);
					fortheval('hash :> [pop()]["部門俗稱"] memberCount 1 >');
					if(pop()) print(i+'\n');
				}
			</js>
			\ 結果
			\ 1CK0K0
			\ 1RRS00
			\ FM1C05
		\ 列出所有【上班地】超過一個以上的部門
			<js>
				for (var i in g.hash) {
					push(i);
					fortheval('hash :> [pop()]["上班地"] memberCount 1 >');
					if(pop()) print(i+'\n');
				}
			</js>
			\ 1D0Q00 x
			\ 1KC720 x
			\ 1M0QK0 x
			\ 1MM220 v
		\ 列出所有【秘書】超過一個以上的部門
			<js>
				for (var i in g.hash) {
					push(i);
					fortheval('hash :> [pop()]["秘書"] memberCount 1 >');
					if(pop()) print(i+'\n');
				}
			</js>
			\ 1MM220 v
		\ 列出所有【JamesYu】超過一個以上的部門
			<js>
				for (var i in g.hash) {
					push(i);
					fortheval('hash :> [pop()]["JamesYu"] memberCount 1 >');
					if(pop()) print(i+'\n');
				}
			</js>
			\ 無
			
	</comment>	
	<comment>	
	\ 分析一 index (or key) 對應多值的情形 : 檢查 PE/TE/PME 表,看有效部門代碼可以省幾個 charactor。
	\ 來方便處理。Run 以下得到 tepepme.json or hash。 
		manual
		char E2 jump \ 先 focus 在部門代碼的最頂。
		{} value hash
		"" value dept
		"" value nick
		"" value boss
		"" value sis
		"" value BU
		"" value site
		cut
		\ 先取部門代碼
		@?stop cell@ remove-leading-ending-white-spaces to dept
		\ init 沒見過的部門
			<js>
			if (!g.hash[g.dept]) {
				g.hash[g.dept] = {};
				g.hash[g.dept]["主管"]={}; // name:count
				g.hash[g.dept]["秘書"]={}; // name:count
				g.hash[g.dept]["上班地"]={}; // name:count
				g.hash[g.dept]["部門俗稱"]={}; // name:count
				g.hash[g.dept]["BU"]={}; // name:count
			}
			</js>
		\ 這個部門代碼同一列有所有資料
			2 ( x ) 0 ( y ) offset :> value remove-leading-ending-white-spaces to site
			3 ( x ) 0 ( y ) offset :> value remove-leading-ending-white-spaces to nick
			4 ( x ) 0 ( y ) offset :> value remove-leading-ending-white-spaces to boss
			5 ( x ) 0 ( y ) offset :> value remove-leading-ending-white-spaces to sis
			6 ( x ) 0 ( y ) offset :> value remove-leading-ending-white-spaces to BU
		\ . . . 都掛進這個 部門 的 object
			boss [if] js> g.hash[g.dept]["主管"]     js: tos()[g.boss]=tos()[g.boss]+1||1 drop [then]
			sis  [if] js> g.hash[g.dept]["秘書"]     js: tos()[g.sis]=tos()[g.sis]+1||1   drop [then]
			site [if] js> g.hash[g.dept]["上班地"]   js: tos()[g.site]=tos()[g.site]+1||1 drop [then]
			nick [if] js> g.hash[g.dept]["部門俗稱"] js: tos()[g.nick]=tos()[g.nick]+1||1 drop [then]
			BU	 [if] js> g.hash[g.dept]["BU"]       js: tos()[g.BU]=tos()[g.BU]+1||1     drop [then]
		\ 繼續下一列
		down
		1 nap
		rewind
		auto
		hash stringify char tepepme.json writeTextFile
	\ 以下分析兩個主管等情況
		char tepepme.json readTextFileAuto parse constant hash // ( -- obj ) Get the database of Michelle.xls
		> hash :> ["FMZ300"]["主管"] stringify . \ ==> {"Roy Zhu":9,"George Chou":1} OK 
		> hash :> ["FMZ300"]["主管"] memberCount . \ ==> 2 OK 
		> hash memberCount . \ ==> 272 OK 
		\ 列出所有【主管】超過一個以上的部門
			<js>
				for (var i in g.hash) {
					push(i);
					fortheval('hash :> [pop()]["主管"] memberCount 1 >');
					if(pop()) print(i+'\n');
				}
			</js>
			\ 無
			
		\ 列出所有【部門俗稱】超過一個以上的部門
			<js>
				for (var i in g.hash) {
					push(i);
					fortheval('hash :> [pop()]["部門俗稱"] memberCount 1 >');
					if(pop()) print(i+'\n');
				}
			</js>
			\ 無
			
		\ 列出所有【上班地】超過一個以上的部門
			<js>
				for (var i in g.hash) {
					push(i);
					fortheval('hash :> [pop()]["上班地"] memberCount 1 >');
					if(pop()) print(i+'\n');
				}
			</js>
			\ 1D0Q00 x
			\ 1R0S00 x
			\ 1ST700 x			
			
		\ 列出所有【秘書】超過一個以上的部門
			<js>
				for (var i in g.hash) {
					push(i);
					fortheval('hash :> [pop()]["秘書"] memberCount 1 >');
					if(pop()) print(i+'\n');
				}
			</js>
			\ 無

		\ 列出所有【BU】超過一個以上的部門
			<js>
				for (var i in g.hash) {
					push(i);
					fortheval('hash :> [pop()]["BU"] memberCount 1 >');
					if(pop()) print(i+'\n');
				}
			</js>
			\ 無
	</comment>		
	<comment>		
	\ 分析【人臉識別】資料, 看某人的上下班時間軌跡。
		\ 直接在 excel 各人的 worksheet 上標【上班】，【下班】時間
		\ E2 開始，一路往下只要【當格】有值就繼續做。當天第一筆標【上班】，最後一筆標【下班】。
	
		{} value table // name:{time:[日期時間],type:[上下班]}
		"" value name // recent person
		
	\ 先把所有人的上下班時間都抓到 json, (這個後來沒用)
		
		char c2 jump cell@ to name \ get name
		table :: [g.name]={}      \ init the person
		table :: [g.name].time=[] \ init the person
		table :: [g.name].type=[] \ init the person
	
		\ 一路往下只要【當格】有值(姓名) 就讀進日期時間、type。
		cut @?stop ( 判斷 )
		\ ---------- do ----------------
		2 0 offset :> value js: g.table[g.name].time.push(pop())
		3 0 offset :> value js: g.table[g.name].type.push(pop())
		\ ---------- do ----------------
		down ( 移位 ) 1 nap rewind ( 重複 )
	
	\ 全部印出來 (抓進 table 的 data)
		: printDateTime ( time -- ) \ print date time from excel like 2015-05-04 08:29 02
			vb> Year(kvm.tos())    . char - .
			vb> Month(kvm.tos())   2 .0r char - .
			vb> Day(kvm.tos())     2 .0r space   
			vb> Hour(kvm.tos())    2 .0r char : .
			vb> Minute(kvm.tos())  2 .0r space
			vb> WeekDay(kvm.pop()) 2 .0r cr ;
		
		<js>
			for (var n in g.table){
				for(var i=0; i<g.table[n].time.length; i++){
					print(n + " : "+ g.table[n].type[i] + " : ")
					push(g.table[n].time[i]);
					execute('printDateTime');
				}
			}
		</js>
		
	\ 直接在 excel 各人的 worksheet 上標【上班】，【下班】時間
	\ 不考慮熬過夜的情形,因為中途有出門就會被當成下班,故熬過夜的情形無法判斷。
	\ 當天第一筆當作上班, 當天最後一筆當作下班。與紀錄比對,一般都吻合。不吻合的可能就是熬過夜的情形。
	
		0 value 當天 // ( -- excelTime ) 目前掃描到這天的資料

		: 同一天 ( time1 time2 -- boolean ) \ excel time
			vb> Day(kvm.tos())=Day(kvm.tos(1)) >r
			vb> Month(kvm.tos())=Month(kvm.tos(1)) >r
			vb> Year(kvm.pop())=Year(kvm.pop())
			r> r> and and 
		;

	    \ E2 開始，一路往下只要【當格】有值就繼續做。當天第一筆標【上班】，最後一筆標【下班】。
		char e2 jump
		cell@ to 當天
		4 0 offset :: value="上班"
		down
		cut 
		\ ---------- do ----------------
		cell@ 當天 同一天 [if] [else] 
			4 -1 offset :: value="下班"
			4  0 offset :: value="上班"
			cell@ to 當天
		[then]
		\ ---------- do ----------------
		down ( 移位 ) 1 nap empty? not ?rewind ( 重複 ) \ 大驚奇! excel time 值屬 (Date) type 其 boolean 有可能是 false !!
		4 -1 offset :: value="下班"

	\ 讀取 excel index(key)-value paris 當成 database 存成 .json 檔。(建立 departmentcode.json)
	\ "c:\Users\8304018\Dropbox\work\2015\misc\W10W RD test inventory control\SAP與PMCS日期對比.xlsx" > worksheet:機台物料超過180天說明
	\ W10W 庫存原始 database 資料有多欄，嘗試用 barcode 欄當作 key, 讀取料號、Borrower、解釋
	\ 把 focus 放在 Barcode 欄 key 頂，指定 offset# column 執行，產生 hash table object。
	\ 建立 W10W 庫存資料
		s" Make sure focus at the top of the excel table index column." js> confirm(pop()) not ?stop
		  0 init-hash2 constant 條碼   
		 -2 init-hash2 constant 料號   
		 -1 init-hash2 constant 品名   
		  5 init-hash2 constant 保管人 
		  6 init-hash2 constant 工號   
		  7 init-hash2 constant 部門   
		 15 init-hash2 constant 解釋   
		js> h={料號:{},品名:{},保管人:{},工號:{},部門:{},解釋:{}}; 
		constant hash
		<js>
		for ( var i in g.條碼 ){
			g.hash.料號[i] = g.料號[i];
			g.hash.品名[i] = g.品名[i];
			g.hash.保管人[i] = g.保管人[i];
			g.hash.工號[i] = g.工號[i];
			g.hash.部門[i] = g.部門[i];
			g.hash.解釋[i] = g.解釋[i];
		}
		</js> 
	\ 給W10W新的庫存報表加上以前的解釋
		manual
		hash :> 品名   activeSheet char m ( index ) char t ( destinaton ) 2 ( row ) hash>column2 100 nap
		hash :> 保管人 activeSheet char m ( index ) char u ( destinaton ) 2 ( row ) hash>column2 100 nap
		hash :> 工號   activeSheet char m ( index ) char v ( destinaton ) 2 ( row ) hash>column2 100 nap
		hash :> 部門   activeSheet char m ( index ) char w ( destinaton ) 2 ( row ) hash>column2 100 nap
		hash :> 解釋   activeSheet char m ( index ) char x ( destinaton ) 2 ( row ) hash>column2 100 nap
		auto

	\ 沿著 key column 把 hash 裡的 data 添加到指定 column 格上。用途: 疊加 W10W 庫長期借用的解釋。
	\ hash 用 init-hash2 取得。
		( Hash "colKey" "colValue" top-row# -- ) \ 疊加 W10W 庫長期借用的解釋。
		<js>
			var top=pop(), colValue=pop(), colKey=pop(), hash=pop();
			execute("activeSheet"); var sheet=pop();
			var key = sheet.range(colKey  +":"+colKey);
			var val = sheet.range(colValue+":"+colValue);
			push(key); execute("bottom"); var bottom = pop();
			for (var i=top; i<=bottom; i++) {
				if (key(i).value == undefined ) continue;
				if (lookup(key(i).value)== undefined) continue;
				val(i).value = lookup(key(i).value) + '\n' + val(i).value;
			}
			// key(i).value 就是本表的 key 或 index 值, 
			// 透過 lookup(index) 查 hash 表，方便改寫來適應各種狀況。
			// 失敗時傳回 undefined。
			function lookup(index){ // return hash[index] or undefined
				var i = index.replace(/(^( |\t)*)|(( |\t)*$)/g,''); // remove 頭尾 whitespaces
				var v = hash[i];
				return v;
			}
		</js>
	
	\ 把 W10W PMCS 庫存的 Days/U.Rate 緊接其右分置兩欄。
		\ <js> ("0/").match(/^\s*(.*?)\s*\/\s*(.*?)\s*$/) </jsV> . 傳回 null 或 array[原 string][前][後]
		\ Days/U.Rate 都有值, 用 @?stop ( -- ) Stop if the activeCell is not value [colon][excel.f][][] 
		s" 確定 focus 在 Days/U.Rate 欄最頂端?" js> confirm(pop()) not ?stop
		0 value data // ( -- data ) Recent cell data
		cut 
		@?stop 
		cell@ <js> pop().match(/^\s*(.*?)\s*\/\s*(.*?)\s*$/) </jsV> to data
		data [if] 
			1 0 offset :: value=g.data[1];
			2 0 offset :: value=g.data[2]; 
		[else]	
			stop
		[then]
		down 1 nap rewind
		
	\ 比對 W10W PMCS 庫存與 SAP 庫存，把所有同一料號的數量都加起來比對。
			
		\ PMCS 部分
			s" 確定是 PMCS 報表?" js> confirm(pop()) not ?stop
			{} value pmcs	// ( -- hash ) { pn:count }
			"" value pn
			char F2 jump
			cut 
			@?stop 
			cell@ to pn
			11 0 offset :> value ( q'ty )
			pmcs :> [g.pn]||0 ( q'ty value ) 
			+ dup ( sum sum ) 
			pmcs :: [g.pn]=pop() ( sum )
			pn . space char = . . cr
			down 1 nap rewind
			
		\ SAP 部分
			s" 確定是 SAP 報表?" js> confirm(pop()) not ?stop
			{} value sap    // ( -- hash ) { pn:count }
			"" value pn
			char B2 jump
			manual excel.invisible
			cut 
			@?stop 
			cell@ to pn
			2 0 offset :> value ( q'ty )
			sap :> [g.pn]||0 ( q'ty value ) 
			+ dup ( sum sum ) 
			sap :: [g.pn]=pop() ( sum )
			pn . space char = . space . space space
			down 1 nap rewind
			excel.visible auto
	
		\ 逐料號比對兩部分的數量
			<js>
				for(var pn in g.sap) if(g.sap[pn]!=g.pmcs[pn]) print(pn+" ");
			</js>

	\ 比對 兩個 excel 表中的項目差異，例如前後不同月份帳上的增減。
		\ 如何用 barcode 或任何 key 比對兩表的差異? 先各自取得所有的 key:count pair. 分別為 table1 table2。
		\ 循 Table1 所有的 key 到 table2 裡去找, 找到了就兩邊都 count+=1. 比對兩表，一趟就可以了。
		\ 此後檢查兩表, count==1 者是唯一的、差異的、或遺漏的。 count==2 是一致的、重複的、或吻合的。意義視用途而定。
		
			\ 第 n 張表, 起始準備、防呆
			s" 確定是 某某 報表?" js> confirm(pop()) not ?stop
			char B2 value starting-position // ( -- "A1" ) Excel cell position
			s" 確定是 開始 focus cell 位置是 " starting-position + js> confirm(pop()) not ?stop
			starting-position jump 
			
			{} value hash  // ( -- hash ) { pn:count }
			"" value key
			manual excel.invisible
			cut 
			@?stop 
			cell@ to key
			hash :: [g.key]=1
			down 10 nap rewind
			excel.visible auto
		
			\ 比對兩表
			<js>
				for(var i in g.明明的總表){
					if(g.盼盼的總表[i]){
						g.盼盼的總表[i] += 1;
						g.明明的總表[i] += 1;
					}
				}
			</js>
			
			\ 標出不吻合的 barcode 
			s" 確定是 盼盼的 報表?" js> confirm(pop()) not ?stop
			char G2 value starting-position // ( -- "A1" ) Excel cell position
			s" 確定是 開始 focus cell 位置是 " starting-position + js> confirm(pop()) not ?stop
			starting-position jump 
			manual excel.invisible
			cut 
			@?stop 
			cell@ js> g.盼盼的總表[pop()]==1 [if] 22 0 offset :: value="唯一" [then]
			down 10 nap rewind
			excel.visible auto

			\ 標出不吻合的 barcode 
			s" 確定是 明明的 報表?" js> confirm(pop()) not ?stop
			char h2 value starting-position // ( -- "A1" ) Excel cell position
			s" 確定是 開始 focus cell 位置是 " starting-position + js> confirm(pop()) not ?stop
			starting-position jump 
			manual excel.invisible
			cut 
			@?stop 
			cell@ js> g.明明的總表[pop()]==1 [if] 15 0 offset :: value="唯一" [then]
			down 10 nap rewind
			excel.visible auto
			
			
	</comment>		
