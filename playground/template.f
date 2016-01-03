	
	\ template.f
	\ H.C. Chen hcchen5600@gmail.com
	\ FigTaiwan http://groups.google.com/group/figtaiwan

	include unindent.f
	s" template.f" source-code-header

	<text>
		<h> /* <h>..</h> 是寫東西進 HTML 的 <head> 裡 */
			<style id=mystyle type="text/css">
				/* 整篇文章的默認設定 */
				.default { 
					/* https://zh.wikipedia.org/zh-tw/Font_family_(HTML) */
					/* https://zh.wikipedia.org/wiki/%E9%BB%91%E4%BD%93_(%E5%AD%97%E4%BD%93) */
					/* 微軟正黑(tw) Microsoft JhengHei; 微軟雅黑(cn) Microsoft Yahei; */
					/* 標楷體(tw) DFKai-SB;  courier new; */
					font-family: Microsoft JhengHei;  /* 微軟正黑(tw) */
					letter-spacing: 0px;
					line-height: 160%;
					tab-size:4; /* IE,Edge 無效(hcchen5600 2015/12/07 11:51:34); Chrome 有效  */
				}
				/* <code> 除了 style 還標示要做 < &lt; > &gt; 轉換的區域，所以一定是最內層 */
				code { 
					font-family: courier new;
					font-size: 110%; /* 通常夾在字裡行間 courier 的筆畫細所以要大一點 */
					background: #E0E0E0; /* <code> 夾在字裡行間時凸顯之 */
				}
				/* .commandline 跟 .source 能不能合併成 .code 一個就好，大家都用？ */
				.commandline { /* 用來修飾 <table class=commandline> */
					width: 90%;
					background: #E0E0E0; /* <code> */
				}
				.source {  /* 用來修飾 <code class=source> */
					font-size: 100%;   /* againt the in-line bigger font-size of <code> */
					line-height: 120%; /* againt the default */
				}
			</style>
		</h> drop \ /* 丟掉 <h>..</h> 留下來的 <style> element object, 用不著 */
		s" body" <e> /* 直接放到 <body> 後面 */
		<div/*article*/ contentEditable=true id=article class=default><blockquote/*整篇文章*/>
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
			<table class=commandline><td class=code /* 影響整格的 background color */>
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
	