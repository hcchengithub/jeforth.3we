
\
\ git.f 利用 forth 的自由語法，簡化 GitHub 使用上的困難。
\
\     GitHub 功能強大，而且一邊用它還會一邊給你很多建議。已經仁盡義至了，但是根本記不住。
\ 今利用 jeforth 來管理這些命令跟建議。平時也可以簡化指令、做筆記、為每組命令添加 help 
\ message。不管 GitHub 再怎麼複雜難用，配合 jeforth 只要 study 一次就永遠不會再忘記了。
\
	<comment>
	hcchen5600 2015/04/17 21:23:33 
		昨天家裡電腦又 GitHub repository 大亂。可能是 GFW 干擾 Dropbox 同步所造成。也可能是 GitHub 
		for Windows 上沒有先 commit 乾淨就按下 [Sync] button 的後果。一時心慌十分挫折。幸好公司電腦
		的 Dropbox folder 還是先前的正常狀況，回公司 commit 上 GitHub 先修復 remote。
		家裡的 .git 已經大亂，size 竟有 47M 正常的才 19M。修復過程： 先 md 一個暫時的 folder, 然後
		從 GitHub 上 clone 下來。檢查 local jeforth.3we 裡 ignored 的檔案先 copy 到 temp folder，最
		後 copy temp 過來蓋掉 local。結果 local size 變成 60M 只好這樣。裡面的垃圾以後再看怎麼清。
	</comment>

