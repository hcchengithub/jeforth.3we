
s" misc.f"	source-code-header

\ OLPC compatibility
\ 推薦人家看 OLPC Forth 書 http://wiki.laptop.org/go/Forth_Lessons 所以要盡量減少困惑。

' .s alias showstack 
    /// Compatable to OLPC
: noshowstack   ( -- ) \ OLPC's Turn off showstack. Not supported
    ." OLPC's Turn off showstack. Not supported!" cr ;
: type ( addr len -- ) \ OLPC's type. Not supported. Use js: type('string') instead 
    [ last literal ] :> help . cr ;
: recursive ( -- ) \ Use "[ last literal ] execute" to execute the word under definition.
    [ last literal ] :> help . cr ;
    /// This is an example: 
    /// : factorial  dup 1 > if dup 1- [ last literal ] execute * then  ;
    last alias recurse

\ Miscellaneous
		
code tib.       ( result -- ) \ Print the command line and the TOS.
				var lastCRindex = tib.slice(0, ntib).lastIndexOf('\n')+1;
				var cmd = tib.slice(lastCRindex).match(/\s*(.*) tib\.\s*/)[1]; 
				var L1 = cmd.length;
				cmd = cmd.replace(/\s*""\s*$/,""); // remove the ending ""
				var L2 = cmd.length;
				type(cmd+" \\ ==> ");
				if (L1==L2) type(tos() + " (" + mytypeof(pop()) + ")");
				else pop();
				type('\n');
				end-code 
				/// Good for experiments that need to show command line and the result.
				/// "" tib. prints the command line only, w/o the TOS.

code now 		( -- Time ) \ Get the Time object of now.
				push(new Date());
				end-code 

code t.year 	( Time -- year ) \ Get year number
				push(pop().getFullYear());
				end-code
   
: t.month 		( Time -- month ) \ Get month number 
				js> pop().getMonth() 1+ ;

: t.date 		( Time -- date ) \ Get date number 
				js> pop().getDate() ;

: t.day 		( Time -- day ) \ Get day number 
				js> pop().getDay() ;

: t.hour		( Time -- hour ) \ Get hour number 
				js> pop().getHours() ;

: t.minute		( Time -- minute ) \ Get minute number 
				js> pop().getMinutes() ;

: t.second		( Time -- second ) \ Get second number 
				js> pop().getSeconds() ;

: t.mS			( Time -- mS ) \ Get mS number 
				js> pop().getMilliseconds() ;

: t.dateTime    ( Time -- "yyyy-mm-dd HH:mm:ss" ) \ Get "yyyy-mm-dd HH:mm:ss" string
				>r
				r@ t.year char - +
				r@ t.month  2 (.0r) char - + +
				r@ t.date   2 (.0r) (space) + +
				r@ t.hour   2 (.0r) char : + +
				r@ t.minute 2 (.0r) char : + +
				r> t.second 2 (.0r) + ;

code precise-time(mS)	( -- mS ) \ JavaScript's precise recent time in mini seconds
						push((new Date()).getTime()) end-code

