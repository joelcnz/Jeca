//#not sure on struct
//#not sure on the names
//#not work
//#not sure about this
//#may not need to check args length
//#should be under file, and have append in its name
//#but what about to!char*( c_str );
//#this little critter I found in a C Allegro5 demo
//#I just commented it out
//#key1
//#I don't see the point of a BMP here
/**
 * Main module for the JECA library
 * 
 * This library uses the DAllegro 5 wrapper of the Allegro 5 C library
 * 
 * Usage:
 * 
 * eg.
 * ---
 * Init( "-wxh 640 480".split ); // full DISPLAY, and DISPLAY dimentions(sp) also "-mode window"
 * ---
 * eg.
 * ---
 * Init( null, ALLEGRO_INIT | TIMER | SOUND ); // setup only allegro_init, timer and sound also GRAPHICS, MOUSE, KEYBOARD, ALL_ALLEGRO (just use by its self), NO_ALLEGRO
 * ---
 */
module jeca.base;

// imports
private {
	import std.stdio; // like writeln
	import std.string;
	import std.file;
	import std.conv; // like to!string - //#but what about to!char*( c_str );
	import std.array;
	import std.c.string; //: cmem = memmove;

	import jeca.all;
}

//#key1
const MAX_KEYBUF = 16;

int key[ALLEGRO_KEY_MAX];
static int keybuf[MAX_KEYBUF];
static int keybuf_len = 0;
static ALLEGRO_MUTEX *keybuf_mutex;
static ALLEGRO_EVENT_QUEUE *input_queue;

// switch posiblities(sp)
enum {
	NO_ALLEGRO = 0,
	ALLEGRO_INIT = 1,
	TIMER = 2,
	KEYBOARD = 4,
	MOUSE = 8,
	SOUND = 16,
	GRAPHICS = 32,
	ALL_ALLEGRO = 0xFFFF
}
// ALLEGRO_INIT | TIMER | KEYBOARD | MOUSE | SOUND | GRAPHICS

/// declearations  and default settings for the graphic mode
int
	SCX = 800,
	SCY = 600;

//#not sure about this
enum {
	GET_DISPLAY_DIMENTIONS
}

alias al_map_rgb makecol;

/// kinda global
ALLEGRO_DISPLAY* DISPLAY;

ALLEGRO_EVENT_QUEUE* QUEUE;
ALLEGRO_FONT* FONT;

/// For selecting colours by name
struct ColourStruct {
	ALLEGRO_COLOR red, blue, green, amber, bluba, magenta, cyan, yellow, gray, white, black;
	void makeColours() {
		red = makecol( 255, 0, 0 );
		green = makecol( 0, 255, 0 );
		amber = makecol( 255, 180, 0 );
		blue = makecol( 0, 0, 255 );
		bluba = makecol( 0, 128, 255 );
		magenta = makecol( 255, 0, 255 );
		cyan = makecol( 0, 255, 255 );
		yellow = makecol( 255, 255, 0 );
		gray = makecol( 128, 128, 128 );
		white = makecol( 255, 255, 255 );
		black = makecol( 0, 0, 0 );
	}
}
ColourStruct Colour;

/**
 * Set every thing up
 * 
 * Set window dimention
 * 
 * Also install: timer, keyboard, and mouse
 * 
 * Uses mixin's for each install allegro part
 * Returns: 0 on success
 */
