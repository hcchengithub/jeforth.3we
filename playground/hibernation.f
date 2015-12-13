.( 這台電腦入睡之後會被無故喚醒，用 jeforth.3hta 來簡單解決。 ) cr
.( 馬上去睡, 萬一被無故喚醒之後 count down 30 秒後繼續睡，讓 user 有機會下 stop 停止。 ) cr
[begin]
run shutdown /h
<o> <h1>Bringing the system into hibernate</h1></o> drop cr
<o> <h3>3 wait 10 seconds .... "stop" me?</h3></o> drop cr 10000 nap
<o> <h3>2 wait 10 seconds .... "stop" me?</h3></o> drop cr 10000 nap
<o> <h3>1 wait 10 seconds .... "stop" me?</h3></o> drop cr 10000 nap
[again]
