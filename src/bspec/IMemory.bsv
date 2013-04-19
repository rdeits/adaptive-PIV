import PIVTypes::*;
import GetPut::*;
import BRAM::*;
import FIFO::*;
import Vector::*;


interface IMemory;
  interface Put#(MemReq) req;
  // interface Get#(Data) resp;
  interface Put#(Data) store;
  method Action clear();
  method Action done_loading();
  method Bool is_loading();
  method ActionValue#(Data) get_queued_data_A(TrackerID tracker_id);
endinterface

(* synthesize *)
module mkIMemory(IMemory);
  Reg#(Addr) store_addr <- mkReg(0);
  Reg#(Bool) loading <- mkReg(False);
  BRAM_Configure cfg = defaultValue;
  FIFO#(TrackerID) req_info_q <- mkFIFO();
  BRAM1Port#(Addr, Data) bram <- mkBRAM1Server(cfg);
  Vector#(NumTrackers, FIFO#(Data)) memq_A <- replicateM(mkFIFO());
  Vector#(NumTrackers, FIFO#(Data)) memq_B <- replicateM(mkFIFO());

  rule get_mem_data;
    let r <- bram.portA.response.get();
    $display("get response %d", r);
    let q = req_info_q.first();
    req_info_q.deq();
    memq_A[q].enq(r);
  endrule

  interface Put req;
    method Action put(MemReq a) if (!loading);
      bram.portA.request.put(BRAMRequest {
        write: False,
        responseOnWrite: False,
        address: truncate(a.addr),
        datain: 0});
      $display("put request: %d", a);
      req_info_q.enq(a.tracker_id);
    endmethod
  endinterface

  method ActionValue#(Data) get_queued_data_A(TrackerID tracker_id);
    memq_A[tracker_id].deq();
    let r = memq_A[tracker_id].first();
    return r;
  endmethod


  // interface Get resp;
  //   method ActionValue#(Data) get()  if (!loading);
  //     let r <- bram.portA.response.get();
  //     $display("get response %d", r);
  //     return r;
  //   endmethod
  // endinterface

  interface Put store;
    method Action put(Data x) if (loading);
      bram.portA.request.put(BRAMRequest {
        write: True,
        responseOnWrite: False,
        address: truncate(store_addr),
        datain: x});
      // $display("storing %d", x);
      store_addr <= store_addr + 1;
    endmethod
  endinterface

  method Action done_loading() if (loading);
    loading <= False;
    $display("done loading");
  endmethod

  method Action clear() if (!loading);
    loading <= True;
    store_addr <= 0;
  endmethod

  method Bool is_loading();
    return loading;
  endmethod
endmodule
