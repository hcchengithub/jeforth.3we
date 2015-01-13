\ Big5

\
\ studying << 悟透JavaScript >> 
\

\ Page 1
\ 	5 basic types : undefined null boolean number string
\   1 object type
	
	undefined undefined = tib. \ ==> true (boolean)
	undefined undefined === tib. \ ==> true (boolean)
	undefined js> stack[1000] === tib. \ ==> true (boolean)

	see undefined
	\				name : undefined (string)
	\				help : undefined    ( -- undefined ) Get an 'unsigned'. (string)
	\				vid : forth (string)
	\				wid : 41 (number)
	\			creater : code (array)
	\			testCase : [object Object] (array)
	\				xt :
	\	function(){ /* undefined */
	\		push(undefined)
	\	}

  	: example.page-2  ( -- ) 
		inline
		var life = {}; 
		for(life.age = 1; life.age <= 3; life.age++) { // for loop can be used on JavaScript console directly
			switch (life.age) { 
				case 1: 
					life.body = "卵細胞\n";   
					life.say = function (){systemtype( this.age + this.body)}; // 'this' is 'life' in the function
					life.say2 = function (){systemtype( life.age + life.body)}; // 'this' is 'life' in the function
					if(debug)javascriptConsole(111,this,life); // now 'this' is the jeforth 'global'!!, === is true, really. 'life' is the correct thing.
					break; 
				case 2: 
					life.tail = "尾巴"; 
					life.gill = "腮\n"; 
					life.body = "蝌蚪"; 
					life.say = function (){systemtype( this.age + this.body + "-" + this.tail + "," + this.gill)}; 
					life.say2 = function (){systemtype( life.age + life.body + "-" + life.tail + "," + life.gill)}; 
					if(debug)javascriptConsole(111,this,life);
					break; 
				case 3: 
					delete life.tail; 
					delete life.gill; 
					life.legs = "四條腿"; 
					life.lung = "肺\n"; 
					life.body = "青蛙"; 
					life.say = function (){systemtype( this.age + this.body + "-" + this.legs + "," + this.lung)}; 
					life.say2 = function (){systemtype( life.age + life.body + "-" + life.legs + "," + life.lung)}; 
					if(debug)javascriptConsole(111,this,life);
					break; 
			}; 
			life.say(); 
			life.say2();  // say2() works the same as say(). But say2() can only works on the 'life'.
		}; 
		end-inline
	; last execute
	/// 1卵細胞
	/// 1卵細胞
	/// 2蝌蚪-尾巴,腮
	/// 2蝌蚪-尾巴,腮
	/// 3青蛙-四條腿,肺
	/// 3青蛙-四條腿,肺
	/// OK
	/// JavaScript Object is dynamically changable

	: arguments.length  ( -- expected-number actual-number ) \ JavaScript knows expected and actual argument number of a function
		<js>
			function test(a,b,c){ /* Expected number of arguments is 3 */
				systemtype("Expected number of arguments is " + test.length+"\n"); 
				systemtype("Actual number of arguments is " + arguments.length+"\n"); 
			}
			test(1,2,3,4,5,6,7,8); /* Actual number of arguments is 8 */ 
		</js>
		drop
	; last execute
	/// Expected number of arguments is 3
	/// Actual number of arguments is 8
	/// I didn't know function has the .length intrinsic property.
	/// Other intrinsic properties of a function are .arguments .caller .constructor .prototype
	/// Also intrinsic methods are toString() valueOf() and call()
	///

\  page 5 ~ page 6

	: function_&_its_member ( -- ) \ 
		<js>
			var era = "唐朝"; /* this era will be used, because the member .era does not exist */
			var poem = "日出漢加添，月落陰山前；女兒琵琶怨，已唱三千年。"; /* this 'poem' will not be used because .poem is a member */
			function Sing() 
			{ 
				with (arguments.callee){ /* specify priority when looking for a thing */
					systemtype(author + "： " + poem + "\n" + era + "\n"); 
				}
			}; 
			Sing.author = "李白"; 
			Sing.poem = "漢家秦地月，流影照明妃；一上玉關道，天涯去不歸。"; 
			Sing();
		</js>
		drop
	; last execute
	/// function test(){ return this.value }
    /// 這時 this.value 不是 test() 的 property 而是 global 的，等於 global.value。
	/// 因為 test() 是 global 的一個 method.
    /// 實驗 test.value = 123; test(); 結果還是 undefined! 何故？ test() 裡所 access 的 this.value 
	/// 不是 test.value 而是 global.value (此時是 undefined)
	/// 
	/// Unlike other languages, JavaScript's 'this' has a different meaning. Therefore, if want to 
	/// refer to properties of the function or object, properties are like static variables of the function
	/// of object, use with(arguments.callee){...} block. Use (function_name.property_name = init_value) to
	/// initialize the static variables. Also use arguments.callee.static_variable_name=init_value directly.

	: static_variables ( -- ) \ 
		<js>
			function try_static () {
				arguments.callee.author = "李白"; 
				arguments.callee.poem = "漢家秦地月，流影照明妃；一上玉關道，天涯去不歸。"; 
				systemtype(arguments.callee.author + "： " + arguments.callee.poem + "\n"); 
			}
			try_static();
			systemtype("Access static variable from out side : " + try_static.author + "  " + try_static.poem + "\n");

			var myobj = new try_static;
			myobj.author = "H.C. Chen";
			myobj.poem = "老兄，你已經穩穩地踏上了正途。";
			javascriptConsole(111,myobj,try_static);
		</js>
		drop
	; last execute


