
	: regRead 	( "strKey[\]"|"value-name" -- reg ) \ Read Windows registry 參 SCRIPT56.CHM 
				WshShell :> regRead(pop()) ;
				/// s" HKLM\SYSTEM\CurrentControlSet\Control\Keyboard Layout\Scancode Map" regRead constant regkey
				/// 結果是個呈現為 [object Object] (unknown) 的 VBArray 因為是 REG_BINARY。
				/// regkey :> getItem(0) \ ==> 0
				/// regkey :> getItem(8) \ ==> 6
				/// regkey :> lbound() \ ==> 0 OK 
				/// regkey :> ubound() \ ==> 35 OK 

	: regWrite 	( "strKey[\]"|"value-name" value "type" -- ) \  Write Windows registry 參 SCRIPT56.CHM 
				WshShell :: regWrite(pop(2),pop(1),pop(0)) ;
				/// -- Type -- 
				/// String  REG_SZ 
				/// String  REG_EXPAND_SZ 
				/// Integer REG_DWORD 
				/// Integer REG_BINARY 
				/// -- Example --
				/// s" HKCU\Software\ACME\FortuneTeller\" 1 s" REG_BINARY" regWrite
				/// s" HKCU\Software\ACME\FortuneTeller\MindReader" s" Goocher!" s" REG_SZ" regWrite
				/// s" HKLM\SYSTEM\CurrentControlSet\Control\Keyboard Layout\Scancode MapTest" s" 11223344" s" REG_BINARY" regWrite
				/// 【成功】s" HKCU\Keyboard Layout\test" s" BBBB" js> g.WshShell.regWrite(pop(1),pop(0))
				/// 【成功】s" HKCU\Keyboard Layout\test" s" a test" s" REG_SZ" regWrite
				/// 【失敗】s" HKCU\Keyboard Layout\test" s" 001122AABB" s" REG_BINARY" regWrite
				/// 【成功】s" HKCU\Keyboard Layout\test2" 0x00112233AA s" REG_BINARY" regWrite \ ==> aa 33 22 11
				/// 要處理超過 DWORD 的 binary 必須改用 autoitx 它用 Binary string 來表達 REG_BINARY。
				
	: regCreate	( "strKey[\]" -- ) \  Create Windows registry key 參 SCRIPT56.CHM 
				WshShell :: regWrite(pop()) ;
				/// s" HKCU\Keyboard Layout\Substitutes\Scancode Map" regCreate
				
	<comment>
		Acer notebook S7 [HKLM\SYSTEM\CurrentControlSet\Control\Keyboard Layout\Scancode Map]
		0,0,0,0, \ header
		0,0,0,0, \ header
		6,0,0,0, \ 6 表示改了 5 個 key (n+1=6, n=5)
		71,224,56,224, \ (71,224) Home to replace (56,224) Right Alt
		79,224,83,224, \ (79,224) End to replace (83,224) Delete
		83,224,58,0,   \ (83,224) Delete to replace (58,0) CapsLock or 3A00
		74,0,71,224,   \ (74,0) Num Pad - to replace (71,224) Home
		78,0,79,224,   \ (78,0) Num Pad + to replace (79,224) End
		0,0,0,0 \ ending 

		0,0,0,0, \ header
		0,0,0,0, \ header
		2,0,0,0, \ 2 表示改了 1 個 key (n+1=2, n=1)
		0x20,0xE0,58,0,   \ Mute 20 E0 to replace (58,0) CapsLock or 3A 00
		0,0,0,0 \ ending 

		js> [0,0,0,0,0,0,0,0,2,0,0,0,0x20,0xE0,58,0,0,0,0,0] binary-array>string 
		s" REG_BINARY"
		s" Scancode Map"
		s" HKLM\SYSTEM\CurrentControlSet\Control\Keyboard Layout\"
		au3 :> RegWrite(pop(),pop(),pop(),pop()) tib.
		
		
		
		
		Special Keys Scan Code 
			Application 5D E0 
			Backspace 0E 00 
			Caps Lock 3A 00 
			Delete 53 E0 
			End 4F E0 
			Enter 1C 00 
			Escape 01 00 
			HOME 47 E0 
			Insert 52 E0 
			Left Alt 38 00 
			Left Ctrl 1D 00 
			Left Shift 2A 00 
			Left Windows 5B E0 
			Num Lock 45 00 
			Page Down 51 E0 
			Page Up 49 E0 
			Power 5E E0 
			PrtSc 37 E0 
			Right Alt 38 E0 
			Right Ctrl 1D E0 
			Right Shift 36 00 
			Right Windows 5C E0 
			Scroll Lock 46 00 
			Sleep 5F E0 
			Space 39 00 
			Tab 0F 00 
			Wake 63 E0 
		Number Pad Keys Scan Code 
			0 52 00 
			1 4F 00 
			2 50 00 
			3 51 00 
			4 4B 00 
			5 4C 00 
			6 4D 00 
			7 47 00 
			8 48 00 
			9 49 00 
			- 4A 00 
			* 37 00 
			. 53 00 
			/ 35 E0 
			+ 4E 00 
			Enter 1C E0

		Arrow Keys Scan Code 
			Down 50 E0 
			Left 4B E0 
			Right 4D E0 
			Up 48 E0

		Function Keys Scan Code 
			F1 3B 00 
			F2 3C 00 
			F3 3D 00 
			F4 3E 00 
			F5 3F 00 
			F6 40 00 
			F7 41 00 
			F8 42 00 
			F9 43 00 
			F10 44 00 
			F11 57 00 
			F12 58 00 
			F13 64 00 
			F14 65 00 
			F15 66 00

		Application Keys Scan Code 
			Calculator 21 E0 
			E-Mail 6C E0 
			Media Select 6D E0 
			Messenger 11 E0 
			My Computer 6B E0

		QWERTY Keys Scan Code 
			' " 28 00 
			- _ 0C 00 
			, < 33 00 
			. > 34 00 
			/? 35 00 
			;: 27 00 
			[ { 1A 00 
			\ | 2B 00 
			] } 1B 00 
			` ~ 29 00 
			= + 0D 00 
			0 ) 0B 00 
			1 ! 02 00 
			2 @ 03 00 
			3 # 04 00 
			4 $ 05 00 
			5 % 06 00 
			6 ^ 07 00 
			7 & 08 00 
			8 * 09 00 
			9 ( 0A 00 
			A 1E 00 
			B 30 00 
			C 2E 00 
			D 20 00 
			E 12 00 
			F 21 00 
			G 22 00 
			H 23 00 
			I 17 00 
			J 24 00 
			K 25 00 
			L 26 00 
			M 32 00 
			N 31 00 
			O 18 00 
			P 19 00 
			Q 10 00 
			R 13 00 
			S 1F 00 
			T 14 00 
			U 16 00 
			V 2F 00 
			W 11 00 
			X 2D 00 
			Y 15 00 
			Z 2C 00 
			F-Lock Keys Scan Code 
			Close 40 E0 
			Fwd 42 E0 
			Help 3B E0 
			New 3E E0 
			Office Home 3C E0 
			Open 3F E0 
			Print 58 E0 
			Redo 07 E0 
			Reply 41 E0 
			Save 57 E0 
			Send 43 E0 
			Spell 23 E0 
			Task Pane 3D E0 
			Undo 08 E0

		Media Keys Scan Code 
			Mute 20 E0 
			Next Track 19 E0 
			Play/Pause 22 E0 
			Prev Track 10 E0 
			Stop 24 E0 
			Volume Down 2E E0 
			Volume Up 30 E0

		Web Keys Scan Code 
			Back 6A E0 
			Favorites 66 E0 
			Forward 69 E0 
			HOME 32 E0 
			Refresh 67 E0 
			Search 65 E0 
			Stop 68 E0

		Disable Turn Key Off 00 00

		Manufacturer Special Keys Scan Code 
			Dell Internet 01 E0 
			Dell Fn No Code Dell Decrease Brightness 40 05 E0 
			Dell Increase Brightness 40 06 E0 
			Dell CRT/LCD No Code Logitech iTouch 13 E0 
			Logitech Shopping 04 E0 
			Logitech Webcam 12 E0

		Non-English (US) Keys Scan Code 
			¥ - 7D 00 45 E0 
			International Keyboard Next to Enter 2B E0 
			Next to L-Shift 56 E0 
			Brazilian Keyboard Next to R-Shift 73 E0 
			Far East Keyboard DBE_KATAKANA 70 E0 
			DBE_SBCSCHAR 77 E0 
			CONVERT 79 E0 
			NONCONVERT 7B E0

		Microsoft Natural Multimedia Keyboard Scan Code 
			My Documents My Pictures 64 E0 
			My Music 3C E0 
			Mute 20 E0 
			Play/Pause 22 E0 
			Stop 24 E0 
			+ (Volume up) 30 E0 
			- (Volume down) 2E E0 
			|<< (Previous) 10 E0 
			>>| (Next) 19 E0 
			Media 6D E0 
			Mail 6C E0 
			Web/Home 32 E0 
			Messenger 05 E0 
			Calculator 21 E0 
			Log Off 16 E0 
			Sleep 5F E0 
			Help (on F1 key) 3B E0 
			Undo (on F2 key) 08 E0 
			Redo (on F3 key) 07 E0 
			New (on F4 key) 
			Open (on F5 key) 
			Close (on F6 key) 
			Replay (on F7 key) 
			Fwd (on F8 key) 42 E0 
			Send (on F9 key) 43 E0 
			Spell (on F10 key) 23 E0 
			Save (on F11 key) 57 E0 
			Print (on F12 key) 58 E0   


























			  3: 

			  
			  
			  
			  
		特別加註: 同儕B10人員為離職同仁"袁婷婷 (K1207600)".	


		> excel.app :> selection .s ==> [object Object] (object)
		> excel.app :> selection.offset(1,1).range("a1").item(1).value .
		b2 OK 
		> excel.app :> selection.offset(0,0).range("a1").value .
		a1 OK 
		> excel.app :> selection.offset(0,0).range("a1").value .
		b2 OK 
		> excel.app :> selection.range("a1").value .
		b2 OK 
		> excel.app :> selection.offset(0,0).value .
		[object Object] OK 
		> excel.app :> selection.offset(0,0).count .
		9 OK 
		> excel.app :> selection.offset(1,1).count .
		9 OK 
		> excel.app :> selection.item(1) .
		b2 OK 
		> excel.app :> selection.item(9) .
		d4 OK 
		> excel.app :> selection.offset(1,1).item(1) .
		undefined OK 
		> excel.app :> selection.offset(1,1).range("a1").item(1) .
		undefined OK 
		> excel.app :> selection.offset(1,1).range("a1").value .
		undefined OK 
		> excel.app :> selection.offset(1,1).range("a1").value .
		c3 OK 
		> excel.app :> selection.offset(1,1).range("a1").item(1) .
		c3 OK 
		> excel.app :> selection.offset(1,1).range("a1").item(1) .s
			  0:           0           0h (number)
			  1:         NaN           0h (number)
			  2:         NaN           0h (number)
			  3:         123          7bh (number)
			  4: [object Object] (object)
			  5: undefined (undefined)
			  6: undefined (undefined)
			  7: [object Object] (object)
			  8: true (boolean)
			  9: true (boolean)
			 10: true (boolean)
			 11: c3 (object)
		 OK 
		> excel.app :> selection.offset(1,1).range("a1").item(1).value .s
			  0:           0           0h (number)
			  1:         NaN           0h (number)
			  2:         NaN           0h (number)
			  3:         123          7bh (number)
			  4: [object Object] (object)
			  5: undefined (undefined)
			  6: undefined (undefined)
			  7: [object Object] (object)
			  8: true (boolean)
			  9: true (boolean)
			 10: true (boolean)
			 11: c3 (object)
			 12: c3 (string)
		 OK 
		> excel.app :> selection.offset(1,1).range("a1").item(1).value tib.
		excel.app :> selection.offset(1,1).range("a1").item(1).value \ ==> c3 (string)
		 OK 
		> excel.app :> selection.offset(1,1).range("a1").item(1) tib.
		excel.app :> selection.offset(1,1).range("a1").item(1) \ ==> c3 (object)
		 OK 
		> excel.app :> selection.offset(1,1).range("a1") tib.
		excel.app :> selection.offset(1,1).range("a1") \ ==> c3 (object)
		 OK 
		> excel.app :> selection.range("a1") tib.
		excel.app :> selection.range("a1") \ ==> b2 (object)
		 OK 
		> excel.app :> selection tib.
		excel.app :> selection \ ==> 
		------------------- P A N I C ! -------------------------
		JavaScript error on word "tib." : String expected
		stop: false
		compiling: false
		stack.length: 14
		rstack.length: 0
		ip: 0
		ntib: 27
		tib.length: 27
		tib: excel.app :> selection tib.<ntib>...

		J a v a S c r i p t   C o n s o l e
		Usage: js: if(kvm.debug){kvm.jsc.prompt='msg';eval(kvm.jsc.xt)}
		jsc> q
		 OK 
		> excel.app :> selection .s
			  0:           0           0h (number)
			  1:         NaN           0h (number)
			  2:         NaN           0h (number)
			  3:         123          7bh (number)
			  4: [object Object] (object)
			  5: undefined (undefined)
			  6: undefined (undefined)
			  7: [object Object] (object)
			  8: true (boolean)
			  9: true (boolean)
			 10: true (boolean)
			 11: c3 (object)
			 12: c3 (string)
			 13: [object Object] (object)
			 14: [object Object] (object)
	</comment>
	 
	 