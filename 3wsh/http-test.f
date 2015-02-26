
	\ Works fine on jeforth.3hta no matter url is www.ibm.com or localhost:8888
	\ Works on jeforth.3wsh if url is http://localhost:8888 even when w/o a local web 
	\ server! means 3wsh can be even driven too.
	
	\ http://www.w3school.com.cn/xml/xml_http.asp
	js> kvm.appname=="jeforth.3wsh" [if]
		<js> new ActiveXObject("Microsoft.XMLHTTP") </jsV> constant XMLHTTP // ( -- xmlhttp ) DOM object, old method
	[else]
		<js> new window.XMLHttpRequest()</jsV> constant XMLHTTP // ( -- xmlhttp ) DOM object, new method
	[then]

	"" value url // ( -- string ) Web address URL 
	
	XMLHTTP :: onreadystatechange=function(){execute("statusChanged")}
	
	: statusChanged ( -- ) \ XMLHTTP status
		." XMLHTTP readyState changed : " XMLHTTP :> readyState . cr
		XMLHTTP :> readyState 4 = if
			XMLHTTP :> status dup ." XMLHTTP :> status : " . cr
			200 = if
				XMLHTTP :> responseText .
			else
				." Problem retrieving XMLHTTP data:" XMLHTTP :> statusText . cr
			then
		then ;	
		
	: get ( "url" -- ) \ Get a thing from url through http protocal
		to url
		url XMLHTTP :: open("GET",pop(),true)
		XMLHTTP :: send(null)
	;

	char http://www.ibm.com get
	
	\ XMLHTTP :: open("GET","http://www.ibm.com",true)
	\ XMLHTTP :: send(null)
	
	