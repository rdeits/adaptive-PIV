import PIVTypes::*;
import GetPut::*;
import IMemory::*;
import ClientServer::*;
import Vector::*;
import FIFO::*;
import WindowManager::*;
import Accumulator::*;
import DisplacementTracker::*;

interface WindowTracker;
  interface Get#(Displacements) resp;
  interface Put#(Pixel) pxA;
  interface Put#(Pixel) pxB;
  method Bool is_done_storing();
  method Action start();
endinterface

module mkWindowTracker(TrackerID tracker_id, WindowTracker ifc);
  // Reg#(PixelNdx) current_ndx <- mkRegU();
  FIFO#(Vector#(2, Pixel)) m2a <- mkFIFO();
  FIFO#(CrossCorrEl) a2t <- mkFIFO();
  // FIFO#(TMul#(Pixel, Pixel)) a2t <- mkFIFO();
  WindowManager manager <- mkWindowManager(tracker_id, m2a);
  Empty accum <- mkAccumulator(m2a, a2t);
  DisplacementTracker tracker <- mkDisplacementTracker(a2t);

  method Bool is_done_storing = manager.is_done_storing;
  method Action start = manager.start;
  interface Put pxA = manager.pxA;
  interface Put pxB = manager.pxB;
  // interface Put request;
  //   method Action put(WindowReq r);
  //     manager.req.put(r);
  //     req_ndx_f.enq(r.ndx);
  //     $display("got request for index: %d", r.ndx);
  //     // iMem.req.put(truncate(r.ndx));
  //   endmethod
  // endinterface

  interface Get resp;
    method ActionValue#(Displacements) get();
      // let x <- iMem.resp.get();
      // let ret = Displacements{u: x, v: x};
      let x <- tracker.resp.get();
      // x.ndx = req_ndx_f.first();
      // req_ndx_f.deq();
      // x.ndx = current_ndx;
      return x;
    endmethod
  endinterface
endmodule
