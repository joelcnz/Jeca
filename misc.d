module jeca.misc;

private import
	std.stdio,
	std.string,
	std.math;

alias double dub;

dub distance( dub x,dub y, dub tx,dub ty )
{
  return abs( x - tx ) + abs( y - ty ); // maybe return absl( (x-tx)+(y-ty) );
}

/// Save writing the symbol twice
string trace(string varName) {
	return `writeln("` ~ varName ~ `: ", ` ~ varName ~ `);`;
}

/// Same as above with title though
string trace( in string title, in string varName ) {
	return `writeln("` ~ title ~ ` ` ~ varName ~ `: ", ` ~ varName ~ `);`;
}

/+
string traceForList( in string title, in string varName ) {
	return `writeln("` ~ title ~ `: ", ` ~ varName ~ `);`;
}

void traceList( in string varsName ) {
	foreach( var; varsName.split )
		//mixin( trace( var.stringof, "var" ) );
		mixin( traceForList( "var", var.stringof ) );
}
+/

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
