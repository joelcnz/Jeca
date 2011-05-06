module jeca.misc;

private import std.stdio;

version( linux ) {
	immutable g_div = '/';
}
else version( Windows ) {
	immutable g_div = '\\';
}

/// Save writing the symbol twice
string trace(string varName) {
	return `writeln("` ~ varName ~ `: ", ` ~ varName ~ `);`;
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
