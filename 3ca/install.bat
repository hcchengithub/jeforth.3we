
@rem 
@rem jeforth for chrome app setup 
@rem 
@rem Google Chrome App requires a certain directory structure. It doesn't necessarily impact
@rem jeforth.3we's directory structure because Windows supports sympolic link and hard link
@rem that virtualize the jeforth.3ca directory to use jeforth.3we's existing directories and 
@rem files that are well managed by GitHub with official version control. All we need is an 
@rem installer that creates the jeforth.3ca virtual directory. This batch program is it.
@rem 
@rem   Through experiment, I found manifest.json can be symbolic link but index.html and 
@rem common.css must be hard link. 
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

md ..\..\jeforth.3ca
cd ..\..\jeforth.3ca

@rem Symbolic File Links
mklink 3ca.log.txt 			..\jeforth.3we\log\3ca.log.txt
mklink manifest.json 		..\jeforth.3we\3ca\manifest.json

@rem Symbolic Directory Links
mklink /d 3ca 				..\jeforth.3we\3ca
mklink /d log 				..\jeforth.3we\log
mklink /d 3htm 				..\jeforth.3we\3htm
mklink /d demo 				..\jeforth.3we\demo
mklink /d external-modules 	..\jeforth.3we\external-modules
mklink /d f 				..\jeforth.3we\f
mklink /d js 				..\jeforth.3we\js
mklink /d playground 		..\jeforth.3we\playground
mklink /d project-k 		..\jeforth.3we\project-k
mklink /d private 			..\jeforth.3we\private

@rem Hard Links
fsutil hardlink create common.css ..\jeforth.3we\common.css
fsutil hardlink create index.html ..\jeforth.3we\index.html


