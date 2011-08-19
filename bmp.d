//#colour blend
//#maybe not ref
/**
 * Bitmap module a layer above ALLEGRO_BITMAP*
 */
module jeca.bmp;

private {
	import std.stdio;
	import std.string;
	import std.file;

	import jeca.all;
}

//debug = Free;

/**
 * Title: Bmp - to do with bitmaps (images made up of pixels)
 * 
 * Terminolagy(sp):
 * bitmap is a ALLEGRO_BITMAP* object<br>
 * bmp is a Bmp object<br>
 */
class Bmp {
private:
	// Allegros bitmap
	ALLEGRO_BITMAP* _bitmap;
	string _name;
public:
	/**
	 * Load bitmap picture
	 * throws: exceptions if file name not exist or get a null
	 */
	static ALLEGRO_BITMAP* loadBitmap( string fileName ) {
		if ( ! exists( fileName ) )
			throw new Exception( format( "%s not found", fileName ) );
		
		auto bitmap = al_load_bitmap( toStringz( fileName ) );
		if ( bitmap is null )
			throw new Exception( format( "%s failed to load.", fileName ) );
		return bitmap;
	}

	/// get a slice
	/// Note: sets target bitmap
	static Bmp getBmpSlice(
		ALLEGRO_BITMAP* src, // source Bmp
		real sx, // source left
		real sy,
		real w, //source and destination
		real h,
		real dx, // destination
		real dy,
		int flags = 0 // 0 - normal
	) {

		auto bmp = new Bmp( cast(int)w, cast(int)h );

		al_set_target_bitmap( bmp() );
		al_draw_bitmap_region( src, sx, sy, w, h, dx, dy, flags );

		return bmp;
	}

	/**
	 *  get bitmap like:
	 *  ---
	 *  al_draw_bitmap( chimney(), 0, 0 ); // or
	 *  al_draw_bitmap( chimney.bitmap, 0, 0 );
	 *  ---
	 */
	@property
	ref ALLEGRO_BITMAP* bitmap() { //#maybe not ref
		return _bitmap;
	}
	
	ALLEGRO_BITMAP* opCall() {
		return bitmap;
	}
	
//	ALLEGRO_BITMAP* bitmap( ALLEGRO_BITMAP* bmp ) {
//		return _bitmap = bmp;
//	}
		
	/// Constructor: loads using passed in file name
	this( string fileName ) {
		try {
			_bitmap = loadBitmap( fileName );
		}
		catch( Exception e) { // or FileException
			new Exception( format( `Error tying to load "%s": %s`, fileName, e.toString() ) );
		}
		_name = fileName;
	}
	
	/// Constuctor: just creates bitmap with given sizes
	this( int w, int h, in string name = "untitled" ) {
		_name = name;
		_bitmap = al_create_bitmap( w, h );
	}
	
	~this() {
		if ( _bitmap !is null ) {
			al_destroy_bitmap( _bitmap );
			_bitmap = null;
			debug( Free )
				writeln( _name ~ " bitmap destroyed and set to null" );
		} else {
			debug( Free )
				writeln( _name ~ " bitmap already null" );
		}
	}
	
	void resize( float w, float h ) {
		auto bmp = al_create_bitmap( cast(int)w, cast(int)h );
		al_set_target_bitmap( bmp );
		al_draw_scaled_bitmap(
			_bitmap,
			0f,0f, cast(float)al_get_bitmap_width( _bitmap ), cast(float)al_get_bitmap_height( _bitmap ),
			0f,0f, w, h,
			0 // flag
		);
		auto tmp = _bitmap;
		_bitmap = bmp;
		al_destroy_bitmap( tmp );
		tmp = null;
		al_set_target_backbuffer( DISPLAY );
	}
	
	typeof(this) draw( ALLEGRO_BITMAP* dest, real x, real y, int flags = 0 ) {

		al_set_target_bitmap( dest );
		al_draw_bitmap( _bitmap, x, y, flags );
		al_set_target_backbuffer( DISPLAY );

		return this;
	}
}

//#colour blend
//version = Test1;
version( Test1 ) {
	import jeca.all;
	
	void main() {
		Init( [""] );
		scope( exit ) Deinit();
		
		//dub 
		foreach( x; 0 .. 100 ) {
			al_draw_filled_rectangle(
				x * 3, 0, x * 3 + 3, 480,
				//getBlend( Colour.red, Colour.red, x / 100.0 )
				getBlend( Colour.red, Colour.blue, x / 100.0 )
				//getBlend( Colour.blue, Colour.red, x / 100.0 )
				//getBlend( makecol( 240, 0, 0 ), makecol( 255, 0, 0 ), x / 100.0 )
				//getBlend( makecol( 255, 180, 0 ), makecol( 0, 255 - 180, 255 ), x / 100.0 )
				//getBlend( makecol( 240, 240, 240 ), makecol( 25, 255, 255 ), x / 100.0 )
			);
		}
		al_draw_rectangle( 0, 0, 100 * 3, 480, Colour.white, 1 );
		al_flip_display();

		poll_input_wait();
	}
}

/+
0.6 red
1.0 red
0.5 percent
//0.75 should be

0.1 - 0.6 = 0.4
0.4 / 0.5 = 

+/

ALLEGRO_COLOR getBlend( ALLEGRO_COLOR a, ALLEGRO_COLOR b, dub percent ) {
	ubyte r1,g1,b1, r2,g2,b2;

	al_unmap_rgb( a, &r1, &g1, &b1 );
	al_unmap_rgb( b, &r2, &g2, &b2 );
	
//	mixin( traceLine( "r1 r2 g1 g2 b1 b2".split ) );

	ubyte chan( int ac, int bc ) {
		//#workings
		// ac = 240, bc = 255
		// 255 - 240 = 15
		// 15 * 0.5 = 7.5
		// 7.5 + ac = 247.5
		dub width = bc - ac;
		//mixin( test( "cast(int)width == abs( 240 - 255 )", "width as expected" ) );
		dub step = width * percent;
		dub dc = ac + step;

//		mixin( traceLine( "percent width step dc".split ) );
		//dub dc = step * percent;

		return cast(ubyte)dc;
	}
	
	return makecol( chan( r1, r2 ), chan( g1, g2 ), chan( b1, b2 ) );
}
