
\ cloth_sam.f

include canvas.f
\ 有現成的畫布就用現成的，否則變出一個畫布來用。 
' cv [if] [else] createCanvas setWorkingCanvas [then]  

s" cloth.f" source-code-header

\ 設定
  600   value w         // ( -- int ) 畫布寬
  300   value h         // ( -- int ) 畫布高
  w h   setCanvasSize   \ 設定 畫布寬高  
   40   lineWidth       \ 畫線寬度 
  100   value r         // ( -- int ) 紅光亮度
  200   value g         // ( -- int ) 綠光亮度 
  200   value b         // ( -- int ) 藍光亮度 
   55   value v         // ( -- int ) 亮度 最大增量
   90   value d         // ( -- int ) 畫線終點橫坐標 最大變量
    0   value xB        // ( -- int ) 畫線起點橫坐標
    0   value yB        // ( -- int ) 畫線起點縱坐標
    0   value xE        // ( -- int ) 畫線終點橫坐標
    0   value yE        // ( -- int ) 畫線終點縱坐標 
     
code random ( -- r ) \ 產生一個亂數 r, 其值域 0 <= r <= 1
	push(Math.random());
end-code

code >rgba ( r g b a -- rgba-Code-String ) 
	push(
		'rgba(' + fixed(pop(3),0) // r 取整數
		+ ',' + fixed(pop(2),0)  // g 取整數
		+ ',' + fixed(pop(1),0) // b 取整數
		+ ',' + fixed(pop(),2) // a 取兩位小數
		+ ')'
	);
	function fixed(f,n){ // 傳回 f 取 n 位小數的結果
		n=Math.pow(10,n); return Math.round(f*n)/n; 
	}
end-code
/// 例如 2 34 56 .3 >rgba . 印出 rgba(12,23,56,0.3)

: draw \ 畫線
  \ 上端點的橫坐標 xB 依       亂數決定
  w 100 + random * 50 -         to xB \ 畫布左界-50 與 畫布右界+50 之間的 任意值
  0                             to yB
  \ 下端點的橫坐標 xE 依 xB 及 亂數 決定
  xB d random * d 2 / - +       to xE \ xB-d/2 與 xB+d/2 之間的 任意值
  h                             to yE
  beginPath             \ 線段開始
    r   random *        \ 紅光亮度隨 亂數 改變
    g   random *        \ 綠光亮度隨 亂數 改變
    b v random * +      \ 藍光亮度隨 亂數 改變
        random          \ 彩色透度隨 亂數 改變
    >rgba    			\ 產生 rgba 對應字串 設定畫線形式
	( *debug* Draw> ) strokeStyle
    xB yB moveTo        \ 移到 起點
    xE yE lineTo        \ 畫到 終點
  stroke                \ 線段結束
;

\ main

150 [for] draw [next]

\ -- the end --
