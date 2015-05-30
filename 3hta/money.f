
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

	</text> .
	
	\ Convert stock name list to stock ID list
		<text>
			8454富邦媒
			910322康師傅
			910861神州
			4703揚華
			8070長華
			6219富旺
			912398友佳
			1813寶利徠
			6414樺漢
			2809京城銀
			1773勝一
			4747強生
			2064晉椿
			8066來思達
			2612中航
			1264德麥
			3032偉訓
			3443創意
			8427F-基勝
			2851中再保
			4144F-康聯
			8942森鉅
			3296勝德
			8435鉅邁
			2395研華
			3698隆達
			3338泰碩
			8422可寧衛
			2467志聖
			4536拓凱
			2201裕隆
			2204中華
			6231系微
			9941裕融
			2062橋椿
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
			4703
			912398
			8066
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
	
