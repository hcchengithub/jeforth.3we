\ A + B - 9 = 4
\ C - D * E = 4
\ F + G - H = 4
\ A + C / F = 4
\ B - D * G = 4
\ 9 - E - H = 4

<js> 
	var temp = 
	 [[ 0,13],  //  0
	  [ 1,12],  //  1 
	  [ 2,11],  //  2 
	  [ 3,10],  //  3 
	  [ 4, 9],  //  4 
	  [ 5, 8],  //  5 
	  [ 6, 7],  //  6 
	  [ 7, 6],  //  7 
	  [ 8, 5],  //  8 
	  [ 9, 4],  //  9 
	  [10, 3],  // 10 
	  [11, 2],  // 11 
	  [12, 1],  // 12 
	  [13, 0]]; // 13 
	temp; 
</jsV> constant ab // ( -- array ) possible [a,b] pairs

<js> 
	var temp = 
	 [[0,5],  // 0
	  [1,4],  // 1
	  [2,3],  // 2 
	  [3,2],  // 3 
	  [4,1],  // 4
	  [5,0]]; // 5
	temp; 
</jsV> constant eh // ( -- array ) possible [e,h] pairs
 

20 value range
	0 value c
	0 value d
	0 value f
	0 value g

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
	random ab :> length * int 
	ab :> [tos()][0] to a 
	ab :> [pop()][1] to b
	random eh :> length * int 
	eh :> [tos()][0] to e
	eh :> [pop()][1] to h
	random range * int to c
	random range * int to d
	random range * int to f
	random range * int to g
	;
	
: view ( -- ) \ view a ~ h
	a 2 .r space
	b 2 .r space
	c 2 .r space
	d 2 .r space
	e 2 .r space
	f 2 .r space
	g 2 .r space
	h 2 .r cr ;

\ 10000
\ [for] 
\ 	10 nap refresh verify 
\ 	[if] ." Bingo!!" r> drop 0 >r 
\ 	[else] ." ." [then] 
\ 	js: window.scrollTo(0,endofinputbox.offsetTop);
\ [next]

20 to range 
[begin] 
	10 nap 
	\ char . . js: jump2endofinputbox.click() --> js: window.scrollTo(0,endofinputbox.offsetTop);
	refresh verify 
[until] ." Bingo!!!" cr
	
50 to range 10000 [for] 9 e - h - 4 = [if] e 3 .r h 3 .r cr [then] refresh 10 nap [next]
	