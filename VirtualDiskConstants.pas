unit VirtualDiskConstants;

interface

uses
  orderlyinit,debug;
const
{$DEFINE BB_128MB}
{x$DEFINE BB_512MB}
{x$DEFINE BB8}

{x$DEFINE TINY_RAID}
{x$DEFINE BIGGUS_DISKUS}
{$IFDEF BIGGUS_DISKUS}
{$ELSE}
  BLOCKSHIFT = int64(9);
  BLOCKSIZE = int64(1) shl int64(blockshift){512};

{$IFDEF TINY_RAID}
  STRIPE_SHIFT = 3;x
{$ELSE}
  STRIPE_SHIFT = int64(9);
{$ENDIF}
  RAID_STRIPE_SIZE_IN_BLOCKS_SHIFT = int64(STRIPE_SHIFT);////<<<<<<----CHANGE TOGETHER--------------
  RAID_ALIGN_BYTE = not int64((1 shl (RAID_STRIPE_SIZE_IN_BLOCKS_SHIFT+BLOCKSHIFT))-1);
  RAID_ALIGN_BLOCK = NOT int64((1 shl RAID_STRIPE_SIZE_IN_BLOCKS_SHIFT)-1);
  RAID_STRIPE_SIZE_IN_BLOCKS = int64(int64(1) shl int64(RAID_STRIPE_SIZE_IN_BLOCKS_SHIFT));//<<<< ----
  RAID_STRIPE_SIZE_IN_BYTES = int64(RAID_STRIPE_SIZE_IN_BLOCKS)*int64(BLOCKSIZE);
  MAX_STRIPE_SIZE_IN_QWORDS = int64((int64(RAID_STRIPE_SIZE_IN_BYTES) div int64(8))+int64(1));
{$IFDEF BB_512MB}
  BIG_BLOCK_BLOCK_SHIFT  = int64(20);
  BIG_BLOCK_SIZE_IN_STRIPES =  int64((int64(65536*16)*int64(512)) div int64(RAID_STRIPE_SIZE_IN_BYTES));
{$ELSE}
  {$IFDEF BB_128MB}
    BIG_BLOCK_BLOCK_SHIFT  = int64(18);
    BIG_BLOCK_SIZE_IN_STRIPES =  int64((int64(65536*4)*int64(512)) div int64(RAID_STRIPE_SIZE_IN_BYTES));
  {$ELSE}
    {$IFDEF BB8}
      BIG_BLOCK_BLOCK_SHIFT  = int64(14);
      BIG_BLOCK_SIZE_IN_STRIPES =  int64((int64(16384)*int64(512)) div int64(RAID_STRIPE_SIZE_IN_BYTES));
    {$ELSE}
      BIG_BLOCK_BLOCK_SHIFT  = int64(16);
      BIG_BLOCK_SIZE_IN_STRIPES =  int64((int64(65536)*int64(512)) div int64(RAID_STRIPE_SIZE_IN_BYTES));
    {$ENDIF}
  {$ENDIF}
{$ENDIF}

  BIG_BLOCK_STRIPE_SHIFT = BIG_BLOCK_BLOCK_SHIFT - STRIPE_SHIFT;
  BIG_BLOCK_BYTE_SHIFT = int64(int64(BIG_BLOCK_BLOCK_SHIFT) + int64(BLOCKSHIFT));
  BIG_BLOCK_ALIGN_BYTE:int64 = not ((int64(1) shl int64(BIG_BLOCK_BYTE_SHIFT))-int64(1));
  BIG_BLOCK_ALIGN_BLOCK:int64 = not ((int64((1 shl BIG_BLOCK_BLOCK_SHIFT)))-int64(1));

  _BIG_BLOCK_SIZE_IN_BLOCKS = int64(int64(BIG_BLOCK_SIZE_IN_STRIPES) * int64(RAID_STRIPE_SIZE_IN_BLOCKS));
  BIG_BLOCK_SIZE_IN_BYTES = int64(int64(_BIG_BLOCK_SIZE_IN_BLOCKS)*int64(BLOCKSIZE));


  STRIPES_PER_BIG_BLOCK = int64(int64(_BIG_BLOCK_SIZE_IN_BLOCKS) div int64(RAID_STRIPE_SIZE_IN_BLOCKS));
  MAX_BLOCKS_IN_VAT = int64(int64(65536)*int64(64));
  MAX_POTENTIAL_DISK_SIZE:int64 = int64(int64(MAX_BLOCKS_IN_VAT) * int64(BIG_BLOCK_SIZE_IN_BYTES));
{$IFDEF TINY_RAID}
  MAX_RAID_STRIPES:int64 = int64(536870912)*int64(16);//int64(int64(MAX_BLOCKS_IN_VAT) * int64(BIG_BLOCK_SIZE_IN_STRIPES));
  LAST_STRIPE:int64 = (int64(536870912)*int64(16))-int64(1);//(int64(int64(MAX_BLOCKS_IN_VAT) * int64(BIG_BLOCK_SIZE_IN_STRIPES)))-1;
{$ELSE}
{$IFDEF BB_128MB}
                         //536870914;//int64(int64(MAX_BLOCKS_IN_VAT) * int64(BIG_BLOCK_SIZE_IN_STRIPES));
                         //536870914;//int64(int64(MAX_BLOCKS_IN_VAT) * int64(BIG_BLOCK_SIZE_IN_STRIPES));
  MAX_RAID_STRIPES:int64 = 1073741828;//int64(int64(MAX_BLOCKS_IN_VAT) * int64(BIG_BLOCK_SIZE_IN_STRIPES));
  LAST_STRIPE:int64 = 1073741827;//(int64(int64(MAX_BLOCKS_IN_VAT) * int64(BIG_BLOCK_SIZE_IN_STRIPES)))-1;
{$ELSE}
  MAX_RAID_STRIPES:int64 = 536870912;//int64(int64(MAX_BLOCKS_IN_VAT) * int64(BIG_BLOCK_SIZE_IN_STRIPES));
  LAST_STRIPE:int64 = 536870911;//(int64(int64(MAX_BLOCKS_IN_VAT) * int64(BIG_BLOCK_SIZE_IN_STRIPES)))-1;

