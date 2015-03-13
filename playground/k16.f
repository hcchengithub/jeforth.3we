<comment>
King 燾昍 2月1日 

大家晚安！ 

在 2010 年，一時手癢，寫了一個 K16 (King16) 的 Forth CPU 模擬器，是使用 
C++ 定義的。原本想改成 SystemC 可惜當時的 FPGA 不支援，後來就沒有動力再
繼續改寫成 Verilog 了，再者，自己只是個念設計學的，寫程式本來就是個外行
，動手寫太多程式，就被人誤解成撈過界了，淺嚐即可，不宜深吞！免得當了理事
長還得親自上陣寫 VHDL 這就有點離譜了！ 

如今 FigTaiwan 的 JavaScript 高手如雲，又有 JeForth 的工具可以與 
JavaScript 「混和雜用」，重寫一個網路版，應該不難！ 

我把當年的 C++ 程式放在這裡，供想理解 Forth CPU 模擬器該如何定義的同好動
手。 

/* ******************************************************************************************
K16 的暫存器僅有 8 個！內部 Bit 與 Byte  I/O 共佔獨立的 256 個定址， ZeroPage 獨佔 256 個定址，給 Global Variabe 使用！Data and Return Stack Depth 由 8 ～ 256 可根據最後應用的需求而決定 easyIO Applicaltion  8~16 ; Normal Application   32~64 ; MultiTasking   128 ~ 256 層不等。
This is King.Cpp   May 02 / 2010   Draft Version
******************************************************************************************** */

