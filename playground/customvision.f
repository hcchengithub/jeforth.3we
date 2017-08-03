
	s" customvision.f" source-code-header
    
    \ My Custom Vision endpoint URL 
		\	( Iteration 1 ) s" https://southcentralus.api.cognitive.microsoft.com/customvision/v1.0/Prediction/e3a282d7-af7f-41d1-a0c5-d8b6c7db8f78/url?iterationId=e3b96da0-0d6a-49b7-bae7-70acf2493e3f"
		\	( Iteration 2 ) s" https://southcentralus.api.cognitive.microsoft.com/customvision/v1.0/Prediction/e3a282d7-af7f-41d1-a0c5-d8b6c7db8f78/url?iterationId=45d2605c-4f74-4491-9ff0-7362cbb77098"
			( Default     ) s" https://southcentralus.api.cognitive.microsoft.com/customvision/v1.0/Prediction/e3a282d7-af7f-41d1-a0c5-d8b6c7db8f78/"
			value custom-vision-endpoint // ( -- "base url" )

    \ Picture URL if the picture is on the net
	
        \ ( fire ) 		s" https://www.evernote.com/shard/s22/sh/6d90631c-04e7-4ab7-a735-77b6c4373e68/fd3c8b1d9dfe9902/res/867b6f21-f68f-4ac4-b4d4-90287244d916/P_20170705_201548.jpg?resizeSmall&width=832"
	 	\ ( no fire )	s" https://www.evernote.com/shard/s22/sh/6d90631c-04e7-4ab7-a735-77b6c4373e68/fd3c8b1d9dfe9902/res/c46d8597-2380-4b99-bfe9-bfdf13b9eb9d/P_20170705_201354.jpg?resizeSmall&width=832"

        : show-the-picture ( -- ) \ View picture-url
			<text> <img src="_pic_"]/></text> 
			:> replace(/_pic_/,vm[context]["picture-url"]) 
			</o> drop cr ;

        "" value picture-url  // ( -- "url" ) 
		"" value request-body // ( -- "body" ) ajax request data field that gives the picture url 
		{} value response     // ( -- object ) response from ajax request to Custom Vision services
		
			
    \ Send the request to Custom Vision server 

		: (custom-vision) ( "picture url" -- response T/f ) \ Send a picture URL to Custom Vision and get the analysed results
			dup to picture-url ( picture-url )
			js> ('{"url":"_pic_"}').replace(/_pic_/,pop())  ( request-body ) to request-body
			<js> 
			if (vm.appname=="jeforth.3hta") $.support.cors=true;  // Overcome the Cross Domain problem https://stackoverflow.com/questions/9160123/no-transport-error-w-jquery-ajax-call-in-ie
			$.ajax({
				url: vm[context]['custom-vision-endpoint']+"url",
				beforeSend: function(xhrObj){
					xhrObj.setRequestHeader("Content-Type","application/json");
					xhrObj.setRequestHeader("Prediction-Key", "8ef4041938284124a45dcb10b9572fb2");
					},
				type: "POST",
				data: vm[context]["request-body"]
				})
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

		: custom-vision ( <picture url> -- response T/f ) \ Send picture URL to Custom Vision and get the analysed results
			CR word ( line ) \ the given URL
			js> tos()=="" if 
				js> typeof(uploadform)=="undefined" if 
					<o> <form id=uploadform><input id="picture" name="picture_file" type="file" /><input type="submit" value="Send"/></form></o> drop 
					<js> 
						$("form").submit(function(evt){	 
							debugger;
							evt.preventDefault();
							var formData = new FormData($(this)[0]); 
							$.ajax({
								url: vm[context]['custom-vision-endpoint']+"image",
								type: 'POST',
								beforeSend: function(xhrObj){
									xhrObj.setRequestHeader("Content-Type","application/octet-stream");
									xhrObj.setRequestHeader("Prediction-Key", "8ef4041938284124a45dcb10b9572fb2");
									},
								data: formData,
							})
							.done(function(response){
									vm[context]["response"] = response;
									alert("Custom Vision service : Success");
									execute("(see)");
								})
							.fail(function(error){
									vm[context]["response"] = error;
									alert("Custom Vision service : Failed!!");
									execute("(see)");
								});
						})
					</js> 
				then
			else 
				(custom-vision) ( resp T/f ) show-the-picture cr
				not if ." Azure Custom Vision endpoint error!" else 
					." Azure Custom Vision has successfully analysed the picture." cr
				then (see) 
			then ;
		
		<comment>
			Custom Vision  https://customvision.ai/ 
			My endpoint : 

			---------------
			How to use the Prediction API
			If you have an image URL:
			https://southcentralus.api.cognitive.microsoft.com/customvision/v1.0/Prediction/e3a282d7-af7f-41d1-a0c5-d8b6c7db8f78/url
			Set Prediction-Key Header to : 8ef4041938284124a45dcb10b9572fb2
			Set Content-Type Header to : application/json
			Set Body to : {"Url": "<image url>"}

			If you have an image file:
			https://southcentralus.api.cognitive.microsoft.com/customvision/v1.0/Prediction/e3a282d7-af7f-41d1-a0c5-d8b6c7db8f78/image
			Set Prediction-Key Header to : 8ef4041938284124a45dcb10b9572fb2
			Set Content-Type Header to : application/octet-stream
			Set Body to : <image file>
			This iteration is marked as Default. If you mark another iteration as Default, the urls shown above will point to that iteration instead. 			
			
		</comment>
