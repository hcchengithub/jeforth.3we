
	s" autoit.f"	source-code-header

	<js> push(new ActiveXObject("AutoItX3.Control"))</js> constant au3 // ( -- AutoItX3 ) Get AutoItX3 object
	/// 直接查 autoitx.hlp 看其他命令。
	/// au3 :> version \ ==> 3.3.8.1 (string) autoitX dll version (equivalent to @autoitversion macro in AutoIt v3) 
	/// au3 :> WinList("[all]") .VBArray \ ==> 427,,Magnifier Touch,00070EE8,...,AutoItX Help,00090C26
	/// -- Read registry -- 
	/// au3 :> RegRead("HKEY_LOCAL_MACHINE\\COMPONENTS","StoreFormatVersion")
	/// \ ==> 0x30002E0030002E0030002E003600 (string)
	/// au3 :> error \ ==> 0 OK
	/// -- Write registry --
	/// au3 :> RegWrite("HKCU\\SOFTWARE","TestKey") create the key
	/// au3 :> RegWrite("HKCU\\SOFTWARE","TestKey","REG_SZ","Hello_this_is_a_test")
	/// au3 :> RegWrite("HKCU\\SOFTWARE","TestKey","REG_MULTI_SZ","line1\nline2")
	/// au3 :> RegWrite("HKCU\\SOFTWARE","TestKey","REG_BINARY","binaryString")  
	/// 注意! 必須用 binary string, number 會被直接當成 string, 而 string 有何意義？
	/// 正確用法是： js> [1,2,3,4,5,6,7,8,9,10,11] binary-array>string 
	/// au3 :> RegWrite("HKCU\\EUDC\\","","REG_BINARY",pop()) \ ==> 1 表示成功
	/// 以上 return 1 Success 注意這是 return 值，不同於 regRead 只能用 au3.error 表示成敗。
    /// 下面這行成功，且要用 douuble back slash，原因很清楚。
    /// <js> g.au3.RegWrite("HKCU\\Keyboard Layout\\","test","REG_SZ","test")</js>
    /// 下面這行幾乎照抄上一行，結果失敗。為什麼？因為 jeforth 的 s".." 不需要 double back slash。
    /// 【失敗】s" HKCU\\Keyboard Layout\\" s" test" s" REG_SZ" s" 6969" au3 :: RegWrite(pop(3),pop(2),pop(1),pop(0))
    /// 改成這樣就好了：
    /// 【成功】s" HKCU\Keyboard Layout\" s" test" s" REG_SZ" s" 6969" au3 :: RegWrite(pop(3),pop(2),pop(1),pop(0))
	/// -- Delete registry value --
	/// 刪除實驗遺跡：
	/// s" HKCU\Keyboard Layout\" s" test" au3 :: RegDeleteVal(pop(1),pop())
	
