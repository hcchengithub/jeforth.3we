


[X] 2020/07/31 14:16:33 make sure wlkeys has nothing duplicated.
    \ 把整個 wlkeys array 翻譯成另一個 hash table,
    \ 查看 hash table 個數若與 wlkeys 一樣就表示 wlkeys 沒有重複的。

    <js>
    execute('wlkeys'); var wlkeys = pop(); var o={};
    for (var i in wlkeys) {
        type(i + " : " + wlkeys[i] + "\n");
        o[wlkeys[i]] = 1;
    }
    push(o)
    </js>

    0 : UDFInstanceName
    1 : PWL_PARAMVALUE_STRING
    2 : SetCurrentWS
    ... snip ....
    1570 : IsCommonNameModifiable
    1571 : BeforeFeat
    1572 : MethodName
     OK

    > .s   this is the hash table
          0: {
        "UDFInstanceName": 1,
        "PWL_PARAMVALUE_STRING": 1,
        "SetCurrentWS": 1,
        "CreateReorderBeforeOp": 1,
        "Invalidate": 1,
        ...snip......
        "BeforeFeat": 1,
        "MethodName": 1
    }

    calculate the hash table item count
    > <js>
    let size=0;
    for(let k in tos()) {
      size++
    }
    pop(); push(size);
    </js> --> 1573(number)  <----- correct!!!

[X] 2020/08/03 13:03:51 如何 download output data from proeforth?
    <html><body>
    <h1>The embed element 也可以插入 plain text</h1>
    <embed src="data:text/plain;base64,aGVsbG8gd29ybGQ=">
    <embed src="data:text/plain;charset=utf-8,hello%20world%21%21"><p>
    其中的 "aGVsbG8gd29ybGQ=" 是由 "hello world" 經 https://www.base64encode.org/ base64 encoded 而來。
    後來發現如果是 text 就沒必要用 base64. Search "data url online" 或 "data uri online"
    就可以找到類似 https://dopiaza.org/tools/datauri/index.php 的 resource 可以幫忙轉成
    data uri 所以不必麻煩自己去搞 HTML 語法、以及 base64 等等。<p>
    因為我不會輸出檔案， proeforth 本來想用此法讓 user download. 若不行，改用 textarea 讓 user 自己 copy-paste 好了。
    </body></html>
    See https://medium.com/cubemail88/data-uri-%E5%89%8D%E7%AB%AF%E5%84%AA%E5%8C%96-d83f833e376d

[X] 2020/08/07 18:00 決定把這個 app 命名為 proeforth.exe 並且放到 proeforth.html 同一個 project
    底下的 exe folder 裡
    Windows Console documentation https://docs.microsoft.com/en-us/windows/console/
    About Character Mode Applications https://docs.microsoft.com/en-us/windows/console/about-character-mode-applications
    
[X] 10:36 2020/08/08
    把 vm->vectors 改名為 vm->words 更好。
    Eval() 改成 KVMDictate() 更好理解。
    KVMGetWord 改成 KVMTick
    DictCompile 改成 KVMComma
        <-- 另有 KVMComma() !! shit, jeforth 好像誤會 comma 的意義了？還好！
        comma 是從 data stack 裡取值，我的 comma(sth) 是從 argument 取值，也可以啦，算是推廣擴充，
    [X] argument 裡放 pop() 就可以了。的確是如此，舊的 KVMComma() 只有一個，改成 KVMDoComma() 即可。
[X] 11:13 2020/08/08 用到 KVMComma() 的地方都要檢討一下，char dictionary[] 裡面既然是用 here 當 pointer
    那是 1+ 還是 8+ ? 參考 eforth64 看看 ==> eforth64 的 here 是以 byte 為單位，不一定 1+ 5+ 或 8+。
    然而，原來的 DictCompile(vm, int) 是否要改成 KVMComma(vm, __int64)? 還是照舊？總之要有能力 comma pointer
    進 dictionary 這可以用 p,(pointer) b,(byte) w,(16bites word) d,(64bits double precision) q,(64bits)
    等來 explicitly 指定。既然本來的 KVMComma() 是 DictCompile(vm, KVMPop(vm) ); 而 data stack 是 64 bits
    答案也就跟著確定是 64bits 的 __int64 了。
[/] comma 相關的 argument 改成 __int64 之後 colon word 一跑就當了。改回去看看， search __int64
    --> 改回去也沒用，可能是之前的 data stack , return stack 改成 __int64 就已經出問題了。
        那只有 vm.h 而已。
    --> 從來就沒好過, KsanaVM 用 Creo Toolkit 的 makefile compile 成 64bits 之後 column word 連
        : test ; test 都會當掉。其實這才對，因為 pointer 就是 64bits 怎可能原來用 int 當 cell、用 int
        compile 能跑？當然不能 RI。
[X] 那就用 GitHub 上的 KsanaVM 來改好吧！直接照這個環境的規格
    int 4 bytes, long 4 bytes, long long 8 bytes, pointer 8 bytes, double float 8 bytes.
    所以 KVMXT 是 8 bytes, char * 也是 8 bytes, . . . etc 重新 review vm.h .... 用最小的幅度把 KsanaVM
    弄到好。如果 data stack 是 int 那麼放 pointer 進去就要 casting, 先用 online gdb 試成功看看.....
    結果還是 yap 原來的方法：
        *(int*)(vm->dictionary + vm->here) = i;
    本來是全部都當 int 現在不行了，有的要用 *(KVMXT) 或別的。所以 8 bytes 的就要占兩個 cell 這有前例。
    --> 增添了一個 DictPointerCompile() --> 檢查所有用到 DictCompile() 的地方，很多要改。--> 其實也沒多少，
    改好了，來試試看吧。。。當！
    [X] 有寫好了 memdump() 再加幾個指令來 debug 吧！
[X] 18:59 2020/08/09 忘了 forth 的 string 怎麼處理的？ KVMTick 需要得到 name string 寫死很難用，想要能從
    TIB 取得 . . . 可以安排！ done
