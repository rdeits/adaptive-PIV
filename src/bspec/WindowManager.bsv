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
  Reg#(Addr) start_addr <- mkRegU();
  Reg#(UInt#(TLog#(ImagePacketSize))) queue_offset_A <- mkReg(0);
  Reg#(UInt#(TLog#(ImagePacketSize))) queue_offset_B <- mkReg(0);
  Reg#(UInt#(TLog#(ImagePacketSize))) phase_B <- mkReg(0);

  Reg#(UInt#(TLog#(ImagePacketSize))) req_cycle_A <- mkReg(0);
  Reg#(UInt#(TLog#(ImagePacketSize))) req_cycle_B <- mkReg(0);

  BRAM_Configure cfg_A = defaultValue;
  cfg_A.memorySize = valueOf(PixelsPerWindowA);
  BRAM1Port#(WindowPixelAddrA, Pixel) bram_A <- mkBRAM1Server(cfg_A);

  BRAM_Configure cfg_B = defaultValue;
  cfg_B.memorySize = valueOf(PixelsPerWindowB);
  BRAM1Port#(WindowPixelAddrB, Pixel) bram_B <- mkBRAM1Server(cfg_B);

  rule request_download_A if (!counter_A.done());
    let addr <- counter_A.get_addr();
    addr = addr >> fromInteger(valueOf(TLog#(PixelsPerData)));
    req_cycle_A <= req_cycle_A + 1;
    if (req_cycle_A == 0) begin
      // $display("requesting download A at %d", addr);
      iMem.req_A.put(MemReq{addr: truncate(addr), tracker_id: tracker_id});
    end
  endrule

  rule request_download_B if (!counter_B.done());
    let addr <- counter_B.get_addr();
    addr = addr >> fromInteger(valueOf(TLog#(PixelsPerData)));
    req_cycle_B <= req_cycle_B + 1;
    if (req_cycle_B == phase_B) begin
      // $display("requesting download B at %d", addr);
      iMem.req_B.put(MemReq{addr: truncate(addr), tracker_id: tracker_id});
    end
  endrule

  rule store_download_A if (!done_storing_A);
    ImagePacket new_data = iMem.queue_first_A(tracker_id);
    Pixel new_pixel = new_data[queue_offset_A];
    // $display("storing download A. new_data: %d, pixel: %d", new_data, new_pixel);
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
    if (queue_offset_A >= fromInteger(valueOf(ImagePacketSize) - 1)) begin
      iMem.queue_deq_A(tracker_id);
      queue_offset_A <= 0;
    end
    else begin
      queue_offset_A <= queue_offset_A + 1;
    end
  endrule

  rule store_download_B if (!done_storing_B);
    ImagePacket new_data = iMem.queue_first_B(tracker_id);
    Pixel new_pixel = new_data[queue_offset_B];
    $display("storing download B value %d at %d with queue offset %d", new_pixel, bram_write_addr_B, queue_offset_B);
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
    if (queue_offset_B == phase_B - 1) begin
      iMem.queue_deq_B(tracker_id);
      queue_offset_B <= phase_B;
    end
    else begin
      queue_offset_B <= queue_offset_B + 1;
    end
  endrule

  rule start_next_frame if (sub_counter_B.done() && !done_requesting_output);
    $display("starting next frame");
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

  // rule disp;
  //   $display("done_storing_A %d", done_storing_A);
  //   $display("done_storing_B %d", done_storing_B);
  //   $display("sub_counter_A.done() %d", sub_counter_A.done());
  //   $display("sub_counter_B.done() %d", sub_counter_B.done());
  //   $display("done_requesting_output %d", done_requesting_output);
  // endrule

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
    $display("adding to output queue: x0 %d, x1 %d\n", x0, x1);
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

      queue_offset_A <= 0;
      UInt#(TLog#(ImagePacketSize)) phase_B = truncate(pos_B);
      $display("pos_B: %d, phase of B: %d", pos_B, phase_B);
      queue_offset_B <= phase_B;
    endmethod
  endinterface
endmodule



