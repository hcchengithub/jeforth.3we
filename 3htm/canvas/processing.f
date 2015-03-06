
\ 
\ Mimic processing.js
\ Usage:
\   setup ...
\   : draw .... ;
\   processing

include canvas.f

s" processing.f" source-code-header

	createCanvas setWorkingCanvas \ Init default canvas kvm.cv

	( dummy ) 0	value timeOutId 	// ( -- int ) setTimeout() returns the ID, clearTimeout(id) to stop it.
	( dummy ) 0	value frameCount 	// ( -- count ) Serial number of frames
	( dummy ) 1	value frameRate 	// ( -- n ) Re-draw the canvas n times per second
	( dummy ) Infinity value frameCountLimit  // ( -- int ) Stop when frameCount reaches limit
	
	<js> // 給 setTimeout() 用的 Interval 時間得隨時修正才準。
		var t0,interval,deltaA,deltaB; // static variables。開始時間，動態 interval 時間，觀察兩次偏時間。
		push({
			init: function(){ // Usage: frameTickInterval :: init()
				// kvm.temp=[]; // <--- 研究電腦速度能到多少，結論是 frameRate 約 60 就已經快滿檔了。
				// kvm.r=[]; // <-- 研究每個 tick 的 now 與理想時間 fc*fi + t0 之間的差距。
				t0 = (new Date()).getTime(); // 單位是 mS JavaScript 既有的 timer 已經很準了
				execute('timeOutId'); if(tos()) clearTimeout(tos());
				fortheval('drop 0 to timeOutId 0 to frameCount frameRate'); 
				interval=1000/pop();
				deltaA = deltaB = 0; // 一開始假設時間都是準的。
			}, 
			value: function(){
				var now = (new Date()).getTime(); // 單位是 mS JavaScript 既有的 timer 已經很準了
				execute('frameRate'); var frameInterval = 1000/pop(); // 可以動態被改所以要每次重抓。
				execute('frameCount'); var frameCount = pop();
				deltaA = deltaB;	
				deltaB = frameInterval*frameCount + t0 - now ; // 理想時間從 frameCount 推算而來，優點是絕對正確，伴隨的條件是 frameRate 改了就得重新 interval.init()。
				if(Math.abs(deltaB)>501) {this.init()} // 自動校正，防 debug 時被搞亂。
				if (deltaA*deltaB <= 0 || Math.abs(deltaB) >= Math.abs(deltaA)) 
					// 異號，表示過頭了，或者差距擴大時，都要修正。只有同號且差距縮小時不必修正。
					if(deltaB>0) interval += 1; // 正的表示實際時間落後，表示跑太快了，interval 要加一點。
					else interval = Math.max(interval-1,1);
				// kvm.temp.push(interval); // study
				// kvm.r.push(deltaB); // study
				return(interval);
			}
		})
	</js> constant frameTickInterval // ( -- obj ) frameTickInterval.init(), frameTickInterval.value(), precise dynamic interval time for setTimeout()

	: setFrameRate	( n -- ) \ Frames per second
		to frameRate frameTickInterval :: init() ;

	: setFrameCountLimit ( n -- ) \ Set maximum frameCount, Infinity to run forever.
		to frameCountLimit ;
		
	: onFrameTick ( -- ) \ Processing main loop
		frameCount frameCountLimit >= if char ending-message execute 0 to timeOutId exit then
		[ s" push(function(){inner(" js> last().cfa + s" )})" + </js> ] literal ( -- callBack ) \ 用自己的 cfa 當 call back
		frameTickInterval :> value() ( -- callBack interval ) js> setTimeout(pop(1),pop()) to timeOutId
		frameCount 1+ to frameCount 
		[ last ] literal js: tos().cvwas=kvm.cv;kvm.cv=pop().cv \ save 人家的 cv 換成自己的 --- (1)
		char draw execute \ call by name 因為 draw 尚未出生
		[ last ] literal js: kvm.cv=pop().cvwas \ restore 別人家的 cv ----- (2)
		js> rstack.length 1 > if 0 >r then \ ----------- (4)
		; interpret-only last :: cv=kvm.cv \ initial 自己的 cv ------ (3) 
		/// onFrameTick command 本身是個 TSR 因此設定為 interpret-only。
		/// This event is usually triggered by setTimeout() when waiting in interpreter state, rstack.length
		/// is supposed to be 1. If triggered in suspending state then rstack.length>1, we have to avoid using the 
		/// working rstack by pushing a dummy 0 into rstack so as to return to interpreter waiting state which is
		/// where it was from. see (4) above, this is very important for any TSR. 

	: processing ( -- ) \ 整個程式像新的一樣重跑。
		char starting-message execute
		char setup execute \ call by name because 'setup' has not born.
		frameTickInterval :: init() 
		char onFrameTick tib.append \ onFrameTick 是 TSR 故最好延後到 interpret mode 執行。
		;
