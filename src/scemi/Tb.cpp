
#include <iostream>
#include <unistd.h>
#include <cmath>
#include <cstdio>
#include <cstdlib>

#include "bsv_scemi.h"
#include "SceMiHeaders.h"
#include "ResetXactor.h"


FILE* outfile = NULL;

int main(int argc, char* argv[])
{

    int sceMiVersion = SceMi::Version( SCEMI_VERSION_STRING );
    SceMiParameters params("scemi.params");
    SceMi *sceMi = SceMi::Init(sceMiVersion, &params);

    // Initialize the SceMi ports
    OutportQueueT<Displacements> disp_get("", "scemi_dispget_get_outport", sceMi);
    InportProxyT<WindowReq> window_req("", "scemi_windowreq_put_inport", sceMi);
    InportProxyT<Data> im_store("", "scemi_imstore_put_inport", sceMi);
    InportProxyT<ClearT> im_clear("", "scemi_imclear_put_inport", sceMi);

    ResetXactor reset("", "scemi", sceMi);
    ShutdownXactor shutdown("", "scemi_shutdown", sceMi);

    // Service SceMi requests
    SceMiServiceThread *scemi_service_thread = new SceMiServiceThread(sceMi);

    // Reset the dut.
    reset.reset();

    im_clear.sendMessage(true);
    Data msg; 
    for (int i = 0; i < 4; i++) {
        msg = i;
        im_store.sendMessage(msg);
    }

    WindowReq winmsg;
    Displacements dispmsg;
    winmsg.m_size = 40;
    for (int i = 0; i < 4; i++) {
        winmsg.m_ndx = i;
        window_req.sendMessage(winmsg);
        dispmsg = disp_get.getMessage();
        fprintf(stdout, "%i %i\n", (int)dispmsg.m_v, (int)dispmsg.m_u);
    }



    shutdown.blocking_send_finish();
    scemi_service_thread->stop();
    scemi_service_thread->join();
    SceMi::Shutdown(sceMi);

    return 0;
}

