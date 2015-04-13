	\ 80286 PC DOS assembler

	s" 80286asm.f"	.( Including ) dup . cr also forth definitions 
					char -- over over + + (marker) (vocabulary) 
					last execute definitions
					// ( -- ) Switch to 80286asm vocabulary

    : malloc    ( -- array ) \ Allocate an array
                js: push([]) ;
                /// Assembler space allocator

                <selftest>
					marker --80286asm.f-self-test--
					include selftest.f
					*** 80286asm.f ... 
					char 80286asm.f find-vocs nip \ true
					==>judge [if] <js> ['80286asm.f'] </jsV> all-pass [then]
				</selftest>

                <selftest>
					*** nop <== wut, explain the test strategy ... 
					js> stack.slice(0) js> [] isSameArray >r dropall r>
					==>judge [if] <js> ['nop'] </jsV> all-pass [then]
				</selftest>

                <selftest>
					*** malloc allocates an normal array ... 
                    malloc js> pop().length 0 = \ true
					==>judge [if] <js> ['malloc'] </jsV> all-pass [then]
				</selftest>

    malloc constant target-space // ( -- space[] ) Get target space which is an array.
    variable target-here 0 target-here ! // ( -- var ) Target space 'here' variable

    code binary-array>string ( byte-array -- binary-string ) \ Convert an array into binary string
        var ba = pop(), bs=new Buffer(ba.length); // The trick Node.js handles binary data
        for (var i=0; i<ba.length; i++) bs[i] = ba[i];
        push(bs)
        end-code

    code binary-string>array ( binary-string -- array ) \ Convert binary string bytes into an array
        var bs=pop(), ba = [];
        for (var i=0; i<bs.length; i++) ba[i] = bs.charCodeAt(i);
        push(ba)
        end-code
    
	: array-slice ( array start end -- array' ) \ Slice the array from start to end. 
		js> pop(2).slice(pop(1),pop()) ;
		/// End is not included but 0 includes the last, -1 includes the one before the last.

	: .b 	base@ >r hex 2 .0r r> base! ; // ( n -- ) Print the number as a byte of hex-decimal
	: .w 	base@ >r hex 4 .0r r> base! ; // ( n -- ) Print the number as a word of hex-decimal
	: .d 	base@ >r hex 8 .0r r> base! ; // ( n -- ) Print the number as a dword of hex-decimal

    : word>bytes ( word -- high-byte low-byte ) \ Convert a word into two bytes
                0xffff AND ( take care of negative numbers ) dup 256 / int swap 255 AND ;

                <selftest>
					*** word>bytes 0x1234 => 0x12 0x34 ... 
                    0x1234 word>bytes 0x34 = swap 0x12 = and \ true
                    0x5678 word>bytes 0x78 = swap 0x56 = and \ true true
					and ==>judge [if] <js> ['word>bytes'] </jsV> all-pass [then]
				</selftest>

    : bytes>word ( high-byte low-byte -- word ) \ Convert two bytes into a word
                0xff AND ( take care of negative numbers ) swap 0xff AND 256 * + ;

                <selftest>
					*** bytes>word 0x12 0x34 => 0x1234 ... 
                    0x12 0x34 bytes>word 0x1234 = \ true
                    0x56 0x78 bytes>word 0x5678 = \ true true
					and ==>judge [if] <js> ['word>bytes'] </jsV> all-pass [then]
				</selftest>

    : org       ( address -- ) \ Specify target space
                target-here ! ;

    : ++        ( variable -- ) \ variable++
                dup @ 1+ swap ! ;

    : 8,        ( byte -- ) \ Compile the given binary byte into target space.
                0xff AND ( take care of negative numbers )
                target-here @ target-space js: pop()[pop()]=pop() \ drop the length
                target-here ++ ;

    : 16,       ( word -- ) \ Compile the given binary word into target space.
                word>bytes ( high-byte low-byte ) 8, 8, ;

                <selftest>
					*** malloc target-space 8, 16, ++ org target-here ... 
					malloc       js> mytypeof(pop()) char array = [if] 1 [else] 0 [then] \ 1
					target-space js> mytypeof(pop()) char array = [if] 1 [else] 0 [then] \ 1
					0 org
					1 2 3 8, 8, 8, 0x1234 16,
					target-space js> pop().pop() \ 18
					target-space js> pop().pop() \ 52
					target-space js> pop().pop() \ 1
					target-space js> pop().pop() \ 2
					target-space js> pop().pop() \ 3
					js> stack.slice(0) js> [1,1,18,52,1,2,3] isSameArray >r dropall r>
					==>judge [if] <js> ['malloc','target-space','8,','16,','++','org','target-here'] </jsV> all-pass [then]
				</selftest>


    : peek8     ( addr -- byte ) \ Read a byte from target space
                target-space js> pop()[pop()] 255 AND ( take care of negative numbers ) ;

    : poke8     ( byte addr -- ) \ Write a byte to target space
                swap 255 AND ( take care of negative numbers ) swap target-space js: pop()[pop()]=pop() ;

                <selftest>
					*** peek8 poke8 ... 
					1234567890 0xf poke8 0xf peek8
					js> stack.slice(0) js> [210] isSameArray >r dropall r>
					==>judge [if] <js> ['peek8', 'poke8'] </jsV> all-pass [then]
				</selftest>

    : peek16    ( addr -- word ) \ Read a word from target space
                dup peek8 swap 1+ peek8 256 * + ;

    : poke16    ( word addr -- ) \ Write a word to target space
                swap word>bytes ( addr high low ) -rot over 1+ ( low addr high addr' ) poke8 poke8 ;

                <selftest>
					*** peek16 poke16 ... 
					0x1234567890 0xe poke16 0xe peek16
					js> stack.slice(0) js> [0x7890] isSameArray >r dropall r>
					==>judge [if] <js> ['peek16','poke16'] </jsV> all-pass [then]
				</selftest>

    code cmove(t>t) ( fStart fEnd tStart -- ) \ move from (fStart-fEnd) to tStart, where fStart,fEnd,tStart are target addresses.
                var ts=pop(), fe=pop(), fs=pop(), len=Math.max(0,fe-fs+1);
                fortheval("target-space"); var space=pop();
                for(var i=0; i<len; i++) {
                    if(typeof space[fs+i] == "undefined") break;
                    space[ts+i] = space[fs+i];
                }
                end-code
                /// Supports the trick that turns cmove into the filling function.
                /// fStart must be smaller than fEnd or it does nothing.

                <selftest>
					*** cmove(t>t) ... 
                    0x0000 org 0x11 8, 0x22 8, 0x33 8, 0x44 8, 0x0000 0x0ff 4 - 0x0004 cmove(t>t)
                    0xfc peek8 \ 0x11
                    0xfd peek8 \ 0x22
                    0xfe peek8 \ 0x33
                    0xff peek8 \ 0x44
					js> stack.slice(0) js> [0x11,0x22,0x33,0x44] isSameArray >r dropall r>
					==>judge [if] <js> ['cmove(t>t)'] </jsV> all-pass [then]
				</selftest>

    code cmove(h>t) ( [host] tStart -- ) \ move from [host] to tStart, where [host] is host binary array, tStart is target addresses.
                var ts=pop(), from=pop(), len=from.length;
                fortheval("target-space"); var space=pop();
                for(var i=0; i<len; i++) {
                    space[ts+i] = from[i];
                }
                end-code

                <selftest>
					*** cmove(h>t) ...
                    js> [0x11,0x22,0x33,0x44] 0x300 cmove(h>t)
                    0x300 peek8 \ 0x11
                    0x301 peek8 \ 0x22
                    0x302 peek8 \ 0x33
                    0x303 peek8 \ 0x44
					js> stack.slice(0) js> [0x11,0x22,0x33,0x44] isSameArray >r dropall r>
					==>judge [if] <js> ['cmove(h>t)'] </jsV> all-pass [then]
				</selftest>

    code hex16  ( address -- ) \ Dump target space 16 bytes from address
                var start=pop();
                fortheval("target-space"); var space=pop();
                for(var i=0; i<16; i++){
                    if (i==8) fortheval("space char - . ");
                    if (space[start+i] == undefined) push("??");
                    else push(space[start+i]);
                    fortheval("space 0x2 .0r");
                }
                fortheval("2 spaces");
                for(var i=0; i<16; i++){
                    var cc = space[start+i];
                    switch(cc){
                        case undefined : push("?"); break;
                        case 160 :
                        case 158 :
                        case 157 :
                        case 149 :
                        case 144 :
                        case 143 :
                        case 142 :
                        case 141 :
                        case 129 :
                        case   9 :
                        case   8 :
                        case   7 :
                        case  10 :
                        case  13 : push("_"); break;
                        default : push(cc); fortheval("ASCII>char");
                    }
                    fortheval(".");
                }
                fortheval("cr");
                end-code
                /// base must be 16 before calling me

                <selftest>
					*** hex16 ...
                    cr 0 hex16
					js> stack.slice(0) js> [] isSameArray >r dropall r>
					==>judge [if] <js> ['hex16'] </jsV> all-pass [then]
				</selftest>

    code dump(t) ( address -- ) \ Dump target space from address
                var start=pop();
                fortheval("cr base@ hex"); var basewas=pop();
                for (var i=0; i<16; i++){
                    push(start + i*16);
                    fortheval("dup 5 .0r space space hex16");
                }
                push(basewas); fortheval("base! cr");
                end-code
                /// Usage: 0x100 dump(t) <=== Hex dump 0x100 ~ 0x1FF

                <selftest>
					*** dump(t) ...
                    cr 0 dump(t)
					js> stack.slice(0) js> [] isSameArray >r dropall r>
					==>judge [if] <js> ['dump(t)'] </jsV> all-pass [then]
				</selftest>

\ -------------- Label tools ---------------------------------------------------------

    0xAB constant AB // ( -- 0xab ) Absolute flag of the L: command. Opposed to 8 and 16 bits relative reference.

	code name>word  push(tick(pop())) end-code // ( "name" -- obj ) Translate TOS to its Word() object

    : L:        ( <label> -- ) \ Resolve all above 8rel> 16rel> labels. label is absolute address constant.
\ ( _debug_ ) js: if(kvm.debug){kvm.jsc.prompt='000';eval(kvm.jsc.xt)}
                create
                    char [ js> last().name char ] + + 
\ ( _debug_ ) js: if(kvm.debug){kvm.jsc.prompt='000fffff';eval(kvm.jsc.xt)}
					(') ( word.name )
\ ( _debug_ ) js: if(kvm.debug){kvm.jsc.prompt='000aaaaa';eval(kvm.jsc.xt)}
                    ?dup if ( word.name )
                        target-space target-here @
\ ( _debug_ ) js: if(kvm.debug){kvm.jsc.prompt='000bbbb';eval(kvm.jsc.xt)}
                        <js>
                            var dest=pop(), target_space=pop(), label=pop(), storage=label.storage;
                            for(var i=0; i<storage.length; i++) {
                                var offset = dest - storage[i];
                                var size = target_space[storage[i]-1]; // this is a trick, this value was stored in by fwd>
// ( _debug_ ) if(kvm.debug){kvm.jsc.prompt='11cccc';eval(kvm.jsc.xt)}
                                switch (size){
                                    case 8: // 8 bits relative address
// ( _debug_ ) if(kvm.debug){kvm.jsc.prompt='11111';eval(kvm.jsc.xt)}
                                        if (offset>127){
                                            push(storage[i]); push(last().name);
                                            fortheval("cr .' Error! label ' . .'  connects ' .w .'  to ' target-here .w .' , overloads one byte.' cr *debug* Error> ");
                                        }
// ( _debug_ ) if(kvm.debug){kvm.jsc.prompt='2222';eval(kvm.jsc.xt)}
                                        target_space[storage[i]-1] = offset;
                                        break;
                                    case 16: // 16 bits relative address
                                        if (offset>32767){
                                            push(storage[i]); push(last().name);
                                            fortheval("cr .' Error! label ' . .'  connects ' .w .'  to ' target-here .w .' , overloads one word.' cr *debug* Error> ");
                                        }
                                        target_space[storage[i]-2] = offset & 0xff;
                                        target_space[storage[i]-1] = parseInt(offset/256);
                                        break;
                                    case 0xab: // ABsolute address
                                        target_space[storage[i]-2] = dest & 0xff;
                                        target_space[storage[i]-1] = parseInt(dest/256);
                                        break;
                                    default:
                                        push(storage[i]);
                                        push(size);
                                        push(last().name);
                                        fortheval("cr .( Error! ) . .(  relative label size ) . .(  at ) .w .(  is unknown.) cr *debug* Error> ");
                                }
                            }
                            storage.splice(0,storage.length); // clean up the storage so we can re-use the same label
                        </js>
                    then
                    target-here @ ,
                does>
                    r> @
                ;
                /// A constant named 'label' will be created. Its value is target-here absolute address.
                /// All above "8|16|0xAB L> label"'s will be resolved. Then they can be re-used. The
                /// label's absolute address value is remained until next "L: label" appears again.

    : L>        ( bits <name> -- ) \ Forward refer to label "name".
                BL word ( bits "name" )
                \ dup (') if cr ." Error! " . ."  re-defined." cr *debug* Error>> then ( bits "name" )
                char [ swap + char ] + ( bits "[name]" )
                dup (')  ( bits "[name]" word["[name]"] )
                ?dup if ( bits "[name]" word["[name]"] )
                    nip target-here @ js: pop(1).storage.push(pop()) ( bits )
                else ( bits "[name]" )
                    (create) reveal target-here @ js> last().storage=[];last().storage.push(pop()) drop ( bits )
                then ( bits )
                target-here @ 1- poke8 ;
                /// The target label 'name' will be created as a new word '[name]' if it is not
                /// appeared before. '8|16|0xAB L> name' can appear many times to refer to the
                /// same destination 'L: name', that should appear later. After that, we use 'name'
                /// as a constant. The same label 'name' is allowed to be re-used in 'L: name'. This
                /// is to make it possible of using anonymous labels, just be careful.
				/// Note! So far 2013/6/9 there's no error check yet to alert if the expected 'L: name'
				/// never shown after all. So be aware of that risk. Use your editor to check all 
				/// 'L> name' manually is suggested.

                <selftest>
					*** L> L: ...
					0x100 org
					0x11 8, 0x12 8, 0x13 8,  8 L> LookForward
					0x21 8, 0x22 8, 0x23 8, 16 L> LookForward
					0x31 8, 0x32 8, 0x33 8, AB L> LookForward
					0x41 8, 0x42 8, 0x43 8, 
\ ( _debug_ ) js: kvm.debug=true .( _debug_ )
	L: LookForward  0x51 8, 0x52 8, 0x53 8, 
	( 0x10c )		LookForward 16, 0x63 8, 0x64 8,  8 L> LookForward
					LookForward 16, 0x73 8, 0x74 8, 16 L> LookForward
					LookForward 16, 0x83 8, 0x84 8, AB L> LookForward
	L: LookForward  0x91 8, 0x92 8, 0x93 8, 
	( 0x11b )		LookForward 16,

					0x100 dump(t)
					.( Compare by your eyes to check if the above code is generated correctly. ) cr
					.( 00100   11 12 09 21 06 00 31 0c - 01 41 42 43 51 52 53 0c) cr
					.( 00110   01 63 08 0c 01 04 00 0c - 01 1b 01 91 92 93 1b 01) cr
					.( 00120   ?? ?? ?? ?? ?? ?? ?? ?? - ?? ?? ?? ?? ?? ?? ?? ??) cr
					*debug* >> 
					js> stack.slice(0) js> [] isSameArray >r dropall r>
					==>judge [if] <js> ['L>','L:'] </jsV> all-pass [then]
				</selftest>

\ -------------- Assembly CPU instructions ---------------------------------------------------------

    : 8rel,     ( address -- ) \ Compile the given address into target space in relative form
                target-here @ 1+ - 8, ;

    : 16rel,    ( address -- ) \ Compile the given address into target space in relative form
                target-here @ 2+ - 16, ;

    :       8c:  create , does> r> @  8,                  ; // ( -- )
    :      16c:  create , does> r> @ 16,                  ; // ( -- )
    :     8c8#:  create , does> r> @  8,          8,      ; // ( #8 -- )
    :   8c8rel:  create , does> r> @  8,       8rel,      ; // ( #8 -- )
    :    8c16#:  create , does> r> @  8,         16,      ; // ( #16 -- )
    :  8c16rel:  create , does> r> @  8,      16rel,      ; // ( #16 -- )
    :   16c16#:  create , does> r> @ 16,         16,      ; // ( #16 -- )
    : 16c8#16#:  create , does> r> @ 16, swap     8,  16, ; // ( #8 #16 -- )
    :  16c8#8#:  create , does> r> @ 16, swap     8,   8, ; // ( #8 #8 -- )
    :    16c8#:  create , does> r> @ 16,          8,      ; // ( #8 -- )

    0x45    8c:         bp++                \ INC     BP
    0x4D    8c:         bp--                \ DEC     BP
    0xFC    8c:         cld                 \ CLD
    0xAD    8c:         lodsw               \ LODSW
    0x58    8c:         pop.ax              \ POP     AX
    0x5B    8c:         pop.bx              \ POP     BX
    0x59    8c:         pop.cx              \ POP     CX
    0x5F    8c:         pop.di              \ POP     DI
    0x5A    8c:         pop.dx              \ POP     DX
    0x5E    8c:         pop.si              \ POP     SI
    0x50    8c:         push.ax             \ PUSH    AX
    0x53    8c:         push.bx             \ PUSH    BX
    0x51    8c:         push.cx             \ PUSH    CX
    0x57    8c:         push.di             \ PUSH    DI
    0x52    8c:         push.dx             \ PUSH    DX
    0x56    8c:         push.si             \ PUSH    SI
    0xc3    8c:         return              \ RET
    0xcc    8c:         int3                \ INT3
    0x46    8c:         si++                \ INC     SI
	0x4E    8c:         si--				\ DEC	  SI
    0x44    8c:         sp++                \ INC     SP
    0xcf    8c:         iret                \ IRET
    0x90    8c:         nop                 \ NOP
    0xfa    8c:         cli                 \ CLI
    0xfb    8c:         sti                 \ STI


    0xB0    8c8#:       al=#8               \ MOV     AL,#8
    0xB4    8c8#:       ah=#8               \ MOV     AH,#8
    0xB2    8c8#:       dl=#8               \ MOV     DL,#8
    0xCD    8c8#:       int.#8              \ INT     #8
    0xE6    8c8#:       port#8=al           \ OUT     #8,AL 
    0xE4    8c8#:       al=port#8           \ IN      AL,#8
    0xEB    8c8rel:     jmp.r8              \ JMP     r8
    0x72    8c8rel:     jb.r8               \ JB      r8
    ' jb.r8 alias       jc.r8               \ JC      r8
    0x75    8c8rel:     jnz.r8              \ JNZ     r8
    ' jnz.r8 alias      jne.r8              \ JNE     r8

    0x74    8c8rel:     jz.r8               \ JZ      r8
    0x25    8c16#:      ax&#16              \ AND     AX,#16
    0xE8    8c16rel:    call.r16            \ CALL    r16
    0xE9    8c16rel:    jmp.r16             \ JMP     r16
    0xC008  16c:        al|al               \ OR      AL,AL
    0xD208  16c:        dl|dl               \ OR      DL,DL
    0xF608  16c:        dh|dh               \ OR      DH,DH
    0xDB09  16c:        bx|bx               \ OR      BX,BX 
    0xC009  16c:        ax|ax               \ OR      AX,AX
    0xD801  16c:        ax+bx               \ ADD     AX,BX
    0xC031  16c:        ax=0                \ XOR     AX,AX
    0xDB31  16c:        bx=0                \ XOR     BX,BX
    0xC931  16c:        cx=0                \ XOR     CX,CX
    0xD231  16c:        dx=0                \ XOR     DX,DX
    0xF631  16c:        si=0                \ XOR     SI,SI
    0xFF31  16c:        di=0                \ XOR     DI,DI
    0x058B  16c:        ax=[di]             \ MOV     AX,[DI]
    0xC88C  16c:        ax=cs               \ MOV     AX,CS
    0xEC87  16c:        bp<>sp              \ XCHG    BP,SP
    0xE389  16c:        bx=sp               \ MOV     BX,SP
    0xD88E  16c:        ds=ax               \ MOV     DS,AX
    0x37FF  16c:        push[bx]            \ PUSH    [BX]
    0xD1D1  16c:        rcl.cx              \ RCL     CX,1
    0xD08E  16c:        ss=ax               \ MOV     SS,AX
    0x5E89  16c8#:      [bp+#8]=bx          \ MOV     [BP+#8],BX
    0x4E89  16c8#:      [bp+#8]=cx          \ MOV     [BP+#8],CX
    0x7E89  16c8#:      [bp+#8]=di          \ MOV     [BP+#8],DI
    0x5689  16c8#:      [bp+#8]=dx          \ MOV     [BP+#8],DX
    0x7689  16c8#:      [bp+#8]=si          \ MOV     [BP+#8],SI
    0x478A  16c8#:      al=[bx+#8]          \ MOV     AL,[BX+#8]
    0x468B  16c8#:      ax=[bp+#8]          \ MOV     AX,[BP+00]
    0x458B  16c8#:      ax=[di+#8]          \ MOV     AX,[DI+33]
    0x458D  16c8#:      ax=lea[di+#8]       \ LEA     AX,[DI+#8]
    0x6E8D  16c8#:      bp=lea[bp+#8]       \ LEA     BP,[BP+#8]
    0xC583  16c8#:      bp+#8               \ ADD     BP,#8
    0xED83  16c8#:      bp-#8               \ SUB     BP,#8
    0x5E8B  16c8#:      bx=[bp+#8]          \ MOV     BX,[BP+#8]
    0x4E8B  16c8#:      cx=[bp+#8]          \ MOV     CX,[BP+#8]
    0x7E8B  16c8#:      di=[bp+#8]          \ MOV     DI,[BP+#8]
    0xFA80  16c8#:      dl?#8               \ CMP     DL,#8
    0x568B  16c8#:      dx=[bp+#8]          \ MOV     DX,[BP+#8]
    0x468F  16c8#:      pop[bp+#8]          \ POP     [BP+#8]
    0x76FF  16c8#:      push[bp+#8]         \ PUSH    [BP+#8]
    0x77FF  16c8#:      push[bx+#8]         \ PUSH    [BX+#8]
    0x768B  16c8#:      si=[bp+#8]          \ MOV     SI,[BP+#8]
    0x748B  16c8#:      si=[si+#8]          \ MOV     SI,[SI+#8]
    0xC483  16c8#:      sp+#8               \ ADD     SP,+02
    0x4689  16c8#:      [bp+#8]=ax          \ MOV     [BP+#8],AX
    0x4683  16c8#8#:    word[bp+#8]+#8      \ ADD     WORD PTR [BP+#8],#8
    0x6E83  16c8#8#:    word[bp+#8]-#8      \ SUB     WORD PTR [BP+#8],#8
    0x4780  16c8#8#:    byte[bx+#8]+#8      \ ADD     BYTE PTR [BX+#8],#8
    0x46C7  16c8#16#:   word[bp+#8]=#16     \ MOV     WORD PTR [BP+#8],#16
    0x6E81  16c8#16#:   word[bp+#8]-#16     \ SUB     WORD PTR [BP+#8],#16
    0x2F81  16c16#:     word[bx]-#16        \ sub     word[bx],#16
    0x07C7  16c16#:     word[bx]=#16        \ MOV     WORD PTR [BX],#16
    0xC381  16c16#:     bx+#16              \ ADD     BX,#16
    0xE0FF  16c:        jmp.ax              \ JMP     AX 
    0xE3FF  16c:        jmp.bx              \ JMP     BX 
    0xE1FF  16c:        jmp.cx              \ JMP     CX 
    0xE2FF  16c:        jmp.dx              \ JMP     DX 
    0xE6FF  16c:        jmp.si              \ JMP     SI 
    0xE7FF  16c:        jmp.di              \ JMP     DI 
    0x24FF  16c:        jmp.[si]            \ JMP     [SI] 
    0x25FF  16c:        jmp.[di]            \ JMP     [DI] 
    0x27FF  16c:        jmp.[bx]            \ JMP     [BX] 
    0xE5FF  16c:        jmp.bp              \ JMP     BP 
    0xE4FF  16c:        jmp.sp              \ JMP     SP 
    0x66FF  16c8#:      jmp.[bp+#8]         \ JMP     [BP+#8] 
    0x67FF  16c8#:      jmp.[bx+#8]         \ JMP     [BX+#8] 

    0xA1    8c16#:      ax=[#16]            \ MOV     AX,[#16] 
    0x1E8B  16c16#:     bx=[#16]            \ MOV     BX,[#16] 
    0x0E8B  16c16#:     cx=[#16]            \ MOV     CX,[#16] 
    0x168B  16c16#:     dx=[#16]            \ MOV     DX,[#16] 
    0x368B  16c16#:     si=[#16]            \ MOV     SI,[#16] 
    0x2E8B  16c16#:     bp=[#16]            \ MOV     BP,[#16] 
    0x268B  16c16#:     sp=[#16]            \ MOV     SP,[#16] 
    0xB8    8c16#:      ax=#16              \ MOV     AX,#16 
    0xBB    8c16#:      bx=#16              \ MOV     BX,#16 
    0xB9    8c16#:      cx=#16              \ MOV     CX,#16 
    0xBA    8c16#:      dx=#16              \ MOV     DX,#16 
    0xBE    8c16#:      si=#16              \ MOV     SI,#16 
    0xBF    8c16#:      di=#16              \ MOV     DI,#16 
    0xBD    8c16#:      bp=#16              \ MOV     BP,#16 
    0xBC    8c16#:      sp=#16              \ MOV     SP,#16 

    0x0789  16c:        [bx]=ax             \ MOV   [BX],AX
    0x1F89  16c:        [bx]=bx             \ MOV   [BX],BX
    0x0F89  16c:        [bx]=cx             \ MOV   [BX],CX
    0x1789  16c:        [bx]=dx             \ MOV   [BX],DX
    0x3789  16c:        [bx]=si             \ MOV   [BX],SI
    0x3F89  16c:        [bx]=di             \ MOV   [BX],DI
    0x0489  16c:        [si]=ax             \ MOV   [SI],AX
    0x1C89  16c:        [si]=bx             \ MOV   [SI],BX
    0x0C89  16c:        [si]=cx             \ MOV   [SI],CX
    0x1489  16c:        [si]=dx             \ MOV   [SI],DX
    0x3489  16c:        [si]=si             \ MOV   [SI],SI
    0x3C89  16c:        [si]=di             \ MOV   [SI],DI
    0x0589  16c:        [di]=ax             \ MOV   [DI],AX
    0x1D89  16c:        [di]=bx             \ MOV   [DI],BX
    0x0D89  16c:        [di]=cx             \ MOV   [DI],CX
    0x1589  16c:        [di]=dx             \ MOV   [DI],DX
    0x3589  16c:        [di]=si             \ MOV   [DI],SI
    0x3D89  16c:        [di]=di             \ MOV   [DI],DI

    0xD889  16c:        ax=bx               \ MOV AX,BX 
    0xD989  16c:        cx=bx               \ MOV CX,BX 
    0xDA89  16c:        dx=bx               \ MOV DX,BX 
    0xDE89  16c:        si=bx               \ MOV SI,BX 
    0xDF89  16c:        di=bx               \ MOV DI,BX 
    0xC389  16c:        bx=ax               \ MOV BX,AX 
    0xCB89  16c:        bx=cx               \ MOV BX,CX 
    0xD389  16c:        bx=dx               \ MOV BX,DX 
    0xF389  16c:        bx=si               \ MOV BX,SI 
    0xFB89  16c:        bx=di               \ MOV BX,DI 
    0x1C8B  16c:        bx=[si]             \ MOV	BX,[SI] 
    0x1D8B  16c:        bx=[di]             \ MOV	BX,[DI] 

    0x05    8c16#:      ax+#16              \ ADD	AX,0055 
    0xC383  16c8#:      bx+#8               \ ADD	BX,+55 
    0xC183  16c8#:      cx+#8               \ ADD	CX,+55 
    0xC283  16c8#:      dx+#8               \ ADD	DX,+55 
    0xC683  16c8#:      si+#8               \ ADD	SI,+55 
    0xC783  16c8#:      di+#8               \ ADD	DI,+55 

    0x0788  16c:        [bx]=al             \ MOV	[BX],AL 
    0x2788  16c:        [bx]=ah             \ MOV	[BX],AH 
    0x1F88  16c:        [bx]=bl             \ MOV	[BX],BL 
    0x3F88  16c:        [bx]=bh             \ MOV	[BX],BH 
    0x0F88  16c:        [bx]=cl             \ MOV	[BX],CL 
    0x2F88  16c:        [bx]=ch             \ MOV	[BX],CH 
    0x1788  16c:        [bx]=dl             \ MOV	[BX],DL 
    0x3788  16c:        [bx]=dh             \ MOV	[BX],DH 

    0x078B  16c:        ax=[bx]             \ MOV   AX,[BX]
    0x1F8B  16c:        bx=[bx]             \ MOV	BX,[BX] 
    0x0F8B  16c:        cx=[bx]             \ MOV	CX,[BX] 
    0x178B  16c:        dx=[bx]             \ MOV	DX,[BX] 
    0x378B  16c:        si=[bx]             \ MOV	SI,[BX] 
    0x3F8B  16c:        di=[bx]             \ MOV	DI,[BX] 
    0x278A  16c:        ah=[bx]             \ MOV	AH,[BX] 
    0x078A  16c:        al=[bx]             \ MOV	AL,[BX] 
    0x3F8A  16c:        bh=[bx]             \ MOV	BH,[BX] 
    0x1F8A  16c:        bl=[bx]             \ MOV	BL,[BX] 
    0x2F8A  16c:        ch=[bx]             \ MOV	CH,[BX] 
    0x0F8A  16c:        cl=[bx]             \ MOV	CL,[BX] 
    0x378A  16c:        dh=[bx]             \ MOV	DH,[BX] 
    0x178A  16c:        dl=[bx]             \ MOV	DL,[BX] 

    0xC489  16c:        sp=ax               \ MOV	SP,AX 
    0xDC89  16c:        sp=bx               \ MOV	SP,BX 
    0xCC89  16c:        sp=cx               \ MOV	SP,CX 
    0xD489  16c:        sp=dx               \ MOV	SP,DX 
    0xF489  16c:        sp=si               \ MOV	SP,SI 
    0xFC89  16c:        sp=di               \ MOV	SP,DI 

    0xE689  16c:        si=sp               \ MOV	SI,SP 
    0xE789  16c:        di=sp               \ MOV	DI,SP 
    0x5C8B  16c8#:      bx=[si+#8]          \ MOV	BX,[SI+22] 
    0x5D8B  16c8#:      bx=[di+#8]          \ MOV	BX,[DI+22] 

    0xC589  16c:        bp=ax               \ MOV	BP,AX 
    0xDD89  16c:        bp=bx               \ MOV	BP,BX 
    0xCD89  16c:        bp=cx               \ MOV	BP,CX 
    0xD589  16c:        bp=dx               \ MOV	BP,DX 
    0xF589  16c:        bp=si               \ MOV	BP,SI 
    0xFD89  16c:        bp=di               \ MOV	BP,DI 
    0xE889  16c:        ax=bp               \ MOV	AX,BP 
    0xEB89  16c:        bx=bp               \ MOV	BX,BP 
    0xE989  16c:        cx=bp               \ MOV	CX,BP 
    0xEA89  16c:        dx=bp               \ MOV	DX,BP 
    0xEE89  16c:        si=bp               \ MOV	SI,BP 
    0xEF89  16c:        di=bp               \ MOV	DI,BP 

    0x98    8c:         cbw	                \ CBW	 
    0xE088  16c:        al=ah               \ MOV	AL,AH 
    0x5E23  16c8#:      bx&[bp+#8]          \ AND	BX,[BP+#8] 
    0x5E0B  16c8#:      bx|[bp+#8]          \ OR	BX,[BP+#8] 
    0x5E33  16c8#:      bx^[bp+#8]          \ XOR	BX,[BP+#8] 

    0xDC88  16c:        ah=bl               \ MOV	AH,BL 
    0xF888  16c:        al=bh               \ MOV	AL,BH 
    0xFC88  16c:        ah=bh               \ MOV	AH,BH 
    0xC788  16c:        bh=al               \ MOV	BH,AL 
    0xC388  16c:        bl=al               \ MOV	BL,AL 
    0xE788  16c:        bh=ah               \ MOV	BH,AH 

    0x5E03  16c8#:      bx+[bp+#8]          \ ADD   BX,[BP+#8]
	0xD0D1  16c:        rcl.ax				\ RCL   AX,1

	0x4680  16c8#8#:    [bp+#8]+#8      	\ ADD	Byte Ptr [BP+11],22   
	0x4681  16c8#16#:   [bp+#8]+#16     	\ ADD	Word Ptr [BP+11],2222 
	0x6E80  16c8#8#:    [bp+#8]-#8      	\ SUB	Byte Ptr [BP+11],22   
	0x6E81  16c8#16#:   [bp+#8]-#16     	\ SUB	Word Ptr [BP+11],2222 

    0x0503  16c:        ax+[di] 			\ ADD   AX,[DI]
    0xEE81  16c16#:     si-#16              \ SUB   SI,1111

    0x5E39  16c8#:      [bp+#8]?bx          \ CMP   [BP+#8],BX
    0x5E3B  16c8#:      bx?[bp+#8]          \ CMP   BX,[BP+#8]

    0xDB19  16c:        bx-bx(carry)        \ SBB   BX,BX

    0xFBC1  16c8#:      sar#8.bx            \ SAR   BX,#8

	<selftest> --80286asm.f-self-test-- </selftest>
	js> tick('<selftest>').enabled [if] js> tick('<selftest>').buffer tib.insert [then] 
	js: tick('<selftest>').buffer="" \ recycle the memory


<comment> %~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~
%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~
%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~
%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~
debugging log

	> ' CTRLC: js> pop().cfa 10 dump
	00676: 822 (number)  <========= does> of AB L> CTRLC:
	00677: 283 (number)  <========= 283 == 0x11b so, CTRLC: is 0x11b 
	00678: 822 (number)

	-u 110
	0EB8:0110 BA00AB         MOV    DX,AB00 <=== !! [ ] should be 0x11B !!
	0EB8:0113 B425           MOV    AH,25
	0EB8:0115 CD21           INT    21
	0EB8:0117 FC             CLD
	0EB8:0118 E9E510         JMP    1200 <=== [ ] !! Wrong address !!
	0EB8:011B CF             IRET				<========= INT3 handler prepared by eforth.com. OK.
	0EB8:011C 0A00           OR     AL,[BX+SI]
	0EB8:011E 0000           ADD    [BX+SI],AL
	-

==> L> command is in trouble. Selftest 早就有提示了！我沒仔細看 :-( 奇怪怎麼誘出問題？以前好了的呀！

	00100   11 12 08 21 22 10 31 32 - ab 41 42 43 51 52 53 0c  
	00110   01 63 08 0c 01 73 10 0c - 01 83 ab 91 92 93 1b 01  
	00120   ?? ?? ?? ?? ?? ?? ?? ?? - ?? ?? ?? ?? ?? ?? ?? ??  ????????????????
	00130   ?? ?? ?? ?? ?? ?? ?? ?? - ?? ?? ?? ?? ?? ?? ?? ??  ????????????????
	00140   ?? ?? ?? ?? ?? ?? ?? ?? - ?? ?? ?? ?? ?? ?? ?? ??  ????????????????
	00150   ?? ?? ?? ?? ?? ?? ?? ?? - ?? ?? ?? ?? ?? ?? ?? ??  ????????????????
	00160   ?? ?? ?? ?? ?? ?? ?? ?? - ?? ?? ?? ?? ?? ?? ?? ??  ????????????????
	00170   ?? ?? ?? ?? ?? ?? ?? ?? - ?? ?? ?? ?? ?? ?? ?? ??  ????????????????
	00180   ?? ?? ?? ?? ?? ?? ?? ?? - ?? ?? ?? ?? ?? ?? ?? ??  ????????????????
	00190   ?? ?? ?? ?? ?? ?? ?? ?? - ?? ?? ?? ?? ?? ?? ?? ??  ????????????????
	001a0   ?? ?? ?? ?? ?? ?? ?? ?? - ?? ?? ?? ?? ?? ?? ?? ??  ????????????????
	001b0   ?? ?? ?? ?? ?? ?? ?? ?? - ?? ?? ?? ?? ?? ?? ?? ??  ????????????????
	001c0   ?? ?? ?? ?? ?? ?? ?? ?? - ?? ?? ?? ?? ?? ?? ?? ??  ????????????????
	001d0   ?? ?? ?? ?? ?? ?? ?? ?? - ?? ?? ?? ?? ?? ?? ?? ??  ????????????????
	001e0   ?? ?? ?? ?? ?? ?? ?? ?? - ?? ?? ?? ?? ?? ?? ?? ??  ????????????????
	001f0   ?? ?? ?? ?? ?? ?? ?? ?? - ?? ?? ?? ?? ?? ?? ?? ??  ????????????????

	在這裡設斷點，停下來檢查以上結果是否如下？ 'q' 繼續。
	00100   11 12 09 21 06 00 31 0c - 01 41 42 43 51 52 53 0c
	00110   01 63 08 0c 01 04 00 0c - 01 1b 01 91 92 93 1b 01
	00120   ?? ?? ?? ?? ?? ?? ?? ?? - ?? ?? ?? ?? ?? ?? ?? ??
	pass

[x]	In L> selftest, the 2nd L: LookForward is 0x11b, correct. 
[x] Backward fillings to LabelWord.storage[] are all to the correct place.
[ ] 8 L> 有時候對，有時錯。 16 L> 都錯。 AB L> 都錯。應該是 L: 回填時的問題。
	==> jeforth.3nd does not support jsc yet. Difficult to debug. Or should I try to 
		learn how to use Node.js debug feature?
		Now, I can use jeforth.3hta to debug the same thing anyway. Wow, feel so good!
	
[x] ~\jeforth.3hta\playground\86ef202.f compile 出來，跑不起來。要重視原因！
	==> 懷疑是用 writeTextFile 有問題，checksum 其實一樣。
		d:\hcchen\Dropbox\learnings\github\jeforth.3hta>d:\Download\BATCH\SUM.EXE eforth.com
		 This program was written by Eddy Chuang 1991.
		 -- The checksum of file:eforth.com is '20633D' on base 16 --
		d:\hcchen\Dropbox\LEARNI~1\github\JEFORT~1.3HT>

		target-space 0x100 DICSIZE array-slice
		<js> var sum=0; for( var i=0; i<12032; i++) {sum+=tos()[i]}; sum</jsV> 
		1:     2122557      20633dh (number)
	==> 接下來用 symdeb.exe 檢查了。。。 --> COLD1: entry should be 1097h ( "see COLD1:" command )
		but symdeb traced it's 1200h
	==> 看到原因了！本來 (create) 現在要改成 (create) reveal !!! hcchen5600 2014/10/13 18:54:01 

[x] The method 86ef202.f writes file to eforth.com needs think twice.
    Node.js and nw can use writeTextFile, but I guess not on HTA.
	==> The reason why 3nd can use it is Node.js' global class Buffer(). It handles binary data.
		So this project is 3nd and 3nw dependent!


%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~
%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~
%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~
%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~ </comment>
