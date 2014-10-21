
	' We need to encapsulate VBS commands into a function or subroutine so
	' as to allow JavaScript to be able to use them. So we can call vbs function from JavaScript!

	' But now I found Microsoft execScript can execute any Script language. Well, good to know. 
	' hcchen5600 2014/07/03 11:46:47 https://www.evernote.com/shard/s22/nl/2472143/dce3aec0-3f47-40b3-8d3c-da862cbef205

	' see vb.f for usage examples
	
	' http://msdn.microsoft.com/en-us/library/0z5x4094(v=vs.84).aspx
	function vbEval (cmd)
		vbEval = Eval(cmd)
	end function
	
	' http://msdn.microsoft.com/en-us/library/03t418d2(v=vs.84).aspx
	Sub vbExecute (cmd)
		Execute cmd
	End Sub

	' ~~~~~~~~~~~~~~ Why "ExecuteGlobal" ? ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	'	<text>
	'		sub test
	'			MsgBox("If you can see me then I must be in global.")
	'		end sub
	'	</text>
	'	<js> 
	'		vbExecute(pop()); vbExecute("test");       // test only works in the <text> section.
	'		vbExecuteGlobal(pop()); vbExecute("test"); // test will be a global function
	'	</js> .s
	' http://msdn.microsoft.com/en-us/library/342311f1(v=vs.84).aspx
	Sub vbExecuteGlobal (cmd)
		ExecuteGlobal cmd
	End Sub


