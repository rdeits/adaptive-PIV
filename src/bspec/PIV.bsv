import IMemory::*;
import PIVTypes::*;
import GetPut::*;
import WindowTracker::*;
import ClientServer::*;
import FIFOF::*;

interface PIV;
  method ActionValue#(Displacements) get_displacements;
  method Action put_window_req(WindowReq req);
  method Action store_image_A(ImagePacket x);
  method Action store_image_B(ImagePacket x);
  method Action clear_image();
  method Action done_loading();
endinterface

(* synthesize *)
module [Module] mkPIV(PIV);
  // FIFOF#(ImagePacket) packet_buffer <- mkFIFOF();
  IMemory iMem <- mkIMemory();
  WindowTracker tracker <- mkWindowTracker(iMem, 0);

  function Bool is_done_loading();
    // let x = !iMem.is_loading && !packet_buffer.notEmpty;
    let x = !iMem.is_loading;
    return x;
  endfunction

  method ActionValue#(Displacements) get_displacements if (is_done_loading());
    let x <- tracker.response.get();
    return x;
  endmethod

  method Action put_window_req(WindowReq req) if (is_done_loading());
    tracker.request.put(req);
  endmethod

  method Action store_image_A(ImagePacket p);
    iMem.store_A.put(unpack(pack(p)));
  endmethod

  method Action store_image_B(ImagePacket p);
    iMem.store_B.put(unpack(pack(p)));
  endmethod

  method Action clear_image();
    iMem.clear();
  endmethod

  method Action done_loading() if (iMem.is_loading);
    iMem.done_loading();
  endmethod

endmodule