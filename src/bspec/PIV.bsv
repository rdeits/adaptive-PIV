import IMemory::*;
import PIVTypes::*;
import GetPut::*;
import WindowTracker::*;
import ClientServer::*;
import FIFO::*;
import Vector::*;

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
  IMemory iMem <- mkIMemory();
  Vector#(NumTrackers, WindowTracker) trackers;
  for (Integer i = 0; i < valueOf(NumTrackers); i = i + 1) begin
    trackers[i] <- mkWindowTracker(iMem, fromInteger(i));
  end
  Reg#(UInt#(TLog#(NumTrackers))) next_tracker_in <- mkReg(0);
  Reg#(UInt#(TLog#(NumTrackers))) next_tracker_out <- mkReg(0);
  FIFO#(ImagePacket) packet_buffer_A <- mkFIFO();
  FIFO#(ImagePacket) packet_buffer_B <- mkFIFO();
  Reg#(UInt#(TLog#(ImagePacketSize))) packet_offset_A <- mkReg(0);
  Reg#(UInt#(TLog#(ImagePacketSize))) packet_offset_B <- mkReg(0);

  rule load_mem_A;
    let p = packet_buffer_A.first();
    iMem.store_A.put(p[packet_offset_A]);
    if (packet_offset_A == fromInteger(valueOf(ImagePacketSize) - 1)) begin
      packet_buffer_A.deq();
    end
    packet_offset_A <= packet_offset_A + 1;
  endrule

  rule load_mem_B;
    let p = packet_buffer_B.first();
    iMem.store_B.put(p[packet_offset_B]);
    if (packet_offset_B == fromInteger(valueOf(ImagePacketSize) - 1)) begin
      packet_buffer_B.deq();
    end
    packet_offset_B <= packet_offset_B + 1;
  endrule

  function Bool is_done_loading();
    // let x = !iMem.is_loading && !packet_buffer.notEmpty;
    let x = !iMem.is_loading;
    return x;
  endfunction

  method ActionValue#(Displacements) get_displacements if (is_done_loading());
    let x <- trackers[next_tracker_out].response.get();
    next_tracker_out <= next_tracker_out + 1;
    return x;
  endmethod

  method Action put_window_req(WindowReq req) if (is_done_loading());
    trackers[next_tracker_in].request.put(req);
    next_tracker_in <= next_tracker_in + 1;
  endmethod

  method Action store_image_A(ImagePacket p);
    packet_buffer_A.enq(p);
    // iMem.store_A.put(p);
  endmethod

  method Action store_image_B(ImagePacket p);
    packet_buffer_B.enq(p);
    // iMem.store_B.put(p);
  endmethod

  method Action clear_image();
    iMem.clear();
  endmethod

  method Action done_loading() if (iMem.is_loading);
    iMem.done_loading();
  endmethod

endmodule