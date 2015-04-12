 

j e f o r t h . 3 w e
==============
**Forth** is the simplest computer programming language ever. **jeforth.3we** is an implementation with only a three words JavaScript engine. The same kernel, *jeforth.js*, *jeforth.f*, and *voc.f* for all applications: *HTA*, *HTM*, *Node.js*, *Node-webkit*, and *WSH*. Let's call them *jeforth.3hta*, *jeforth.3htm*, *jeforth.3nd*, *jeforth.3nw*, and *jeforth.3wsh* respectively.
Play now
-----------

 - [Solar system](http://figtaiwan.org/project/jeforth/jeforth.3we-master/index.html?cls_include_solar-system.f)
 - [H2O](http://figtaiwan.org/project/jeforth/jeforth.3we-master/index.html?cls_include_h2o.f)
 - [Alarm clock](http://figtaiwan.org/project/jeforth/jeforth.3we-master/index.html?cls_include_alarm.f_er)

Get source code and help
-----------------------------------
Source code : *http://github.com/hcchengithub/jeforth.3we* 
FigTaiwan : *http://figtaiwan.org*
Contact : *H.C. Chen by email hcchen5600@gmail.com*

Presentation videos
-----------------------

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

How to run
-------------
Download the entire project zip file from the above GitHub repository to your working directory that is the root folder.

####**HTA** / jeforth.3hta
Double click the **jeforth.3we/jeforth.hta** or execute the below DOS command line,
```
jeforth.hta cls .' Hello world' cr 3000 sleep bye
```
The prior method runs self-test because there's no task given. The 2'nd method is expected to print 'Hello world' and return to DOS box after 3 seconds.

In case you see the message : "Safety settings on this computer prohibit accessing a data source on another domain" that I heard may happen on some computers. Please read [discussion1](http://forums.aspfree.com/windows-scripting-64/safety-settings-error-hta-script-266006.html), [discussion2](http://www.sapien.com/forums/viewtopic.php?f=20&t=3725), and [discussion3](https://nakedsecurity.sophos.com/2009/10/16/power-misplaced-trust-htas-insecurity). It'll be very appreciated if you try their suggestions and let me know the results. I tried but didn't reproduce the problem on all computers I can access.

####**Node.js** / jeforth.3nd
Make sure you can run node.exe in a DOS box so you have setup the path. Make the jeforth.3we/ folder be your working directory. Execute one of the below demo command lines:
```
node jeforth.3nd.js
node jeforth.3nd.js cls .' Hello world' cr 3000 sleep bye
```
Again, like the above HTA case, the prior command line does the self-test, and the 2'nd is expected to print 'Hello world' and return to DOS box after 3 seconds.

We have a local Web server written by jeforth.3nd itself. See jeforth.3we/Webserver.bat. It's all about path settings. You need to modify the path in the .bat file for your own computer before using it. Having a local Web server is necessary to run jeforth.3htm.

####**HTML** / jeforth.3htm
Setup your local Web server by running jeforth.3we/Webserver.bat (You need to modify path settings in it for your computer for the first time), then visit either one of:
```
http://localhost:8888
http://localhost:8888/index.html
http://localhost:8888/index.html? cr ." hello world" cr cr 
http://localhost:8888/index.html?_cr_."_hello_world"_cr_cr 
http://localhost:8888/index.html? ." 8-) " 100 nap rewind
http://localhost:8888/index.html?_."_8-)_"_100_nap_rewind
```
I have tested IE10 and Chrome. Firefox or other web browsers are not tested yet. The Demo's in the above 'Play now' section are all running jeforth.3htm. As shown above, we can put any forth words in the URL. That will be the task jeforth.3htm will do after start up and the self-test will be skipped when having a task to do.

####**Node-webkit** / jeforth.3nw
Setup your Node.js and Node-Webkit path in prior. Refer to jeforth.3nw.bat as an example. Make jeforth.3we/ be your working directory, run either one of below command lines:
```
nw ../jeforth.3we
nw ../jeforth.3we cls .' Hello World' 3000 sleep bye
```
The prior runs self-test because there's no task given. The 2'nd is expected to print 'Hello world' and return to DOS box after 3 seconds.
	
More demo programs
-------------------------
####Compile eforth.com the legend

Use jeforth.3nd, 3 words engine jeforth for Node.js, to compile eforth.com ( eforth executable for 16 bits DOS)

 1. Working directory at jeforth.3we/. Setup the path to your Node.js executable node.exe 32 bits or 64 bits. Refer to jeforth.3we/jeforth.3nd.bat if you need an example.
 2. Run: node.exe jeforth.3nd.js 86ef202.f bye
 3. You got jeforth.3we/eforth.com
 4. My windows 8 is 32bits, so I can run eforth.com directly. If your Windows system has been 64 bits, you'll need a DOS virtual machine like vmware, virtual box, or I recommend DOSBox.

####Excel automation
Use jeforth.3hta to manipulate excel spread sheets. This example gets a column from a reference excel file to your target excel file.

 1. Double click on jeforth.3we/jeforth.hta to start it. After the self-test type the command line "include merge2.f" into the input box.
 2. Or run the below command line directory for the same thing:
```
jeforth.hta include merge2.f
```

####The End




