import PIVTypes::*;

interface AddrCounter;
  method Action reset(PixelNdx ndx);
  method ActionValue#(PixelNdx) get_addr();
  method Bool done();
endinterface

module mkCounter(Bit#(winsize) dummy1, Bit#(imwidth) dummy2, AddrCounter ifc);
  Reg#(PixelNdx) curr_ndx <- mkRegU();
  Reg#(PixelNdx) start_ndx <- mkRegU();
  Reg#(Bool) has_data <- mkReg(False);
  Reg#(Bit#(winsize)) col_pos <- mkRegU();
  Reg#(Bit#(winsize)) row_pos <- mkRegU();

  method Action reset(PixelNdx ndx);
    has_data <= True;
    col_pos <= 0;
    row_pos <= 0;
    curr_ndx <= ndx;
    start_ndx <= ndx;
  endmethod

  method ActionValue#(PixelNdx) get_addr() if (has_data);
    let ret = curr_ndx;
    if (col_pos >= fromInteger(valueOf(winsize) - 1)) begin
      col_pos <= 0;
      curr_ndx <= curr_ndx + fromInteger((valueOf(imwidth) - valueOf(winsize)) + 1);
      row_pos <= row_pos + 1;
      // $display("row pos increments. new row pos: %d, winsize: %d", row_pos + 1, valueOf(winsize));
    end
    else begin
      col_pos <= col_pos + 1;
      curr_ndx <= curr_ndx + 1;
    end
    return ret;
  endmethod

  method Bool done();
    let ret = row_pos >= fromInteger(valueOf(winsize));
    return ret;
  endmethod
endmodule

