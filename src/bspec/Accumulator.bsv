import PIVTypes::*;
import FIFO::*;
import Vector::*;

module mkAccumulator(FIFO#(Vector#(2, Pixel)) m2a, FIFO#(CrossCorrEl) a2t, Empty ifc);
  Reg#(CrossCorrEl) val <- mkReg(0);
  Reg#(WindowPixelAddrB) pixels_handled <- mkReg(0);

  rule accumulate;
    let pixels = m2a.first();
    CrossCorrEl prod = unsignedMul(pixels[0], pixels[1]);
    m2a.deq();
    if (pixels_handled >= fromInteger(valueOf(PixelsPerWindowB) - 1)) begin
      pixels_handled <= 0;
      a2t.enq(val + prod);
      val <= 0;
    end
    else begin
      val <= val + prod;
      pixels_handled <= pixels_handled + 1;
    end
  endrule
endmodule
