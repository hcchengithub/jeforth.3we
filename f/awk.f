
	\ AWK.f  jeforth to support AWK features


	s" awk.f"	source-code-header

	\ -------------------------------------------------------------------------------------------------------------------

	: <search> 	( "source" <RegEx> -- "source" "RegEx" "" ) \ Locate position of RegEx in "source" string. -1 not found
		char </search>|<igm>|<flags> word
		compiling if literal compile "" else "" then 
		; immediate
		/// s" source" <search> regex [<flags> igm] </search> ==> index or -1

	: <igm> ( "source" <RegEx> "" -- "source" "RegEx" igm ) \ Get flags (i, g, m, ig, gm, im, igm) of RegEx
		compiling if compile drop else drop then 
		char </search>|</match>|<to> word 
		compiling if literal then 
		; immediate
		/// <igm> or <flags> alias.
		/// s" source" <search> regex [<flags> igm] </search> ==> index or -1

	' <igm> alias <flags> immediate // ( "source" <RegEx> "" -- "source" "RegEx" igm ) Get flags (i, g, m, ig, gm, im, igm) of RegEx
		/// Alias of <igm>
		/// Usage: <search> regex[<flags> igm]</search>

	code </search> ( "source" "RegEx" "flags" -- int|-1 ) \ Delimiter of <search>
		// forthConsole("f>");
		var flags = pop().replace(/\s*$/,''); // remove tailing white spaces
		var pattern = pop().replace(/\s*$/,''); // remove tailing white spaces
		var source = pop();
		var re = new RegExp(pattern,flags) 
		push(source.search(re));
		end-code 
		/// s" source" <search> regex [<flags> igm] </search> ==> index or -1

	<selftest>
		marker ---
		*** <search> RegEx<flags> igm</search>
		s" 11 22 33 44 55 66" <search> 33</search> \ 6
		s" aa bb cc dd AAA BBB CCC DDD " <search> cc</search> \ 6
		s" aa bb cc dd AAA BBB CCC DDD " <search> ccc<flags> i</search> \ 20
		: test1 <search> 33</search> ; 
		char 23423sdf4628933629349287923426 last execute \ 13
		: test2 <search> 3..3</search> ;
		char 234234628933629349287923426 last execute \ 1
		: test3 s" aa bb cc dd AAA BBB CCC DDD " <search> c.+ddd<flags> ig</search> ; last execute \ 6
		: test4 s" aa bb cc dd AAA BBB CCC DDD " <search> c.?ddd<flags> i</search> ; last execute \ 22
        [d 6,6,20,13,1,6,22 d] [p '<search>','<flags>','<igm>','</search>' p]
		---
	</selftest>
	\ -------------------------------------------------------------------------------------------------------------------

	: <indexof> ( "source" <substr> -- "source" "substr" 0 ) \ Position substring first occurs within String. -1 not found
		char </indexof>|<start> word 
		compiling if literal 0 literal else 0 then 
		; immediate
		/// Usage: "source" <indexof> "sub-string"[<start> n]</indexof> ( -- position|-1 ) -1 not found, or position of sub-string.

	: <start> 	( "source" "substr" n -- "source" "substr" n' ) \ The index to begin searching within the string, default 0.
		compiling if compile drop else drop then 
		char </indexof>|</lastindexof> word 1 * 
		compiling if literal then 
		; immediate
		/// Usage: "source" <indexof> "sub-string"[<start> n]</indexof> ( -- position|-1 ) -1 not found, or position of sub-string.

	code </indexof> ( "source" "substr" n -- int|-1 ) \ Delimiter of <indexof>
		var start = pop();
		var subs = pop();
		var source = pop();
		push(source.indexOf(subs,start));
		end-code 
		/// Usage: "source" <indexof> "sub-string"[<start> n]</indexof> ( -- position|-1 ) -1 not found, or position of sub-string.

	<selftest>
		*** <indexof> "sub-string"[<start> n]</indexof> returns the index or -1
		marker ~selftest~
		s" 11 22 33 44 55 66" s" 33" 0 </indexof> \ 6 
		s" 11 22 33 44 55 66" <indexof> 33</indexof> \ 6
		s" aa bb cc dd AAA BBB CCC DDD " <indexof> cc</indexof> \ 6 
		s" aa bb cc dd AAA BBB CCC DDD " <indexof> cc<start> 7</indexof> \ -1
		s" aa bb cc dd AAA BBB CCC DDD " <indexof> CC<start> 7</indexof> \ 20
		: test1 <indexof> 33</indexof> ; 
		char 23423sdf4628933629349287923426 last execute \ 13
		: test2 s" aa bb cc dd AAA BBB CCC DDD " <indexof> CC</indexof> ; last execute \ 20
		: test3 s" aa bb cc dd AAA BBB CCC DDD " <indexof> cc</indexof> ; last execute \ 6
		[d 6,6,6,-1,20,13,20,6 d] [p '<indexof>','</indexof>','<start>' p]
		~selftest~
	</selftest>
 
	\ -------------------------------------------------------------------------------------------------------------------

	: <lastindexof> 	( "source" <substr> -- "source" "substr" length ) \ Position substring last occurs within String. -1 not found
		char </lastindexof>|<start> word 
		compiling if 
			literal compile over compile count compile swap compile drop 
		else 
			over count swap drop 
		then 
		; immediate
		/// Usage: "source" <lastindexof> "sub-string"[<start> n]</lastindexof> ( -- position|-1 ) -1 not found, or position of sub-string.

	code </lastindexof> ( "source" "substr" n -- int|-1 ) \ Delimiter of <lastindexof>
		var start = pop();
		var subs = pop();
		var source = pop();
		push(source.lastIndexOf(subs,start));
		end-code 
		/// Usage: "source" <lastindexof> "sub-string"[<start> n]</lastindexof> ( -- position|-1 ) -1 not found, or position of sub-string.

	<selftest>
		*** <lastindexof> "sub-string"[<start> n]</lastindexof> returns index or position of sub-string or -1
		marker ~selftest~
		s" 11 22 33 44 55 33 66" s" 33" 10000 </lastindexof> \ 15
		s" 11 22 33 44 55 33 66" <lastindexof> 33</lastindexof> \ 15
		s" aa bb cc dd AAA BBB CCC DDD " <lastindexof> cc</lastindexof> \ 6
		s" aa bb cc dd AAA BBB CCC DDD " <lastindexof> cc<start> 7</lastindexof> \ 6
		s" aa bb cc dd AAA BBB CCC DDD " <lastindexof> CC<start> 7</lastindexof> \ -1
		: test1 <lastindexof> 33</lastindexof> ; 
		char 23423sdf46289336293492879233426 last execute \ 26
		: test2 s" aa bb cc dd AAA BBB CCC DDD " <lastindexof> CC</lastindexof> ; last execute \ 21
		: test3 s" aa bb cc dd AAA BBB CCC DDD " <lastindexof> cc</lastindexof> ; last execute \ 6
		[d 15,15,6,6,-1,26,21,6 d] [p '<lastindexof>','</lastindexof>','<start>' p]
		~selftest~
	</selftest>

	\ -------------------------------------------------------------------------------------------------------------------

	: <match> 	( "source" <RegEx> -- "source" "RegEx" "" ) \ Search "source" returns an object {["match",..],input,index}
		char </match>|<igm>|<flags> word 
		compiling if literal compile "" else "" then 
		; immediate
		/// Usage: "source" <match> "regex"[<flags> "igm"]</match> ( -- ["match",..] ) 

	code </match> ( "source" "EegEx" "flags" -- {["match",..],input,index} ) \ Delimiter of <match>
		var flags = pop();
		var pattern = pop();
		var source = pop();
		var re = new RegExp(pattern,flags) 
		push(source.match(re));
		end-code 
		/// Usage: "source" <match> "regex"[<flags> "igm"]</match> ( -- {["match",..],input,index} ) 

	<selftest>
		marker ~selftest~
		*** <match> "regex"[<flags> "igm"]</match> returns an object contains matched string(s) ...
		s" aaa : bb : ccc " <match> \s*(d*?)\s*:\s*(.*?)\s*:\s*(.*?)\s* <flags> m</match> \  [": bb : ccc ",,"bb","ccc"]
		js> tos().index swap \ 3 
		<js> [" : bb : ccc ","","bb","ccc"]</jsV> isSameArray \ true
		s" 11 22 33 44 55 33 66" <match> 66</match> js> pop().index 
		s" aa bb cc dd AAA BBB CCC DDD " <match> cc</match> js> pop().index
		s" aa bb cc dd AAA BBB CCC DDD " <match> cc<flags> i</match> js> pop().index
		s" aa bb cc dd AAA BBB CCC DDD " <match> CC<flags> ig</match> js> pop().length
		: test1 <match> 33</match> ; 
		char 23423sdf46289336293492879233426 last execute js> pop().index
		: test2 s" aa bb cc dd AAA BBB CCC DDD " <match> CC</match> ; last execute js> pop().index
		: test3 s" aa bb cc dd AAA BBB CCC DDD " <match> cc</match> ; last execute js> pop().index
		[d 3,true,18,6,6,2,13,20,6 d]
		[p '<match>','</match>','<flags>' p]
		~selftest~
	</selftest>
 
	\ -------------------------------------------------------------------------------------------------------------------

	: <replace> 	( "source" <RegEx> -- "source" "RegEx" "" ) \ Returns a new string with text replaced.
		char <igm>|<flags>|<to> word 
		compiling if literal compile "" else "" then 
		; immediate
		/// Usage: "source" <replace> "regex"[<flags> "igm"]<to> "replaceText"</replace> ( -- ["replace",..] ) 

	code literal>escape ( "literal" -- "escape" ) \ Convert literal string's escape patterns into escape charaters.
		var source = pop();
		source = source.replace(/\\n/g,'\n');
		source = source.replace(/\\r/g,'\r');
		source = source.replace(/\\t/g,'\t');
		source = source.replace(/\\v/g,'\v');
		source = source.replace(/\\f/g,'\f');
		push(source);
		end-code
		/// Escape charaters are \n \r \t \v \f ,
		/// Do I have escape>literal ? No, not yet at v2.07, 17:38 2013/5/12. 

	: <to> 	( "source" <RegEx> -- "source" "RegEx" "" ) \ Get replace text of <replace> clause
		char </replace> word literal>escape
		compiling if literal then 
		; immediate
		/// Usage: "source" <replace> "regex"[<flags> "igm"]<to> "replaceText"</replace> ( -- ["replace",..] ) 

	code </replace> ( "source" "EegEx" "flags" "replaceText" -- "replaced" ) \ Delimiter of <replace>
		var replaceText = pop();
		var flags = pop().replace(/\s*$/,''); // remove tailing white spaces
		var pattern = pop().replace(/\s*$/,''); // remove tailing white spaces
		var source = pop();
		var re = new RegExp(pattern,flags) 
		push(source.replace(re,replaceText));
		end-code 
		/// Usage: "source" <replace> "regex"[<flags> "igm"]<to> "replaceText"</replace> ( -- ["replace",..] ) 

	<selftest>
		*** <replace> "regex"[<flags> "igm"]<to> "replaceText"</replace>
		marker ~selftest~
		s" 11 22 33 44" s" 33" s" i" s" EEEE" </replace> \ "11 22 EEEE 44"
		s" 11 22 33 44 55 33 66" <replace> 3+<to> 99</replace> \ "11 22 99 44 55 33 66"
		s" aa bb cc dd AAA BBB CCC DDD " <replace> cc<flags> i<to> pp</replace> \ "aa bb pp dd AAA BBB CCC DDD "
		s" aa bb cc dd AAA BBB CCC DDD " <replace> CC<flags> ig<to> pppp</replace> \ "aa bb pppp dd AAA BBB ppppC DDD "
		: test1 <replace> 33<to> EEEE</replace> ; 
		char 23423sdf46289336293492879233426 last execute \ "23423sdf46289EEEE6293492879233426"
		: test2 s" aa bb cc dd AAA BBB CCC DDD " <replace> CC<flags> ig<to> PPPP</replace> ; last execute \ "aa bb PPPP dd AAA BBB PPPPC DDD "
		[d
			"11 22 EEEE 44",
			"11 22 99 44 55 33 66",
			"aa bb pp dd AAA BBB CCC DDD ",
			"aa bb pppp dd AAA BBB ppppC DDD ",
			"23423sdf46289EEEE6293492879233426",
			"aa bb PPPP dd AAA BBB PPPPC DDD "
		d]
		[p '<replace>','</replace>','<to>','literal>escape' p]
		~selftest~
	</selftest>

<comment>
	 
	舊筆記、想法, debug log

	\ -------------------------------------------------------------------------------------------------------------------
	Demo 1/16'15
	cls 1.txt <match> \n\[ \].*<flags> img</match> .
	cls 1.txt <match> \n\[ \].*\r\n.*<flags> img</match> .
	1.txt js> pop().slice(25318,25400)
	1.txt <search> 已經</search> .
	1.txt <search> \[ \]</search> .
	1.txt <search> \[ \]</search> 2- 1.txt js> pop().slice(pop()).charCodeAt(0) \ ==> 13 (number)
	1.txt <search> \[ \]</search> 1- 1.txt js> pop().slice(pop()).charCodeAt(0) \ ==> 10 (number)
	
	\ -------------------------------------------------------------------------------------------------------------------

	\s
	execute this line twice ,
		: test2 [ char before> *debug* ] s" aa bb cc dd AAA BBB CCC DDD " <match> CC</match> [ char after> *debug* ] ; last execute
	the first time leaves [["CC"]] , the 2'nd time too. But they are different.

	Now I found, both the first time and the 2nd time are objects. *Objects* with same properties are still different things.
	That's not the most strange thing. The most strange thing is that the first time was OK!!! While the stack was empty. After
	the last execute , the [["CC"]] appears. Then the second time complains about the stack is changed during colon definition.
	Why? Is it possible that the *thing* is exactly same, only because of the awy the : definition saves the stack is not suitable
	for the object that makes the comparsion failed after all. To deal with the problem, other than fixing the problem around
	the compasion, we can change the result from object array into string array. Simply because the result Object properties are
	not usable at all. They are , 

	Now back to the question of why [["CC"]] !== [["CC"]] ?? Try to use the same method to copy the stackwas and then compare
	to itself.

	code s==s ( a b -- boolean )
		var a = pop(), b = pop();
		function compare(a,b)
		{
			if (a.length != b.length) {
	push("length!=");
				return false;
			} else {
				for (var i=0; i < a.length; i++){
					var ta = typeof(a[i]);
					var tb = typeof(b[i]);
					if (ta == tb) {
						if (ta == "number"){
							if (isNaN(a[i]) && isNaN(b[i])) continue; // because (NaN == NaN) 的結果是 false 所以要特別處理。
						}
						if (ta == "object") {  // 怎麼比較 obj? v2.05 之後用 memberCount()
							if (memberCount.call(a[i]) != memberCount.call(b[i])) {
	push("member count !=");
								return false;
							}
						} else if (a[i] != b[i]){
	push("a[i] != b[i]");
							return false;
						}
					} else if (a[i] != b[i]) {
	push("a[i] != b[i]");
						return false;
					}
				}
				return true;
			}
		}
		push(compare(a,b))
	end-code

	js> one js> two s==s tib.

	js> memberCount.call(two[0]) tib. \ ==> 4 (number)
	js> memberCount.call(one[0]) tib. \ ==> 1 (number)

	js> memberCount.call(two) tib. \ ==> 4 (number)
	js> memberCount.call(one) tib. \ ==> 1 (number)

	js> memberCount.call(two) tib. \ ==> 1 (number)
	js> memberCount.call(one) tib. \ ==> 1 (number)

	the two is really an object,
		self-test-failed>> js> two[0] (see)
		input : aa bb cc dd AAA BBB CCC DDD  (string)
		index : 6 (number)
		lastIndex : 8 (number)
		0 : cc (string)

	which has four elements! I guess that's exactly what match() returns. ==> prove it _______
	Simply have match() to match something ... 

		js>dumpObj( ss.match(/dl/))
		input : sdfsjdlfsdj (string)
		index : 5 (number)
		lastIndex : 7 (number)
		0 : dl (string)

	.... it's true!!!! So, is this a miss-judgement? 


</comment>










