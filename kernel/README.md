
> Written with [StackEdit](https://stackedit.io/).

A minimum Forth kernel
======================
#en
jeForth was first invented by FigTaiwan Mr. Yap and Sam Suan Chen during end of 2011. It's a very simple way to develop your own Forth system anywhere JavaScript is available -- Web page, HTA, Node.js, Node-Webkit, and Windows DOS box. 

#demo
Sample program baby.html is a very simple demo. 
Sample program cub.html has most forth words. 
Use Google Chrome to run them.

jeforth.js is the only file in this project. The below two lines generate a Forth Virtual Machine on your web page in HTML:

    <script src="./jeforth.js"></script>
    <script> vm = new jeForth(); </script>

Now we have an object 'vm' which is the Forth virtual machine that has only two Forth words 'coce' and 'end-code'. Use the two words to create your own entire Forth system then. 

#tutorials and documents
Find tutorials and documents in [the wiki](https://github.com/hcchengithub/project-k/wiki).

#quick reference

Get the jeforth VM up and running,

**a.** For HTML, HTA, and Node-webkit:

    <script src="./jeforth.js"></script>
    <script> vm = new jeForth(); </script>

**b.** For Node.js and Node-webkit:

    jeForth = require("./jeforth.js").jeForth;
    vm = new jeForth();

**c.** For WSH cscript.exe:

    eval(readTextFile(".\\jeforth.js"));
    vm = new jeForth();
    /* readTextFile() is not cscript.exe built-in, you need to write it */

#real thing
[jeforth.3we](http://github.com/hcchengithub/jeforth.3we) is this project's predecessor that has developed completely. You can use it to do real things. The bast way to learn Forth is to create your own Forth. So I rejuvenate jeforth.3we back to it's kernel, the jeforth.js source code, for people to develop their own Forth system from a higher starting point.

#participation

Any suggestion or question, use the 'issues' and 'wiki' on this GitHub repository, raise them to [the FigTaiwan forum](https://groups.google.com/forum/?hl=zh-TW#!forum/figtaiwan) or email me at hcchen5600@gmail.com. 

###Happy programming !

#tw
整理 FigTaiwan 用 JavaScript 寫成的 Forth VM, 只專注在 kernel 使它能在所有的 application （HTML, Node.js, Node-webkit, WSH, HTA）通用。這會使得 kernel 更精簡、易懂。說明稿直接放在 GitHub > project-k > Wiki 供參與者編輯。也可以透過 GitHub > project-k > issues 追蹤討論單項問題。

