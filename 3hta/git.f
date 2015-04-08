
include vb.f
s" git.f"	source-code-header

	\	第 03 天：建立儲存庫 https://github.com/hcchengithub/Learn-Git-in-30-days
	\	0. 	use Github for Windows to open the shell through the [setting] button at the upper right corner.
	\		We can change default shell to dos, powershell, or linux. GitHub for Window always open the same
	\		PowerShell window. 一開始還沒有 git-demo 所以先從我現有的 repository 啟動 git shell 借力省掉 path
	\		設定的麻煩。

	s" forthtranspiler" value project-name // ( -- str ) The github repository name (project title)
	( Desktop@home ) s" C:\Users\hcchen\AppData\Local\GitHub\GitHub.appref-ms --open-shell" value git-shell-path // ( -- str ) Command line to launch Git Shell.
	( WKS-38EN3477 ) s" C:\Users\8304018.WKSCN\AppData\Local\GitHub\GitHub.appref-ms --open-shell" value git-shell-path // ( -- str ) Command line to launch Git Shell.
	s" https://github.com/figtaiwan/forthtranspiler" value uri(origin/master) // ( -- str ) URI of figtaiwan/forthtranspiler

	: shellId (  -- processID ) \ Get Git Shell processID, only one allowed.
		0 s" where CommandLine like '%GitHub%' and name = 'powershell.exe'" objEnumWin32_Process >r  ( 0 | obj )
		begin
			r@  ( 0 obj | obj)
			js> !pop().atEnd() ( 0 NotAtEnd? )
		while ( count | obj )
			1+ ( count )
			r@ :> item().ProcessId swap ( processID count | obj )
		r@ js: pop().moveNext() repeat ( ... count | obj )
		r> drop 1 = if else 0 then ;
		
	: activate-shell ( -- ) \ Active Git Shell (Git Shell's powershell.exe)
		200 nap shellId ?dup if ( processID )
			s' WshShell.AppActivate ' swap + </vb> 
		then 200 nap ; /// assume it's powershell
	: activate-jeforth ( -- ) \ Come back to jeforth.3hta
		200 nap s" WshShell.AppActivate " kvm.process :> processID + </vb> 200 nap ;
		
	: <shell> ( <command line> -- ) \ Command line to the shell
		char {enter}{enter} char </shell> word + compiling if literal then ; immediate
	: </shell> ( "command line" -- ) \ Send command line to the shell
		compiling if 
			\ '^' and '~' 是 sendkey 的 special character 要改成 "{^}" and "{~}"
			js: push(function(){push(pop().replace(/\^/g,"{^}").replace(/~/g,"{~}"))}) 
			, compile activate-shell
			s' WshShell.SendKeys "' literal compile swap compile + s' {enter}"' literal 
			compile + [compile] </vb> compile activate-jeforth
		else 
			js> pop().replace(/\^/m,"{^}").replace(/~/g,"{~}") activate-shell
			s' WshShell.SendKeys "' swap + s' {enter}"' + </vb> activate-jeforth
		then ; immediate
		
	: git-shell ( -- ) \ Run or activate Git Shell
		shellId if activate-shell else git-shell-path (fork) 
		begin 100 nap shellId until \ launch powershell takes a long time
		1000 nap <shell> subst x: .</shell> <shell> x:</shell>
		s" cd " project-name + </shell> then ; 

	: check-shell ( -- boolean ) \ Is Git Shell running?
		shellId not ?abort" Error! Git Shell is not running. Try 'git-shell' again." ;
	: init ( -- ) \ Create a new git repository at the current directory
		check-shell <shell> git init</shell> ;
		/// Don't worry about re-init a git again. It's idiot-proof, it
		/// responses something like:
		/// Reinitialized existing Git repository in D:/hcchen/Dropbox/learnings/github/demo/.git/
		
	: status ( -- ) \ Git status of the repository
		check-shell <shell> git status</shell> ;

	\ 先手動建立 shared-repository
	\ ~\git-demo [master]> md .\shared-repository
	\ cd shared-repository
	\ 然後當場執行 git init --bare
	\ 他會在當前目錄建立所有 Git 儲存庫的相關檔案與資料夾，你必須特別注意，這個資料夾不能直
	\ 接拿來做開發用途，只能用來儲存 Git 的相關資訊，大多數情況下，你都不應該手動編輯這個資
	\ 料夾的任何檔案，最好透過 git 指令進行操作
	\ 這是一個「沒有工作目錄的純儲存庫」 -- bare repository.
	\ 再次強調，Git 屬於「分散式版本控管」，每個人都有一份完整的儲存庫(Repository)。也就是說，
	\ 當你想要建立一個「工作目錄」時，必須先取得這個「裸儲存庫」的內容回來，這時你必須使用 
	\ git clone [REPO_URI] 指令「複製」(clone)一份回來才行，而透過 git clone 的過程，不但會自動
	\ 建立工作目錄，還會直接把這個「裸儲存庫」完整的複製回來。這個複製的過程，就如同「完整備份」
	\ 一樣，是把所有 Git 儲存庫中的所有版本紀錄、所有版本的檔案、...等等，所有資料全部複製回來。

	\ 手動建立工作用的 workspace
	\ github\git-demo [master +1 ~0 -0 !]> md git-workspaces
	\ github\git-demo [master +1 ~0 -0 !]> cd .\git-workspaces
	\ 然後把 shared repository clone 過來
	\ github\git-demo\git-workspaces [master +1 ~0 -0 !]> git clone ..\shared-repository
	\ 	Cloning into 'shared-repository'...
	\ 	warning: You appear to have cloned an empty repository.
	\ 	done.

	: clone ( 'URI' -- ) \ Get repository from URI to under the current folder
		check-shell s" git clone " swap + </shell> ;
		///     Example: 
		/// powershell @ github/ , char https://github.com/figtaiwan/forthtranspiler clone
		/// clone 下來是在 current directory 之下自動 md project folder 而非以
		/// current directory 當作 project folder。本地的就是一個 "branch"。
		///     如果 github/forthtranspiler 不是空的, 則：
		/// fatal: destination path 'forthtranspiler' already exists and is not an empty directory.
		/// 已經有東西的就要用 pull 的。參「第8天」。

	: help ( -- ) \ Git help
		js> tib.length>ntib if help else 
		<text>
	usage: git [--version] [--help] [-C <path>] [-c name=value]
			   [--exec-path[=<path>]] [--html-path] [--man-path] [--info-path]
			   [-p|--paginate|--no-pager] [--no-replace-objects] [--bare]
			   [--git-dir=<path>] [--work-tree=<path>] [--namespace=<name>]
			   <command> [<args>]

	The most commonly used git commands are:
	   add        Add file contents to the index
	   bisect     Find by binary search the change that introduced a bug
	   branch     List, create, or delete branches
	   checkout   Checkout a branch or paths to the working tree
	   clone      Clone a repository into a new directory
	   commit     Record changes to the repository
	   diff       Show changes between commits, commit and working tree, etc
	   fetch      Download objects and refs from another repository
	   grep       Print lines matching a pattern
	   init       Create an empty Git repository or reinitialize an existing one
	   log        Show commit logs
	   merge      Join two or more development histories together
	   mv         Move or rename a file, a directory, or a symlink
	   pull       Fetch from and integrate with another repository or a local branch
	   push       Update remote refs along with associated objects
	   rebase     Forward-port local commits to the updated upstream head
	   reset      Reset current HEAD to the specified state
	   rm         Remove files from the working tree and from the index
	   show       Show various types of objects
	   status     Show the working tree status
	   tag        Create, list, delete or verify a tag object signed with GPG

	'git help -a' and 'git help -g' lists available subcommands and some
	concept guides. See 'git help <command>' or 'git help <concept>'
	to read about a specific subcommand or concept.
		</text> . then ;

	\ 第 04 天：常用的 Git 版本控管指令
	\ 	master 代表目前工作目錄是 master 分支，也是 Git 的預設分支名稱。
	\ 	「紅色」的數字都代表 Untracked (未追蹤) 的檔案，也就是這些變更都不會進入版本控管。
	\ 	+10 代表有 10 個「新增」的檔案
	\ 	~0 代表有 0 個「修改」的檔案
	\ 	-0 代表有 0 個「刪除」的檔案
	\	「綠色」的數字都代表 Staged (準備好) 的檔案，也就是這些變更才會進入版本控管。
	\	+23 代表有 23 個「新增」的檔案將被建立一個版本
	\	~0 代表有 0 個「修改」的檔案將被建立一個版本
	\	-0 代表有 0 個「刪除」的檔案將被建立一個版本
		
	\ git add . 不用學, use GitHub for Windows
	\ 	github\forthtranspiler [master +1 ~1 -0 !]> git add readme.md <------ 應該是 README.md 大小寫有分，但不會有任何警告！
	\ 	github\forthtranspiler [master +1 ~1 -0 !]> git add readme.mdddd <--- 檔案真的不存在才會有 error
	\ 	fatal: pathspec 'readme.mdddd' did not match any files
	\	github\forthtranspiler [master +1 ~1 -0 !]> git status <---- add 過之後用 status 查
	\	On branch master
	\	Your branch is up-to-date with 'origin/master'.
    \
	\	Changes not staged for commit:
	\	  (use "git add <file>..." to update what will be committed)
	\	  (use "git checkout -- <file>..." to discard changes in working directory) <------ 這個有用！
    \
	\			modified:   README.md  <-------------- 只說是 modified 但仍是紅色，表示 unstaged
    \
	\	Untracked files:
	\	  (use "git add <file>..." to include in what will be committed)
    \
	\			cfg.bat <------ 當然是紅色的
    \
	\	no changes added to commit (use "git add" and/or "git commit -a")
	\ 	我用 git add . 才終於把 readme.md 搞成 staged (綠色)，從而發現大小寫有分，真的是困難重重。
	\	D:\hcchen\Dropbox\learnings\github\forthtranspiler [master +1 ~1 -0 !]> git add README.md <----- 大小寫對了
	\	D:\hcchen\Dropbox\learnings\github\forthtranspiler [master +0 ~1 -0 | +1 ~0 -0 !]> git status
	\	On branch master
	\	Your branch is up-to-date with 'origin/master'.
    \
	\	Changes to be committed:
	\	  (use "git reset HEAD <file>..." to unstage) <--- 很貼心，但 HEAD 又是啥意思？
    \
	\			modified:   README.md		<------ 綠色
    \
	\	Untracked files:
	\	  (use "git add <file>..." to include in what will be committed)
    \
	\			cfg.bat
    \
	\	D:\hcchen\Dropbox\learnings\github\forthtranspiler [master +0 ~1 -0 | +1 ~0 -0 !]> git commit -m "modify the readme.md"
	\	[master a372103] modify the readme.md
	\	 1 file changed, 2 insertions(+)
	\	D:\hcchen\Dropbox\learnings\github\forthtranspiler [master +1 ~0 -0 !]> git status
	\	On branch master
	\	Your branch is ahead of 'origin/master' by 1 commit.
	\	  (use "git push" to publish your local commits) <------ 實在有夠貼心，被罵夠了。揣摩，要先 commit 然後 push 才會上網。
    \															 上哪個網？自己的，還是原來的？
	\	Untracked files:
	\	  (use "git add <file>..." to include in what will be committed)
    \
	\			cfg.bat
    \
	\	nothing added to commit but untracked files present (use "git add" to track)
	\	D:\hcchen\Dropbox\learnings\github\forthtranspiler [master +1 ~0 -0 !]>


	\ git rm 相對於 add 但還會真的把檔案殺掉。別用！ Use GitHub for Windows instead
	\ git reset 就是把 tracking 全抹掉，要重新 add。 Use GitHub for Windows

	\ git commit -m "版本紀錄的說明文字"
	\ 就是把 tracked files 都 commit 進 repository
	\ Then Git Shell 的 prompt 就只剩下 [master] 字樣了，代表目前已經沒有任何要被建立版本的索引或快取。

	\ git log 很有用！

	: log-verbose ( -- ) \ Read the commit log, 'q' to stop.
		check-shell <shell> git log </shell> ;
		/// "git log -10" to see only the recent 10 commits

	: 還原 ( <filename1 filename2 ...> -- ) \ 把檔案從最後的 commit 裡還原回來
		check-shell char \n|\r word s" git checkout -- " swap + </shell> ;
		/// 另一種寫法還原其中一個被改壞的檔案: git checkout master Gruntfile.js

	: 徹底還原 ( -- ) \ 把所有改過的都重新 checkout 回來，小心！連新加的檔案也都殺掉。
		check-shell <shell> git reset --hard </shell> ;

	: ls ( -- ) \ Same as 'dir', like dir of DOS, list all files of the repository.
		check-shell <shell> git ls-files</shell> ;
		last alias dir

	\ 第 05 天：了解儲存庫、工作目錄、物件與索引之間的關係。<----------- 應該先閱讀這一章！
	\ 	使用 Git 版本控管時，會遭遇到很多分支的狀況
	\ 	使用 git checkout 切換到不同分支會將你工作目錄下的目錄與檔案都改成與要切換過去的分支下的目錄
	\	與檔案一樣。所以，適時的保持工作目錄的乾淨，是版本控管過程中的一個基本原則。
	\ object 「物件」用來保存版本庫中所有檔案與版本紀錄
	\ index 「索引」則是用來保存當下要進版本庫之前的目錄狀態。
	
	\ 第 06 天：解析 Git 資料結構 - 物件結構
		
	: file-system-check ( -- ) \ check repository file system integity
		check-shell <shell> git fsck</shell> ;

	\ 第 07 天：解析 Git 資料結構 - 索引結構 <----------- 了解 tracked/untracked, modified/unmodified, staged/unstaged 必讀。

	: add-modified ( -- ) \ 忽略 untracked 僅 cache "modified" and "deleted" files.
		check-shell <shell> git add -u </shell> ;
		/// 'add' 是把檔案加進 cache 準備提交，原本是 tracked 或 untracked 
		/// 皆然，不只是用來加新檔進 tracked。

	\ 第 08 天：關於分支的基本觀念與使用方式

	: list-branch ( -- ) \ List all branches. Other commands work *in* a branch.
		check-shell <shell> git branch </shell> ;

	: create-branch ( <branch name> -- ) \ Create a new branch.
		check-shell s" git branch " BL word + </shell> ;
		/// 不必先 commit，故可以 commit 到新 branch 去。

	: delete-branch ( <branch name> -- ) \ Delete an existing branch.
		check-shell s" git branch -d " BL word + </shell> ;
		/// 你不能刪除目前工作的分支，必須先切換到其他分支後，再刪除之。

	: branch-branch ( <branch name> -- ) \ New a branch and switch over.
		check-shell s" git checkout -b " BL word + </shell> ;
		/// 不必先 commit，故可以 commit 到新 branch 去。
		
	: switch-branch ( <branch name> -- ) \ Switch to another branch.
		check-shell s" git checkout " BL word + </shell> ;
		/// "switch branch" and "switch commit" are the same command.
		/// 不必先 commit，故可以 commit 到別的 branch 去。
		
	last alias switch-commit // ( <commit ID> -- ) Switch to another commit.
		/// "switch branch" and "switch commit" are the same command.
		/// Use "git log" to see commit ID's
		/// Switch commit 到舊版，即進入了所謂的 detached HEAD 狀態，這是一種
		/// 「目前工作目錄不在最新版」的提示，你可以隨時切換到 Git 儲存庫的任
		/// 意版本，但是由於這個版本已經有「下一版」，所以如果你在目前的「舊版」
		/// 執行 git commit 的話，就會導致這個新版本無法被追蹤變更，所以建議不
		/// 要這麼做。若你要在 detached HEAD 狀態建立一個可被追蹤的版本，那麼正
		/// 確的方法則是透過「建立分支」的方式。

	\ 第 09 天：比對檔案與版本差異

	: diff ( <[id1] [--cached] [id2]> -- ) \ List differences between comments.
		check-shell s" git diff " char \n|\r word + </shell> ;
		/// diff               => 工作目錄 vs 索引
		/// diff HEAD          => 工作目錄 vs HEAD (代表最新版本 or commit)
		/// diff --cached HEAD => 索引     vs HEAD
		/// diff --cached      => 索引     vs HEAD
		/// diff HEAD^ HEAD    => HEAD^    vs HEAD
		/// diff commit1 commit2 => commit1 vs commit2

	\ 第 10 天：認識 Git 物件的絕對名稱

	: log ( -- ) \ Read the simplified commit log, 'q' to stop. Also 'log-verbose'.
		check-shell <shell> git log --pretty=oneline --abbrev-commit </shell> ;
		
	\ 第 11 天：認識 Git 物件的一般參照與符號參照
	\ 	HEAD, branch name, --cached are all references
	\	在 Git 工具中，預設會維護一些特別的符號參照，方便我們快速取得常用的 commit 
	\	物件，且這些物件預設都會儲存在 .git/ 目錄下。這些符號參考有以下四個：
    \	
	\ HEAD
	\	永遠會指向「工作目錄」中所設定的「分支」當中的「最新版」。所以當你在這個分
	\	支執行 git commit 後，這個 HEAD 符號參照也會更新成該分支最新版的那個 commit 物件。
	\ ORIG_HEAD
	\	簡單來說就是 HEAD 這個 commit 物件的「前一版」，經常用來復原上一次的版本變更。
	\ FETCH_HEAD
	\	使用遠端儲存庫時，可能會使用 git fetch 指令取回所有遠端儲存庫的物件。這個 
	\	FETCH_HEAD 符號參考則會記錄遠端儲存庫中每個分支的 HEAD (最新版) 的「絕對名稱」。
	\ MERGE_HEAD
	\	當你執行合併工作時 (關於合併的議題會在日後的文章中會提到)，「合併來源｣的 commit 
	\	物件絕對名稱會被記錄在 MERGE_HEAD 這個符號參照中。
		
	: reference ( "reference" <pathname> -- ) \ Create or change a reference that points to a GitHub object. 
		check-shell BL word ( "reference" "ref-name" ) s" git update-ref " swap + s"  " + swap + </shell> ;
		/// Example of a pathname : refs\refName
		/// GitHb object is usually a comment. Can also be a tree 
		/// or something else that you can find in the .git folder.

	: symbol ( "reference-pathname" <pathname> -- ) \ Create (and change?) a symbolic reference.
		check-shell BL word ( "reference-pathname" "symbol-name" ) s" git symbolic-ref " swap + s"  " + swap + </shell> ;
		/// Example of a pathname : refs\symName

	: show-ref ( -- ) \ List all references include symbols.
		check-shell <shell> git show-ref</shell> ;

	\ 第 12 天：認識 Git 物件的相對名稱
	













