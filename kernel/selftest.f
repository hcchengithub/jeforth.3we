<text>
    ~%~%~%~%~%~%~%~   S e l f - t e s t   e x a m p l e s   ~%~%~%~%~%~%~%~

O   最原始的 *** 最簡單，靠結尾的 ==>judge 在 wut 及螢幕上打 pass/failed!。請看範例。。。

    <selftest>
        *** int 3.14 is 3, "12.34AB" is 12 ...
        3.14 int 3 =
        char 12.34AB int 12 =
        and
        ==>judge drop \ 沒有用到時，把留給 all-pass 的 flag drop 掉。
    </selftest>

O   四顆星的 **** 用在一次 test 好幾個 words 時，不用 wut 改用 all-pass。下面範例把螢幕關
    掉是本方式的常態。如果不想用 selftest-invisible 隱藏螢幕，則 ==>judge 打 pass/failed!
    就不確定打在哪裡了，不好看。這時要改用下面介紹的五顆星的方式。本方式自動把 wut 指向 
    dummy，不用擔心 ==>judge 寫錯人。

    <selftest>
        marker -%-%-%-%-%-
        **** word1 word2 word3 descriptions ... \ [pass|failed] 會由 ==>judge 打上
        selftest-invisible \ 我想讓畫面整潔，self-test 的過程可以看 kvm.screenbuffer。
        js> kvm.screenbuffer.length constant start-here // ( -- n ) 開始測試前的 kvm.screenbuffer 尾巴。
        ( ------------ Start to do anything --------------- )
        ( ------------ done, start checking ---------------- )
        start-here <js> kvm.screenbuffer.slice(pop()).indexOf("期望出現的 string")!=-1 </jsV> \ true
        selftest-visible
        js> stack.slice(0) <js> [0x11,0x22,0x33,0x44] </jsV> isSameArray >r dropall r>
        ==>judge [if] <js> [
            'word-name-1',
            'word-name-2'
        ] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
        -%-%-%-%-%-
    </selftest>

O   五顆星的 ***** 利用 HTML5.f 可以回頭打 pass/failed 適用於 selftest 直接當 demo 程式 。。。
    不用 ==>judge 改用 -->judge 才有這新功能。示範如下，

    <selftest>
        ***** Selftest item description ........
        marker -%-%-%-%-%-
        js> kvm.screenbuffer.length constant start-here // ( -- n ) 開始測試前的 kvm.screenbuffer 尾巴。
        ( ------------ Start to do anything --------------- )
        ( ------------ done, start checking ---------------- )
        start-here <js> kvm.screenbuffer.slice(pop()).indexOf("期望出現的 string")!=-1 </jsV> \ true
        js> stack.slice(0) <js> [true,11,22,33,false] </jsV> isSameArray >r dropall r>
        -->judge [if] <js> [
            'word111',
            'word222',
            'word333'
        ] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
        -%-%-%-%-%-
    </selftest>

</text> ' <selftest> :: comment=pop()

    0 value wut // ( -- Word ) Word under test

    : ==>judge      ( boolean -- boolean ) \ print 'pass'(if true) or 'failed!' and stop testing.
                    if ." pass" cr wut :: selftest='pass' true
                    else ." failed!" cr wut :: selftest='failed!' \s then ;

    : ***           ( <name> <description down to '\n'> -- ) \ Start to test ONE word
                    BL word dup (') to wut char \n|\r word ( -- "name" "descriptions ..." )
                    ." *** " swap . space 1 sleep \ desc
                    wut if . else drop ." unknown?" cr abort then
                    depth ?abort" *** Error! Data stack is not empty!" ;
                    /// Prepare the wut, check stack should be empty at beginning.
                    /// ==>judge will mark the word.selftest='pass' or 'failed!'

    : ****          ( <description down to '\n'> -- ) \ Print header of a self-test section
                    ['] *** to wut \ dummy wut
                    s" *** " char \n|\r word + . cr
                    depth ?abort" *** Error! Data stack is not empty!" ;
                    /// Only print the header. Your test program has to take care of everything.

\ If html5.f has been included then selftest can show pass/faled a little better
\ therefore we may not need to use selftest-invisible command. This is good for
\ wmi.f self test. Because they are actually demos that are better to be visible.

' <o> [if]

    0 value eleHeader // ( -- element ) The recent self-test header line HTML element

    : -->judge      ( boolean -- boolean ) \ print 'pass'(if true) or 'failed!' and stop testing.
                    if
                        eleHeader <js> pop().innerText+=" pass" </js>
                        true
                    else
                        eleHeader <js> pop().innerText+=" failed!" </jsV>
                        false js: alert(pop(1));
                    then ;

    : *****         ( <description down to '\n'> -- ) \ Print header of a self-test section
                    char <div> s" *** " char \n|\r word                 \ entire line
                    <js> pop().replace(/\s*\.*\s*$/," ... ") </jsV> +   \ replace ending "...." to " ... "
                    js> kvm.plain(pop()) +                              \ convert HTML special characters
                    char </div> +
                    </o> to eleHeader
                    depth ?abort" *** Error! Data stack is not empty!" ;
                    /// Use "-->judge" command to print pass/failed!
[then]

code all-pass   ( ["name",...] -- ) \ Pass-mark all these word's selftest flag
                var a=pop();
                for (var i in a) {
                    var w = tick(a[i]);
                    if(!w) panic("Error! " + a[i] + "?\n");
                    else w.selftest='pass';
                }
                end-code

js> print constant printwas // ( -- print ) Save a backup of the original print function.

code selftest-invisible
                ( -- ) \ Turn off display output
                kvm.print=print=function(s){kvm.screenbuffer += s;}
                end-code

: selftest-visible
                ( -- ) \ Turn display output back on
                printwas <js> kvm.print=print=pop() </js> ;

