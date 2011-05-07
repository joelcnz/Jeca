pragma( lib, "liballegro5" );
pragma( lib, "libdallegro5" );
pragma( lib, "libjeca" );

import std.stdio;
import std.string;
import jeca.all;

void main( string[] args ) {
	scope( exit )
		shutdown_input;

	if ( args.length != 4 ) {
		writeln( "test <ttf name> <picture file name> <sound file name>" );
		writeln( "Defaulting to: test DejaVuSans.ttf mysha.pcx fire.wav" );
		args ~= "DejaVuSans.ttf mysha.pcx fire.wav".split;
	}

	try {
		Init( args ); //[ "-mode window -wxh 800 600 -depth 32" ] );
	} catch( Exception e ) {
		writeln( "Caught in test.d in main: " ~ e.toString );
	}
	
	string loadTest( in string lhs, in string rhs ) {
		return
			lhs ~ ` = ` ~ rhs ~ `; `
			`if (` ~ lhs ~ ` !is null ) {`
				`writeln( "loading ` ~ `", ": passed" ); `
			`} `
			`else `
				`writeln( "` ~ lhs ~ `", ": failed" ); `;
	}
	
	//mixin( loadTest( "FONT", `al_load_font("DejaVuSans.ttf", 18, 0)` ) );
	mixin( loadTest( "FONT", `al_load_font( toStringz( args[1] ), 18, 0)` ) );
	//FONT = al_load_font("DejaVuSans.ttf", 18, 0);
	auto pic = al_load_bitmap( toStringz( args[ 2 ] ) );
	auto snd = new Snd( args[ 3 ] );
//	auto snd = al_load_sample( toStringz( args[ 3 ] ) );
	
	assert( snd !is null && pic !is null && FONT !is null, "media missing or failed." );

	auto spr = new Bmp( 16, 16 );
	al_set_target_bitmap( spr() );
	
	al_set_target_bitmap( al_get_backbuffer( DISPLAY ) );
	float y = 0f;

	writeln( "Help:\nEscape to exit\ncursor down to move triangle\nEnter for sound" );
	bool exit = false;
	while( ! exit )
	{
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
						case ALLEGRO_KEY_DOWN: y += 10; break;
						case ALLEGRO_KEY_ENTER:
							writeln( "Lets hear it!" );
							snd.play;
							/*
							al_play_sample(
								snd,
								1.0,
								ALLEGRO_AUDIO_PAN_NONE,
								1.0,
								ALLEGRO_PLAYMODE.ALLEGRO_PLAYMODE_ONCE,
								null
							);
							*/
							break;
						default:
						break;
					}
					break;
				}
				case ALLEGRO_EVENT_MOUSE_BUTTON_DOWN:
				{
					exit = false;
					break;
				}
				default:
			}
		}
		if ( key[ ALLEGRO_KEY_D ] )
			++y;

		al_clear_to_color( ALLEGRO_COLOR(0.5, 0.25, 0.125, 1) );
		al_draw_bitmap( pic, 50, 50, 0 );
		al_draw_triangle( 20, y + 20, 300, y + 30, 200, y + 200, ALLEGRO_COLOR( 1, 1, 1, 1 ), 4 );
		al_draw_text(
			FONT,
			ALLEGRO_COLOR( 1, 1, 1, 1 ),
			70, 40,
			ALLEGRO_ALIGN_CENTRE, toStringz( format( "y = %s", y ) )
		);
		al_flip_display;
	}
}
