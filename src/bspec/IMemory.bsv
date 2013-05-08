import PIVTypes::*;
import GetPut::*;
import BRAM::*;
import FIFO::*;
import Vector::*;


interface IMemory;
  interface Put#(MemReq) req_A;
  interface Put#(MemReq) req_B;
  interface Get#(Pixel) resp_A;
  interface Get#(Pixel) resp_B;
  interface Put#(Pixel) store_A;
  interface Put#(Pixel) store_B;
  method Action clear();
  method Action done_loading();
  method Bool is_loading();
  // method TrackerID get_current_tracker();
  // method Action next_tracker();
  // method Action get_lock();
  // method Action release_lock();
  // method Pixel queue_first_A(TrackerID tracker_id);
  // method Action queue_deq_A(TrackerID tracker_id);
  // method Pixel queue_first_B(TrackerID tracker_id);
  // method Action queue_deq_B(TrackerID tracker_id);
  // method ActionValue#(Pixel) get_queued_data_A(TrackerID tracker_id);
endinterface

(* synthesize *)
module mkIMemory(IMemory);
  Reg#(PixelNdx) store_addr_A <- mkReg(0);
  Reg#(PixelNdx) store_addr_B <- mkReg(0);
  Reg#(Bool) loading <- mkReg(False);
  BRAM_Configure cfg = defaultValue;
  cfg.memorySize = valueOf(PixelsPerImage);
  // Reg#(TrackerID) current_tracker <- mkReg(0);
  // FIFO#(TrackerID) req_info_q_A <- mkFIFO();
  // FIFO#(TrackerID) req_info_q_B <- mkFIFO();
  BRAM1Port#(PixelNdx, Pixel) bram_A <- mkBRAM1Server(cfg);
  BRAM1Port#(PixelNdx, Pixel) bram_B <- mkBRAM1Server(cfg);
  // Vector#(NumTrackers, FIFO#(Pixel)) memq_A <- replicateM(mkFIFO());
  // Vector#(NumTrackers, FIFO#(Pixel)) memq_B <- replicateM(mkFIFO());
  // Reg#(Bool) in_use <- mkReg(False);

  // rule get_mem_data_A;
  //   let r <- bram_A.portA.response.get();
  //   let q = req_info_q_A.first();
  //   req_info_q_A.deq();
  //   $display("enq pixel with id: %d", q);
  //   memq_A[q].enq(r);
  // endrule

  // rule get_mem_data_B;
  //   let r <- bram_B.portA.response.get();
  //   let q = req_info_q_B.first();
  //   req_info_q_B.deq();
  //   memq_B[q].enq(r);
  // endrule

  // method TrackerID get_current_tracker();
  //   let x = current_tracker;
  //   return x;
  // endmethod

  // method Action next_tracker();
  //   if (current_tracker < fromInteger(valueOf(NumTrackers) - 1)) begin
  //     current_tracker <= current_tracker + 1;
  //   end
  //   else begin
  //     current_tracker <= 0;
  //   end
  // endmethod

  interface Put req_A;
    method Action put(MemReq a) if (!loading);
      bram_A.portA.request.put(BRAMRequest {
        write: False,
        responseOnWrite: False,
        address: truncate(a.addr),
        datain: ?});
      // req_info_q_A.enq(a.tracker_id);
    endmethod
  endinterface

  interface Put req_B;
    method Action put(MemReq a) if (!loading);
      bram_B.portA.request.put(BRAMRequest {
        write: False,
        responseOnWrite: False,
        address: a.addr,
        datain: ?});
      // req_info_q_B.enq(a.tracker_id);
    endmethod
  endinterface

  interface Get resp_A;
    method ActionValue#(Pixel) get() if (!loading);
      let x <- bram_A.portA.response.get();
      return x;
    endmethod
  endinterface

  interface Get resp_B;
    method ActionValue#(Pixel) get() if (!loading);
      let x <- bram_B.portA.response.get();
      return x;
    endmethod
  endinterface

  interface Put store_A;
    method Action put(Pixel x) if (loading);
      bram_A.portA.request.put(BRAMRequest {
        write: True,
        responseOnWrite: False,
        address: store_addr_A,
        datain: x});
      store_addr_A <= store_addr_A + 1;
    endmethod
  endinterface

  interface Put store_B;
    method Action put(Pixel x) if (loading);
      bram_B.portA.request.put(BRAMRequest {
        write: True,
        responseOnWrite: False,
        address: store_addr_B,
        datain: x});
      store_addr_B <= store_addr_B + 1;
    endmethod
  endinterface



  method Action done_loading() if (loading);
    loading <= False;
    $display("done loading");
  endmethod

  method Action clear() if (!loading);
    loading <= True;
    store_addr_A <= 0;
    store_addr_B <= 0;
  endmethod

  method Bool is_loading();
    return loading;
  endmethod
endmodule
