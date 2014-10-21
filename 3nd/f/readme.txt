
[ ]	These two files,
		2014/10/15  17:01               448 jsc.hlp
		2014/10/15  17:00               733 jsc.js
	are not defined in jeforth.3nd.js directly because it's not convenient to define multiple
	line string, as far as I know. jsc.js will go to kvm.jsc.xt in text form so it will be a
	string too.
	
	If use <text> ... </text> to define kvm.jsc.help and kvm.jsc.xt then sure it's easy but 
	then platform.f is supposed to do that. Then kvm.jsc life cycle will be delaied. I want 
	jsc to be available earlier before jeforth.f.
	
	