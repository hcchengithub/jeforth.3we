
    \ Flot.js demo GitHub\flot\examples\basic-usage\index.html

	s" flot.f" source-code-header

	js> typeof($.plot)!="function" [if] 
		<h> 
		<!-- link id=flotcss href="external modules/flot/examples/examples.css" rel="stylesheet" type="text/css"-->
		<script id=flotjs language="javascript" type="text/javascript" src="external modules/flot/jquery.flot.js"></script>
		</h> drop

		\ Wait a while, make sure Flot.js is ready
		.( $.plot readiness check .)
		( seconds * 1000 / nap ) js> 60*1000/200 [for] 
			js> typeof($.plot)=="function" [if] 
				r> drop 0 >r \ break the loop
			[else] 
				200 nap ." ." \ wait a while
			[then] 
		[next] cr
	[then]
