import PIVTypes::*;
import GetPut::*;
import FIFO::*;
import FIFOF::*;
import IMemory::*;
import Vector::*;
import BRAM::*;
import AddrCounter::*;


interface WindowManager;
  interface Put#(WindowReq) req;
  interface Get#(Displacements) resp;
  method Vector#(2, Pixel) get_next_pixels;
endinterface

module mkWindowManager(IMemory iMem, TrackerID tracker_id, FIFO#(Vector#(2, Pixel)) m2a, WindowManager ifc);
  AddrCounter counter_A <- mkCounter(WindowSizeA, ImageWidth);
  AddrCounter counter_B <- mkCounter(WindowSizeB, ImageWidth);
  AddrCounter sub_counter_A <- mkCounter(WindowSizeB, WindowSizeA);
  AddrCounter sub_counter_B <- mkCounter(WindowSizeB, WindowSizeB);
  AddrCounter sub_frame_pos_counter <- mkCounter(valueOf(WindowSizeA) - valueOf(WindowSizeB) + 1, WindowSizeA);
  Reg#(TLog#(TMul#(CrossCorrWidth, CrossCorrWidth))) sub_frames_requested <- mkReg(0);
  Reg#(WindowPixelAddrA) bram_write_addr_A <- mkReg(0);
  Reg#(WindowPixelAddrB) bram_write_addr_B <- mkReg(0);

  Reg#(Bool) done_requesting_output <- mkReg(False);
  Reg#(Bit#(TLog#(TSub#(WindowSizeA, WindowSizeB)))) sub_frame_row <- mkReg(0);
  Reg#(Bit#(TLog#(TSub#(WindowSizeA, WindowSizeB)))) sub_frame_col <- mkReg(0);

  Reg#(Bool) done_storing_A <- mkReg(False);
  Reg#(Bool) done_storing_B <- mkReg(False);
  Reg#(Addr) start_addr <- mkRegU();
  Reg#(Bit#(TLog#(DataSz))) queue_offset_A <- mkReg(0);
  Reg#(Bit#(TLog#(DataSz))) queue_offset_B <- mkReg(0);


  BRAM_Configure cfg_A = defaultValue;
  cfg_A.memorySize = valueOf(PixelsPerWindowA);
  BRAM1Port#(WindowPixelAddrA, Pixel) bram_A <- mkBRAM1Server(cfg_A);

  BRAM_Configure cfg_B = defaultValue;
  cfg_B.memorySize = valueOf(PixelsPerWindowB);
  BRAM1Port#(WindowPixelAddrA, Pixel) bram_B <- mkBRAM1Server(cfg_B);

  rule request_download_A if (!counter_A.done());
    let addr <- counter_A.get_addr() >> fromInteger(valueOf(TLog#(PixelsPerData)));
    iMem.req_A.put(MemReq{addr: addr, tracker_id: tracker_id});
  endrule

  rule request_download_B if (!counter_B.done());
    let addr <- counter_B.get_addr() >> fromInteger(valueOf(TLog#(PixelsPerData)));
    iMem.req_B.put(MemReq{addr: addr, tracker_id: tracker_id});
  endrule

  rule store_download_A if (!done_storing_A);
    Data new_data = iMem.queue_first_A(tracker_id);
    bram_A.portA.request.put(BRAMRequest {
      write: True,
      responseOnWrite: False,
      address: bram_write_addr_A,
      datain: truncate(new_data >> queue_offset)});
    if (bram_write_addr_A >= fromInteger(valueOf(PixelsPerWindowA) - 1))
      done_storing_A <= True;
    else
      bram_write_addr_A <= bram_write_addr_A + 1;
    if (queue_offset_A >= fromInteger(valueOf(DataSz) - valueOf(PixelSz))) begin
      iMem.queue_deq_A(tracker_id);
      queue_offset_A <= 0;
    end
    else begin
      queue_offset_A <= queue_offset_A + fromInteger(valueOf(PixelSz));
    end
  endrule

  rule store_download_B if (!done_storing_B);
    Data new_data = iMem.queue_first_B(tracker_id);
    bram_B.portA.request.put(BRAMRequest {
      write: True,
      responseOnWrite: False,
      address: bram_write_addr_B,
      datain: truncate(new_data >> queue_offset)});
    if (bram_write_addr_B >= fromInteger(valueOf(PixelsPerWindowB) - 1))
      done_storing_B <= True;
    else
      bram_write_addr_B <= bram_write_addr_B + 1;
    if (queue_offset_B >= fromInteger(valueOf(DataSz) - valueOf(PixelSz))) begin
      iMem.queue_deq_B(tracker_id);
      queue_offset_B <= 0;
    end
    else begin
      queue_offset_B <= queue_offset_B + fromInteger(valueOf(PixelSz));
    end
  endrule

  rule start_next_frame if (sub_counter_B.done() && !done_requesting_output);
    let addr <- sub_frame_pos_counter.get_addr();
    sub_counter_A.reset(addr);
    sub_counter_B.reset(addr);
    if (sub_frames_requested >= fromInteger(valueOf(TMul#(CrossCorrWidth, CrossCorrWidth)) - 1)) begin
      done_requesting_output <= True;
    end
    else begin
      sub_frames_requested <= sub_frames_requested + 1;
    end
  endrule


  rule request_output if (done_storing_A && done_storing_B && !sub_counter_B.done() && !done_requesting_output);
    let addr_A <- sub_counter_A.get_addr();
    bram_A.portA.request.put(BRAMRequest {
      write: False,
      responseOnWrite: False,
      address: truncate(addr_A),
      datain: 0});
    let addr_B <- sub_counter_B.get_addr();
    bram_B.portA.request.put(BRAMRequest {
      write: False,
      responseOnWrite: False,
      address: truncate(addr_B),
      datain: 0});
  endrule

  rule output_data;
    Vector#(2, Pixel) out;
    let x0 <- bram_A.response.get();
    let x1 <- bram_B.response.get();
    out[0] = x0;
    out[1] = x1;
    m2a.enq(out);
  endrule

  interface Put req;
    method Action put(WindowReq r) if (!needs_data);
      bram_write_addr <= 0;
      let ndx = r.ndx;
      counter_A.reset(ndx);
      counter_B.reset(ndx + fromInteger(((valueOf(WindowSizeA) - valueOf(WindowSizeB)) / 2) * (valueOf(ImageWidth) +1)));
    endmethod
  endinterface
endmodule



