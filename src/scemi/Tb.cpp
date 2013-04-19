
#include <iostream>
#include <unistd.h>
#include <cmath>
#include <cstdio>
#include <cstdlib>

#include "bsv_scemi.h"
#include "SceMiHeaders.h"
#include "ResetXactor.h"

#define PIXEL_DEPTH 4
#define PIXELS_PER_MSG 8

FILE* outfile = NULL;

int main(int argc, char* argv[])
{

    int sceMiVersion = SceMi::Version( SCEMI_VERSION_STRING );
    SceMiParameters params("scemi.params");
    SceMi *sceMi = SceMi::Init(sceMiVersion, &params);

    // Initialize the SceMi ports
    OutportQueueT<Displacements> disp_get("", "scemi_dispget_get_outport", sceMi);
    InportProxyT<WindowReq> window_req("", "scemi_windowreq_put_inport", sceMi);
    InportProxyT<ImagePacket> im_store("", "scemi_imstore_put_inport", sceMi);
    InportProxyT<ClearT> im_clear("", "scemi_imclear_put_inport", sceMi);
    InportProxyT<ClearT> im_done("", "scemi_imdone_put_inport", sceMi);

    ResetXactor reset("", "scemi", sceMi);
    ShutdownXactor shutdown("", "scemi_shutdown", sceMi);

    // Service SceMi requests
    SceMiServiceThread *scemi_service_thread = new SceMiServiceThread(sceMi);

    // Reset the dut.
    reset.reset();

    im_clear.sendMessage(true);
    char *line;
    size_t len = 0;
    int read;
    int pixel;
    ImagePacket msg;
    int line_pos = 0;
    while ((read = getline(&line, &len, stdin)) != -1) {
        if (read != 0) {
            pixel = atoi(line);
            msg[line_pos] = (pixel >> PIXEL_DEPTH);
            line_pos++;
            if (line_pos == PIXELS_PER_MSG) {
                line_pos = 0;
                im_store.sendMessage(msg);
            }
        }
    }
    im_done.sendMessage(true);

    WindowReq winmsg;
    Displacements dispmsg;
    winmsg.m_size = 40;
    for (int i = 0; i < 4; i++) {
        winmsg.m_ndx = i;
        window_req.sendMessage(winmsg);
        dispmsg = disp_get.getMessage();
        fprintf(stdout, "Tb got %x\n", (int)dispmsg.m_v);
    }



    shutdown.blocking_send_finish();
    scemi_service_thread->stop();
    scemi_service_thread->join();
    SceMi::Shutdown(sceMi);

    return 0;
}

