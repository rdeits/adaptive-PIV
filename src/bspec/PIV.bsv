import IMemory::*;
import PIVTypes::*;
import GetPut::*;
import WindowTracker::*;
import ClientServer::*;
import FIFO::*;
import Vector::*;
import AddrCounter::*;

interface PIV;
  method ActionValue#(Displacements) get_displacements;
  method Action put_window_req(WindowReq req);
  method Action store_image_A(ImagePacket x);
  method Action store_image_B(ImagePacket x);
  method Action clear_image();
  method Action done_loading();
endinterface

typedef enum {WaitingForReq, Downloading} PIVState deriving (Bits, Eq);

(* synthesize *)
module [Module] mkPIV(PIV);
  IMemory iMem <- mkIMemory();
  Vector#(NumTrackers, WindowTracker) trackers;
  for (Integer i = 0; i < valueOf(NumTrackers); i = i + 1) begin
    trackers[i] <- mkWindowTracker(fromInteger(i));
  end
  Reg#(TrackerID) next_tracker_in <- mkReg(0);
  Reg#(TrackerID) current_tracker_in <- mkReg(0);
  Reg#(TrackerID) next_tracker_out <- mkReg(0);
  FIFO#(ImagePacket) packet_buffer_A <- mkFIFO();
  FIFO#(ImagePacket) packet_buffer_B <- mkFIFO();
  FIFO#(WindowReq) reqFIFO <- mkFIFO();
  FIFO#(PixelNdx) req_ndxFIFO <- mkFIFO();
  Reg#(UInt#(TLog#(ImagePacketSize))) packet_offset_A <- mkReg(0);
  Reg#(UInt#(TLog#(ImagePacketSize))) packet_offset_B <- mkReg(0);

  Bit#(WindowSizeA) winsizeA = ?;
  Bit#(WindowSizeB) winsizeB = ?;
  Bit#(ImageWidth) imwidth = ?;
  AddrCounter counter_A <- mkCounter(winsizeA, imwidth);
  AddrCounter counter_B <- mkCounter(winsizeB, imwidth);
  Reg#(PIVState) state <- mkReg(WaitingForReq);

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

  rule start_next_tracker if (!iMem.is_loading && state == WaitingForReq);
    state <= Downloading;
    let r = reqFIFO.first();
    reqFIFO.deq();
    let ndx = r.ndx;
    $display("PIV got request: %d", ndx);
    $display("tracker in use: %d", next_tracker_in);
    counter_A.reset(ndx);
    let pos_B = ndx + fromInteger(((valueOf(WindowSizeA) - valueOf(WindowSizeB)) / 2) * (valueOf(ImageWidth) +1));
    counter_B.reset(pos_B);
    trackers[next_tracker_in].start();
    current_tracker_in <= next_tracker_in;
    next_tracker_in <= next_tracker_in + 1;
  endrule

  rule request_download_A if (!iMem.is_loading && state == Downloading && !counter_A.done());
    let addr <- counter_A.get_addr();
    iMem.req_A.put(MemReq{addr: addr, tracker_id: current_tracker_in});
  endrule

  rule request_download_B if (!iMem.is_loading && state == Downloading && !counter_B.done());
    let addr <- counter_B.get_addr();
    iMem.req_B.put(MemReq{addr: addr, tracker_id: current_tracker_in});
  endrule

  rule send_download_A if (!iMem.is_loading && state == Downloading);
    Pixel new_pixel <- iMem.resp_A.get();
    trackers[current_tracker_in].pxA.put(new_pixel);
  endrule

  rule send_download_B if (!iMem.is_loading && state == Downloading);
    Pixel new_pixel <- iMem.resp_B.get();
    trackers[current_tracker_in].pxB.put(new_pixel);
  endrule

  rule finish_downloading if (!iMem.is_loading && trackers[current_tracker_in].is_done_storing() && state == Downloading);
    state <= WaitingForReq;
  endrule

  method ActionValue#(Displacements) get_displacements if (!iMem.is_loading);
    let x <- trackers[next_tracker_out].resp.get();
    x.ndx = req_ndxFIFO.first();
    req_ndxFIFO.deq();
    next_tracker_out <= next_tracker_out + 1;
    return x;
  endmethod

  method Action put_window_req(WindowReq req) if (!iMem.is_loading);
    reqFIFO.enq(req);
    req_ndxFIFO.enq(req.ndx);
    // trackers[next_tracker_in].request.put(req);
    // next_tracker_in <= next_tracker_in + 1;
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