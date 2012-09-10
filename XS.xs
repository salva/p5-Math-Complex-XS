#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <complex.h>

typedef struct st_cx {
    complex double c;
    unsigned char flags;
} cx;

static char bad_internals_error[] = "Internal error: bad representation for Math::Complex::XS code";

#define croak_bad_internals() Perl_croak(aTHX_ bad_internals_error);

#define CXLEN (sizeof(cx))
#define SVt_Cx SVt_PV

static SV *
new_scx(pTHX) {
    SV *scx = newSV(CXLEN + 1);
    SvPOK_on(scx);
    SvCUR_set(scx, CXLEN);
    return scx;
}

#define SvCxY(sv)         (*((cx*)SvPVX(sv)))
#define SvCxY_c(sv)       (((cx*)SvPVX(sv))->c)
#define SvCxY_flags(sv) = (((cx*)SvPVX(sv))->flags)
static SV *
newSVcx(pTHX_ double complex c) {
    SV *scx = new_scx(aTHX);
    SvCxY_c(scx) = c;
    SvCxY_flags(scx) = 0;
    SV *sv = newRV_noinc(scx);
    sv_bless(sv, gv_stashpvs("Math::Complex::XS", TRUE));
    return sv;
}

static int
SvCxOK(pTHX_ SV *sv) {
    if (SvROK(sv)) {
        SV *scx = SvROK(sv);
        return (scx && (SvTYPE(scx) >= SVt_Cx) && sv_isa(sv, "Math::Complex::XS"));
    }
    return 0;
}

static SV *
SvSCx(pTHX_ SV *sv) {
    if (SvRV(sv)) {
        SV *scx = SvRV(sv);
        if (SvPOK(scx) && (SvCUR(scx) == CXLEN))
            return scx;
    }
    croak_bad_internals();
}

#define SvCxx(sv) SvCxY(SvSCx(aTHX_ sv))

static complex double
SvCx(pTHX_ SV *sv) {
    if (SvROK(sv)) {
        SV *scx = SvRV(sv);
        if (scx && SvOBJECT(scx)) {
            char const *classname = HvNAME_get(SvSTASH(scx));
            if (strcmp(classname, "Math::Complex::XS") == 0) {
                if (!SvPOK(scx) || (SvCUR(scx) != CXLEN))
                    croak_bad_internals();
            }
        }
    }
}



MODULE = Math::Complex::XS		PACKAGE = Math::Complex::XS		