[X] 20:52 2020/08/09 把 colon word 當掉的問題解決就好了，proeforth.exe 處理 toolkit arguments 好難 <-- 15:30 2020/08/13 已經做到了第三課，不難了。
    先直接 trace 到 xt 的進入點，以及查看 : test ; compile 出來的結果。

    ok>tick + 100 dump
                        0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
    0000000002D91E50 :                         2B 00 00 00 00 00 00 00          +.......
    0000000002D91E60 : 00 00 00 00 00 00 00 00 30 2D 5A 2E F7 7F 00 00  ........0-Z.....
    0000000002D91E70 : 00 00 00 00 00 00 00 00 2D 00 00 00 00 00 00 00  ........-.......
    0000000002D91E80 : 00 00 00 00 00 00 00 00 E0 31 5A 2E F7 7F 00 00  .........1Z.....
    0000000002D91E90 : 00 00 00 00 00 00 00 00 2A 00 00 00 00 00 00 00  ........*.......

    ok>hex 2e5a2d30 hex 00007ff7 100 dump
                        0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
    00007FF72E5A2D30 : 48 89 4C 24 08 48 83 EC 38 48 8B 4C 24 40 E8 7D  H.L$.H..8H.L$@.}
    00007FF72E5A2D40 : FF FF FF 89 44 24 28 48 8B 4C 24 40 E8 6F FF FF  ....D$(H.L$@.o..
    00007FF72E5A2D50 : FF 89 44 24 20 8B 44 24 28 8B 4C 24 20 03 C8 8B  ..D$ .D$(.L$ ...
    00007FF72E5A2D60 : C1 89 44 24 24 8B 54 24 24 48 8B 4C 24 40 E8 DD  ..D$$.T$$H.L$@..
    00007FF72E5A2D70 : FE FF FF 48 83 C4 38 C3 CC CC CC CC CC CC CC CC  ...H..8.........
    ok>

    用 https://defuse.ca/online-x86-assembler.htm#disassembly2 disassemble 得：

    0:  48 89 4c 24 08          mov    QWORD PTR [rsp+0x8],rcx
    5:  48 83 ec 38             sub    rsp,0x38
    9:  48 8b 4c 24 40          mov    rcx,QWORD PTR [rsp+0x40]
    e:  e8 7d ff ff ff          call   0xffffffffffffff90
    13: 89 44 24 28             mov    DWORD PTR [rsp+0x28],eax
    17: 48 8b 4c 24 40          mov    rcx,QWORD PTR [rsp+0x40]
    1c: e8 6f ff ff ff          call   0xffffffffffffff90
    21: 89 44 24 20             mov    DWORD PTR [rsp+0x20],eax
    25: 8b 44 24 28             mov    eax,DWORD PTR [rsp+0x28]
    29: 8b 4c 24 20             mov    ecx,DWORD PTR [rsp+0x20]
    2d: 03 c8                   add    ecx,eax
    2f: 8b c1                   mov    eax,ecx
    31: 89 44 24 24             mov    DWORD PTR [rsp+0x24],eax
    35: 8b 54 24 24             mov    edx,DWORD PTR [rsp+0x24]
    39: 48 8b 4c 24 40          mov    rcx,QWORD PTR [rsp+0x40]
    3e: e8 dd fe ff ff          call   0xffffffffffffff20
    43: 48 83 c4 38             add    rsp,0x38
    47: c3                      ret
    48: cc                      int3

    確實就是 KVMAdd() 的 code 與
        cl /FAs -c -GS -fp:precise -D_WSTDIO_DEFINED -I. -I"D:\ptc\Creo 2.0/COMMON FILES/M230/protoolkit/x86e_win64/../includes" -DPRO_MACHINE=36 -DPRO_OS=4 vm.c
    compile 出來的 .asm 一致無誤。

    11:45 2020/08/10 it works on the older KsanaVM.exe
        ok>variable x
        ok>123 x !
        ok>x ?
        123 ok>
    but crash on compiled .exe. Let's see how's x ?

    ok>variable x
    ok>tick x 100 dump
                      0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
    0000000003608E00                         78 00 00 00 00 00 00 00          x.......
    0000000003608E10 00 00 00 00 00 00 00 00 A4 A7 60 03 00 00 00 00  ..........`.....  對啦！ xt 指向 dictionary 裡無誤。
    0000000003608E20 00 00 00 00 00 00 00 00

    ok>hex 0360a7a4 0 100 dump
                      0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
    000000000360A7A0             A0 20 B8 4F 00 00 00 00/00 00 00 00      . .O........  這裡應該是 KVMDoVariable 的 entry 看起來像 32bits 而已？
    000000000360A7B0 00 00 00 00/00 00 00 00 00 00 00 00 00 00 00 00  ................
    000000000360A7C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

    hex 4fb820a0 0 100 dump <-- 這就當了，可見當初 compile 時的這行
        DictPointerCompile(vm, KVMdoVariable);  // must add this for high level word
    就有問題了！必要時單寫成一 word 試試看。。 --> DictPointerCompile() 本來以為 *(long int*)
    是 64bits 改成 *(__int64*) 好多了。 可是 123 x ! 還是當掉 ... 直接 x ? 也當。光 x 就當了！

    [X] 14:35 2020/08/10 32bits 64bits 轉換用到 bit wise shift 結果在 sign bit 上出問題。
        KVMShiftLeft()
        hex 88888888 dup 32 <<
        Was FFFFFFFF88888888 <--- 之前從 2 cells 合併成 64bits 就已經錯了！我還以為已經驗證過了。
        To be 8888888800000000 after shift <--- shift 好了反而對了，錯了好久，矇在鼓裡。
        ok>
        15:30 2020/08/10 改用 union, actually Union64, FP.

    [X] 15:32 2020/08/10 回到上面 (光 x 就當了！)
        ok>variable x tick x 100 dump
                          0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
        00000000030EAE20                         78 00 00 00 00 00 00 00          x.......
        00000000030EAE30 00 00 00 00 00 00 00 00 A4 C7 0E 03 00 00 00 00  ................
        00000000030EAE40 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

        ok>hex 030ec7a4 0 100 dump
                          0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
        00000000030EC7A0             30 21 FD 42 F7 7F 00 00 00 00 00 00      0!.B........
        00000000030EC7B0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

        ok>hex 42fd2130 hex 7ff7 100 dump
                          0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
        00007FF742FD2130 48 89 4C 24 08 48 83 EC 28 48 8B 44 24 30 8B 90  H.L$.H..(H.D$0..
        00007FF742FD2140 28 3C 00 00 48 8B 4C 24 30 E8 92 0B 00 00 48 8B  (<..H.L$0.....H.
        00007FF742FD2150 4C 24 30 E8 D8 13 00 00 48 83 C4 28 C3 CC CC CC  L$0.....H..(....

        Disassembly:    這段 code 確定是 KVMdovariable
        0:  48 89 4c 24 08          mov    QWORD PTR [rsp+0x8],rcx
        5:  48 83 ec 28             sub    rsp,0x28
        9:  48 8b 44 24 30          mov    rax,QWORD PTR [rsp+0x30]
        e:  8b 90 28 3c 00 00       mov    edx,DWORD PTR [rax+0x3c28]
        14: 48 8b 4c 24 30          mov    rcx,QWORD PTR [rsp+0x30]
        19: e8 92 0b 00 00          call   0xbb0
        1e: 48 8b 4c 24 30          mov    rcx,QWORD PTR [rsp+0x30]
        23: e8 d8 13 00 00          call   0x1400
        28: 48 83 c4 28             add    rsp,0x28
        2c: c3                      ret
        2d: cc                      int3
        2e: cc                      int3
        2f: cc                      int3

        [X] 15:54 2020/08/10 不知道怎麼回事，從 KVMdovariable 裡面去 printf 來看吧。。。
            --> 根本沒有執行到 x 的 KVMdovariable 就當了 --> 檢查 outer loop, innter loop
            --> 可能是 KVMCall() 有問題，因為 code words run 的很好 --> 哈！果然，當時的 source code 以為
            addr 是 int 錯了，現在所有的 pointer 都是 64 bits. Compile 進 dictionary 的 code 有改用
            dictPointerCompile() 了所以裡面沒錯，但是 KVMCall() 還是舊的 code . . .
            --> dictionary 本身的 addrerss vm->ip 還是 32bits 無誤。
            [/] 可是 inDictionary() 的檢查就很可疑了
            [x] 把 vm->ip 由 int 改成 unsigned char *
            [X] KVMCall() 裡這段顯然錯了
                KVMRPush(vm,vm->ip); --> 要 push 兩次, [/] 檢討所有 KVMRpop()
                KVMCall(vm,addr);
            [X] 同上，KVMRet() 也要跟著改成 64bits
            [X] KVMCall() 的 spec 也錯了
                void KVMCall(KsanaVm *vm, int startaddr) --> int 改成 KVMXT
            [X] KVMCall() 的 ip 調整也錯了，ip 本身一跳要兩 cells 才對。若心疼 dictionary 空間，都用
                dictionary + ip 也是要一跳兩 cell, 根本原因是因為 sizeof data 與 sizeof address 不同。
                vm->ip += CELLSIZE;  --> 改成 vm->ip += POINTERSIZE;
            [/] 檢討所有用到 vm->ip 的地方
            [/] KVMDoVariable() 一開始的 push ip
            --> variable x x 不會當了，stack 中留下了兩個 cell 共 64bits 位址正確指向 x 的 data 位置
            [X] void  KVMStore(KsanaVm *vm) 原 code 以為 address 32bits 鐵定不行, also c!
            [X] void  KVMFetch(KsanaVm *vm) 原 code 以為 address 32bits 鐵定不行, also c@
            [X] void  KVMFill(KsanaVm *vm)
    [X] 09:32 2020/08/11 先把 以上 64bits address 在 data stack 裡的順序改一下 ( p.high p.low -- p.high p.low+count)
        比較方便運算，本來的 low 放前面只是照著 Intel CPU 以及 memory 裡的樣子，但不方便。
        [X] 09:39 2020/08/11 再加個 dropall 把 data stack 都清掉。
        [X] 改良 .s 看到大數就自動抓前一 cell 組成 64bits pointer.
            加個 .p (pointer) command 用來查看 data stack 上的 64 bits 資料，一般都是 pointer.
        [X] 利用 GitHub 查所有 存/取 64bits 的地方，都改掉。。。

    [X] 可是 inDictionary() 的檢查就很可疑了
        17:34 2020/08/10 果然可疑這是 vm.h 裡的 spec : int inDictionary(KsanaVm *vm, int address);

    [X] 檢討所有用到 vm->ip 的地方
        [X] KVMdoLiteral 看起來還好
        [X] branch(KsanaVm *vm)
            void KVMdoStrQ(KsanaVm *vm)
    [X] 檢討所有用到 DictCompile 的地方，很多應該改成 DictPointerCompile
    [X] KVMDoVariable() 一開始的 push ip
    [X] 檢討所有 KVMRpop()
[X] hex 抓 tib 後一個 hex, new word Hex 抓後面一整排 e.g. HEX D0 2F B4 39 F7 7F --> 00007FF739B42FD0
[X] 14:04 2020/08/11 if then else ffff eeee are not filled with correct address
    see OneNote2020 "Debug KsanaVM 的 if else then" 畫圖即解。
[X] 16:12 2020/08/11 test create does>
    ok>: constant create , does> @ ;  所以留給 does> 的是 PFA parameter fild address
    ok>234 constant aa \ 定義出 aa
    ok>aa .  \ 直接看 aa 拿到的是 PFA 開頭的 address
    28256544
    ok>aa ?  \ 去看看那 address 有啥？ 就是 constant 234.
    234
    08:54 2020/08/21 以上是有問題的，應該是 : constant create , does> r> @ ; 其中 r> 取得 PFA
    是 yap 的發明，顯然一定得做。
[X] 16:25 2020/08/11 把 string 改掉，不用 forth 慣例，改用 C 的方法用 null character 做 ending 就不必多
    一個 count. Note! s" foo bar " 本來就是會留下 addr count
    [X] 還是要寫個 count 來用。
        : count ( addrHL -- addrHL count ) \ get string length
            0 >r ( h l : count )
            begin
                over over ( h l h l : count )
                c@ 0 = ( h l 0? : count ) if ( h l : count ) \ 好了 \0 不算
                    r> ( h l count ) 1 \ break flag
                else ( h l : count )
                    r> 1 + >r  ( h l : count++ )
                    1 + ( h l++ : count++ ) 0 \ continue flag
                then
            until ;
    [X] 一跑就被 invalid address 擋了, 還是需要一個合用的安全檢查。
        08:16 2020/08/12 寫一個 suspecious function (start,length) 用來檢查 memory access
        vm 範圍涵蓋了 dictionary 範圍
        [x] 08:54 2020/08/12 code space 範圍用實驗法從 main 開始刺探看看安全範圍到哪裡？
            PS C:\Users\8304018\Documents\GitHub\KsanaVM> ./main
            Chern's EFI Forth v0.01 H.C. Chen 2008/10/26   http://www.stixy.com/guest/25033
            Based on yap's great works on <<Ksana Virtual Machine>>   http://tutor.ksana.tw
            CELLSIZE:4, POINTERSIZE:8
            main() @ 00007FF60FAD1000
            vm @ 0000000001AD0080, sizeof vm 00000008
            vm->ip 0000000000000000, sizeof vm->ip: 8
            vm->dictionary @ 0000000001AD289C, sizeof 00004000
            vm->vectors @ 0000000001AD0898, sizeof 00002000
            ok>hex 00007FF60FAD1000  <--- 試過加上 128K 00007FF60FAF1000 就當了
            ok>.s
            Data stack:
              0:       32758 00007FF6
              1:   263000064 0FAD1000 00007FF60FAD1000
            ok>74240 + .s  \ <--------- main.exe 的 file size
            Data stack:
              0:       32758 00007FF6
              1:   263074304 0FAE3200 00007FF60FAE3200
            ok>16 -
            ok>.s
            Data stack:
              0:       32758 00007FF6
              1:   263074288 0FAE31F0 00007FF60FAE31F0
            ok>200 -
            ok>dump  這個範圍內是安全的，超過太多就會當掉。怎麼取得這個範圍的尾巴？
            Attempt to dump a suspicious address: 00007FF60FAE3128 are you sure?[y/N]
            y
                              0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
            00007FF60FAE3120                         00 00 00 00 00 00 00 00          ........
            00007FF60FAE3130 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
            00007FF60FAE3140 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
            00007FF60FAE3150 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
            00007FF60FAE3160 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
            ok>

            [X] 查看 code 的順序是否照 obj 的順序？ --> 有，所以照 main() / .exe size 就可以了。
            # Object files
            OBJS = $(APP_NAME).obj io.obj string.obj progflow.obj var.obj compiler.obj vm.obj
                CELLSIZE:4, POINTERSIZE:8

                main()          @ 00007FF7AE881000
                end_of_io()     @ 00007FF7AE881760
                end_of_string() @ 00007FF7AE881C60
                the_end()       @ 00007FF7AE884240
                printf()        @ 00007FF7AE88454C <-------- 看起來有照 obj 順序！而且很小，
                                                             來自 library 的 code 跟在後面，佔大多數。

                vm @ 0000000001880080, sizeof vm 00000008
                vm->ip 0000000000000000, sizeof vm->ip: 8
                vm->dictionary @ 000000000188289C, sizeof 00004000
                vm->vectors @ 0000000001880898, sizeof 00002000
        [X] inDictionary() has its necessasity in KVMCall() so add vm and code check by leveraging it.
            inDictionary(): return (address >= vm->dictionary) && (address <= vm->dictionary + DICTSIZE);
            inVM():         return (address >= vm) && (address <= vm+sizeof(KsanaVm));
            inCode():       return (address >= main) && (address <= (__int64)main + 80000);
[X] 10:29 2020/08/12 以上 count 成功了！ 把 include 從 winapi.f 抄過來，也加進去 io.c 也成功了。
[X] 10:55 2020/08/12 從第一課開始來試 toolkit functions . . .
    [X] function names are very long, so change vm.h MAXNAMELEN from 15 to 31.
    [X] 11:35 2020/08/12 一跑等好久，結果 ProError -1
        ok>ProEngineerStart 等好久好久。。。。
        ok>.s
        Data stack:
          0:          -1 FFFFFFFF
        --> 改跑第一課看看。。。可以。
        --> 也改用 run.bat 照抄。。。好了！
[X] 09:42 2020/08/13 所有用到 KVMNextToken 的地方都要檢討，它傳回 Boolean 且 vm->token 可能無意義。
    [X] KVMNextString 亦同。 --> 06:14 2020/08/22 果然有問題... e.g. [x] : 開始之後直接 enter 就會出毛病。
    [X] variable [X] create [X] alias
[X] 11:45 2020/08/12 進入第三課
    [X] 11:50 2020/08/12 先需要 wchar_t * 版本的 s" 稱作 w" 吧！ --> 新增了 w" 與 wtype
        [X] 12:49 2020/08/12 這下要先把 forth string 的 count 革除 . . . 好了。
        [X] 13:39 2020/08/12
            wchar_t 似乎都是兩個 byts --> wcslen 說多少乘以2 就對了
            但中文好像 3 個 byts --> 確實很奇怪，不管它，依 wcslen 就對了
            且 ending null character 也不詳 --> 就是 '\0\0'.

            種種疑點需要做個 strncpy 的 wchar_t 版本的來試
            wchar_t *wcsncpy(
               wchar_t *strDest,
               const wchar_t *strSource,
               size_t count
            );
            char *strncpy(  <----- 有了
               char *strDest,
               const char *strSource,
               size_t count
            );
            swprintf(dest,"format",source)

            here . cr create ss 100 allot create ws 100 allot here . cr  \ 弄出兩塊 string 空間
            ss 100 hex 11 fill    \ 給定初值
            ws 100 hex ff fill
            ss 16 - 250 Dump      \ 查看它們

            \ 試驗 strncpy

            ws 3 + ss 5 strncpy   \ make a copy
            ss 16 - 250 Dump      \ 查看它們 --> strncpy string copy 就是 byte to byte copy 沒有管 ending 的 null char

            14:28 2020/08/12 開頭有個 wchar_t * string ws 用來試驗看看
                C:\Users\8304018\Documents\GitHub\KsanaVM>main.exe
                Chern's EFI Forth v0.01 H.C. Chen 2008/10/26   http://www.stixy.com/guest/25033
                Based on yap's great works on <<Ksana Virtual Machine>>   http://tutor.ksana.tw
                CELLSIZE:4, POINTERSIZE:8
                main() @ 00007FF75D4C1000
                end_of_io() @ 00007FF75D4C18C0
                end_of_string() @ 00007FF75D4C21D0
                the_end() @ 00007FF75D4C4740
                printf() @ 00007FF75D9736E8
                vm @ 0000000003BBBF90, sizeof KsanaVm 00007C68
                vm->ip 0000000000000000, sizeof vm->ip: 8
                vm->dictionary @ 0000000003BBF7AC, sizeof 00004000
                vm->vectors @ 0000000003BBC7A8, sizeof 00003000
                ws @ 000000000131FB48, sizeof 00000009

            ws hex 000000000131FB48 9 wcsncpy   \ make a copy
            ss 16 - 250 Dump      \ 查看它們

                              0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
            0000000003BBF820 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11  ................
            0000000003BBF830 50 2A 4C 5D F7 7F 00 00 41 00 42 00 43 00 9D 92  P*L]÷...A.B.C..’
            0000000003BBF840 5C 52 3F 00 45 00 4E 00 44 00 FF FF FF FF FF FF  \R?.E.N.D.yyyyyy
                                                           ^^^^ 同樣 wcsncpy 也不含 ending null char
            ok>hex 000000000131FB48 dump
                              0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
            000000000131FB40                         41 00 42 00 43 00 9D 92          A.B.C..’
            000000000131FB50 5C 52 3F 00 45 00 4E 00 44 00 00 00 F7 7F 00 00  \R?.E.N.D...÷...
                                                           ^^^^^ 可能 null char 也是 \0\0


        [X] 所以要搞懂 wchar_t* 的 ending null char 就要用 swprint 來試驗。

            C:\Users\8304018\Documents\GitHub\KsanaVM>main.exe
            Chern's EFI Forth v0.01 H.C. Chen 2008/10/26   http://www.stixy.com/guest/25033
            Based on yap's great works on <<Ksana Virtual Machine>>   http://tutor.ksana.tw
            CELLSIZE:4, POINTERSIZE:8
            main() @ 00007FF64BF11000
            end_of_io() @ 00007FF64BF118C0
            end_of_string() @ 00007FF64BF12260
            the_end() @ 00007FF64BF147D0
            printf() @ 00007FF64C3C3778
            vm @ 000000000316BF90, sizeof KsanaVm 00007C68
            vm->ip 0000000000000000, sizeof vm->ip: 8
            vm->dictionary @ 000000000316F7AC, sizeof 00004000
            vm->vectors @ 000000000316C7A8, sizeof 00003000
            ws1 @ 00007FF64D2FA000, sizeof 00000009
            ws2 @ 00007FF64D2FA018, sizeof 00000008
            ok>
            wchar_t ws1[] = L"ABC" L"中文" L"END";
            wchar_t ws2[] = L"ABC" L"一" L"END";

            把 ws1 or ws2 swprint 給 ws 看看

            create ws 100 allot \ 弄出 Wstring 空間
            ws 100 hex ff fill
            ws 16 - 117 Dump      \ 查看它們

            ok>ws hex 00007FF64D2FA000 swprintf
            ok>ws 16 - 117 Dump      \ 查看它們
                              0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
            000000000316F7B0                                     C0 40 F1 4B              A@nK
            000000000316F7C0 F6 7F 00 00 E0 2A F1 4B F6 7F 00 00 41 00 42 00  o...a*nKo...A.B.
            000000000316F7D0 43 00 9D 92 5C 52 3F 00 45 00 4E 00 44 00 00 00  C..’\R?.E.N.D...
                                   ^^^^^ 猜是中文開頭                  ^^^^^ 終於證實了！ wchar_t* 的 ending null char 是 '\0\0'
                                         ^^^^^ 「中」嗎？
                                               ^^^^^ 「文」嗎？

            ok>\ 再來一次，改用 ws2
            ok>ws hex 00007FF64D2FA018 swprintf
            ok>ws 16 - 117 Dump \ 查看它們
                              0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
            000000000316F7B0                                     C0 40 F1 4B              A@nK
            000000000316F7C0 F6 7F 00 00 E0 2A F1 4B F6 7F 00 00 41 00 42 00  o...a*nKo...A.B.
            000000000316F7D0 43 00 9D 92 80 00 45 00 4E 00 44 00 00 00 FF FF  C..’..E.N.D...yy
                                   ^^^^^ 這可能是中文的開頭
                                         ^^^^^ 這才是「一」嗎？
        [X] 15:38 2020/08/12 繼續改寫 --> 16:20 2020/08/12 好了！新增 w" 與 wtype
    [X] 16:56 2020/08/12 : pathname w" cube.prt" ;  執行 pathname 就當掉。
        對照 ANSI string 看看。。。。。
        ok>: test s" abc" ;
        ok>test
        ok>.s
        Data stack:
          0:           0 00000000
          1:    64419740 03D6F79C 0000000003D6F79C
        ok>dump
                          0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
        0000000003D6F790                                     61 62 63 00              abc.
        0000000003D6F7A0 F0 40 29 0A F6 7F 00 00 00 00 00 00 00 00 00 00  e@).o...........

        ok>tick test .s
        Data stack:
          0:           0 00000000
          1:    64410632 03D6D408 0000000003D6D408
        ok>dump
                          0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
        0000000003D6D400                         74 65 73 74 00 00 00 00          test....
        0000000003D6D410 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
        0000000003D6D420 00 00 00 00 00 00 00 00 94 F7 D6 03 00 00 00 00  ........”÷O.....
                                                 ^^^^^^^^^^^^^^^^^^^^^^^ 這應該是 KVMdoStrQ
        ok>: test w" this is a wide string" ;
        ok>test wtype cr
        this is a wide string  <---- 奇怪，又好了!
        ok>

        ok>: pathname w" cube.prt" ; <--- 當不當，隨長度有關
        ok>pathname   <---- 這個真的就會當，奇怪了！！！

        17:16 2020/08/12 先看 compile 進去的東西對不對，here 是否調正確？應該是
        下一步才是 從 KVMdoWStrQ 裡印 debug message 出來看

        ok>: test w" cube.prt" ;
        ok>tick test .s
        Data stack:
          0:           0 00000000
          1:    56087560 0357D408 000000000357D408
        ok>dump
                          0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
        000000000357D400                         74 65 73 74 00 00 00 00          test....
        000000000357D410 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
        000000000357D420 00 00 00 00 00 00 00 00 94 F7 57 03 00 00 00 00  ........”÷W.....

        ok>0 hex 0357f794 dump
                          0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
        000000000357F790             60 1B 29 0A F6 7F 00 00 63 00 75 00      `.).o...c.u.
                                     ^^^^^^^^^^^^^^^^^^^^^^^ KVMdoWStrQ
                                                             ^^^^^^^^^^^ cu
        000000000357F7A0 62 00 65 00 2E 00 70 00 72 00 74 00 00 00 00 00  b.e...p.r.t.....
                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ be.prt
                                                             ^^^^^ null
                                                                   ^^^^^ alignment
        000000000357F7B0 F0 40 29 0A F6 7F 00 00 00 00 00 00 00 00 00 00  e@).o...........
                         ^^^^^^^^^^^^^^^^^^^^^^^ KVMRet

        17:38 2020/08/12

        ok>: test w" cube.prt" ;
        ok>tick test .s
        Data stack:
          0:           0 00000000
          1:    53924872 0336D408 000000000336D408
        ok>dump
                          0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
        000000000336D400                         74 65 73 74 00 00 00 00          test....
        000000000336D410 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
        000000000336D420 00 00 00 00 00 00 00 00 94 F7 36 03 00 00 00 00  ........”÷6.....
        000000000336D430 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
        000000000336D440 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
        ok>0 hex 0336f794 dump
                          0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
        000000000336F790             60 1B 43 09 F6 7F 00 00 63 00 75 00      `.C       o...c.u.
        000000000336F7A0 62 00 65 00 2E 00 70 00 72 00 74 00 00 00 00 00  b.e...p.r.t.....
        000000000336F7B0 30 41 43 09 F6 7F 00 00 00 00 00 00 00 00 00 00  0AC   o...........
        000000000336F7C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
        000000000336F7D0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
        ok>test
        wstring address 000000000336F79C <--- correct
        len 16, align 0
        vm->ip  000000000336F7AC <--- 錯了！  0336F7B0 才對，所以是 align 算錯了 --> 17:51 2020/08/12 解了


    [X] 16:21 2020/08/12 繼續做第三課 --> 16:42 2020/08/12 寫好了，來玩玩看。。。
            \ 啟動 creo 2
            ProEngineerStart <---- 別忘了，否則執行 ProMdlRetrieve 等半天之後回 -11 'communication error'

            \ this is the spec
            \ ( pathname ProMdlType &ProMdl -- ProError ) http://localhost:8800/Creo_3.0_Toolkit_Doc/protkdoc/api/1759.html
            \ void MdlRetrieve(KsanaVm *vm)

            \ sizeof(ProMdl): 8 因為 typedef void* ProMdl; 本身就是個 void *
            create model 8 allot \ 弄出 ProMdl
            : pathname w" cube.prt" ;

            \ model 一開始都是 0, allot 會清零
            model dump
                              0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
            000000000351F790                                     00 00 00 00              ....
            000000000351F7A0 00 00 00 00 60 1B 63 8E F6 7F 00 00 63 00 75 00  ....`.c.....c.u.
            000000000351F7B0 62 00 65 00 2E 00 70 00 72 00 74 00 00 00 00 00  b.e...p.r.t.....
            000000000351F7C0 F0 40 63 8E F6 7F 00 00 00 00 00 00 00 00 00 00  .@c.............

            \ 用 proeforth 切換到對的 working directory 否則 ProError -4 PRO_TK_E_NOT_FOUND
            cd c:\Users\8304018\Documents\Creo2\cube

            \ Run
            pathname 2 model ProMdlRetrieve
            ok>.s
            Data stack:
              5:           0 00000000 0000000000000000  執行成功了
            ok>

            \ 回頭檢查 model (ProMdl) 為 0000000013EB30E8
            model dump
                              0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
            000000000351F790                                     E8 30 EB 13              .0..
            000000000351F7A0 00 00 00 00 60 1B 63 8E F6 7F 00 00 63 00 75 00  ....`.c.....c.u.
            000000000351F7B0 62 00 65 00 2E 00 70 00 72 00 74 00 00 00 00 00  b.e...p.r.t.....
            000000000351F7C0 F0 40 63 8E F6 7F 00 00 00 00 00 00 00 00 00 00  .@c.............

            ok>0 hex 13eb30e8 dump  想把 model dump 出來看，立刻被甩出去
                              0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
            0000000013EB30E0
    [x] 08:10 2020/08/13 dump 沒有檢查嗎？ 有哇！這就奇怪了，main 一開始印出 VM Code 的範圍吧！也有哇！
            memdump() 竟然沒有攔截到異常的 access？

        ok>model dump
                          0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
        00000000035BF790                                     38 86 12 14              8...
        00000000035BF7A0 00 00 00 00 60 1B 84 1A F7 7F 00 00 63 00 75 00  ....`.......c.u.
        00000000035BF7B0 62 00 65 00 2E 00 70 00 72 00 74 00 00 00 00 00  b.e...p.r.t.....
        00000000035BF7C0 F0 40 84 1A F7 7F 00 00 00 00 00 00 00 00 00 00  .@..............
        00000000035BF7D0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

        ok>3453354 hex 14128638 dump \ <--- 故意弄個超過的，果然有被攔截到
        Attempt to dump a suspicious address: 0034B1AA14128638 are you sure?[y/N]

        ok>0  hex 14128638 dump \ <--- 這個有在範圍內嗎？看起來不對呀！沒有攔截到！！
                          0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
        0000000014128630
        PS C:\Users\8304018\Documents\GitHub\KsanaVM>

        08:43 2020/08/13 果然 inVM 是有問題的！竟然回 1
        vm 304BF60 ~ hex 000000003f79a9a0 inVM 都回 1 這很奇怪
            vm @ 000000000304BF60, sizeof KsanaVm 00007C68
