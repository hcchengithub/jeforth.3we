
    \ Skype4com COM document
    \ http://users.skynet.be/fa258239/bestanden/skype4com/skype4com.pdf
    

    <vb>
    Set skype = GetObject("","skype4com.skype")
    vm.push(skype)
    </vb> constant skype // ( -- obj ) The skype4com COM object

    : skype.isRunning skype :> Client.IsRunning ; // ( -- boolean ) 
    : skype.start ( -- ) \ start running the skype client 
        skype.isRunning if else skype :: Client.Start() then ;
        /// None blocking command, you need to check status before using it.
    
    : skype.attach ( -- ) \ attach the bot to skype
        skype :: Attach() ; 
        
    : skype.attachmentStatus ( -- statusCode ) \ check status code
        skype :> AttachmentStatus ;

    : skype.Convert.TextToAttachmentStatus ( "TOKEN" -- statusCode )
        skype :> Convert.TextToAttachmentStatus(pop()) ;
        /// -1 means unknown token

    \ 執行 ok 但不知在幹嘛    
    \   skype js: tos().SendCommand(pop().Command(0,"PING","PONG",true)) 
    \   skype js: tos().SendCommand(pop().Command(0,"PING"))

    : skype.CurrentUserHandle ( -- "skypeID" ) It returns "h.c.chen" for me
        skype :> CurrentUserHandle ; 

    \ 這個成功，好多！
    skype :> Messages.Count \ ==> 1526 (number)
    
    \ No error, but prints nothing
    <comment>
        skype <vb>
        set oSkype = vm.pop()
        vm.type("Active chats:"&VBCRLF) ' 這有點特別，我都忘了
        For Each oChat In oSkype.ActiveChats
            vm.type(oChat.Timestamp & " " & oChat.Name & " " & oChat.FriendlyName & VBCRLF)
        Next
        </vb>
    </comment>
    
    <comment>
        \ 這個 loop 第一個就是我自己，但是我自己不會有我自己的 chat, 出錯可能因此 <-- 猜錯！
        \   oChat.Name --> #h.c.chen/$eugene.chin95;24270a00c9f054a7
        \   oChat.Timestamp    --> VBscript error :  Invalid chat name
        \   oChat.FriendlyName --> VBscript error :  Invalid chat name

        skype <vb>
        set oSkype = vm.pop()
        c = 0
        vm.type("All chats:"&VBCRLF)
        For Each oChat In oSkype.Chats
            If c = 2 Then
                vm.type(oChat.Name & VBCRLF)
                vm.type(oChat.Timestamp & VBCRLF)
                vm.type(oChat.FriendlyName & VBCRLF)
            End If
            c = c + 1
        Next
        </vb>
        All chats:
        #h.c.chen/$eugene.chin95;24270a00c9f054a7
    </comment>

    <comment>
        skype <vb>
        set oSkype = vm.pop()
        ' For Each oChat In oSkype.Chats
        ' For Each oChat In oSkype.ActiveChats
        ' For Each oChat In oSkype.MissedChats
        For Each oChat In oSkype.RecentChats
        ' For Each oChat oSkype.BookmarkedChats
            vm.type(oChat.Name & VBCRLF)
        Next
        </vb>
    </comment>

        > skype <vb>
        set oSkype = vm.pop()
        Set oUser = oSkype.User("echo123")
        vm.push(oUser)
        </vb> constant oUser // ( -- obj ) skype echo123 echo'er

         OK 
        > oUser :> OnlineStatus tib.
        oUser :> OnlineStatus \ ==> 1 (number)
         OK 
        > oUser :> handle . 
        echo123 OK 
        > oUser skype :> Convert.OnlineStatusToText(pop().OnlineStatus) tib.
        oUser skype :> Convert.OnlineStatusToText(pop().OnlineStatus) \ ==> Online (string)
         OK 
 
        oUser skype <vb>
        set oSkype = vm.pop()
        set oUser = vm.pop()
        Set oCall = oSkype.PlaceCall(oUser.Handle)
        vm.push(oCall)
        </vb> constant oCall \ 成功！ call 上了語音測試系統。

        > oCall :> status tib.
        oCall :> status \ ==> 7 (number)  掛掉之後的 status

        \ 不知幹啥的
        skype <js> tos().SendCommand(tos().Command(5,"GET USER echo123 DISPLAYNAME", "USER echo123 DISPLAYNAME", true))</jsV> \ ==> undefined (undefined)
        skype <js> tos().SendCommand(pop().Command(3, "GET CURRENTUSERHANDLE", "CURRENTUSERHANDLE", true)) </jsV> \ ==> undefined (undefined)
    

stop








    > skype :> Client.Start() \ 真的就 Activate Skype Client 了！

    > skype :> friends 
    > .s
          0: undefined (undefined)
          1: [object Object] (object) \ 要用 enum 看
          
    > dup Enumerator
    > .s
          0: undefined (undefined)
          1: [object Object] (object) \ skype.friends collection
          2: [object Object] (object) \ skype.friends enumerator
    > constant friends // ( -- enumerator ) my skype friends

    friends <js>
    enum = pop()
    while(!enum.atEnd()){
        type(enum.item().Name + '\n')
        enum.moveNext()
    }
    </js>


