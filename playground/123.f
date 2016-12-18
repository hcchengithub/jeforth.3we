"" value TIB
0  value  nTIB
js> tib to TIB js> ntib to nTIB *debug* 00>>

    \ developing new include and friends
js> tib to TIB js> ntib to nTIB *debug* 222>>

    : prioritize ( vid -- ) \ Make the vocabulary first priority
        js> order.indexOf(tos()) ( vid i ) 
        js> tos()==-1 ?abort" Error! unknown vocabulary." ( vid i )
        js> order.splice(pop(),1);order.push(pop()) ;
        /// works fine!
        
js> tib to TIB js> ntib to nTIB *debug* 333>>
    \ Get .f module file name left by include command
    : get-module-name ( -- "name" ) \ include command inserts it before ntib
        char -=pathname[ js> tib.slice(0,ntib).lastIndexOf(tos()) ( pattern i )
js> tib to TIB js> ntib to nTIB *debug* 77>>
        dup -1 = ?abort" Error! ~.f pathname start mark not found." ( pattern i )
        swap :> length + ( i0 ) char ]pathname=- ( i0 pattern )
        js> tib.slice(0,ntib).lastIndexOf(pop()) ( i0 i )
        dup -1 = ?abort" Error! ~.f pathname end mark not found." ( i0 i )
        js> tib.substring(pop(1),pop()) ;
    : header ( -- 'head' ) \ ~.f common header
        EOF :> pattern <text>
            \ ~.f common header
            ?skip2 _eof_ \ skip it if already included
            dup .( Including ) . cr char -- over over + +
            js: tick('<selftest>').masterMarker=tos()+"selftest--";
            also forth definitions (marker) (vocabulary)
            last execute definitions
            <selftest>
                js> tick('<selftest>').masterMarker (marker)
            </selftest>
        </text> :> replace("_eof_",pop()) ; private
    
    : tailer ( -- 'tailer' ) \ ~.f common tailer
        <text> 
            \ ~.f common tailer
            <selftest>
            js> tick('<selftest>').masterMarker tib.insert
            </selftest>
            js> tick('<selftest>').enabled [if] js> tick('<selftest>').buffer tib.insert [then]
            js: tick('<selftest>').buffer="" \ recycle the memory
        </text> ; private
js> tib to TIB js> ntib to nTIB *debug* 333>>        
    : source~ ( "mname" -- ) \ source code header
        \ Check if the module is included already
js> tib to TIB js> ntib to nTIB *debug* 22>>
        dup (') ( mname w )
        if  \ already included ( mname ) 
js> tib to TIB js> ntib to nTIB *debug* 66>>
            *debug* 456> prioritize
        else 
            \ not included yet ( mname )
                drop
js> tib to TIB js> ntib to nTIB *debug* 88>>
            \ cut after EOF 
                js> tib.slice(ntib).indexOf(vm.g.EOF.pattern) ( ieof )
                dup -1 = ?abort" Error! EOF mark not found." ( ieof )
                js> ntib + ( ieof ) \ insert selftest section tail here
                js> tib.slice(ntib,pop()) ( tib[ntib ~ before EOF] ) 
js> tib to TIB js> ntib to nTIB *debug* 99>>
            \ append the tailer
js> tib to TIB js> ntib to nTIB *debug* aa>>
                tailer + ( tib[ntib ~ before EOF]+tailer ) 
js> tib to TIB js> ntib to nTIB *debug* bb>>
            \ append the EOF
                s" \ "  EOF :> pattern + js> '\n' + + ( tib[ntib~beforeEof+tailer+EOF] )
js> tib to TIB js> ntib to nTIB *debug* cc>>
            \ wrap up the tib
                js> tib.slice(0,ntib) swap + js: tib=pop()
js> tib to TIB js> ntib to nTIB *debug* dd>>
                header tib.insert 
        then ;

js> tib to TIB js> ntib to nTIB *debug* 55>>

char 123.f source~

\  磁碟區 C 中的磁碟沒有標籤。
\  磁碟區序號:  7C0C-0BD2
\ 
\  c:\Users\hcche\Documents\GitHub\jeforth.3we\playground 的目錄
\ 
\ 2016/12/11  09:17    <DIR>          .
\ 2016/12/11  09:17    <DIR>          ..
\ 2016/12/11  09:17                 0 123.f 

cr .( -------- check TIB and nTIB if you want to -------- ) cr
js> tib to TIB js> ntib to nTIB *debug* 99>>

.( I am visible )

-=EOF=- 

.( I am invisible because EOF has blocked me )
