import PIVTypes::*;
import GetPut::*;
import BRAM::*;
import FIFO::*;
import Vector::*;


interface IMemory;
  interface Put#(MemReq) req_A;
  interface Put#(MemReq) req_B;
  // interface Get#(Pixel) resp;
  interface Put#(Pixel) store_A;
  interface Put#(Pixel) store_B;
  method Action clear();
  method Action done_loading();
  method Bool is_loading();
  method Pixel queue_first_A(TrackerID tracker_id);
  method Action queue_deq_A(TrackerID tracker_id);
  method Pixel queue_first_B(TrackerID tracker_id);
  method Action queue_deq_B(TrackerID tracker_id);
  // method ActionValue#(Pixel) get_queued_data_A(TrackerID tracker_id);
endinterface

(* synthesize *)
module mkIMemory(IMemory);
  Reg#(PixelNdx) store_addr_A <- mkReg(0);
  Reg#(PixelNdx) store_addr_B <- mkReg(0);
  Reg#(Bool) loading <- mkReg(False);
  BRAM_Configure cfg = defaultValue;
  cfg.memorySize = valueOf(PixelsPerImage);
  FIFO#(TrackerID) req_info_q_A <- mkFIFO();
  FIFO#(TrackerID) req_info_q_B <- mkFIFO();
  BRAM1Port#(PixelNdx, Pixel) bram_A <- mkBRAM1Server(cfg);
  BRAM1Port#(PixelNdx, Pixel) bram_B <- mkBRAM1Server(cfg);
  Vector#(NumTrackers, FIFO#(Pixel)) memq_A <- replicateM(mkFIFO());
  Vector#(NumTrackers, FIFO#(Pixel)) memq_B <- replicateM(mkFIFO());

  rule get_mem_data_A;
    let r <- bram_A.portA.response.get();
    let q = req_info_q_A.first();
    req_info_q_A.deq();
    memq_A[q].enq(r);
  endrule

  rule get_mem_data_B;
    let r <- bram_B.portA.response.get();
    let q = req_info_q_B.first();
    req_info_q_B.deq();
    memq_B[q].enq(r);
  endrule

  interface Put req_A;
    method Action put(MemReq a) if (!loading);
      bram_A.portA.request.put(BRAMRequest {
        write: False,
        responseOnWrite: False,
        address: truncate(a.addr),
        datain: ?});
      req_info_q_A.enq(a.tracker_id);
    endmethod
  endinterface

  interface Put req_B;
    method Action put(MemReq a) if (!loading);
      bram_B.portA.request.put(BRAMRequest {
        write: False,
        responseOnWrite: False,
        address: a.addr,
        datain: ?});
      req_info_q_B.enq(a.tracker_id);
    endmethod
  endinterface

  method Pixel queue_first_A(TrackerID tracker_id);
    let r = memq_A[tracker_id].first();
    return r;
  endmethod

  method Pixel queue_first_B(TrackerID tracker_id);
    let r = memq_B[tracker_id].first();
    return r;
  endmethod

  method Action queue_deq_A(TrackerID tracker_id);
    memq_A[tracker_id].deq();
  endmethod

  method Action queue_deq_B(TrackerID tracker_id);
    memq_B[tracker_id].deq();
  endmethod

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
