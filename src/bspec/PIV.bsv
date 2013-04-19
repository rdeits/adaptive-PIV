import IMemory::*;
import PIVTypes::*;
import GetPut::*;
import WindowTracker::*;
import ClientServer::*;
import FIFOF::*;


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

  method Action store_image(ImagePacket p);
    // packet_buffer.enq(p);
    iMem.store.put(unpack(pack(p)));
    $display("writing to BRAM: %x", p);
    // iMem.store.put(x);
  endmethod

  method Action clear_image();
    iMem.clear();
  endmethod

  method Action done_loading() if (iMem.is_loading);
    iMem.done_loading();
  endmethod

endmodule