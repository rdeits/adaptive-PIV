import Types::*;
import MemTypes::*;

interface PIV;
   // method ActionValue#(Tuple2#(RIndx, Data)) cpuToHost;
   // method Action hostToCpu(Addr startpc);
   interface MemInitIfc iMemInit;
   interface MemInitIfc dMemInit;
endinterface