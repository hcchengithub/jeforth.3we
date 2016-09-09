
	s" calc.f" source-code-header

	<o> 
		<style>
			.calc table, .calc th, .calc td {
				border: 1px solid #989898;
				border-collapse: collapse;
				padding:4px;
				font-size:20px;
			}
			.calc input {
				font-size:20px;
				margin: 5px 5px 5px 5px;
			}
			.calc [type=text] {
				border: 0px;
			}
			.calc input:hover {
				background-color: pink;
			}
		</style>
		<p>
		<table class=calc>
			<caption><span style="font-family:DFKai-SB;font-size:40px;text-shadow: 2px 2px 3px #505050;">小算盤</span>
			<span style="font-family:'Microsoft YaHei';">value 填初值， 改寫 formula 或點觸 x,y,z 疊代計算新值。</span></caption>
			<tr>   
				<th><input type=button value=Reset onclick="kvm.execute('清空')" /></th><th>Formula</th><th>Value</th><th>Remark</th>
			</tr>
			<tr>
				<td align=center><input type=button value='	   x	' onclick="kvm.execute('calculate-x')" /></td>
				<td><input id=x type=text value='' onchange="kvm.execute('calculate-x')" /></td>
				<td><input id=xvalue type=text value=0 /></td>
				<td><input id=xremark size=70 type=text value='' /></td>
			</tr>
			<tr>
				<td align=center><input type=button value='	   y	' onclick="kvm.execute('calculate-y')" /></td>
				<td><input id=y type=text value='' onchange="kvm.execute('calculate-y')" /></td>
				<td><input id=yvalue type=text value=0 /></td>
				<td><input id=yremark size=70 type=text value='' /></td>
			</tr>
			<tr>
				<td align=center><input type=button value='	   z	' onclick="kvm.execute('calculate-z')" /></td>
				<td><input id=z type=text value='' onchange="kvm.execute('calculate-z')" /></td>
				<td><input id=zvalue type=text value=0 /></td>
				<td><input id=zremark size=70 type=text value='' /></td>
			</tr>
			<tr>
				<td colspan=4> <input 
						type=button 
						onclick="kvm.execute('原始範例')" 
						value="原始範例"
					/>
					<input 
						type=button 
						onclick="kvm.execute('歐元換算台幣')" 
						value="歐元換算台幣"
					/>
					<input 
						type=button 
						onclick="kvm.execute('疊代法')" 
						value="3x² + 4x = 5, 求 x"
					/>
				</td>
			</tr>
		</table>
	</o> drop

	: 產生計算器 ( "variable-name" -- ) \ x y z 都由這個母機產生
		create
			( 0 formula id	  ) dup ,
			( 1 value id	  ) char value + , 
		does> 
			r@ @ ( -- "formula id" ) 
			js> eval(pop()).value ( -- "formula" )
			<text>
				var x = parseFloat(eval(xvalue).value);
				var y = parseFloat(eval(yvalue).value);
				var z = parseFloat(eval(zvalue).value);
			</text> ( -- "formula" "給定 x,y,z 之值如上" )
			js> eval(pop()+pop()) ( -- value )
			r> 1+ @ ( -- value valueId ) \ 取得回填結果的格位
			js: eval(pop()).value=pop()	 \ 回填結果
	;
	
	: 清空 ( -- ) \ 清空「小算盤」所有輸入格。
		js: x.value=y.value=z.value=''
		js: xvalue.value=yvalue.value=zvalue.value=0
		js: xremark.value=yremark.value=zremark.value=''
	;

	: 歐元換算台幣 ( -- ) \ value 放歐元，觸點一下換算成台幣
		js: x.value='x';y.value='x*y';z.value='(z/100)*x'
		js: xvalue.value=35.402;yvalue.value=2;zvalue.value=4.5
		<js> xremark.value="一塊歐元值這麼多台幣。這是常數，填好不要動。" </js>
		<js> yremark.value="value 填歐元，點一下 y 換算成台幣。" </js>
		<js> zremark.value="value 填歐分，點一下 z 換算成台幣。4.5c 是 Skype 發簡訊的價碼。" </js>
	;

	: 原始範例 ( -- ) \ 展現「小算盤」的使用方法
		js: x.value='x+1';y.value='3*7';z.value='(z-32)/1.8'
		js: xvalue.value=0;yvalue.value='三七';zvalue.value=100
		<js> xremark.value='按 x 一直加一' </js>
		<js> yremark.value='按 y 管他三七。。。'  </js>
		<js> zremark.value="按 z 華氏溫度轉成攝氏 °C = (°F - 32) / 1.8" </js>
	;

	: 疊代法 ( -- ) \ 展現「小算盤」的使用方法，用疊代法求方程式的解。
		js: x.value='5/(3*x)-4/3';y.value='3*x*x+4*x';z.value='2.54*(Math.floor(z)*12+10*(z-Math.floor(z)))'
		js: xvalue.value=0;yvalue.value=0;zvalue.value=5.6
		<js> xremark.value='原式搬弄改寫成 5/(3x) - 4/3 = x, 按幾下 x 其值逐漸收斂成答案。' </js>
		<js> yremark.value='驗算'	 </js>
		<js> zremark.value='英制身高五呎六吋記為 5.6, 按 z 換算成公分。' </js>
	;
	
	char x 產生計算器 calculate-x
	char y 產生計算器 calculate-y
	char z 產生計算器 calculate-z

	原始範例
	cr
	.' 1. 想查看 source code 請輸入以下命令 char calc.f readTextFileAuto .（含最後的小點）' cr
	." 2. help 命令之後沒有東西時列出操作用法指引。" cr
	
	