int Init( string[] args, int parts = ALL_ALLEGRO ) {
	foreach( arg; args ) {
		switch( arg ) {
			default:
			break;
			case "-h", "-?", "-help":
				writeln(
				"Usage:" ~ newline ~
				"	-help/h/?" ~ newline ~
				"	-mode/m (auto/windowed/full/noframe/opengl)" ~ newline ~
				"	-wxh (width height)"
				);
				return 1;
			break;
		}
	}

	assert( al_init, "al_init failure" );
	writeln( "al_init success");

	QUEUE = al_create_event_queue;

	scope ( failure ) {
		//#may not need to check args length
		writeln( "Init(", (args.length == 0 ? ["null"] : args), " parts code: ", parts, "); failure" );
	}
	try {
		auto pass = true;
		string checkOut( string test ) {
			return
				"write(`" ~ test ~ "` ~ `: `); "
				"if ( " ~ test ~ " == pass ) "
				"	writeln( `pass` ); "
				"else "
				"	writeln( `fail` ); ";
		}
		
		if ( parts & KEYBOARD ) {
			mixin( checkOut( "al_install_keyboard" ) );
			al_register_event_source( QUEUE, al_get_keyboard_event_source );
			
		}
		else
			writeln( "No keyboard" );
		if ( parts & MOUSE ) {
			mixin( checkOut( "al_install_mouse" ) );
			al_register_event_source( QUEUE, al_get_mouse_event_source );
		}
		else
			writeln( "No mouse" );
		if ( parts & SOUND ) {
			mixin( checkOut( "al_install_audio" ) );
			mixin( checkOut( "al_init_acodec_addon" ) );
			mixin( checkOut( "al_reserve_samples( 255 )" ) );
		}
		else
			writeln( "No sound" );

		// IMAGE_ADDON
		al_init_image_addon;
		// FONT_ADDON
		al_init_font_addon;
		// TTF_ADDON
		al_init_ttf_addon;
		// PRIMITIVES_ADDON
		al_init_primitives_addon;
		
		int display_flags;

		// Note: you can have parts not set to graphics, but you can still do grahics settings
		if ( args.length > 1 ) {
			foreach( i; 0 .. args.length ) {
				if ( args[i].length < 2 )
					continue;
				if ( args[i][0] == '-' ) {
					// list of helpers for easier reading
					int dummy;
					bool isEnoughArguments( int argDepth ) {
						return i + argDepth < args.length;
					}
					enum {
						oneArgument = 1,
						twoArguments = 2
					}
					alias i currentArgument;
					int nextArgument() {
						return i + 1;
					}
					int nextAfterNextArgument() {
						return i + 2;
					}
					enum {
						skipDash = 1
					}
					enum {
						yes = true,
						no = false
					}
					switch ( args[ currentArgument ][ skipDash .. $ ] ) {
						default:
							writeln("Unregistered: ", args[ currentArgument ] );
						break;
						case "wxh":
							if ( isEnoughArguments( twoArguments ) == true ) { // is there another two or more arguments?
								SCX = to!int( args[ nextArgument ] );
								SCY = to!int( args[ nextAfterNextArgument ] );
								i = nextAfterNextArgument; // move the index position
							}
						break;
						case "mode", "m":
							if ( isEnoughArguments( oneArgument ) ) {
								int[string] dflag = [
									"auto" : ALLEGRO_FULLSCREEN_WINDOW,
									"windowed" : ALLEGRO_WINDOWED,
									"full" : ALLEGRO_FULLSCREEN,
									"noframe" : ALLEGRO_NOFRAME,
									"opengl" : ALLEGRO_OPENGL
								];
								if ( args[ nextArgument ] in dflag )
									display_flags |= dflag[ args[ nextArgument ] ];
								else
									writeln( args[ nextArgument ], " not valid." );
							}
						break;
					} // switch
				} // if long enough argument
			}
		} // if is args
		
		if ( parts & GRAPHICS ) {
			writeln( "Graphic dimentions ( ", SCX, " x ", SCY, " )" );
			
			al_set_new_display_flags( display_flags ); //#just trying it out
			
			DISPLAY = al_create_display( SCX, SCY );
			al_register_event_source( QUEUE, al_get_display_event_source( DISPLAY ) );
			init_input; //#code for this little critter I found in a C Allegro5 demo
			Colour.makeColours; // mine :-)
			if ( ( parts & MOUSE ) == 0 )
				al_hide_mouse_cursor( DISPLAY );
		}
	} catch ( Exception e ) {
		throw new Exception("Install failure - Fatal error");
	}

	return 0;
}

void Deinit( string message = "" ) {
	shutdown_input;
	if ( ! message.empty )
		writeln( message );
}

