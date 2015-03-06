\ Big5

\ This module supports binary file read/write functions that are surprisingly not existing in JScript nor WSH.
\    save-binary-file    ( binary-string pathname -- ) Save binary-string to binary file
\    read-binary-file    ( pathname -- binary-string ) Read binary file into a binary string
\    binary-array>string ( array -- binary-string    ) Convert an array into binary string
\    binary-string>array ( binary-string -- array    ) Convert binary string into an array

\ JScript or WSH's FileSystemObject can not access binary files. Dr. Alexander J Turner has
\ resolved this problem through ADO. His binary.js is the solution.

\ binary.js creats a BinaryFile() class that has following members,
\   objBinaryFile.WriteAll(BinaryString)    writes the binary string to the binary file.
\   objBinaryFile.ReadAll()                 read the binary file and returns a binary string
\   objBinaryFile.d2h(43981)                convert decimal integer into a hex string
\   objBinaryFile.h2d("ABCD")               convert a hex strings into a decimal integer
\   objBinaryFile.path                      return the path name of the binary file

<vb> Set o = CreateObject("ADODB.Stream"): kvm.push(o) </vb> constant BinaryStream // ( -- ADODB.Stream-object ) Stream object for Read/Write binary file. 
BinaryStream js: kvm.BinaryStream=pop()
include.js js/binary.js

