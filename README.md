 
              ~%~%~%~%~%~%~%~  j e f o r t h . 3 w e  ~%~%~%~%~%~%~%~
                      The jeforth with a three words engine
                 Same kernel - jeforth.js, jeforth.f, voc.f - for 
                 all applications - HTA, HTM, Node.js - and more?
                    http://github.com/hcchengithub/jeforth.3we
How to run:

    Working directory is always the jeforth.3we/ root folder. Do self-test automatically if there
    is no further forth commands in the command line.

    HTA
        Double click the jeforth.3we/jeforth.hta or execute the below command line from a DOS box,
        jeforth.hta cls .' Hello world' cr 3000 sleep bye

    Node.js
        Execute below command lines from a DOS box, you setup the path to your node.exe in prior,
			node jeforth.3nd
			node jeforth.3nd cls .' Hello world' cr 3000 sleep bye
        There's a local Web server which is also under jeforth.3nd. See jeforth.3we/Webserver.bat.
        To have a local Web server is necessary to run jeforth.3htm.

    HTML
        Setup your local Web server by running jeforth.3we/Webserver.bat (modify path in it for 
        your Node.js first), then visit,
        http://localhost:8888/jeforth.3htm.html
        , from IE or Chome. Firefox and other web browsers are not tested yet.
        Then, try "include clock3.f" and "include p5.f" to see world clocks and a bouncing ball.

	Node-webkit
		Setup your Node.js and Node-Webkit path in prior. See jeforth.3nw.bat as an example. 
		CD to ~/jeforth.3we as the root directory. Run,
			d:\jeforth.3we> nw ../jeforth.3we cls .' Hello World!!' 5000 sleep bye
		or run,
			d:\jeforth.3we> nw ../jeforth.3we
		... without CLI command so as to run self-test.
	
More demo programs:

    *** Use jeforth.3nd, 3 words engine jeforth for Node.js, to compile eforth.com ( eforth executable
        for DOS 16 bits )
    1.  jeforth.3nd works on DOS box. Setup the path to your node.exe 32 bits or 64 bits.
        jeforth.3we/jeforth.3nd.bat is an example.
    2.  run: node.exe jeforth.3nd.js 86ef202.f bye
    3.  you got jeforth.3we/eforth.com
    4.  my windows 8 is 32bits, so I can run eforth.com directly. If your Windows system has been
        64 bits, you'll need a DOS virtual machine like vmware, virtual box, or I recommend DOSBox.

    *** Use jeforth.3hta, 3 words engine jeforth for Windows HTA, to work on excel spread sheets.
        This example gets a column from a reference excel file to your target excel file.
    1.  Double click on jeforth.3we/jeforth.hta to start it. After the self-test "include merge2.f"
    2.  Or run this command line for the same thing, but skip the self-test,
        ~/jeforth.3we> jeforth.hta include merge2.f

    *** and more . . . . 


