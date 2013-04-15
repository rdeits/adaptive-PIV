import Types::*;
import MemTypes::*;
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
  interface MemInitIfc init;
endinterface

(* synthesize *)
module mkIMemory(IMemory);
  BRAM_Configure cfg = defaultValue;
  BRAM1Port#(Bit#(16), Data) bram <- mkBRAM1Server(cfg);
  MemInitIfc memInit <- mkMemInitBRAM(bram);

  interface Put req;
    method Action put(Addr a) if (memInit.done());
      bram.portA.request.put(BRAMRequest {
        write: False,
        responseOnWrite: False,
        address: truncate(a >> 2),
        datain: 0});
    endmethod
  endinterface

  interface Get resp;
    method ActionValue#(MemResp) get()  if (memInit.done());
      let r <- bram.portA.response.get();
      return r;
    endmethod
  endinterface

  interface MemInitIfc init = memInit;
endmodule
