/*
 * display-keep-awake - stop X from blanking/powering off the display when idle.
 *
 * Equivalent to `xset s off -dpms`, but needs no extra package: it only uses
 * libX11 + libXext, which are always installed.
 *
 *   display-keep-awake          disable the screen saver and DPMS
 *   display-keep-awake status   print the current screen saver / DPMS state
 */
#include <X11/Xlib.h>
#include <X11/extensions/dpms.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char **argv)
{
    Display *dpy = XOpenDisplay(NULL);
    if (!dpy) {
        fprintf(stderr, "display-keep-awake: cannot open X display\n");
        return 1;
    }

    if (argc > 1 && strcmp(argv[1], "status") == 0) {
        int timeout, interval, prefer_blanking, allow_exposures;
        XGetScreenSaver(dpy, &timeout, &interval, &prefer_blanking, &allow_exposures);
        printf("screensaver timeout: %d s (0 = off)\n", timeout);

        int ev, er;
        if (DPMSQueryExtension(dpy, &ev, &er)) {
            CARD16 level;
            BOOL state;
            if (DPMSInfo(dpy, &level, &state))
                printf("dpms enabled: %s (power level %u)\n",
                       state ? "yes" : "no", (unsigned)level);
            else
                printf("dpms: query failed\n");
        } else {
            printf("dpms: extension not available\n");
        }
        XCloseDisplay(dpy);
        return 0;
    }

    /* timeout 0 disables the screen saver; reset clears any pending blank. */
    XSetScreenSaver(dpy, 0, 0, DefaultBlanking, DefaultExposures);
    XResetScreenSaver(dpy);

    int ev, er;
    if (DPMSQueryExtension(dpy, &ev, &er))
        DPMSDisable(dpy);

    XSync(dpy, False);
    XCloseDisplay(dpy);
    return 0;
}
