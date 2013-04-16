
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

    Empty dispget <- mkCpuToHostXactor(dut, clk_port);
    Empty windowreq <- mkWindowReqXactor(dut, clk_port);
    Empty imstore <- mkStoreXactor(dut, clk_port);
    Empty imclear <- mkClearXactor(dut, clk_port);

    Empty shutdown <- mkShutdownXactor();
endmodule

module [SceMiModule] mkDispXactor#(PIV piv, SceMiClockPortIfc clk_port ) (Empty);

    Get#(Displacements) resp = interface Get;
        method ActionValue#(Displacements) get = piv.getDisplacements();
    endinterface;

    Empty get <- mkGetXactor(resp, clk_port);
endmodule

module [SceMiModule] mkWindowReqXactor#(PIV piv, SceMiClockPortIfc clk_port ) (Empty);

    Put#(WindowReq) req = interface Put;
        method Action put(WindowReq x) = piv.putWindowReq(x);
    endinterface;

    Empty put <- mkPutXactor(req, clk_port);
endmodule

module [SceMiModule] mkStoreXactor#(PIV piv, SceMiClockPortIfc clk_port ) (Empty);

    Put#(Data) req = interface Put;
        method Action put(Data x) = piv.storeImage(x);
    endinterface;

    Empty put <- mkPutXactor(req, clk_port);
endmodule

module [SceMiModule] mkClearXactor#(PIV piv, SceMiClockPortIfc clk_port ) (Empty);

    Put#(Bool) req = interface Put;
        method Action put(Bool x) = piv.clear();
    endinterface;

    Empty put <- mkPutXactor(req, clk_port);
endmodule
