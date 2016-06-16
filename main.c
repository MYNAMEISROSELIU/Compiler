#include "heading.h"

int yyparse();

int main(int argc, char **argv)
{
	if((argc > 1) && (freopen(argv[1], "r", stdin) == NULL)) {
		cerr << argv[0] << ": File " << argv[1] << " cannot be opened." << endl;
		exit(1);
	}
	//fstream fileout;
	//fileout.open("output.s",ios::out);
	//fileout << "main:\n";

	yyparse();
	//fileout.close();

	return 0;
}
