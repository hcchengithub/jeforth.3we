cls
<o> <h2> 十分抱歉，這台電腦入睡之後會被無故喚醒，用 jeforth.3hta 來簡單解決。
萬一被無故喚醒之後 count down 一段時間讓 user 有機會關掉本程式，否則過後繼續睡。</h2></o>
[begin]
<o> <h1>Bringing the system into hibernate. </h1></o> drop
<o> <h3>5. wait 20 seconds .... "stop" me?</h3></o> drop cr 20000 nap
<o> <h3>4. wait 20 seconds .... "stop" me?</h3></o> drop cr 20000 nap
<o> <h3>3. wait 20 seconds .... "stop" me?</h3></o> drop cr 20000 nap
<o> <h3>2. wait 20 seconds .... "stop" me?</h3></o> drop cr 20000 nap
<o> <h3>1. wait 20 seconds .... "stop" me?</h3></o> drop cr 20000 nap
run shutdown /h
[again]
