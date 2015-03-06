
\ 變出 Playground 用來玩 HTML 或什麼的 <p> ..... </p> 
<o> <div id=pg></div></o> eleDisplay insertBefore \ 放在 outputbox 之前
js> pg constant pg // ( -- element ) The Play-Ground element
s" \s*(</e>|</o>|</h>|</p>)" <js> new Constant(pop())</jsV> ' <e> :> cfa ! \ 修改 <e> 增加 </p> 作為 <p> 的結尾
' </e> alias </p>
: <p> pg [compile] <e> ; interpret-only // ( -- ) <p> .... </p> for appending HTML to the Play-Ground <div>
<p> <h1>Playground</h1></p> \ 驗收

\ 如果是作實驗玩 HTML 應該直接用 outputbox , 到時候整個抓到 word 或哪兒去編輯好變成筆記。