/** initialises the input emulation */
void init_input()
{
   keybuf_len = 0;
   keybuf_mutex = al_create_mutex();

   input_queue = al_create_event_queue;
   al_register_event_source( input_queue, al_get_keyboard_event_source );
   al_register_event_source( input_queue, al_get_display_event_source( DISPLAY ) );
}

/** closes down the input emulation */
void shutdown_input()
{
	scope( success )
		writeln( "shutdown_input successfully" );
   al_destroy_mutex(keybuf_mutex);
   keybuf_mutex = null;

   al_destroy_event_queue(input_queue);
   input_queue = null;
}

/** helper function to add a keypress to a buffer */
static void add_key(ALLEGRO_KEYBOARD_EVENT* event)
{
   if ((event.unichar == 0) || (event.unichar > 255))
      return;

   al_lock_mutex(keybuf_mutex);

   if (keybuf_len < MAX_KEYBUF) {
      keybuf[keybuf_len] = event.unichar | ((event.keycode << 8) & 0xff00);
      keybuf_len++;
   }

   al_unlock_mutex(keybuf_mutex);
}

/** emulate poll_keyboard() and poll_joystick() combined */
void poll_input()
{
   ALLEGRO_EVENT event;

   while (al_get_next_event(input_queue, &event)) {

      switch (event.type) {

	 case ALLEGRO_EVENT_KEY_DOWN:
	    key[event.keyboard.keycode] = 1;
	    break;

	 case ALLEGRO_EVENT_KEY_UP:
	    key[event.keyboard.keycode] = 0;
	    break;

	 case ALLEGRO_EVENT_KEY_CHAR:
	    add_key(&event.keyboard);
	    break;

	 case ALLEGRO_EVENT_TIMER:
	    /* retrace_count incremented */
	    break;

	 case ALLEGRO_EVENT_DISPLAY_EXPOSE:
	    break;
	  default:
	  break;
      }
   }
}

/** blocking version of poll_input(), also wakes on retrace_count */
void poll_input_wait()
{
   al_wait_for_event(input_queue, null );
   poll_input();
}

/** emulate keypressed() */
int keypressed()
{
   poll_input();

   return keybuf_len > 0;
}

//#not work
/** emulate readkey(), except this version never blocks */
int readkey()
{
   int c = 0;

   poll_input();

   al_lock_mutex(keybuf_mutex);

   if (keybuf_len > 0) {
      c = keybuf[0];
      keybuf_len--;
      
    //  int tmp = keybuf[ $ - 1 ];
    //  for( int i = keybuf.length - 2; i >= 0; --i )
	//	keybuf[ i ] = keybuf[ i + 1 ];
      memmove(keybuf.ptr, keybuf.ptr + 1, keybuf[0].sizeof * keybuf_len);
      //memmove(keybuf, keybuf + 1, keybuf[0].sizeof * keybuf_len); //#I just commented it out, 'readkey' may not Work!
   }

   al_unlock_mutex(keybuf_mutex);

   return c;
}

/** emulate clear_keybuf() */
void clear_keybuf()
{
   al_lock_mutex(keybuf_mutex);

   keybuf_len = 0;

   al_unlock_mutex(keybuf_mutex);
}

//#should be under file, and have append in its name
/**
 * Append to z.txt file
 */
void tofile( string content ) {
	auto file = File( "z.txt", "a" );
	file.write( content ~ "\n\r" );
	file.close;
}

//#not sure on struct
struct ExitHandler {
private:
	ALLEGRO_EVENT event;
	bool getNextEvent() {
		return al_get_next_event( QUEUE, &event );
	}
public:
	auto doKeysAndCloseHandling() {
		auto
			exitFalse = false,
			exitTrue = true;
		
		poll_input; //#may be not needed after a library fix
		
		if ( key[ ALLEGRO_KEY_ESCAPE ] )
			return exitTrue;
		
		// keep going through current events till none left, in which case contiune
		while( getNextEvent() )
		{
			switch( event.type )
			{
				// close button includes Alt + F4 etc
				case ALLEGRO_EVENT_DISPLAY_CLOSE:
					return exitTrue;
					
				default:
				break;
			}
		}
		
		return exitFalse;
	}
}
//#not sure on the names
ExitHandler exitHandler;
