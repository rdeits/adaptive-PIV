
#include <iostream>
#include <unistd.h>
#include <cmath>
#include <cstdio>
#include <cstdlib>

#include "bsv_scemi.h"
#include "SceMiHeaders.h"

#define PIXEL_DEPTH 4
#define PIXELS_PER_MSG 8


void out_cb(void* x, const Displacements& dispmsg)
{
    static int cnt = 1;
    fprintf(stdout, "%i: $%d\n$%d\n$%d\n", cnt, (int)dispmsg.m_ndx, (int)dispmsg.m_u, (int)dispmsg.m_v);
    cnt++;
}

int main(int argc, char* argv[])
{

    fprintf(stderr, "1");
    int sceMiVersion = SceMi::Version( SCEMI_VERSION_STRING );
    SceMiParameters params("scemi.params");
    SceMi *sceMi = SceMi::Init(sceMiVersion, &params);
    fprintf(stderr, "2");

    // Initialize the SceMi ports
    OutportProxyT<Displacements> disp_get("", "scemi_dispget_get_outport", sceMi);
    disp_get.setCallBack(out_cb, NULL);

    InportProxyT<WindowReq> window_req("", "scemi_windowreq_put_inport", sceMi);
    InportProxyT<ImagePacket> im_store_A("", "scemi_imstoreA_put_inport", sceMi);
    InportProxyT<ImagePacket> im_store_B("", "scemi_imstoreB_put_inport", sceMi);
    InportProxyT<BitT<1> > im_cleardone("", "scemi_imclear_put_inport", sceMi);
    fprintf(stderr, "3");

    ShutdownXactor shutdown("", "scemi_shutdown", sceMi);
    fprintf(stderr, "4");

    // Service SceMi requests
    SceMiServiceThread *scemi_service_thread = new SceMiServiceThread(sceMi);
    fprintf(stderr, "5");

    fprintf(stderr, "6");

    im_cleardone.sendMessage(BitT<1>(0));
    fprintf(stderr, "6");
    char *line;
    size_t len = 0;
    int read;
    int pixel;
    ImagePacket msg;
    int line_pos = 0;
    fprintf(stderr, "waiting for image A\n");
    while ((read = getline(&line, &len, stdin)) != -1) {
        if (read != 0) {
            if (line[0] == '.') {
                break;
            } else {
                pixel = atoi(line);
                msg[line_pos] = (pixel >> (8 - PIXEL_DEPTH));
                line_pos++;
                if (line_pos == PIXELS_PER_MSG) {
                    line_pos = 0;
                    im_store_A.sendMessage(msg);
                }
            }
        }
    }
    fprintf(stderr, "Finished storing image A\n");
    line_pos = 0;
    while ((read = getline(&line, &len, stdin)) != -1) {
        if (read != 0) {
            if (line[0] == '.') {
                break;
            } else {
                pixel = atoi(line);
                msg[line_pos] = (pixel >> PIXEL_DEPTH);
                line_pos++;
                if (line_pos == PIXELS_PER_MSG) {
                    line_pos = 0;
                    im_store_B.sendMessage(msg);
                }
            }
        }
    }
    im_cleardone.sendMessage(BitT<1>(1));
    fprintf(stderr, "Finished storing image B\n");

    WindowReq winmsg;
    int num_requests = 0;
    while ((read = getline(&line, &len, stdin)) != -1) {
        if (read != 0) {
            if (line[0] == '.') {
                break;
            } else {
                winmsg.m_ndx = atoi(line);
                fprintf(stderr, "Sending request: %d\n", (int)winmsg.m_ndx);
                window_req.sendMessage(winmsg);
                num_requests++;
            }
        }
    }
//    Displacements dispmsg;
//    for (int i = 0; i < num_requests; i++) {
//        dispmsg = disp_get.getMessage();
//        fprintf(stdout, "$%d\n$%d\n$%d\n", (int)dispmsg.m_ndx, (int)dispmsg.m_u, (int)dispmsg.m_v);
//        fprintf(stderr, "$%d\n$%d\n$%d\n", (int)dispmsg.m_ndx, (int)dispmsg.m_u, (int)dispmsg.m_v);
//    }
    fprintf(stderr, "Waiting for %i displacements... (press enter when ready)", num_requests);
    getchar();
    fprintf(stderr, "Finished tracking\n");
    // winmsg.m_size = 40;
    // for (int i = 0; i < 1; i++) {
    //     winmsg.m_ndx = i * 8;
    //     window_req.sendMessage(winmsg);
    //     dispmsg = disp_get.getMessage();
    //     fprintf(stdout, "Tb got %d %d\n", (int)dispmsg.m_u, (int)dispmsg.m_v);
    // }
// 

    shutdown.blocking_send_finish();
    scemi_service_thread->stop();
    scemi_service_thread->join();
    SceMi::Shutdown(sceMi);

    return 0;
}

