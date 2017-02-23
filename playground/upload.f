
	\ 
	\ MSDN input type=file element | input type=file object
	\ Example from this page https://msdn.microsoft.com/en-us/library/ms535263(v=vs.85).aspx
	\ 
	
    <js>
        var f = function getFiles() {
			debugger;
            // Get input element
            myFileList = document.getElementById("myfiles");
            // loop through files property, using length to get number of files chosen
            for (var i = 0; i < myFileList.files.length; i++) {
                // display them in the div
                document.getElementById("display").innerHTML += "<br/>" + myFileList.files[i].name ;
            }
        };f
	</jsV> constant getFiles // ( -- func ) event handler
	
	<o>
	<label>Use <strong>shift</strong> or <strong>ctrl</strong> click to pick a few files: 
	<input type="file" multiple id="myfiles" /></label>
	<div id="display"></div>
	</o> drop
	getFiles js: myfiles.onchange=pop() \ 3ce doesn't accept inline event handler
	
	
	