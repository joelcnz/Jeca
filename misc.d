module jeca.misc;

private import
	std.stdio,
	std.string,
	std.math;

//void main() {}

alias double dub;

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
