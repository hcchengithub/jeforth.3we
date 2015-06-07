
\ utf-8	
\ 改良版，只要把 activeCell 放在 stackID 行的開頭，執行 command 即可在元大的除權除息表左邊加上
\ ID column; 類似的方式把 StackID column 展開成 DDE table of 富邦的即時 dynamic information.
\ e01 copy 過來的

	include excel.f

	s" money.f" source-code-header


	js> [6457,8027] constant category_TE // ( -- [...] ) These Stock's formula is =XQFAP|Quote!'6457.TE-Name' not .TW-Name.
	
	: DDE-formula ( -- ) \ ActiveCell 在一列最左邊的 stockID 上，自動向右設定全部 DDE 公式。
		activeCell :> column 1 cell :> value ( formula )
		dup :> indexOf("|Quote!'")==-1 ?abort" ActiveCell at wrong position, wrong formula see TOS."
		activeCell :> column ( x )
		activeCell :> row ( y )
		activeCell :> value ( -- formula x y id )
		<js>
		var id=pop(), y=pop(), x=pop(), formula=pop();
		for (var i=1; i<=8; i++) {
			var ss = formula + id + '.'; // StockID
			for (var category='TW',j=0; j<g.category_TE.length; j++){
				if(id==g.category_TE[j]) category='TE';
			}
			ss += category + '-'; // category TW or TE
			push(x+i);fortheval("1 cell :> value"); ss += pop() + "'"; // Name
			push(i);fortheval("0 offset");pop().formula=ss;
		}
		</js> ;
		/// Usage: 
		/// 1. activeCell at the first StockID in the "e01" worksheet,
		/// 2. manual ' DDE-formula repeat-down auto

	: interested ( -- ) \ ActiveCell 在最上方的 ID 上，自動抄左邊的 DDE 像下到底。
		1 ( i=1... ) 0 0 offset :> value ( i ID )
		begin ( i ID )
			-1 js> tos(2) ( i id -1 i ) offset :> formula ?dup ( i id F|formula formula )
		while 
			:> replace(/'.+\./,"'"+tos()+".") ( i id formula' ) 
			0 js> tos(3) offset :: formula=pop() ( i id )
		js: push(pop(1)+1,0) ( i++ ) repeat ( i id )
		2drop ;
		/// Usage: 
		/// 1. activeCell at the StockID on top of the interested stock column in interested.xlsx file
		/// 2. manual interested auto <-- 若忘了用 manula .. auto 保護起來，會變得很慢很慢。
		///    manual ' interested repeat-right auto
		
	: repeat-right ( cmd -- ) \ if (activeCell.value) then do the given forth 'cmd' then move right and repeat
		dup :> constructor!=Word ?abort" The given command (the TOS) is not a forth word."
		begin ( cmd ) 0 0 offset :> value!=undefined while 
			dup execute 
			1 0 offset :: activate 
		repeat drop ;
		/// manual ' interested repeat-right auto
		
	: ctrl<- ( -- ) \ 把右邊一格的 "8942森鉅" 抄過來變成 "8942"
		1 0 offset :> value ?dup if 
			<js> pop().replace(/(^( |\t)*)|(( |\t)*$)/g,'')</jsV> \ remove 頭尾 white spaces
			:> match(/^\d+/) int \ 只抓開頭的數字
			0 0 offset :: value=pop() 
		else	
			0 0 offset :: clear() \ 令 activeCell 清除，表示右邊一格沒東西。
		then ;
		/// 整個做完了的線索 0 0 offset :> value==undefined is true 
		/// Usage: manual ' ctrl<- repeat-down auto
		
	: remove"\r\n" ( {clipboard} -- {clipboard}' ) \ Remove \r\n from clipboard
		js> clipboardData.getData("text")
		:> replace(/\r\n/g,"")
		js: clipboardData.setData("text",pop()) ;
		/// 從網頁上 copy 表格下來 paste to excel 往往發現 title row 不對，因為
		/// 其中有 \r\n 之故。先 copy 好資料，跑一下本 command 然後去 excel paste
		/// 即可，隨後再轉貼別地方。用 multiplicity 在兩台電腦間來回處理無誤。

	: repeat-down ( cmd -- ) \ Do the given forth 'cmd' then if (activeCell.value) go down and repeat
		dup :> constructor!=Word ?abort" The given command (the TOS) is not a forth word."
		begin dup execute 
		0 0 offset :> value!=undefined while 
		0 1 offset :: activate repeat drop ;
		/// 應用一、把右邊一格的 "8942森鉅" 抄過來變成 "8942", 往「下」重複到右邊沒有了為止。
		///   1. activeCell at the index column which is at the lest side of the
		///      table copy-past from 元大除權除息表網站，
		///   2. manual ' ctrl<- repeat-down auto
		/// 應用二、設定整張表的 DDE formula，
		///   1. activeCell at the first StockID in the "e01" worksheet,
		///   2. manual ' DDE-formula repeat-down auto

	: float-them ( -- ) \ Convert selection to float with isNaN() error check
		selection ( obj ) <js>
			var selection=pop();
			for (var i=1; i<=selection.count; i++){
				var vv = selection.item(i).value;
				if(isNaN(vv)) {
					print("Item " + i + " value " + vv + " is NaN!\n");
					continue;
				}
				selection.item(i).value=parseFloat(vv);
			}
		</js> ;
		/// Usage: 
		/// 1. Mark an area.
		/// 2. Run: manual float-them auto
		
<comment>		

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

	</text>
	
	\ Convert stock name list to stock ID list
		<text>
			1264德麥
			1590F-亞德
			1773勝一
			1813寶利徠
			2062橋椿
			2063世鎧
			2064晉椿
			2201裕隆
			2204中華
			2395研華
			2467志聖
			2597潤弘
			2612中航
			2637F-慧洋
			2809京城銀
			2851中再保
			2916滿心
			3032偉訓
			3296勝德
			3338泰碩
			3443創意
			3563牧德
			3658漢微科
			3698隆達
			4144F-康聯
			4536拓凱
			4703揚華
			4747強生
			5388中磊
			6023元大期
			6219富旺
			6231系微
			6414樺漢
			6457紘康
			8027鈦昇
			8066來思達
			8070長華
			8422可寧衛
			8427F-基勝
			8435鉅邁
			8942森鉅
			912398友佳
			9941裕融
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
			2916
			5388
			6457
			8027
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

	fubon e01 all DDE formula
		1	2	3	4	5	6	7	8	9	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	25	26	27	28	29	30	31	32	33	34	35	36	37	38	39	40	41	42	43	44	45	46	47	48	49	50	51	52	53	54	55	56	57	58	59	60	61	62	63	64	65	66	67	68	69	70	71	72	73	74	75	76	77	78	79	80	81	82	83	84	85	86	87	88	89	90	91	92	93	94	95	96	97	98	99	100	101	102	103	104	105	106	107	108	109	110	111	112	113	114	115	116	117	118	119	120	121	122	123	124	125	126	127	128	129	130	131	132	133	134	135	136	137	138	139	140	141	142	143	144	145	146	147	148	149	150	151	152	153	154	155	156	157	158	159	160	161	162	163	164	165	166	167	168	169	170	171	172	173	174	175	176	177	178	179	180	181	182	183	184	185	186	187	188	189	190	191	192	193	194	195	196	197	198
		代碼	商品	交易日期	時間	買進	賣出	成交	漲跌	漲幅%	振幅%	單量	總量	委買	委賣	最高	最低	開盤	昨收	均價	漲停	跌停	內盤	外盤	內外盤比%	內外盤比圖	前一	前二	前三	前四	昨量	盤後量	買進一	買進二	買進三	買進四	買進五	賣出一	賣出二	賣出三	賣出四	賣出五	委買一	委買二	委買三	委買四	委買五	總委買	委賣一	委賣二	委賣三	委賣四	委賣五	總委賣	累計委買	累委買筆	委買均	累計委賣	累委賣筆	委賣均	累計成交	累成交筆	成交均	內盤家	外盤家	上漲家	下跌家	平盤家	漲停家	跌停家	上漲量	下跌量	平盤量	幣別	銀行	銀行名稱	外匯價	前匯價	RS%	RSL	Beta	一週%	一月%	一季%	半年%	一年%	YTD%	公司動態	產業地位	未平倉	未平倉變化	結算價	基差	價差	內含值	時間價值	歷史波動率%	履約率%	理論價	Delta	Gamma	Theta	Vega	Rho	隱含波動率%	買賣價差	買賣價差%	隱含履約率%	量P/C	倉P/C	保證金	權利金	累買成筆	累賣成筆	成交值	成交比重%	存續期間	代碼	商品	中文簡稱	中文全名	英文簡稱	英文全名	交易單位	類型	標的股	執行比例	履約價	限制價	最後交易日	到期日	剩餘日	內含價值	價內外%	有效槓桿比例	買進隱含波動率%	賣出隱含波動率%	標的價格	標的漲跌	標的漲幅%	波動率差額	市值	淨利	盈餘	盈餘(單)	盈餘(4)	盈餘(累)	營收	營收(12)	營收期增率%	營收年增率%	每股淨值	毛利率%	營益率%	稅後淨利率%	每股營收	ROE%	營業利益成長率%	稅前淨利成長率%	稅後淨利成長率%	PE(市盈率)	PB(市淨率)	資產報酬率%	流動比率%	速動比率%	負債比率%	利息保障倍數	應收帳款週轉率%	存貨週轉率%	固定資產週轉率%	總資產週轉率%	員工平均營業額	淨值週轉率%	現金股利	股票股利	現金+股票股利	現金流量	應收帳款	上市日期	委比	委買賣差	換手率%	量比	股數	股本	殖利率%	溢價率%	損益兩平	暫停交易時間	恢復交易時間	暫緩收盤	發行財務費用	流通在外張數	流通在外比率%	現股距回收價%	財務費用(日)	財務費用率%	試算買價	試算賣價
		=XQFAP|Quote!'2597.TW-ID'	=XQFAP|Quote!'2597.TW-Name'	=XQFAP|Quote!'2597.TW-TradingDate'	=XQFAP|Quote!'2597.TW-Time'	=XQFAP|Quote!'2597.TW-Bid'	=XQFAP|Quote!'2597.TW-Ask'	=XQFAP|Quote!'2597.TW-Price'	=XQFAP|Quote!'2597.TW-PriceChange'	=XQFAP|Quote!'2597.TW-PriceChangeRatio'	=XQFAP|Quote!'2597.TW-Amplitude'	=XQFAP|Quote!'2597.TW-Volume'	=XQFAP|Quote!'2597.TW-TotalVolume'	=XQFAP|Quote!'2597.TW-BestBidSize'	=XQFAP|Quote!'2597.TW-BestAskSize'	=XQFAP|Quote!'2597.TW-High'	=XQFAP|Quote!'2597.TW-Low'	=XQFAP|Quote!'2597.TW-Open'	=XQFAP|Quote!'2597.TW-PreClose'	=XQFAP|Quote!'2597.TW-AvgPrice'	=XQFAP|Quote!'2597.TW-UpLimit'	=XQFAP|Quote!'2597.TW-DownLimit'	=XQFAP|Quote!'2597.TW-InSize'	=XQFAP|Quote!'2597.TW-OutSize'	=XQFAP|Quote!'2597.TW-InOutRatioNumber'	=XQFAP|Quote!'2597.TW-InOutRatio'	=XQFAP|Quote!'2597.TW-PrePrice1'	=XQFAP|Quote!'2597.TW-PrePrice2'	=XQFAP|Quote!'2597.TW-PrePrice3'	=XQFAP|Quote!'2597.TW-PrePrice4'	=XQFAP|Quote!'2597.TW-PreTotalVolume'	=XQFAP|Quote!'2597.TW-PostSize'	=XQFAP|Quote!'2597.TW-BestBid1'	=XQFAP|Quote!'2597.TW-BestBid2'	=XQFAP|Quote!'2597.TW-BestBid3'	=XQFAP|Quote!'2597.TW-BestBid4'	=XQFAP|Quote!'2597.TW-BestBid5'	=XQFAP|Quote!'2597.TW-BestAsk1'	=XQFAP|Quote!'2597.TW-BestAsk2'	=XQFAP|Quote!'2597.TW-BestAsk3'	=XQFAP|Quote!'2597.TW-BestAsk4'	=XQFAP|Quote!'2597.TW-BestAsk5'	=XQFAP|Quote!'2597.TW-BestBidSize1'	=XQFAP|Quote!'2597.TW-BestBidSize2'	=XQFAP|Quote!'2597.TW-BestBidSize3'	=XQFAP|Quote!'2597.TW-BestBidSize4'	=XQFAP|Quote!'2597.TW-BestBidSize5'	=XQFAP|Quote!'2597.TW-FiveBidSize'	=XQFAP|Quote!'2597.TW-BestAskSize1'	=XQFAP|Quote!'2597.TW-BestAskSize2'	=XQFAP|Quote!'2597.TW-BestAskSize3'	=XQFAP|Quote!'2597.TW-BestAskSize4'	=XQFAP|Quote!'2597.TW-BestAskSize5'	=XQFAP|Quote!'2597.TW-FiveAskSize'	=XQFAP|Quote!'2597.TW-TotalBidContract'	=XQFAP|Quote!'2597.TW-TotalBidSize'	=XQFAP|Quote!'2597.TW-TotalEachBidSize'	=XQFAP|Quote!'2597.TW-TotalAskContract'	=XQFAP|Quote!'2597.TW-TotalAskSize'	=XQFAP|Quote!'2597.TW-TotalEachAskSize'	=XQFAP|Quote!'2597.TW-TotalMakeContract'	=XQFAP|Quote!'2597.TW-TotalMakeSize'	=XQFAP|Quote!'2597.TW-TotalEachMakeSize'	=XQFAP|Quote!'2597.TW-InNo'	=XQFAP|Quote!'2597.TW-OutNo'	=XQFAP|Quote!'2597.TW-UpStk'	=XQFAP|Quote!'2597.TW-DownStk'	=XQFAP|Quote!'2597.TW-EqualStk'	=XQFAP|Quote!'2597.TW-UpLimitStk'	=XQFAP|Quote!'2597.TW-DownLimitStk'	=XQFAP|Quote!'2597.TW-UpVolume'	=XQFAP|Quote!'2597.TW-DownVolume'	=XQFAP|Quote!'2597.TW-EqualVolume'	=XQFAP|Quote!'2597.TW-FX'	=XQFAP|Quote!'2597.TW-BankID'	=XQFAP|Quote!'2597.TW-BankName'	=XQFAP|Quote!'2597.TW-CurrencyPrice'	=XQFAP|Quote!'2597.TW-PreCurrencyPrice'	=XQFAP|Quote!'2597.TW-StockRS'	=XQFAP|Quote!'2597.TW-StockRSL'	=XQFAP|Quote!'2597.TW-Beta'	=XQFAP|Quote!'2597.TW-WeekReturn'	=XQFAP|Quote!'2597.TW-MonthReturn'	=XQFAP|Quote!'2597.TW-QuarterReturn'	=XQFAP|Quote!'2597.TW-HalfYearReturn'	=XQFAP|Quote!'2597.TW-YearReturn'	=XQFAP|Quote!'2597.TW-YTDReturn'	=XQFAP|Quote!'2597.TW-CompanyNews'	=XQFAP|Quote!'2597.TW-CompanyPos'	=XQFAP|Quote!'2597.TW-OI'	=XQFAP|Quote!'2597.TW-OIChange'	=XQFAP|Quote!'2597.TW-SettlePrice'	=XQFAP|Quote!'2597.TW-BaseDif'	=XQFAP|Quote!'2597.TW-PriceDiff'	=XQFAP|Quote!'2597.TW-InnerValue'	=XQFAP|Quote!'2597.TW-TimeValue'	=XQFAP|Quote!'2597.TW-Volatility'	=XQFAP|Quote!'2597.TW-ExeProb'	=XQFAP|Quote!'2597.TW-TheoryPrice'	=XQFAP|Quote!'2597.TW-Delta'	=XQFAP|Quote!'2597.TW-Gamma'	=XQFAP|Quote!'2597.TW-Theta'	=XQFAP|Quote!'2597.TW-Vega'	=XQFAP|Quote!'2597.TW-Rho'	=XQFAP|Quote!'2597.TW-ImplyVolatility'	=XQFAP|Quote!'2597.TW-BidAskPriceDiff'	=XQFAP|Quote!'2597.TW-BidAskPriceDiffRatio'	=XQFAP|Quote!'2597.TW-ImplyExeProb'	=XQFAP|Quote!'2597.TW-VolumePCR'	=XQFAP|Quote!'2597.TW-OIPCR'	=XQFAP|Quote!'2597.TW-Guarantee'	=XQFAP|Quote!'2597.TW-OptionPremium'	=XQFAP|Quote!'2597.TW-$TotalBidMatchTx'	=XQFAP|Quote!'2597.TW-$TotalAskMatchTx'	=XQFAP|Quote!'2597.TW-Value'	=XQFAP|Quote!'2597.TW-StockValueRatio'	=XQFAP|Quote!'2597.TW-PersistPeriod'	=XQFAP|Quote!'2597.TW-ID'	=XQFAP|Quote!'2597.TW-Name'	=XQFAP|Quote!'2597.TW-CName'	=XQFAP|Quote!'2597.TW-CFName'	=XQFAP|Quote!'2597.TW-EName'	=XQFAP|Quote!'2597.TW-EFName'	=XQFAP|Quote!'2597.TW-TradeLotSize'	=XQFAP|Quote!'2597.TW-WCPType'	=XQFAP|Quote!'2597.TW-WBaseSymbol'	=XQFAP|Quote!'2597.TW-WRatio'	=XQFAP|Quote!'2597.TW-WContractPrice'	=XQFAP|Quote!'2597.TW-CeilingPrice'	=XQFAP|Quote!'2597.TW-WLastTradeDate'	=XQFAP|Quote!'2597.TW-WContractDate'	=XQFAP|Quote!'2597.TW-WRemainDate'	=XQFAP|Quote!'2597.TW-WInnerValue'	=XQFAP|Quote!'2597.TW-WInOutRatio'	=XQFAP|Quote!'2597.TW-WLeverRatio'	=XQFAP|Quote!'2597.TW-WBidImplyVolatility'	=XQFAP|Quote!'2597.TW-WAskImplyVolatility'	=XQFAP|Quote!'2597.TW-WBasePrice'	=XQFAP|Quote!'2597.TW-WBasePriceChange'	=XQFAP|Quote!'2597.TW-WBasePriceChangeRatio'	=XQFAP|Quote!'2597.TW-VolatilityDiff'	=XQFAP|Quote!'2597.TW-MarketValue'	=XQFAP|Quote!'2597.TW-NetProfit'	=XQFAP|Quote!'2597.TW-Profit'	=XQFAP|Quote!'2597.TW-ProfitSingle'	=XQFAP|Quote!'2597.TW-ProfitFourSeason'	=XQFAP|Quote!'2597.TW-ProfitAcc'	=XQFAP|Quote!'2597.TW-NetSales'	=XQFAP|Quote!'2597.TW-AccumulatedRevenue'	=XQFAP|Quote!'2597.TW-TFXRatio'	=XQFAP|Quote!'2597.TW-MonthlyNetSalesYoY'	=XQFAP|Quote!'2597.TW-StockNetValue'	=XQFAP|Quote!'2597.TW-ProfitMargin'	=XQFAP|Quote!'2597.TW-OperatingProfitRatio'	=XQFAP|Quote!'2597.TW-NetProfitMargin'	=XQFAP|Quote!'2597.TW-RevenuePerShare'	=XQFAP|Quote!'2597.TW-ROE'	=XQFAP|Quote!'2597.TW-OperIncomeGrowthRate'	=XQFAP|Quote!'2597.TW-PreTaxIncomeGrowthRate'	=XQFAP|Quote!'2597.TW-NetIncomeGrowthRate'	=XQFAP|Quote!'2597.TW-PERatio'	=XQFAP|Quote!'2597.TW-PBRatio'	=XQFAP|Quote!'2597.TW-ReturnOnAssets'	=XQFAP|Quote!'2597.TW-CurrentRatio'	=XQFAP|Quote!'2597.TW-QuickRatio'	=XQFAP|Quote!'2597.TW-LiabilityRatio'	=XQFAP|Quote!'2597.TW-TimesInterestEarne'	=XQFAP|Quote!'2597.TW-ReceivablesTurnoverRatio'	=XQFAP|Quote!'2597.TW-InventoryTurnoverRatio'	=XQFAP|Quote!'2597.TW-FixedAssetTurnoverRatio'	=XQFAP|Quote!'2597.TW-TotalAssetTurnoverRatio'	=XQFAP|Quote!'2597.TW-EmployeeAvgTurnover'	=XQFAP|Quote!'2597.TW-EquityTurnoverRatio'	=XQFAP|Quote!'2597.TW-CashDividend'	=XQFAP|Quote!'2597.TW-StockDividend'	=XQFAP|Quote!'2597.TW-CashAndStockDividend'	=XQFAP|Quote!'2597.TW-CashFlow'	=XQFAP|Quote!'2597.TW-AccountsReceivable'	=XQFAP|Quote!'2597.TW-ListingDate'	=XQFAP|Quote!'2597.TW-BidAskSizeRatio'	=XQFAP|Quote!'2597.TW-BidAskDiff'	=XQFAP|Quote!'2597.TW-TurnoverRatio'	=XQFAP|Quote!'2597.TW-VolumeRatio'	=XQFAP|Quote!'2597.TW-Shared'	=XQFAP|Quote!'2597.TW-Capital'	=XQFAP|Quote!'2597.TW-CashDividendYieldRate'	=XQFAP|Quote!'2597.TW-PremiumRate'	=XQFAP|Quote!'2597.TW-BreakEven'	=XQFAP|Quote!'2597.TW-PauseTradingTime'	=XQFAP|Quote!'2597.TW-RestoreTradingTime'	=XQFAP|Quote!'2597.TW-DelayTradeState'	=XQFAP|Quote!'2597.TW-FinancialCosts'	=XQFAP|Quote!'2597.TW-OutstandingSize'	=XQFAP|Quote!'2597.TW-OutstandingRate'	=XQFAP|Quote!'2597.TW-RecoveryRate'	=XQFAP|Quote!'2597.TW-FinancialCostDay'	=XQFAP|Quote!'2597.TW-FinancialCostYear'	=XQFAP|Quote!'2597.TW-CalcBid'	=XQFAP|Quote!'2597.TW-CalcAsk'
		0000000 =XQFAP|Quote!'2597.TW-ID,Name,TradingDate,Time,Bid,Ask,Price,PriceChange,PriceChangeRatio,Amplitude'
		0000001 =XQFAP|Quote!'2597.TW-Volume,TotalVolume,BestBidSize,BestAskSize,High,Low,Open,PreClose,AvgPrice,UpLimit'
		0000002 =XQFAP|Quote!'2597.TW-DownLimit,InSize,OutSize,InOutRatioNumber,InOutRatio,PrePrice1,PrePrice2,PrePrice3,PrePrice4,PreTotalVolume'
		0000003 =XQFAP|Quote!'2597.TW-PostSize,BestBid1,BestBid2,BestBid3,BestBid4,BestBid5,BestAsk1,BestAsk2,BestAsk3,BestAsk4'
		0000004 =XQFAP|Quote!'2597.TW-BestAsk5,BestBidSize1,BestBidSize2,BestBidSize3,BestBidSize4,BestBidSize5,FiveBidSize,BestAskSize1,BestAskSize2,BestAskSize3'
		0000005 =XQFAP|Quote!'2597.TW-BestAskSize4,BestAskSize5,FiveAskSize,TotalBidContract,TotalBidSize,TotalEachBidSize,TotalAskContract,TotalAskSize,TotalEachAskSize,TotalMakeContract'
		0000006 =XQFAP|Quote!'2597.TW-TotalMakeSize,TotalEachMakeSize,InNo,OutNo,UpStk,DownStk,EqualStk,UpLimitStk,DownLimitStk,UpVolume'
		0000007 =XQFAP|Quote!'2597.TW-DownVolume,EqualVolume,FX,BankID,BankName,CurrencyPrice,PreCurrencyPrice,StockRS,StockRSL,Beta'
		0000008 =XQFAP|Quote!'2597.TW-WeekReturn,MonthReturn,QuarterReturn,HalfYearReturn,YearReturn,YTDReturn,CompanyNews,CompanyPos,OI,OIChange'
		0000009 =XQFAP|Quote!'2597.TW-SettlePrice,BaseDif,PriceDiff,InnerValue,TimeValue,Volatility,ExeProb,TheoryPrice,Delta,Gamma'
		0000010 =XQFAP|Quote!'2597.TW-Theta,Vega,Rho,ImplyVolatility,BidAskPriceDiff,BidAskPriceDiffRatio,ImplyExeProb,VolumePCR,OIPCR,Guarantee'
		0000011 =XQFAP|Quote!'2597.TW-OptionPremium,$TotalBidMatchTx,$TotalAskMatchTx,Value,StockValueRatio,PersistPeriod,ID,Name,CName,CFName'
		0000012 =XQFAP|Quote!'2597.TW-EName,EFName,TradeLotSize,WCPType,WBaseSymbol,WRatio,WContractPrice,CeilingPrice,WLastTradeDate,WContractDate'
		0000013 =XQFAP|Quote!'2597.TW-WRemainDate,WInnerValue,WInOutRatio,WLeverRatio,WBidImplyVolatility,WAskImplyVolatility,WBasePrice,WBasePriceChange,WBasePriceChangeRatio,VolatilityDiff'
		0000014 =XQFAP|Quote!'2597.TW-MarketValue,NetProfit,Profit,ProfitSingle,ProfitFourSeason,ProfitAcc,NetSales,AccumulatedRevenue,TFXRatio,MonthlyNetSalesYoY'
		0000015 =XQFAP|Quote!'2597.TW-StockNetValue,ProfitMargin,OperatingProfitRatio,NetProfitMargin,RevenuePerShare,ROE,OperIncomeGrowthRate,PreTaxIncomeGrowthRate,NetIncomeGrowthRate,PERatio'
		0000016 =XQFAP|Quote!'2597.TW-PBRatio,ReturnOnAssets,CurrentRatio,QuickRatio,LiabilityRatio,TimesInterestEarne,ReceivablesTurnoverRatio,InventoryTurnoverRatio,FixedAssetTurnoverRatio,TotalAssetTurnoverRatio'
		0000017 =XQFAP|Quote!'2597.TW-EmployeeAvgTurnover,EquityTurnoverRatio,CashDividend,StockDividend,CashAndStockDividend,CashFlow,AccountsReceivable,ListingDate,BidAskSizeRatio,BidAskDiff'
		0000018 =XQFAP|Quote!'2597.TW-TurnoverRatio,VolumeRatio,Shared,Capital,CashDividendYieldRate,PremiumRate,BreakEven,PauseTradingTime,RestoreTradingTime,DelayTradeState'
		0000019 =XQFAP|Quote!'2597.TW-FinancialCosts,OutstandingSize,OutstandingRate,RecoveryRate,FinancialCostDay,FinancialCostYear,CalcBid,CalcAsk'
		
</comment>