[X] immediate flag 太浪費, 31 characters name 太長, 可以合併一下。Flag 一個 byte 夠了，放在 name 後面。
[X] 15:31 2020/08/13 著手給每個 word 都加上 help
    給每個 word 都加上 help, 多一個 help char * 欄位指向 help. code words 用 interpret mode commands
    在某個 .f 裡整批填；
    [X] colon words 用 // command 比照 peforth.
    --> 先改定義讓 KsanaWord 帶有 help
[ ] 把 vm 弄成 global 就不必每次都得以 vm 當 argument。用到 vm 的 function 都以 KVM 開頭，還是有點章法。
[ ] reset command 或每出 error e.g. stack overflow, stack underflow 等就該 reset.
[ ] compiler、colon definition 等都要有防爆機制，words 空間、dictionary 空間爆滿警告。
[X] 10:36 2020/08/14 main 印的一堆東西都弄成 info and info: <name> commands
    13:10 2020/08/14 inlist command 好了, debugging . . . 一跑就被甩出來 RI: KVMAddInfo
    13:14 2020/08/14 因為可能很多想看的 info 都是 toolkit 的，add info 都搬進 toolkit.c
    [X] 可能是 string 的問題 --> 用 toolkit.c 做做實驗
        --> 發現 vm->constList 本身就試 SystemInof_t 的 next 不能再 ->next 了
            而且它初值就是 0 寫進去要用 vm->constList.
    --> 完成了 system-constants 以及 const: <name> 兩個好用的命令。
