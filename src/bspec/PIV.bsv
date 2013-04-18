import IMemory::*;
import PIVTypes::*;
import GetPut::*;
import WindowTracker::*;
import ClientServer::*;
import FIFOF::*;


(* synthesize *)
module [Module] mkPIV(PIV);
  FIFOF#(ImagePacket) packet_buffer <- mkFIFOF();
  // Reg#(UInt#(TAdd#(TLog#(ImagePacketSize), 1))) packet_offset <- mkReg(0);
  IMemory iMem <- mkIMemory();
  WindowTracker tracker <- mkWindowTracker(iMem);

  // rule packet_to_bram;
  //   // let finish = valueOf(ImagePacketSize);
  //   // let packet = packet_buffer.first();
  //   // Data new_data = packet[packet_offset]
  //   // Data new_data = truncate(packet >> (fromInteger(finish) - packet_offset));
  //   let new_data = packet_buffer.first();
  //   iMem.store.put(new_data);
  //   packet_buffer.deq();
  //   $display("writing to BRAM: %x", new_data);
  //   // if (packet_offset >= fromInteger(valueOf(TSub#(ImagePacketSize, DataSz)))) begin
  //   //   packet_offset <= 0;
  //   //   packet_buffer.deq();
  //   // end
  //   // else begin
  //   //   packet_offset <= packet_offset + fromInteger(valueOf(DataSz));
  //   // end
  // endrule

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