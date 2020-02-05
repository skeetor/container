#include <stdio.h>

#include <exec/exec>

bool testLibrary(void)
{
	ExecLibrary exec;

	struct ExecBase *libExec = exec;

	if (libExec != (struct ExecBase *)0x676)
		return false;

	const char *argv[] =
	{
		"dos.library",
		"intution.library",
		nullptr
	};

	int argc = 0;
	while(argv[argc])
		argc++;

	for(int i = 0; i < argc; i++)
	{
		const char *libname = argv[i];

		struct Library *lib = exec.OpenLibrary(libname, 0);

		if(lib)
		{
			exec.CloseLibrary(lib);
		}
		else
			return false;
			
	}

	return true;
}
