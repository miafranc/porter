%{
#include <iostream>
using namespace std;
%}

%option noyywrap

%x STEP0
%x STEP1a STEP1b STEP1b1 STEP1b2 STEP1b3 STEP1c STEP1D STEP1E 
%x STEP2 STEP21 STEP22 STEP23 STEP24 STEP25 STEP26 STEP27 STEP28 STEP29 STEP291 STEP292 STEP293
%x STEP3 STEP31 STEP32 STEP33 STEP34 STEP35
%x STEP4 STEP41 STEP42 STEP43 STEP44 STEP45
%x STEP5a STEP5a1 STEP5b
%x STEP6

%x STEP100 STEP101

C (([a-z]{-}[aeiouy])*y|([a-z]{-}[aeiouy])+)

Ve [aeiou]+
VbC ([aeiou]*y|[aeiou]+)

W [a-z]
M_ONE {VbC}?{C}({VbC}{C}|{Ve})
M_GT_ZERO {VbC}?(({C}{VbC})+{C}|({C}{VbC})*{C}{Ve})
M_GT_ONE {VbC}?(({C}{VbC})+{C}{Ve}|({C}{VbC}){2,}{C})

%%

<STEP0>{W}* {
	char *s = strdup(yytext);
	// Reversing the token:
	for (int i = 0; i < yyleng; ++i)
		unput(s[i]);
	delete s;
	if (yyleng <= 2)
		BEGIN(STEP6);
	else
		BEGIN(STEP1a);
}

<STEP1a>(sess|sei){W}* { yyless(2); BEGIN(STEP1b);
/* SSES -> SS; IES  -> I */ }

<STEP1a>ss{W}* { yyless(0); BEGIN(STEP1b);
/* SS -> SS */ }

<STEP1a>s{W}* { yyless(1); BEGIN(STEP1b);
/* S -> */ }

<STEP1a>{W}* { yyless(0); BEGIN(STEP1b); }

<STEP1b>dee{W}* { yyless(0); BEGIN(STEP1b1); }

<STEP1b>gni{W}* { yyless(0); BEGIN(STEP1b2); }

<STEP1b>de{W}* { yyless(0); BEGIN(STEP1b3); }

<STEP1b1>dee{M_GT_ZERO} { yyless(1); BEGIN(STEP1c);
/* (m>0) EED -> EE */ }

<STEP1b2>gni{W}*({Ve}|{VbC}{C}) { yyless(3); BEGIN(STEP1D);
/* (*v*) ING -> */ }

<STEP1b3>de{W}*({Ve}|{VbC}{C}) { yyless(2); BEGIN(STEP1D);
/* (*v*) ED -> */ }

<STEP1b1,STEP1b2,STEP1b3,STEP1b>{W}* { yyless(0); BEGIN(STEP1c); }

<STEP1D>(ta|lb|zi){W}* { yyless(0); unput('e'); BEGIN(STEP1c);
/*AT -> ATE; BL -> BLE; IZ -> IZE*/ }

<STEP1D>{C}{W}* {
	if (yytext[0] == yytext[1] && yytext[0] != 'l' && yytext[0] != 's' && yytext[0] != 'z') {
		yyless(1);
		BEGIN(STEP1c);
	} else {
		yyless(0);
		BEGIN(STEP1E);
	}
/* (*d and not (*L or *S or *Z)) -> single letter */}

<STEP1D,STEP1E>([a-z]{-}[aeiouwxy])[aeiouy]{C} { yyless(0); unput('e'); BEGIN(STEP1c);
/* (m=1 and *o) -> E */ }

<STEP1D,STEP1E>{W}* { yyless(0); BEGIN(STEP1c); }

<STEP1c>y{W}*({Ve}|{VbC}{C}) { yyless(1); unput('i'); BEGIN(STEP2);
/* (*v*) Y -> I */ }

<STEP1c>{W}* { yyless(0); BEGIN(STEP2); }

<STEP2>(lanoita|noitazi){W}* { yyless(0); BEGIN(STEP21); }

<STEP21>(lanoita|noitazi){M_GT_ZERO} { yyless(5); unput('e'); BEGIN(STEP3); //7
/* (m>0) ATIONAL -> ATE; (m>0) IZATION -> IZE */ }

