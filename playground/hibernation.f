
include autoit.f

cls
<o> <h2> 十分抱歉，這台電腦入睡之後會被無故喚醒，用 jeforth.3hta 來簡單解決。
萬一被喚醒之後 count down 一段時間讓 user 有機會關掉本程式，否則過後繼續睡。</h2></o>
<o> <h1>Bringing the system into sleep .... </h1></o> drop
[begin]
\ run shutdown /h  ( shutdown.exe is a Windows built-in utility)
au3 :: Shutdown(32) \ Bring the system into 'Standby' power saving mode.
<o> <h3>5. wait 20 seconds .... "stop" me?</h3></o> drop cr 20000 nap
<o> <h3>4. wait 20 seconds .... "stop" me?</h3></o> drop cr 20000 nap
<o> <h3>3. wait 20 seconds .... "stop" me?</h3></o> drop cr 20000 nap
<o> <h3>2. wait 20 seconds .... "stop" me?</h3></o> drop cr 20000 nap
<o> <h3>1. wait 20 seconds .... "stop" me?</h3></o> drop cr 20000 nap
[again]

<comment>

	Copy from autoit help
	The shutdown code is a combination of the following values:
		$SD_LOGOFF (0) = Logoff
		$SD_SHUTDOWN (1) = Shutdown
		$SD_REBOOT (2) = Reboot
		$SD_FORCE (4) = Force
		$SD_POWERDOWN (8) = Power down
		$SD_FORCEHUNG (16) = Force if hung
		$SD_STANDBY (32) = Standby
		$SD_HIBERNATE (64) = Hibernate

	Constants are defined in AutoItConstants.au3.

	Required values should be BitOR()'ed together. To shutdown and power down, 
	for example, the code would be BitOR($SD_SHUTDOWN, $SD_POWERDOWN).

	Standby or Hibernate are ignored if other codes are set.
	
</comment>




