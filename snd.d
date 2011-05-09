//#don't know the order of the arguments
/**
 * Sample module a layer over allegros sound stuff
 */
module jeca.snd;

private {
	import std.stdio;
	import std.string;
	import std.file;
	import std.conv;
	
	import jeca.all;
}

class Snd {
public:
	this( string filename ) {
		_speed = _gain = _pan = 1.0;
		_sample = al_load_sample( toStringz( filename ) );
		assert( _sample, text( filename, " sound failed" ) );
	}
	
	void setSample() {
	}
	
	void setGain( real gain ) {
		_gain = gain;
	}
	
	//#don't know the order of the arguments
	void play() {
		al_play_sample(
			_sample,
			_gain,
			ALLEGRO_AUDIO_PAN_NONE,
			_speed,
			ALLEGRO_PLAYMODE.ALLEGRO_PLAYMODE_ONCE,
			null
		);
	}
	
	~this() {
		clear( _sample );
	}
private:
	ALLEGRO_SAMPLE* _sample;
	float
		_speed,
		_gain,
		_pan;
}
