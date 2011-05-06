//#I think there's a shorter way to do it
/**
 * Bitmap module a layer above ALLEGRO_BITMAP*
 */
module jeca.bmp;

private {
	import std.stdio;
	import std.string;
	import std.file;
//	import allegro5.allegro;
	import jeca.all;
}

/*
 * Title: Bmp - to do with bitmaps (images made up of bits)
 * 
 * terminolagy(sp): bitmap = ALLEGRO_BITMAP* and bmp is Bmp
 */
class Bmp {
private:
	/// Allegros bitmap
	ALLEGRO_BITMAP* _bitmap;
public:
	/**
	 *  get bitmap like:
	 *  ---
	 *  al_draw_bitmap( chimney(), 0, 0 );
	 *  ---
	 */
	ALLEGRO_BITMAP* opCall() { // maybe add ref and @property(sp)
		return _bitmap;
	}
	
	ALLEGRO_BITMAP* opCall( ALLEGRO_BITMAP* bmp ) {
		return _bitmap = bmp;
	}
	
	/// Constructor: loads using passed in file name
	this( string fileName ) {
		try {
			_bitmap = loadBitmap( fileName );
		}
		catch( Exception e) { // or FileException
			writeln( `Error tying to load "`, fileName, `": `, e.toString );
		}
	}
	
	/// Constuctor: just creates bitmap with given sizes
	this( int w, int h ) {
		_bitmap = al_create_bitmap( w, h );
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
		al_set_target_bitmap( al_get_backbuffer( DISPLAY ) ); // switch it back! //#I think there's a shorter way to do it
	}
	
	/// get a slice
	static Bmp getBmpSlice(
		Bmp src, // source Bmp
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
		al_draw_bitmap_region( src(), sx, sy, w, h, dx, dy, flags );

		return bmp;
	}
	
	typeof(this) draw( ALLEGRO_BITMAP* dest, real x, real y, int flags = 0 ) {

		al_set_target_bitmap( dest );
		al_draw_bitmap( _bitmap, x, y, flags );
		
		return this;
	}
}

ALLEGRO_BITMAP* loadBitmap( string fileName ) {
	if ( ! exists( fileName ) )
		throw new Exception( format( "%s not found", fileName ) );
	
	auto bitmap = al_load_bitmap( toStringz( fileName ) );
	if ( bitmap is null )
		throw new Exception( format( "%s failed to load.", fileName ) );

}
