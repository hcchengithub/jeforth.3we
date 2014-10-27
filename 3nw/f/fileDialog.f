
\ file dialogs for node-webkit

s" fileDialog.f"	source-code-header

\ ---------------- File-dialogs --------------------------------------------------------------
\ https://github.com/rogerwang/node-webkit/wiki/File-dialogs

: (fileDialog)	( 'attribute' -- 'pathname' ) \ The <input type='file'> dialog.
				<text> <input style="display:none;" type="file" </text>
				swap + s"  />" + </o>
				<js>
					var chooser = $(pop());
					chooser.change(function(evt) {
						push($(this).val());
					});
					chooser.trigger('click');  
				</js> ;

: getFilePath	( -- 'pathname' ) \ Get a file pathname through a dialog box.
				"" (fileDialog) ;
				
: getFilePaths	( -- 'pathname;pathname' ) \ Get file pathnames through a dialog box.
				char multiple (fileDialog) ;

: nwdirectory  	( -- 'path' ) \ Get directory path through a dialog box.
				char nwdirectory  (fileDialog) ;

: nwsaveas  	( -- 'path' ) \ Get save-as pathname through a dialog box.
				char nwsaveas  (fileDialog) ;
