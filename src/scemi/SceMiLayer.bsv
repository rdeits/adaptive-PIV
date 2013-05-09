
import ClientServer::*;
import FIFO::*;
import GetPut::*;
import DefaultValue::*;
import SceMi::*;
import Clocks::*;
import ResetXactor::*;

import PIVTypes::*;
import PIV::*;

typedef PIV DutInterface;

(* synthesize *)
module [Module] mkDutWrapper (DutInterface);
    let m <- mkPIV();
    return m;
endmodule

module [SceMiModule] mkSceMiLayer();

    SceMiClockConfiguration conf = defaultValue;

    SceMiClockPortIfc clk_port <- mkSceMiClockPort(conf);
    DutInterface dut <- buildDutWithSoftReset(mkDutWrapper, clk_port);

    Empty dispget <- mkDispXactor(dut, clk_port);
    Empty windowreq <- mkWindowReqXactor(dut, clk_port);
    Empty imstoreA <- mkStoreAXactor(dut, clk_port);
    Empty imstoreB <- mkStoreBXactor(dut, clk_port);
    Empty imclear <- mkClearDoneXactor(dut, clk_port);

    Empty shutdown <- mkShutdownXactor();
endmodule

module [SceMiModule] mkDispXactor#(PIV piv, SceMiClockPortIfc clk_port ) (Empty);

    Get#(Displacements) resp = interface Get;
        method ActionValue#(Displacements) get = piv.get_displacements();
    endinterface;

    Empty get <- mkGetXactor(resp, clk_port);
endmodule

module [SceMiModule] mkWindowReqXactor#(PIV piv, SceMiClockPortIfc clk_port ) (Empty);

    Put#(WindowReq) req = interface Put;
        method Action put(WindowReq x) = piv.put_window_req(x);
    endinterface;

    Empty put <- mkPutXactor(req, clk_port);
endmodule

module [SceMiModule] mkStoreAXactor#(PIV piv, SceMiClockPortIfc clk_port ) (Empty);
    Put#(ImagePacket) req = interface Put;
        method Action put(ImagePacket x) = piv.store_image_A(x);
    endinterface;
    Empty put <- mkPutXactor(req, clk_port);
endmodule

module [SceMiModule] mkStoreBXactor#(PIV piv, SceMiClockPortIfc clk_port ) (Empty);
    Put#(ImagePacket) req = interface Put;
        method Action put(ImagePacket x) = piv.store_image_B(x);
    endinterface;
    Empty put <- mkPutXactor(req, clk_port);
endmodule

module [SceMiModule] mkClearDoneXactor#(PIV piv, SceMiClockPortIfc clk_port ) (Empty);

    Put#(Bit#(1)) req = interface Put;
        method Action put(Bit#(1) x);
            if (x == 0) begin
                 piv.clear_image();
            end else begin
                piv.done_loading();
            end
        endmethod
    endinterface;

    Empty put <- mkPutXactor(req, clk_port);
endmodule