public Class King16_SoC  {
 
const short int RegisterMax = 8 ;

const short int InternalMax = 256;

const short int StackDepth = 256;

const unsigned  int  MemoryMax = 0xFFFF ;

typedef unsigned int Word ;

typedef unsinged char Byte ;


// Regsiter Definition:
// A is DataStk.Top
// B is DataStk.Second
// C is LoopCounter or Temporay
// D is Double Density Math or Destination Pointer
// X is IndeX and SourcFrom Pointer
// S is [ ReturnStackPointer && 0xFF00 | DataStackPointer & 0x00FF ]
// F is Frame Pointer for Local Variable  or Frame Buffer for Display
// P is Program Counter and Literal Pointer

emun RegisterName = { Acc, Base, Count, Dest, indeX, Stack, Frame, ProgramCounter } ;

Word Register[ RegisterMax] ;

#define A  Register[Acc]
#define B  Register[Base]
#define C  Register[Counter]
#define D  Regiser[Dest]
#define X  Regsiter[indeX]
#define S  Register[Stack]
#define F  Register[Frame]
#define P  Register[ProgramCounter]

#define SP  (Register[Stack] & 0x00FF)
#define RP  ((Register[Stack] & 0xFF00 ) >> 8 )



Byte  Internal_IO_and_SRAM[ InternalMax]

Word ZerpPage[ InternalMax];

Word Memory [MemoryMax];

privati Class DataStack {

private Byte SP = 0 ;
private Word Stack[StackDepth] ;

#define  PushB    Stack[ ++ SP ] = B ;

#define PopB       B = Stack[ SP--] ;

#define CopyB     B = Stack[SP]；

#define PushA    Stack[++ SP] = A ;

#define PopA      A = Stack[ SP--] ;

#define CopyA     A = Stack[SP] ;

#define AtoB        B = A;

#define AfromB    A = B;

public  void _dup()
             {  PushB
              AtoB
              A = Register[A] ;
           }
#define DUP  _dup()


public void _over()
            { PushB
              AtoB
              CopyA
             }
#define OVER  _over

public void _swap()
            { A ^= B ;
              B ^= A ;
              A ^= B ; } // In real design should use D-Latch to exchange contain each other in single clock.
#define SWAP  _swap

public void _drop()
              { AfromB
                PopB
               }
#define DROP _drop()

public void _plus()

/*
機械碼 eCode 的格式為 L -XX-YYYY-R   8  Bits 固定格式，沒有例外，解碼器使用兩層 Pipe Line 來簡化內部的硬體執行結構！ 
*/
// L          Literal() { TempBuffer = DecodeBuffer.getNextOne();} 
// XX       Group 
// YYYY  Instruction
// R          Return() { ProgramCouter = ReturnStack.Pop();}

const int FiFoBuffer  = 2 ;

enum DecodeFiFo = { Current, NextOne }

Word InstructionBuffer[ DecodeFiFo]

#define HighByte  ( InstructionBuffer[Current] & 0xFF00 >> 8 )

#define LowByte  ( InstructionBuffer[ Current] & 0x00FF )

Class King16_CPU


private void decoing()
             {

               
                enum Signal = { Off, On } ;               
                enum Boolean = { Fault, True } ;
                // RESET
                A = B = C = D = X = S = F = 0
                DisableInterrupt();
                P = Memory[FFFF];
                void FetchInstruction() {
                                         InstructionBuffer[Current] =  Memory[ Register[P++] ];
                                         InstructionBuffer[NextOne] = memory[ Register[P++]];
                                                     }
                // DECODE
                Boolean LitReady = False , ReturnNow  = False ;
                for(;;){
                        while( ! ( Interrupt || DebuggerMode) )
                           { int  eCodeBuffer ; Signal DecodeCycle = 0 ;
                                  eCodeBuffer = ( DecodeCycle == 0 ? HighByte : LowByte ; ) ;
                                  DecodeCycle = ~DecodeCycle; 
                            if  ( DebuggerMode )  P = Memory[FFFE] ; FetchInstruction(); continue ;
                            if  ( Interrupt ) P = Memory[FFFx] ; FetchInstruction; continue ;
                                   
                                  void GetLit()  { if  ( LitReady = ( eCode & 0x80 >> 7 ) )  
                                                        TempBuffer = Instruction[NextOne];  }
                                  void Excute(){ 
                                  	    switch ( eCode & 0x7E >> 1)
                                               { 
                  // Control Unit
                                 /* NOP */       case  0x00 : {  InterruptEnable = LitReady ;
                                                                 if (ReturnNow) P = ReturnStack.Pop() ;                                                                                
                                                                 else DecodeNextByte(); 
                                                                 continue;}
                                // Could be using as NOP / Disable Interrupt / Return 
                    
                                 /* DBG */       case  0x01 : { DebuggerMode =  LitReady ; 
                                                                if ( ReturnNow ) P = ReturnStack.Pop();
                                                                else DecodeNextByte();
                                                                continue; }
                                // Using to Set Debugger Mode Flag to Hardware Generate Single Step Trap 
                                                                 ;

                                /* CALL */        case 0x02 : { ReturnStack.Push(P); /* goto JUMP */
                                /* JUMP */        case 0x03 : { if ( LitReady ) 
                                                                    P = TempBuffer ; 
                                                                else  { P = A ;  DROP  ;}
                                                                FetchInstruction();
                                                                continue ; }
                                                //  Using for else / break / continue / AGAIN / AFT / Forever()

                                /* LOOP */        case 0x04 : { if ( C-- ) 
                                                                    { if ( LitReady ) P = TempBufer ; 
                                /* NEXT */                            else  P = P - 2 ; 
                                                                      FetchInstruction(); 
                                                                      continue; }
                                                                else { DecodeNextByteCode() } ; 
                                                                break ;  
                                                 // Using for FOR   ..  NEXT 
                      
                               /* +LOOP */          case 0x05 : { if ( C-- ) 
                                                                     { if ( LitReady ) P = TempBuffer; 
                                                                       else P = P - 2 ;  
                                                                       A+= B ; 
                                                                       FetchInstruction() ; 
                                                                       continu;
                                                //  for Accumulation of Multiple ( Partialy DSP )                           
                                                                     
                               /*  JZ  */           case 0x06 : { if ( A == 0 , DROP )
                                                                      { if (LitReady) { P = Tempbuffer ;}
                               /*  RTZ */                               else if ( ReturnNow)
                                                                             { P = ResturnStack.Pop() ; }
                                                                      } 
                                                                  else DecodeNextByteCode(P++);
                                                                  continue ;   
                                               //  for ?Branch and ?Return  
                                  
                              /*   JP  */          case 0x07 : { if ( DROP >= 0 ) 
                                                                     { if (LitReady) { P = Tempbuffer ;}
                                                                        else if ( ReturnNow)
                                                                             { P = ResturnStack.Pop() ; }
                                                                      } 
                                                                  else DecodeNextByteCode();
                                                                  continue ; 
                                              //  for MAX  MIN  ABS
                               
                               //  Memory Acess Constant and Pointer
                                               
                             /* LIT(LD#) */         case 0x08 : { if (LitReady){ DUP ; A = TempBuffer ; P++ ;}
                             /* R@   */                          else { DUP ; A = ReturnStack.Copy() ; }                                                                 
                                                                  DecodeNextByteCode();
                                                                 break ;
                                                                 
                             /* STA */              case 0x09 : { if ( LitReady) { Memory[TempBuffer] = A ; DROP ;P++;} 
                             /* ! */                              else { Memory[A] = B ; DROP ; DROP ;}
                                                                  DecodeNextByteCode();
                                                                  break;
                                                                }
                             /* LDA  */            case 0x0A  : { if ( LitReady) { DUP  ; A = Memory[TempBuffer] ;
                                                                                  ; P++;} 
                             /* @ */                             else { A  =  Memory[A] ;}
                                                                  DecodeNextByteCode();
                                                                  break;
                                                                } 
                                             
                             /* X+@ */              case 0x0B : { if(LitReady) { DUP; A = Memory[TempBuffer + X] ; P++ ; }
                                                                 else { DUP ; A = Memory[X] ; }
                                                                 X++;
                                                                 DecodeNextByteCode();
                                                                 break;
                                                                 
                             /* X+! */              case 0x0C : { if ( LitReady) { Memory[TempBuffer+X] =A ; DROP
                                                                                 ;P++;} 
                                                                 else { Memory[X] = A ; DROP ;}
                                                                  X++;
                                                                  DecodeNextByteCode();
                                                                  break;                   
                                                                 
                             /* JmpTable */         case 0x0D : { if(LitReady) { P = Memory[TempBuffer + X] ; }
                                                                 else {  P = Memory[X] ; }                                              
                                                                 continue;
                                                                 
                             /* D@+ */              case 0x0E : { if(LitReady) { DUP; A = Memory[D] + TempBuffer; P++; }
                             /* D@  */                             else {A = Memory[D] ;}
                                                                 
                             /* D+! */              case 0x0F : { if ( LitReady) { Memory[D] = TempBuffer ; 
                                                                                 ;P++;} 
                             /* Array Initial */                  else { Memory[D] = A ; DROP ;}
                                                                  D++;
                                                                  DecodeNextByteCode();
                                                                  break;                                    
                                                                         
                                
          //  Register Movement
           
                             /*  PUSH#  */           case 0x10 : { if(LitReady) { ReturnStack.Push(TempBuffer); P++;}
                             /*   >R  */                            else { ReturnStack.Push(A); DROP; } break ;
                             
                             /*  POP  */             case 0x11 : { if(LitReady) { 
                                                                       ZeroPage[TempBuffer] = ReturnStack.Pop();}
                             /*  R>   */                            else { DUP; A = ReturnStack.Pop();} break ;
                             
                             /*  LDC,#  */           case 0x12 : { if(LitReady) { C = TempBuffer ; P++; }
                             /*  >C   */                            else { C = A ; DROP ; } break ;
                                                                    
                             /*  STC_Local */        case 0x13 : { if (LitReady) { Frame[ F + TempBuffer] = C ; P++ } 
                             /*  C   */                            else { DUP ; A = C ; } break ;
                             
                             /*  LDD,#  */           case 0x14 : { if(LitReady) { D = TempBuffer ; P++; }
                             /*  >D   */                            else { D = A ; DROP ; } break ;
                                                                    
                             /*  STD_Local */        case 0x15 : { if (LitReady) { Frame[ F + TempBuffer] = D ; P++ } 
                             /*  D   */                             else { DUP ; A = D ; } break ;
                             
                             /*  LDX,#  */           case 0x16 : { if(LitReady) { X = TempBuffer ; P++; }
                             /*  >X   */                           else { X = A ; DROP ; } break ;
                                                                    
                             /*  STD_Local */        case 0x17 : { if (LitReady) { Frame[ F + TempBuffer] = C ; P++ } 
                             /*  X    */                           else { DUP ; A = X ; } break ;
                          
                             /*  #S!  */             case 0x18 : { if(LitReady) { S = TempBuffer ; P++; }
                             /*  >SP  */                           else { S = A ; DROP ; } break ;
                                                                    
                             /*  SP@    */           case 0x19 : { if (LitReady) { DUP ; A = DataStack[SP+TempBuffer];
                                                                                   P++ } // for Debug .S  
                             /*  SP     */                         else { DUP ; A = S ; } break ;
                             
                             /*  Enter  */           case 0x1A : { if ( LitReady) { ReturnStack.Push(F); P++ 
                                                                                    F -= TempBuffer ; // Local Frame }
                             /*  Leave  */                         else { F = ReturnStack.POP(); } break ;
                             
                             /*  Local@ */           case 0x1B : { if (LitReady) { DUP; A = Frame[F+TempBuffer] ; P++; }                  
                             /*  F      */                         else { A = F ; DROP ; } break ;
                             
                             /*  Local! */           case 0x1C : { if (LitReady) { Frame[ F + TempBuffer ] = A ; P++ }
                             /*  >F     */                         else { F = A ; }
                                                                   DROP ; break ;
                                                                   
                             /*  LIT# SWAP  */       case 0x1D : { if {LitReady) { DataStack.Push(B), // Half DUP 
                                                                                   B = TempBuffer ;  // Lit#  SWAP 
                                                                                   P++ ;}
                             /*   DUP  */                          else { DataStack.Push(B), B = A ; } 
                                                                   break ;
                                                                   
                            /*  POKE  */            case 0x1E :  { if (LitReady) { ZeroPage[TempBuffer] = A ;
                                                                                   A = B DataStack.Pop(); 
                                                                                    P++ ;} 
                            /*   DROP */                           else { A = B ; B = DataStack.PoP;}
                                                                   break ;
                                                                   
                            /*  PEEK  */            case 0x1F :  { if (LitReady) { DUP ; A = ZeroPage[TempBuffer] ;P++}
                            /*  OVER  */                           else { DUP ;  A = DataStack.Copy() ; }
                                                                   break ;
                                                                   
          //  ALU and SHIFT 
                           
                           /*  #+   */              case 0x20 : { if ( LitReady ) { A += TempBuffer ; P++ ;}
                           /*   +   */                            else { A += B ; B = DataStack.Pop(); } break ;                                         
                                                                   
                           /*  #-   */              case 0x21 : { if ( LitReady ) { A = TempBuffer - A ; P++ ;}
                           /*   -   */                            else { A = B  - A ; B = DataStack.Pop(); } break ;
                           
                           /*  #<  */               case 0x22 : { if ( LitReady ) { (A < TempBuffer) ? A = 1 : A = 0 ;
                                                                                      P++ ;}
                           /*   <  */                            else { (A < B) ? A = 1 : A = 0 ; 
                                                                         B = DataStack.Pop(); } break ; 
                                                                         
                           /*  #>  */               case 0x24 : { if ( LitReady ) { (A > TempBuffer) ? A = 1 : A = 0 ;
                                                                                      P++ ;}
                           /*   <  */                            else { (A > B) ? A = 1 : A = 0 ; 
                                                                         B = DataStack.Pop(); } break ;                                                                     
                                                                   
                           /*  #&   */              case 0x25 : { if ( LitReady ) { A &= TempBuffer ; P++ ;}
                           /*  AND  */                            else { A &= B ; B = DataStack.Pop(); } break ;                                         
                                                                   
                           /*  #|   */              case 0x26 : { if ( LitReady ) { A |= TempBuffer ; P++ ;}
                           /*  OR   */                            else { A &= B ; B = DataStack.Pop(); } break ; 
                           
                           /*  #^   */              case 0x27 : { if ( LitReady ) { A ^= TempBuffer ; P++ ;}
                           /*  XOR  */                            else { A ^= B ; B = DataStack.Pop(); } break ;
                           
                           /*  NOT  */              case 0x28 : { if ( LitReady ) { A = ~A | TempBuffer ; P++ ;}
                           /*  IMP  */                            else { A = ~B ; B = DataStack.Pop(); } break ;
                           
                           /*  #<<  */              case 0x29 : { if ( LitReady ) { C = TempBuffer ; P++ ; A << 1 ; }
                           /*  2*   */                            else { A = A << 1 ; } break ;
                           
                           /*  #>>  */              case 0x2A : { if ( LitReady ) { C = TempBuffer ; P++ ; A >> 1 ; }
                           /*  2/   */                            else { A = A >> 1 ; } break ;
                           
                           /*   #*+  */             case 0x2B : { if ( LitReady ) {  A += TempBuffer ; P++ ; AD >> 1 ; }
                           /*   *+   */                           else { (AD >>= 1)==1 ? A += B : A  ; } break ;
                           
                           /*   #/-  */             case 0x2D : { if ( LitReady ) {  A = -A + TempBuffer ; P++ ; 
                                                                                     AD >> 1 ; }
                           /*   /-   */                           else { (AD >>= 1)>0 ? A -= B : A  ; } break ;
                           
                           /*  #SWAP-  Optimize */ case 0x2E : { if (LitReady) { A = A - TempBuffer ; P++ } 
                           /* Negate */                           else { A = ~A + 1 ; } break ;
                           
                           /*  TASK  */            case 0x2F : { if(LitReady){ 
                                                                   ZeroPage[TempBuffer] = P = ReturnStack.Pop();
                                                                   P++; 
                                                                   continue ; }
                                                                // Using for MultiThreaded Programming    
                           /*  SWAP  */                          else A >< B ; /* HardWare D-Latch Swap */ break ;
                           
          // I/O Contrul   Bit / Port / ZeroPageRAM (Global Variable) 
          #define  BitAddr    IO_Map[(TempBuffer>>3) & 0x00FF]
          #define  WhichBit   TempBuffer & 0x07	  
                           /*  TEST  */          case 0x30 : {if (LitReady) { DUP ; 
                                                                              A = ReadBit(BitAddr) & ( 0x01 << WhichBit ) ;P++; }
                           /*  Bit@  */                         else { DUP ;A = IO_Map[A>>3] & (0x01 << (A & 0x07) }; 
                                                              break ; }              
                           
                           /* SetBit */          case 0x31 : {if (LitReady) { SetBit((TempBuffer & 0x00FF)  ) ; P++ ;
                           /*  ON    */                         else { SetBit( A * 0x00FF) ;}
                                                              break ; } 
                           
                           /* ResetBit */        case 0x32 : {if (LitReady) { ResetBit((TempBuffer & 0x00FF)  ) ; P++ ;
                           /*  OFF    */                      else { ResetBit( A * 0x00FF) ;} 
                                                              break ; } 
                                                     
                           /*  Port@ */          case 0x33 :{ if(LitReady) { DUP ; A = IO_Map[TempBuffer & 0x00FF ] ; P++;} 
                               PC@                            else { A = ReadByte(IO_Map[A & 0x00FF] ); }
                                                              break ; } 
                               
                           /*  Port! */          case 0x34 :{ if(LitReady) { IO_Map[TempBuffer & 0x00FF ] = A ; 
                                                                            DROP; P++;} 
                               PC!                              else { IO_Map[A & 0x00FF] = B & 0x00FF ; DROP ; DROP ; }
                                                              break ;} 
                           
                           /*  Global@ */        case 0x35 :{ if(LitReady) { DUP ; A = ZeroPage[TempBuffer & 0x00FF ] ;
                                                                             P++;} 
                           /*    Z@    */                       else { A = ZeroPage[A & 0x00FF] );} 
                                                              break ;} 
                           
                           /*  Global! */       case 0x36 :{ if(LitReady) {  ZeroPage[TempBuffer & 0x00FF ] = A ;
                                                                             DROP; P++;} 
                           /*    Z!    */                       else { ZeroPage[A & 0x00FF] = B ; DROP ; DROP ;} 
                                                              break ;} 
                           
                           /*  MP@    */        case 0x37 :{ if(LitReady ) { DUP ; A = Memory[ P + TempBuffer ] ; 
                                                                          P++ ; }
                                                // A very useful when write Class.Method() for ROM System
                           /*  ?DUP   */                       else { (A) ? DUP : NOP ; } break ; }
                                                // When testing DataStack.Top is useful  
                           /*  USER_Ext   */       case 0x38 : // Base on  User Application Extention
                           /*  USER_Ext   */       case 0x39 : // ex.  Hardware UM*+ ( Multiple and Accumulate )
                           /*  USER_Ext   */       case 0x3A : //      Image Signal Processing
                           /*  USER_Ext   */       case 0x3B : //      Voice Signal Processing
                           /*  USER_Ext   */       case 0x3C : //      ZigBEE Communication
                           /*  USER_Ext   */       case 0x3D : //      TCP/IP Stack Operation 
                           /*  USER_Ext   */       case 0x3E :
                           /*  USER_Ext   */       case 0x3F :
                                                                    
                         void ReturnNow() { if ( ReturnNow = eCode & 0x01) P = ReturnStack.Pop() ; 
                                                        else { eCodeBuffer = InstructionBuffer[NextByte] ;}
                         }
</comment>
