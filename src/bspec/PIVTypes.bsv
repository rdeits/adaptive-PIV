import ClientServer::*;
import GetPut::*;
import Vector::*;
import FIFO::*;

typedef 1 NumTrackers;
typedef Bit#(TAdd#(TLog#(NumTrackers), 1)) TrackerID;

interface PIV;
  method ActionValue#(Displacements) get_displacements;
  method Action put_window_req(WindowReq req);
  method Action store_image(ImagePacket x);
  method Action clear_image();
  method Action done_loading();
   // method ActionValue#(Data) cpuToHost;
   // method Action hostToCpu(Addr startpc);
   // interface MemInitIfc iMemInit;
endinterface

typedef 18 AddrSz;
typedef Bit#(AddrSz) Addr;

typedef 4 PixelSz;
typedef Bit#(PixelSz) Pixel;
typedef 8 ImagePacketSize;
typedef Vector#(ImagePacketSize, Pixel) ImagePacket;

typedef 32 DataSz;
typedef Bit#(DataSz) Data;
// typedef ImagePacket Data;

typedef struct {
  Addr addr;
  TrackerID tracker_id;
} MemReq deriving (Bits);

typedef struct {
  PixelNdx ndx;
  WindowSize size;
} WindowReq deriving (Bits, Eq);

typedef Bit#(19) PixelNdx;

typedef Bit#(TMul#(WindowSizeSz, WindowSizeSz)) WindowPixelNdx;

typedef 6 WindowSizeSz;
typedef Bit#(WindowSizeSz) WindowSize;

typedef Int#(4) Displacement;

// typedef struct {
//   Displacement u;
//   Displacement v;
// } Displacements deriving (Bits, Eq);

typedef struct {
  Data u;
  Data v;
} Displacements deriving (Bits, Eq);

typedef Server#(
  WindowReq,
  Displacements
) WindowTracker;

typedef 480000 PIXELS_PER_IMAGE;

typedef 4 PIXELS_PER_LINE;
// typedef 4 PIXELS_PER_IMAGE;



typedef Bool ClearT;

