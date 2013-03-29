package nom.stream
{
	public class Stream
	{
		private var headValue:*;
		private var tailPromise:*;
		
		public function Stream(head:*=null,tail:Function=null)
		{
			headValue=head;
			tailPromise=tail||function():Stream{return new Stream};
		}
		public function get empty():Boolean
		{
			return !headValue&&headValue!=0;
		}
		public function get head():*
		{
			if ( this.empty ) {
				throw new Error('Cannot get the head of the empty stream.');
			}
			return this.headValue;
		}
		public function get tail():Stream
		{
				if ( this.empty ) {
					throw new Error('Cannot get the tail of the empty stream.');
				}
				// TODO: memoize here
				return this.tailPromise();
		}
		public function item(index:int):*
		{
			if ( this.empty ) {
				throw new Error('Cannot use item() on an empty stream.');
			}
			var s:Stream = this;
			while ( index != 0 ) {
				--index;
				try {
					s = s.tail;
				}
				catch ( e:Error ) {
					throw new Error('Item index does not exist in stream.');
				}
			}
			try {
				return s.head;
			}
			catch ( e:Error ) {
				throw new Error('Item index does not exist in stream.');
			}
		}
		public function get length():int
		{
			var s:Stream = this;
			var len:int = 0;
			
			
			while ( !s.empty ) {
				++len;
				s = s.tail;
			}
			return len;
		}
		public function add(item:*):*
		{
			return this.zip( function ( x:*, y:* ):*{
				return x + y;
			}, item );
		}
		public function append(stream:Stream):Stream
		{
			if ( this.empty ) {
				return stream;
			}
			var self:Stream = this;
			return new Stream(
				self.head,
				function ():Stream {
					return self.tail.append( stream );
				}
			);
		}
		public function zip(func:Function,stream:Stream):Stream
		{
			if ( this.empty ) {
				return stream;
			}
			if ( stream.empty ) {
				return this;
			}
			var self:Stream = this;
			return new Stream( func( stream.head, this.head ), function ():Stream {
				return self.tail.zip( func, stream.tail );
			} );
		}
		public function map(f:Function):Stream
		{
			if ( this.empty ) {
				return this;
			}
			var self:Stream = this;
			return new Stream( f( this.head ), function ():Stream {
				return self.tail.map( f );
			} );
		}
		public function reduce(...args):Stream
		{
			var aggregator:* = args[0];
			var initial:Stream, self:Stream;
			if(args.length < 2) {
				if(this.empty) throw new TypeError("Array length is 0 and no second argument");
				initial = this.head();
				self = this.tail;
			}
			else {
				initial = args[1];
				self = this;
			}
			// requires finite stream
			if ( self.empty ) {
				return initial;
			}
			// TODO: iterate
			return self.tail.reduce( aggregator, aggregator( initial, self.head ) );
		}
		public function concatmap(func:Function):Stream
		{
			return this.reduce( function ( a:Stream, x:* ):Stream {
				return a.append( func(x) );
			}, new Stream () );
		}
		/**
		 *requires finite stream 
		 * @return 
		 * 
		 */		
		public function sum():Stream
		{
			return this.reduce( function ( a:*, b:* ):Stream {
				return a + b;
			}, 0 );
		}
		public function walk(f:Function):void
		{
			this.map( function ( x:* ):* {
				f( x );
				return x;
			} ).force();
		}
		public function force():void
		{
			var stream:Stream = this;
			while ( !stream.empty ) {
				stream = stream.tail;
			}
		}
		public function scale(factor:Number):Stream
		{
			return map(function (x:*):Number{return factor * x})
		}
		
		public function filter(func:Function):Stream
		{
			if(empty)
			{
				return this;
			}
			var h:*=head;
			var t:Stream=tail;
			if(func(h))
			{
				return new Stream(h,function():Stream{return t.filter(func)})
			}
			return t.filter(func);
		}
		public function take(time:int):Stream
		{
			if ( this.empty ) {
				return this;
			}
			if ( !time ) {
				return new Stream();
			}
			var self:Stream = this;
			return new Stream(
				this.head,
				function ():Stream {
					return self.tail.take( time - 1 );
				}
			);
		}
		public function drop(value:int):Stream
		{
			var self:Stream = this; 
			
			while ( value-- > 0 ) {
				
				if ( self.empty) {
					return new Stream();
				}
				
				
				self = self.tail;
			}
			
			// create clone/a contructor which accepts a stream?
			return new Stream( self.headValue, self.tailPromise );
		}
		public function member(item:*):Boolean
		{
			var self:Stream= this;
			
			while( !self.empty ) {
				if ( self.head == item ) {
					return true;
				}
				
				self = self.tail;
			}
			
			
			return false;
		}
		public function print(topNum:int=0):void
		{
			var target:Stream;
			if ( topNum ) {
				target = this.take( topNum );
			}
			else {
				// requires finite stream
				target = this;
			}
			target.walk( function ( x:* ):void {
				trace( x );
			} )
		}
		public function toString():String
		{
			return '[Stream head: ' + this.head + '; tail: ' + this.tail + ']';
		}
		public static function makeOnes():Stream
		{
			return new Stream( 1, Stream.makeOnes );
		}
		
		public static function makeNaturalNumbers():Stream
		{
			return new Stream( 1, function ():Stream {
				return makeNaturalNumbers().add( Stream.makeOnes() );
			} );
		}
		public static function make(...args):Stream
		{
			if (!args|| !args.length ) {
				return new Stream();
			}
			return new Stream( args.shift(), function ():Stream {
				return make.apply( null, args );
			} );
		}
		
		public static function fromArray(arr:Array):Stream
		{
			if ( arr.length == 0 ) {
				return new Stream();
			}
			return new Stream( arr[0], function():Stream { return fromArray(arr.slice(1)); } );
		}
		/**
		 * // if high is undefined, there won't be an upper bound 
		 * @param low
		 * @param high
		 * @return 
		 * 
		 */		
		public static function range(low:int=1,high:int=0):Stream
		{
			if ( low == high ) {
				return Stream.make( low );
			}
			return new Stream( low, function ():Stream {
				return range( low + 1, high );
			} );
		}
		
		public static function equals(stream1:Stream,stream2:Stream):Boolean
		{
			if ( ! (stream1 is Stream) ) return false;
			if ( ! (stream2 is Stream) ) return false;
			if ( stream1.empty && stream2.empty ) {
				return true;
			}
			if ( stream1.empty || stream2.empty ) {
				return false;
			}
			if ( stream1.head === stream2.head ) {
				return Stream.equals( stream1.tail, stream2.tail );
			}
			return false
		}
			
		
		

	}
}