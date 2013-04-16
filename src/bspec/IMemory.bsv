import Types::*;
import MemTypes::*;
import PIVTypes::*;
// import RegFile::*;
import MemInit::*;
import GetPut::*;
import BRAM::*;

// interface IMemory;
//     method MemResp req(Addr a);
//     interface MemInitIfc init;
// endinterface

// (* synthesize *)
// module mkIMemory(IMemory);
//     RegFile#(Bit#(16), Data) mem <- mkRegFileFull();
//     MemInitIfc memInit <- mkMemInitRegFile(mem);

//     method MemResp req(Addr a) if (memInit.done());
//         return mem.sub(truncate(a>>2));
//     endmethod

//     interface MemInitIfc init = memInit;
// endmodule


interface IMemory;
  interface Put#(Addr) req;
  interface Get#(MemResp) resp;
  // interface MemInitIfc init;
  interface Put#(Data) store;
  method Action clear();
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
        address: truncate(a >> 2),
        datain: 0});
    endmethod
  endinterface

  interface Get resp;
    method ActionValue#(MemResp) get()  if (!loading);
      let r <- bram.portA.response.get();
      return r;
    endmethod
  endinterface

  interface Put store;
    method Action put(Data x);
      bram.portA.request.put(BRAMRequest {
        write: True,
        responseOnWrite: False,
        address: truncate(store_addr),
        datain: x});
      $display("storing %d at %d", x, store_addr);
      store_addr <= store_addr + 1;
      if (store_addr >= fromInteger(valueOf(PIXELS_PER_IMAGE))) begin
        loading <= False;
      end
    endmethod
  endinterface

  method Action clear() if (!loading);
    loading <= True;
    store_addr <= 0;
  endmethod
endmodule