[X] 23:51 2020/08/14 new bug!!
    p r o e f o r t h . e x e           H.C.Chen 2020/08/13
    Based on yap's great works on <<Ksana Virtual Machine>>
    OK : test ;
    unknown command test <---- 因為 forth.f 沒有結束。。。 哈哈 bug , shit !!!
[X] 23:52 2020/08/14 working on : test [ lit hex 11223344 , ] ; <--- it works now!
        [ lit hex 11223344 , ] 32 bits literal
        [ lit hex 11223344 , ]

[X] 16:45 2020/08/14 改短一點
        Attempt to dump a suspicious address: 0000000003B69150 are you sure?[y/N]
[X] 22:16 2020/08/16 print 64 bits integer : printf("int 64 bits %I64d\n", 0x7fffffffffffffff ); // int 64 bits 9223372036854775807
[X] 21:52 2020/08/15 CELLSIZE 應該要與 POINTERSIZE 一致，都用 64 bits 才對，否則太麻煩了。
    還是要回歸到 曾慶潭 老師的 指導。
    [X] 20:47 2020/08/16 動手了，Branch 64-bits-cell on GitHub 是動手前的最後一版 32 bits cell 版。
        從 vm.h 改下去再說了 --> 21:26 2020/08/16 很順利，直接能跑！看一下 .s 顯示還是 32 bits 竟然也對！
        因為光 CELLSIZE 改了，並沒有多少人鳥他。不是從 .s 開始看，從 Eval() 才對
    [X] vm.c eval
    [X] hex hex:
    [X] kvmpop rpop kvmpush rpush
    [X] dup swap drop . . .
    [X] 怕 eval() 裡的 atoi() 有 support 64bits 嗎？有
    [X] DictCompile
    [X] vm.h 裡的 spec int -> __int64
    [X] compiler.c 整個要看一遍,
    [X] DictPointerCompile 可以取消，用不著了。
    [X] 22:17 2020/08/16 暫時可以正確 .s 了，休息了，明天見。。。
    [X] . dot
    [X] 四則運算、邏輯、左移、右移等
    [X] review int -> __int64 and Union64 in
        [x] io.c [x]string.c [X]progflow.c [X]var.c [X]main.c [X]toolkit.c [X]root.f
        [X]compiler.c [X]vm.h [X]vm.c
[X] 14:33 2020/08/19 為了利用 TIB 又不要它太 volatile, main loop 裡弄多份輪著用 ... done!
    This is easy and powerful. 以後可以方便地使用 str and line 不怕馬上 volatile 了。
[X] 給個 string 指出最後一個 word 的 index 怎麼寫? 從尾巴往回找到 space or 0
    結果就是 0 or the space + 1 , while space is c <= $20
    : indexof-last-token // ( str -- idx ) Get index to the trimed string's last token
        count 1 - ( str idx )
        begin ( str idx )
            \ 往回找看先到 c <= 32 或 idx 0 先到
            1 - ( str idx-- )
            ?dup if ( str idx )
                2dup + c@ ( str idx c ) 32 > if ( str idx )
                    CONTINUE
                else ( str idx ) \ 找到 white space 了, 答案就是 idx+1
                    1 + nip BREAK
                then
            else ( str ) \ 到頭了
                drop 0 BREAK
            then
        until ;
    this is for tab completion

