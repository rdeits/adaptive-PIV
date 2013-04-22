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
endinterface

module mkWindowManager(IMemory iMem, TrackerID tracker_id, FIFO#(Vector#(2, Pixel)) m2a, WindowManager ifc);
  Bit#(WindowSizeA) winsizeA = ?;
  Bit#(WindowSizeB) winsizeB = ?;
  Bit#(ImageWidth) imwidth = ?;
  Bit#(TAdd#(TSub#(WindowSizeA, WindowSizeB), 1)) dummy1 = ?;
  AddrCounter counter_A <- mkCounter(winsizeA, imwidth);
  AddrCounter counter_B <- mkCounter(winsizeB, imwidth);
  AddrCounter sub_counter_A <- mkCounter(winsizeB, winsizeA);
  AddrCounter sub_counter_B <- mkCounter(winsizeB, winsizeB);
  AddrCounter sub_frame_pos_counter <- mkCounter(dummy1, winsizeA);

  Reg#(UInt#(TLog#(TMul#(CrossCorrWidth, CrossCorrWidth)))) sub_frames_requested <- mkReg(0);
  Reg#(WindowPixelAddrA) bram_write_addr_A <- mkReg(0);
  Reg#(WindowPixelAddrB) bram_write_addr_B <- mkReg(0);

  Reg#(Bool) done_requesting_output <- mkReg(False);
  Reg#(Bit#(TLog#(TSub#(WindowSizeA, WindowSizeB)))) sub_frame_row <- mkReg(0);
  Reg#(Bit#(TLog#(TSub#(WindowSizeA, WindowSizeB)))) sub_frame_col <- mkReg(0);

  Reg#(Bool) done_storing_A <- mkReg(False);
  Reg#(Bool) done_storing_B <- mkReg(False);

  BRAM_Configure cfg_A = defaultValue;
  cfg_A.memorySize = valueOf(PixelsPerWindowA);
  BRAM1Port#(WindowPixelAddrA, Pixel) bram_A <- mkBRAM1Server(cfg_A);

  BRAM_Configure cfg_B = defaultValue;
  cfg_B.memorySize = valueOf(PixelsPerWindowB);
  BRAM1Port#(WindowPixelAddrB, Pixel) bram_B <- mkBRAM1Server(cfg_B);

  rule request_download_A if (!counter_A.done());
    let addr <- counter_A.get_addr();
    iMem.req_A.put(MemReq{addr: addr, tracker_id: tracker_id});
  endrule

  rule request_download_B if (!counter_B.done());
    let addr <- counter_B.get_addr();
    iMem.req_B.put(MemReq{addr: addr, tracker_id: tracker_id});
  endrule

  rule store_download_A if (!done_storing_A);
    Pixel new_pixel = iMem.queue_first_A(tracker_id);
    bram_A.portA.request.put(BRAMRequest {
      write: True,
      responseOnWrite: False,
      address: bram_write_addr_A,
      datain: new_pixel});
    if (bram_write_addr_A >= fromInteger(valueOf(PixelsPerWindowA) - 1)) begin
      $display("done storing A");
      done_storing_A <= True;
    end
    else begin
      bram_write_addr_A <= bram_write_addr_A + 1;
    end
    iMem.queue_deq_A(tracker_id);
  endrule

  rule store_download_B if (!done_storing_B);
    Pixel new_pixel = iMem.queue_first_B(tracker_id);
    // $display("storing download B value %d at %d", new_pixel, bram_write_addr_B);
    bram_B.portA.request.put(BRAMRequest {
      write: True,
      responseOnWrite: False,
      address: bram_write_addr_B,
      datain: new_pixel});
    if (bram_write_addr_B >= fromInteger(valueOf(PixelsPerWindowB) - 1)) begin
      $display("done storing B");
      done_storing_B <= True;
    end
    else begin
      bram_write_addr_B <= bram_write_addr_B + 1;
    end
    iMem.queue_deq_B(tracker_id);
  endrule

  rule start_next_frame if (sub_counter_B.done() && !done_requesting_output);
    $display("starting next frame");
    let addr <- sub_frame_pos_counter.get_addr();
    sub_counter_A.reset(addr);
    sub_counter_B.reset(0);
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
    // $display("requesting output: A %d B %d", addr_A, addr_B);
  endrule

  rule output_data;
    Vector#(2, Pixel) out;
    let x0 <- bram_A.portA.response.get();
    let x1 <- bram_B.portA.response.get();
    out[0] = x0;
    out[1] = x1;
    // $display("%d, %d", x0, x1);
    m2a.enq(out);
  endrule

  interface Put req;
    method Action put(WindowReq r);
      bram_write_addr_A <= 0;
      bram_write_addr_B <= 0;
      sub_frames_requested <= 0;
      done_requesting_output <= False;
      sub_frame_pos_counter.reset(1);
      sub_counter_A.reset(0);
      sub_counter_B.reset(0);
      sub_frame_row <= 0;
      sub_frame_col <= 0;
      let ndx = r.ndx;
      counter_A.reset(ndx);
      let pos_B = ndx + fromInteger(((valueOf(WindowSizeA) - valueOf(WindowSizeB)) / 2) * (valueOf(ImageWidth) +1));
      counter_B.reset(pos_B);
    endmethod
  endinterface
endmodule



