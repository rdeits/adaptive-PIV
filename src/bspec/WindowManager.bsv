import PIVTypes::*;
import GetPut::*;
import FIFO::*;
import IMemory::*;
import Vector::*;
import BRAM::*;
import AddrCounter::*;


interface WindowManager;
  // interface Put#(WindowReq) req;
  method Action start();
  method Bool is_done_storing();
  interface Put#(Pixel) pxA;
  interface Put#(Pixel) pxB;
endinterface

typedef enum {WaitingForReq, Downloading, Outputting} State deriving (Bits, Eq);

module mkWindowManager(TrackerID tracker_id, FIFO#(Vector#(2, Pixel)) m2a, WindowManager ifc);
  Bit#(WindowSizeA) winsizeA = ?;
  Bit#(WindowSizeB) winsizeB = ?;
  Bit#(TAdd#(TSub#(WindowSizeA, WindowSizeB), 1)) dummy1 = ?;
  AddrCounter sub_counter_A <- mkCounter(winsizeB, winsizeA);
  AddrCounter sub_counter_B <- mkCounter(winsizeB, winsizeB);
  AddrCounter sub_frame_pos_counter <- mkCounter(dummy1, winsizeA);
  FIFO#(Pixel) inFIFO_A <- mkFIFO();
  FIFO#(Pixel) inFIFO_B <- mkFIFO();

  Reg#(UInt#(TLog#(TMul#(CrossCorrWidth, CrossCorrWidth)))) sub_frames_requested <- mkReg(0);
  Reg#(WindowPixelAddrA) bram_write_addr_A <- mkReg(0);
  Reg#(WindowPixelAddrB) bram_write_addr_B <- mkReg(0);

  Reg#(State) state <- mkReg(WaitingForReq);

  Reg#(Bool) done_requesting_output <- mkReg(False);
  Reg#(Bit#(TLog#(TSub#(WindowSizeA, WindowSizeB)))) sub_frame_row <- mkReg(0);
  Reg#(Bit#(TLog#(TSub#(WindowSizeA, WindowSizeB)))) sub_frame_col <- mkReg(0);

  Reg#(Bool) done_storing_A <- mkReg(False);
  Reg#(Bool) done_storing_B <- mkReg(False);

  Reg#(UInt#(TLog#(NumPixelPairs))) num_pixel_pairs_output <- mkReg(0);

  BRAM_Configure cfg_A = defaultValue;
  cfg_A.memorySize = valueOf(PixelsPerWindowA);
  BRAM1Port#(WindowPixelAddrA, Pixel) bram_A <- mkBRAM1Server(cfg_A);

  BRAM_Configure cfg_B = defaultValue;
  cfg_B.memorySize = valueOf(PixelsPerWindowB);
  BRAM1Port#(WindowPixelAddrB, Pixel) bram_B <- mkBRAM1Server(cfg_B);

  rule store_download_A if (!done_storing_A && state == Downloading);
    // Pixel new_pixel = iMem.queue_first_A(tracker_id);
    // Pixel new_pixel <- iMem.resp_A.get();
    Pixel new_pixel = inFIFO_A.first();
    inFIFO_A.deq();
    // $display("manager %d got pixel A from iMem", tracker_id);
    bram_A.portA.request.put(BRAMRequest {
      write: True,
      responseOnWrite: False,
      address: bram_write_addr_A,
      datain: new_pixel});
    if (bram_write_addr_A >= fromInteger(valueOf(PixelsPerWindowA) - 1)) begin
      // $display("done storing A");
      done_storing_A <= True;
    end
    else begin
      bram_write_addr_A <= bram_write_addr_A + 1;
    end
  endrule

  rule store_download_B if (!done_storing_B && state == Downloading);
    // $display("tracker %d got pixel B from iMem", tracker_id);
    // Pixel new_pixel = iMem.queue_first_B(tracker_id);
    // Pixel new_pixel <- iMem.resp_B.get();
    Pixel new_pixel = inFIFO_B.first();
    inFIFO_B.deq();
    // $display("storing download B value %d at %d", new_pixel, bram_write_addr_B);
    bram_B.portA.request.put(BRAMRequest {
      write: True,
      responseOnWrite: False,
      address: bram_write_addr_B,
      datain: new_pixel});
    if (bram_write_addr_B >= fromInteger(valueOf(PixelsPerWindowB) - 1)) begin
      // $display("done storing B");
      done_storing_B <= True;
    end
    else begin
      bram_write_addr_B <= bram_write_addr_B + 1;
    end
    // iMem.queue_deq_B(tracker_id);
  endrule

  rule end_downloading_state if (done_storing_A && done_storing_B && state == Downloading);
    state <= Outputting;
    $display("tracker: %d ending downloading state", tracker_id);
    // iMem.next_tracker();
    // iMem.release_lock();
  endrule

  rule start_next_frame if (sub_counter_B.done() && !done_requesting_output && state == Outputting);
    // $display("starting next frame");
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

  rule request_output if (state == Outputting && !sub_counter_B.done() && !done_requesting_output);
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

  rule output_data if (state == Outputting);
    Vector#(2, Pixel) out;
    let x0 <- bram_A.portA.response.get();
    let x1 <- bram_B.portA.response.get();
    out[0] = x0;
    out[1] = x1;
    // $display("%d, %d", x0, x1);
    m2a.enq(out);
    if (num_pixel_pairs_output < fromInteger(valueOf(NumPixelPairs) - 1)) begin
      num_pixel_pairs_output <= num_pixel_pairs_output + 1;
    end
    else begin
      $display("tracker: %d done outputting data", tracker_id);
      state <= WaitingForReq;
    end
  endrule

  method Bool is_done_storing();
    let x = done_storing_A && done_storing_B;
    return x;
  endmethod

  method Action start() if (state == WaitingForReq);
    // let r = reqFIFO.first();
    // reqFIFO.deq();
    $display("tracker: %d starting", tracker_id);
    state <= Downloading;
    done_storing_A <= False;
    done_storing_B <= False;
    bram_write_addr_A <= 0;
    bram_write_addr_B <= 0;
    sub_frames_requested <= 0;
    done_requesting_output <= False;
    sub_frame_pos_counter.reset(1);
    sub_counter_A.reset(0);
    sub_counter_B.reset(0);
    sub_frame_row <= 0;
    sub_frame_col <= 0;
    num_pixel_pairs_output <= 0;
  endmethod


  interface Put pxA = toPut(inFIFO_A);
  interface Put pxB = toPut(inFIFO_B);
endmodule



