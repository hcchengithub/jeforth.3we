
s" mytools.f"	source-code-header
		
code tib.       ( thing -- ) \ Print the command line and the TOS.
				print(tib.slice(0, ntib).match(/\s*(.*)/)[1] + " \\ ==> " + tos() + " (" + mytypeof(pop()) + ")\n");
				end-code 
				/// Good for experiments that need to show command line and the result.

code now 		( -- Time ) \ Get the Time object of now.
				push(new Date());
				end-code 

code t.year 	( Time -- year ) \ Get year number
				push(pop().getFullYear());
				end-code
   
: t.month 		( Time -- month ) \ Get month number 
				js> pop().getMonth() 1+ ;

: t.date 		( Time -- date ) \ Get date number 
				js> pop().getDate() ;

: t.day 		( Time -- day ) \ Get day number 
				js> pop().getDay() ;

: t.hour		( Time -- hour ) \ Get hour number 
				js> pop().getHours() ;

: t.minute		( Time -- minute ) \ Get minute number 
				js> pop().getMinutes() ;

: t.second		( Time -- second ) \ Get second number 
				js> pop().getSeconds() ;

: t.mS			( Time -- mS ) \ Get mS number 
				js> pop().getMilliseconds() ;

: t.dateTime	( Time -- "yyyy-mm-dd HH:mm:ss" ) \ Print Date time
				>r 
				r@ t.year . char - .
				r@ t.month  2 .0r char - .
				r@ t.date   2 .0r space
				r@ t.hour   2 .0r char : .
				r@ t.minute 2 .0r char : .
				r@ t.second 2 .0r ;

: member-count	( obj|hash|array -- count ) \ Get member count of an obj or hash table
				js> memberCount.call(pop()) ;
				/// Get hash table's length
				/// An array's length is array.length but there's no such thing of hash.length for hash{}.
				/// memberCount.call(object) gets the given object's member count which is also a hash table's length.

code freeze 	( mS -- ) \ Freeze the entire system for mS time. Nobody can do anything.
				var ms=pop();
				var startTime = new Date().getTime();
				while(new Date().getTime() < (startTime + ms));
				end-code

code .longwords ( length -- ) \ print long words. I designed this word for fun to see what are they.
				var limit = pop();
				for (var j=0; j<order.length; j++) { // 越後面的 priority 越新
					print("\n-------- " + order[j] +" "+ (words[order[j]].length-1) + " words --------\n" );
					for (var i=1; i<words[order[j]].length; i++){  // 從舊到新
						if(words[order[j]][i].name.length > limit) print(words[order[j]][i].name+" ");
					}
				}
                end-code

\ setTimout timers & setInterval timers. Idea was from Sam Suan Chen's jeforth HTML5 clock demo.
[] constant timouts		// ( -- array[] ) setTimeout IDs' storage
						/// Refer to : timeouts.push and timeouts.clear
code timeouts.push		( id -- ) \ Save the setTimeout ID into timeouts[].
						execute('timeouts'); pop().push(pop()) end-code
code timeouts.clear		( n -- ) \ Clear older setTimeout IDs leaving the last n ones.
						var n=pop(); execute('timeouts'); var a=pop();
						while(a.length>n) clearTimeout(a.shift());
						end-code
[] constant intervals 	// ( -- array[] ) setInterval IDs' storage
						/// Refer to : intervals.push and intervals.clear
code intervals.push		( id -- ) \ Save the setInterval ID into intervals[].
						execute('intervals'); pop().push(pop()) end-code
code intervals.clear	( n -- ) \ Clear older setInterval IDs leaving the last n ones.
						var n=pop(); execute('intervals'); var a=pop();
						while(a.length>n) clearInterval(a.shift());
						end-code






