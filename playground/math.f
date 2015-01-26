
	also forth 
	vocabulary math // ( -- ) Make 'math' word-list the context
	math definitions

	code int ( float -- integer ) \ float to integer, cut off all cecimal places.
		push(parseInt(pop())) 
		end-code

	code random ( -- 0..1 ) \ Get a ramdom number
		push(Math.random()) 
		end-code
