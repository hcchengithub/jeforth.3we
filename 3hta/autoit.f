
	s" autoit.f"	source-code-header

	<js> push(new ActiveXObject("AutoItX3.Control"))</js> constant au3 // ( -- AutoItX3 ) Get AutoItX3 object
	/// 直接查 autoitx.hlp 看其他命令。
	/// au3 :> version \ ==> 3.3.8.1 (string) autoitX dll version (equivalent to @autoitversion macro in AutoIt v3) 
	/// au3 :> RegRead("HKEY_LOCAL_MACHINE\\COMPONENTS","StoreFormatVersion")
	///     \ ==> 0x30002E0030002E0030002E003600 (string)
	///     au3 :> error \ ==> 0 (Not 1) OK
	/// au3 :> RegWrite("HKLM\SOFTWARE","TestKey","REG_SZ","Hello_this_is_a_test")
	/// au3 :> RegWrite("HKLM\SOFTWARE","TestKey","REG_MULTI_SZ","line1\nline2")
	/// au3 :> RegWrite("HKLM\SOFTWARE","TestKey","REG_BINARY","00AA5566")
	/// au3 :> RegWrite("HKLM\SOFTWARE","TestKey") create the key
	///     au3 :> error \ ==> 1 (Not 0) Success

