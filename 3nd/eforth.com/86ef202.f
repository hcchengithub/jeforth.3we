
\ Big5

\ hcchen5600 2013/05/30 11:28:19
\ Dr. C.H. Ting's below source code is DTC. To use his works but translate to STC, I
\ refer to Yap's fsharp or weforth. Forth codes and names are placed seperatly. Codes start from 
\ the beginning of the dictionary; while names are at the end of the dictionary.
\ TOS(0) = BX, TOS(1) = [bp], TOS(2) = [bp+2], ... 
\ RTOS(0) = [SP] , RTOS(1) = [SP+2], ...
\ branch ?branch to absolute address ( weforth.asm uses relative address )
\ Built-in debug-build test programs.

\ TITLE 86eForth
\
\ PAGE 62,132 ;62 lines per page, 132 characters per line
\
\ ;===============================================================
\ ;       86eForth 2.02, C. H. Ting, 06/02/99
\ ;       Add create, checksum, UPLOAD and DOWNLOAD.
\ ;       A sample session looks like:
\ ;               c>86ef202
\ ;               DOWNLOAD LESSONS.TXT
\ ;               WORDS
\ ;               ' THEORY 'BOOT !
\ ;               UPLOAD TEST.EXE
\ ;               BYE
\ ;               c>test
\ ;
\ ;       86eForth 2.01, C. H. Ting, 05/24/99
\ ;       Merge Zen2.asm with eForth 1.12
\ ;1.     Eliminate most of the @EXECUTE thru user variables
\ ;2.     Combine name and code dictionary
\ ;3.     Eliminate code pointer fields
\ ;4.     elimiate catch-throw
\ ;5.     eliminate most user variables
\ ;6.     extend top memory to FFF0H where the stacks and user area are.
\ ;7.     add open, close, read, write; improve BYE
\ ;8      add 1+, 1-, 2/
\ ;
\ ;
\ ;       eForth 1.12, C. H. Ting, 03/30/99
\ ;               Change READ and LOAD to 'read' and 'load'.
\ ;               Make LOAD to read and compile a file.  The file
\ ;               buffer is from CP+1000 to NP-100.
\ ;               To load all the lessons, type:
\ ;                       LOAD LESSONS.TXT
\ ;               and you can test all the examples in this file.
\ ;       eForth 1.11, C. H. Ting, 03/25/99
\ ;               Change BYE to use function 4CH of INT 21H.
\ ;               Add read, write, open, close, READ, and LOAD
\ ;               To read a text file into memory:
\ ;                       HEX 2000 1000 READ TEST.TXT
\ ;               READ returns the number of byte actually read.
\ ;               To compile the source code in the text file:
\ ;                       2000 FCD LOAD
\ ;               where FCD is the length returned by READ.
\ ;               These additions allow code for other eForth systems
\ ;               to be tested on PC first.
\ ;               It is part of the Firmware Engineering Workshop.
\ ;
\ ;
\ ;   eForth 1.0 by Bill Muench and C. H. Ting, 1990
\ ;   Much of the code is derived from the following sources:
\ ;       8086 figForth by Thomas Newman, 1981 and Joe smith, 1983
\ ;       aFORTH by John Rible
\ ;       bFORTH by Bill Muench
\ ;
\ ;   The goal of this implementation is to provide a simple eForth Model
\ ;   which can be ported easily to many 8, 16, 24 and 32 bit CPU's.
\ ;   The following attributes make it suitable for CPU's of the '90:
\ ;
\ ;       small machine dependent kernel and portable high level code
\ ;       source code in the MASM format
\ ;       direct threaded code
\ ;       separated code and name dictionaries
\ ;       simple vectored terminal and file interface to host computer
\ ;       aligned with the proposed ANS Forth Standard
\ ;       easy upgrade path to optimize for specific CPU
\ ;
\ ;   You are invited to implement this Model on your favorite CPU and
\ ;   contribute it to the eForth Library for public use. You may use
\ ;   a portable implementation to advertise more sophisticated and
\ ;   optimized version for commercial purposes. However, you are
\ ;   expected to implement the Model faithfully. The eForth Working
\ ;   Group reserves the right to reject implementation which deviates
\ ;   significantly from this Model.
\ ;
\ ;   As the ANS Forth Standard is still evolving, this Model will
\ ;   change accordingly. Implementations must state clearly the
\ ;   version number of the Model being tracked.
\ ;
\ ;   Representing the eForth Working Group in the Silicon Valley FIG Chapter.
\ ;   Send contributions to:
\ ;
\ ;       Dr. C. H. Ting
\ ;       156 14th Avenue
\ ;       San Mateo, CA 94402
\ ;       (415) 571-7639
\ ;
\ ;===============================================================
\
\ ;; Version control

\ << 明確界定命名規則 >>
\
\       host 是 forth 而 target machine 也是 forth，同樣的 word name 會在三個地方
\       出現，以 c@ 為例子討論:
\
\       case.1, 
\       c@ 是 host 的 byte fetch 一如原始定義。
\
\       case.2, 
\       c@ (改名成 peek8) 這個 words 僅供 host 使用，從 host 伸手進 target space 取
\       值，參考的地址是 target 觀點。但是這類 words 也會同時參考到 target 及  host 
\       兩邊的觀點，再舉一例: cmove 是 host 原有的,   cmove(h>t) 則是從 host 搬東西
\       進 target; 反之則為  cmove(t>h)。 從這個例子看出這類 words 應該改名，所以對 
\       target 工作的 c@ 要拆成 peek8 或 c@(t>h) 以及 poke8 或 c!(h>t) 以避免混淆。 
\
\       case.3,
\       Target machine 裡的 forth 系統又有 c@。我的結論是任何 target 裡的 word name
\       都包成 {name}。因為 host 字典裡也會有這個 word， 若不用某種方式改頭換面，會
\       撞上。以 host 觀點看, {c@} 這個 word 是個 compiling word 用來把 {c,} compile
\       進 target space, 程式 source 裡 {c@} 以及 host 自己的 c@ 都有出現的機會，兩
\       者都是存在於 host dictionary 裡的 words ... 這些狀況下擠出這個結論。 
\
\       考慮用 {} 包起來之外其他方式，切 vocabulary 的方式也可以，但是可以想見到處都
\       在切 vocabulary 太煩，直接放棄。 或者 target words  用大寫字母，問題是 forth 
\       words 不一定是 alphabet。 Tiny Assembly 原創 國科會 張吉進先生針對這個問題是
\       把 host 的 name 調開 (see fence55a.f or the likes)。這跟用 { } 把所有 target 
\       words 包起來是同一套邏輯，好壞一時也看不清楚，做了再說。
\
\       如果 target machine 上有 console，所有的 word 都變成 {word} 用起來不是很麻煩
\       嗎？ 在 host 端 compile 完成，產生 target system 之後，來一動 touch up 在 
\       target space 裡把 {name} 改回 name 似乎可行(確定可行)。
\
\		在 host 端寫 target 程式真的經常會忘了加上 { } 因此頗能理解 張吉進先生要把原
\		forth word name 都調開。我覺得如果主要工作都是在寫 target 端程式，切 vocabulary
\       應可考慮。加 { } 的麻煩在 host 端也可以用 editor 的 macro 做一個 hotkey 來回
\		切換以紓緩麻煩。

\ VER             EQU     2                       ;major release version
\ EXT             EQU     2                       ;minor extension

	' 80286asm.f [if] [else] include 80286asm.f [then]
    
    2 constant VER // ( -- n ) major release version
    2 constant EXT // ( -- n ) minor extension
    false constant debug-build // ( -- boolean ) work with debug-build? [if] .... [then]

\ ;; Constants
\
\ TRUEE       EQU -1          ;true flag
\
\ COMPO       EQU 040H            ;lexicon compile only bit
\ IMEDD       EQU 080H            ;lexicon immediate bit
\ MASKK       EQU 0FF1FH          ;lexicon bit mask , low byte 1Fh is to mask the length

    -1      constant TRUEE // ( -- -1    ) true flag
    0x040   constant COMPO // ( -- 0x040 ) lexicon compile only bit
    0x080   constant IMEDD // ( -- 0x080 ) lexicon immediate bit
    0x07F1F constant MASKK // ( -- 0x07F1F ) lexicon bit mask

\ CELL        EQU 2           ;size of a cell
\ BASEE       EQU 10          ;default radix
\ VOCSS       EQU 8           ;depth of vocabulary stack
\
\ BKSPP       EQU 8           ;back space
\ LF          EQU 10          ;line feed
\ CRR         EQU 13          ;carriage return
\ ERR         EQU 27          ;error escape
\ TIC         EQU 39          ;tick

    2  constant CELL  // ( -- 2  ) size of a cell
    10 constant BASEE // ( -- 10 ) default radix
    8  constant VOCSS // ( -- 8  ) depth of vocabulary stack
    8  constant BKSPP // ( -- 8  ) back space
    10 constant LF    // ( -- 10 ) line feed
    13 constant CRR   // ( -- 13 ) carriage return
    27 constant ERR   // ( -- 27 ) error escape
    39 constant TIC   // ( -- 39 ) tick

\ CALLL       EQU 0E890H          ;NOP CALL opcodes

    0xE890 constant CALLL // ( -- 0E890H ) CALL opcodes, 90h NOP is dummy

\ ;; Memory allocation
\
\ EM              EQU 0FFF0H          ;top of memory
\ US              EQU 64*CELL         ;user area size in cells
\ RTS             EQU 128*CELL        ;return stack/TIB size

    0x0FFF0     constant EM       // ( -- 0FFF0H   FFF0h ) top of memory
    64 CELL  *  constant US       // ( -- 64*CELL    80h ) user area size in cells
    128 CELL  * constant RTS      // ( -- 128*CELL  100h ) return stack/TIB size
    0x3000      constant DICSIZE  // ( -- int16    3000h ) size of the dictionary, end of it is the name space

    create NP DICSIZE ,           // ( -- address ) Variable (Next available address+1) of target name space
    0xcc 0 poke8 0 NP @ 1- 1 cmove(t>t) \ clean the target space with cch int3 instruction


    : HERE target-here @ ;      // ( -- target-here )
    : CELLS 2 * ; // ( n -- n*CELL ) 1 CELLS = 2, 2 CELLS = 4, ... 
    : call, 0xe8 8, HERE CELL  + - 16, ;    // ( cfa -- ) Compile a 'call' instruction

\ UPP             EQU     TIBB-RTS     ;start of user area (UP0)
\ RPP             EQU     UPP-RTS      ;start of return stack (RP0)
\ TIBB            EQU     EM-RTS       ;terminal input buffer (TIB)
\ SPP             EQU     UPP-8*CELL   ;start of data stack (SP0)
\ COLDD           EQU     0            ;cold start vector

    EM RTS -        constant TIBB  // ( -- EM-RTS     FEF0h ) terminal input buffer (TIB)
    TIBB RTS -      constant UPP   // ( -- TIBB-RTS   FDF0h ) start of user area (UP0)
    UPP RTS -       constant RPP   // ( -- UPP-RTS    FCF0h ) start of return stack (RP0)
    UPP 8 CELL * -  constant SPP   // ( -- UPP-8*CELL FDE0h ) start of data stack (SP0)
    0x100           constant COLDD // ( -- 0            ) cold start vector

