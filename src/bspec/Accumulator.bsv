import PIVTypes::*;

module mkAccumulator(FIFO#(Vector#(2, Pixel)) m2a, FIFO#(CrossCorrEl) a2t, Empty ifc);
  Reg#(CrossCorrEl) val <- mkReg(0);
  Reg#(WindowPixelAddrB) pixels_handled <- mkReg(0);

  rule accumulate;
    let pixels = m2a.first();
    m2a.deq();
    if (pixels_handled >= fromInteger(valueOf(PixelsPerWindowB) - 1)) begin
      pixels_handled <= 0;
      a2t.enq(val + pixels[0] * pixels[1]);
      val <= 0;
    end
    else begin
      val <= val + pixels[0] * pixels[1];
      pixels_handled <= pixels_handled + 1;
    end
  endrule
endmodule
