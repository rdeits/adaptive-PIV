import PIVTypes::*;

interface AddrCounter;
  method Action reset(PixelNdx ndx);
  method ActionValue#(PixelNdx) get_addr();
  method Bool done();
endinterface

module mkCounter(Numeric winsize, Numeric imwidth, AddrCounter ifc);
  Reg#(PixelNdx) curr_ndx <- mkRegU();
  Reg#(PixelNdx) start_ndx <- mkRegU();
  Reg#(Bool) has_data <- mkReg(False);
  Reg#(Bit#(SizeOf#(winsize))) col_pos <- mkRegU();
  Reg#(Bit#(SizeOf#(winsize))) row_pos <- mkRegU();

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
    end
    else begin
      curr_addr <= curr_addr + 1;
    end
    return ret;
  endmethod

  method Bool done();
    let ret = row_pos >= fromInteger(valueOf(winsize) - 1);
    return ret;
  endmethod
endmodule

