import Types::*;
import MemTypes::*;
import PIVTypes::*;
import GetPut::*;
import IMemory::*;
import ClientServer::*;


module mkWindowTracker(IMemory iMem, WindowTracker ifc);
  interface Put request;
    method Action put(WindowReq r);
      iMem.req.put(signExtend(r.ndx));
    endmethod
  endinterface

  interface Get response;
    method ActionValue#(Displacements) get();
      let x <- iMem.resp.get();
      let ret = Displacements{u: x, v: x};
      return ret;
    endmethod
  endinterface
endmodule
