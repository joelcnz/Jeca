//#can't get this to work like I want it to
//#msecs
//#draw on spr here
module testjeca;

//version = AwfulSlow; // note: not fun to exit, actually not fun any way

version( Windows ) {
	pragma( lib, "liballegro5" );
	pragma( lib, "libdallegro5" );
	pragma( lib, "libjeca" );
}

version( linux ) {
	pragma( lib, "allegro" );
	pragma( lib, "allegro_primitives" );
	pragma( lib, "allegro_ttf" );
	pragma( lib, "allegro_font" );
	pragma( lib, "allegro_image" );
	pragma( lib, "allegro_audio" );
	pragma( lib, "allegro_acodec" );

	pragma( lib, "jeca" );

	pragma( lib, "dallegro5" );
}

import std.stdio;
import std.string;
import std.c.string;
import std.datetime;
import std.random;
import std.math;
import std.conv: text, to;
import std.array;
import std.exception;

import jeca.all;
import testodds;

void main( string[] args ) {
	if ( args.length == 1 ) {
		writeln( "test <picture file name> <sound file name> <ttf name>" );
		writeln( "Defaulting to: test mysha.pcx fire.wav DejaVuSans.ttf" );
	}
	args = "exe mysha.pcx fire.wav DejaVuSans.ttf".split() ~ args;

	immutable(char)* cstrFromBoard = toStringz( getTextClipBoard() );
	writeln( "From clpbrd: ",to!string( cstrFromBoard ) );
	setTextClipboard( "This text was " ~ "set done made".split[ uniform( 0, 3 ) ] ~" from within my program. :-)" );
	writeln( getTextClipBoard() );

	try {
		Init( args ); //[ "-mode window -wxh 800 600" ] );
	} catch( Exception e ) {
		writeln( "Caught in test.d in main: " ~ e.toString );
		return;
	}
	scope( failure ) writeln( "We have failed you today!" );
	scope( success ) writeln( "We have achieved success, people!" );
	scope( exit ) Deinit( "Farewell.." );

	alias toStringz z;
	auto cfg = al_load_config_file( z( "media.cfg" ) );
	scope( exit ) al_destroy_config( cfg );
	auto banner = to!string( al_get_config_value( cfg, z( "test" ), z( "banner" ) ) ) ~ " - from cfg file";
	
	writeln( "Defaulting to: test mysha.pcx fire.wav DejaVuSans.ttf" );

	al_set_new_bitmap_flags( ALLEGRO_MAG_LINEAR | ALLEGRO_MIN_LINEAR );
	immutable loadPic = "Bmp.loadBmp( @ )";
	Bmp pic;
	mixin( loadTest( "pic", "Bmp.loadBmp( @ )", "args[ 1 ]" ) );
	scope( exit ) clear( pic );
	Snd snd;
	mixin( loadTest( "snd", "new Snd( @ )", "args[ 2 ]" ) );
	scope( exit ) clear( snd );

	//font from Jeca
	mixin( loadTest( "FONT", `al_load_font( toStringz( @ ), 18, 0)`, " args[ 3 ] " ) );
	scope( exit ) al_destroy_font( FONT );
	
	enforce( snd !is null && pic !is null && FONT !is null, "Missing or failed media." );

	auto spr = new Bmp( 16, 16 );
	scope( exit ) clear( spr );
	al_set_target_bitmap( spr() );
	
	//#draw on spr here
	
	al_set_target_backbuffer( DISPLAY );
	float x = 0f, y = 0f;

	al_set_new_bitmap_flags( ALLEGRO_MEMORY_BITMAP );
	ALLEGRO_BITMAP* stamp = al_create_bitmap( DISPLAY_W, DISPLAY_H );
	scope( exit ) al_destroy_bitmap( stamp );
	al_set_new_bitmap_flags( ALLEGRO_VIDEO_BITMAP ); //#why do I need this?
	
	writeln(
		"\nHelp:\nEscape/Alt+F4/X frame button to exit\nbotton [D] to move triangle\n"
		"Enter for sound\nUp/down change size of graphic\n"
		"Ctrl 1/2/3 to toggle pic/triangle/and text on and off\n"
		"Ctrl N toggle pic quality on and off" );
	StopWatch sw;
	
	auto colourHSL = new ColourChanger;
	auto mouseStuff = new Mouse;
	
	sw.start;
	uint counter = 0, fps = 0;
	bool exit = false;
	auto bsize = 1f;
	immutable tenMillion = 10_000_000;
	immutable increase = true;
	immutable decrease = false;
	bool dir = increase;
	while( ! exit )
	{
		++counter;
		if ( sw.peek.hnsecs > tenMillion ) {
			sw.start;
			fps = counter;
			counter = 0;
		}
		//do {
			poll_input;
			
			ALLEGRO_EVENT event;
			while( al_get_next_event( QUEUE, &event ) )
			{
				switch(event.type)
				{
					// close button includes Alt + F4
					case ALLEGRO_EVENT_DISPLAY_CLOSE:
					{
						exit = true;
						break;
					}
					case ALLEGRO_EVENT_KEY_DOWN:
					{
						switch(event.keyboard.keycode)
						{
							case ALLEGRO_KEY_ESCAPE:
							{
								exit = true;
								break;
							}
							case ALLEGRO_KEY_ENTER:
								writeln( "Lets hear it!" );
								snd.play();
								break;
							case ALLEGRO_KEY_BACKSPACE:
								snd.stop(); // stops all the snd sounds
							break;
							default:
							break;
						}
						break;
					}
					case ALLEGRO_EVENT_MOUSE_BUTTON_DOWN:
					{
						banner ~= ".";
						break;
					}
					default:
				}
			}
			if ( key[ ALLEGRO_KEY_F ] )
				++y;
			if ( key[ ALLEGRO_KEY_R ] )
				--y;
			if ( key[ ALLEGRO_KEY_G ] )
				++x;
			if ( key[ ALLEGRO_KEY_D ] )
				--x;

		//#3
		version( AwfulSlow ) {
			al_set_target_bitmap( stamp );
			static bool pipe = true;
			ALLEGRO_COLOR col = ( pipe == true ? getColour( "red" ) : getColour( "orange" ) );
			foreach( py; 0 .. DISPLAY_H )
				foreach( px; 0 .. DISPLAY_W ) 
					al_put_pixel( px, py, col );
			if ( pipe )
				pipe = false;
			else
				pipe = true;
			al_set_target_backbuffer( DISPLAY );
			al_draw_bitmap( stamp, 0, 0, 0 );
		}
		else
			al_clear_to_color( getColour( "forestgreen" ) ); //ALLEGRO_COLOR(0.5, 0.25, 0.125, 1) );

		static int sboard = 1 | 2 | 4 | 8; // turn them all on
		immutable holdCtrl = "while( key[ ALLEGRO_KEY_LCTRL ] ) { poll_input; }";
		if ( key[ ALLEGRO_KEY_1 ] ) {
			sboard ^= 1;
			bsize = 1f;
			mixin( holdCtrl );
		}
		if ( key[ ALLEGRO_KEY_2 ] ) {
			sboard ^= 2;
			mixin( holdCtrl );
		}
		if ( key[ ALLEGRO_KEY_3 ] ) {
			sboard ^= 4;
			mixin( holdCtrl );
		}
		
		if ( key[ ALLEGRO_KEY_N ] ) {
			sboard ^= 8;
			if ( sboard & 8 )
				al_set_new_bitmap_flags( ALLEGRO_MAG_LINEAR | ALLEGRO_MIN_LINEAR );
			else
				al_set_new_bitmap_flags( 0 );
			mixin( loadTest( "pic", loadPic, "args[ 1 ]" ) );
			mixin( holdCtrl );
		}
		
		if ( key[ ALLEGRO_KEY_4 ] ) {
			sboard ^= 16;
			mixin( holdCtrl );
		}
		
		if ( sboard & 1 ) {
			al_draw_scaled_bitmap( pic.bitmap,
				0, 0, pic.width, pic.height,
				0, 0, pic.width * bsize, pic.height * bsize, 0 );
			if ( key[ ALLEGRO_KEY_DOWN ] ) {
				bsize *= 1.001;
				if ( bsize > 3 )
					dir = decrease;
			}
			else if ( key[ ALLEGRO_KEY_UP ] ) {
				bsize *= 0.999;
				if ( bsize < 1 / 3f )
					dir = increase;
			}
		}
		if ( sboard & 2 )
			al_draw_triangle( x + 20, y + 20, x + 300, y + 30, x + 200, y + 200, getColour( "purple" ), 4 ); // getColour( "darkorange" ), 4 );
		if ( sboard & 4 ) {
			al_draw_text(
				FONT,
				ALLEGRO_COLOR( 1, 1, 1, 1 ),
				70, 40,
				ALLEGRO_ALIGN_LEFT, toStringz(
				  format( "y = %3s counter: %3s fps: %3s, Stop Watch: %8s", y, counter, fps, sw.peek.hnsecs ) )
			);

			al_draw_text(
				FONT,
				ALLEGRO_COLOR( 1, 1, 1, 1 ),
				70, 60,
				ALLEGRO_ALIGN_LEFT,
				toStringz( banner )
			);
			
			al_draw_text(
				FONT,
				ALLEGRO_COLOR( 1, 1, 1, 1 ),
				70, 80,
				ALLEGRO_ALIGN_LEFT,
				toStringz( "Clipboard text: " ~ to!string(cstrFromBoard) )
			);
			
		}
		
		//#can't get this to work like I want it to
		if ( sboard & 16 ) {
			static float angle = 0f;
			al_draw_rotated_bitmap( pic.bitmap, pic.width / 2, pic.height / 2,
			  DISPLAY_W / 2, DISPLAY_H / 2,
			  angle, 0 );
			angle += ( PI * 2 ) / 3_000;
			if ( angle > ( PI * 2 ) )
				angle = 0;
		}
		
		with( colourHSL ) {
			input;
			draw;
		}
		
		with( mouseStuff ) {
			update;
			draw;
		}
		

		al_flip_display;
	}
}
