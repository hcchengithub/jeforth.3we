
see Ynote,

(<text>) is almost same as <text> but it consumes the 
next </text> in TIB and returns <text> + "</text>"

so if <text> hits <text> in TIB then it returns 
string1 +  "<text>" + (<text>) + <text> 
leaves the next </text> in TIB


				[ last literal ] ( 取得 word <text> 本身 )
				js: tos().nestLevel+=1 
                    
					over ( <text> string1 <text> )
					execute \ recurse nested level ( <text> string1 string2 )
					\ 把 nested 部分加進來，先補回被吃掉的 <text> token
					\ 如果 TIB 未竟，就要補回 </text>
						js> ntib<tib.length if ( <text> string1 string2 )
							s" </text> " +
						then
						( <text> string1 string2 ) + ( <text> string1 )
					swap ( string1 <text> )
					js: tos().nestLevel-=1 \ 預減 <text> 將多出的跳增
					execute \ 剩下來的部分 ( string1 string2 )
					+ ( string )
					char </text> execute \ future word call by name

                    execute \ future word call by name
					( D: [string] ; R: <text> ) 
					js> rtos().nestLevel 
					( D: [string] level ; R: <text> ) 
					1- 0 max r> :: nestLevel=pop() ( [string] )

null value '<text> // ( -- <text> ) The <text> Word object, for indirect call.
                    
: (<text>)		( <text> -- "text"+"</text>" ) \ Auxiliary <text>, handles nested portion
                '<text> execute ( string ) \ 此時 TIB 非 </text> 即行尾
				BL word char </text> = ( string is</text>? )
				if \ 剛才撞上了 </text> ( string )
					s" </text> " + ( string1' )
				then ;
                /// (<text>) is almost same as <text> but it consumes the 
                /// next </text> in TIB and returns <text> + "</text>"

: <text>		( <text> -- "text" ) \ Get multiple-line string, can be nested.
				char </text>|<text> word ( string1 )
				\ 撞到 delimiter 停下來非 <text> 即 </text> 要不就是行尾
				BL word dup char <text> = ( string1 deli is<text>? )
				if \ 剛才撞上了 <text> ( string1 deli )
					drop s" <text> " + ( string1' )
                    (<text>) ( string1' string2 ) + 
                    [ last literal ] execute ( string1'' string3 ) + ( string )
				else \ 剛才撞上了 </text> 或行尾  ( string1 deli )
					char </text> swap over = ( string1 "</text>" is</text>? ) 
                    if js: ntib-=pop().length ( string1 )
                    else drop then  ( string1 )
				then ; immediate last to '<text>
                /// If <text> hits <text> in TIB then it returns 
                /// string1 +  "<text>" + (<text>) + <text> 
                /// leaves the next </text> in TIB
                /// Colon definition 中萬一前後不 ballance 會造成 colon definition
                /// 不如預期結束而停留在 compiling state 裡等 closing </text> 的現象。
				
: </text> 		( "text" -- ... ) \ Delimiter of <text>
				compiling if literal then ; immediate
				/// Usage: <text> word of multiple lines </text>

dropall 11 22 33
: tt <text> aa <text> bb </text> cc </text> 77 ;
[ q ]
[ .s ]