code jquery.version ( -- string ) \ Check jQuery version
				push($.fn.jquery) end-code
				/// or push($().jquery) too
				/// http://www.moreonfew.com/how-to-check-jquery-version

				<comment>
				\ This was for test
				code freeze 	( mS -- ) \ Freeze the entire system for mS time. Nobody can do anything.
								var ms=pop();
								var startTime = new Date().getTime();
								while(new Date().getTime() < (startTime + ms));
								end-code
								/// 'freeze' is not a good word, it totally blocks the entire system, useless maybe.
								/// Try 'sleep' instead.
								
				\ This was for fun
				code .longwords ( length -- ) \ type long words. I designed this word for fun to see what are they.
								var limit = pop();
								for (var j=0; j<order.length; j++) { // 越後面的 priority 越新
									type("\n-------- " + order[j] +" "+ (words[order[j]].length-1) + " words --------\n" );
									for (var i=1; i<words[order[j]].length; i++){  // 從舊到新
										if(words[order[j]][i].name.length > limit) type(words[order[j]][i].name+" ");
									}
								}
								end-code

				\ 已經有更好的方法： mySetTimeout() mySetInterval()
				\ setTimout timers & setInterval timers. Idea was from Sam Suan Chen's jeforth HTML5 clock demo.
				\ [] constant timouts		// ( -- array[] ) setTimeout IDs' storage
				\ 						/// Refer to : timeouts.push and timeouts.clear
				\ code timeouts.push		( id -- ) \ Save the setTimeout ID into timeouts[].
				\ 						execute('timeouts'); pop().push(pop()) end-code
				\ code timeouts.clear		( n -- ) \ Clear older setTimeout IDs leaving the last n ones.
				\ 						var n=pop(); execute('timeouts'); var a=pop();
				\ 						while(a.length>n) clearTimeout(a.shift());
				\ 						end-code
				\ [] constant intervals 	// ( -- array[] ) setInterval IDs' storage
				\ 						/// Refer to : intervals.push and intervals.clear
				\ code intervals.push		( id -- ) \ Save the setInterval ID into intervals[].
				\ 						execute('intervals'); pop().push(pop()) end-code
				\ code intervals.clear	( n -- ) \ Clear older setInterval IDs leaving the last n ones.
				\ 						var n=pop(); execute('intervals'); var a=pop();
				\ 						while(a.length>n) clearInterval(a.shift());
				\ 						end-code

				\ 不如放進 calc.f 裡去
				\ : dollar>ntd 			( USD -- NTD ) \ 美金（美元）換算成台幣（元），將來看能不能自動從網路上取得匯率。
				\ 						32 * ; 
				\ 						/// 1 dollar = 100 cent, 1 quarter = 25 cent
				\ 						/// 1 dime = 10 cent, 1 nickel = 5 cent
				\ : cent>ntd				( cent -- NTD ) \ 美金（美分）換算成台幣（元）
				\ 						100 / dollar>ntd ; 
				\ 
				\ : euro>ntd 				( EUR -- NTD ) \ 歐元（元）換算成台幣（元），將來看能不能自動從網路上取得匯率。
				\ 						35.402 * ; 
				\ 						/// 1 euro = 100 cent, 1 quarter = 25 cent
				\ 						/// 1 dime = 10 cent, 1 nickel = 5 cent
				\ : euro.cent>ntd			( cent -- NTD ) \ 歐元（分）換算成台幣（元）
				\ 						100 / euro>ntd ; 
					https://tw.knowledge.yahoo.com/question/question;_ylt=A3eg.oaZmchUwG0AsfHXrYlQ?qid=1513122703211
					美金有；1分，5分，1角，2角5分，5角，1元。
					英鎊有；1便士，2便士，10便士，20便士，50便士，1鎊，2鎊，5鎊，10鎊，20鎊。
					歐元有；1分，2分，5分，10分，20分，50分，1元，2元。
					日幣有；1元，5元，10元，50元，100元，500元。
					港幣有；10分，20分，50分，1元，2元，5元，10元。
				</comment>

: sign      ( n -- sign ) \ sign of n, result is 1 or -1 
			?dup if dup abs ( n abs(n) ) / int else 1 then ;

: round-off ( float 100(desimal) -- f' ) \ Round at 0.00 in this example, 0.005 --> 0.01, 0.00499 --> 0.0
			over sign ( f 100 sign ) swap ( f sign 100 ) 
			rot ( sign 100 f ) abs ( sign 100 |f| ) over * ( sign 100 |f|*100 ) 
			0.500000000001 +  ( sign 100 |f|*100+0.5 )
			int swap / * ; 
			/// where decimal=0 means integer
			
: -->   	( result -- ) \ Print the result with the command line.
			js> tib :> substring(0,ntib) ( result tib' )
			dup :> lastIndexOf("\n") ( result tib' idxLastCR )
			swap :> substring(Math.max(0,pop()),ntib) ( result tib" )
			trim . \ print the TIB line 
            space dup ( value value ) . \ print the value 
            ( value ) js> typeof(pop()) char ( . . char ) . cr ;




