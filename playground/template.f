	
	\ template.f
	\ H.C. Chen hcchen5600@gmail.com
	\ FigTaiwan http://groups.google.com/group/figtaiwan

	include unindent.f
	also forth definitions
	

	<text>
		<h> /* <h>..</h> 是寫東西進 HTML 的 <head> 裡 */
			<style type="text/css">
				code, .code { /* <code> 夾在文章中 */
					font-family: courier new;
					font-size: 110%; /*夾在文章中， courier new 字細所以要大一點*/
					background: #E0E0E0;
				}
				table {
					width: 100%;
				}
				.essay { 
					font-family: Microsoft Yahei;
					letter-spacing: 1px;
					line-height: 160%;
				}
				.source { /* 配合 <code> 放 source code 
							主要是把字體、行距恢復否則太大太遠了*/
					font-size:100%;
					letter-spacing:0px"
					line-height: 100%;
				}
				
			</style>
		</h> drop \ /* 丟掉 <h>..</h> 留下來的 <style> element object, 用不著 */
		s" body" <e> /* 直接放到 <body> 後面 */
		<div/*article*/ contentEditable=true id=article class=essay><blockquote/*整篇文章*/>
/* -------------------------------------------------------------------------- */
			<h1>Article title</h1>
/* -------------------------------------------------------------------------- */
			<img src="doc/jeforth-demo-cloth-2015-11-201.jpg">
/* -------------------------------------------------------------------------- */
			<p>
				Greeting
			</p>
/* -------------------------------------------------------------------------- */
			<h2>Capter-1</h2>
/* -------------------------------------------------------------------------- */
			<p>
				paragraph 1
			</p>
/* -------------------------------------------------------------------------- */
/* -------------------------------------------------------------------------- */
			<h2>chapter 2</h2>
/* -------------------------------------------------------------------------- */
			<p>
				chapter 2
			</p>
			<table><td class=code /* 影響整格的 background color */>
			<blockquote><pre><code /* 影響 font-size 跟 font-family */ class=source><unindent>
				source code
			</unindent></code></pre></blockquote></td></table>
/* -------------------------------------------------------------------------- */
			<h2>Ending</h2>
/* -------------------------------------------------------------------------- */
			<p>
				ending
			</p>	
			<p>--- The End ---</p>	
			<p>H.C. Chen hcchen5600@gmail.com 2015.11.27</p>
			<p>FigTaiwan http://groups.google.com/group/figtaiwan</p>
		</blockquote/*整篇文章*/></div/*article*/>
		</e> drop /* 留下來的 element 沒用到 */
	</text> 
	/*remove*/ 		\ :> replace(/\/\*(.|\r|\n)*?\*\//mg,"") \ 清除註解。
	unindent 		\ handle all <unindent >..</unindent > sections
	<code>escape	\ convert "<>" to "&lt;&gt;" in code sections
	tib.insert		\ execute the string on TOS
\ ---------- The End -----------------
	