
import ClientServer::*;
import FIFO::*;
import GetPut::*;
import DefaultValue::*;
import SceMi::*;
import Clocks::*;
import ResetXactor::*;

import Types::*;
import MemTypes::*;
import PIVTypes::*;
import PIV::*;

typedef PIV DutInterface;
typedef Data ToHost;
typedef Addr FromHost;

(* synthesize *)
module [Module] mkDutWrapper (DutInterface);
    let m <- mkPIV();
    return m;
endmodule

module [SceMiModule] mkSceMiLayer();

    SceMiClockConfiguration conf = defaultValue;

    SceMiClockPortIfc clk_port <- mkSceMiClockPort(conf);
    DutInterface dut <- buildDutWithSoftReset(mkDutWrapper, clk_port);

    Empty imem <- mkPutXactor(dut.iMemInit.request, clk_port);
    Empty tohost <- mkCpuToHostXactor(dut, clk_port);
    Empty fromhost <- mkHostToCpuXactor(dut, clk_port);

    Empty shutdown <- mkShutdownXactor();
endmodule

module [SceMiModule] mkCpuToHostXactor#(PIV piv, SceMiClockPortIfc clk_port ) (Empty);

    Get#(ToHost) resp = interface Get;
        method ActionValue#(ToHost) get = piv.cpuToHost();
    endinterface;

    Empty get <- mkGetXactor(resp, clk_port);
endmodule

module [SceMiModule] mkHostToCpuXactor#(PIV piv, SceMiClockPortIfc clk_port ) (Empty);

    Put#(FromHost) req = interface Put;
        method Action put(FromHost x) = piv.hostToCpu(x);
    endinterface;

    Empty put <- mkPutXactor(req, clk_port);
endmodule

