import Types::*;
import MemTypes::*;
import IMemory::*;
import PIVTypes::*;
import GetPut::*;


(* synthesize *)
module [Module] mkPIV(PIV);
  IMemory iMem <- mkIMemory();


  rule fetchReq;
    Addr fetchaddr = 0;
    iMem.req.put(fetchaddr);
  endrule

  rule fetchResp;
    let x <- iMem.resp.get();
    $display(x);
  endrule

  interface MemInit iMemInit = iMem.init;
endmodule