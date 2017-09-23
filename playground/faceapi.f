
	s" faceapi.f" source-code-header
	
	\ ==== All you need to provide are here ====

    \ Request parameters, you can change them 
	
        <js>
            ({
                "returnFaceId": "true",
                "returnFaceLandmarks": "false",
                "returnFaceAttributes": "age,gender,headPose,smile,facialHair,glasses,emotion,hair,makeup,accessories"
            })
        </jsV> value parameters-on-Request-URL // ( -- hashTable ) 
        
    \ Picture URL
	
        s" https://upload.wikimedia.org/wikipedia/en/d/d0/Hippolyta_%28DC_Comics%29_as_WW_-_from_WW_v2_i130.png"
        value picture-url // ( -- "url" ) Default is a wonder woman from wikipedia

        : show-the-picture ( -- ) \ View picture-url
			<text> <img src="_pic_"]/></text> 
			:> replace(/_pic_/,vm[context]["picture-url"]) 
			</o> drop cr ;

    \ Azure resource subscription-key (paied account to call the service)
    
        char 5f5f04717cb641e0aa54ca03c9a5dfe0 value subscription-key 
		// ( -- "key") hcchen's Azure cognitive services resource subscription-key
    
	\ ==== Now prepare to send the request to Azure server ====
    
    \ Request URL
	
        parameters-on-Request-URL <js>
            "https://southeastasia.api.cognitive.microsoft.com/face/v1.0/detect?" + $.param(pop())
        </jsV> value request-url // ( -- "url" )
		
		"" value request-body // ( -- "body" ) ajax request data field

    \ Send the request to Azure server 

		: (faceapi) ( "picture url" -- response T/f ) \ Send a picture to Face API and get the analysed results
			dup to picture-url ( picture-url )
			js> ('{"url":"_pic_"}').replace(/_pic_/,pop())  ( request-body ) to request-body
			<js> 
			if (vm.appname=="jeforth.3hta") $.support.cors=true;  // Overcome the Cross Domain problem https://stackoverflow.com/questions/9160123/no-transport-error-w-jquery-ajax-call-in-ie
			$.ajax({
				url: vm[context]["request-url"],
				beforeSend: function(xhrObj){
					// Request headers
					xhrObj.setRequestHeader("Content-Type","application/json");
					xhrObj.setRequestHeader("Ocp-Apim-Subscription-Key",vm[context]["subscription-key"]);
					},
				type: "POST",
				data: vm[context]["request-body"]
			})
			.done(function(response) {
					push(response);
					push(true);
					execute("stopSleeping");
				})
			.fail(function(error) {
					push(error);    
					push(false);
					execute("stopSleeping");
				});
			</js>
			120000 sleep 50 nap \ LL from 3htm's readtextfile.f 
			;
			
		: faceapi ( <picture url> -- response T/f ) \ Send a picture to Face API and get the analysed results
			CR word ( line ) \ the given picture URL 
			js> tos()=="" if drop picture-url then \ idiot proof
			(faceapi) ( resp T/f ) show-the-picture cr 
			not if ." Face detection failed!" else 
				js> tos().length . ."  faces are successfully detected."
			then cr (see) ;

		<comment>
			Face API - V1.0 reference
			https://southeastasia.dev.cognitive.microsoft.com/docs/services/563879b61984550e40cbbe8d/operations/563879b61984550f30395236/console
			My key : 5f5f04717cb641e0aa54ca03c9a5dfe0
			returnFaceAttributes=age,gender,headPose,smile,facialHair,glasses,emotion,hair,makeup,occlusion,accessories,blur,exposure,noise"
			大頭照 <o> <img src="https://upload.wikimedia.org/wikipedia/en/d/d0/Hippolyta_%28DC_Comics%29_as_WW_-_from_WW_v2_i130.png"/> </o>
			data = '{"url":"https://upload.wikimedia.org/wikipedia/en/d/d0/Hippolyta_%28DC_Comics%29_as_WW_-_from_WW_v2_i130.png"}'
			Examples:
				cls faceapi http://old.communityjournal.net//wp-content/uploads/2013/10/HAPPY-PEOPLE-iStock.jpg
				cls faceapi http://tse4.mm.bing.net/th?id=OIP.6R81A97uBqgASEgviEUkigD6D6&pid=15.1
		</comment>
