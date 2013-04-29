import PIVTypes::*;
import FIFO::*;
import GetPut::*;
import Ehr::*;

interface DisplacementTracker;
  interface Get#(Displacements) resp;
endinterface

module mkDisplacementTracker(FIFO#(CrossCorrEl) a2t, DisplacementTracker ifc);
  Ehr#(2, CrossCorrEl) max_val <- mkEhr(0);
  Ehr#(2, UInt#(TLog#(CrossCorrWidth))) max_row <- mkEhr(4);
  Ehr#(2, UInt#(TLog#(CrossCorrWidth))) max_col <- mkEhr(4);
  Reg#(UInt#(TLog#(CrossCorrWidth))) curr_row <- mkReg(0);
  Reg#(UInt#(TLog#(CrossCorrWidth))) curr_col <- mkReg(0);
  FIFO#(Displacements) outfifo <- mkFIFO();

  rule update;
    let new_val = a2t.first();
    a2t.deq();
    Displacement u;
    Displacement v;
    if (new_val > max_val[0]) begin
      max_col[0] <= curr_col;
      max_row[0] <= curr_row;
      u = curr_col;
      v = curr_row;
      max_val[0] <= new_val;
    end
    else begin
      u = max_col[0];
      v = max_row[0];
    end


    if (curr_col >= fromInteger(valueOf(CrossCorrWidth) - 1)) begin
      curr_col <= 0;
      if (curr_row >= fromInteger(valueOf(CrossCorrWidth) - 1)) begin
        curr_row <= 0;
        Displacements disp;
        disp.u = fromInteger(valueOf(CrossCorrWidth)) - 1 - u; // math is hard
        disp.v = v;
        disp.ndx = ?;
        outfifo.enq(disp);
        max_row[1] <= 4;
        max_col[1] <= 4;
        max_val[1] <= 0;
      end
      else begin
        curr_row <= curr_row + 1;
      end
    end
    else begin
      curr_col <= curr_col + 1;
    end
  endrule

  interface Get resp;
    method ActionValue#(Displacements) get();
      let x = outfifo.first();
      outfifo.deq();
      return x;
    endmethod
  endinterface
endmodule




