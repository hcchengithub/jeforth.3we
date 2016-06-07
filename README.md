j e f o r t h . 3 w e
==============
**Forth** is the simplest programming language ever. The jeforth.**3we** project is an implementation based on a **3 Words Engine** from [project-k](http://github.com/hcchengithub/project-k) for many applications: *HTA (jeforth.3hta)*, *HTML (jeforth.3htm)*, *Chrome Extension (jeforth.3ca)*, *Node.js (jeforth.3nd)*, *Node-webkit or NW.js (jeforth.3nw)*, and probably more in the future. All of them have been tested on Windows 8 or Windows 10.

Play now
===========
Among the many applications, jeforth for web page (jeforth.3htm) can run on your web browser right now thus is good for demonstration. 

#### [Solar system](http://rawgit.com/hcchengithub/jeforth.3we/master/index.html?cls_include_solar-system.f)
![enter image description here](https://github.com/hcchengithub/jeforth.3we/wiki/pictures/solar-system.png)

#### [H2O](http://rawgit.com/hcchengithub/jeforth.3we/master/index.html?cls_include_h2o.f)
![enter image description here](https://github.com/hcchengithub/jeforth.3we/wiki/pictures/h2o.png)

#### [Alarm clock](http://rawgit.com/hcchengithub/jeforth.3we/master/index.html?cls_include_alarm.f_er)
 ![enter image description here](https://github.com/hcchengithub/jeforth.3we/wiki/pictures/demo-alarm.png)
 
#### [Box2Dweb Physics Engine demo - Arrows](http://rawgit.com/hcchengithub/jeforth.3we/master/index.html?cls_include_box2dweb-arrow.f)
![enter image description here](https://github.com/hcchengithub/jeforth.3we/wiki/pictures/demo-arrow.png)

#### [Chipmunk Physics Engine demo - Pyramid Stack](http://rawgit.com/hcchengithub/jeforth.3we/master/index.html?cls_include_chipmunk-js-pyramidstack.f)
![enter image description here](https://github.com/hcchengithub/jeforth.3we/wiki/pictures/demo-pyramidstack.png)


What else can you do with jeforth.3we?
=============

#### [Markdown editor](http://note.youdao.com/yws/public/redirect/share?id=1a8a342f3a9c1e0622a6050480af28b7&type=false)

NW.js can access files in your local computer and also have all abilities like the Chrome browser, that allows jeforth.3nw to include JavaScript modules from the Internet. For example, [SimpleMDE](https://simplemde.com) is a Markdown Editor that works fine on jeofrth.3nw. 

![enter image description here](https://github.com/hcchengithub/jeforth.3we/wiki/pictures/demo 3nw mde editor.JPG)


Get source code, unzip, and start running
=============

| Item | Address |
----------------|----------------------------------------------
| jeforth.3we high level source code | *http://github.com/hcchengithub/jeforth.3we* |
| Kernel, jeforth.js 3-words-engine| *http://github.com/hcchengithub/project-k* |

<br>
Click the [Download ZIP] button of both projects [jeforth.3we](https://github.com/hcchengithub/jeforth.3we) and [project-k](https://github.com/hcchengithub/project-k) on their GitHub web page to get them. Unzip jeforth.3we first and then unzip project-k to under the jeforth.3we directory, as shown in the below directory listing. Then you can run 3hta.bat  without installing anything else if your computer is Windows 8 or Windows 10; or run 3nd.bat and 3nw.bat, if you have installed node.js and nw.js.

My jeforth.3we/ directory listing for example,

![jeforth3we-dir.png](https://github.com/hcchengithub/jeforth.3we/wiki/pictures/jeforth3we-dir.png)


**Note:** Only for jeforth.3hta and only when you were **Download Zip** jeforth.3we from GitHub, It's necessary to use GNU tool [unix2dos](http://waterlan.home.xs4all.nl/dos2unix.html) to convert the new line characters of all text files [from Unix's LF to Windows' CRLF](https://en.wikipedia.org/wiki/Unix2dos). This is an example command line of the usage:

    d:\jeforth.3we>for /R %G in (*.*) do d:\bin\unix2dos.exe "%G"

<br>

If you were **git clone https://github.com/hcchengithub/jeforth.3we** instead of **Download Zip** then forget this step, GitHub shell for Windows already converts new line characters to CRLF correctly. 

Presentation videos
======

| No.   | Mandarin | English |
--------|----------|---------
| 1  | [Opening](http://www.camdemy.com/media/19253)| n/a |
| 2  | [Run the HTML version online](http://www.camdemy.com/media/19254)| n/a |
| 3  | [Run the HTML version on local computer](http://www.camdemy.com/media/19255)| n/a |
| 4  | [Run the HTA version](http://www.camdemy.com/media/19256)| n/a |
| 5  | [Run Node.js and Node-Webkit version](http://www.camdemy.com/media/19257)| n/a |
| 6  | [F2 inputbox edit mode](http://www.camdemy.com/media/19258)| n/a |
| 7  | [F4 Copy marked string to inputbox](http://www.camdemy.com/media/19259)| n/a |
| 8  | [F5 Restart](http://www.camdemy.com/media/19260)| n/a |
| 9  | [Bigger/Smaller input box](http://www.camdemy.com/media/19261)| n/a |
| 10 | [Esc clear input box](http://www.camdemy.com/media/19262)| n/a |
| 11 | [Tab auto-complete](http://www.camdemy.com/media/19263)| n/a |
| 12 | [Enter jump into the input box](http://www.camdemy.com/media/19264)| n/a |
| 13 | [Up/Down recall command history](http://www.camdemy.com/media/19265)| n/a |
| 14 | [Alt-Up Reuse used commands](http://www.camdemy.com/media/19266)| n/a |
| 15 | [Crtl- / Ctrl+ Zoom in/ Zoom out](http://www.camdemy.com/media/19267)| n/a |
| 16 | [Ctrl-Break stop all tasks](http://www.camdemy.com/media/19268)| n/a |
| 17 | [BackSpace trims the output box](http://www.camdemy.com/media/19269)| n/a |
| 18 | [Help is helpful](http://www.camdemy.com/media/19270)| n/a |
| 19 | [jsc JavaScript Console](http://www.camdemy.com/media/19271)| n/a |

What to play in further depth
========================
Download and setup the jeforth.3we directory and project-k directory as mentioned above.

#### **HTA** / jeforth.3hta
Double click the **jeforth.3we/jeforth.hta** or execute the below DOS command line in a DOS box,
```
jeforth.hta cls .' Hello world' cr 3000 sleep bye
```
![3htahello-world.png](https://github.com/hcchengithub/jeforth.3we/wiki/pictures/3htahello-world.png)

The prior method runs self-test because there's no given task to do. The 2'nd method is expected to print 'Hello world' (as shown above) and return to DOS box after 3 seconds.


Note! If you see the Windows error message : ["Safety Settings on this computer prohibit accessing a data source on another domain"](https://social.msdn.microsoft.com/Forums/en-US/becc982a-b693-49bb-8fb0-95847a3e96c7/hta-safety-settings-on-this-computer-prohibit-accessing-a-data-source-on-another-domain?forum=scripting) that I heard may happen on some Windows 7 computers. Sorry, [I have no solution yet](http://stackoverflow.com/questions/32177060/hta-safety-settings-on-this-computer-prohibit-accessing-a-data-source-on-anot), It didn't happen on those Windows 7 computers that I could reach. Please upgrade to Windows 8 or 10 to avoid from the problem.

#### **Node.js** / jeforth.3nd
Make sure you can run node.exe in a DOS box so you have setup the path. Make the jeforth.3we/ folder be your working directory. Execute one of the below demo command lines:
```
node jeforth.3nd.js
node jeforth.3nd.js cls .' Hello world' cr bye
```
Again, like the above HTA case, the prior command line does the self-test, and the 2'nd is expected to print 'Hello world'.

We have a local Web server written by jeforth.3nd itself. See jeforth.3we/Webserver.bat. Having a local Web server is necessary to run jeforth.3htm. 

#### **HTML** / jeforth.3htm
Setup your local Web server by running jeforth.3we/Webserver.bat, 

![webserver.png](https://github.com/hcchengithub/jeforth.3we/wiki/pictures/webserver.png)

then try to visit below URLs:
```
http://localhost:8888
http://localhost:8888/index.html
http://localhost:8888/index.html? cr ." hello world" cr cr 
http://localhost:8888/index.html?_cr_."_hello_world"_cr_cr 
http://localhost:8888/index.html? ." 8-) " 100 nap rewind
http://localhost:8888/index.html?_."_8-)_"_100_nap_rewind
```
I have tested IE10 , IE11 and Chrome. Firefox or other web browsers are not tested yet. As shown above, we can put any forth words in the URL. That will be the task jeforth.3htm will do after start up and the self-test will be skipped when having a task to do.

#### **Node-webkit** / jeforth.3nw
Setup your Node.js and Node-Webkit path in prior. Refer to 3nw.bat as an example. Make jeforth.3we/ be your working directory, run either one of below command lines:
```
nw ../jeforth.3we
nw ../jeforth.3we cls .' Hello World' 3000 sleep bye
```
The prior runs self-test because there's no given task to do. The 2'nd is expected to print 'Hello world' and return to DOS box after 3 seconds.
	
Compile eforth.com
--------------------------

Jeforth.3nd for Node.js can be a handy x86 CPU assembler (any other CPU too). We have an example to compile the legendary eforth.com executable for 16 bits PC under MS-DOS by Bill Muench and C. H. Ting, 1990.

 1. Install node.js correctly so you can run node.exe in a DOX box. Working directory at jeforth.3we/. 
 2. Run: node.exe jeforth.3nd.js include 86ef202.f bye
 3. You got jeforth.3we/eforth.com
 4. I have a 32bits windows 8, so I can run eforth.com directly. If your Windows system is 64 bits, you'll need a DOS virtual machine like vmware, virtual box, or I recommend DOSBox, to run the created eforth.com.

Excel automation
---------------------
Use jeforth.3hta to manipulate excel spread sheets. This example gets a column from a reference excel file to your target excel file.

 1. Double click on jeforth.3we/jeforth.hta to start it. After the self-test type the command line "include merge2.f" into the input box.
 2. Or run the below command line directory for the same thing:
```
jeforth.hta include merge2.f
```

#### The End

 - FigTaiwan [http://figtaiwan.org](http://figtaiwan.org) 
 - H.C. Chen [hcchen5600@gmail.com](hcchen5600@gmail.com) 
 - Written with [StackEdit](https://stackedit.io/)


  