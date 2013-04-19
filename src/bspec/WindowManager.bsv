import PIVTypes::*;
import GetPut::*;
import FIFO::*;
import IMemory::*;
import Vector::*;

interface WindowManager;
  interface Put#(WindowReq) req;
  interface Get#(Displacements) resp;
  method Vector#(2, Pixel) get_next_pixels;
endinterface

module mkWindowManager(IMemory iMem, TrackerID tracker_id, FIFO#(Vector#(2, Pixel)) m2a, WindowManager ifc);
  Reg#(WindowSize) win_size_A <- mkRegU();
  Reg#(WindowSize) win_size_B <- mkRegU();
  Reg#(WindowPixelNdx) pixel_ndx_A <- mkRegU();
  Reg#(WindowPixelNdx) pixel_ndx_B <- mkRegU();
  Vector#(TDiv#(DataSz, PixelSz), Reg#(Pixel)) pixel_buffer_A <- replicateM(mkRegU());
  Vector#(TDiv#(DataSz, PixelSz), Reg#(Pixel)) pixel_buffer_B <- replicateM(mkRegU());
  FIFO#(Data) memq_A <- mkFIFO();
  FIFO#(Data) memq_B <- mkFIFO();

  interface Put req;
    method Action put(WindowReq r);
      let ndx = r.ndx;
      Addr addr = truncate(ndx >> 2);
      pixel_ndx_A <= 0;
      pixel_ndx_B <= 0;
      iMem.req.put(MemReq{addr: addr, tracker_id: tracker_id});
    endmethod
  endinterface

  interface Get resp;
    method ActionValue#(Displacements) get();
      let r <- iMem.get_queued_data_A(tracker_id);
      return Displacements{u: truncate(r), v: truncate(r)};
    endmethod
  endinterface
endmodule



