
@rem 
@rem jeforth for Chrome Extension setup 
@rem 
@rem Google Chrome Extension requires a certain directory structure. It doesn't necessarily impact
@rem jeforth.3we's directory structure because Windows supports sympolic link and hard link
@rem that virtualize the jeforth.3ce directory to use jeforth.3we's existing directories and 
@rem files that are well managed by GitHub with official version control. All we need is an 
@rem installer that creates the jeforth.3ce virtual directory. This batch program is it.
@rem 
@rem Through experiment, I found manifest.json and background.html can be symbolic link but
@rem jeforth.3ce.html and common.css must be hard link. Hard link is a real file header that
@rem shares the same file pathname. Many hard links can be sharing the same file or directory
@rem and all of them are equal, no master. While symbolic link is a virtual file pathname that 
@rem points to the real file or directory. For cloud safety, I guess, symblic links may not be
@rem acceptable to web browsers. In that cases, use hard link instead.
@rem
@rem H.C. Chen 14:01 November 17, 2016
@rem

md ..\..\jeforth.3ce
cd ..\..\jeforth.3ce

@rem Symbolic File Links
mklink manifest.json				..\jeforth.3we\3ce\manifest.json
mklink jeforth.3ce.background.html	..\jeforth.3we\3ce\jeforth.3ce.background.html

@rem Symbolic Directory Links
mklink /d 3ce 				..\jeforth.3we\3ce
mklink /d log 				..\jeforth.3we\log
mklink /d 3htm 				..\jeforth.3we\3htm
mklink /d demo 				..\jeforth.3we\demo
mklink /d external modules 	..\jeforth.3we\external modules
mklink /d f 				..\jeforth.3we\f
mklink /d js 				..\jeforth.3we\js
mklink /d playground 		..\jeforth.3we\playground
mklink /d project-k 		..\jeforth.3we\project-k

@rem Hard Links
fsutil hardlink create common.css 		..\jeforth.3we\common.css
fsutil hardlink create jeforth.3ce.html	..\jeforth.3we\3ce\jeforth.3ce.html


