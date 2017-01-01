
    \ Flot.js demo GitHub\flot\examples\basic-usage\index.html

	include flot.f
    
    \ Prepare the Flot ploting zone

		cls ' flotzone [if] [else]
			<o> <div class=flotzone></div></o> constant flotzone // ( -- DIV ) Place for Flot plotings avoid CSS conflict.
			flotzone js> $(".console3we")[0] insertBefore

			\ Show Flot version information, code snippet from flot.js demo.
			flotzone <o> <div id="footer">
				Copyright &copy; 2007 - 2014 IOLA and Ole Laursen
			</div></o> appendChild
		[then]

    \ Demo #1
        \ Create the placeholder

        flotzone
        <o> <div id="placeholder1" style="width:600px;height:300px"></div></o> ( placeholer1 )
        appendChild

        \ Plot a line 
        
        js: $.plot($("#placeholder1"),[[[0,0],[1,1]]],{yaxis:{max:1}})

    \ Demo #2
        \ Create the placeholder

        flotzone
        <o> <div id="placeholder2" style="width:600px;height:300px"></div></o> ( placeholer2 )
        appendChild

        \ Plot some lines
        
        <js>
            $(function() {

                var d1 = [];
                for (var i = 0; i < 14; i += 0.5) {
                    d1.push([i, Math.sin(i)]);
                }

                var d2 = [[0, 3], [4, 8], [8, 5], [9, 13]];

                // A null signifies separate line segments

                var d3 = [[0, 12], [7, 12], null, [7, 2.5], [12, 2.5]];

                $.plot("#placeholder2", [ d1, d2, d3 ]);
				$("#footer").prepend("Flot " + $.plot.version + " &ndash; ");

            });
        </js>

