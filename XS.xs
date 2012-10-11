#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <complex.h>

typedef complex double Cx;
typedef complex double Cx_inv; /* hack to use a different typemap for inverse functions as sec or asec */

static char bad_internals_error[] = "Internal error: bad representation for Math::Complex::XS code";

#define croak_bad_internals() Perl_croak(aTHX_ bad_internals_error);

#define CXLEN (sizeof(Cx) + 1)
#define SVt_Cx SVt_PV

#define SCx_c(scx) (*(Cx *)(SvPVX(scx)))
#define SCx_flags(scx) (*(unsigned char *)(((Cx *)(SvPVX(scx))) + 1))

static SV *
new_scx(pTHX) {
    SV *scx = newSV(CXLEN);
    SvPOK_on(scx);
    SvCUR_set(scx, CXLEN);
    (SvPVX(scx))[CXLEN] = '\0';
    return scx;
}

#define STRINGIFY_AS_POLAR  1

static SV *
newSVcx(pTHX_ double complex c) {
    SV *scx = new_scx(aTHX);
    SCx_c(scx) = c;
    SCx_flags(scx) = 0;
    SV *sv = newRV_noinc(scx);
    sv_bless(sv, gv_stashpvs("Math::Complex::XS", TRUE));
    return sv;
}

static SV *
newSVcx_inv(pTHX_ double complex c) {
    if (c == 0)
        Perl_croak(aTHX_ "Illegal division by zero");
    return newSVcx(aTHX_ 1 / c);
}

static int
SvCxOK(pTHX_ SV *sv) {
    if (SvROK(sv)) {
        SV *scx = SvRV(sv);
        return (scx && sv_isa(sv, "Math::Complex::XS"));
    }
    return 0;
}

static Cx *
SvCx_fast(pTHX_ SV *sv) {
    if (SvROK(sv)) {
        SV *scx = SvRV(sv);
        if (SvPOK(scx) && (SvCUR(scx) == CXLEN))
            return (Cx *)SvPVX(scx);
    }
    croak_bad_internals();
}
#define SvCxX(sv) (*(SvCx_fast(aTHX_ sv)))

static Cx *
SvCx_only(pTHX_ SV *sv) {
    if (SvROK(sv)) {
        SV *scx = SvRV(sv);
        if (scx && SvOBJECT(scx)) {
            char const *classname = HvNAME_get(SvSTASH(scx));
            if (strcmp(classname, "Math::Complex::XS") == 0)
                if (SvPOK(scx) && (SvCUR(scx) != CXLEN))
                    return (Cx *)SvPVX(scx);
        }
    }
    Perl_croak(aTHX_ "Object of type Math::Complex::XS expected");
}
#define SvCxX_only(sv) (*(SvCx_only(aTHX_ sv)))                 

static Cx
SvCx(pTHX_ SV *sv) {
    if (SvROK(sv)) {
        SV *scx = SvRV(sv);
        if (scx && SvOBJECT(scx)) {
            char const *classname = HvNAME_get(SvSTASH(scx));
            if (strcmp(classname, "Math::Complex::XS") == 0) {
                if (!SvPOK(scx) || (SvCUR(scx) != CXLEN))
                    croak_bad_internals();
                return *(Cx *)SvPVX(scx);
            }
        }
    }
    return SvNV(sv);
}

static Cx
SvCx_inv(pTHX_ SV *sv) {
    Cx c = SvCx(aTHX_ sv);
    if (c == 0)
        Perl_croak(aTHX_ "Illegal division by zero");
    return c;
}

MODULE = Math::Complex::XS		PACKAGE = Math::Complex::XS		

SV *
make(klass,...)
    SV *klass
CODE:
    switch (items) {
    case 1:
        RETVAL = newSVcx(aTHX_ 0);
        break;
    case 2:
        Perl_croak(aTHX_ "Math::Complex::XS->make(arg1) not implemented yet");
    case 3:
        RETVAL = newSVcx(aTHX_ SvCx(aTHX_ ST(1)) + SvCx(aTHX_ ST(2)) * I);
        break;
    default:
        Perl_croak(aTHX_ "Usage: Math::Complex::XS->make($real, $imag)");
    }
