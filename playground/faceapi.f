--- marker --- cls
\ ==== All you need to provide are here ====

    \ Request parameters
        <js>
            ({
                "returnFaceId": "true",
                "returnFaceLandmarks": "false",
                "returnFaceAttributes": "age,gender,headPose,smile,facialHair,glasses,emotion,hair,makeup,accessories"
            })
        </jsV> value parameters-on-Request-URL // ( -- hashTable ) 
        
    \ Picture URL
        s" https://upload.wikimedia.org/wikipedia/en/d/d0/Hippolyta_%28DC_Comics%29_as_WW_-_from_WW_v2_i130.png"
        value picture-url // ( -- "url" )

        \ show the picture
        <text> <img src="_pic_"]/></text> 
            :> replace(/_pic_/,vm[context]["picture-url"]) 
            </o> drop cr

    \ Azure resource subscription-key (paied account to call the service)
    
        char 5f5f04717cb641e0aa54ca03c9a5dfe0 value subscription-key // ( -- "key") hcchen's Azure cognitive services resource subscription-key
    
\ ==== Now prepare to send the request to Azure server ====
    
    \ Request URL
        parameters-on-Request-URL <js>
            "https://southeastasia.api.cognitive.microsoft.com/face/v1.0/detect?" + $.param(pop())
        </jsV> value request-url // ( -- "url" )

    \ Request body
    
        picture-url <js>
            ('{"url":"__url__"}').replace(/__url__/,pop())
        </jsV> value request-body // ( -- "object" )

    \ Send the request to Azure server 

        <js> 
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
                alert("success");
                push(response);
                execute('(see)'); // see the result 
            })
        .fail(function(error) {
                alert("error");
                push(error);    
                execute('(see)'); // see the error message
            });
        </js>


<comment>
	Face API - V1.0 reference
	https://southeastasia.dev.cognitive.microsoft.com/docs/services/563879b61984550e40cbbe8d/operations/563879b61984550f30395236/console
	My key : 5f5f04717cb641e0aa54ca03c9a5dfe0
	returnFaceAttributes=age,gender,headPose,smile,facialHair,glasses,emotion,hair,makeup,occlusion,accessories,blur,exposure,noise"
	大頭照 <o> <img src="https://upload.wikimedia.org/wikipedia/en/d/d0/Hippolyta_%28DC_Comics%29_as_WW_-_from_WW_v2_i130.png"/> </o>
	data = '{"url":"https://upload.wikimedia.org/wikipedia/en/d/d0/Hippolyta_%28DC_Comics%29_as_WW_-_from_WW_v2_i130.png"}'
</comment>
