/**
 * Sample module a layer over allegros sound stuff
 */
module jeca.snd;

private {
	import std.stdio;
	import std.string;
	import std.file;
	import jeca.all;
}

class Snd {
public:
	this( string filename ) {
		_sample = al_load_sample( toStringz( filename ) );
	}
	void play() {
		al_play_sample(
			_sample,
			1.0,
			1.0,
			1.0,
			0,
			null
		);
	}
private:
	ALLEGRO_SAMPLE* _sample;
}
