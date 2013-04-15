
#include <iostream>
#include <unistd.h>
#include <cmath>
#include <cstdio>
#include <cstdlib>

#include "bsv_scemi.h"
#include "SceMiHeaders.h"
#include "ResetXactor.h"

FILE* outfile = NULL;
bool indone = false;

void out_cb(void* x, const BitT<16>& res) {
    if (indone && outfile) {
        fclose(outfile);
        outfile = NULL;
    } else {
        int a = res.get();
        fputc(a, outfile);
    }
}

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
    if (argc < 2) {
        fprintf(stderr, "usage: TestDriver <data-file>\n");
        return 1;
    }
    char* vmh = argv[1];

    int sceMiVersion = SceMi::Version( SCEMI_VERSION_STRING );
    SceMiParameters params("scemi.params");
    SceMi *sceMi = SceMi::Init(sceMiVersion, &params);

    // Initialize the SceMi ports
    InportProxyT<MemInit> imem("", "scemi_imem_inport", sceMi);
    OutportQueueT<ToHost> tohost("", "scemi_tohost_get_outport", sceMi);
    InportProxyT<FromHost> fromhost("", "scemi_fromhost_put_inport", sceMi);
    ResetXactor reset("", "scemi", sceMi);
    ShutdownXactor shutdown("", "scemi_shutdown", sceMi);

    // Service SceMi requests
    SceMiServiceThread *scemi_service_thread = new SceMiServiceThread(sceMi);

    // Reset the dut.
    reset.reset();

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

    shutdown.blocking_send_finish();
    scemi_service_thread->stop();
    scemi_service_thread->join();
    SceMi::Shutdown(sceMi);

    return 0;
}

