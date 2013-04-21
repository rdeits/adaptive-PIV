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

typedef 800 ImageWidth;
typedef 600 ImageHeight;
typedef 4 PixelSz;
typedef Bit#(PixelSz) Pixel;

typedef 8 ImagePacketSize;
typedef Vector#(ImagePacketSize, Pixel) ImagePacket;

typedef 32 DataSz;
typedef Bit#(DataSz) Data;

typedef TMul#(ImageWidth, ImageHeight) PixelsPerImage;
typedef Bit#(TLog#(PixelsPerImage)) PixelNdx;
typedef TDiv#(DataSz, PixelSz) PixelsPerData;

typedef Bit#(TLog#(ImageWidth)) ColNdx;
typedef Bit#(TLog#(ImageHeight)) RowNdx;

typedef Bit#(TLog#(TDiv#(PixelsPerImage, PixelsPerData))) Addr;

typedef struct {
  Addr addr;
  TrackerID tracker_id;
} MemReq deriving (Bits);


typedef struct {
  PixelNdx ndx;
} WindowReq deriving (Bits, Eq);

typedef 40 WindowSizeA;
typedef 32 WindowSizeB;
typedef TMul#(WindowSizeA, WindowSizeA) PixelsPerWindowA;
typedef TMul#(WindowSizeB, WindowSizeB) PixelsPerWindowB;
typedef Bit#(TLog#(PixelsPerWindowA)) WindowPixelAddrA;
typedef Bit#(TLog#(PixelsPerWindowB)) WindowPixelAddrB;

typedef TAdd#(TSub#(WindowSizeA, WindowSizeB), 1) CrossCorrWidth;
typedef Bit#(TMul#(PixelSz, PixelSz)) CrossCorrEl;

typedef Int#(4) Displacement;

typedef struct {
  Displacement u;
  Displacement v;
} Displacements deriving (Bits, Eq);

typedef Server#(
  WindowReq,
  Displacements
) WindowTracker;

typedef Bool ClearT;

