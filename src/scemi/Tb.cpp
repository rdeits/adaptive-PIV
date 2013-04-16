
#include <iostream>
#include <unistd.h>
#include <cmath>
#include <cstdio>
#include <cstdlib>

#include "bsv_scemi.h"
#include "SceMiHeaders.h"
#include "ResetXactor.h"


int main(int argc, char* argv[])
{


FILE* outfile = NULL;

// Initialize the memories from the given vmh file.
bool mem_init(const char *filename, InportProxyT<MemInit>& imem)
{
    char *line;
    size_t len = 0;
    int read;

    FILE *file = fopen(filename, "r");

    if (file == NULL)
    {
        fprintf(stderr, "could not open image file %s.\n", filename);
        return false;
    }

    uint32_t addr = 0;
    while ((read = getline(&line, &len, file)) != -1) {
        if (read != 0) {
            uint32_t data = strtoul(line, NULL, 16);

            MemInit msg;
            msg.the_tag = MemInit::tag_InitLoad;
            msg.m_InitLoad.m_addr = addr;
            msg.m_InitLoad.m_data = data;
            imem.sendMessage(msg);

            addr++;
        }
    }

    free(line);
    fclose(file);

    MemInit msg;
    msg.the_tag = MemInit::tag_InitDone;
    imem.sendMessage(msg);
    return true;
}

int main(int argc, char* argv[])
{

    int sceMiVersion = SceMi::Version( SCEMI_VERSION_STRING );
    SceMiParameters params("scemi.params");
    SceMi *sceMi = SceMi::Init(sceMiVersion, &params);

    // Initialize the SceMi ports
    OutportQueueT<Displacements> disp_get("", "scemi_dispget_outport", sceMi);
    InportProxyT<WindowReq> window_req("", "scemi_windowreq_inport", sceMi);
    InportProxyT<Data> im_store("", "scemi_imstore_inport", sceMi);
    InportProxyT<Boolean> im_clear("", "scemi_imclear_inport", sceMi);

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

    WindowReq msg;
    
    window_req.

    char* vmh = argv[1];
    // Initialize the memories.
    if (!mem_init(vmh, imem)) {
        fprintf(stderr, "Failed to load memory\n");
        std::cout << "shutting down..." << std::endl;
        shutdown.blocking_send_finish();
        scemi_service_thread->stop();
        scemi_service_thread->join();
        SceMi::Shutdown(sceMi);
        std::cout << "finished" << std::endl;
        return 1;
    }

    // Handle tohost requests.
    while (true) {
        ToHost msg = tohost.getMessage();
        uint32_t data = msg;
        fprintf(stdout, "%i\n", data);
        break;
    }

    shutdown.blocking_send_finish();
    scemi_service_thread->stop();
    scemi_service_thread->join();
    SceMi::Shutdown(sceMi);

    return 0;
}

