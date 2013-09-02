#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <mpd/client.h>

#ifdef DEBUG
	#define DO_DEBUG DEBUG
#else
	#define DO_DEBUG 0
#endif
#define DEBUG_PRINTF(...) do{ if (DO_DEBUG) { printf(__VA_ARGS__);} } while(0)

/* Output the current song if MPD is in a playing state. The connection password, host and port is
 * specified like for mpc with environment variables
 * MPD_HOST=[password@]host
 * MPD_PORT=port
 * If they are empty they defaults to localhost on port 6600.
 */
int main(int argc, const char *argv[])
{
	char *mpd_host = NULL;
	char *mpd_password = NULL;
	unsigned int mpd_port = 0;

	char *mpd_host_m = NULL;
	char *mpd_password_m = NULL;

	const char *mpd_host_str = getenv("MPD_HOST");
	if (mpd_host_str == NULL || strlen(mpd_host_str) == 0) {
		DEBUG_PRINTF("No envvar MPD_HOST set or empty. Using default value (localhost).\n");
		mpd_host = "localhost";
	} else {
		size_t mpd_host_len = strlen(mpd_host_str);
		char mpd_host_env[mpd_host_len + 1];
		strncpy(mpd_host_env, mpd_host_str, mpd_host_len);
		mpd_host_env[mpd_host_len] = '\0';

		char *pch = strtok(mpd_host_env, "@");
		char *first = NULL;
		char *second = NULL;
		if (pch != NULL) {
			first = pch;
		}
		pch = strtok(NULL, "@");
		if (pch != NULL) {
			second = pch;
		}

		if (first != NULL && second != NULL) {
			DEBUG_PRINTF("%s - %s\n", first, second);
			size_t first_len = strlen(first);
			size_t second_len = strlen(second);
			mpd_password_m = (char *) malloc(first_len + 1);
			mpd_host_m= (char *) malloc(second_len + 1);
			if (mpd_password_m == NULL || mpd_host_m == NULL) {
				DEBUG_PRINTF("Failed alloc password/host.\n");
				return EXIT_FAILURE;
			}
			strncpy(mpd_password_m, first, first_len);
			mpd_password_m[first_len] = '\0';
			strncpy(mpd_host_m, second, second_len);
			mpd_host_m[second_len] = '\0';
		} else if (first != NULL) {
			DEBUG_PRINTF("%s\n", first);
			size_t first_len = strlen(first);
			mpd_host_m = (char *) malloc(first_len + 1);
			if (mpd_host_m == NULL ) {
				DEBUG_PRINTF("Failed alloc host.\n");
				return EXIT_FAILURE;
			}
			strncpy(mpd_host_m, first, first_len);
			mpd_host_m[first_len] = '\0';
		}
	}

	if (mpd_host_m != NULL) {
		mpd_host =  mpd_host_m;
	}

	if (mpd_password_m != NULL) {
		mpd_password =  mpd_password_m;
	}

	const char *mpd_port_env = getenv("MPD_PORT");
	if (mpd_port_env == NULL || strlen(mpd_port_env) == 0) {
		DEBUG_PRINTF("No envvar MPD_PORT set or empty. Using default value (6600).\n");
		mpd_port = 6600;
	} else {
		int mpd_port_m = atoi(mpd_port_env);
		if (mpd_port_m == 0) {
			DEBUG_PRINTF("Could not convert MPD_PORT to int.\n");
			return EXIT_FAILURE;
		} else if (mpd_port_m < 0) {
			DEBUG_PRINTF("Negative port?!\n");
			return EXIT_FAILURE;
		} else {
			mpd_port = mpd_port_m;
			DEBUG_PRINTF("Using port %i\n", mpd_port);
		}
	}


	struct mpd_connection *mpd_connection = mpd_connection_new(mpd_host, mpd_port, 1000);
	if (mpd_connection == NULL) {
		DEBUG_PRINTF("%s\n", "Could Not connect");
		return EXIT_FAILURE;
	}

	if (mpd_password != NULL) {
		bool authenticated = mpd_run_password(mpd_connection, mpd_password);
		if (!authenticated) {
			DEBUG_PRINTF("Failed to authenticate.\n");
			return EXIT_FAILURE;
		}
	}

	free(mpd_host_m);
	free(mpd_password_m);

	bool sent_status = mpd_send_status(mpd_connection);
	if (!sent_status) {
		DEBUG_PRINTF("Could not send status request.");
		return EXIT_FAILURE;
	}
	struct mpd_status *mpd_status = mpd_recv_status(mpd_connection);
	if (mpd_status == NULL) {
		DEBUG_PRINTF("Could not get mpd status.\n");
		return EXIT_FAILURE;
	}

	enum mpd_state mpd_state = mpd_status_get_state(mpd_status);
	DEBUG_PRINTF("State: ");
	if (mpd_state == MPD_STATE_PLAY) {
		DEBUG_PRINTF("Playing.");
	} else if (mpd_state == MPD_STATE_PAUSE) {
		DEBUG_PRINTF("Paused.");
	} else if (mpd_state == MPD_STATE_UNKNOWN) {
		DEBUG_PRINTF("Unknown state.");
	} else if (mpd_state == MPD_STATE_STOP) {
		DEBUG_PRINTF("Stopped.");
	}
	DEBUG_PRINTF("\n");

	if (mpd_state != MPD_STATE_PLAY) {
		// Nothing to do.
		mpd_status_free(mpd_status);
		mpd_connection_free(mpd_connection);
		return EXIT_SUCCESS;
	}

	int song_id = mpd_status_get_song_id(mpd_status);
	DEBUG_PRINTF("songid = %i\n", song_id);

	mpd_status_free(mpd_status);

	struct mpd_song *song = mpd_run_get_queue_song_id(mpd_connection, song_id);
	if (song == NULL) {
		DEBUG_PRINTF("Could not get song.\n");
		return EXIT_FAILURE;
	}

	const char *song_artist = mpd_song_get_tag(song, MPD_TAG_ARTIST, 0);
	if (song_artist == NULL) {
		DEBUG_PRINTF("Could not get song artist.");
		return EXIT_FAILURE;
	}

	const char *song_title = mpd_song_get_tag(song, MPD_TAG_TITLE, 0);
	if (song_title == NULL) {
		DEBUG_PRINTF("Could not get song title.");
		return EXIT_FAILURE;
	}
	printf("%s - %s\n", song_artist, song_title);

	mpd_song_free(song);
	mpd_connection_free(mpd_connection);
	return EXIT_SUCCESS;
}
