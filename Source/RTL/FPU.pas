{ Floating POint Runtime lib (Intel386 CPU are minimum, Pentium-class recommended)

WARNING
/*use InitFPU before calling any of this funcs*/
	(C) 2003 HELL SL, MP_ART
	(C) 2003, 2004 Unknown Group North, EP_X0FF
}
unit FPU;

interface

function sinl(x: pextended): extended;
function cosl(x: pextended): extended;
function tanl(x: pextended): extended;
function ctgl(x: pextended): extended;
function arcsinl(x: pextended): extended;
function arccosl(x: pextended): extended;
function arctanl(x: pextended): extended;
function arcctgl(x: pextended): extended;
function sqrtl(x: pextended): extended;
function sqrl(x: pextended): extended;
function _log10(x: pextended): extended;
function _log2(x: pextended): extended;
function _ln(x: pextended): extended;
function _log(b, x: pextended): extended;
function _exp(x: pextended): extended;
function _pow(b, e: pextended): extended;

implementation

{$r-}
{$q-}

function sinl(x: pextended): extended;
asm
  fld tbyte ptr [eax]
  fsin
end;

function cosl(x: pextended): extended;
asm
  fld tbyte ptr [eax]
  fcos
end;

function tanl(x: pextended): extended;
asm
  fld tbyte ptr [eax]
  fptan
  fstp st(0)
end;

function ctgl(x: pextended): extended;
asm
  fld tbyte ptr [eax]
  fptan
  fdivrp st(1), st(0)
end;

function arcsinl(x: pextended): extended;
asm
  fld tbyte ptr [eax]
  fld1
  fld st(1)
  fld st(2)
  fmulp st(1), st(0)
  fsubp st(1), st(0)
  fsqrt
  fpatan
end;

function arccosl(x: pextended): extended;
asm
  fld1
  fld tbyte ptr [eax]
  fld st(0)
  fmulp st(1), st(0)
  fsubp st(1), st(0)
  fsqrt
  fld tbyte ptr [eax]
  fpatan
end;

function arctanl(x: pextended): extended;
asm
  fld tbyte ptr [eax]
  fld1
  fpatan
end;

function arcctgl(x: pextended): extended;
asm
  fld1
  fld tbyte ptr [eax]
  fpatan
end;

function sqrtl(x: pextended): extended;
asm
  fld tbyte ptr [eax]
  fsqrt
end;

function sqrl(x: pextended): extended;
asm
  fld tbyte ptr [eax]
  fmul st(0), st(0);
end;

function _log10(x: pextended): extended;
asm
  fldlg2
  fld tbyte ptr [eax]
  fyl2x
end;

function _log2(x: pextended): extended;
asm
  fld1
  fld tbyte ptr [eax]
  fyl2x
end;

function _ln(x: pextended): extended;
asm
  fld tbyte ptr [eax]
  fldln2
  fxch st(1)
  fyl2x
end;

function _log(b, x: pextended): extended;
asm
  fld1
  fld tbyte ptr [edx]
  fyl2x
  fld1
  fld tbyte ptr [eax]
  fyl2x
  fdiv
end;

function _exp(x: pextended): extended;
asm
  fld tbyte ptr [eax]
  fldl2e
  fmulp
  fld st(0)
  frndint
  fsub st(1), st(0)
  fxch st(1)
  f2xm1
  fld1
  faddp
  fscale
  fstp st(1)
end;

function _pow(b, e: pextended): extended;
var
  tmp: extended;
begin
  if b^ = 0 then
  begin
    result := 0;
    exit;
  end;
  if e^ = 0 then
  begin
    result := 1;
    exit;
  end;
  tmp := e^ * _ln(b);
  result := _exp(@tmp);
end;

end.

