
    include canvas.f
	
    s" many-clocks.f"    source-code-header

	\ createCanvas setWorkingCanvas  

    now value NOW // ( -- objDate ) Start time
                  
    NOW js> pop().getSeconds() value seconds // ( -- n ) Start time
    NOW js> pop().getMinutes() value minutes // ( -- n ) Start time
    NOW js> pop().getHours()   value hours   // ( -- n ) Start time
    
    150 constant RX // ( -- n ) X-axis of the center of the clock
    150 constant RY // ( -- n ) Y-axis of the center of the clock

    : 畫針  ( 刻度 長度 -- ) \ 刻度=[0..59]
        swap ( 長度 刻度 ) 
        save
        RX RY translate \ 移動座標系 http://blog.csdn.net/fulianwu/article/details/7001618
        ( 圓周刻度 ) 60 / 2 * 0.5 - js> Math.PI * rotate \ 旋轉座標系 其中的 0.5 是為了避免1px線條模糊問題 
        beginPath 0 0 moveTo ( 指針長度 ) 0 lineTo
        stroke
        restore
    ;
    : 畫時針 5 lineWidth s" green" strokeStyle 60 畫針 ; // ( angle -- ) angle is 0~59
    : 畫分針 3 lineWidth s" navy"  strokeStyle 75 畫針 ; // ( angle -- ) angle is 0~59
    : 畫秒針 1 lineWidth s" red"   strokeStyle 90 畫針 ; // ( angle -- ) angle is 0~59
    : 清螢幕 clearCanvas ; // ( -- )
    : 畫框 ( -- ) \ Draw the frame of the clock
        1 lineWidth char  black strokeStyle beginPath RX RY 98 0 js> Math.PI*2 0 arc stroke
        3 lineWidth char silver strokeStyle beginPath RX RY 90 0 js> Math.PI*2 0 arc stroke ;
    : 加時 hours   1+ dup 24 > if      24 - then to hours ; // ( -- ) 
    : 加分 minutes 1+ dup 60 > if 加時 60 - then to minutes ; // ( -- ) 
    : 加秒 seconds 1+ dup 60 > if 加分 60 - then to seconds ; // ( -- ) 
*debug* 00>>
    
    : 畫訊息 ( msg grd -- ) \ Forth萬歲 
        s" 20pt bold Arial" font
        ( grd ) fillStyle ( msg ) 20 40 fillText
    ;

    : 時鐘 ( hourTimeOffset <CityName> -- ) \ Create a clock of a city in new canvas
		create 
			( 0 offset ) 60 * 60 * 1000 * , \ city time offset in (+-)hours
			( 1 canvas ) createCanvas dup , 	
			( 2 grd    ) \ 宣告漸層色 
						 js: push(vm.g.cv);vm.g.cv=pop(1) \ save recent cv
						 20 40 80 50 createLinearGradient
						 dup 0   char black   addColorStop
						 dup 0.3 char magenta addColorStop
						 dup 0.5 char blue    addColorStop
						 dup 0.6 char green   addColorStop
						 dup 0.8 char yellow  addColorStop
						 dup 1   char red     addColorStop
						 , js: vm.g.cv=pop() \ restore recent cv
			( 3 buffer ) 0 , \ original canvas buffer
			( 4 name   ) js> last().name ,
		\	( 5 callbk ) s" push(function(){inner(" js> last().cfa + s" )})" + jsEvalNo dup ,
			( 5 callbk ) s" push(function(){execute('" js> last().name + s" ')})" + [compile] </js> dup ,
						 js: vm.g.setTimeout(pop(),100) \ 直接啟動，此時 does> 尚未宣告完成，所以要等一下。 
		does> 
			js> vm.g.cv r@ 3 + ! \ save original cv 
			r@ 1+ @ js: vm.g.cv=pop() \ activate the cv of the clock
			清螢幕 畫框 r@ 4 + @ r@ 2+ @ 畫訊息 
			r@ @ <js> new Date((new Date()).valueOf()+pop())</jsV>
			js> tos().getHours()%12*5+tos().getMinutes()/12 畫時針 
			js> tos().getMinutes()+tos().getSeconds()/60 畫分針 
			js> pop().getSeconds() 畫秒針 
			r@ 3 + @ js: vm.g.cv=pop() \ restore original cv
			r> 5 + @ js: vm.g.setTimeout(pop(),1000)
		\	js> rstack.length if 0 >r then \ TSR 不要吃到別人 (in suspending) 的 rstack。重要！
	; interpret-only
*debug* 11>>

	0	時鐘 台北 
*debug* 22>>
	1	時鐘 東京 
*debug* 33>>
	-6	時鐘 巴黎 
*debug* 44>>
	-7	時鐘 倫敦 
*debug* 55>>
	-15	時鐘 洛杉磯 
*debug* 66>>
	-12	時鐘 紐約 
*debug* 77>>
	-4	時鐘 杜拜 
*debug* 88>>

	




