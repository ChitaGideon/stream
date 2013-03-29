package flexUnitTests
{
	import nom.stream.Stream;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertTrue;

	public class MainTest
	{
		[Test]
		public function test1():void
		{
			var main1:Stream=Stream.make(10,20,30);
			assertEquals(main1.length,3);
			assertEquals(main1.head,10);
			assertEquals(main1.item(0),10)
			assertEquals(main1.item(1),20)
			assertEquals(main1.item(2),30);
			
			var tail:Stream=main1.tail;
			assertEquals(tail.head,20);
			assertEquals(tail.length,2)
		}
		
		[Test]
		public function test2():void
		{
			var main:Stream=Stream.range(10,20);
			assertEquals(main.item(0),10);
			assertEquals(main.length,11);
			assertEquals(main.item(main.length-1),20);
			
			main=main.map(function (item:Number):Number{return item*2.5})
			assertEquals(main.item(0),10*2.5)	
			assertEquals(main.item(5),15*2.5)	
		}
		
		[Test]
		public function test3():void
		{
			function checkIfOdd( x:int ):Boolean {  
				if ( x % 2 == 0 ) {  
					// even number  
					return false;  
				}  
				else {  
					// odd number  
					return true;  
				}  
			}  
			var numbers:Stream = Stream.range( 10, 15 );  
			var ii:int=10;
			numbers.walk(function (item:int):void{
				assertEquals(item,ii++)
			})
			var onlyOdds:Stream = numbers.filter( checkIfOdd );  
			onlyOdds.walk(function(item:int):void{
				assertTrue(checkIfOdd(item))
			})
		}
		
		[Test]
		public function  test4():void
		{
			var numbers:Stream = Stream.range( 10, 100 ); // numbers 10...100  
			var fewerNumbers:Stream = numbers.take( 10 ); // numbers 10...19  
			assertEquals(fewerNumbers.length,10);
			
			numbers = Stream.range( 0, 3 );  
			var multiplesOfTen:Stream = numbers.scale( 10 );  
			multiplesOfTen.print();
			assertEquals(multiplesOfTen.item(2),20)
			var eleStream:Stream=numbers.add( multiplesOfTen ) // prints 11, 22, 33  
			assertEquals(eleStream.item(3),33);
		}
		
		[Test]
		public function test5():void
		{
			var naturalNumbers:Stream = Stream.range(); // naturalNumbers is now 1, 2, 3, ...  
			var evenNumbers:Stream = naturalNumbers.map( function ( x:int ):int {  
				return 2 * x;  
			} ); // evenNumbers is now 2, 4, 6, ...  
			var oddNumbers:Stream = naturalNumbers.filter( function ( x:int ):Boolean {  
				return x % 2 != 0;  
			} ); // oddNumbers is now 1, 3, 5, ...  
			assertEquals(evenNumbers.tail.head,oddNumbers.tail.head+1,4)
			
			function sieve( s:Stream ):Stream {  
				var h:* = s.head;  
				return new Stream( h, function ():Stream {  
					return sieve( s.tail.filter( function( x:int ):Boolean {  
						return x % h != 0;  
					} ) );  
				} );  
			}
			var st:Stream=sieve(Stream.range( 2 ));
			assertEquals(st.item(0),2)
			assertEquals(st.item(1),3)
			assertEquals(st.item(2),5)
			assertEquals(st.item(3),7)
			assertEquals(st.item(4),11)
			
		}

		
		
	}
}