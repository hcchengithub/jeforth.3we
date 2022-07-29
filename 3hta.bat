@echo jeforth.hta
@rem Necessary lines: "%~d0" switch to correct drive and "cd %~dp0" to working directory 
@rem because running from home directory is required with .3htm and thus .3hta follows the rule although should not and it thus is a todo item @log.txt(11:39 2022/7/9). 
@rem Necessary switch: "start /wait . . . . " avoid running all paralelly when, e.g. !start /wait 3hta.bat include word.f pdf2docx $pathname, is in a loop.
@rem Necessary line: exit to leave from python script e.g. !start /wait 3hta.bat . . . when in a loop

%~d0
cd %~dp0
start /wait jeforth.hta nop %*
exit