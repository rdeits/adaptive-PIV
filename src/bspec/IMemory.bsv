import Types::*;
import MemTypes::*;
import PIVTypes::*;
// import RegFile::*;
import MemInit::*;
import GetPut::*;
import BRAM::*;

// interface IMemory;
//     method Data req(Addr a);
//     interface MemInitIfc init;
// endinterface

// (* synthesize *)
// module mkIMemory(IMemory);
//     RegFile#(Bit#(16), Data) mem <- mkRegFileFull();
//     MemInitIfc memInit <- mkMemInitRegFile(mem);

//     method Data req(Addr a) if (memInit.done());
//         return mem.sub(truncate(a>>2));
//     endmethod

//     interface MemInitIfc init = memInit;
// endmodule


interface IMemory;
  interface Put#(Addr) req;
  interface Get#(Data) resp;
  // interface MemInitIfc init;
  interface Put#(Data) store;
  method Action clear();
  method Bool is_loading();
endinterface

(* synthesize *)
module mkIMemory(IMemory);
  Reg#(Addr) store_addr <- mkReg(0);
  Reg#(Bool) loading <- mkReg(False);
  BRAM_Configure cfg = defaultValue;
  BRAM1Port#(Bit#(16), Data) bram <- mkBRAM1Server(cfg);

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
      $display("storing %d", x);
      store_addr <= store_addr + 1;
      if (store_addr+1 >= fromInteger(valueOf(PIXELS_PER_IMAGE))) begin
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