{$ENDIF}
{$ENDIF}

{x$DEFINE SMALL_ARC}
{x$DEFINE SMALL_ARC}
{$IFDEF SMALL_ARC}

  ARC_ZONE_BLOCK_SHIFT  = 8;
  ARC_ZONE_SIZE_IN_BLOCKS = 1 shl ARC_ZONE_BLOCK_SHIFT;
  ARC_ZONE_BLOCK_BLOCK_ALIGN_MASK: Uint64=$FFFFFFFFFFFFFF00;
  ARC_ZONE_SIZE_IN_BYTES = ARC_ZONE_SIZE_IN_BLOCKS*BLOCKSIZE;
  ARC_ZONE_BYTE_ALIGN_MASK: Uint64 =      $FFFFFFFFFFFE0000;
{$ELSE}
{$IFDEF BB_128MB}
  ARC_ZONES_PER_BIG_BLOCK = 16;
{$ELSE}
  ARC_ZONES_PER_BIG_BLOCK = 4;
{$ENDIF}
  ARC_ZONE_BLOCK_SHIFT  = 14;
  ARC_ZONE_BYTE_SHIFT = ARC_ZONE_BLOCK_SHIFT + BLOCKSHIFT;
  ARC_ZONE_SIZE_IN_BLOCKS = 1 shl ARC_ZONE_BLOCK_SHIFT;
  ARC_ZONE_BLOCK_BLOCK_ALIGN_MASK: Uint64=$FFFFFFFFFFFFB000;
  ARC_ZONE_SIZE_IN_BYTES = ARC_ZONE_SIZE_IN_BLOCKS*BLOCKSIZE;
  ARC_ZONE_BYTE_ALIGN_MASK: Uint64 =      $FFFFFFFFFF800000;
{$ENDIF}

  MAX_DISK_SIZE = int64(65536*16)*int64(_BIG_BLOCK_SIZE_IN_BLOCKS*512);
  MAX_ARC_ZONES = MAX_DISK_SIZE div 256;
  MAX_ZONES = (_BIG_BLOCK_SIZE_IN_BLOCKS * MAX_BLOCKS_IN_VAT) div (ARC_ZONE_SIZE_IN_BLOCKS);
{$ENDIF}
  MAX_BIG_BLOCKS = MAX_BLOCKS_IN_VAT;
  STRIPE_ALIGN_MASK = $FFFFFFFFFFFFFFFF xor ((int64(1) shl (BLOCKSHIFT+STRIPE_SHIFT)) -1);
  STRIPE_ALIGN_BLOCK_MASK = $FFFFFFFFFFFFFFFF xor ((int64(1) shl (STRIPE_SHIFT)) -1);


function GetRaidBase(i: int64): int64;

implementation

    uses
  sysutils;

function GetRaidBase(i: int64): int64;
begin
  result := (i shr RAID_STRIPE_SIZE_IN_BLOCKS_SHIFT) shl RAID_STRIPE_SIZE_IN_BLOCKS_SHIFT;
end;