OUTPUT:
    RETVAL

SV *
emake(klass, ...)
    SV *klass
CODE:
    switch (items) {
    case 1:
        RETVAL = newSVcx(aTHX_ 0);
        break;
    case 2:
        Perl_croak(aTHX_ "Math::Complex::XS->emake(arg1) not implemented yet");
    case 3:
        RETVAL = newSVcx(aTHX_ SvCx(aTHX_ ST(1)) * cexp(I * SvCx(aTHX_ ST(2))));
        break;
    default:
        Perl_croak(aTHX_ "Usage: Math::Complex::XS->make($module, $argument)");
    }
OUTPUT:
    RETVAL

SV *
cplx(...)
CODE:
    switch (items) {
    case 0:
        RETVAL = newSVcx(aTHX_ 0);
        break;
    case 1:
        Perl_croak(aTHX_ "Math::Complex::XS->make(arg1) not implemented yet");
    case 2:
        RETVAL = newSVcx(aTHX_ SvCx(aTHX_ ST(0)) + SvCx(aTHX_ ST(1)) * I);
        break;
    default:
        Perl_croak(aTHX_ "Usage: Math::Complex::XS->make($real, $imag)");
    }
OUTPUT:
    RETVAL

SV *
cplxe(...)
CODE:
    switch (items) {
    case 0:
        RETVAL = newSVcx(aTHX_ 0);
        break;
    case 1:
        Perl_croak(aTHX_ "Math::Complex::XS->emake(arg1) not implemented yet");
    case 2:
        RETVAL = newSVcx(aTHX_ SvCx(aTHX_ ST(0)) * cexp(I * SvCx(aTHX_ ST(1))));
        break;
    default:
        Perl_croak(aTHX_ "Usage: Math::Complex::XS->make($module, $argument)");
    }
OUTPUT:
    RETVAL

SV *
_stringify(self, ...)
    SV *self
PREINIT:
    Cx c;
    SV *sre, *sim;
CODE:
    c = SvCxX(self);
    sre = sv_2mortal(newSVnv(creal(c)));
    sim = sv_2mortal(newSVnv(cimag(c)));
    RETVAL = newSVpvf("%s+%si", SvPV_nolen(sre), SvPV_nolen(sim));
OUTPUT:
    RETVAL

SV *
_plus(self, other, rev = &PL_sv_no)
    SV *self
    SV *other
    SV *rev
CODE:
    if (SvOK(rev))
        RETVAL = newSVcx(aTHX_ SvCxX(self) + SvCx(aTHX_ other));
    else {
        RETVAL = self;
        SvREFCNT_inc(RETVAL);
        SvCxX(self) += SvCx(aTHX_ other);
    }
OUTPUT:
    RETVAL

SV *
_minus(self, other, rev = &PL_sv_no)
    SV *self
    SV *other
    SV *rev
PREINIT:
    Cx b;
CODE:
    b = SvCx(aTHX_ other);
    if (SvOK(rev)) {
        Cx a = SvCxX(self);
        RETVAL = newSVcx(aTHX_ SvTRUE(rev) ? b - a : a - b);
    }
    else {
        RETVAL = self;
        SvREFCNT_inc(RETVAL);
        SvCxX(self) -= b;
    }
OUTPUT:
    RETVAL

SV *
_multiply(self, other, rev = &PL_sv_no)
    SV *self
    SV *other
    SV *rev
CODE:
    if (SvOK(rev))
        RETVAL = newSVcx(aTHX_ SvCxX(self) * SvCx(aTHX_ other));
    else {
        RETVAL = self;
        SvREFCNT_inc(RETVAL);
        SvCxX(self) *= SvCx(aTHX_ other);
    }