[X] study sendkey
    [/] 找到 sendkeys 的 example "SendKeys in C++ - CodeProject", 不會 compile。
        [/] RTFD https://docs.microsoft.com/zh-tw/cpp/windows/walkthrough-creating-windows-desktop-applications-cpp?view=vs-2019
        最後沒用到，改用了 SendMessage()
    [/] 11:10 2020/08/20 查 winuser.h https://docs.microsoft.com/en-us/windows/win32/api/winuser/
        就有很多可能的 sendkey methods: SendInput SendMessage SendMessageA SendMessageW 等應該都可以。
        --> 不是用 compile 的，應該沒人這樣用，都是 call user32.dll 的吧！
    [X] 11:03 2020/08/20
        EiZu Yu 教我用 sendmessage 結果也 compile 不出來。Branch semdmessage 簡化到只剩 main.c 用來搞懂這關。
        --> 用 VS project 來試試看。。。自己送 message 給自己。成功了在轉出 makefile 來參考。
        --> 哈! 還是卡在 including winuser.h, EiZu 說是直接 call user32.dll <--- 對了！
        [X] 11:30 2020/08/20 果然找到這篇 https://stackoverflow.com/questions/13667001/using-user32-dll-sendmessage-to-send-keys-with-alt-modifier
        [X] 11:45 2020/08/20 更好的辦法是參考 KsanaVM winapi.f, see my OneNote2020 > "用 KsavaVM call Windows user32.dll"
    Get your console window
    https://stackoverflow.com/questions/2620409/getting-hwnd-of-current-process
    https://docs.microsoft.com/en-us/windows/console/getconsolewindow?redirectedfrom=MSDN
[X] 18:32 2020/08/21 簡化設計，想要把 loadlibrary 改成 colon word
    07:27 2020/08/22 done!
[X] 06:54 2020/08/22 help 直接 enter .... 提供指引 --> 改 run helpall
[X] 11:40 2020/08/22
    str:    aaa    <-- with tailing white spaces
    type -->     aaaOK <--- tailing white spaces are missing !!!
    RI: trim() were used in main() that should and has now been removed
    --> trim 還意外被定義成 immediate 因為它會修改 string 所以會當掉。
[x] : lineEdit \ 這已經是在取代 shell command line editer 的功能了，不必！
        s" ----> " type 0 ( count )
        begin
            getch >r
            r@ 8 = if
                    ( count ) ?dup if
                        8 emit space 8 emit 1 - ( count-- )
                    else
                        0 ( count )
                    then
                    r> drop 0 >r \ 把 char 換成 0
                    ( count ) CONTINUE
                then
            r@ 13 = if
                    r> drop 0 >r \ 把 char 換成 0
                    drop ( empty ) BREAK
                then
            r> ?dup if
                    emit 1 +
                    ( count++ ) CONTINUE
                then
        until ( empty )
        ;
[X] 14:17 2020/08/22 nword d@ 改成 nword 就好， read only 沒必要 d@ 徒增困擾。
[X] 15:46 2020/08/22 help 改壞了，錯！不是改壞了，而是 BL word 傳回 string 含進了
    行尾的 0A 00 所以 (help) 找不到該 word
    : hh BL word (help) ;
    OK : tt BL word dump ;
    OK tt sssss
                      0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
    0000000003C7BF90 73 73 73 73 73 0A 00 64 65 65 65 31 31 31 31 31  sssss..deee11111
                                    ^^ 何時多出來的？
    16:26 2020/08/22 因為 word 想要包括 CRLF 所以另外設計了 io.c KVMNextString
    偏偏 13 word 時它就把 0A 給包括進去了。 所以 KVMNextString 並不成功，要再想清楚。。。
    將來要 support <comment> <text> 之類怎麼辦？
    --> KVMNextString() 的設計應該要把 BL 解釋成所有的 white space 才對。
        所以它接受 BL(32) CRLF(1310) 以及其他 char
    --> Done !!!

