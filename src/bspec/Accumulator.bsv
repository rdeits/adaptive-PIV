import PIVTypes::*;
import FIFO::*;
import Vector::*;

module mkAccumulator(FIFO#(Vector#(2, Pixel)) m2a, FIFO#(CrossCorrEl) a2t, Empty ifc);
  Reg#(CrossCorrEl) val <- mkReg(0);
  Reg#(WindowPixelAddrB) pixels_handled <- mkReg(0);

  rule accumulate;
    let pixels = m2a.first();
    let prod = unsignedMul(pixels[0], pixels[1]);
    let result = val + zeroExtend(prod);
    m2a.deq();
    if (pixels_handled >= fromInteger(valueOf(PixelsPerWindowB) - 1)) begin
      pixels_handled <= 0;
      a2t.enq(result);
      val <= 0;
    end
    else begin
      val <= result;
      pixels_handled <= pixels_handled + 1;
    end
  endrule
endmodule
