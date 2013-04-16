import PIVTypes::*;
import GetPut::*;
import BRAM::*;


interface IMemory;
  interface Put#(Addr) req;
  interface Get#(Data) resp;
  interface Put#(Data) store;
  method Action clear();
  method Bool is_loading();
endinterface

(* synthesize *)
module mkIMemory(IMemory);
  Reg#(Addr) store_addr <- mkReg(0);
  Reg#(Bool) loading <- mkReg(False);
  BRAM_Configure cfg = defaultValue;
  BRAM1Port#(Addr, Data) bram <- mkBRAM1Server(cfg);

  interface Put req;
    method Action put(Addr a) if (!loading);
      bram.portA.request.put(BRAMRequest {
        write: False,
        responseOnWrite: False,
        address: truncate(a),
        datain: 0});
      $display("put request: %d", a);
    endmethod
  endinterface

  interface Get resp;
    method ActionValue#(Data) get()  if (!loading);
      let r <- bram.portA.response.get();
      $display("get response %d", r);
      return r;
    endmethod
  endinterface

  interface Put store;
    method Action put(Data x) if (loading);
      bram.portA.request.put(BRAMRequest {
        write: True,
        responseOnWrite: False,
        address: truncate(store_addr),
        datain: x});
      // $display("storing %d", x);
      store_addr <= store_addr + 1;
      if (store_addr+1 >= fromInteger(valueOf(PIXELS_PER_IMAGE) / valueOf(PIXELS_PER_LINE))) begin
        $display("done loading");
        loading <= False;
      end
    endmethod
  endinterface

  method Action clear() if (!loading);
    loading <= True;
    store_addr <= 0;
  endmethod

  method Bool is_loading();
    return loading;
  endmethod
endmodule