s" binary.f"	source-code-header // ( -- ) Switch vocabulary context to 'binary'

    <selftest>
		***** Demo usage of BinaryFile() class, Wrte/Read binary file ........
		marker -%-%-%-%-%-
		js: kvm.screenbuffer=kvm.screenbuffer?kvm.screenbuffer:""; \ enable kvm.screenbuffer, it stops working if is null.
		js> kvm.screenbuffer.length constant start-here // ( -- n ) 開始測試前的 kvm.screenbuffer 尾巴。
		( ------------ Start to do anything --------------- )
			code data0-255 ( -- binary-string ) \ Create a binary string of 0-255
				var ba = String.fromCharCode( // this is the JavaScript way to create a binary array
                  0,
                  1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,  12,  13,  14,  15,  16,  17,  18,  19,  20,
                 21,  22,  23,  24,  25,  26,  27,  28,  29,  30,  31,  32,  33,  34,  35,  36,  37,  38,  39,  40,
                 41,  42,  43,  44,  45,  46,  47,  48,  49,  50,  51,  52,  53,  54,  55,  56,  57,  58,  59,  60,
                 61,  62,  63,  64,  65,  66,  67,  68,  69,  70,  71,  72,  73,  74,  75,  76,  77,  78,  79,  80,
                 81,  82,  83,  84,  85,  86,  87,  88,  89,  90,  91,  92,  93,  94,  95,  96,  97,  98,  99, 100,
                101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120,
                121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140,
                141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160,
                161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180,
                181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200,
                201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220,
                221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240,
                241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255
				);
				push(ba);
			end-code
			last execute constant 0-255 // ( -- binary-string ) 
			<js> new kvm.BinaryFile("0-255.bin") </jsV> constant 0-255.bin // ( -- objBinaryFile )
			0-255 0-255.bin js> pop().WriteAll(pop())  \ now you've got a binary file "0-255.bin" with 0-255 in it
			0-255.bin js> pop().ReadAll(pop()) constant binary-string // ( -- binary-string ) 0-255 in it
			binary-string <js> for (var i=0,sum=0; i<tos().length; i++) sum+=tos().charCodeAt(i); sum </jsV> nip
			\ (255 + 0) * 256/2 = 32640 , says google
		( ------------ done, start checking ---------------- ) 
		js> stack.slice(0) <js> [32640] </jsV> isSameArray >r dropall r>
		-->judge [if] <js> [
			'BinaryStream'
		] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
		-%-%-%-%-%-
	</selftest>

    : writeBinaryFile ( binary-string pathname -- ) \ Save binary-string to binary file
        <js> new kvm.BinaryFile(pop()) </jsV> ( -- objBinaryFile )
        <js> pop().WriteAll(pop()) </js> ;

    : readBinaryFile ( binary-file-pathname -- binary-string ) \ Read binary file into a binary string
        <js> new kvm.BinaryFile(pop()) </jsV> ( -- objBinaryFile )
        <js> pop().ReadAll() </jsV> ;

    code binary-array>string ( byte-array -- binary-string ) \ Convert an array into binary string
        var bs="", ba = pop();
        for (var i=0; i<ba.length; i++) bs += String.fromCharCode(ba[i]);
        push(bs)
        end-code

    code binary-string>array ( binary-string -- array ) \ Convert binary string bytes into an array
        var bs=pop(), ba = [];
        for (var i=0; i<bs.length; i++) ba[i] = bs.charCodeAt(i);
        push(ba)
        end-code
		
		<selftest>
			***** readBinaryFile writeBinaryFile ........
			marker -%-%-%-%-%-
			( ------------ Start to do anything --------------- )
				char 0-255.bin readBinaryFile constant binaryString // ( -- "\0~\255" ) 
				binaryString binary-string>array constant binaryArray // ( -- [0,...,255] ) 
				binaryString <js> for (var i=0,sum=0; i<tos().length; i++) sum+=tos().charCodeAt(i); sum </jsV> nip \ 32640
				binaryArray  <js> for (var i=0,sum=0; i<tos().length; i++) sum+=tos()[i]; sum </jsV> nip \ 32640
				binaryArray binary-array>string binaryString = \ true
			( ------------ done, start checking ---------------- ) 
			js> stack.slice(0) <js> [32640,32640,true] </jsV> isSameArray >r dropall r>
			-->judge [if] <js> [
				'readBinaryFile',
				'writeBinaryFile',
				'binary-string>array',
				'binary-array>string'
			] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
			-%-%-%-%-%- char 0-255.bin DeleteFile
		</selftest>
    
	: array-slice ( array start end -- array' ) \ Slice the array from start to end. 
		js> pop(2).slice(pop(1),pop()) ;
		/// End is not included but 0 includes the last, -1 includes the one before the last.

	: .b 	base@ >r hex 2 .0r r> base! ; // ( n -- ) Print the number as a byte of hex-decimal
	: .w 	base@ >r hex 4 .0r r> base! ; // ( n -- ) Print the number as a word of hex-decimal
	: .d 	base@ >r hex 8 .0r r> base! ; // ( n -- ) Print the number as a dword of hex-decimal
	
		<selftest>
			***** Print binary numbers ........
			marker -%-%-%-%-%-
			js: kvm.screenbuffer=kvm.screenbuffer?kvm.screenbuffer:""; \ enable kvm.screenbuffer, it stop working if it's null.
			js> kvm.screenbuffer.length constant start-here // ( -- n ) 開始測試前的 kvm.screenbuffer 尾巴。
			selftest-invisible \ 我想讓畫面整潔，self-test 的過程可以看 kvm.screenbuffer。 
			( ------------ Start to do anything --------------- )
			123 .b cr \ 7b
			321 .w cr \ 0141
			888 .d cr \ 00000378
			( ------------ done, start checking ---------------- ) 
			selftest-visible
			start-here <js> kvm.screenbuffer.slice(pop()).indexOf("7b")!=-1 </jsV> \ true 
			start-here <js> kvm.screenbuffer.slice(pop()).indexOf("0141")!=-1 </jsV> \ true 
			start-here <js> kvm.screenbuffer.slice(pop()).indexOf("00000378")!=-1 </jsV> \ true 
			js> stack.slice(0) <js> [true,true,true] </jsV> isSameArray >r dropall r>
			-->judge [if] <js> [
				'.b',
				'.w',
				'.d'
			] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
			-%-%-%-%-%-
		</selftest>