[ ] 06:54 2020/08/22 review helpall，錯誤很多。
[X] 16:37 2020/08/17 來寫個 tab autocompletion
    收 getche() 都放進 tib 裡去
    隨時按下 tab 就到 vectors 裡去找類似的 words 出來輪

    [X] see OneNote Work2020 "proeforth.exe tab autocompletion" ... 09:21 2020/08/23 早期的設計構想。
    [/] 17:12 2020/08/19 改用 C 來寫 --> 21:40 2020/08/22 擱置了。

        // 一整行讀進來如果最後是 tab 就來 call TabCompletion() 把最後一 token 自動完成，整行印出，等待 user 繼續輸入。
        // 最後把 TCline 行，加上 token'，加上 user 的輸入，當成 command line 餵進去。
        // 因為有 tab completed 就有 TCtoken 因此狀態可分辨。

        // Tab Completion
        int TCidx = 0; // 有 Tab Completion 進行中時，指在最後找到的 wid。
        char TCtoken[MAXNAMELEN+1]; // 原始 user 輸入的 token
        char TCfound[MAXNAMELEN+1]; // 找到的 word name
        char TCline[TIBLINESIZE]; // 原始 user 輸入行，去掉 last token。

        TCtoken[0] = '\0'; // 確保初值為 ""

        // 查看是已經在 tab completion 進行中還是剛進來？
        if (strlen(TCtoken)) { // 已經在進行中

        } else { // 剛開始 tab completion
            // ----- 分離 last token 取得 TCline ( s -- s' token )  ---------------
            trim(s);
            for (i=strlen(s)-1; i>=0; i--) if (s[i]<=32) break; // 可能是 -1, i + 1 就是 last token
            // i 指在 white space 上或 -1，下一 char 就是 token
            strncpy(TCtoken, s+i+1,MAXNAMELEN);
            s[i>0 ? i : 0 ] = '\0'; // 切掉 token
            strncpy(TCline, s, TIBLINESIZE);
            // ----- 剛開始，words list 從頭找起。
            TCidx = 0;
        }

        // ( token -- token' ) search token in words 自動完成某 token
        for (i=TCidx; i<vm->nword; i++){
            if (stricmp(vm->vectors[i].name,TCtoken) == 0 ) {
                strncpy(TCfound, vm->vectors[i].name,MAXNAMELEN);
                TCidx = i+1; // 更新最後找到的 wid
            }

        }

    [X] 應該是給出原始 s0 的開始 index 以及新 s1, 這個功能把 s1 用 sendkey 印在 s0 正確的位置上，不用管
        backspace 等 editing 功能。只好在 tab 之後用 enter 送出，上手後根據 tab 再把整行用 sendkey 重送
        一遍，但是換掉最後一個 token

        : SendString // ( str -- ) Mimic keyboard stokes send a string
            count ( str len )
            0 do ( str )
                dup i + c@ sendkey 0 sendkey
            loop drop ;
            \ 成功了

        \ limit 來自 indexof-last-toekn
        : SendnString // ( str limit -- ) Mimic keyboard stokes send a trimed string's leading n chars
            ( str limit ) over count nip
            0 do ( str limit )
                i over ( str limit i limit ) < if ( str limit )
                    over i + c@ sendkey 0 sendkey
                else ( str limit )
                    2drop
                    ( break the loop ) r> drop r> drop 0 >r 0 >r
                then
            loop
            ;
            \ 成功了
            \ dropall str:   11 22 33
            \ trim dup indexof-last-token ( str limit ) 2dup + -rot ( s0 str limit )
            \ SendnString
    [X] 21:39 2020/08/22 應該是放在 main() 裡面檢查，方法就是來 call back 一個 colon word "tab-complete"
        : tab-complete // ( line -- bool ) compose command line with TAB completion of the last word
            count ( line len ) over + 2 - \ 長度減一變 index, 行尾的 0A 再減一, 得到最後 char 的位置
            ?dup if ( line tail )
                c@ ( line c ) 9 = ( line tab? ) if ( line )
                    \ 目標：切分最後一個 token 得 s0 s1
                    trim \ 到這裡整理一下不為過了 ( line' )
                    dup indexof-last-token ( line idx ) ?dup if ( line idx )
                        over + ( line idx s1 ) -rot ( s1 line idx ) \ s1 有了
                        over + 1 - ( s1 line s0tail ) 0 swap c! ( s1 line ) \ s0 結尾填 \0
                        swap ( s0 s1 ) \ s0 結尾少了一個 space 將來要還它
                    else ( line ) \ 單一個 token
                        null swap ( null line )
                    then \ ( s0 s1 ) 分好了
                    \ 進入回圈選 candidate
                    tab-select \ ( ss s0 -- ) any key to iterate candidates ESC to exit
                    F \ 這時候 keyboard buffer 上就是選好的 command line
                else ( line ) drop T then \ 不是 tab 結尾就不用加工
            else ( line ) drop T then \  空的
            ;

        先觀察 tab-complete 收到什麼
        : tab-complete ( line -- line' )
            dup dumpn 100 ;
    [X] 07:09 2020/08/23 照上面已經成功的操作來看，根本不必放進 main() 的機關，也不必檢查是
        否 tab key, 直接設計一個普通 word 用來做 completion 就可以了。
        ?? ( -- ) complete the next word
        --> 成功了！ 為了 tab complete root.f 裡寫了一堆東西都可以刪掉了。
            紀念版 is the commit af2794c "new word ?? is the alternate solution of tab completion"
    [X] 09:25 2020/08/23 把 itick 改成大小寫不分。有了 winapi 根本不用重新 compile, 直接取用 DLL 的
        StrStrIA: Finds the first occurrence of a substring within a string. The comparison is not case-sensitive. https://docs.microsoft.com/en-us/windows/win32/api/shlwapi/nf-shlwapi-strstria
        loadlibrary Shlwapi.dll
        Shlwapi.dll @ 2 winapi StrStrIA
        str ABCDEFG str efg StrStrIA --> 傳回 EFG 的開頭地址無誤。
        --> 09:58 2020/08/23 Done.
    [ ] 07:10 2020/08/29 用 SendMessage 做的 sendkey 在 Windows Terminal 無效，而且也不是真的 tab completion 再接再厲。。。
        https://docs.microsoft.com/en-us/windows/console/
        
[X] 複習怎麼直接把 printf puts getch memdump 等從 C 裡面抓來用? 可能要直接寫 .asm code 因為 __asm 已經被禁止了。
    [X] 09:58 2020/08/23 有了 winapi 很多 function 不必從 .c export 出來了。
        See my OneNote2020 > "用 KsavaVM call Windows user32.dll":
        找到了！幾乎所有 stdio stdlib functions 都在 c:\Windows\System32\msvcrt.dll   https://docs.microsoft.com/en-us/windows-hardware/drivers/develop/using-the-microsoft-c-runtime-with-user-mode-drivers-and-apps
        裡面，所以 proeforth.exe 可以任意取用他們了！
        [X] 簡化 proeforth.exe 把 loadlib winapi 的定義提前，io.c 幾乎快不用了。
        [X] online reference of Windows API
            API index portal https://docs.microsoft.com/en-us/windows/win32/apiindex/api-index-portal
            https://docs.microsoft.com/en-us/windows/win32/api/_shell/
[X] 22:09 2020/08/23 為了給 printf 各種版本改名用 alias 不適合，需要 rename command.
    loadlibrary msvcrt.dll // ( -- var ) Usage: msvcrt.dll @ 2 winapi printf rename printf2
    rename // ( <new name> -- ) Rename the last word
[X] 08:08 2020/08/24 仿 system constants 做一個 Toolkit function linked list. 用 macro 取 function name
    做成 name:entry 經過 make.bat 得到該 list. 用 create...does> 產生 toolkit class 用來產生 toolkit function words.
    使用方法為  arg1 arg2 arg3 arg4 toolkitFunction
    [X] 13:38 2020/08/24 run ProEngineerStart return -1 after a long wait.
        用 tkapi 定義 ProEngineerStart 有點冗贅, 直接 call : count entry executeCfunc 看看 <--- 可！
[X] 把 tkapi 改成自動 loop 把 tkList 全部打包成 words. new word (create) ( 'token' -- ) needed.
    [X] 13:39 2020/08/25 tkapi 取代原來的 tkapi 只做一個。
    [X] create-tk-functions // ( -- ) Create words for all toolkit functions available in toolkit.c
[X] 13:15 2020/08/22 想辦法攔截 protection errors 避免太容易當掉。
    [X] 2020/08/25 09:27:17 光 count 就會當掉！--> 用 CDB 接球成功！
        https://docs.microsoft.com/en-us/windows-hardware/drivers/debugger/
        https://hyp.is/SDbMuOZ0Eequ-ic1TgmfOw/docs.microsoft.com/en-us/windows-hardware/drivers/debugger/
        ----- 設定 CDB 為 debugger 攔截 exceptions ------
        Windows Registry Editor Version 5.00
        [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AeDebug]
        "UserDebuggerHotKey"=dword:00000000
        "Debugger"="\"c:\\Program Files (x86)\\Windows Kits\\10\\Debuggers\\x64\\cdb.exe\" -p %ld -e %ld -g"
        "Auto"="1"
    --> 同時，改良了 inCode() 擴大可用範圍。
[X] 16:12 2020/08/28 malloc get 到的 memory is safe too, 納入納入 ==> 問題是 malloc 的回傳位置真的都亂跳。
    const: vm drop --> 51298192 00000000030EBF90
    tick T hfa @   --> 47508256 0000000002D4EB20
    tick s# hfa @  --> 51360528 00000000030FB310

[x] 10:29 2020/08/25 need to get process ID --> ProEngineerConnect works fine
    Hi 厚哥，
    這兩個函數只有非同步模式才可以使用。
    上課提供的makefile可以支援exe或dll兩種編譯模式，若仔細進去看makefile的內容，
    可以發現兩種模式使用不同的Toolkit Library。上課時有提到，同步模式分別編譯成
    exe或dll，其實是使用不同的 Toolkit Library。以前有發生過，在exe中可以執行成
    功，但改成dll就不能執行的現象。
    Regards,
    Gary
    From: H.C. Chen/WHQ/Wistron
    Sent: Tuesday, August 25, 2020 3:19 PM
    To: pmpgary@gmail.com
    Cc: H.C. Chen/WHQ/Wistron <H.C._CHEN@WISTRON.COM>; Ian Tseng/WHQ/Wistron <Ian_Tseng@wistron.com>; Bryan Chen/WHQ/Wistron <Bryan_Chen@wistron.com>; Lisa HJ Liu/WHQ/Wistron <Lisa_HJ_Liu@wistron.com>
    Subject: 無法解析的外部符號 ProEngineerConnectionStart
    老師好，
    嘗試用這兩個 toolkit functions :
    ProEngineerConnect
    ProEngineerConnectionStart
    Compile 不過，錯誤如下：
    toolkit.obj : error LNK2019: 無法解析的外部符號 ProEngineerConnect 在函式 addToolKitWords 中被參考
    toolkit.obj : error LNK2019: 無法解析的外部符號 ProEngineerConnectionStart 在函式 addToolKitWords 中被參考
    ./main.exe : fatal error LNK1120: 2 個無法解析的外部符號
    手冊上比較接近的敘述是他們需要用 C++ compiler 並且說這裡 "d:\PTC\Creo 2.0\Common Files\M230\protoolkit\x86e_win64\obj" 有 sample makefile 語焉不詳，須請老師指點一二，謝謝！
[X] ProEngineerConnect 用來連上 existing Creo session 成功！
        variable random? // ( -- var ) Returned value from ProEngineerConnect
        variable ProProcessHandle // ( -- var ) Returned value from ProEngineerConnect
        null null null null 1 100 random? ProProcessHandle ProEngineerConnect ( ... -- ProError ) .s
    連上就可以直接執行 ProEngineerEnd 了，用不著 ProProcessHandle.
[X] 12:00 2020/08/25 other than tos, need a pop ( i -- n )
[X] 15:48 2020/08/25 ?? command 增加 ESC key abort
[X] 10:16 2020/08/26 用 dumpbin 把 "d:\PTC\Creo 2.0\Common Files\M230\x86e_win64\obj\"  *.dll 全部 list 出來
    使用方式: DUMPBIN [options] [files] 一起也都放到 c:\Users\8304018\Documents\GitHub\KsanaVM\DLL\
    --> 13:11 2020/08/26 Creo Parametric 沒有可以 call 的一般 .dll 用 loadllib 試過的都傳回 NULL, 改試正常 .dll 就可以。
        \ 一般的可以
        OK str: c:\Windows\System32\mfcore.dll
        OK trim loadlib
          1:      140735299387392 00007FFF7D870000
        OK str:   d:\PTC\Creo 2.0\Common Files\M230\x86e_win64\lib\gpi80.dll
        OK trim loadlib
          2:                    0 0000000000000000  <--- PTC 的就不行
        OK str: d:\PTC\Creo 2.0\Common Files\M230\x86e_win64\obj\coreutils_sh.dll
        OK trim loadlib
          2:                    0 0000000000000000  <--- PTC 的就不行
[X] 15:52 2020/08/26 用 winapi ShellAboutA 寫成 version ( -- ver ) 好了。順便把 s" w" 的問題都解了。
    這段只差 101 與行尾的 '\0' --> 故意改行尾的 '\0' 會怎樣？查 doS" 的 code . . . shit!!
    KVMdoStrQ(KsanaVm *vm) 要靠 string 的長度來算出下一個 ip 位置！當初改掉 forth 的 string
    count 結構果然出問題了。KVMStrQ KVMdoStrQ KVMdoWStrQ KVMWStrQ 都要改寫，改成第一個 4 bytes 放 string 長度。
    [X] 08:39 2020/08/26 KVMdoStrQ 改寫 on branch 'KVMdoStrQ'
        msvcrt.dll @ 3 winapi swprintf rename swprintf3
        : test
            w" P r o e f o r t h . e x e  Rev.999 is a shell developped for Creo Parametric Toolkit team.   " dup
            w" P r o e f o r t h . e x e  Rev.%d is a shell developped for Creo Parametric Toolkit team."
            101 swprintf3 drop wtype ;
        測試通過 :-D
[X] 16:05 2020/08/26 先引進 CDB debugger 的 source code debug
    成功了，改一下 makefile
    was: $(LINK) /subsystem:console -out:$(APP_EXE) /debug:none /machine:amd64 @<<longline.list
     to: $(LINK) /subsystem:console -out:$(APP_EXE) /pdb:$(APP_NAME).pdb /debug /machine:amd64 @<<longline.list
                                                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^
    was: CCFLAGS = -c -GS -fp:precise -D_WSTDIO_DEFINED
     to: CCFLAGS = /Zi -c -GS -fp:precise -D_WSTDIO_DEFINED                                                    
                   ^^^ 
    如果是 toolkit 的作業，因為 src diectory 並非 executing directory 而 /pdb option 又要指定 path 所以該項要改一下變成 /pdb:..\$(APP_NAME).pdb 
    [X] 16:56 2020/08/26 also the way to set an int3 breakpoint
        https://stackoverflow.com/questions/54540099/what-is-the-difference-between-int3-instruction-and-call-debugbreak
    [X] 加個 debugbreak command 用來簡單 trigger int3 __debugbreak() MSVC intrinsic function 讓 CDB 上手。
    [X] 進了 CDB 一查 toolkit functions 有一大堆，遠比 toolkit.c 有抓的還多得多！
        0:000> x main!ProMdl*
        00007ff7`a2211ad0 main!ProMdlOriginGet (ProMdlOriginGet)
        00007ff7`a1e040a0 main!ProMdlCopy (ProMdlCopy)
        ... snip .....
        00007ff7`a1e04220 main!ProMdlNameGet (ProMdlNameGet)
        00007ff7`a207ddb0 main!ProMdlIsEcadBoard (ProMdlIsEcadBoard)
        00007ff7`a21fda80 main!ProMdlIsVariantfeatMdl (ProMdlIsVariantfeatMdl)
        00007ff7`a1e04440 main!ProMdlToModelitem (ProMdlToModelitem)
        0:000> g
    [X] CDB 列出來的 symbol 與 proeforth 的 system constants 竟然不同！因為實際上經過了一個 jmp 故兩個等效。

        OK constants
        0000000000000065 Revision Aug 26 2020 17:09:31
        ...snip...
        00007FF7A1DF11AE KVMdoVariable()

        0:000> x main!KVM*
        ... snip ....
        00007ff7`a1df4020 main!KVMdoVariable (struct KsanaVm *)
        00007ff7`a1df6470 main!KVMRPop (struct KsanaVm *)
        00007ff7`a1df3010 main!KVMtrim (struct KsanaVm *)

        0:000>  u 00007FF7A1DF11AE
        main!ILT+425(KVMdoVariable):
        00007ff7`a1df11ae e96d2e0000      jmp     main!KVMdoVariable (00007ff7`a1df4020)
        main!ILT+430(KVMexecuteCfunc):
        00007ff7`a1df11b3 e9986e0000      jmp     main!KVMexecuteCfunc (00007ff7`a1df8050)
[X] 10:29 2020/08/25 need dos command
    msvcrt.dll has it, doc found at https://docs.microsoft.com/en-us/cpp/c-runtime-library/reference/system-wsystem?view=vs-2019
    OK str dir/s dos
     Volume in drive C has no label.
     Volume Serial Number is E437-F11C

     Directory of C:\Users\8304018\Documents\GitHub\KsanaVM

    2020/08/26  17:09    <DIR>          .
    2020/08/26  17:09    <DIR>          ..
    2020/08/08  14:26                68 .gitattributes
    2020/08/26  15:56               531 .gitignore
    2020/08/25  16:26             3,615 compiler.c
[X] 10:29 2020/08/25 need the cls clear screen command --> str cls dos 即可
[ ] 13:44 2020/08/25 need [if][else][then][begin][until][for][next]
[ ] 17:10 2020/08/25 發現 Windows Shell 有 auto completion 的 API !!!
    https://docs.microsoft.com/en-us/windows/win32/api/shldisp/nn-shldisp-iautocomplete
[X] 18:26 2020/08/27 add these TK functions for class
    KVMAddToolkit(ProDrawingDimAttachpointsGet ,4, "Free this result using ProDimattachmentarrayFree().");
    KVMAddToolkit(ProDrawingDimAttachsGet      ,4, "no help yet");
    KVMAddToolkit(ProSelectionModelitemGet     ,2, "no help yet");
    KVMAddToolkit(ProSelect                    ,8, "no help yet");
    KVMAddToolkit(ProSelectionCopy             ,2, "no help yet");
    KVMAddToolkit(ProDrawingDimCreate          ,6, "no help yet");
    KVMAddToolkit(ProArrayAlloc                ,4, "no help yet");
    KVMAddToolkit(ProArrayFree                 ,1, "no help yet");
    KVMAddToolkit(ProSolidDimensionVisit       ,5, "no help yet");
    KVMAddToolkit(ProDimensionShow             ,4, "no help yet");
    KVMAddToolkit(ProDrawingDimensionViewGet   ,3, "no help yet");
    KVMAddToolkit(ProMousePickGet              ,3, "no help yet");
    KVMAddToolkit(ProAnnotationShow            ,3, "no help yet");
    KVMAddToolkit(ProSolidFeatVisit            ,4, "no help yet");
    KVMAddToolkit(ProFeatureGeomitemVisit      ,5, "no help yet");
    KVMAddToolkit(ProSelectionAlloc            ,3, "no help yet");
    KVMAddToolkit(ProSelectionViewGet          ,2, "no help yet");
    KVMAddToolkit(ProDrawingViewOutlineGet     ,3, "no help yet");
    error C2065: 'ProDrawingDimAttachpointsGet' : 未宣告的識別項          #include <ProDrawing.h> <--- yes!!
    error C2065: 'ProDrawingDimensionViewGet' : 未宣告的識別項
    toolkit.c(92) : error C2065: 'ProMousePickGet' : 未宣告的識別項
    toolkit.c(93) : error C2065: 'ProAnnotationShow' : 未宣告的識別項     #include <ProAnnotation.h>
    error C2065: 'ProDrawingViewOutlineGet' : 未宣告的識別項
    --> 都只是 include .h 的問題。

[X] 15:19 2020/08/28 複習，如何分辨 code word vs colon word ? CFA 的位置區段不同
    OK str word (tick) dump
                      0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
    00000000030EDDA0 77 6F 72 64 00 00 00 00 00 00 00 00 00 00 00 00  word............
    00000000030EDDB0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
    00000000030EDDC0 F5 10 0F E5 F6 7F 00 00 D0 31 B1 E6 F6 7F 00 00  o..ao...D1±ao...
                     ^^^^^^^^^^^^^^^^^^^^^^^ code word
    OK str ProEngineerStart (tick) dump
                      0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
    00000000030EF7B0 50 72 6F 45 6E 67 69 6E 65 65 72 53 74 61 72 74  ProEngineerStart
    00000000030EF7C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
    00000000030EF7D0 20 1D 0F 03 00 00 00 00 20 4D B1 E6 F6 7F 00 00   ....... M±ao...
                     ^^^^^^^^^^^^^^^^^^^^^^^ colon word
[X] ProError is 0 , ok but iSelCount 的傳回值很奇怪
        OK iSelCount @ . cr
        -1080855033123174414
        OK
    [X] 查 ProSelect 複習 tkList words 的結構，特別是 Toolkit function 的 entry address
        breakpoint
        0:000> x main!ProSelect
        00007ff6`be1f7010 main!ProSelect (ProSelect) <--- 查到了 entry 結果實際跑的抓錯了，因為 tk command 裡面用 indexof 只比 partial name 不對
        OK tick ProSelect dump
                          0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
        000000000347F510 50 72 6F 53 65 6C 65 63 74 00 00 00 00 00 00 00  ProSelect.......
        000000000347F520 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
        000000000347F530 70 1B 48 03 00 00 00 00 A0 51 C0 BF F6 7F 00 00  p.H......Q......
                         ^^^^^^^^^^^^^^^^^^^^^^^ CFA 指向 tkList 裡面某個 item

        以下就是 tkList [does>:8][count:8][entry:8] . . .

        OK hex: 70 1B 48 03 00 00 00 00 dump  \ does> r@ @ ( count ) r> 8 + @ ( entry ) executeCfunc ret
                          0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
        0000000003481B70 08 18 48 03 00 00 00 00 02 00 00 00 00 00 00 00  ..H.............
                         ^^^^^^^^^^^^^^^^^^^^^^^ does> of main!ProSelectionViewGet: 00007ff6`be1f6f50 <---- Problem!!!
                                                 ^^^^^^^^^^^^^^^^^^^^^^^ count
        0000000003481B80 50 6F 1F BE F6 7F 00 00 08 18 48 03 00 00 00 00  Po........H.....
                         ^^^^^^^^^^^^^^^^^^^^^^^ entry
                                                 ^^^^^^^^^^^^^^^^^^^^^^^ does> of main!ProSelectionModelitemGet: 00007ff6`be1f6ec0
        0000000003481B90 02 00 00 00 00 00 00 00 C0 6E 1F BE F6 7F 00 00  .........n......
                         ^^^^^^^^^^^^^^^^^^^^^^^ count
        0000000003481BA0 08 18 48 03 00 00 00 00 04 00 00 00 00 00 00 00  ..H.............
                         ^^^^^^^^^^^^^^^^^^^^^^^ does> of main!ProDrawingDimAttachsGet: 00007ff6`be1ec030
                                                 ^^^^^^^^^^^^^^^^^^^^^^^ count
        0000000003481BB0 30 C0 1E BE F6 7F 00 00 08 18 48 03 00 00 00 00  0.........H.....
                                                 ^^^^^^^^^^^^^^^^^^^^^^^ does> of main!ProDrawingDimAttachpointsGet: 00007ff6`be20c1d0
        0000000003481BC0 04 00 00 00 00 00 00 00 D0 C1 20 BE F6 7F 00 00  .......... .....

    [X] 13:24 2020/08/28 也複習一下 winapi words 的結構
        OK msvcrt.dll @ 1 winapi malloc
        OK tick malloc dump
                          0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
        0000000003EAF960 6D 61 6C 6C 6F 63 00 00 00 00 00 00 00 00 00 00  malloc..........
        0000000003EAF970 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
        0000000003EAF980 38 1E EB 03 00 00 00 00 A2 E4 2B A6 F7 7F 00 00  8.........+.....

        OK hex: 38 1E EB 03 00 00 00 00 dump
                          0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
        0000000003EB1E30                         E6 10 78 A4 F7 7F 00 00          ..x.....
                                                 ^^^^^^^^^^^^^^^^^^^^^^^ KVMdoWinapi
        0000000003EB1E40 30 9D F7 A5 FF 7F 00 00 01 00 00 00 00 00 00 00  0...............
                         ^^^^^^^^^^^^^^^^^^^^^^^ entry
                                                 ^^^^^^^^^^^^^^^^^^^^^^^ arguemnt count
        如果故意亂寫，當場會有 Error message
        msvcrt.dll @ 1 winapi mallocccccc
        Error: failed to load winapi 00007FFFA5F60000 mallocccccc
[X] 16:37 2020/08/28 code word strncpy 可以拿掉了-->不行， rename 在 winapi 之前就要定義好。
[X] 16:58 2020/08/28 嘗試用 printf scanf 了解 double float
    \ 查看 point3d 需要了解 C double type
    OK str %lf random scanf2
    3.14159265358
    OK random @ .s
    Data stack:
      5:  4614256656552023796 400921FB5443D6F4
    OK str %f hex 400921FB5443D6F4 printf2 drop cr
    3.141593
    
[X] 20:18 2020/08/30 研究 ProArrayAlloc & ProArrayObjectAdd 

    OK help ProArrayAlloc
     ( int/n_objs int/obj_size int/reallocation_size , ProArray* -- ProError )
     
    # variable pa 4 8 1 pa ProArrayAlloc --> 0 0000000000000000
    # pa @ dump
                      0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
    0000000003BEDDD0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
    0000000003BEDDE0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

    這時候若增加會怎樣?
    OK help ProArrayObjectAdd
     ( ProArray*/the_array   int/index|-1 int/n_objects void*/p_object -- ProError ) http://localhost:8800/Creo_3.0_Toolkit_Doc/protkdoc/api/133.html
    # pa -1 4 ( 故意用 pa 處的 addr 正好是 8 bytes data ) pa ProArrayObjectAdd --> 0 0000000000000000
    # pa @ dump
                      0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
    0000000003BEDDD0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
    0000000003BEDDE0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
    0000000003BEDDF0 D0 DD BE 03 00 00 00 00 00 00 00 00 00 00 00 00  DY?.............
    0000000003BEDE00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
    
    想必是從指定的位置 void*/p_object pa copy 4 個 8 bytes object 過去的 <--- Yes! 
    OK pa dump 
                      0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
    0000000003673C20                         D0 DD BE 03 00 00 00 00          DY?.....
    0000000003673C30 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
    0000000003673C40 00 00 00 00 00 00 00 00 
    
    不信再試一次，這回用 tick + cfa 當 void*/p_object : 
    
    # pa -1 4 # tick + cfa ( void*/p_object ) # ProArrayObjectAdd --> 0 0000000000000000
    # pa @ dumpn 100
    
    確定了！
[ ] 18:00 2020/08/29 到處當，遇到 unknown command 應該要中斷執行，否則執行下去撞上 toolkit 多半會當掉。
    [X] 10:53 2020/08/31 有了 safe? 之後，改寫 @ ! c@ c! fill memdump 都不檢查了，否則太多地方分別檢查，改用 safe?
        在 root.f 裡改寫以上各個 words, 如此一來只有 safe? 單一 word 負責全部檢查工作。
        15:26 2020/08/31 結果 branch tryAgainDrwEx21_utilities 
            1. tab sth 當掉! --> 簡化到 itick 就當了。
            2. 如果把 : safe? ; 這樣點掉就會當在 create-tk-functions
        --> 把 safe? 從 root.f 裡拿掉 ... 都點掉了，還是一樣跑 tab aaa 就當
            這時候 toolkit.c 已經有 DrwEx21.c 的 code 了，若有關也很奇怪。。
        --> 還是退回 master 重來好了。。。
            master 只換 io.c --> ok 
            master 加換 string.c --> tab aa --> ok 
            master 加換 var.c --> tab aa --> ok 
        RI: 只要 : @ safe? @ ; 這樣重新定義 tab 就會當 --> 簡化到 0 str aa itick 就會當 
            --> 因為 tos rtos 這兩個 word 都有用到 @ 而 @ 重新定義過會影響到它自己的 rstack 深度！
                所以 tos rtos 的測試方法要記得(如下)，非常敏感。    
                : rtos-test 
                    11 >r 22 >r 33 >r 44 >r 
                    2 rtos . cr 
                    r> drop r> drop r> drop r> drop 
                    ;
                本應拿到 22 結果拿到的是 33 表示要多減一 --> 藉此修改 rtos 的調整常數，好了！
    
[X] 16:49 2020/08/31 測試 GaryWei utility 傳回值預期是 string 結果很奇怪：
        OK 3 UserDimTypeToStr .s
        Data stack:
          0:           -188331128 FFFFFFFFF4C64B88
    debug tklist functions 的方法 
        1. 先用 toolkits command list all toolkit functions, check UserDimTypeToStr entry looks good
        2. OK tk: UserDimTypeToStr .s   ( <name> -- entry count help T|F )
            Data stack:
              0:      140698617909483 00007FF6F32410EB <--- entry 
              1:                    1 0000000000000001 <--- arg count 
              2:      140698645324968 00007FF6F4C664A8 <--- help 
              3:                    1 0000000000000001
           OK 140698645324968 type --> ( ProDimensiontype/hDimensiontype -- str )OK
        3. 用 executeCfunc ( count entry -- ... ) Run time of C functions
           直接執行看看 --> 結果真的就是這樣。。。 
                OK dropall 3 1 140698617909483 executeCfunc .s
                Data stack:
                0:           -188331168 FFFFFFFFF4C64B60
                OK 3 UserDimTypeToStr .s
                Data stack:
                0:           -188331168 FFFFFFFFF4C64B60
                1:           -188331168 FFFFFFFFF4C64B60
        4. 到它裡面去 printf 來看
            OK 3 UserDimTypeToStr .s
            ss is 7FF7B73C4B60 <--------------------- 裡面是對的
            Data stack:
              0:          -1220785312 FFFFFFFFB73C4B60 <---- 出來就錯了
            OK        
           問題出在: typedef int (*func1)(__int64);  // the execution vector
                             ^^^ 這個錯了，應該是 __int64 
           --> winapi 裡的 typedef int (*DLL3)(__int64,__int64,__int64);  // the execution vector
               也一併改好          ^^^
        17:32 2020/08/31 Done!
        
[X] 18:14 2020/08/31 proeforth.exe crash now, I thought it caused by safe? changes but it's not! 
    Root cause is the known problem in KsanaVM ... the deep call issue. I fixed it again now! 
    See FigTaiwan group : https://groups.google.com/g/figtaiwan/c/l24RIwnpjv0/m/E4PxNMcJAwAJ
    See evernote: 小葉老師的 KsanaVM Forth 以及 KVMCall deep call issue 的可能解法
        
[X] 21:07 2020/08/27 start tying exercises : DrwEx21 , exciting !!! --> 16:47 2020/09/01 done DrwEx21.f 
[X] 14:28 2020/09/01 超過了 #define KVM_MAXWORD 256 先改成 1000 將來改成 linked list 避免再有問題。

[ ] 08:43 2020/09/02 msvcrt.dll 有 atof atoi atol 所以 hex 可以改寫或不用了。
[ ] 08:56 2020/09/02 從 CDB 0:000> x main!Pro* 看來，所有的 Toolkit functions 好像都抓進來了！似乎不必一一用
    KVMAddToolkit() 去加！
    00007ff7`8903b768 main!PRO_OS_TYPE = 0x00007ff7`87d2a0b0 "WIN32"
    00007ff7`8903b770 main!PRO_MACHINE_TYPE = 0x00007ff7`87cf97d8 "x86e_win64"
    00007ff7`87a27250 main!Process_Kill_nsb (void *)
    00007ff7`87a28e20 main!Process_Wait_nsb (void *, long *, bool, bool)
    00007ff7`87a27360 main!Process_WaitExitCode (void *, long *)
    00007ff7`879e6d40 main!Process_GetCurrentId_sb (void)
    ... snip ... 共有 4815-2+1 個！！
    這些 entry point 都是固定的，所以可以用 .f 來 include 即可。
    --> 試一版不含 Proxxx 的 toolkit.c 看看。。。如下，只剩 22.5 kbytes 而已！
        簡單只把 KVMAddToolkit() 都拿掉而已，Gary Wei 的 UserXXXX() 都還在，也就是說，<ptc toolkit>.h 有用到
        只是沒有用到 obj lib 就可以了。
        2020/09/02  10:03           225,280 main.exe  <--- 22.5kbytes 
                   1 File(s)        225,280 bytes
                   0 Dir(s)  223,616,000,000 bytes free
    --> 再試一版，只用一行 KVMAddToolkit() 的看看。。。馬上變成 29.1M
        2020/09/02  10:08        29,153,792 main.exe  <--- 29.1MegaBytes
                   1 File(s)     29,153,792 bytes
                   0 Dir(s)  223,571,968,000 bytes free    
        --> 用 CDB 查看它肚子裡有多少 tk functions . . . 
    --> 問題一、只用一行 KVMAddToolkit() 的比 master branch 的少一點！所以 KVMAddToolkit() 不能只放一行。
        問題二、ProXXX functions 的 entry point 隨 built 版本會變。
    --> 嘗試讓 makefile 吐出 mapfile 
        $(LINK) /subsystem:console -out:$(APP_EXE) /pdb:$(APP_NAME).pdb /debug /map /machine:amd64 @<<longline.list
                                                                               ^^^^ 
    --> 結果產生 4Mega 的 main.map 文字檔，有了 map 檔如虎添翼呀！一堆程式都不用寫了，直接從 .map 檔裡找來用就可以。
        --> 11:44 2020/09/02 可惜研究不出來怎麼換算 .map 的 info 成 run time 的 address. 
    --> 還是用手工
        x main!KVM*
        x main!Pro*
        來取得好了。

[X] 13:47 2020/09/02 改寫 --> 用長度來打印 '\0' 都印成 space 
    : ==>   
        ntib 0 do 
            tib i + c@ ?dup if emit else space then 
        loop space dup . .q cr ;

[X] 21:09 2020/12/10 proeforth.exe 為了接受 DrwEx22.c 的挑戰，要回想當初 Web.Link 的 DLL 怎麼 export 的？
[X] 09:04 2021/03/11 為何本 log 裡沒有 proeforth 的 binlingual repl 的記錄？乾脆抄相關的 code 來做個記錄：
    </div><!-- outputbox -->
    <textarea id="inputbox" cols=100 rows=2></textarea><a id=jump2endofinputbox href="#endofinputbox"></a>
    <span id=endofinputbox class=std><input type="radio" id="forthbtn" value="forth" name="lang"><label class=std>FORTH</label> <input type="radio" id="jsbtn" value="js" name="lang"><label class=std>JavaScript</label> - A bilingual programmer's console, try 'help'.</span>
    </div><!--console3we-->

    vm.consoleHandler = function(cmd) {
        window.lang = forthbtn.checked ? 'forth' : 'js';
        if (window.lang == 'js' || window.lang != 'forth'){
            type((cmd?'\n> ':"")+cmd+'\n');
            result = eval(cmd);
            if(result != undefined) type(result + "\n");
            vm.scroll2inputbox(); inputbox.focus();
        }else{
            var rlwas = vm.rstack().length; // r)stack l)ength was
            type((cmd?'\n> ':"")+cmd+'\n');
            vm.dictate(cmd);  // Pass the command line to KsanaVM
            (function retry(){
                // rstack 平衡表示這次 command line 都完成了，這才打 'OK'。
                // event handler 從 idle 上手，又回到 idle 不會讓別人看到它的 rstack。
                // 雖然未 OK, 仍然可以 key in 新的 command line 且立即執行。
                if(vm.rstack().length!=rlwas)
                    setTimeout(retry,100);
                else {
                    type(" " + vm.prompt + " ");
                    if ($(inputbox).is(":focus")) vm.scroll2inputbox();
                }
            })();
        }
    }

[ ] 09:04 2021/03/11 仿照 proeforth.htm 的方式提供 jeforth.3we .兩種 repl 的選擇 forth and JavaScript 
[ ] 09:04 2021/03/11 proeforth 的 binlingual repl 在 chrome maximum 時跑到 inputbox 底下去了，看不到。
    [ ] 09:17 2021/03/11 jeforth.3we, proeforth.html 用到 window.scrollTo(0,endofinputbox.offsetTop) 都改成 vm.scroll2inputbox() 好像應該要這樣。我在研究為何 proeforth.html bilingal line at the button 當 chrome maximum 時看不見。
[ ] 09:20 2021/03/11 整個 jeforth.3we & proeforth.hhtml 的 CSS 都應該要修整，考慮用 bootstrap？