\ page 7

	: WhoAmI ( -- ) 
		<js>
			function WhoAmI() { 
				systemtype("I'm " + this.name + " of " + typeof(this) + "\n"); 
			};
			WhoAmI();
			var BillGates = {name: "Bill Gates"}; 
			BillGates.WhoAmI = WhoAmI;
			BillGates.WhoAmI();
		</js>
		drop
	; last execute
	/// I'm undefined of object
	/// I'm Bill Gates of object

	: WhoAmI ( -- ) 
		inline
			function WhoAmI() { 
				systemtype("I'm " + this.name + " of " + typeof(this) + "\n"); 
			};
			WhoAmI();  // 'this' is global, it does not have the .name property thus I'm undefined ....

			var BillGates = {name: "Bill Gates"}; 
			BillGates.WhoAmI = WhoAmI;  
			BillGates.WhoAmI(); // 'this' is now BillGates
			
			var SteveJobs = {name: "Steve Jobs"}; 
			SteveJobs.WhoAmI = WhoAmI;
			SteveJobs.WhoAmI();  // 'this' is now SteveJobs

			WhoAmI.call(BillGates); // 'this' is now BillGates
			WhoAmI.call(SteveJobs); // 'this' is now SteveJobs
			
			BillGates.WhoAmI.call(SteveJobs); // 'this' is now SteveJobs
			SteveJobs.WhoAmI.call(BillGates); // 'this' is now BillGates
			
			WhoAmI.WhoAmI = WhoAmI; 
			WhoAmI.name = "WhoAmI"; 
			WhoAmI.WhoAmI();   // 'this' is now WhoAmI
			
			({name: "nobody", WhoAmI: WhoAmI}).WhoAmI(); // 'this' is now anonymous
 
		end-inline
	; last execute
	/// sI'm undefined of object
	/// sI'm Bill Gates of object
	/// sI'm Steve Jobs of object
	/// sI'm Bill Gates of object
	/// sI'm Steve Jobs of object
	/// sI'm Steve Jobs of object
	/// sI'm Bill Gates of object
	/// sI'm WhoAmI of function
	/// sI'm nobody of object

\ page 12 Prototype
	
	: prototype-and-sub-class ( -- ) \ 
		inline
			function Person(name) // base class constructor 
			{ 
				this.name = name; 
			}; 

			Person.prototype.SayHello = function () // add mathod to base class' prototype
			{ 
				systemtype("Hello, I'm " + this.name +"\n"); 
			}; 

			function Employee(name, salary) // constructor of sub class
			{ 
				Person.call(this, name); // invoke base class constructor
				this.salary = salary; 
			}; 

			Employee.prototype = new Person();  
				// This is very interesting. Note! object.prototype is an object! or base-class.

				// Create a base class object, Person(), which is to be, Employee(), sub-class' 
				// prototype. SteveJobs can't SayHello() without this prototype.

				// Person(name) has an argument which is absent here. That
				// doesn't matter. Because during the run time of the constructor 
				// Employee(), Person.call(this, name) will initialize the Employee.name property.
				// We want Employee.SayHello which is the real purpose.

			Employee.prototype.ShowMeTheMoney = function () // add method to sub-class constructor's prototype
			{ 
				systemtype(this.name + " $" + this.salary + "\n"); 
			}; 

			var BillGates = new Person("Bill Gates"); // create base class Person BillGates object
			var SteveJobs = new Employee("Steve Jobs", 1234); // create sub-class Employee SteveJobs object
			BillGates.SayHello(); // invoke prototype method via object directly  
			SteveJobs.SayHello(); // Note! invoke bass-class prototype method via sub-class object
			SteveJobs.ShowMeTheMoney(); // invoke sub-class prototype via sub-class object
			systemtype(BillGates.SayHello == SteveJobs.SayHello); // true, prototype method is shared
		end-inline
	; last execute
	/// Hello, I'm Bill Gates
	/// Hello, I'm Steve Jobs
	/// Steve Jobs $1234
	
