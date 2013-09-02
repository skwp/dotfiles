/* xkb_layout
 * Description:
 * This program will connect to the X Server and print the id of the currently
 * active keyboard layout.
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <X11/XKBlib.h>

#ifdef DEBUG
	#define DO_DEBUG DEBUG
#else
	#define DO_DEBUG 0
#endif
#define DEBUG_PRINTF(...) do{ if (DO_DEBUG) { printf(__VA_ARGS__);} } while(0)

int main() {
	// Get X display
	char *displayName = "";
	int eventCode;
	int errorReturn;
	int major = XkbMajorVersion;
	int minor = XkbMinorVersion;;
	int reasonReturn;
	Display *_display = XkbOpenDisplay(displayName, &eventCode, &errorReturn,
			&major, &minor, &reasonReturn);
	bool error = false;
	switch (reasonReturn) {
	case XkbOD_BadLibraryVersion:
		DEBUG_PRINTF("Bad XKB library version.\n");
		error = true;
		break;
	case XkbOD_ConnectionRefused:
		DEBUG_PRINTF("Connection to X server refused.\n");
		error = true;
		break;
	case XkbOD_BadServerVersion:
		DEBUG_PRINTF("Bad X11 server version.\n");
		error = true;
		break;
	case XkbOD_NonXkbServer:
		DEBUG_PRINTF("XKB not present.\n");
		error = true;
		break;
	case XkbOD_Success:
		break;
	}

	if (error) {
		return EXIT_FAILURE;
	}

	// Get current state of keyboard.
	int _deviceId = XkbUseCoreKbd;
    	XkbStateRec xkbState;
    	XkbGetState(_display, _deviceId, &xkbState);
	// print the groupnumber, may be used with setxkbmap -query to get name
	// of current layout
	printf("%d\n", xkbState.group);
	return 0;
	return EXIT_SUCCESS;
}
