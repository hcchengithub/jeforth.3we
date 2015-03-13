
    include canvas.f
    
    s" one-clock.f"    source-code-header

	createCanvas setWorkingCanvas

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

    \ 宣告漸層色
    50 250 250 300 createLinearGradient constant grd // ( -- objGradient ) linear gradient area
    grd 0   char black   addColorStop
    grd 0.3 char magenta addColorStop
    grd 0.5 char blue    addColorStop
    grd 0.6 char green   addColorStop
    grd 0.8 char yellow  addColorStop
    grd 1   char red     addColorStop
    
    : 畫訊息 ( -- ) \ Forth萬歲
        s" 20pt bold Arial" font
        grd fillStyle s" Forth萬歲" 90 200 fillText
    ;

    : 畫鐘 ( -- ) \ Clock main program
        加秒
        清螢幕
        畫框
        畫訊息
        hours   12 mod 5 * minutes 12 / +  畫時針
        minutes seconds 60 / + 畫分針
        seconds 畫秒針
        js> g.setTimeout((function(){execute('畫鐘')}),1000) ( -- id ) drop
    ;

    畫鐘
