import Types::*;
import MemTypes::*;
import DMemory::*;
import PIVTypes::*;


(* synthesize *)
module [Module] mkPIV(PIV);
  DMemory dMem <- mkDMemory();
