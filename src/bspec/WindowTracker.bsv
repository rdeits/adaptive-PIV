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

  interface Get resp;
    method ActionValue#(Displacements) get();
      let x <- tracker.resp.get();
      return x;
    endmethod
  endinterface
endmodule
