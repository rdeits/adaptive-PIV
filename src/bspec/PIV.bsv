import Types::*;
import MemTypes::*;
import IMemory::*;
import PIVTypes::*;
import GetPut::*;


(* synthesize *)
module [Module] mkPIV(PIV);
  IMemory iMem <- mkIMemory();
  Reg#(MemResp) x <- mkRegU();
  Reg#(Bool) has_data <- mkReg(False);


  rule fetchReq;
    Addr fetchaddr = 0;
    iMem.req.put(fetchaddr);
  endrule

  rule fetchResp;
    let r <- iMem.resp.get();
    x <= r;
    has_data <= True;
    // $display(x);
  endrule

  interface MemInit iMemInit = iMem.init;

  method ActionValue#(Data) cpuToHost if (has_data);
    return x;
  endmethod
endmodule