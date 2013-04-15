/*

Copyright (C) 2012 Muralidaran Vijayaraghavan <vmurali@csail.mit.edu>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

import Types::*;
import MemTypes::*;
// import RegFile::*;
import MemInit::*;
import GetPut::*;
import BRAM::*;

// interface DMemory;
//     method ActionValue#(MemResp) req(MemReq r);
//     interface MemInitIfc init;
// endinterface

interface DMemory;
  interface Put#(MemReq) req;
  interface Get#(MemResp) resp;
  interface MemInitIfc init;
endinterface


(* synthesize *)
module mkDMemory(DMemory);
  BRAM_Configure cfg = defaultValue;
  BRAM1Port#(Bit#(16), Data) bram <- mkBRAM1Server(cfg);
  MemInitIfc memInit <- mkMemInitBRAM(bram);

  interface Put req;
    method Action put(MemReq r) if (memInit.done());
      if (r.op == St) begin
        bram.portA.request.put(BRAMRequest {
          write: True,
          responseOnWrite: False,
          address: truncate(r.addr >> 2),
          datain: r.data});
      end
      else begin
        bram.portA.request.put(BRAMRequest {
          write: False,
          responseOnWrite: False,
          address: truncate(r.addr >> 2),
          datain: 0});
      end
    endmethod
  endinterface

  interface Get resp;
    method ActionValue#(MemResp) get()  if (memInit.done());
      let r <- bram.portA.response.get();
      return r;
    endmethod
  endinterface

  // RegFile#(Bit#(16), Data) mem <- mkRegFileFull();
  // MemInitIfc memInit <- mkMemInitRegFile(mem);

  // method ActionValue#(MemResp) req(MemReq r) if (memInit.done());
  //   Bit#(16) index = truncate(r.addr>>2);
  //   let data = mem.sub(index);
  //   if(r.op==St)
  //   begin
  //     mem.upd(index, r.data);
  //   end
  //   return data;
  // endmethod

  interface MemInitIfc init = memInit;
endmodule