OUTPUT:
    RETVAL

SV *
_divide(self, other, rev = &PL_sv_no)
    SV *self
    SV *other
    SV *rev
CODE:
    if (SvOK(rev)) {
        Cx a, b;
        if (SvTRUE(rev)) {
            a = SvCx(aTHX_ other);
            b = SvCxX(self);
        }
        else {
            a = SvCxX(self);
            b = SvCx(aTHX_ other);
        }
        if (b == 0.0) Perl_croak(aTHX_ "Illegal division by zero");
        RETVAL = newSVcx(aTHX_ a / b);
    }
    else {
        Cx b = SvCx(aTHX_ other);
        if (b == 0.0) Perl_croak(aTHX_ "Illegal division by zero");
        RETVAL = self;
        SvREFCNT_inc(RETVAL);
        SvCxX(self) /= b;
    }
OUTPUT:
    RETVAL


SV *
_power(self, other, rev = &PL_sv_no)
    SV *self
    SV *other
    SV *rev
PREINIT:
    Cx a, b;
CODE:
    if (SvTRUE(rev)) {
        a = SvCx(aTHX_ other);
        b = SvCxX(self);
    }
    else {
        a = SvCxX(self);
        b = SvCx(aTHX_ other);
    }
    if ((a == 0.0) && (creal(b) <= 0.0)) Perl_croak(aTHX_ "Illegal division by zero");
    if (SvOK(rev))
        RETVAL = newSVcx(aTHX_ cpow(a, b));
    else {
        RETVAL = self;
        SvREFCNT_inc(RETVAL);
        SvCxX(self) = cpow(a, b);
    }
OUTPUT:
    RETVAL

int
_spaceship(self, other, rev = &PL_sv_no)
    SV *self
    SV *other
    SV *rev
PREINIT:
    Cx a, b;
CODE:
    if (SvTRUE(rev)) {
        a = SvCx(aTHX_ other);
        b = SvCxX(self);
    }
    else {
        a = SvCxX(self);
        b = SvCx(aTHX_ other);
    }
    RETVAL = ((creal(a) < creal(b)) ? -1 :
              (creal(a) > creal(b)) ?  1 :
              (cimag(a) < cimag(b)) ? -1 :
              (cimag(a) > cimag(b)) ?  1 :
                                       0 );
OUTPUT:
    RETVAL

SV *
_numeq(self, other, rev = &PL_sv_no)
    SV *self
    SV *other
    SV *rev = NO_INIT
CODE:
    RETVAL = ((SvCxX(self) == SvCx(aTHX_ other)) ? &PL_sv_yes : &PL_sv_no);
OUTPUT:
    RETVAL

SV *
_negate(self, other = NULL, rev = &PL_sv_no)
    SV *self
    SV *other = NO_INIT
    SV *rev = NO_INIT
CODE:
    RETVAL = newSVcx(aTHX_ -SvCvX(self));
OUTPUT:
    RETVAL

SV *
_conjugate(self,  other = NULL, rev = NULL)
    SV *self
    SV *other = NO_INIT
    SV *rev = NO_INIT
CODE:
    RETVAL = newSVcx(aTHX_ conj(SvCxX(self)));
OUTPUT:
    RETVAL

SV *
abs(self, other = NULL, rev = NULL )
    SV *self
    SV *other = NO_INIT
    SV *rev = NO_INIT
CODE:
    RETVAL = newSVnv(cabs(SvCxX(self)));
OUTPUT:
    RETVAL

NV
arg(self, theta = &PL_sv_undef)
    SV *self
    SV *theta
CODE:
    if (SvOK(theta)) {
        Cx *a = SvCx_only(aTHX_ self);
        *a = cabs(*a) * cexp(I * SvNV(theta));
        RETVAL = carg(*a);
    }
    else
        RETVAL = carg(SvCx(aTHX_ self));
OUTPUT:
    RETVAL

