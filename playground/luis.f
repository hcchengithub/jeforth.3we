
	s" luis.f" source-code-header
    
    \ My LUIS endpoint URL, the key is subject to be changed
        <js>
            "https://westus.api.cognitive.microsoft.com/luis/v2.0/apps/023ebea1-16f6-46ba-a1d9-8869025bf68b?subscription-key=e06b331fc1eb4253805197301ea2eed7&staging=true&verbose=true&timezoneOffset=480&q="
        </jsV> value luis-endpoint-url // ( -- "url" )

    \ Send the request to LUIS server 

		: (luis) ( "input" -- response T/f ) \ Send a string to LUIS and get the analysed results
			js> encodeURI(pop()) luis-endpoint-url swap + ( url )
			\ encodeURI() https://stackoverflow.com/questions/7416328/convert-utf-8-string-to-url-ajax 
			<js> 
			if (vm.appname=="jeforth.3hta") $.support.cors=true;  // Overcome the Cross Domain problem https://stackoverflow.com/questions/9160123/no-transport-error-w-jquery-ajax-call-in-ie
			$.ajax({type: "GET",url: pop()})
				.done(function(response){
						push(response);
						push(true);
						execute("stopSleeping");
					})
				.fail(function(error){
						push(error);    
						push(false);
						execute("stopSleeping");
					});
			</js> 
			120000 sleep 50 nap \ LL from 3htm's readtextfile.f 
			;

		: luis ( <input> -- response T/f ) \ Send rest of the TIB to LUIS and get the analysed results
			CR word ( line ) \ the given sentence
			(luis) ( resp T/f )
			not if ." LUIS endpoint error!" else 
				." LUIS has successfully analysed the sentence." cr
			then (see) ;
		
		<comment>
			LUIS  https://www.luis.ai/applications
			My key : e06b331fc1eb4253805197301ea2eed7 (free temparatory https://www.luis.ai/home/keys)
			My endpoint : https://westus.api.cognitive.microsoft.com/luis/v2.0/apps/023ebea1-16f6-46ba-a1d9-8869025bf68b?subscription-key=e06b331fc1eb4253805197301ea2eed7&staging=true&verbose=true&timezoneOffset=480&q=
		</comment>
