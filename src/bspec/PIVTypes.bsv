import Types::*;
import MemTypes::*;

interface PIV;
   method ActionValue#(Data) cpuToHost;
   method Action hostToCpu(Addr startpc);
   interface MemInitIfc iMemInit;
endinterface