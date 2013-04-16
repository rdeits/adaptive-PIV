import IMemory::*;
import PIVTypes::*;
import GetPut::*;
import WindowTracker::*;
import ClientServer::*;


(* synthesize *)
module [Module] mkPIV(PIV);
  IMemory iMem <- mkIMemory();
  WindowTracker tracker <- mkWindowTracker(iMem);

  method ActionValue#(Displacements) getDisplacements if (!iMem.is_loading);
    let x <- tracker.response.get();
    return x;
  endmethod

  method Action putWindowReq(WindowReq req) if (!iMem.is_loading);
    tracker.request.put(req);
  endmethod

  method Action storeImage(Data x);
    iMem.store.put(x);
  endmethod

  method Action clearImage();
    iMem.clear();
  endmethod
endmodule