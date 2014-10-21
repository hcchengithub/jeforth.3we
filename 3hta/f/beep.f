
	s" beep.f"	source-code-header 
	
	\ After html5.f and env.f, Setup embeded beep sound wave file
	
	\ Create an embed element that holds the beeping wave file.
	\ char embed createElement \ ele
	\ dup char id char beep setAttribute \ ele
	\ dup char src char %WINDIR% env@ s" \Media\Windows Ding.wav" + setAttribute \ ele
	\ dup char autostart char false setAttribute \ ele
	\ dup char enablejavascript char true setAttribute \ ele
	\ js: $(tos()).hide() eleHead swap appendChild \ 可以掛 header （與 body 同屬 document）但不能不掛

	s" <embed id=beep autostart=false enablejavascript=true src='" 
	char %WINDIR% env@ +
	s" \Media\Windows Information Bar.wav'></embed>" + 
	</h> constant eleBeep // ( -- element ) HTML embed element of the beep sound wave file.
	js: kvm.beep=function(){beep.Play()} \ kvm.beep() can be used by call back functions
	: beep	js: kvm.beep() ; // ( -- ) Sounds a beep
				



				