
	s" proe.f" source-code-header

	: -->   ( result -- ) \ Print the result with the command line.
			js> tib :> substring(0,ntib) ( result tib' )
			dup :> lastIndexOf("\n") ( result tib' idxLastCR )
			swap :> substring(Math.max(0,pop()),ntib) ( result tib" )
			trim . space char \ . space . cr ;

	include.js creoson_creo.js \ 

[X] 2020/03/21 15:02:24 忘了外掛的 .js 該怎麼處理。先找找看看 numeric-1.2.6.js 又是怎麼用的?
	c:\Users\8304018\Documents\GitHub\jeforth\jeforth.3hta\external-modules\numeric\numeric-1.2.6.js 
	c:\Users\8304018\Documents\GitHub\jeforth\jeforth.3hta\3htm\f\numeric.f 
	--> 已經寫好 numeric.f 用 include numeric.f 就可以了，flot 也是這樣用。我好棒！
	--> 直接把 CREOSON 的 .js copy-paste 放進 <js></js> 裡跑跑看。。。。 
		> include.js creoson_creo.js \ 用這個方式跟 copy'n paste to <js></js> 是等效的，但是會出問題：
		JavaScript error on word "sinclude.js" : Expected ';'
		--> 原因是 creoson_???.js 中有用到很多新的 keyword "let" 而 HTA (JScript v11.0.16384) 不認得。
		--> 解法是把所有 .js files in \web\assets\creoson_stuff\creoson_js 裡的 let 改成 var 就好了。
[X] 2020/03/21 20:23:56 不只 let 連 Object 的 support 也不全，算了，別用 HTA for Creoson 了。
	-->	改用 3ca 好了。





<comment>
	\ 取得 pfcls object 不必先跑 pro/e 表示這個 class 是 install 時登記的。
	<js>
		try {
			obj = new ActiveXObject("pfcls.pfcAsyncConnection");
		}
		catch (e) {
			type("Failed to create object");
			obj = null  
		}
		push(obj)
	</js> constant cAC // ( -- obj ) 取得 pro/e API AsyncConnection
	
	cAC --> \ [object Object]
	cAC :> Connect --> \ undefined
  \ cAC :> Connect("","",".",5) --> \ JavaScript error : pfcExceptions::XToolkitNotFound <-- when pro/e is not run or not authorized
	cAC :> Connect("","",".",5) constant conn // ( -- obj ) pfcls connection object
	conn :> session constant session // ( -- obj ) pfcls session 

	session :> CurrentModel.GenericName   --> 
	session :> CurrentModel.InstanceName  --> 
	session :> CurrentModel.Type          --> 
	session :> CurrentModel.Host          --> 
	session :> CurrentModel.Device        --> 
	session :> CurrentModel.Path          --> 
	session :> CurrentModel.FileVersion   --> 
  \ session :> CurrentModel.GetFullName() -->  no such method!!
	session :> CurrentModel.FullName      --> 

	CCpfcAsyncConnection.Start()
	IpfcAsyncConnection.End()

	\ List parameters of the current model 
	session :> CurrentModel.ListParams() constant ListParams // ( -- obj ) pramameters of the model
	<js>
	params = vm.v('ListParams')
	for (i=1; i < params.count; i++){
		param = params(i)
			type(param.name + " : ")
		switch(param.value.discr) {
			case 0: /* StringValue */
				type(param.value.StringValue);
				break
			case 1: /* IntValue */
				type(param.value.IntValue);
				break
			case 2: /* BoolValue */
				type(param.value.BoolValue);
				break
			case 3: /* DoubleValue */
				type(param.value.DoubleValue);
				break
		}
		type("\n")
	}
	</js>
	
	\ 終於讀出 parameters 了
	session :> GetModel("prt0009.PRT",1) constant prt0009.prt // ( -- ) object of the model
	prt0009.prt :> getparam('length').value.DoubleValue --> \ 23
	prt0009.prt :> getparam('width').value.DoubleValue --> \ 54
	prt0009.prt :> getparam('height').value.DoubleValue --> \ 67

	<text>
	pfcAnalysisFeat
	pfcAnnotationFeat
	pfcAreaNibbleFeat
	pfcArgument
	pfcArtworkFeat
	pfcAssembly
	</text> :> split("\n") constant allModules // ( -- [...] ) all modules 	
	<js>
		am = vm.v('allModules')
		for (i=0; i < am.length; i++){ 
			m = "pfcls." + am[i].trim()
			type(m)
			try {
				obj = new ActiveXObject(m);
			}
			catch (e) {
				type(" <-- Failed to create object: " + m);
				obj = null  
			}
			type("\n")
		}
	</js>

> js> vm.argv .
"C:\Users\8304018\OneDrive\OneNote,Notebooks\Work2020(local)\attachments\proeforth\proeforth.hta",nop >>> 
> <js> (vm.argv.slice(1)).join(" ") </jsV> . 
Notebooks\Work2020(local)\attachments\proeforth\proeforth.hta" nop >>> 
> <js> (hta.commandLine + " dummy").split(/\s+/).slice(0,-1) </jsV> .
"C:\Users\8304018\OneDrive\OneNote,Notebooks\Work2020(local)\attachments\proeforth\proeforth.hta",nop >>> 
> <js> (hta.commandLine + " dummy").split(/\\/).slice(0,-1) </jsV> .
"C:,Users,8304018,OneDrive,OneNote Notebooks,Work2020(local),attachments,proeforth >>> 



1. 	hta.commandLine string 1st item is program "pathname" that can be obtained by 
	<js> (hta.commandLine + " dummy").split(/\"/) </jsV> (see)
	[
    "", // 第一個丟掉
    "C:\\Users\\8304018\\OneDrive\\OneNote Notebooks\\Work2020(local)\\attachments\\proeforth\\proeforth.hta", // 第二個就是 pathname
    "  nop 111 222 333 444      dummy" // 第三個就是其他 arguments 
	]
2. 	這樣切就對了
	dropall 
	<js> (hta.commandLine + " dummy").split(/\"/).slice(1) </jsV> 
	dup :> [0] swap :> [1] trim :> split(/\s+/).slice(0,-1) .s
3.  合併成 args array 
	js: tos().unshift(pop(1))
</comment>