<STEP2>(ssenevi|ssenluf|ssensou){W}* { yyless(0); BEGIN(STEP22); }

<STEP22>(ssenevi|ssenluf|ssensou){M_GT_ZERO} { yyless(4); BEGIN(STEP3); //7
/* (m>0) IVENESS -> IVE; (m>0) FULNESS -> FUL; (m>0) OUSNESS -> OUS */ }

<STEP2>(lanoit|ilsuo|iltne){W}* { yyless(0); BEGIN(STEP23); }

<STEP23>(lanoit|ilsuo|iltne){M_GT_ZERO} { yyless(2); BEGIN(STEP3); //6
/* (m>0) TIONAL -> TION; (m>0) OUSLI -> OUS; (m>0) ENTLI -> ENT */ }

<STEP2>itilib{W}* { yyless(0); BEGIN(STEP24); }

<STEP24>itilib{M_GT_ZERO} { yyless(5); unput('l'); unput('e'); BEGIN(STEP3); //6
/* (m>0) BILITI -> BLE */ }

<STEP2>(noita|itivi){W}* { yyless(0); BEGIN(STEP25); }

<STEP25>(noita|itivi){M_GT_ZERO} { yyless(3); unput('e'); BEGIN(STEP3); //5
/* (m>0) ATION -> ATE; (m>0) IVITI -> IVE */ }

<STEP2>(msila|itila){W}* { yyless(0); BEGIN(STEP26); }

<STEP26>(msila|itila){M_GT_ZERO} { yyless(3); BEGIN(STEP3); //5
/* (m>0) ALISM -> AL; (m>0) ALITI -> AL */ }

<STEP2>(icne|icna|igol){W}* { yyless(0); BEGIN(STEP27); }

<STEP27>(icne|icna|igol){M_GT_ZERO} { yyless(1); unput('e'); BEGIN(STEP3); //4
/* (m>0) ENCI -> ENCE; (m>0) ANCI -> ANCE; extra: (m>0) logi -> log */ }

<STEP2>rezi{W}* { yyless(0); BEGIN(STEP28); }

<STEP28>rezi{M_GT_ZERO} { yyless(1); BEGIN(STEP3);
/* (m>0) IZER -> IZE */ }

<STEP2>illa{W}* { yyless(0); BEGIN(STEP29); }

<STEP29>illa{M_GT_ZERO} { yyless(2); BEGIN(STEP3); //4
/* (m>0) ALLI -> AL */ }

<STEP2>rota{W}* { yyless(0); BEGIN(STEP291); }

<STEP291>rota{M_GT_ZERO} { yyless(2); unput('e'); BEGIN(STEP3); //4
/* (m>0) ATOR -> ATE */ }

<STEP2>ilb{W}* { yyless(0); BEGIN(STEP292); }

<STEP292>ilb{M_GT_ZERO} { yyless(1); unput('e'); BEGIN(STEP3);
/* (m>0) bli -> ble (instead of (m>0) abli -> able)) */ }

<STEP2>ile{W}* { yyless(0); BEGIN(STEP293); }

<STEP293>ile{M_GT_ZERO} { yyless(2); BEGIN(STEP3);
/* (m>0) ELI -> E */ }

<STEP21,STEP22,STEP23,STEP24,STEP25,STEP26,STEP27,STEP28,STEP29,STEP291,STEP292,STEP293,STEP2>{W}* { yyless(0); BEGIN(STEP3); }

<STEP3>(etaci|ezila|itici){W}* { yyless(0); BEGIN(STEP31); }

<STEP31>(etaci|ezila|itici){M_GT_ZERO} { yyless(3); BEGIN(STEP4); //5
/* (m>0) ICATE -> IC; (m>0) ALIZE -> AL; (m>0) ICITI -> IC */ }

<STEP3>evita{W}* { yyless(0); BEGIN(STEP32); }

<STEP32>evita{M_GT_ZERO} { yyless(5); BEGIN(STEP4); //5
/* (m>0) ATIVE -> */ }

<STEP3>laci{W}* { yyless(0); BEGIN(STEP33); }

