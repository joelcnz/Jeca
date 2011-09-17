//#redundant - use std.conv.text
module jeca.misc;

private import
	std.stdio,
	std.string,
	std.conv,
	std.math,
	std.c.string;

version( Windows ) {
	extern(Windows) {
	   bool OpenClipboard(void*);
	   void* GetClipboardData(uint);
	   void* SetClipboardData(uint, void*);
	   bool EmptyClipboard();
	   bool CloseClipboard();
	   void* GlobalAlloc(uint, size_t);
	   void* GlobalLock(void*);
	   bool GlobalUnlock(void*);
	}

	string getTextClipBoard() {
	   if (OpenClipboard(null)) {
		   scope( exit ) CloseClipboard();
		   auto cstr = cast(char*)GetClipboardData( 1 );
		   if(cstr)
			   return cstr[0..strlen(cstr)].idup;
		}
		return null;
	}

	string setTextClipboard( string mystr ) {
		if (OpenClipboard(null)) {
			scope( exit ) CloseClipboard();
			EmptyClipboard();
			void* handle = GlobalAlloc(2, mystr.length + 1);
			void* ptr = GlobalLock(handle);
			memcpy(ptr, toStringz(mystr), mystr.length + 1);
			GlobalUnlock(handle);

			SetClipboardData( 1, handle);
		}
		return mystr;
	}
}

alias double dub;

/// like format, but not having %s etc
//#redundant - use std.conv.text
string getWriteToString(T...)(T args) {
	string result = "";
	foreach( e; tuple( args ).expand )
		result ~= to!string( e );
	return result;
}

ubyte chr( int c ) {
	return c & 0xFF;
}

bool tkey( int let, int code ) {
	return let >> 8 == code;
}

/// char to char*
char* jtoCharPtr( dchar d ) {
	return cast(char*)to!(char[])(d ~ "\0"d).dup.ptr;
}

/// calculate distance between two 2D points
dub distance( dub x, dub y, dub tx, dub ty ) {
  return sqrt( ( x - tx ) ^^ 2 + ( y - ty ) ^^ 2 );
}

/// inaccreate(sp)
dub quickDistance( dub x,dub y, dub tx,dub ty )
{
  return abs( x - tx ) + abs( y - ty ); // maybe return absl( (x-tx)+(y-ty) );
}

/// Save writing the symbol twice each time
/// ---
/// mixin( trace( "xpos", "ypos" ) );
/// Output:
/// xpos: 1979
/// ypos: 30
/// ---
string trace( in string[] strs... ) {
	string result;
	foreach( str; strs ) {
		result ~= `writeln( "` ~ str ~ `: ", ` ~ str ~ ` );` ~ newline;
	}

	return result;
}

/**
 * int a = 1; double b = 0.2; string c = "three";
 * 
 * eg. mixin( traceLine( "a b c".split ) );
 * 
 * Output:
 * 
 * (a: 1) (b: 0.2) (c: three)
 */
string traceLine( in string[] strs... ) {
	string result;

	foreach( i, str; strs ) {
		result ~= `writef( "(` ~ str ~ `: %s) ", ` ~ str ~ ` );`;
	}
	result ~= `writeln();`;

	return result;
}

unittest {
	int a = 1;
	double b = 0.2;
	string c = "three";
	mixin( traceLine( "a b c".split ) );
}

/// TDD - test driven development tool - bit of one
string test(in string exp, in string should)
{
	// Note no new lines
	debug (TDD)
		return
			"write(`" ~ should ~ " - Testing ( " ~ exp ~ " ) - `); "
			"if ( " ~ exp ~ " ) "
			"{"
			"	write(`PASS`); "
			"} "
			"else "
			"{ "
			"	write(`FAIL`); "
			"} "
			"writeln(` - line: `,__LINE__, ` file: `, __FILE__); ";
	debug( TDD ) {
	} else {
		return "";
	}
}

