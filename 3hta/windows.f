
	\ windows指令集锦 (1/245)   Windows tips windows commands from ice zhang tip command
	\ https://www.evernote.com/shard/s22/nl/2472143/72fd4186-b618-4ed3-b824-be8235a2a336
	
	: mac-address	( -- ) \ List all LAN cards and Wifi cards' Mac-address
		<shell> getmac /v</shell> ;
		/// Network cards' physical ID.

	: charmap ( -- ) \ Get characters like Ã î ͏ ҉ ѿ ѹ ҈ Ӧ Ҋ ֟ ؓ Ḝ Ṩ Ṧ Ẏ Ỷ ỷ ² ¹ ³ 
		<shell> charmap </shell> ;
		/// Copy foreign characters 
		/// Ҋ҈ ỶḜṨ

	
	
	