\ ;; Initialize assembly variables

    \ sp 要給 CPU 當 return stack, 用 bp 當 data stack pointer.
    \ 以下用 {} 包起來的 push pop 指的是 forth data stack 的 push pop, 相當於 assembly 的 macro.

    : {push.ax}   CELL bp-#8 0 [bp+#8]=ax ;
    : {push.bx}   CELL bp-#8 0 [bp+#8]=bx ;
    : {push.cx}   CELL bp-#8 0 [bp+#8]=cx ;
    : {push.dx}   CELL bp-#8 0 [bp+#8]=dx ;
    : {push.si}   CELL bp-#8 0 [bp+#8]=si ;
    : {push.di}   CELL bp-#8 0 [bp+#8]=di ;
    : {pop.ax}    0 ax=[bp+#8] CELL bp=lea[bp+#8] ; \ "bp=lea[bp+#8]" is similar to "bp+#8" but it doesn't change flags.
    : {pop.bx}    0 bx=[bp+#8] CELL bp=lea[bp+#8] ; \ This is a very importnt trick. Thanks to FigTaiwan gurus!!
    : {pop.cx}    0 cx=[bp+#8] CELL bp=lea[bp+#8] ;
    : {pop.dx}    0 dx=[bp+#8] CELL bp=lea[bp+#8] ;
    : {pop.si}    0 si=[bp+#8] CELL bp=lea[bp+#8] ;
    : {pop.di}    0 di=[bp+#8] CELL bp=lea[bp+#8] ;
    : {push.#16}  {push.bx} bx=#16 ;

\ _LINK   = 0                 ;force a null link
\ _USER   = 0                 ;first user variable offset

    create _LINK 0 , // ( -- addr ) word name list head
    create _USER 0 , // ( -- addr ) first user variable offset

\ ;; Define assembly macros
\
\ ;   Compile a code definition header.
\
\ $CODE   MACRO   LEX,NAME,LABEL
\               _LINK                    ;;token pointer and link
\     _LINK   = $             ;;link points to a name string
\     DB  LEX,NAME            ;;name string
\ LABEL:                      ;;assembly label
\     ENDM

    \ 這個 assembly macro $CODE 該怎麼在 jeforth 下實現？
    \ 先設想，將來用到 $CODE 時實況應該像這樣，
    \
    \   $CODE firstword
    \     nop   \ $90 c,
    \
    \   $CODE secondword
    \     nop   \ $90 c,
    \
    \   $CODE thirdword
    \     nop   \ $90 c,
    \
    \ 採 STC, code 與 name 分開放，以上 $CODE words 效果應該如下，
    \
    \    CFA      .-------> 0x90
    \    CFA      | .-----> 0x90
    \    CFA      | | .---> 0x90
    \             | | |     <------ there
    \             | | |
    \             | | |  dictionary free spaces
    \             | | |
    \    PCFA     | | `- (points to CFA of 'thirdword') 16,
    \    LFA      | |    (points to LFA of 'secondword') 16, ----.  
    \    NFA      | |    Length 8, "thirdword"  <----------------------------- _LINK points to
    \             | |                                            |             the last word's LFA
    \    PCFA     | `--- (points to CFA of 'secondword') 16,     |
    \    LFA      | .--- (points to LFA of 'firstword') 16,      |
    \    NFA      | |    Length 8, "secondword" <----------------'
    \             | |
    \    PCFA     `-|--- (points to CFA of 'firstword') 16,
    \    LFA        |    $0 16,   頭一個 LFA 接地 ---------------.
    \    NFA        `--> Length 8, "firstword"                   |
    \                                                            |
    \                                                            |
    \                                                           ---
    \
    \ 要達到這個效果的 $CODE spec 如下，
    \
    \ $CODE     ( -- )
    \           name list 是一坨坨倒著長上來的，順序上要先把自己的 name string 擺進 name space。
    \           然後 LFA 的位置就明確了。LFA 指到前一個 word 的 LFA 處，並調整 _LINK 的新值指到自己的
    \           LFA。實際動作是 LFA = _LINK, _LINK = (LAF 的地址)。然後把 PCFA 指到 target here。

                variable last$code // ( -- name ) The last $code word's name

                : $CODE     ( <name> -- ) \ Target word header, creates a target word

                    create
                    js> last().name binary-string>array        \ ( [name] )
                    js> tos().unshift(last().name.length) drop \ ( [length,name] )
                    NP @ js> tos(1).length -   \ ( [length,name] PNFA )
                    dup 4 - NP ! \ adjust NP to the (next available position + 1)  \ ( [length,name] PNFA )

                    \ LFA = _LINK,  _LINK 要改指向這個 NFA 了，趕快 copy 給這個 LFA
                    _LINK @ NP @ 2+ poke16			\ ( [length,name] PNFA )

                    \ _LINK = (LAF 的地址)
                    dup ( NP @ 2+ ) _LINK !			\ ( [length,name] PNFA )

                    cmove(h>t)						\ ( empty )

                    \ 然後把 PCFA 指到 target here。
                    HERE NP @ poke16

                    \ new word 本身是個動詞，動作是 compile 該 word 進 dictionary。
                    HERE ,    \ new word's value is its cfa

                    \ Print compile time messages
                    js> last() last$code !
                    last$code @ js> pop().name . ."  = " HERE .w cr

                    \ Run time routine,
                    does> r> @ call,
                ;
                ' $CODE alias $code  // ( <name> -- ) Target word header, alias of $CODE
                ' $CODE alias $colon // ( <name> -- ) Target word header, alias of $CODE
                ' $CODE alias $COLON // ( <name> -- ) Target word header, alias of $CODE

                : compile-only(t)   ( -- ) \ Mark the last target word 'compile only'.
                    _LINK @    ( addr )
                    dup peek8  ( addr len )
                    COMPO +    ( addr len' )
                    swap poke8 ;
                
                : immediate(t)   ( -- ) \ Mark the last target word 'immediate'.
                    _LINK @    ( addr )
                    dup peek8  ( addr len )
                    IMEDD +    ( addr len' )
                    swap poke8 ;

                : entryof  ( <{name}> -- entry ) \ Get next {word} or LABEL:'s entry 
                    ' ?dup if else ." Error! The name for 'entryof' not found." cr char Error> *debug* >>> then 
                    js> pop().cfa 1+ @ ;
                    /// The good thing is that it works on both CPU instruction {name} and label L: LABEL: !!
                
                : jump>    ( <{name}> -- ) \ compile a jmp.r16 that jumps to the next {word} or LABEL:
                    entryof s" jmp.r16" execute ;
                    /// The {word} or the LABEL: must have been defined.

                code text, ( "string" -- ) \ Compile sting into target dictionary ==> [len,"string"]
                    var ss=pop(); var count = ss.length;
                    push(count);
                    execute("8,");
                    for (var i=0; i<count; i++){
                        push(ss.charCodeAt(i));
                        execute("8,");
                    }
                    end-code
 
					: debug-build? ( -- boolean ) \ Start a testing section. Print last() and last$code word's name and the recent HERE address
						debug-build if
							." After " last$code @ js> pop().name . ."   " js> last().name . ."  -- Test entry : " 
							s" HERE" execute dup .w cr
							last$code @ js> pop().selftest=pop() drop
							true
						else
							false
						then
					; 
					/// Usage: debug-build? [if] ...test program... [then]


\ ;   Compile a colon definition header.
\
\ $COLON  MACRO   LEX,NAME,LABEL
\     $CODE   LEX,NAME,LABEL
\     CALL    DOLST               ;;include CALL doLIST
\     ENDM
\
\ ;   Compile a user variable header.
\
\ $USER   MACRO   LEX,NAME,LABEL
\     $CODE   LEX,NAME,LABEL
\     CALL    DOLST               ;;include CALL doLIST
\       DOUSE,_USER         ;;followed by doUSER and offset
\     _USER = _USER+CELL          ;;update user area offset
\     ENDM

                    : $USER   ( <name> -- ) \ Allocate an user variable
                        $CODE
                        s" {douser}       " execute
                        _USER @ 16,       \ followed by douser and offset
                        _USER @ CELL +    \ update user area offset
                        _USER !           
                    ;
                    ' $USER alias $user 

\ ;   Assemble inline direct threaded code ending.
\
\ $NEXT   MACRO
\     LODSW                   ;;read the next code address into AX
\     JMP AX              ;;jump directly to the code address
\     ENDM
\
\ ;; Main entry points and COLD start data
\
\ MAIN    SEGMENT
\     ASSUME  CS:MAIN,DS:MAIN,ES:MAIN,SS:MAIN
\
\ ORG COLDD                   ;beginning of cold boot area

                    0x100 org   \ MS-DOS .com executable entry point

\ ORIG:   MOV AX,CS
\         MOV DS,AX           ;all in one segment
\         CLI             ;disable interrupt for old 808x CPU bug
\         MOV SS,AX
\         MOV SP,SPP          ;initialize SP
\         STI
\         MOV BP,RPP          ;initialize RP
\         MOV AL,023H         ;^C interrupt Int23
\         MOV DX,OFFSET CTRLC
\         MOV AH,025H         ;set ^C address
\         INT 021H
\         CLD             ;SI gets incremented
\         JMP COLD
\ ;               MOV     SI,OFFSET COLD1
\ ;               $NEXT                           ;to high level cold start

    L: ORIG:        ax=cs
                    ds=ax                   \ all in one segment
                    cli                     \ disable interrupt for old 808x CPU bug
                    ss=ax
                    SPP bp=#16              \ initialize SP
                    sti
                    RPP sp=#16              \ initialize RP
                    0x23 al=#8              \ ^C interrupt Int23
                    0 dx=#16 AB L> CTRLC:   \ Get absolute address CTRLC:
                    0x25 ah=#8              \ set ^C address
                    0x21 int.#8
                    cld                     \ SI gets incremented

                    \ debug-build? [if]
                    \         0x2222 ax=#16 {push.ax}
                    \         0x3333 bx=#16 {push.bx}
                    \         0x4444 cx=#16 {push.cx}
                    \         0x5555 dx=#16 {push.dx}
                    \         0x6666 si=#16 {push.si}
                    \         0x7777 di=#16 {push.di}
                    \         {pop.ax}
                    \         {pop.bx}
                    \         {pop.cx}
                    \         {pop.dx}
                    \         {pop.si}
                    \         {pop.di}
                    \         0x1111 {push.#16} \ TOS bx was 0x3333 unknown, now is 0x1111
                    \         int3
                    \ [then] \ pass!!

                    0 jmp.r16 16 L> COLD1:  \ jmp to 16 bits relative destination, labeled 'COLD1:'.

\ CTRLC:      IRET                ;just return from ^C interrupt Int23

    L: CTRLC:       iret                    \ just return from ^C interrupt Int23


\ ; COLD start moves the following to USER variables.
\ ; MUST BE IN SAME ORDER AS USER VARIABLES.
\
\ UZERO:
\           BASEE           ;BASE
\           0           ;tmp
\           0           ;>IN
\           0           ;#TIB
\           TIBB            ;TIB
\           INTER           ;'EVAL
\           0           ;HLD
\           0           ;CONTEXT pointer
\           CTOP            ;CP
\                       LASTN                   ;LAST
\ ULAST:                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

    L: UZERO:
                    BASEE 16,                   \ FDF0 BASE
                    0     16,                   \ FDF2 tmp
                    0     16,                   \ FDF4 >IN
                    0     16,                   \ FDF6 #TIB
                    TIBB  16,                   \ FDF8 TIB
                    0     16, AB L> INTER:      \ FDFA 'EVAL
                    0     16,                   \ FDFC HLD
                    0     16,                   \ FDFE CONTEXT pointer
                    0     16, AB L> CTOP        \ FE00 CP
                    0     16, AB L> LASTN       \ FE02 LAST
    L: ULAST:       0 16, 0 16, 0 16, 0 16,
                    0 16, 0 16, 0 16, 0 16,
                    0 16, 0 16, 0 16, 0 16,
                    0 16, 0 16, 0 16, 0 16,

\ ;; Device dependent I/O
\ ;       All channeled to DOS 21H services
\
\ ;   BYE     ( -- )
\ ;       Exit eForth.
\
\         $CODE   3,'BYE',BYE
\                 MOV     AX,04C00H
\                 INT     021H                    ;MS-DOS terminate process

                    $CODE {bye}
                    0x4c00 ax=#16
                    0x21 int.#8                 \ MS-DOS terminate process

                    debug-build? [if]
                        {bye}
                    [then] \ pass!!


\ ;   ?RX     ( -- c T | F )
\ ;       Return input character and true, or a false if no input.
\
\                 $CODE   4,'?KEY',QKEY
\         XOR BX,BX           ;BX=0 setup for false flag
\         MOV DL,0FFH         ;input command
\         MOV AH,6            ;MS-DOS Direct Console I/O
\         INT 021H
\         JZ  QRX3            ;?key ready
\         OR  AL,AL           ;AL=0 if extended char
\         JNZ QRX1            ;?extended character code
\         INT 021H
\         MOV BH,AL           ;extended code in msb
\         JMP QRX2
\ QRX1:       MOV BL,AL
\ QRX2:       PUSH    BX          ;save character
\         MOV BX,TRUEE        ;true flag
\ QRX3:       PUSH    BX
\         $NEXT

                    $CODE {?key}
                    {push.bx}
                    bx=0                \ BX=0 setup for false flag
                    0xFF dl=#8          \ input command
                    6 ah=#8             \ MS-DOS Direct Console I/O
                    0x21 int.#8
                    jz.r8 8  L> QRX3:   \ ?key ready
                    al|al               \ AL=0 if extended char
                    jnz.r8 8 L> QRX1:   \ ?extended character code
                    0x21 int.#8
                    bh=al               \ extended code in msb
                    0 jmp.r8 8 L> QRX2:
    L:  QRX1:       bl=al
    L:  QRX2:       {push.bx}           \ save character
                    TRUEE bx=#16        \ true flag
    L:  QRX3:       return

                    debug-build? [if]
                        {?key}
                        int3
                    [then] \ pass

\ ;   TX!     ( c -- )
\ ;       Send character c to the output device.
\
\                 $CODE   4,'EMIT',EMIT
\         POP DX          ;char in DL
\         CMP DL,0FFH         ;0FFH is interpreted as input
\         JNZ TX1         ;do NOT allow input
\         MOV DL,32           ;change to blank
\ TX1:        MOV AH,6            ;MS-DOS Direct Console I/O
\         INT 021H            ;display character
\         $NEXT

                    $CODE   {emit}
                    dx=bx            \ char in DL
                    {pop.bx}         \ adjust TOS
                    0xff dl?#8       \ 0FFH is interpreted as input
                    jnz.r8 8 L> TX1: \ do NOT allow input
                    32 dl=#8         \ change to blank
    L: TX1:         6 ah=#8          \ MS-DOS Direct Console I/O
                    0x21 int.#8      \ display character
                    return

                    debug-build? [if]
                        13 {push.#16} {emit}
                        10 {push.#16} {emit}
                         1 {push.#16} {emit}
                         2 {push.#16} {emit}
                         3 {push.#16} {emit}
                         4 {push.#16} {emit}
                         5 {push.#16} {emit}
						32 {push.#16} {emit}    \ space works fine
                         1 {push.#16} {emit}
                         2 {push.#16} {emit}
                         3 {push.#16} {emit}
                         4 {push.#16} {emit}
                         5 {push.#16} {emit}
						BKSPP {push.#16} {emit}  \ backspace works fine
                         1 {push.#16} {emit}
                         2 {push.#16} {emit}
                         3 {push.#16} {emit}
                         4 {push.#16} {emit}
                         5 {push.#16} {emit}
                        int3
                    [then] \ pass!!


\ ;   open        ( fileAccess -- handle )
\ ;               Open file.  3D00 read-only, 3D01 write-only.
\
\                 $CODE   4,'open',OPENF
\                 POP     AX
\                 MOV     DX, OFFSET ULAST
\                 INT     021H
\                 JC      ERROR                   ;error return -1
\                 PUSH    AX
\                 $NEXT
\
\ ;   create      ( fileAccess -- handle )
\ ;               Create file.  0 read-write, 1 read-only.
\
\                 $CODE   6,'create',CREATF
\                 POP     CX
\                 MOV     DX, OFFSET ULAST
\                 MOV     AX,5B00H
\                 INT     021H
\                 JC      ERROR                   ;error return -1
\                 PUSH    AX
\                 $NEXT
\
\ ;   close       ( handle -- )
\ ;               Close file.
\
\                 $CODE   5,'close',CLOSE
\                 POP     BX
\                 MOV     AX,3E00H
\                 INT     021H
\                 $NEXT
\
\ ;   read        ( buffer len handle -- len-read )
\ ;               Read file into buffer.
\
\                 $CODE   4,'read',READF
\                 POP     BX
\                 POP     CX
\                 POP     DX
\                 MOV     AX, 3F00H
\                 INT     021H
\                 JC      ERROR
\                 PUSH    AX
\                 $NEXT
\ ERROR:          MOV     AX,-1
\                 PUSH    AX
\                 $NEXT

\ ;   write       ( buffer len handle -- len-writtn )
\ ;               Read file into buffer.
\
\                 $CODE   5,'write',WRITEF
\                 POP     BX
\                 POP     CX
\                 POP     DX
\                 MOV     AX, 4000H
\                 INT     021H
\                 JC      ERROR
\                 PUSH    AX
\                 $NEXT

\ ;; The kernel
\
\ ;   doLIT   ( -- w )
\ ;       Push an inline literal.
\
\                 $CODE   COMPO+5,'doLit',DOLIT
\                 LODSW
\                 PUSH    AX
\                 $NEXT

                    $CODE   {dolit} compile-only(t)
                    {push.bx}           \ make TOS (bx) ready to get literal value from dictionary
                    pop.si              \ the number is on return stack, get RTOS address
                    bx=[si]             \ get the literal number from dictionary to TOS (bx)
                    2 si+#8 push.si     \ return address of this function should be moved to the next word
                    return              \ return to the address prepared above

                    debug-build? [if]
                        13 {push.#16} {emit} 10 {push.#16} {emit}
                        {dolit} 1 16, {emit}  \ print a smiling face (ASCII 01h on MS-DOS console)
                        13 {push.#16} {emit} 10 {push.#16} {emit} 10 {push.#16} {emit}
                        int3 
                    [then] \ pass!!

\ ;   doLIST  ( a -- )
\ ;       Process colon list.
\
\                 $CODE   COMPO+6,'doList',DOLST
\         XCHG    BP,SP           ;exchange the return and data stack pointers
\         PUSH    SI          ;push on return stack
\         XCHG    BP,SP           ;restore the pointers
\         POP SI          ;new list address
\         $NEXT
\
\ ;   donext    ( -- )
\ ;       Run time code for the single index loop.
\ ;       : next ( -- ) \ hilevel model
\ ;         r> r> dup if 1 - >r @ >r exit then drop cell+ >r ;

                    $CODE   {donext} compile-only(t) \ DONXT 
                    pop.di                      \ [ -- ][ -- count ] di=ReturnAddress it contains the offset of the toLOOPP starting point
                    2 ax=lea[di+#8]             \ get the address after $NEXT to eax, for end of loop. relative addressing 14jun02sam
                  \ sub     dword ptr [esp] , 1 \ [ -- ][ -- count ] count-- symdeb.exe 打不出這個指令
                    pop.si 1 si-#16 push.si     \ count down
                    jb.r8 8 L> ^11              \ jb when 0 => -1
                  \ add     eax , [edi]         \ [edi] is the offest of loop start, eax is next instruction after the loop
                  \ ax+[di]                     \ 爽哥在 Win32 用相對地址，咱在 DOS 16bits 不適合。且絕對地址比較好讀。
                    jmp.[di]                    \ repeat the loop
    L: ^11          pop.cx                      \ [ -- ][ count -- ] drop the counter
                    jmp.ax                      \ continue from next entry by skipping a word


\ ;   ?branch ( f -- )
\ ;       Branch if flag is zero.
\
\                 $CODE   COMPO+7,'?branch',QBRAN
\                 POP BX          ;pop flag
\                 OR  BX,BX           ;?flag=0
\                 JZ  BRAN1           ;yes, so branch
\                 INC SI          ;point IP to next cell
\                 INC SI
\                 $NEXT
\ BRAN1:          MOV SI,0[SI]        ;IP:=(IP)
\                 $NEXT

                    $CODE   {?branch} compile-only(t)
                    bx|bx                 \ is TOS true?
                    {pop.bx}              \ adjust TOS
                    pop.di                \ get target pointer when TOS==NULL
                    CELL ax=lea[di+#8]    \ get target pointer when TOS!=NULL
                    0 jne.r8 8 L> BRAN1:
                    jmp.[di]              \ branch to absolute address
    L: BRAN1:       jmp.ax 

                    debug-build? [if]
                        13 {push.#16} {emit} 10 {push.#16} {emit}
                               0 {push.#16} {?branch} 0 16, AB L> ^11
                               ASCII 1 {push.#16} {emit}
                        L: ^11 
                               ASCII h {push.#16} {emit}
                               0 {push.#16} {?branch} 0 16, AB L> ^22
                               ASCII X {push.#16} {emit}
                        L: ^22 
                               ASCII e {push.#16} {emit}
                               0 {push.#16} {?branch} 0 16, AB L> ^33
                               ASCII X {push.#16} {emit}
                        L: ^33 
                               ASCII l {push.#16} {emit}
                               0 {push.#16} {?branch} 0 16, AB L> ^44
                               ASCII X {push.#16} {emit}
                        L: ^44 
                               ASCII l {push.#16} {emit}
                               1 {push.#16} {?branch} 0 16, AB L> ^55   
                               ASCII o {push.#16} {emit}
                               ASCII _ {push.#16} {emit}
                        L: ^55 
                               1 {push.#16} {?branch} 0 16, AB L> ^66
                               ASCII w {push.#16} {emit}
                        L: ^66 
                               ASCII o {push.#16} {emit}
                               1 {push.#16} {?branch} 0 16, AB L> ^77
                               ASCII r {push.#16} {emit}
                        L: ^77 
                               ASCII l {push.#16} {emit}
                               1 {push.#16} {?branch} 0 16, AB L> ^88
                               ASCII d {push.#16} {emit}
                        L: ^88 
                               ASCII ! {push.#16} {emit}
                        13 {push.#16} {emit} 10 {push.#16} {emit}
                        13 {push.#16} {emit} 10 {push.#16} {emit}
                               int3
                    [then] \ pass!!!

\ ;   branch  ( -- )
\ ;       Branch to an inline address.
\
\         $CODE   COMPO+6,'branch',BRAN
\         MOV SI,0[SI]        ;IP:=(IP)
\         $NEXT

                    $CODE {branch} compile-only(t)
                    pop.di        \ get ret addr's pointer
                    jmp.[di]      \ IP:=(IP)

                    debug-build? [if]
                                {branch} 0 16, AB L> ^11
                                ASCII W {push.#16} {emit}  ASCII r {push.#16} {emit}  ASCII o {push.#16} {emit}  ASCII n {push.#16} {emit}  ASCII g {push.#16} {emit}  ASCII ! {push.#16} {emit}
                        L: ^11 
                                {branch} 0 16, AB L> ^22
                                ASCII W {push.#16} {emit}  ASCII r {push.#16} {emit}  ASCII o {push.#16} {emit}  ASCII n {push.#16} {emit}  ASCII g {push.#16} {emit}  ASCII ! {push.#16} {emit}
                        L: ^22 
                                {branch} 0 16, AB L> ^33
                                ASCII W {push.#16} {emit}  ASCII r {push.#16} {emit}  ASCII o {push.#16} {emit}  ASCII n {push.#16} {emit}  ASCII g {push.#16} {emit}  ASCII ! {push.#16} {emit}
                        L: ^33 
                                {branch} 0 16, AB L> ^44
                                ASCII W {push.#16} {emit}  ASCII r {push.#16} {emit}  ASCII o {push.#16} {emit}  ASCII n {push.#16} {emit}  ASCII g {push.#16} {emit}  ASCII ! {push.#16} {emit}
                        L: ^44  
                                13 {push.#16} {emit} 10 {push.#16} {emit}
                                ASCII B {push.#16} {emit}
                                ASCII i {push.#16} {emit}
                                ASCII n {push.#16} {emit}
                                ASCII g {push.#16} {emit}
                                ASCII o {push.#16} {emit}
                                ASCII ! {push.#16} {emit}
                                13 {push.#16} {emit} 10 {push.#16} {emit}
                                13 {push.#16} {emit} 10 {push.#16} {emit}
                                int3
                    [then] \ pass!!!!


\ ;   EXECUTE ( ca -- )
\ ;       Execute the word at ca.
\
\         $CODE   7,'EXECUTE',{execute}
\         POP BX
\         JMP BX          ;jump to the code address

                    $code   {execute}
                    ax=bx
                    {pop.bx}
                    jmp.ax

                    debug-build? [if]
                        HERE constant test-entry
                        $code {test-execute}
                            13 {push.#16} {emit} 10 {push.#16} {emit}
                            ASCII H {push.#16} {emit}
                            ASCII E {push.#16} {emit}
                            ASCII L {push.#16} {emit}
                            ASCII L {push.#16} {emit}
                            ASCII O {push.#16} {emit}
                            13 {push.#16} {emit} 10 {push.#16} {emit}
                            return
                    [then]
                    debug-build? [if]
                        test-entry {push.#16} {execute}
                        int3
                    [then] \ pass !!!

\ ;   EXIT    ( -- )
\ ;       Terminate a colon definition.
\
\         $CODE   4,'EXIT',EXIT
\         MOV SI,[BP]         ;pop return address
\         INC BP          ;adjust RP
\         INC BP
\         $NEXT

                    ' return alias {exit}

\ ;   !       ( w a -- )
\ ;       Pop the data stack to memory.
\
\         $CODE   1,'!',{!}
\         POP BX
\         POP 0[BX]
\         $NEXT
                    $CODE   {!}
                    {pop.ax}
                    [bx]=ax
                    {pop.bx}
                    return

                    debug-build? [if]
                        0x2222 {push.#16}  \ data
                        0xfff2 {push.#16}  \ address
                        0x1111 {push.#16}  \ data
                        0xfff0 {push.#16}  \ address
                        {!} {!} \ then check ds:fff0 it's 0x1122, correct!
                        int3
                    [then] \ pass!!!


\ ;   @       ( a -- w )
\ ;       Push memory location to the data stack.
\
\         $CODE   1,'@',AT
\         POP BX
\         PUSH    0[BX]
\         $NEXT

                    $CODE   {@}
                    bx=[bx]
                    return

                    debug-build? [if]
                        0xfff0 {push.#16}
                        {@}
                        0xfff2 {push.#16}  \ address
                        {@}
                        int3 \ test (!) first then TOS=[1111,2222=BX]
                    [then] \ pass !!!


\ ;   C!      ( c addr -- )
\ ;       Pop the data stack to byte memory.
\
\         $CODE   2,'C!',CSTOR
\         POP BX
\         POP AX
\         MOV 0[BX],AL
\         $NEXT

                    $code   {c!}
                    {pop.ax}
                    [bx]=al
                    {pop.bx}
                    return

                    debug-build? [if]
                        0x0055 {push.#16}
                        0xfff0 {push.#16}
                        0x00AA {push.#16}
                        0xfff1 {push.#16}
                        {c!}
                        {c!}
                        int3 \ [FFF0]=55AA
                    [then] \ pass!!

\ ;   C@      ( addr -- c )
\ ;       Push byte memory location to the data stack.
\
\         $CODE   2,'C@',CAT
\         POP BX
\         XOR AX,AX           ;AX=0 zero the hi byte
\         MOV AL,0[BX]
\         PUSH    AX
\         $NEXT

                    $code   {c@}
                    ax=0
                    al=[bx]
                    bx=ax
                    return

                    debug-build? [if]
                        0xfff0 {push.#16}
                        {c@}
                        int3 \ [FFF0]=55 , BX=0055
                    [then] \ pass!!


\ ;   RP@     ( -- a )
\ ;       Push the current RP (return stack pointer) to the data stack.
\
\         $CODE   3,'rp@',RPAT
\         PUSH    BP
\         $NEXT

                    $code   {rp@}
                    pop.ax
                    {push.bx}
                    bx=sp
                    jmp.ax

                    debug-build? [if]
                        int3   \ check SP value , BX value , BP value
                        {rp@}  \ get SP to TOS
                        int3   \ check SP value(same) , BX value(was SP) , [BP]=[ ... SP]
                    [then] \ pass!!


\ ;   RP!     ( a -- )
\ ;       Set the return stack pointer.
\
\         $CODE   COMPO+3,'rp!',RPSTO
\         POP BP
\         $NEXT

                    $code   {rp!} compile-only(t)
                    pop.di      \ Get return address of this word
                    sp=bx       \ SP = TOS
                    {pop.bx}    \ adjust TOS
                    jmp.di

                    debug-build? [if]
                        0x55AA {push.#16}
                        0xEEEE {push.#16}
                        {rp!}  \ Set SP
                        {rp@}  \ get SP to TOS
                        int3   \ BX=EEEE SP=EEEE [BP]=[55AA, old BX] bingo!!
                    [then] \ pass!!!


\ ;   R>      ( -- w )
\ ;       Pop the return stack to the data stack.
\
\         $CODE   COMPO+2,'R>',RFROM
\         PUSH    0[BP]
\         INC BP          ;adjust RP
\         INC BP
\         $NEXT

                    $code   {r>} compile-only(t)
                    {push.bx}
                    pop.ax     \ 新奇！ 怎麼想得出來？ 這樣看來， r> 一定是 call rfrom 進來的。
                    pop.bx
                    jmp.ax


\ ;   R@      ( -- w )
\ ;       Copy top of return stack to the data stack.
\
\         $CODE   2,'R@',RAT
\         PUSH    0[BP]
\         $NEXT

                    $code   {r@}
                    {push.bx}
                    si=sp
                    CELL bx=[si+#8]
                    return

\ ;   >R      ( w -- )
\ ;       Push the data stack to the return stack.
\
\         $CODE   COMPO+2,'>R',TOR
\         DEC BP          ;adjust RP
\         DEC BP
\         POP 0[BP]           ;push
\         $NEXT

                    $code   {>r} compile-only(t)
                    pop.ax
                    push.bx
                    {pop.bx}
                    jmp.ax

                    debug-build? [if]
                        13 {push.#16} {emit} 10 {push.#16} {emit}
                        0x66BB  {push.#16} {>r}
                        ASCII O {push.#16}
                        ASCII k {push.#16}
                        ASCII ! {push.#16}
                        ASCII ? {push.#16}
                        {>r}
                        {>r}
                        {>r}
                        {>r}
                        {r>} {emit}
                        {r>} {emit}
                        {r>} {emit}
                        {r>} {emit}
                        {r@} \ BX=66BB , return stack 66BB too
                        13 {push.#16} {emit} 10 {push.#16} {emit}
                        int3
                    [then] \ pass!!!

\ ;   SP@     ( -- a )
\ ;       Push the current data stack pointer, which is BP
\
\         $CODE   3,'sp@',{sp@}
\         MOV BX,SP           ;use BX to index the data stack
\         PUSH    BX
\         $NEXT

                    $code   {sp@}
                    {push.bx}
                    bx=bp
                    return


\ ;   SP!     ( a -- )
\ ;       Set the data stack pointer. Actually move BX to BP
\
\         $CODE   3,'sp!',SPSTO
\         POP SP
\         $NEXT

                    $code   {sp!}
                    bp=bx
                    {pop.bx}
                    return

                    debug-build? [if]
                        0x55AA {push.#16}
                        0xEEEE {push.#16}
                        ax=bp  \ save old BP
                        {sp!}  \ Set BP
                        {sp@}  \ get BP to TOS
                        int3   \ BX=EEEE BP=EEEE [new BP=EEEE]=[ -- ????] old stack pointer [AX]=[ -- 55AA ]
                    [then] \ pass!!!

\ ;   DROP    ( w -- )
\ ;       Discard top stack item.
\
\         $CODE   4,'DROP',DROP
\         INC SP          ;adjust SP
\         INC SP
\         $NEXT

                    $code   {drop}
                    {pop.bx}
                    return


\ ;   DUP     ( w -- w w )
\ ;       Duplicate the top stack item.
\
\         $CODE   3,'DUP',DUPP
\         MOV BX,SP           ;use BX to index the data stack
\         PUSH    0[BX]
\         $NEXT

                    $code   {dup}
                    {push.bx}
                    return


\ ;   SWAP    ( w1 w2 -- w2 w1 )
\ ;       Exchange top two stack items.
\
\         $CODE   4,'SWAP',SWAP
\         POP BX
\         POP AX
\         PUSH    BX
\         PUSH    AX
\         $NEXT

                    $code   {swap}
                    0 ax=[bp+#8]
                    0 [bp+#8]=bx
                    bx=ax
                    return

\ ;   OVER    ( w1 w2 -- w1 w2 w1 )
\ ;       Copy second stack item to top.
\
\         $CODE   4,'OVER',OVER
\         MOV BX,SP           ;use BX to index the stack
\         PUSH    2[BX]
\         $NEXT

                    $code   {over}
                    {push.bx}
                    CELL bx=[bp+#8]
                    return

                    debug-build? [if]
                        0x1111 {push.#16}
                        0x2222 {push.#16}
                        0x3333 {push.#16}
                        0x4444 {push.#16}
                        {drop}
                        {swap}
                        {over}
                        {dup}
                        int3   \ [bp]=[ -- 1111 3333 2222 3333 ], bx=3333
                    [then] \ pass!

\ ;   0<      ( n -- t )
\ ;       Return true if n is negative.
\
\         $CODE   2,'0<',ZLESS
\         POP AX
\         CWD             ;sign extend
\         PUSH    DX
\         $NEXT

                    $code   {0<}
                    15 sar#8.bx  \ 我也蠻神的
                    return

\ ;   AND     ( w w -- w )
\ ;       Bitwise AND.
\
\         $CODE   3,'AND',ANDD
\         POP BX
\         POP AX
\         AND BX,AX
\         PUSH    BX
\         $NEXT

                    $code   {and}
                    0 bx&[bp+#8]
                    CELL bp=lea[bp+#8]
                    return


\ ;   OR      ( w w -- w )
\ ;       Bitwise inclusive OR.
\
\         $CODE   2,'OR',ORR
\         POP BX
\         POP AX
\         OR  BX,AX
\         PUSH    BX
\         $NEXT

                    $code   {or}
                    0 bx|[bp+#8]
                    CELL bp=lea[bp+#8]
                    return


\ ;   XOR     ( w w -- w )
\ ;       Bitwise exclusive OR.
\
\         $CODE   3,'XOR',XORR
\         POP BX
\         POP AX
\         XOR BX,AX
\         PUSH    BX
\         $NEXT

                    $code   {xor}
                    0 bx^[bp+#8]
                    CELL bp+#8
                    return

                    debug-build? [if]
                        0x1234 {push.#16}
                        0x5678 {push.#16}
                        0x8000 {push.#16}
                        0x2222 {push.#16}
                        0x8888 {push.#16}
                        0x4444 {push.#16}
                        {dup} int3 ( -- 1234 5678 8000 2222 8888 4444 4444 )
                        {xor} int3 ( -- 1234 5678 8000 2222 8888 0000 )
                        {or}  int3 ( -- 1234 5678 8000 2222 8888 )
                        {or}  int3 ( -- 1234 5678 8000 AAAA )
                        {0<}  int3 ( -- 1234 5678 8000 FFFF )
                        {xor} int3 ( -- 1234 5678 7FFF )
                        {0<}  int3 ( -- 1234 5678 0000 )
                    [then] \ pass !!


\ ;   UM+     ( u u -- low high )
\ ;       Add two unsigned single numbers and return a double sum.
\
\                 $CODE   3,'UM+',UPLUS
\         XOR CX,CX           ;CX=0 initial carry flag
\         POP BX
\         POP AX
\         ADD AX,BX
\         RCL CX,1            ;get carry
\         PUSH    AX          ;push sum
\         PUSH    CX          ;push carry
\         $NEXT

                    $code   {um+}
                    ax=0                      \ cx=0 initial carry flag
                    0 bx+[bp+#8]
                    rcl.ax                    \ get carry
                    0 [bp+#8]=bx              \ push sum
                    bx=ax
                    return

                    debug-build? [if]
                        0x1234 {push.#16}
                        0x5678 {push.#16}
                        0x9999 {push.#16}
                        0x8888 {push.#16}
                        {um+} ( -- 1234 5678 2221 0001 ) int3
                        {um+} ( -- 1234 5678 2222 0000 ) int3
                        {drop} ( -- 1234 5678 2222 )     int3
                        {um+}  ( -- 1234 789A 0000 )     int3
                        {drop} ( -- 1234 789A )          int3
                        {um+}  ( -- 8ACE 0000 )          int3
                    [then] \ pass !!

\ ;; System and user variables
\
\ ;   doVAR   ( -- a )
\ ;       Run time routine for VARIABLE and CREATE.
\
\         $COLON  COMPO+5,'doVar',DOVAR
\           RFROM,EXIT

                    $code  {dovar} compile-only(t)
                    {push.bx}
                    pop.bx
                    return

\ ;   UP      ( -- a )
\ ;       Pointer to the user area.
\
\         $COLON  2,'up',UP
\           DOVAR
\           UPP

                    $code  {up}
                    {dovar}
                    UPP 16,

                    debug-build? [if]
                        {up}
                        int3  \ BX @ = UPP
                    [then] \ pass !!

\ ;   doUSER  ( -- a )
\ ;       Run time routine for user variables.
\
\         $COLON  COMPO+6,'doUser',DOUSE
\           RFROM,AT,UP,AT,PLUS,EXIT

                    $code  {douser} compile-only(t)
    L: douser       {r>} {@} {up} {@}
                    0 jmp.r16 16 L> PLUS:

\ ;   BASE    ( -- a )
\ ;       Storage of the radix base for numeric I/O.

                    $user   {base} \ base

                    debug-build? [if]
                        {base} 
                        int3
                    [then]

\ ;   tmp     ( -- a )
\ ;       A temporary storage location used in parse and find.

                    $USER   {tmp} compile-only(t) \ TEMP

\ ;   >IN     ( -- a )
\ ;       Hold the character pointer while parsing input stream.

                    $USER   {>in} \ INN

\ ;   #TIB    ( -- a )
\ ;       Hold the current count in and address of the terminal input buffer.

                    $USER   {#tib} \ NTIB
                    _USER @ CELL + _USER !   \ hold the base address of the terminal input buffer

                    debug-build? [if]
                        0x1122 {push.#16}  \ make a mark on TOS so I am sure where it is.
                        {#tib} \ get #tib, #tib @ is the count
                        {dup} {@} \ BX=#tib.value , ( -- #TIB.address )
                        int3  \ BX=#tib.value=0000 , ( -- #TIB.address=FDF6 )
                    [then] \ Pass!!

\ ;   'EVAL   ( -- a )
\ ;       Execution vector of EVAL.

                    $USER   {'eval} \ TEVAL

\ ;   HLD     ( -- a )
\ ;       Hold a pointer in building a numeric output string.

                    $USER   {hld}  \ HLD

\ ;   CONTEXT ( -- a )
\ ;       A area to specify vocabulary search order.
 
                    $USER   {context} \ CNTXT

\ ;   CP      ( -- a )
\ ;       Point to the top of the code dictionary.

                    $USER   {cp} \ CP

\ ;   LAST    ( -- a )
\ ;       Point to the last name in the name dictionary.

                    $USER   {last} \ LAST

\ ;; Common functions
\
\ ;   ?DUP    ( w -- w w | 0 )
\ ;       Dup tos if its is not zero.
\
\         $COLON  4,'?DUP',QDUP
\           DUPP
\           QBRAN,QDUP1
\           DUPP
\ QDUP1:    EXIT

                    $colon  {?dup}
                    {dup}
                    {?branch} 0 16, AB L> ^11
                    {dup}
    L: ^11          {exit}

                    debug-build? [if]
                        0x4444 {push.#16}
                        {?dup}
                        0x0000 {push.#16}
                        {?dup}
                        int3  \ BX = 0000, ( -- 4444 4444 )
                    [then] \ pass

\ ;   ROT     ( w1 w2 w3 -- w2 w3 w1 )
\ ;       Rot 3rd item to top.
\
\         $COLON  3,'ROT',ROT
\           TOR,SWAP,RFROM,SWAP,EXIT

                    $colon  {rot}
                    {>r} {swap} {r>} 
                    jump> {swap} 

                    debug-build? [if]
                        0xaaaa {push.#16}
                        0xbbbb {push.#16}
                        0xcccc {push.#16}
                        {rot}
                        int3  \ BX = aaaa, ( -- bbbb cccc )
                    [then] \ pass 

\ ;   2DROP   ( w w -- )
\ ;       Discard two items on stack.
\
\         $COLON  5,'2DROP',DDROP
\           DROP,DROP,EXIT

                    $colon  {2drop}
                    {drop}
                    jump> {drop} 

                    debug-build? [if]
                        0x9999 {push.#16}
                        0xaaaa {push.#16}
                        0xbbbb {push.#16}
                        0xcccc {push.#16}
                        {2drop}
                        int3  \ BX = aaaa, ( -- 9999 )
                    [then] \ pass

\ ;   2DUP    ( w1 w2 -- w1 w2 w1 w2 )
\ ;       Duplicate top two items.
\
\         $COLON  4,'2DUP',DDUP
\           OVER,OVER,EXIT

                    $code {2dup}
                    {over}
                    jump> {over} 

                    debug-build? [if]
                        0x9999 {push.#16}
                        0xaaaa {push.#16}
                        {2dup}
                        int3  \ BX = aaaa, ( -- 9999 aaaa 9999 )
                    [then] \ pass

\ ;   +       ( w w -- sum )
\ ;       Add top two items.
\
\         $COLON  1,'+',PLUS
\           {um+},DROP,EXIT

                    $code  {+}
    L: PLUS:        {um+}
                    jump> {drop} 

                    debug-build? [if]
                        0x4444 {push.#16}
                        0x2222 {push.#16}
                        0x3333 {push.#16}
                        {+}
                        int3  \ BX = 5555, ( -- 4444 )
                    [then] \ pass !!

\ ;   NOT     ( w -- w )
\ ;       One's complement of tos.
\
\         $COLON  3,'NOT',INVER
\           DOLIT,-1,XORR,EXIT

                    $colon  {not}
                    {dolit} -1 16, 
                    jump> {xor} 

\ ;   NEGATE  ( n -- -n )
\ ;       Two's complement of tos.
\
\         $COLON  6,'NEGATE',NEGAT
\                       INVER,ONEP,EXIT

                    $colon  {negate}
                    {not} 
                    0 jmp.r16 16 L> ONEP:

\ ;   DNEGATE ( d -- -d )
\ ;       Two's complement of top double.
\
\         $COLON  7,'DNEGATE',DNEGA
\           INVER,TOR,INVER
\           DOLIT,1,{um+}
\           RFROM,PLUS,EXIT

                    $colon  {dnegate}
                    {not} {>r} {not}
                    {dolit} 1 16, {um+}
                    {r>} 
                    jump> {+} 

\ ;   -       ( n1 n2 -- n1-n2 )
\ ;       Subtraction.
\
\         $COLON  1,'-',SUBB
\           NEGAT,PLUS,EXIT

                    $colon {-}
                    {negate}
                    jump> {+} 

\ ;   ABS     ( n -- n )
\ ;       Return the absolute value of n.
\
\         $COLON  3,'ABS',ABSS
\           DUPP,ZLESS
\           QBRAN,ABS1
\           NEGAT
\ ABS1:         EXIT

                    $colon  {abs}
                    {dup} {0<}
                    {?branch} 0 16, AB L> ^11
                    {negate}
    L: ^11          {exit}


\ ;   =       ( w w -- t )
\ ;       Return true if top two are equal.
\
\         $COLON  1,'=',EQUAL 
\           XORR
\           QBRAN,EQU1
\           DOLIT,0,EXIT
\ EQU1:         DOLIT,TRUEE,EXIT

                    $colon  {=}
                    {xor}
                    {?branch} 0 16, AB L> ^11
                    {dolit} 0 16, {exit}
    L: ^11          {dolit} TRUEE 16, {exit}


\ ;   U<      ( u u -- t )
\ ;       Unsigned compare of top two items.
\
\         $COLON  2,'U<',ULESS
\           DDUP,XORR,ZLESS
\           QBRAN,ULES1
\           SWAP,DROP,ZLESS,EXIT
\ ULES1:        SUBB,ZLESS,EXIT

                    $colon  {u<}
                    0 [bp+#8]?bx 
                    bx-bx(carry)
                    2 bp=lea[bp+#8]
                    return

                    debug-build? [if]
                        0x3333 {push.#16}
                        0x2222 {push.#16}
                        {u<} int3
                        0x4444 {push.#16}
                        0x5555 {push.#16}
                        {u<} int3
                        0x7777 {push.#16}
                        0x7777 {push.#16}
                        {u<} int3
                        -1 {push.#16}
                        -2 {push.#16}
                        {u<} int3
                        -2 {push.#16}
                        -1 {push.#16}
                        {u<} int3
                        -3 {push.#16}
                        -3 {push.#16}
                        {u<} int3
                    [then] \ pass!!


\ ;   <       ( n1 n2 -- t )
\ ;       Signed compare of top two items.
\
\         $COLON  1,'<',LESS
\           DDUP,XORR,ZLESS
\           QBRAN,LESS1
\           DROP,ZLESS,EXIT
\ LESS1:        SUBB,ZLESS,EXIT

                    $colon  {<}   \ 感覺太複雜了，有空改改看 [ ]
                    {2dup} {xor} {0<}
                    {?branch} 0 16, AB L> ^11
                    {drop} 
                    jump> {0<} 
    L: ^11          {-} 
                    jump> {0<} 


\ ;   MAX     ( n n -- n )
\ ;       Return the greater of two top stack items.
\
                    $colon  {max} \ max
                    {2dup} {<}
                    {?branch} 0 16, AB L> ^11
                    {swap}
    L: ^11          jump> {drop}

                    debug-build? [if]
                        0x3333 {push.#16}
                        0x2222 {push.#16}
                        {max} int3
                        0x4444 {push.#16}
                        0x5555 {push.#16}
                        {max} int3
                        0x7777 {push.#16}
                        0x7777 {push.#16}
                        {max} int3
                        -1 {push.#16}
                        -2 {push.#16}
                        {max} int3
                        -2 {push.#16}
                        -1 {push.#16}
                        {max} int3
                        -3 {push.#16}
                        -3 {push.#16}
                        {max} int3
                    [then] \ pass!!


\ ;   MIN     ( n n -- n )
\ ;       Return the smaller of top two stack items.
\
                    $colon  {min} \ min
                    {2dup} {swap} {<}
                    {?branch} 0 16, AB L> ^11
                    {swap}
    L: ^11          jump> {drop} 


\ ;   WITHIN  ( u ul uh -- t )
\ ;       Return true if u is within the range of ul and uh. ( ul <= u < uh )
\
                    $colon  {within} \ withi
                    {over} {-} {>r}
                    {-} {r>} 
                    jump> {u<} 

\ ;; Divide
\
\ ;   UM/MOD  ( udl udh un -- ur uq )
\ ;       Unsigned divide of a double by a single. Return mod and quotient.
 
                    $colon  {um/mod} \ ummod
                    {2dup} {u<}
                    {?branch} 0 16, AB L> UMM4:
                    {negate} {dolit} 15 16, {>r}
    L: UMM1:        {>r} {dup} {um+}
                    {>r} {>r} {dup} {um+}
                    {r>} {+} {dup}
                    {r>} {r@} {swap} {>r}
                    {um+} {r>} {or}
                    {?branch} 0 16, AB L> UMM2:
                    {>r} {drop} 
    L: UMM777:      0 call.r16 16 L> ONEP: \ {1+} 
                    {r>}
                    {branch} 0 16, AB L> UMM3:
    L: UMM2:        {drop}
    L: UMM3:        {r>}
                    {donext} UMM1: 16,
                    {drop} 
                    jump> {swap} 
    L: UMM4:        {drop} {2drop}
                    {dolit} -1 16, 
                    jump> {dup} 

\ ;   M/MOD   ( d n -- r q )
\ ;       Signed floored divide of double by single. Return mod and quotient.

                    $colon  {m/mod}
                    {dup} {0<} {dup} {>r}
                    {?branch} 0 16, AB L> MMOD1:
                    {negate} {>r} {dnegate} {r>}
    L: MMOD1:       {>r} {dup} {0<}
                    {?branch} 0 16, AB L> MMOD2:
                    {r@} {+}
    L: MMOD2:       {r>} {um/mod} {r>}
                    {?branch} 0 16, AB L> MMOD3:
                    {swap} {negate} {swap}
    L: MMOD3:       {exit}


\ ;   /MOD    ( n n -- r q )
\ ;       Signed divide. Return mod and quotient.

                    $COLON  {/mod}
                    {over} {0<} {swap} 
                    jump> {m/mod} 

\ ;   MOD     ( n n -- r )
\ ;       Signed divide. Return mod only.

                    $COLON  {mod}
                    {/mod} 
                    jump> {drop} 

\ ;   /       ( n n -- q )
\ ;       Signed divide. Return quotient only.

                    $COLON  {/} \ SLASH
                    {/mod} {swap} 
                    jump> {drop} 

\ ;; Multiply
\
\ ;   UM*     ( u u -- ud )
\ ;       Unsigned multiply. Return double product.

                    $COLON  {um*}
                    {dolit} 0 16, {swap} {dolit} 15 16, {>r}
    L: UMST1:       {dup} {um+} {>r} {>r}
                    {dup} {um+} {r>} {+} {r>}
                    {?branch} 0 16, AB L> UMST2:
                    {>r} {over} {um+} {r>} {+}
    L: UMST2:       {donext} UMST1: 16,
                    {rot} jump> {drop}

\ ;   *       ( n n -- n )
\ ;       Signed multiply. Return single product.

                    $COLON  {*}
                    {um*} jump> {drop}

\ ;   M*      ( n n -- d )
\ ;       Signed multiply. Return double product.

                    $COLON  {m*} \ MSTAR
                    {2dup} {xor} {0<} {>r}
                    {abs} {swap} {abs} {um*}
                    {r>}
                    {?branch} 0 16, AB L> MSTA1:
                    {dnegate}
    L: MSTA1:       {exit}

\ ;   */MOD   ( n1 n2 n3 -- r q )
\ ;       Multiply n1 and n2, then divide by n3. Return mod and quotient.

                    $COLON  {*/mod}
                    {>r} {m*} {r>} jump> {m/mod} \ {exit}

\ ;   */      ( n1 n2 n3 -- q )
\ ;       Multiply n1 by n2, then divide by n3. Return quotient only.

                    $COLON  {*/} \ STASL
                    {*/mod} {swap} jump> {drop} \ {exit}


\ ;; Miscellaneous
\
\ ;   CELL+   ( a -- a )
\ ;       Add cell size in byte to address.

                    $COLON  {cell+}
                    {dolit} CELL 16, jump> {+} \ {exit}

\ ;   CELL-   ( a -- a )
\ ;       Subtract cell size in byte from address.

                    $COLON  {cell-}
                    {dolit} 0 CELL - 16, jump> {+} \ {exit}

\ ;   CELLS   ( n -- n )
\ ;       Multiply tos by cell size in bytes.

                    $COLON  {cells}
                    {dolit} CELL 16, jump> {*} \ {exit}

\ ;   1+          ( a -- a )
\ ;       Add cell size in byte to address.

                    $colon  {1+}
    L: ONEP:        {dolit} 1 16, 
                    jump> {+} 


\ ;   1-          ( a -- a )
\ ;       Subtract cell size in byte from address.

                       $COLON  {1-}
                       {dolit} -1 16, jump> {+} \ {exit}


\ ;   2/          ( n -- n )
\ ;       Multiply tos by cell size in bytes.

                    $COLON  {2/}
                    {dolit} CELL 16, jump> {/} \ {exit}


\ ;   BL      ( -- 32 )
\ ;       Return 32, the blank character.

          $COLON  {BL}
          {dolit} 32 16, {exit}


\ ;   >CHAR       ( c -- c )
\ ;       Filter non-printing characters.

                    $COLON  {>char}
                    {dolit} 0x07F 16, {and} {dup}    \ mask msb
                    {dolit} 127 16, {BL} {within}    \ check for printable
                    {?branch} 0 16, AB L> TCHA1:
                    {drop} {dolit} ASCII _ 16,       \ replace non-printables
    L: TCHA1:       {exit}


\ ;   DEPTH   ( -- n )
\ ;       Return the depth of the data stack.

                    $COLON  {depth}
                    {sp@} {dolit} SPP 16, {swap} {-}
                    {dolit} CELL 16, jump> {/} \ {exit}

					debug-build? [if]
						{depth}
						int3
						0x1234 {push.#16}
						{depth}
						int3
					[then]  \ pass 

\ ;   PICK    ( ... +n -- ... w )
\ ;       Copy the nth stack item to tos.

                    $COLON  {pick}
                    {1+} {cells}
                    {sp@} {+} jump> {@} \ {exit}


\ ;; Memory access
\
\ ;   +!      ( n a -- )
\ ;       Add n to the contents at address a.

                    $COLON  {+!}
                    {swap} {over} {@} {+}
                    {swap} jump> {!} \ {exit}

\ ;   2!      ( d a -- )
\ ;       Store the double integer to address a.

                    $COLON  {2!}
                    {swap} {over} {!}
                    {cell+} jump> {!} \ {exit}


\ ;   2@      ( a -- d )
\ ;       Fetch double integer from address a.

                    $COLON  {2@}
                    {dup} {cell+} {@}
                    {swap} jump> {@} \ {exit}


\ ;   COUNT   ( b -- b +n )
\ ;       Return count byte of a string and add 1 to byte address.

                    $COLON  {count}
                    {dup} {1+}
                    {swap} jump> {c@} \ {exit}

                    debug-build? [if]
                        {dolit} 0 16, AB L> ^11 {count} int3
                        L: ^11 s" test" text,
                    [then] \ pass!! bx=4 [bp]="test" , Bingo!

\ ;   HERE    ( -- a )
\ ;       Return the top of the code dictionary.

                    $COLON  {here}
                    {cp} jump> {@} \ {exit}

\ ;   PAD     ( -- a )
\ ;       Return the address of the text buffer above the code dictionary.

                    $COLON  {pad}
                    {here} {dolit} 80 16, jump> {+} \ {exit}

\ ;   TIB     ( -- a )
\ ;       Return the address of the terminal input buffer.

                    $COLON  {tib}
                    {#tib} {cell+} jump> {@} \ {exit}

\ ;   @EXECUTE    ( a -- )
\ ;       Execute vector stored in address a.

                    $COLON  {@execute}
                    {@} {?dup}        \ address or zero
                    {?branch} 0 16, AB L> ^11
                    {execute}         \ xecute if non-zero
    L: ^11          {exit}            \ do nothing if zero

\ ;   CMOVE   ( b1 b2 u -- )
\ ;       Copy u bytes from b1 to b2.

                    $COLON  {cmove}
                    {>r}
                    {branch} 0 16, AB L> CMOV2:
    L: CMOV1:       {>r} {dup} {c@}
                    {r@} {c!}
                    {1+}
                    {r>} {1+}
    L: CMOV2:       {donext} CMOV1: 16,
                    jump> {2drop} \ {exit}

\ ;   FILL    ( b u c -- )
\ ;       Fill u bytes of character c to area beginning at b.

                    $COLON  {fill}
                    {swap} {>r} {swap}
                    {branch} 0 16, AB L> FILL2:
    L: FILL1:       {2dup} {c!} {1+}
    L: FILL2:       {donext} FILL1: 16,
                    jump> {2drop} \ {exit}

\ ;   ERASE       ( b u -- )
\ ;               Erase u bytes beginning at b.

                    $COLON  {erase}
                    {dolit} 0 16, jump> {fill}

\ ;   PACK$   ( b u a -- a )
\ ;       Build a counted string with u characters from b. Null fill.

                    $COLON  {pack$}
                    {dup} {>r}          \ strings only on cell boundary
                    {2dup} {c!} {1+}    \ save count
                    {swap} {cmove}      \ move string
                    {r>} {exit}   

\ ;; Numeric output, single precision
\
\ ;   DIGIT   ( u -- c )
\ ;       Convert digit u to a character.

                    $COLON  {digit}
                    {dolit} 9 16, {over} {<}
                    {dolit} 7 16, {and} {+}
                    {dolit} ASCII 0 16, jump> {+} \ {exit}


\ ;   EXTRACT ( n base -- n c )
\ ;       Extract the least significant digit from n.

                    $COLON  {extract}
                    {dolit} 0 16, {swap} {um/mod}
                    {swap} jump> {digit} \ {exit}

\ ;   <#      ( -- )
\ ;       Initiate the numeric output process.

                    $COLON  {<#}
                    {pad} {hld} jump> {!} \ {exit}

\ ;   HOLD    ( c -- )
\ ;       Insert a character into the numeric output string.

                    $COLON  {hold}
                    {hld} {@} {1-}
                    {dup} {hld} {!} jump> {c!} \ {exit}

\ ;   #       ( u -- u )
\ ;       Extract one digit from u and append the digit to output string.

                    $COLON  {#}
                    {base} {@} {extract} jump> {hold} \ {exit}

\ ;   #S      ( u -- 0 )
\ ;       Convert u until all digits are added to the output string.

                    $COLON  {#s}
    L: DIGS1:       {#} {dup}
                    {?branch} 0 16, AB L> DIGS2:
                    {branch} DIGS1: 16,
    L: DIGS2:       {exit}

\ ;   SIGN    ( n -- )
\ ;       Add a minus sign to the numeric output string.

                    $COLON  {sign}
                    {0<}
                    {?branch} 0 16, AB L> SIGN1:
                    {dolit} ASCII - 16, {hold}
    L: SIGN1:       {exit}

\ ;   #>      ( w -- b u )
\ ;       Prepare the output string to be TYPE'd.

                    $COLON  {#>}
                    {drop} {hld} {@}
                    {pad} {over} jump> {-} \ {exit}


\ ;   str     ( w -- b u )
\ ;       Convert a signed integer to a numeric string.

                    $COLON  {str}
                    {dup} {>r} {abs}
                    {<#} {#s} {r>}
                    {sign} jump> {#>} \ {exit}


\ ;   HEX     ( -- )
\ ;       Use radix 16 as base for numeric conversions.

                    $COLON  {hex}
                    {dolit} 16 16, {base} jump> {!} \ {exit}


\ ;   DECIMAL ( -- )
\ ;       Use radix 10 as base for numeric conversions.

                    $COLON  {decimal}
                    {dolit} 10 16, {base} jump> {!} \ {exit}


\ ;; Numeric input, single precision
\
\ ;   digit?  ( c base -- u t )
\ ;       Convert a character to its numeric value. A flag indicates success.

                    $COLON  {digit?}
                    {>r} {dolit} ASCII 0 16, {-}
                    {dolit} 9 16, {over} {<}
                    {?branch} 0 16, AB L> DGTQ1:
                    {dolit} 7 16, {-}
                    {dup} {dolit} 10 16, {<} {or}
    L: DGTQ1:       {dup} {r>} jump> {u<} \ {exit}


\ ;   NUMBER? ( a -- n T | a F )
\ ;       Convert a number string to integer. Push a flag on tos.

                    $COLON  {number?}
                    {base} {@} {>r} {dolit} 0 16, {over} {count}
                    {over} {c@} {dolit} ASCII $ 16, {=}
                    {?branch} 0 16, AB L> NUMQ1:
                    {hex} {swap} {1+}
                    {swap} {1-}
    L: NUMQ1:       {over} {c@} {dolit} ASCII - 16, {=} {>r}
                    {swap} {r@} {-} {swap} {r@} {+} {?dup}
                    {?branch} 0 16, AB L> NUMQ6:
                    {1-} {>r}
    L: NUMQ2:       {dup} {>r} {c@} {base} {@} {digit?}
                    {?branch} 0 16, AB L> NUMQ4:
                    {swap} {base} {@} {*} {+} {r>}
                    {1+}
                    {donext} NUMQ2: 16,
                    {r@} {swap} {drop}
                    {?branch} 0 16, AB L> NUMQ3:
                    {negate}
    L: NUMQ3:       {swap}
                    {branch} 0 16, AB L> NUMQ5:
    L: NUMQ4:       {r>} {r>} {2drop} {2drop} {dolit} 0 16,
    L: NUMQ5:       {dup}
    L: NUMQ6:       {r>} {2drop}
                    {r>} {base} jump> {!} \ {exit}


\ ;; Basic I/O
\
\ ;   KEY     ( -- c )
\ ;       Wait for and return an input character.

                    $COLON  {key}
    L: KEY1:        {?key}
                    {?branch} KEY1: 16,
                    {exit}

                    debug-build? [if]
                        {key}
                        int3
                    [then] \ pass

\ ;   NUF?    ( -- t )
\ ;       Return false if no input, else pause and if CR return true.

                    $COLON  {nuf?} \ NUFQ 
                    {?key} {dup} ( -- c T T| F F )
                    {?branch} 0 16, AB L> NUFQ1:
                    {2drop} {key} {dolit} CRR 16, {=}
    L: NUFQ1:       {exit}

					debug-build? [if]
	L: nuf?test			{dolit} 0 16, AB L> nuf?str
						{count} 0 call.r16 16 L> TYPE:
						{nuf?}
						{?branch} nuf?test 16,
						int3
	L: nuf?str			s"   la le" text,
					[then] \ pass

\ ;   SPACE   ( -- )
\ ;       Send the blank character to the output device.

                    $COLON  {space} \ SPACE
                    {BL} jump> {emit}


\ ;   SPACES  ( +n -- )
\ ;       Send n spaces to the output device.

                    $COLON  {spaces} \ SPACS
                    {dolit} 0 16, {max} {>r}
                    {branch} 0 16, AB L> CHAR2:
    L: CHAR1:       {space}
    L: CHAR2:       {donext} CHAR1: 16,
                    {exit}


\ ;   TYPE    ( addr n -- )
\ ;       Output n characters from addr.

                    $COLON  {type}
    L: TYPE:        {>r}
                    {branch} 0 16, AB L> TYPE2:
    L: TYPE1:       {dup} {c@} {emit}
                    {1+}
    L: TYPE2:       {donext} TYPE1: 16, 
                    jump> {drop} \ {exit}

                    debug-build? [if]
                        {dolit} 0 16, AB L> ^11 {count} {type} int3
                        L: ^11 s" Hello world!!" text,
                    [then] \ pass!

\ ;   CR      ( -- )
\ ;       Output a carriage return and a line feed.

                    $COLON  {cr}
                    {dolit} CRR 16, {emit}
                    {dolit} LF 16, jump> {emit} \ {exit}


\ ;   do$     ( -- a )
\ ;       Return the address of a compiled string.

                    $COLON  {do$} compile-only(t) \ DOSTR 
                    {r>} {r@} {r>} {count} {+} \ myreturn str ((str+1)+len) 
                    {>r} {swap} {>r} {exit}  \ str <tos, (str+len) myreturn <rtos

					debug-build? [if]
						$code {do$test}
							int3 {do$} int3 return
	L: do$test			int3
						{do$test} s" Hello world!" text,
						int3
						{count} 
						int3
						{type} 
						int3
						{cr}
						int3
					[then]  \ pass


\ ;   $"|     ( -- a )
\ ;       Run time routine compiled by $". Return address of a compiled string.

                    $COLON  {$"|} compile-only(t) \ STRQP
                    {do$} {exit}      \ force a call to do$


\ ;   ."|     ( -- )
\ ;       Run time routine of ." . Output a compiled string.

                    $COLON  {."|} compile-only(t) \ DOTQP
                    {do$} {count} jump> {type} \ {exit}


\ ;   .R      ( n +n -- )
\ ;       Display an integer in a field of n columns, right justified.

                    $COLON  {.r}   \ DOTR
                    {>r} {str} {r>} {over} {-}
                    {spaces} jump> {type} \ {exit}


\ ;   U.R     ( u +n -- )
\ ;       Display an unsigned integer in n column, right justified.

                    $COLON  {u.r} \ UDOTR
                    {>r} {<#} {#s} {#>}
                    {r>} {over} {-}
                    {spaces} jump> {type} \ {exit}


\ ;   U.      ( u -- )
\ ;       Display an unsigned integer in free format.

                    $COLON  {u.} \ UDOT
                    {<#} {#s} {#>}
                    {space} jump> {type} \ {exit}

					debug-build? [if]
						0x4321 {push.#16}
						{u.}
						int3
					[then]


\ ;   .       ( w -- )
\ ;       Display an integer in free format, preceeded by a space.

                    $COLON  {.}  \ DOT
                    {base} {@} {dolit} 10 16, {xor}     \ ? decimal
                    {?branch} 0 16, AB L> ^11
                    jump> {u.} \ {exit}                 \ no, display unsigned
    L: ^11          {str} {space} jump> {type} \ {exit} \ yes, display signed

					debug-build? [if]
						12345 {push.#16}
						{u.}
						int3
					[then]

\ ;   ?       ( a -- )
\ ;       Display the contents in a memory cell.

                    $COLON  {?}  \ QUEST
                    {@} jump> {.} \ {exit}


\ ;; Parsing

\ ;   doPARSE   ( b u c -- b u delta ; <string> )
\ ;       Scan string delimited by c. Return found string and its offset.

                    $COLON  {doparse}  \ PARS
                    {tmp} {!} {over} {>r} {dup}
                    {?branch} 0 16, AB L> PARS8:
                    {1-} {tmp} {@} {BL} {=}
                    {?branch} 0 16, AB L> PARS3:
                    {>r}
    L: PARS1:       {BL} {over} {c@}      \ skip leading blanks ONLY
                    {-} {0<} {not}
                    {?branch} 0 16, AB L> PARS2:
                    {1+}
                    {donext} PARS1: 16, 
                    {r>} {drop} {dolit} 0 16, jump> {dup} \ {exit}
    L: PARS2:       {r>}
    L: PARS3:       {over} {swap}
                    {>r}
    L: PARS4:       {tmp} {@} {over} {c@} {-}       \ scan for delimiter
                    {tmp} {@} {BL} {=}
                    {?branch} 0 16, AB L> PARS5:
                    {0<}
    L: PARS5:       {?branch} 0 16, AB L> PARS6:
                    {1+}
                    {donext} PARS4: 16,
                    {dup} {>r}
                    {branch} 0 16, AB L> PARS7:
    L: PARS6:       {r>} {drop} {dup}
                    {1+} {>r}
    L: PARS7:       {over} {-}
                    {r>} {r>} jump> {-} \ {exit}
    L: PARS8:       {over} {r>} jump> {-} \ {exit}



\ ;   PARSE   ( c -- b u ; <string> )
\ ;       Scan input stream and return counted string delimited by c.

                    $COLON  {parse} \ PARSE
                    {>r} {tib} {>in} {@} {+}     \ current input buffer pointer
                    {#tib} {@} {>in} {@} {-}     \ remaining count
                    {r>} {doparse} {>in} 
                    jump> {+!} \ {exit}

					debug-build? [if]
					[then] \ passed when debuging {token}

\ ;   .(      ( -- )
\ ;       Output following string up to next ) .

                    $COLON  {.(}  immediate(t) \ DOTPR
                    {dolit} ASCII ) 16, {parse} 
                    jump> {type} \ {exit}


\ ;   (       ( -- )
\ ;       Ignore following string up to next ) . A comment.

                    $COLON  {(}  immediate(t)  \ PAREN
                    {dolit} ASCII ) 16, {parse} 
                    jump> {2drop}  \ {exit}


\ ;   \       ( -- )
\ ;       Ignore following text till the end of line.

                    $COLON  {\}  immediate(t) \ BKSLA
                    {#tib} {@} {>in} 
                    jump> {!}   \ {exit}


\ ;   WORD    ( <TIB> -- addr )
\ ;       Parse a word from input stream and copy it to code dictionary.
\         where addr is a counted string, usually at here+2.

                    $COLON  {word}
                    {parse}
                    {here} {cell+}
                    jump> {pack$} \ {exit}

					debug-build? [if]
						0 jmp.r8 8 L> ^11
						L: SS s" Hello World!!" text,
						L: ^11 {dolit} SS 1+ 16, {dolit} 0xFEF0 16, {dolit} SS peek8 16, {cmove} \ ( from to length -- )
						L: {word}test int3 {word}
						int3
					[then]


\ ;   TOKEN   ( -- a ; <string> )
\ ;       Parse a word from input stream and copy it to name dictionary.

                    $COLON  {token}
                    {BL} jump> {word} \ {exit}

					debug-build? [if]
						0 call.r16 16 L> QUERY:
						int3
						{token}
						int3
					[then]


\ ;; Dictionary search
\
\ ;   NAME>   ( na -- ca )
\ ;       Return a code address given a name address.

                    $COLON  {name>}   \ NAMET
                    \ {count} {dolit} 31 16, {and}
                    \ jump> {+} \ {exit}
					{dolit} 2 CELLS 16, {-} jump> {@} \ my structure is [CFA][LFA][NFA]


\ ;   SAME?   ( a a u -- a a f \ -0+ )
\ ;       Compare u cells in two strings. Return 0 if identical.

                    $COLON  {same?}  \ SAMEQ
                    {1-} {>r}
                    {branch} 0 16, AB L> SAME2:
    L: SAME1:       {over} {r@} {+} {c@}
                    {over} {r@} {+} {c@}
                    {-} {?dup}
                    {?branch} 0 16, AB L> SAME2:
                    {r>} jump> {drop} \ {exit}
    L: SAME2:       {donext} SAME1: 16,
                    {dolit} 0 16, {exit}



\ ;   find    ( a va -- ca na | a F )
\ ;       Search a vocabulary for a string. Return ca and na if succeeded.

                    $COLON  {find} \ FIND
                    {swap} {dup} {c@}
                    {tmp} {!}
                    {dup} {@} {>r} {cell+} {swap}
    L: FIND1:       {@} {dup}
                    {?branch} 0 16, AB L> FIND6:
                    {dup} {@} {dolit} MASKK 16, {and} {r@} {xor}
                    {?branch} 0 16, AB L> FIND2:
                    {cell+} {dolit} -1 16,
                    {branch} 0 16, AB L> FIND3:
    L: FIND2:       {cell+} {tmp} {@} {same?}
    L: FIND3:       {branch} 0 16, AB L> FIND4:
    L: FIND6:       {r>} {drop}
                    {swap} {cell-} 
                    jump> {swap} \ {exit}
    L: FIND4:       {?branch} 0 16, AB L> FIND5:
                    {cell-} {cell-}
                    {branch} FIND1: 16, 
    L: FIND5:       {r>} {drop} {swap} {drop}
                    {cell-} 
                    {dup} {name>} 
                    jump> {swap} \ {exit}

					debug-build? [if]
						L: find22	{dolit} 0 16, AB L> find11
									int3
						L: find33	{context}				\ [FDFE] = 7805 _LINK
									int3
						L: find44	{find}
									int3
						L: find11	s" {dup}" text,			\ 13ec
					[then]

\ ;   NAME?   ( a -- ca na | a F )
\ ;       Search all context vocabularies for a string.

                    $COLON  {name?}    \ NAMEQ
                    {context} jump> {find} \ {exit}

					debug-build? [if]
	L: TT11			{dolit} 0 16, AB L> SS11 
					int3
	L: PP01			{context} \ return FDFE, the pointer, correct. [FDFE] = 7803h which is the _LINK head
					int3
					{find}
					int3
	L: SS11			s" 112233" text,

					[then]

\ ;; Terminal response

\ ;   ^H      ( bot eot cur -- bot eot cur )
\ ;       Backup the cursor by one character.

                    $COLON  {^h}  \ BKSP
                    {>r} {over} {r>} {swap} {over} {xor}    \ bot eot cur bot?cur 
                    {?branch} 0 16, AB L> BACK1:			\ bot eot cur , is at the head
                    {dolit} BKSPP 16, {emit} {1-}			\ bot eot cur-1
                    {BL} {emit}
                    {dolit} BKSPP 16, {emit}
    L: BACK1:       {exit}
    

\ ;   TAP     ( bot eot cur c -- bot eot cur )
\ ;       Accept and echo the key stroke and bump the cursor.

                    $COLON  {tap} \ TAP
                    {dup} {emit}
                    {over} {c!} jump> {1+} {exit}

                    debug-build? [if]
                        0x1234 {push.#16} \ bot don't know what's that
                        0x5678 {push.#16} \ eot don't know what's that
                        0x9000 {push.#16} \ string buffer address
                        {key} {tap} int3
                    [then] \ pass!


\ ;   KTAP    ( bot eot cur c -- bot eot cur )
\ ;       Process a key stroke, {cr} or backspace.

                    $COLON   {ktap}  \ KTAP
                    {dup} {dolit} CRR 16, {xor}   		\ bot eot cur c c?cr 
                    {?branch} 0 16, AB L> KTAP2:		\ bot eot cur c , yes it's CR, which has no problem
                    {dolit} BKSPP 16, {xor}				\ bot eot cur c?backspace	
                    {?branch} 0 16, AB L> KTAP1:		\ bot eot cur , yes bug in KTAP1
                    {BL} jump> {tap} \ {exit}
    L: KTAP1:       jump> {^h} \ {exit}
    L: KTAP2:       {drop} {swap} {drop} jump> {dup} \ {exit}


\ ;   accept  ( b u -- b u )
\ ;       Accept characters to input buffer. Return with actual count.
 
                    $COLON  {accept}  \ ACCEP
                    {over} {+} {over}
    L: ACCP1:       {2dup} {xor}
                    {?branch} 0 16, AB L> ACCP4:
                    {key} {dup}
                  \ {BL} {-} {dolit},95,{u<}
                    {BL} {dolit} 127 16, {within}
                    {?branch} 0 16, AB L> ACCP2:
                    {tap}
                    {branch} 0 16, AB L> ACCP3:
    L: ACCP2:       
					{ktap}
    L: ACCP3:       {branch} ACCP1: 16,
    L: ACCP4:       {drop} {over} jump> {-} \ {exit}

                    debug-build? [if]
                        {dolit} 0 16, AB L> ^11 {count} {accept} int3
                        L: ^11 s" string buffer" text,
                    [then] \ pass!


\ ;   QUERY   ( -- )
\ ;       Accept input stream to terminal input buffer.

                    $COLON  {query}   \ QUERY
    L: QUERY:       {tib} {dolit} 80 16, {accept} {#tib} {!}
                    {drop} {dolit} 0 16, {>in} 
                    jump> {!} \ {exit}

                    debug-build? [if]
                        {query}
                        int3 \ type string and enter. The string goes to TIB, FEF0, 'abcde' correct. #TIB is at FDF6, it's 5, correct too.
                    [then] \ pass!


\ ;   ABORT   ( -- )
\ ;       Reset data stack and jump to QUIT.

                    $COLON  {abort} \ ABORT
                    0 call.r16 16 L> PRESET: \ call future entry
                    0 jmp.r16 16 L> QUIT1:   \ jump future entry


\ ;   abort"  ( f -- )
\ ;       Run time routine of abort" . Abort with a message.

                    $COLON  {abort"} compile-only(t) \ ABORQ
                    {?branch} 0 16, AB L> ABOR2:     \ text flag
                    {do$}
    L: ABOR1:   \ Many other words jump to this label too
                    {space} {count} {type}
                    {dolit} ASCII ? 16, {emit} 
                    {cr} {abort}                     
    L: ABOR2:       {do$}                            \ pass error string
                    {drop} {exit}            \ drop error


\ ;; The text interpreter
\
\ ;   $INTERPRET  ( a -- )
\ ;       Interpret a word. If failed, try to convert it to an integer.
 
                    $COLON  {$interpret}    \ INTER
    L: INTER:       {name?} \ ( a -- ca na | a F )
					{?dup}      \ ?defined      ca na na
                    {?branch} 0 16, AB L> ^11  \ ca na
                    {@} {dolit} COMPO 16, {and}   \ ?compile only lexicon bits     ca na[1:0]&COMPO 
                    {abort"} s"  compile only" text,
                    jump> {execute} \ {exit}      \ execute defined word
    L: ^11          {number?}            \ convert a number
                    {?branch} ABOR1: 16,
                    {exit}


\ ;   [       ( -- )
\ ;       Start the text interpreter.

                    $COLON  {[} immediate(t)  \ LBRAC
                    {dolit} entryof {$interpret} 16, {'eval} 
                    jump> {!} \ {exit}


\ ;   .OK     ( -- )
\ ;       Display 'ok' only while interpreting.

                    $COLON  {.ok}  \ DOTOK
                    {dolit} entryof {$interpret} 16, {'eval} {@} {=}
                    {?branch} 0 16, AB L> DOTO1:
                    {."|} s"  ok" text,  \ 3 8, 32 8, ASCII o 8, ASCII k 8,
    L: DOTO1:       jump> {cr} \ {exit}


\ ;   ?STACK  ( -- )
\ ;       Abort if the data stack underflows.

                    $COLON  {?stack}   \ QSTAC
                    {depth} {0<}     \ check only for underflow
                    {abort"} s"  underflow" text,
					\ 10 8, 32 8, ASCII u 8, ASCII n 8, ASCII d 8, ASCII e 8,
					\ ASCII r 8, ASCII f 8, ASCII l 8, ASCII o 8, ASCII w 8,
                    {exit}


\ ;   EVAL    ( -- )
\ ;       Interpret the input stream.
    
                    $COLON  {eval} \ EVAL
    L: EVAL1:       {token} {dup} {c@}              \ ?input stream empty
                    {?branch} 0 16, AB L> EVAL2:
                    {'eval} {@execute} {?stack}     \ evaluate input, check stack
                    {branch} EVAL1: 16,
    L: EVAL2:       {drop} jump> {.ok} \ {exit}   \ prompt


\ ;   PRESET  ( -- )
\ ;       Reset data stack pointer and the terminal input buffer.

                    $COLON  {preset}  \ PRESE
    L: PRESET:      {dolit} SPP 16, {sp!}
                    {dolit} TIBB 16, 
                    {#tib}            \ get #tib variable's address
                    {cell+}           \ Now it's the TIB variable's address
                    jump> {!} \ {exit} \ store constant TIBB to TIB.

                    debug-build? [if]
                        0x2233 {push.#16} \ mark the recent TOS
						int3 \ pass
                        {#tib} \ get the #tib.address so we know the next address is TIB.pointer
						int3 \ FDF6 FDF8
                        {preset} \ stack pointer BP will be reset to FDE0, TIB.pointer(FDF8) to FEF0 initial value
						int3
                    [then]

\ ;   QUIT    ( -- )
\ ;       Reset return stack pointer and start text interpreter.

                    $COLON  {quit}   \ QUIT
    L: QUIT1:       {dolit} RPP 16, {rp!}   \ reset return stack pointer
                    {[}                     \ start interpretation
    L: QUIT2:       {query}                 \ get input
                    {eval}
                    {branch} QUIT2: 16,     \ continue till error


\ ;; The compiler

\ ;   '       ( -- ca )
\ ;       Search context vocabularies for the next word in input stream.

                    $COLON  {'}   \ TICK
                    {token} {name?}         \ ?defined
                    {?branch} ABOR1: 16,
                    {exit}                  \ yes, push code address


\ ;   ALLOT   ( n -- )
\ ;       Allocate n bytes to the code dictionary.

                    $COLON  {allot}   \ ALLOT
                    {cp} jump> {+!} \ {exit}       \ adjust code pointer


\ ;   ,       ( w -- )
\ ;       Compile an integer into the code dictionary.

                    $COLON  {,}   \ COMMA
                    {here} {dup} {cell+}     \ cell boundary
                    {cp} {!} jump> {!} \ {exit}     \ adjust code pointer and compile


\ ;   [COMPILE]   ( -- ; <string> )
\ ;       Compile the next immediate word into code dictionary.

                    $COLON  {[compile]} immediate(t)  \ BCOMP
                    {'} jump> {,} \ {exit}

\ ;   call,   ( ca -- )
\ ;       Assemble a call instruction to ca.

                    $COLON  {call,} \ CALLC
                    {dolit} CALLL 16, {,} {here} 
                    {cell+} {-} jump> {,} \ {exit}


\ ;   COMPILE ( -- )
\ ;       Compile the next address in colon list to code dictionary.

                    $COLON  {compile}  compile-only(t) \ COMPI
                    \ {r>} {dup} {@} {,}      \ compile address
                    \ {cell+}     \ adjust return address
                    \ {>r} {exit}
					{r>}		\ (next word's instruction address)
					{1+}		\ (next word's entry address)
					{dup}		\ entry (entry)
					{@}			\ entry (entry relative address)
					{swap}		\ (entry relative address) entry 
					{cell+}		\ (entry relative address) entry+2  \ next instruction address
					{dup}		\ (entry relative address) entry+2 entry+2
					{>r}		\ (entry relative address) entry+2 , entry+2 <rtos  ;adjust return address
					{+}			\ (entry address) <tos , entry+2 <rtos
					{call,}
					{exit}
					


\ ;   LITERAL ( w -- )
\ ;       Compile tos to code dictionary as an integer literal.

                    $COLON  {literal}  immediate(t) \ LITER
                    {compile} {dolit} 
                    jump> {,} \ {exit}


\ ;   $,"     ( -- )
\ ;       Compile a literal string up to next " .

                    $COLON  {$,"}   \ STRCQ
                    {dolit} ASCII " 16, {parse} {here} {pack$}   \ string to code dictionary
                    {count} {+}        \ calculate aligned end of string
                    {cp} {!} {exit}    \ adjust the code pointer


\ ;; Structures

\ ;   FOR     ( -- a )
\ ;       Start a FOR-NEXT loop structure in a colon definition.

                    $COLON  {for} immediate(t)  \ FOR
                    {compile} {>r} 
                    jump> {here} \ {exit}


\ ;   BEGIN   ( -- a )
\ ;       Start an infinite or indefinite loop structure.

                    $COLON  {begin} immediate(t) \ BEGIN
                    jump> {here} \ {exit}


\ ;   NEXT    ( a -- )
\ ;       Terminate a {for}-NEXT loop structure.
 
                    $COLON  {next} immediate(t)  \ NEXT
                    {compile} {donext} jump> {,} \ {exit}


\ ;   UNTIL   ( a -- )
\ ;       Terminate a {begin}-UNTIL indefinite loop structure.
 
                    $COLON  {until} immediate(t) \ UNTIL
                    {compile} {?branch} jump> {,} \ {exit}


\ ;   AGAIN   ( a -- )
\ ;       Terminate a {begin}-AGAIN infinite loop structure.

                    $COLON  {again} immediate(t)  \ AGAIN
                    {compile} {branch} jump> {,} \ {exit}


\ ;   IF      ( -- A )
\ ;       Begin a conditional branch structure.

                    $COLON  {if} immediate(t) \ IFF
                    {compile} {?branch} {here}
                    {dolit} 0 16, jump> {,} \ {exit}


\ ;   AHEAD   ( -- A )
\ ;       Compile a forward branch instruction.

                    $COLON  {ahead} immediate(t)  \ AHEAD
                    {compile} {branch} {here} {dolit} 0 16, jump> {,} \ {exit}


\ ;   REPEAT  ( A a -- )
\ ;       Terminate a {begin}-WHILE-REPEAT indefinite loop.

                    $COLON  {repeat} immediate(t)  \ REPEA
                    {again} {here} {swap} jump> {!} \ {exit}


\ ;   THEN    ( A -- )
\ ;       Terminate a conditional branch structure.

                    $COLON  {then} immediate(t)  \ THENN
                    {here} {swap} jump> {!} \ {exit}

\ ;   AFT     ( a -- a A )
\ ;       Jump to THEN in a {for}-AFT-THEN-{next} loop the first time through.

                    $COLON  {aft} immediate(t)  \ AFT
                    {drop} {ahead} {begin} jump> {swap} \ {exit}


\ ;   ELSE    ( A -- A )
\ ;       Start the false clause in an IF-ELSE-THEN structure.

                    $COLON  {else} immediate(t) \ ELSEE
                    {ahead} {swap} jump> {then} \ {exit}


\ ;   WHILE   ( a -- A a )
\ ;       Conditional branch out of a {begin}-WHILE-REPEAT loop.

                    $COLON  {while} immediate(t) \ WHILE
                    {if} jump> {swap} \ {exit}


\ ;   ABORT"  ( -- ; <string> )
\ ;       Conditional abort with an error message.

                    $COLON  {ABORT"} immediate(t) \ ABRTQ
                    {compile} {abort"} jump> {$,"} \ {exit}


\ ;   $"      ( -- ; <string> )
\ ;       Compile an inline string literal.

                    $COLON  {$"} immediate(t) \ STRQ
                    {compile} {$"|} jump> {$,"} \ {exit}


\ ;   ."      ( -- ; <string> )
\ ;       Compile an inline string literal to be typed out at run time.

                    $COLON  {."} immediate(t)  \ DOTQ
                    {compile} {."|} jump> {$,"} \ {exit}


\ ;; Name compiler

\ ;   ?UNIQUE ( a -- a )
\ ;       Display a warning message if the word already exists.

                    $COLON  {?unique}  \ UNIQU
                    {dup} {name?}               \ ?name exists
                    {?branch} 0 16, AB L> UNIQ1: 
                    {."|} s"  reDef " text,		\ redefinitions are OK but the user should be warned
                    {over} {count} {type}       \ just in case its not planned
    L: UNIQ1:       jump> {drop} \ {exit}

					debug-build? [if]
						int3
						{dolit} 0 16, AB L> uniq-test-str
						int3
						{?unique}
						int3
	L: uniq-test-str    s" {swap}" text,
					[then]  \ pass!


\ ;   $,n     ( na -- )
\ ;       Build a new dictionary name using the string at na.
\         本 project 使 code 與 name 分離，原設計要改。
    
                    $COLON  {$,n} \ SNAME
                    {dup} {c@}                  \ ?null input
\ int3
                    {?branch} 0 16, AB L> PNAM1:
\ int3
                    {?unique}                   \ ?redefinition   ( -- na )
                    \ {dup} {count} {+}  	\ na (na+len)
                    \ {cp} {!}           	\ na     HERE adjusted already
\ int3
					{dup} {count}	{1+} {swap} {drop}		\ na len
\ int3
					{last} {@} {dolit} 2 16, {cells} {-} 	\ na len target
\ int3
					{over} {-}				\ na len (target-len)
\ int3
					{dup} {>r}			 	\ na len target <tos, target < rtos 
\ int3
					{swap} {cmove} {r>} 	\ target
\ int3
					
                    {dup} {last} {!}        \ save na for vocabulary link      na  _LINK=na
\ int3
                    {cell-}                 \ link address     LFA.address
\ int3
                    {context} {@} {swap}    \ 				   NFA LFA 
\ int3
                    jump> {!} \ {exit}      \ save code pointer   LFA=NFA 
    L: PNAM1:       
\ int3

					{$"|} s"  name" text,
\ int3
                    {branch} ABOR1: 16,

					debug-build? [if]
						{last} {dup} {@}	\  15cc fe02 7803
						{context} {dup} {@}  \  15cc fe02 7803 fdfe 7803
						int3
						{dolit} 0 16, AB L> newwordname
						int3 \ 1813
						{$,n}
						int3
	L: newwordname		s" test" text,
					[then] \ pass

\ ;; FORTH compiler
\
\ ;   $COMPILE    ( a -- )
\ ;       Compile next word to code dictionary as a token or literal.

                    $COLON  {$compile}  \ SCOMP
                    {name?} {?dup}                  \ ?defined
                    {?branch} 0 16, AB L> SCOM2:    
                    {@} {dolit} IMEDD 16, {and}     \ ?immediate
                    {?branch} 0 16, AB L> SCOM1:
                    jump> {execute} \ {exit}        \ its immediate, execute
    L: SCOM1:       jump> {,} {exit}                \ its not immediate, compile
    L: SCOM2:       {number?}                       \ try to convert to number
                    {?branch} ABOR1: 16,
                    jump> {literal} \ {exit}        \ compile number as integer


\ ;   OVERT   ( -- )
\ ;       Link a new word into the current vocabulary.

                    $COLON  {overt} \ OVERT
                    {last} {@} {context} jump> {!} \ {exit}


\ ;   ;       ( -- )
\ ;       Terminate a colon definition.

                    $COLON  {;} immediate(t) compile-only(t) \ SEMIS
\ int3
                    \ {compile} {exit} 
					{dolit} 0x90c3 16,
					\ {here} 
					\ {dup} {cell+} {cp} {!} 
					{,} 
\ int3
					{[} 
\ int3
					jump> {overt} 
\ int3
					\ {exit}


\ ;   ]       ( -- )
\ ;       Start compiling the words in the input stream.

                    $COLON  {]} \ RBRAC
                    {dolit} entryof {$compile} 16, {'eval} jump> {!} \ {exit}


\ ;   :       ( -- ; <string> )
\ ;       Start a new colon definition using next word as its name.

                    $COLON  {:}  \ COLON
                    {token}    \  ( <string> -- a )
					{$,n}      \ 
					{here} 
					{last} {@} {dolit} 2 16, {cells} {-} {!}
					jump> {]} \ {exit}


\ ;   IMMEDIATE   ( -- )
\ ;       Make the last compiled word an immediate word.

                    $COLON  {immediate}  \ IMMED
                    {dolit} IMEDD 16, {last} {@} {@} {or}
                    {last} {@} jump> {!} \ {exit}


\ ;; Defining words

\ ;   CREATE  ( -- ; <string> )
\ ;       Compile a new array entry without allocating code space.

                    $COLON  {create}  \ CREAT
                    {token} {$,n} {overt}
                    {compile} {dovar} {exit}


\ ;   VARIABLE    ( -- ; <string> )
\ ;       Compile a new variable initialized to 0.

                    $COLON  {variable} \ VARIA
                    {create} {dolit} 0 16, jump> {,} \ {exit}

\ ;; Tools
\
\ ;   _TYPE   ( b u -- )
\ ;       Display a string. Filter non-printing characters.
    
                    $COLON  {_type} \ UTYPE
                    {>r}                            \ start count down loop
                    {branch} 0 16, AB L> UTYP2:     \ skip first pass
    L: UTYP1:       {dup} {c@} {>char} {emit}       \ display only printable
                    {1+}                            \ increment address
    L: UTYP2:       {donext} UTYP1: 16,             \ loop till done
                    jump> {drop} \ {exit}


\ ;   dm+     ( a u -- a )
\ ;       Dump u bytes from , leaving a+u on the stack.
    
                    $COLON  {dm+}  \ DUMPP
                    {over} {dolit} 4 16, {u.r}      \ display address
                    {space} {>r}                    \ start count down loop
                    {branch} 0 16, AB L> PDUM2:     \ skip first pass
    L: PDUM1:       {dup} {c@} {dolit} 3 16, {u.r}  \ display numeric data
                    {1+}                            \ increment address
    L: PDUM2:       {donext} PDUM1: 16,             \ loop till done
                    {exit}


\ ;   DUMP    ( a u -- )
\ ;       Dump u bytes from a, in a formatted manner.

                    $COLON  {dump}  \ DUMP
                    {base} {@} {>r} {hex}               \ save radix, set hex
                    {dolit} 16 16, {/}                  \ change count to lines
                    {>r}                                \ start count down loop
    L: DUMP1:       {cr} {dolit} 16 16, {2dup} {dm+}    \ display numeric
                    {rot} {rot}                         \ 
                    {dolit} 2 16, {spaces} {_type}      \ display printable characters
                    {nuf?} {not}                        \ user control
                    {?branch} 0 16, AB L> DUMP2:        \ 
                    {donext} DUMP1: 16,                 \ loop till done
                    {branch} 0 16, AB L> DUMP3:         \ 
    L: DUMP2:       {r>} {drop}                         \ cleanup loop stack, early {exit}
    L: DUMP3:       {drop} {r>} {base}                  \ restore radix
                    jump> {!} \ {exit}


\ ;   .S      ( ... -- ... )
\ ;       Display the contents of the data stack.

                    $COLON  {.s}  \ DOTS
                    {cr} {depth}                    \ stack depth
                    {>r}                            \ start count down loop
                    {branch} 0 16, AB L> DOTS2:     \ skip first pass
    L: DOTS1:       {r@} {pick} {.}                 \ index stack, display contents
    L: DOTS2:       {donext} DOTS1: 16,             \ loop till done
                    {."|} s"  <sp " text,
                    \ 5 8, 32 8, ASCII < 8, ASCII s 8, ASCII p 8, 32 8,
                    {exit}


\ ;   >NAME   ( ca -- na | F )
\ ;       Convert code address to a name address.
    
                    $COLON  {>name}  \ TNAME
                    {context}                       \ vocabulary link
    L: TNAM2:       {@} {dup}                       \ ?last word in a vocabulary
                    {?branch} 0 16, AB L> TNAM4:    \ 
                    {2dup} {name>} {xor}            \ compare
                    {?branch} 0 16, AB L> TNAM3:    \ 
                    {cell-}                         \ continue with next word
                    {branch} TNAM2: 16,
    L: TNAM3:       {swap} {drop} {exit}
    L: TNAM4:       {2drop} {dolit} 0 16, {exit}


\ ;   .ID     ( na -- )
\ ;       Display the name at address.
    
                    $COLON  {.id}   \ DOTID
                    {?dup}                          \ if zero no name
                    {?branch} 0 16, AB L> DOTI1:    \ 
                    {count} {dolit} 0x1F 16, {and}  \ mask lexicon bits
                    {_type} {exit}                  \ display name string
    L: DOTI1:       {."|} s"  {noName}" text,
                    {exit}


\ ;   SEE     ( -- ; <string> )
\ ;               A simple decompiler. Updated for byte machines, 08mar98cht
\				  原本 [LFA][NFA][CFA] 的結構，被我改成 [CFA][LFA][NFA], SEE 也得跟著改。
\ 
\                   $COLON  {see}   \ SEE
\                   {'}                         \ starting address
\                   {cr} {cell+}                \ 
\   L: SEE1:        {1+} {dup} {@} {dup}        \ ?does it contain a zero
\                   {?branch} 0 16, AB L> SEE2: \ 
\                   {>name}                     \ ?is it a name
\   L: SEE2:        {?dup}                      \ name address or zero
\                   {?branch} 0 16, AB L> SEE3: \ 
\                   {space} {.id}               \ display name
\                   {1+}                        \ 
\                   {branch} 0 16, AB L> SEE4:  \ 
\   L: SEE3:        {dup} {c@} {u.}             \ display number
\   L: SEE4:        {nuf?}                      \ user control
\                   {?branch} SEE1: 16,
\                   jump> {drop} \ {exit}

\ ;   int3   ( -- )
\ ;               int3 is 8086's break point, hand over to debugger.

                    $code  {int3}
					int3
					return

\ ;   WORDS   ( -- )
\ ;       Display the names in the context vocabulary.

                    $COLON  {words}    \ WORDS
                    {cr} {context}              \ only in context
    L: WORS1:       {@} {?dup}                  \ ?at end of list
                    {?branch} 0 16, AB L> WORS2:
                    {dup} {space} {.id}         \ display a name
                    {cell-} {nuf?}              \ user control
                    {?branch} WORS1: 16,
                    {drop}
    L: WORS2:       {exit}


\ ;   READ        ( bufffer len -- len-read , filename )
\ ;       Open a file by name and load it into buffer.
\ ;
\                 $COLON  4,'READ',READ
\                       {dolit},ULAST,{dolit},32
\                       {dolit},0,{fill}
\                       {BL} {word} {count}
\                       {dolit},ULAST,{swap} {cmove}
\                       {dolit},3D00H
\                       OPENF,{dup} {dolit},-1
\                       {xor}
\                       {?branch},READ1
\                       {dup} {>r}
\                       READF
\                       {dup} {dolit},-1,{xor}
\                       {?branch},READ2
\                       {r>},CLOSE
\                       {exit}
\ READ2:                {r>} {drop}
\ READ1:                {dolit},'?',{emit} {cr} {abort}


\ ;   LOAD        ( buffer len -- )
\ ;       Load file read into the buffer.
\
\                 $COLON  4,'LOAD',LOAD
\                       {>in} {@} {>r}
\                       {#tib} {2@} {>r} {>r}
\                       {#tib} {2!}
\                       {dolit},0,{>in} {!}
\                       {eval}
\                       {r>} {r>} {#tib} {2!}
\                       {r>} {>in} {!}
\                       {exit}


\ ;   DOWNLOAD    ( -- , <filename> )
\ ;       Load file read into the buffer.
\
\                 $COLON  8,'DOWNLOAD',DLOAD
\                       {here} {dolit},1000,{+}
\                       {dup}
\                       {sp@} {dolit},1000,{-}
\                       {over} {-},READ
\                       LOAD
\                       {exit}


\ ;       checksum ( addr len -- sum )
\ ;       Add words to form 16-bit sum. len must be even.
\
\                 $COLON  8,'checksum',CHECKS
\                       {dolit},0,{tmp} {!}
\                       {2/} {dolit},-1,{+}
\                       {>r}
\ CHECK1:               {dup} {@} {tmp} {+!}
\                       {cell+}
\                       {donext},CHECK1
\                       {drop} {tmp} {@}
\                       {exit}


\ ;       EXE file header for SAVE
\ EXEHDR:               5A4DH           ;signature
\                       22H             ;extra bytes
\                       0CH             ;pages
\                       0               ;reloc items
\                       20H             ;header size
\                       0               ;min alloc
\                       0FFFFH          ;max alloc
\                       0               ;init SS
\                       0               ;init SP
\                       0BC66H          ;checksum
\                       0               ;init IP
\                       0               ;init CS
\                       1EH             ;reloc table
\                       0               ;{over}lay
\                       1               ;?
\                       0               ;reloc table


\ ;       UPLOAD  ( -- , <filename> )
\ ;       Save current image to an EXE file.
\
\                 $COLON  6,'UPLOAD',ULOAD
\                       {here} {dolit},1,{and} {allot}
\                       {dolit},UPP,{dolit},UZERO
\           {dolit},ULAST-UZERO,{cmove} ;initialize user area
\                       {dolit},ULAST,{dolit},32
\                       {erase}
\                       {BL} {word} {count}       ;get file name
\                       {dolit},ULAST,{swap} {cmove}
\                       {pad} {dolit},200H,{erase}
\                       {dolit},EXEHDR,{pad}
\                       {dolit},20H,{cmove}         ;init header
\                       {cp} {@} {dolit},0,{dolit},200H
\                       {um/mod} {1+}              ;add 512 bytes of header
\                       {over}
\                       {?branch},SAVE0
\                       {1+}
\ SAVE0:                {pad} {dolit},4,{+} {!}
\                       {pad} {cell+} {!}
\                       {pad} {dolit},200H,CHECKS
\                       {dolit},0,{cp} {@},CHECKS
\                       {+} {dolit},-1,{xor}
\                       {pad} {dolit},18,{+} {!}
\                       {dolit},3D01H             ;open to write
\                       OPENF,{dup} {dolit},-1
\                       {=}
\                       {?branch},SAVE1
\                       {drop} {dolit},0            ;create read/write
\                       CREATF,{dup} {dolit},-1
\                       {xor}
\                       {?branch},SAVE3
\ SAVE1:                {>r}                     ;save handle
\                       {pad} {dolit},200H
\                       {r>} {dup} {>r}
\                       WRITEF                  ;write header
\                       {dup} {dolit},-1,{xor}
\                       {?branch},SAVE2
\                       {dolit},0,{cp} {@}
\                       {r>} {dup} {>r}
\                       WRITEF                  ;write program
\                       {dup} {dolit},-1,{xor}
\                       {?branch},SAVE2
\                       {r>},CLOSE             ;ok. close file
\                       {exit}
\ SAVE2:                {r>} {drop}              ;write error
\ SAVE3:                {dolit},'?',{emit} {cr} {abort} ;create error


\ ;; Hardware reset

\ ;   hi      ( -- )
\ ;       Display the sign-on message of eForth.

                        $COLON  {hi}    \ HI
                        {cr} {."|}          \ initialize I/O
						s" 86eForth v?.?" text, HERE 3 - target-here !
                        VER ASCII 0 + 8,
                        ASCII . 8,
                        EXT ASCII 0 + 8,
                        jump> {cr} \ {exit}

						debug-build? [if]
							int3
							{hi}
							int3
						[then] \ pass


\ ;   'BOOT       ( -- a )
\ ;               The application startup vector.

                        $COLON  {'boot}    			\ TBOOT
                        {dovar} entryof {hi} 16,    \ application to boot


\ ;   COLD    ( -- )
\ ;       The hilevel cold start sequence.

                        $COLON  {cold}  \ COLD
    L: COLD1:           {dolit} UZERO: 16, {dolit} UPP 16,
                        {dolit} ULAST: UZERO: - 16, {cmove}     \ initialize user area
                        {preset}                                \ initialize data stack and {tib}
                        {'boot} {@execute}                      \ application boot
                        {overt}
                        {quit}              \ start interpretation
                        {branch} COLD1: 16, \ just in case

\ ;===============================================================

  L: CTOP    		    \ next available memory in code dictionary
  _LINK @ org L: LASTN  \ last name address in name dictionary

\ MAIN        ENDS
\ END ORIG
\
\ ;===============================================================


: touch-up  ( -- ) \ Remove the enveloping { and } from word names
	_LINK @ \ name_pointer
	begin
		dup peek8 0x1F AND \ name_pointer name_length
		2dup over 2+ -rot + over 1- cmove(t>t)  \ name_pointer name_length
		2- over peek8 0xE0 AND + over poke8 \ name_pointer
		2- peek16 \ name_pointer'
	?dup 0= until ;
	last execute

cr .( -- Save eforth.com -- )
target-space 0x100 DICSIZE array-slice binary-array>string constant eforth.bin // ( -- binaryString ) entire eforth.com binary
eforth.bin char eforth.com writeTextFile