<STEP33>laci{M_GT_ZERO} { yyless(2); BEGIN(STEP4); //4
/* (m>0) ICAL -> IC */ }

<STEP3>ssen{W}* { yyless(0); BEGIN(STEP34); }

<STEP34>ssen{M_GT_ZERO} { yyless(4); BEGIN(STEP4); //4
/* (m>0) NESS -> */ }

<STEP3>(luf){W}* { yyless(0); BEGIN(STEP35); }

<STEP35>(luf){M_GT_ZERO} { yyless(3); BEGIN(STEP4);
/* (m>0) FUL -> */ }

<STEP31,STEP32,STEP33,STEP34,STEP35,STEP3>{W}* { yyless(0); BEGIN(STEP4); }

<STEP4>tneme{W}* { yyless(0); BEGIN(STEP41); }

<STEP41>tneme{M_GT_ONE} { yyless(5); BEGIN(STEP5a); //5
/* (m>1) EMENT -> */ }

<STEP4>(ecna|ecne|elba|elbi|tnem){W}* { yyless(0); BEGIN(STEP42); }

<STEP42>(ecna|ecne|elba|elbi|tnem){M_GT_ONE} { yyless(4); BEGIN(STEP5a); //4
/* (m>1) ANCE -> ; (m>1) ENCE -> ; (m>1) ABLE -> ; (m>1) IBLE -> ;(m>1) MENT -> */ }

<STEP4>(tna|tne|msi|eta|iti|suo|evi|ezi){W}* { yyless(0); BEGIN(STEP43); }

<STEP43>(tna|tne|msi|eta|iti|suo|evi|ezi){M_GT_ONE} { yyless(3); BEGIN(STEP5a);
/* (m>1) ANT -> ; (m>1) ENT -> ; (m>1) ISM -> ; (m>1) ATE -> ; (m>1) ITI -> ; (m>1) OUS -> ; (m>1) IVE -> ; (m>1) IZE -> */ }

<STEP4>noi{W}* { yyless(0); BEGIN(STEP44); }

<STEP44>noi[st]{C}?{VbC}({C}{VbC})*{C}({Ve}|{VbC}{C}) { yyless(3); BEGIN(STEP5a);
/* (m>1 and (*S or *T)) ION -> */ }

<STEP4>(la|re|ci|uo){W}* { yyless(0); BEGIN(STEP45); }

<STEP45>(la|re|ci|uo){M_GT_ONE} { yyless(2); BEGIN(STEP5a);
/* (m>1) AL -> ; (m>1) ER -> ; (m>1) IC -> ; (m>1) OU -> */ }

<STEP41,STEP42,STEP43,STEP44,STEP45,STEP4>{W}* { yyless(0); BEGIN(STEP5a); }

<STEP5a>e{M_GT_ONE} { yyless(1); BEGIN(STEP5b);
/* (m>1) E -> */ }

<STEP5a>e{M_ONE} { yyless(0); BEGIN(STEP5a1);
/* (m=1 and not *o) E -> ; part "m=1" */ }

<STEP5a>{W}* { yyless(0); BEGIN(STEP5b); }

<STEP5a1>e([a-z]{-}[aeiouwxy])[aeiouy]{C}{W}* { yyless(0); BEGIN(STEP5b);
/* (m=1 and not *o) E -> ; part "*o" */ }

<STEP5a1>{W}* { yyless(1); BEGIN(STEP5b);
/* (m=1 and not *o) E -> ; part "not *o" */ }

<STEP5b>ll{C}?{VbC}({C}{VbC})*{C}({Ve}|{VbC}{C}) { yyless(1); BEGIN(STEP6);
/*(m > 1 and *d and *L) -> single letter*/ }

<STEP5b>{W}* { yyless(0); BEGIN(STEP6); }

<STEP6>{W}* {
	char *s = strdup(yytext);
	// Reversing the token:
	for (int i = 0; i < yyleng; ++i) {
		cout << s[yyleng-1-i];
	}
	cout << endl;
}

<STEP6>[\n\r]+ { BEGIN(STEP0); }

%%

int main() {
	BEGIN(STEP0);
	yylex();
}
