import PIVTypes::*;
import GetPut::*;
import IMemory::*;
import ClientServer::*;
import Vector::*;
import FIFO::*;
import WindowManager::*;
// import Accumulator::*;
// import Tracker::*;


module mkWindowTracker(IMemory iMem, TrackerID tracker_id, WindowTracker ifc);
  FIFO#(Vector#(2, Pixel)) m2a <- mkFIFO();
  FIFO#(CrossCorrEl) a2t <- mkFIFO();
  // FIFO#(TMul#(Pixel, Pixel)) a2t <- mkFIFO();
  WindowManager manager <- mkWindowManager(iMem, tracker_id, m2a);
  Empty accum <- mkAccumulator(m2a, a2t);
  Tracker tracker <- mkTracker();

  interface Put request;
    method Action put(WindowReq r);
      manager.req.put(r);
      // iMem.req.put(truncate(r.ndx));
    endmethod
  endinterface

  interface Get response;
    method ActionValue#(Displacements) get();
      // let x <- iMem.resp.get();
      // let ret = Displacements{u: x, v: x};
      let x <- m2a.first();
      m2a.deq();
      $display("pixel pair: %d, %d", x[0], x[1]);
      return Displacements{u: 0, v: 0};
    endmethod
  endinterface
endmodule
