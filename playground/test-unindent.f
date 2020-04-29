

    \ <comment>
    include unindent.f
    <text> 
		\ 實驗範例
        Command 'unindent' 處理 multiple lines string 把其中用 
        <un\indent>..</un\indent> 標示的部分做 unindent 處理。
        方法就是把標示的部分整個左移到不能再移為止。且 TAG 本身
        的頭尾最後都會消失，好像不存在一樣。
		
				I should be indented
				x<unindent>
				y
				I should not be indented
				x</unindent>y
				I should be indented z <unindent>
				I should not be indented </unindent> 
				I should be indented
				<unindent>
				I should not be indented
				</unindent> 
				I should be indented

	</text> unindent . cr
    \ </comment>