import ClientServer::*;
import GetPut::*;
import Vector::*;
import FIFO::*;

typedef 2 NumTrackers;
// typedef UInt#(TAdd#(TLog#(NumTrackers), 1)) TrackerID;
typedef UInt#(TLog#(NumTrackers)) TrackerID;

typedef 800 ImageWidth;
typedef 60 ImageHeight;
typedef 4 PixelSz;
typedef UInt#(PixelSz) Pixel;

typedef 8 ImagePacketSize;
typedef Vector#(ImagePacketSize, Pixel) ImagePacket;

// typedef 32 DataSz;
// typedef UInt#(DataSz) Data;

typedef TMul#(ImageWidth, ImageHeight) PixelsPerImage;
typedef UInt#(TLog#(PixelsPerImage)) PixelNdx;
// typedef TDiv#(DataSz, PixelSz) PixelsPerData;

typedef UInt#(TLog#(ImageWidth)) ColNdx;
typedef UInt#(TLog#(ImageHeight)) RowNdx;

// typedef UInt#(TLog#(TDiv#(PixelsPerImage, PixelsPerData))) Addr;

typedef struct {
  // Addr addr;
  PixelNdx addr;
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
typedef UInt#(TAdd#(TAdd#(PixelSz, PixelSz), TMul#(CrossCorrWidth, CrossCorrWidth))) CrossCorrEl;

typedef TMul#(TMul#(TMul#(WindowSizeB, WindowSizeB), CrossCorrWidth), CrossCorrWidth) NumPixelPairs;

typedef UInt#(TLog#(CrossCorrWidth)) Displacement;

typedef struct {
  PixelNdx ndx;
  Displacement u;
  Displacement v;
} Displacements deriving (Bits, Eq);

typedef Bool ClearT;

