
hcchen5600 2014/10/13 20:29:24 
[x]	The reason why 3nd can use writeTextFile to write the binary to the output file eforth.com
	is Node.js' global class Buffer(). It handles binary data. So this project is Node-Webkit or
	Node.js dependent!

hcchen5600 2014/10/27 17:24:46 
[x]	jeforth.3nw can run this demo too. No problem at all.
	1. Make sure you can run jeforth.3we/jeforth.3nw.bat 
	2. cd to ~/jeforth.3we/3nd/eforth.com
	3. include 86ef202.f -----> it generates eforth.com (MD5 ba058c05da4028e55308b8e7ccc2d5b3 *eforth.com)
								at the recent folder.
