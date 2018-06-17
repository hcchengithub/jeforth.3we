	\ utf-8
	\ Words that are for HTA only 

	s" misc.hta.f"	source-code-header
	
	: stamp ( -- ) \ Paste date-time at cursor position
		js> clipboardData.getData("text")  ( saved ) \ SAVE-restore
		now t.dateTime ( saved "date time" )
		js: clipboardData.setData("text",pop()) ( saved )
		<vb> WshShell.SendKeys "^v" </vb> 
		500 sleep js: clipboardData.setData("text",pop()) ( empty ) \ save-RESTORE
		;
		/// It works now 2016-05-16 18:11:03. Leave 'stamp' in inputbox then put cursor
		/// at target position, press Ctrl-Enter, then that's it! Date-time pasted to
		/// the target position. Only supported in 3hta so far.
	
	: beep ( -- ) \ Sounds a beep
		js: _beep_.play() 600 nap ;
		s" <embed id=_beep_ autostart=false enablejavascript=true src='" 
		char %WINDIR% env@ + s" \Media\chord.wav'></embed>" + </h> drop
		\ After html5.f and env.f, Setup embeded beep sound wave file
		\ Create an embed element that holds the beeping wave file.
		\ char embed createElement \ ele
		\ dup char id char beep setAttribute \ ele
		\ dup char src char %WINDIR% env@ s" \Media\Windows Ding.wav" + setAttribute \ ele
		\ dup char autostart char false setAttribute \ ele
		\ dup char enablejavascript char true setAttribute \ ele
		\ js: $(tos()).hide() eleHead swap appendChild \ 可以掛 header （與 body 同屬 document）但不能不掛

	<js>
		// HTA does not support Math.sign so far, fix it.
		// http://stackoverflow.com/questions/7624920/number-sign-in-javascript
		if (Math.sign==undefined)
			Math.sign = function sign(x) { return x > 0 ? 1 : x < 0 ? -1 : 0; };
	</js>

	: (aliases) ( Word [array] -- ) \ Make array of tokens to be aliases of the Word
		js> tos().length ( w a length ) ?dup if for ( w a )
			\ create one alias word
				js> tos().pop() ( w a name ) (create) reveal ( w a )
			\ copy from predecessor, arrays and objects are by reference
				<js> for(var i in tos(1)) last()[i] = tos(1)[i]; </js>
			\ touch up
				<js>
					last().type = "alias";
					last().predecessor = last().name;
					last().name = newname;
				</js>
		next then ( w a ) 2drop ;
		/// Used in DOS box batch program for jeforth to ignore DOS words.

	: aliases	( Word <name1 name2 ... > -- ) \ Make following tokens be aliases of the Word
		CR word s"  dummy" + :> split(/\s+/) 
		js: tos().pop() \ drop the dummy
		( Word array ) (aliases) ; 
		/// Used in DOS box batch program for jeforth to ignore DOS words.

proc-env COMPUTERNAME char 31ENB667 = [if]
    
	\ ----- NIC on/off utility -----
	
	0 value officeLAN  // ( -- n ) DeviceID of the OA LAN NIC. Change this for your case.
                       /// Loaded by find-office-nic command automatically
					   /// Need administrator privilege, Run 3HTA.bat through right click to 'Run as administrator'.
					   /// Set NIC deviceID : 19 to officeLAN
					   /// Get NIC deviceID : activeNIC :> deviceid
					   /// See all NIC devices : list-all-nic
					   /// "where deviceid = 8" is for my LRV2 OA

    : is-office-nic? ( "caption" -- boolean ) \ 用 Caption 來辨認 OA 的 office LAN 是那個 nic
                <js> tos().indexOf("ThinkPad USB-C Dock Ethernet")!=-1</jsV>
                <js> pop(1).indexOf("Intel(R) Ethernet Connection (4) I219-LM")!=-1</jsV>
                or ;
                    
    : find-office-nic ( -- ) \ Load officeLAN with office NIC automatically
                "" getNIC  ( nic nic ... ) \ No where clause, get all of them
                #nic ?dup if for 
                    >r r@ :> caption is-office-nic? \ 找到了 
                    if
                        r@ :> NetConnectionStatus==2 \ must be connected
                        if
                            r@ :> DeviceID to officeLAN
                        then
                    then
                    r> drop
                next then ;
                
    0 to officeLAN find-office-nic officeLAN [if] [else] 
    <js> alert("officeLAN not found! Manually '8 to officeLAN' for nicon,nicoff") </js> [then]
					   
	: (nicoff) 	( -- ) \ Turn off the NIC (the certain where clause is for my LRV2 only)
			  \ s" where deviceid = 19" getNIC :> disable() 
				officeLAN s" where deviceid = _id_" :> replace(/_id_/,pop()) getNIC :> disable() 
				dup if 
					\ return 5 is failed when not an administrator
					." Failed! Error code " . ." . Make sure to run as an administrator." cr
				else
					drop ." NIC device turned off sucessfully." cr
				then ;
				last :: comment=tick('officeLAN').comment
					   
	: nicon		( -- ) \ Turn on the NIC (the certain where clause is for my LRV2 only)
				\ s" where deviceid = 19" getNIC :> enable() 
				officeLAN s" where deviceid = _id_" :> replace(/_id_/,pop()) getNIC :> enable() 
				dup if 
					\ return 5 is failed when not an administrator
					." Failed! Error code " . ." . Make sure to run as an administrator." cr
				else
					drop ." NIC device turned on sucessfully." cr
				then ;
				last :: comment=tick('officeLAN').comment

	: nicoff 	( <minutes> -- ) \ Turn off the NIC 1~120 minutes, default 15 minutes
				CR word js> parseFloat(pop()) ( min|NaN ) 
				?dup if else 15 then \ default 15 minutes
				js> (tos()>=1)&&(tos()<=360) if else 
					." Error: Given time period must be > 1 and <= 120 (minutes)." cr exit 
				then (nicoff) ." It'll be back " dup . ."  minutes later." cr 60 * 1000 * 
				nap nicon ;
				/// Run (nicoff) to turn off the NIC permanently 
				last :: comment+=tick('officeLAN').comment

	\ : rdlan 	( minutes -- ) \ Disable office LAN to use RD LAN through WiFi for a period of time that > 1 minute and <= 120 minutes
	\ 			js> (tos()>=1)&&(tos()<=120) if else ." Error: Given time period must be > 1 and <= 120 (minutes)." cr exit then 
	\ 			nicoff 60 * 1000 * nap nicon ;
	\ 			last :: comment=tick('officeLAN').comment

[then]


\ --- The End ---

				