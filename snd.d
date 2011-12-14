//#I think it stops all of 'this' sounds playing
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
	/**
	 * Start a sample from the HDD
	 */
	this( string filename ) {
		_speed = _gain = _pan = 1.0;
		_sample = al_load_sample( toStringz( filename ) );
		assert( _sample, text( filename, " sound failed" ) );
	}
	
	void speed( float speed ) {
		_speed = speed;
	}
	
	void setSample() {
	}
	
	void setGain( real gain ) {
		_gain = gain;
	}
	
	/**
	 * Hear the sound
	 **/
	void play() {
		al_play_sample(
			_sample,
			_gain,
			ALLEGRO_AUDIO_PAN_NONE,
			_speed,
			ALLEGRO_PLAYMODE.ALLEGRO_PLAYMODE_ONCE,
			ret_id
		);
	}
	
	void stop() {
		if ( ret_id !is null )
			al_stop_sample( ret_id ); //#I think it stops all of 'this' sounds playing
		else
			al_stop_samples();
	}
	
	
	~this() {
		if ( _sample !is null )
			al_destroy_sample( _sample );
	}
private:
	ALLEGRO_SAMPLE* _sample;
	ALLEGRO_SAMPLE_ID* ret_id;
	float
		_speed,
		_gain,
		_pan;
}