js> kvm.appname char jeforth.3hta != [if] ?abort" Sorry! git.f is for jeforth.3hta only." \s [then]
include vb.f
s" git.f"	source-code-header

	\	第 03 天：建立儲存庫 https://github.com/hcchengithub/Learn-Git-in-30-days
	\	0. 	use Github for Windows to open the shell through the [setting] button at the upper right corner.
	\		We can change default shell to dos, powershell, or linux. GitHub for Window always open the same
	\		PowerShell window. 一開始還沒有 git-demo 所以先從我現有的 repository 啟動 git shell 借力省掉 path
	\		設定的麻煩。

	\ Setup git-shell-path so we know how to run Git Shell.
	( WKS-38EN3477 ) char COMPUTERNAME proc-env@ char WKS-38EN3477 = [if]
		s" C:\Users\8304018.WKSCN\AppData\Local\GitHub\GitHub.appref-ms --open-shell" 
		value git-shell-path // ( -- str ) Command line to launch Git Shell.
		s" c:\Users\8304018.WKSCN\Downloads" value downloads-path // ( -- 'path' ) 
	[then]
	( DP-20121028UGNO ) char COMPUTERNAME proc-env@ char DP-20121028UGNO = [if]
		s" C:\Users\hcchen\AppData\Local\GitHub\GitHub.appref-ms --open-shell" 
		value git-shell-path // ( -- str ) Command line to launch Git Shell.
	[then]
	/// Something like this:
	/// C:\Users\hcchen\AppData\Local\GitHub\GitHub.appref-ms --open-shell
	/// which is from right-click the 'Git Shell' icon on the Desktop.

	\ You need to setup 'project-name' and 'uri(origin/master)' manually.
	\ s" forthtranspiler" value project-name // ( -- str ) The github repository name (project title)
	s" jeforth.3we" value project-name // ( -- str ) The github repository name (project title)
	\ s" https://github.com/figtaiwan/forthtranspiler" value uri(origin/master) // ( -- str ) URI of figtaiwan/forthtranspiler
	s" https://github.com/hcchengithub/" project-name + value uri(origin/master) // ( -- str ) URI of figtaiwan/forthtranspiler

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
		
	: check-shell ( -- ) \ Abort if Shell is not running.
		shellId not ?abort" Error! Git Shell is not running. Try 'launch-git-shell' command again." ;
		
	: activate-shell ( -- ) \ Active Git Shell (Git Shell's powershell.exe)
		500 nap shellId ?dup if ( processID )
			s' WshShell.AppActivate ' swap + </vb> 
		then 500 nap ; /// assume it's powershell
	: activate-jeforth ( -- ) \ Come back to jeforth.3hta
		1000 nap s" WshShell.AppActivate " kvm.process :> processID + </vb> 500 nap ;

	: <shell> ( <command line> -- ) \ Command line to the Git Shell
		char {enter}{enter} char </shell> word + compiling if literal then ; immediate

	: </shell> ( "command line" -- ) \ Send command line to the Git Shell
		compiling if 
			compile check-shell 
			\ '^' and '~' 是 sendkey 的 special character 要改成 "{^}" and "{~}"
			js: push(function(){push(pop().replace(/\^/g,"{^}").replace(/~/g,"{~}"))}) 
			, compile activate-shell 
			s' WshShell.SendKeys "' literal compile swap compile + s' {enter}"' literal 
			compile + [compile] </vb> compile activate-jeforth
		else 
			check-shell
			js> pop().replace(/\^/m,"{^}").replace(/~/g,"{~}") activate-shell
			s' WshShell.SendKeys "' swap + s' {enter}"' + </vb> activate-jeforth
		then ; immediate
		
	: launch-git-shell ( -- ) \ Run or activate Git Shell
		shellId if activate-shell else git-shell-path (fork) then
		begin 500 nap shellId until 500 nap activate-shell ;
		
	: autoexec ( -- ) \ Mimic autoexec.bat
		<shell> subst x: /d </shell> 
		<shell> subst x: .</shell> <shell> x:</shell>  
		s" cd " project-name + </shell> then ; 

	: cd ( <...> -- ) \ The DOS command 'change directory'.
		s" cd " char \n|\r word + </shell> ;
		
	: (cd) ( "..." -- ) \ The DOS command 'change directory'.
		s" cd " swap + </shell> ;
		
	: cls ( <...> -- ) \ The DOS command 'Clear screen', also clear jeforth output box.
		<shell> cls </shell> cls ;
		/// 'er' to erase only the jeforth output box.

	: dir ( <...> -- ) \ The DOS command 'View directory'.
		s" dir " char \n|\r word + </shell> ;
		/// 'ls' to list repository.
		
	: init ( -- ) \ Create a new git repository at the current directory
		<shell> git init</shell> ;
		/// Don't worry about re-init a git again. It's idiot-proof, it
		/// responses something like:
		/// Reinitialized existing Git repository in D:/hcchen/Dropbox/learnings/github/demo/.git/
		
	: status ( -- ) \ Git status of the repository
		<shell> git status</shell> ;

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

	: clone ( <'URI'> -- ) \ New a repository, which is from URI, at the current folder
		s" git clone " char \n|\r word + </shell> ;
		///     git clone 將遠端儲存庫複製到本地，並建立工作目錄與本地儲存庫，
		/// 也就是 .git 資料夾。
		///     Example: clone https://github.com/figtaiwan/forthtranspiler
		/// clone 下來是在 current directory 之下自動 md project folder 而非以
		/// current directory 當作 project folder。本地的就是一個 "branch"。
		///     如果 github/forthtranspiler 不是空的, 則：
		/// fatal: destination path 'forthtranspiler' already exists and is 
		/// not an empty directory.
		/// Local 已經有東西的就要用 pull 的。參「第8天」。
		///     如果你用 git clone https://balbal.git 複製一個 「沒有版本」的
		/// 空白 Git 儲存庫，將會得到一個 warning: You appear to have cloned 
		/// an empty repository. 警告訊息，不過這不影響你上傳本地的變更。

	: git-help ( -- ) \ Git help
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
		</text> . ;

	\ 第 04 天：常用的 Git 版本控管指令
	\ 	master 代表目前工作目錄是 master 分支，也是 Git 的預設分支名稱。
	\ 	「紅色」的數字都代表 Untracked (未追蹤) 的檔案，也就是這些變更都不會進入版本控管(commit)。
	\ 	+10 代表有 10 個「新增」的檔案
	\ 	~0 代表有 0 個「修改」的檔案
	\ 	-0 代表有 0 個「刪除」的檔案
	\	「綠色」的數字都代表 Staged (準備好) 的檔案，也就是這些變更才會進入版本控管(commit)。
	\	+23 代表有 23 個「新增」的檔案將被建立一個版本
	\	~0 代表有 0 個「修改」的檔案將被建立一個版本
	\	-0 代表有 0 個「刪除」的檔案將被建立一個版本

	: add ( <...> -- ) \ Add file(s) into the cache of the repo (the project)
		s" git add " char \n|\r word + </shell> ;
		/// 注意，pathname 有分大小寫，靠，弄錯了沒有 warning 等你自己慢慢發現！
		/// Usage: add pathname1 pathname2 ...
		/// 'add' 把檔案加進 cache 準備 commit。原本是 tracked 或 untracked 都
		/// 得經過 add 才會進 cache。別以為只有新檔才需要 add 因為即使是已經 
		/// tracked 的檔案也不會自動進 cache 故也不會自動被 commit 到。

	: commit ( <...> -- ) \ Save the cache into the repository.
		s" git commit " char \n|\r word + </shell> ;
		/// Usage: commit -m "Descriptions"
		/// 先用 'add' 把檔案加進 cache 才 commit 得到它。原本是 tracked 或
		/// untracked 都得經過 add 才會進 cache。別以為只有新檔才需要 add 因
		/// 為即使是已經 tracked 的檔案也不會自動進 cache 故也不會自動被 
		/// commit 到。

		
	\ 注意！ pathname 有分大小寫，弄錯了不會有 warning, 靠。
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
		<shell> git log </shell> ;
		/// "git log -10" to see only the recent 10 commits

	: 還原檔案 ( <filename1 filename2 ...> -- ) \ 把檔案從最後的 commit 裡恢復回來
		s" git checkout -- " char \n|\r word + </shell> ;
		/// 另一種寫法還原其中一個被改壞的檔案: 
		/// git checkout <master|commitId> path/Gruntfile.js
		last alias retrieve // ( <filename1 filename2 ...> -- ) 還原檔案
		last alias recall // ( <filename1 filename2 ...> -- ) 還原檔案
		
	: 徹底還原 ( -- ) \ 把所有改過的都重新 checkout 回來，小心！連新加的檔案也都殺掉。
		<shell> git reset --hard </shell> ;
		/// 做錯了？沒關係，只要執行 git reset --hard ORIG_HEAD 就可
		/// 以回復到上一版，然後再重新合併一次引發相同的衝突。

	: ls ( <[-u or other options]> -- ) \ Like dir of DOS, list all files of the repository.
		s" git ls-files " char \n|\r word + </shell> ;
		/// "ls -u" to list conflict files then use "diff [filepath]" to see the details.

	: ls-remote ( -- ) \  'ls' but regarding the remote repo.
		s" git ls-remote " char \n|\r word + </shell> ;
		/// ls-remote 顯示特定 remote repo 的 reference 名稱。包含
		/// remote branchs 與 remote tags.


	\ 第 05 天：了解儲存庫、工作目錄、物件與索引之間的關係。<----------- 應該先閱讀這一章！
	\ 	使用 Git 版本控管時，會遭遇到很多分支的狀況
	\ 	使用 git checkout 切換到不同分支會將你工作目錄下的目錄與檔案都改成與要切換過去的分支下的目錄
	\	與檔案一樣。所以，適時的保持工作目錄的乾淨，是版本控管過程中的一個基本原則。
	\ object 「物件」用來保存版本庫中所有檔案與版本紀錄
	\ index 「索引」則是用來保存當下要進版本庫之前的目錄狀態。
	
	\ 第 06 天：解析 Git 資料結構 - 物件結構
		
	: file-system-check ( -- ) \ check repository file system integity
		<shell> git fsck</shell> ;

	\ 第 07 天：解析 Git 資料結構 - 索引結構 <----------- 了解 tracked/untracked, modified/unmodified, staged/unstaged 必讀。

	: add-modified ( -- ) \ 忽略 untracked 僅 cache "modified" and "deleted" files.
		<shell> git add -u </shell> ;
		/// 'add' 把檔案加進 cache 準備 commit。原本是 tracked 或 untracked 都
		/// 得經過 add 才會進 cache。別以為只有新檔才需要 add 因為即使是已經 
		/// tracked 的檔案也不會自動進 cache 故也不會自動被 commit 到。

	\ 第 08 天：關於分支的基本觀念與使用方式

	: branch ( [<...>] -- ) \ List all branches. Other commands work *in* a branch.
		s" git branch " char \n|\r word + </shell> ;
		last alias list-branches // ( -- ) List local branches.
		
	: create-branch ( <branch name> -- ) \ Create a new branch.
		s" git branch " BL word + </shell> ;
		/// 不必先 commit，故可以 commit 到新 branch 去。

	: delete-branch ( <branch name> -- ) \ Delete an existing branch.
		s" git branch -d " BL word + </shell> ;
		/// 你不能刪除目前工作的分支，必須先切換到其他分支後，再刪除之。
		/// 沒有執行過「合併」的分支，都不能用本指令進行刪除，必須改用
		/// git branch -D feature （大寫的 -D）才能刪除該分支。

	: list-all-branch ( -- ) \ List all local and remote branches.
		<shell> git branch -a </shell> ;
		/// git branch -a 顯示出所有「本地分支」與「遠端追蹤分支」。
		///     本地分支 : 在透過 git branch 指令執行時所顯示的分支，這
		/// 些分支存在於本地端，而這些分支又常被稱為 主題分支 (Topic 
		/// Branch) 或 開發分支 (Development Branch)，就是因為這些分支
		/// 預設不會被推送到遠端儲存庫，主要用來做開發用途。
		///     遠端分支：顧名思義，遠端分支就是在遠端儲存庫中的分支，
		/// 如此而已。你用 GitHub 是無法存取遠端分支的。
		
	: branch-branch ( <branch name> -- ) \ New a branch and switch over.
		s" git checkout -b " BL word + </shell> ;
		/// 不必先 commit，故可以 commit 到新 branch 去。
		
	: switch-branch ( <branch name> -- ) \ Switch to another branch.
		s" git checkout " char \n|\r word + </shell> ;
		/// "switch branch" and "switch commit" are the same command.
		/// 不必先 commit，故可以 commit 到別的 branch 去。
	last alias checkout // ( <...> -- ) "git checkout" general 
		/// Switch HEAD to another commit, recall a file, .. etc.
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
		s" git diff " char \n|\r word + </shell> ;
		/// diff               => 工作目錄 vs 索引
		/// diff HEAD          => 工作目錄 vs HEAD (代表最新版本 or commit)
		/// diff --cached HEAD => 索引     vs HEAD
		/// diff --cached      => 索引     vs HEAD
		/// diff HEAD^ HEAD    => HEAD^    vs HEAD
		/// diff commit1 commit2 => commit1 vs commit2
		/// 執行 git diff 自動比對出 merge 之後到底哪些檔案的哪幾行發生衝突了。
		/// 從 <<<<<<< HEAD 到 ======= 的內容，代表 HEAD （當前 master 分支的最
		/// 新版）裡發生衝突的內容。從 ======= 到 >>>>>>> hotfixes 的內容，代表
		/// hotfixes 分支裡發生衝突的內容


	\ 第 10 天：認識 Git 物件的絕對名稱

	: log ( -- ) \ Read the simplified commit log, 'q' to stop. Also 'log-verbose'.
		<shell> git log --pretty=oneline --abbrev-commit </shell> ;
		
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
	\ 心得：常見的 'origin' 就是一個 reference, 指到 GitHub。這個 origin 名稱是在 Git 版
	\   本控管中慣用的預設遠端分支的參照名稱，主要目的是用來代表一個遠端儲存庫的 URL 位址。
		
	: reference ( "reference" <pathname> -- ) \ Create or change a reference that points to a GitHub object. 
		BL word ( "reference" "ref-name" ) s" git update-ref " swap + s"  " + swap + </shell> ;
		/// Example of a pathname : refs\refName
		/// GitHub object is usually a commit. Can also be a tree 
		/// or something else that you can find in the .git folder.

	: symbol ( "reference-pathname" <pathname> -- ) \ Create (and change?) a symbolic reference.
		BL word ( "reference-pathname" "symbol-name" ) s" git symbolic-ref " swap + s"  " + swap + </shell> ;
		/// Example of a pathname : refs\symName

	: show-ref ( -- ) \ List all references include symbols.
		<shell> git show-ref</shell> ;

	\ 第 12 天：認識 Git 物件的相對名稱
	
	\ 第 17 天：關於合併的基本觀念與使用方式
	\     當你在工作目錄下建立分支時，可以讓你的系統依據不同的需求分別進行開發，又不互相影響。例如
	\ 你原本穩定的系統可以放在 master 分支中進行開發，而當要修正錯誤時則額外建立一個 bugfix 分支來改
	\ 正軟體錯誤，等 Bugs 修正後，在透過「合併」的方式將 bugfix 分支上的變更重新套用到 master 上面，
	\ 這就是一種主要的使用情境。事實上，執行「合併」動作時，是將另一個分支合併回目前分支，然後再手動
	\ 將另一個分支給移除，這樣才符合「兩個分支合併成一個」的概念。
	\     在 Git 使用合併時，有一個重要的觀念是【合併的動作必須發生在同一個儲存庫中】。請回想一下，
	\ 在任何一個 Git 儲存庫中，都必須存在一個 Initial Commit 物件(初始版本)，而所有其他版本都會跟這
	\ 個版本有關係，這個關係我們稱為「在分支線上的可追蹤物件」(the tracked object on the branch heads)
	\ ，所以你不能將一個儲存庫的特定分支合併到另一個毫不相干的儲存庫的某個分支裡。
	\     合併的時候，如果兩個分支當中有修改到相同的檔案，但只要修改的行數不一樣，Git 就會自動幫你套
	\ 用/合併這兩個變更。但如果就這麼剛好，你在兩個分支裡面改到「同一個檔案」的「同一行」，那麼在合
	\ 併的時候就會引發衝突事件。當合併衝突發生時，Git 並不會幫你決定任何事情，而是將「解決衝突」的工
	\ 作交給「你」來負責，且這些發生衝突的檔案也都會被標示為 unmerged 狀態，合併衝突後你可以用 git 
	\ status 指令看到這些狀態。
	\     Git 指令找出衝突的檔案：執行 git status 或執行 git ls-files -u
	\ 找到之後再用 git diff [filepath] 就可以僅比對其中一個檔案了：

	: merge ( <from commit> -- ) \ Merge the commit(s) into the recent HEAD
		s" git merge " char \n|\r word + </shell> ;
	
	\ 第 24 天：使用 GitHub 遠端儲存庫 - 入門篇
	
	\ Github 端一定要去建立一個 repo 才行，不能憑空就弄上去。用網頁上的功能取得 project URI。
	\ Case A.	在 GitHub 建立一個「沒有版本」的空白 Git 儲存庫，
	\			然後透過 git clone 取得遠端儲存庫，
	\			再建立版本後上傳
	\ Case C. 	在 GitHub 建立一個「有初始化版本」的 Git 儲存庫，
	\			然後透過 git clone 取得遠端儲存庫，
	\			再建立版本後上傳
	\ 最簡單的方法就是利用 GitHub for Windows 工具。你只要點擊 Clone in Desktop 按鈕，(see
	\ https://www.evernote.com/shard/s22/nl/2472143/371b041f-787f-4dad-9075-98ebc870ba8b)
	\ 即可自動啟動 GitHub for Windows 工具幫你下載 Git 專案。clone 是在 local 建「新」repo.
	\ 之後就要用 pull 的從 remote 下來。

	: push.default ( -- ) \ git push 會出現一段提示，告訴你要設定 push.default 這個選項.
		<shell> git config --global push.default simple</shell> ;
		/// 要設定 push.default 這個選項，因為這種簡寫的 git push 方法的預設行為將會
		/// 在 Git 2.0 之後發生改變，建議你透過設定 push.default 選項的方式明確指定 
		/// push 的方法。詳細說明請參見 git help config 的說明文件，搜尋 push.default 
		/// 即可找到相關說明。我建議各位設定成 simple，以利跟日後的 Git 指令列工具的預
		/// 設值相同。
	
	: push ( [<options>] -- ) \ Upload local repo up to the remote repo
		s" git push " char \n|\r word + </shell> ;
		///     假設本地是 GitHub 上 clone 下來的，第一次 upload 所用的命令
		/// 是：git push origin master 。當你第二次建立版本時，直接執行 git push 
		/// 就會自動上傳成功。
		///     git push 將本地儲存庫中目前分支的所有相關物件推送到遠端儲存
		/// 庫中。這個 origin 名稱是在 Git 版本控管中慣用的預設遠端分支的參
		/// 照名稱，主要目的是用來代表一個遠端儲存庫的 URL 位址。
		<comment>
			X:\forthtranspiler [jeforth.3hta]> git push
			fatal: The current branch jeforth.3hta has no upstream branch.
			To push the current branch and set the remote as upstream, use
		
				git push --set-upstream origin jeforth.3hta
		
			X:\forthtranspiler [jeforth.3hta]>
		</comment>

	: push到「空」遠端 ( -- ) \ 當 GitHub 上的 repo 是空的，upload 本地成果上去必須用這個。
		<shell> git push -u origin master</shell> ;
		/// 在 GitHub 上新建的 repo 是空的，連預設的 master 分支都沒有。此時
		/// 下達 git push 指令時必須加上 -u 參數，才能成功地把本地儲存庫上傳
		/// 到 GitHub 上的遠端儲存庫，其指令是 git push -u origin master
	
	\ Github 端一定要去建立一個 repo 才行，不能憑空就弄上去。用網頁上的功能取得 project URI。
	\ Case B. 在 GitHub 建立一個「沒有版本」的空白 Git 儲存庫，
	\         然後直接將現有的本地 Git 儲存庫上傳到指定的 GitHub 專案
	\ Case D. 在 GitHub 建立一個「有初始化版本」的 Git 儲存庫，
	\         然後直接將現有的本地 Git 儲存庫上傳到指定的 GitHub 專案

	: remote ( <...> -- ) \ 對 GitHub 操作
		s" git remote " char \n|\r word + </shell> ;
		///     本地若非 clone 下來的，就必須告訴本地 Git 遠端儲存庫在哪。而如
		/// 果 GitHub 上的 repo 又是空的，這時我們可以輸入:
		///     git remote add origin https://bla/bla/bla.git
		/// 建立一個名為 origin 的 reference 名稱，並指向 URI 位址，也就是我們
		/// 在 GitHub 上的遠端儲存庫位址。接著就可以 push origin master。
		///     但如果 GitHub 上的 repo 不是空的，解決的方法很簡單，只要把遠端
		/// 儲存庫的 master 分支，成功合併回我本地的分支，即可建立兩個不同版本
		/// 庫之間的關聯，這樣你就可以把本地的 master 分支推送到 GitHub 上遠端
		/// 儲存庫的 master 分支了。「合併回我本地」用 pull or fetch + merge。
		/// [ ] 疑問：怎麼不直接 merge 下來？
		/// 這個 origin 名稱是在 Git 版本控管中慣用的預設遠端分支的參照名稱，
		/// 主要目的是用來代表一個遠端儲存庫的 URL 位址。

	: pull ( <...> -- ) \ Get repo from GitHub and merge to local.
		s" git pull " char \n|\r word + </shell> ;
		/// 將遠端儲存庫的 master 分支取回，並合併到本地儲存庫的 master 分支:
		///	使用 git pull origin master 指令
		/// git pull 將遠端儲存庫的最新版下載回來，下載的內容包含完整的物件儲
		/// 存庫(object storage)。並且將遠端分支合併到本地分支。(將 origin/master 
		/// 遠端分支合併到 master 本地分支) 所以一個 git pull 動作，完全相等
		/// 於以下兩段指令：
		///     git fetch
		///     git merge origin/master
		
	: fetch  ( <...> -- ) \ Get repo from GitHub w/o merge.
		s" git fetch " char \n|\r word + </shell> ;
		/// 將遠端儲存庫的 master 分支取回，並合併到本地儲存庫的 master 分支:
		///	使用 git fetch 指令後再執行 git merge origin/master 合併動作。
		///     git fetch 將遠端儲存庫的最新版下載回來，下載的內容包含完整的
		/// 物件儲存庫(object storage)。 這個命令不包含「合併」分支的動作。

	\ 第 25 天：使用 GitHub 遠端儲存庫 - 觀念篇

	<comment>
	Q: 	依您附圖，紅色部分都是 remotes .... 怎麼會是「本地追蹤分支」？
		https://github.com/doggy8088/Learn-Git-in-30-days/issues/8#issuecomment-91797074
	A: 	2015-04-11 17:12 GMT+08:00 Yue Lin Ho <notifications@github.com>:
		More note: it is on day 25.

		Pro Git 3.5

		Remote Branches
		Remote branches are references (pointers) to the state of branches in your remote repositories. 
		They’re local branches that ...
		中文版 Pro Git 3.5

		遠端分支
		遠端分支（remote branch）是對遠端倉庫中的分支的索引。
		它們是一些無法移動的本地分支...
		重點在於: 雖然是用 remotes 字眼做 prefix, 但它們存在於 本地(實際上是一種 local branches)
		它的特性是要標示遠端的版本庫有一個本地分支, 你可以這樣子想它:
		remotes/origin/master -> 遠端(remotes)版本庫(給它取名叫origin)有一個master分支

		假設, 遠端版本庫有一個本地分支叫 abc
		你clone時,
		本地版本庫為了記錄遠端版本庫有個 abc 指到某個 commit 上,
		會在本地版本庫會產生一個 remotes/origin/abc, 並同時也指向那個 commit 上
		當你在本地版本庫的這個 commit 上, 或者 remotes/origin/abc 上產生一個本地分支 abc 時,
		本地版本庫的本地分支 abc 和 remotes/origin/abc 之間會自動產生一個 "追蹤" 闗係

		更詳盡的 "跟蹤" 的概念, 請參考 這裡
		當一個本地分支(master)與遠端分支(remotes/origin/master)之間有 "跟蹤" 關係時, 才會用這個詞
		—
		Reply to this email directly or view it on GitHub.
	</comment>
	
	: 手動加入一個「遠端儲存庫」 ( <tagName> <URI> -- )
		s" git remote add " char \n|\r word + </shell> ;
		/// 事實上你可以在你的工作目錄中，建立多個遠端儲存庫的參照位址。
		/// 看不太懂。see 第 25 天：使用 GitHub 遠端儲存庫 - 觀念篇
	
	: list-uri ( -- ) \ List associated URIs on GitHub.com
		<shell> git remote -v </shell> ;
		
	\ 第 26 天：多人在同一個遠端儲存庫中進行版控	
		





: ver ( -- ) \ Git version
	<shell> git --version</shell> ;
	/// 請確定你的 git 版本是在 1.7.10以上。
	/// http://jlord.us/git-it/challenges-zhtw/get_git.html

: config ( -- ) \ The 'git config' general
	s" git config " char \n|\r word + </shell> ;

: list-config ( -- ) \ List the entire configuarations
	<shell> git config -l</shell> ;

: 設定你的名字 ( -- ) \ Setup the user name
	s" git config --global user.name " BL word + </shell> ;
	/// 讓 Git 知道這台電腦所做的修改該連結到什麼使用者
	
: 設定你的電子信箱 ( -- ) \ Setup the user's email address
	s" git config --global user.email " BL word + </shell> ;
	/// 讓 Git 知道這台電腦所做的修改該連結到什麼使用者
	
	






