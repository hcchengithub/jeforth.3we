
@rem 
@rem jeforth for Microsoft HTML Applications (HTA)
@rem 
@rem   This batch program creates a mirror directory for jeforth.3hta while the root is still
@rem jeforth.3we that are under the GitHub version contorl.
@rem 
@rem   Hard links are real file headers that share the same file pathname. Many hard links 
@rem can be sharing the same file or directory and all of them are equal, no master. While 
@rem symbolic link is a virtual file pathname that points to the real file or directory. For 
@rem cloud safety, I guess, symblic links may not be acceptable to web browsers. In that cases, 
@rem use hard link instead.
@rem
@rem H.C. Chen 14:01 November 17, 2016
@rem 

cd %~dp0
@rem mklink.exe and fsutil.exe need administrator priviledges, check it.
call admin.bat

md ..\..\jeforth.3hta
cd ..\..\jeforth.3hta

@rem Symbolic File Links
mklink log.txt 			..\jeforth.3we\log\log.txt
@rem mklink jeforth.hta 		..\jeforth.3we\jeforth.hta

@rem Symbolic Directory Links
mklink /d log 				..\jeforth.3we\log
mklink /d 3hta 				..\jeforth.3we\3hta
mklink /d 3htm 				..\jeforth.3we\3htm
mklink /d demo 				..\jeforth.3we\demo
mklink /d external-modules 	..\jeforth.3we\external-modules
mklink /d f 				..\jeforth.3we\f
mklink /d js 				..\jeforth.3we\js
mklink /d playground 		..\jeforth.3we\playground
mklink /d project-k 		..\jeforth.3we\project-k

@rem Hard Links
fsutil hardlink create common.css	..\jeforth.3we\common.css
fsutil hardlink create jeforth.hta	..\jeforth.3we\jeforth.hta

pause