\ closure
\ evernote:///view/2472143/s22/a6f5d481-6664-4c81-a337-7e0b4709422b/a6f5d481-6664-4c81-a337-7e0b4709422b/

	: create_counter ( start -- counter ) \ Create a counter function which returns a increamental value
		inline var c=pop();push(function(){push(c++)}) end-inline \ Leave a function on TOS. The function access the 
		create , does> r> @ execute                               \ dynamic variable c that makes c none-volatile during 
	;															  \ alive of the function.
	/// Demo how to make a dynamic variable none-volatile, which is like a static variable.
	100 create_counter counter
	counter tib.
	counter tib.
	counter tib.
	counter tib.
		
	
\s 


var aaa = [1,2,3,4];
function tos() { arguments.callee.value=aaa[aaa.length-1] }


\s
	//語法甘露： 
	var object = // 定義小寫的 object 基本類， 用于實現最基礎的方法等 
	{ 
		isA: function (aType) // 一個判斷類與類之間以及對象與類之間關係的基礎方法 
		{ 
			var self = this; 
			while (self) {  // self=self.Type can make self != true because the ending is undefined, I guess so.
				if (self == aType) // The 'a' in 'aType' means Argument.
					return true; 
				self = self.Type; // parent's type
			}; 
			return false; 
		} 
	}; 

	function Class (aBaseClass, aClassDefine) // 創建 class 的 function，用于聲明 class 及繼承關係 
	{ 
		function class_() //創建 class 的臨時 function 殼 
		{ 
			this.Type = aBaseClass; // 我們給每一個 class 約定一個 Type 屬性，引用其繼承的 class
			for (var member in aClassDefine) 
				this.[member] = aClassDefine[member]; // 複製 class 的全部定義到當前創建的 class 
		}; 
		class_.prototype = aBaseClass; 
		return new class_(); // Now, members in aBaseClass will be overwritten by members in aClassDefine if the name is same.
	}; 
	
	
	function New(aClass, aParams) // 創建 object 的函數，用于任意 class 的 object 創建 
	{ 
		function new_() // 創建 object 的臨時 function 殼 
		{ 
			this.Type = aClass; // 我們也給每一個 object 約定一個 Type 屬性，據此可以訪問到 object 所屬的 class
			if (aClass.Create) 
				aClass.Create.call(this, aParams); // 我們約定所有 class 的 constructor 都叫 Create，這和 DELPHI 比較相似 
		}; 
		new_.prototype = aClass; 
		return new new_(); 
	}; 

	//語法甘露的應用效果： 
	var Person = Class(object, // 衍生自 object 基本 class
		{ 
			Create: function (name, age) 
				{ 
					this.name = name; 
					this.age = age; 
				}, 
			SayHello: function() 
				{ 
					alert("Hello, I'm " + this.name + ", " + this.age + " years old."); 
				} 
		}
	); 
	
	var Employee = Class(Person, // 衍生自 Person class，是不是和一般 Object Oriented 語言很相似？ 
		{ 
			Create: function (name, age, salary) 
				{ 
					Person.Create.call(this, name, age); // 調用 base class 的 constructor
					this.salary = salary; 
				}, 
			ShowMeTheMoney: function () 
				{ 
					alert(this.name + " $" + this.salary); 
				} 
		}
	); 
	
	var BillGates = New(Person, ["Bill Gates", 53]); 
	var SteveJobs = New(Employee, ["Steve Jobs", 53, 1234]); 
	BillGates.SayHello(); 
	SteveJobs.SayHello(); 
	SteveJobs.ShowMeTheMoney(); 
	
	var LittleBill = New(BillGates.Type, ["Little Bill", 6]); // 根據 BillGate 的 class 創建 LittleBill 
	LittleBill.SayHello(); 
	
	alert(BillGates.isA(Person)); //true 
	alert(BillGates.isA(Employee)); //false 
	alert(SteveJobs.isA(Person)); //true 
	alert(SteveJobs.isA(Employee)); //true 
	alert(Person.isA(Employee)); //false 
	alert(Employee.isA(Person)); //true 