procedure oinit;
begin
  DEBUG.consolelog('    BLOCKSHIFT = '+inttostr(  BLOCKSHIFT));//BLOCKSHIFT = 9;
  debug.ConsoleLog('  BLOCKSIZE = '+inttostr(  BLOCKSIZE ));//1 shl blockshift{512};

  debug.consolelog('  STRIPE_SHIFT = '+inttostr(  STRIPE_SHIFT ));//0;
  debug.consolelog('  RAID_STRIPE_SIZE_IN_BLOCKS_SHIFT = '+inttostr(  RAID_STRIPE_SIZE_IN_BLOCKS_SHIFT ));//STRIPE_SHIFT;////<<<<<<----CHANGE TOGETHER--------------
  debug.consolelog('  RAID_ALIGN_BYTE = '+inttohex(  RAID_ALIGN_BYTE ,16));//not int64((1 shl (RAID_STRIPE_SIZE_IN_BLOCKS_SHIFT+BLOCKSHIFT))-1);
  debug.consolelog('  RAID_ALIGN_BLOCK = '+inttohex(  RAID_ALIGN_BLOCK,16 ));//NOT int64((1 shl RAID_STRIPE_SIZE_IN_BLOCKS_SHIFT)-1);
  debug.consolelog('  RAID_STRIPE_SIZE_IN_BLOCKS = '+inttostr(  RAID_STRIPE_SIZE_IN_BLOCKS ));//1 shl RAID_STRIPE_SIZE_IN_BLOCKS_SHIFT;//<<<< ----
  debug.consolelog('  RAID_STRIPE_SIZE_IN_BYTES = '+inttostr(  RAID_STRIPE_SIZE_IN_BYTES ));//RAID_STRIPE_SIZE_IN_BLOCKS*BLOCKSIZE;
  debug.consolelog('  MAX_STRIPE_SIZE_IN_QWORDS = '+inttostr(  MAX_STRIPE_SIZE_IN_QWORDS));//RAID_STRIPE_SIZE_IN_BYTES div 8)+1;

  debug.consolelog('  BIG_BLOCK_BLOCK_SHIFT  = '+inttostr(  BIG_BLOCK_BLOCK_SHIFT  ));//16;
  debug.consolelog('  BIG_BLOCK_BYTE_SHIFT = '+inttostr(  BIG_BLOCK_BYTE_SHIFT ));//BIG_BLOCK_BLOCK_SHIFT + BLOCKSHIFT;
  debug.consolelog('  BIG_BLOCK_ALIGN_BYTE:'+inttohex(  BIG_BLOCK_ALIGN_BYTE,16));//int64 = not (int64(1) shl int64(BIG_BLOCK_BYTE_SHIFT))-int64(1);
  debug.consolelog('  BIG_BLOCK_ALIGN_BLOCK:'+inttohex(  BIG_BLOCK_ALIGN_BLOCK,16));//int64 = not int64((1 shl BIG_BLOCK_BLOCK_SHIFT))-int64(1);
  debug.consolelog('  BIG_BLOCK_SIZE_IN_BYTES = '+inttostr(  BIG_BLOCK_SIZE_IN_BYTES ));//_BIG_BLOCK_SIZE_IN_BLOCKS*BLOCKSIZE;
  debug.consolelog('  BIG_BLOCK_SIZE_IN_STRIPES =  '+inttostr(  BIG_BLOCK_SIZE_IN_STRIPES ));//BIG_BLOCK_SIZE_IN_BYTES) div (RAID_STRIPE_SIZE_IN_BYTES);
  debug.consolelog('  _BIG_BLOCK_SIZE_IN_BLOCKS = '+inttostr(  _BIG_BLOCK_SIZE_IN_BLOCKS ));//BIG_BLOCK_SIZE_IN_STRIPES * RAID_STRIPE_SIZE_IN_BLOCKS;

  debug.consolelog('  STRIPES_PER_BIG_BLOCK = '+inttostr(  STRIPES_PER_BIG_BLOCK ));//_BIG_BLOCK_SIZE_IN_BLOCKS div RAID_STRIPE_SIZE_IN_BLOCKS;
  debug.consolelog('  MAX_BLOCKS_IN_VAT = '+inttostr(  MAX_BLOCKS_IN_VAT ));//65536*16;
  debug.consolelog('  MAX_POTENTIAL_DISK_SIZE ='+inttostr(  MAX_POTENTIAL_DISK_SIZE));//int64 = int64(MAX_BLOCKS_IN_VAT) * int64(BIG_BLOCK_SIZE_IN_BYTES);
  debug.consolelog('  MAX_RAID_STRIPES ='+inttostr(  MAX_RAID_STRIPES));//int64 = int64(MAX_BLOCKS_IN_VAT) * int64(BIG_BLOCK_SIZE_IN_STRIPES);
  debug.consolelog('  LAST_STRIPE ='+inttostr(  LAST_STRIPE));//int64 = int64(MAX_BLOCKS_IN_VAT) * int64(BIG_BLOCK_SIZE_IN_STRIPES);

end;

procedure ofinal;
begin
//TODO -cunimplemented: unimplemented block
end;

initialization
orderlyinit.init.RegisterProcs('virtualdiskconstants', oinit, ofinal, 'debug');


end.
