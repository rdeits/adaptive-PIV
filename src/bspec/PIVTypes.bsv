import ClientServer::*;
import GetPut::*;
import Vector::*;
import FIFO::*;

typedef 1 NumTrackers;
typedef UInt#(TAdd#(TLog#(NumTrackers), 1)) TrackerID;

typedef 40 ImageWidth;
typedef 40 ImageHeight;
typedef 4 PixelSz;
typedef UInt#(PixelSz) Pixel;

typedef 8 ImagePacketSize;
typedef Vector#(ImagePacketSize, Pixel) ImagePacket;

typedef 32 DataSz;
typedef UInt#(DataSz) Data;

typedef TMul#(ImageWidth, ImageHeight) PixelsPerImage;
typedef UInt#(TLog#(PixelsPerImage)) PixelNdx;
typedef TDiv#(DataSz, PixelSz) PixelsPerData;

typedef UInt#(TLog#(ImageWidth)) ColNdx;
typedef UInt#(TLog#(ImageHeight)) RowNdx;

typedef UInt#(TLog#(TDiv#(PixelsPerImage, PixelsPerData))) Addr;

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
typedef UInt#(TLog#(PixelsPerWindowA)) WindowPixelAddrA;
typedef UInt#(TLog#(PixelsPerWindowB)) WindowPixelAddrB;

typedef TAdd#(TSub#(WindowSizeA, WindowSizeB), 1) CrossCorrWidth;
typedef UInt#(TAdd#(PixelSz, PixelSz)) CrossCorrEl;

typedef UInt#(TLog#(CrossCorrWidth)) Displacement;

typedef struct {
  Displacement u;
  Displacement v;
} Displacements deriving (Bits, Eq);

typedef Bool ClearT;

