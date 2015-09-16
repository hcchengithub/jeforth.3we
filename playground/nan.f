\ A + B - 9 = 4
\ C - D * E = 4
\ F + G - H = 4
\ A + C / F = 4
\ B - D * G = 4
\ 9 - E - H = 4

10 value range
random range * int value a
random range * int value b
random range * int value c
random range * int value d
random range * int value e
random range * int value f
random range * int value g
random range * int value h

: verify ( -- boolean ) \ verify the recent set
	\ a b c d e f g h + + + + + + + . space
	a b + 9 - 4 =
	c d e * - 4 =
	f g + h - 4 =
	a c f / + 4 =
	b d g * - 4 =
	9 e - h - 4 = 
	and and and and and ;
: refresh ( -- ) \ refresh a~h
	random range * int to a
	random range * int to b
	random range * int to c
	random range * int to d
	random range * int to e
	random range * int to f
	random range * int to g
	random range * int to h ;
: view ( -- ) \ view a ~ h
	a . space 
	b . space 
	c . space 
	d . space 
	e . space 
	f . space 
	g . space 
	h . space cr ;

\ 10000
\ [for] 
\ 	10 nap refresh verify 
\ 	[if] ." Bingo!!" r> drop 0 >r 
\ 	[else] ." ." [then] 
\ 	js: jump2endofinputbox.click() 
\ [next]

20 to range [begin] 10 nap refresh verify [until] ." Bingo!!!" cr
	