SV *
sqrt(self, other = NULL, rev = NULL)
    SV *self
    SV *other = NO_INIT
    SV *rev = NO_INIT
CODE:
    RETVAL = newSVcx(aTHX_ csqrt(SvCx(aTHX_ self)));
OUTPUT:
    RETVAL

SV *
cbrt(self)
    SV *self
CODE:
    RETVAL = newSVcx(aTHX_ cpow(SvCx(aTHX_ self), 1.0/3.0));
OUTPUT:
    RETVAL

NV
Re(self, rv = &PL_sv_undef)
    SV *self
    SV *rv
CODE:
    if (SvOK(rv)) {
        Cx *a = SvCx_only(aTHX_ self);
        *a = SvNV(rv) + cimag(*a) * I;
        RETVAL = creal(*a);
    }
    else
        RETVAL = creal(SvCx(aTHX_ self));
OUTPUT:
    RETVAL

NV
Im(self, rv = &PL_sv_undef)
    SV *self
    SV *rv
CODE:
    if (SvOK(rv)) {
        Cx *a = SvCx_only(aTHX_ self);
        *a = creal(*a) + SvNV(rv) * I;
        RETVAL = cimag(*a);
    }
    else
        RETVAL = cimag(SvCx(aTHX_ self));
OUTPUT:
    RETVAL

NV
rho(self, rv = &PL_sv_undef)
    SV *self
    SV *rv
CODE:
    if (SvOK(rv)) {
        Cx *a = SvCx_only(aTHX_ self);
        NV old = cabs(*a);
        if (a == 0)
            Perl_croak(aTHX_ "Illegal division by zero");
        *a *= SvNV(rv) / old;
        RETVAL = cimag(*a);
    }
    else
        RETVAL = cabs(SvCx(aTHX_ self));
OUTPUT:
    RETVAL

NV
theta(self, rv = &PL_sv_undef)
    SV *self
    SV *rv
CODE:
    if (SvOK(rv)) {
        Cx *a = SvCx_only(aTHX_ self);
        NV old = cabs(*a);
        *a = old * cexp(SvNV(rv) * I);
        RETVAL = carg(*a);
    }
    else
        RETVAL = carg(SvCx(aTHX_ self));
OUTPUT:
    RETVAL

Cx
log(a)
    Cx a
ALIAS:
    ln = 0
CODE:
    if (a == 0)
        Perl_croak(aTHX_ "Can't take log of 0");
    RETVAL = clog(a);
OUTPUT:
    RETVAL

Cx
log10(a)
    Cx a;
CODE:
    if (a == 0)
        Perl_croak(aTHX_ "Can't take log of 0");
    RETVAL = clog(a) / log(10);
OUTPUT:
    RETVAL

Cx
logn(a, b)
    Cx a
    Cx b
CODE:
    if ((a == 0) || (b == 0))
        Perl_croak(aTHX_ "Can't take log of 0");
    if (b == 1)
        Perl_croak(aTHX_ "Illegal division by zero");
    RETVAL = clog(a) / clog(b);
OUTPUT:
    RETVAL


MODULE = Math::Complex::XS		PACKAGE = Math::Complex::XS		PREFIX=c

Cx cexp(Cx a)

Cx csin(Cx a)

Cx ccos(Cx a)

Cx ctan(Cx a)

Cx cacos(Cx a)

Cx casin(Cx a)

Cx catan(Cx a)

Cx ccosh(Cx a)

Cx csinh(Cx a)

Cx ctanh(Cx a)

#define csec ccos
Cx_inv csec(Cx a)

#define ccsc csin
Cx_inv ccsc(Cx a)
ALIAS:
    cosec = 0

#define ccot ctan
Cx_inv ccot(Cx a)
ALIAS:
    cotan = 0

#define casec cacos
Cx casec(Cx_inv a)

#define cacsc casin
Cx cacsc(Cx_inv a)
ALIAS:
    acosec = 0

#define cacot catan
Cx cacot(Cx_inv a)

