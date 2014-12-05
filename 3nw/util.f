
\ http://nodejs.org/docs/latest/api/util.html
\ http://stackoverflow.com/questions/5227701/wheres-the-documentation-for-nodejss-system-module was the 'sys' module

s" util.f"		?skip2 --EOF-- \ skip it if already included
				dup .( Including ) . cr char -- over over + + 
			 	also forth definitions (marker) (vocabulary) 
			 	last execute definitions

js> window.util=require('util') constant util // ( -- obj ) Node.js Utility module  

\ util.format(format, [...])	printf(format,...), js> util.format("%d",0x100) . ==> 256
\ util.isArray()
\ util.isRegExp()
\ util.isDate()
\ util.isError()
\ util.inherits()

\ OK js> require('util')
\ OK constant util
\ OK util obj>keys .
\ format,deprecate,print,puts,debug,error,inspect,isArray,isRegExp,isDate,
\ isError,p,log,exec,pump,inherits,_extend OK 
  
code inspect	( x -- string ) \ Similar to JSON.stringify(), let you see the object.
				push(util.inspect(pop(),{showHidden: false, depth: 2,})) 
				end-code

\ --EOF--

