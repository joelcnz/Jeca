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

debug = Free;

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
