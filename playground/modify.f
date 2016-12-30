
	char %HOMEDRIVE%%HOMEPATH%\Downloads\jeforth.3htm.html 
		env@ value command-file // ( -- "pathname" ) 
	char %HOMEDRIVE%%HOMEPATH%\Documents\GitHub\jeforth.3we\playground\template.f 
		env@ value target-file // ( -- "pathname" ) 
	"" value command // ( -- string ) Remaining string
	"" value target // ( -- string ) Target string to be modified.
	0  value itarget  // ( -- int ) Pointer of target
	"" value pattern  // ( -- string ) The next pattern ^^^==>...^^^ in command. Specify the target position.
	: init  ( -- ) \ Initialize everything before a run.
		command-file readTextFile to command
		target-file  readTextFile to target 
		0 to itarget "" to pattern \ reset
		;
		
	: ^^^==> ( -- T/f ) \ Move icommand and get pattern. Return true if found.
		js> vm[context].command.indexOf("^^^==&gt;") ( idx )
		dup -1 = if (  沒事做了 ) drop false else ( idex )
			\  找到了
			js> vm[context].command.slice(pop()) to command \ chop leading garbage
			js> vm[context].command.search(/\^\^\^[+-]/) ( idx ) 
			dup -1 = if ( idx )
				\  故意留下 idx 
				abort" Error! anticipating ^^^+ or ^^^- command not found!" 
			else
				js> vm[context].command.slice(0,tos()) to pattern \ get pattern
				js> vm[context].command.slice(pop()) to command   \ chop processed portion
			then
			true
		then ;
\ [ ] /* ... */ comments 當然要留著, 別破壞到, 同時也不讓它們干擾到 modification 的工作。
		

