.686
.model flat
extern _MessageBoxA@16: PROC
extern _ExitProcess@4: PROC
extern _GetSystemTime@4: PROC
extern _GetSystemInfo@4: PROC
public _szukaj_max,_liczba_przeciwna,_odejmij_jeden,_przestaw,_NWD,_obj_stozka_sc,_razy_32,_avg,_sprawdz_okresowosc,_aktualna_godzina,_plus_jeden,
_float_na_double,_liczba_procesow,_sortowanie

; 18,446,744,073,709,551,615
.data
tablica dword 4 dup(0)
trojka dword 3
zmienna dword 0
dana db 00h,00h,0F0h,0C0h
srednia dword 0
mianownik dword 0
licznik dword 0
dwie_dziesiate dword 0.2
minus_jeden dword -1.0
godzina byte 2 dup(0)
BIZNES word 8 dup(0)
mantysa dd 0
wykladnik dd 0
liczba_double dd 2 dup(0)
info dd 12 dup(0)
liczba_64 dq 0
mlodsza dd 0
starsza dd 0
najwiekszy dq 0
.code

_szukaj_max PROC	;szukanie najwiekszej liczby z 4 intow
	push ebp
	mov ebp,esp

	mov ecx,4 ;ile argumentow
	push ecx
	ptl:
	mov esi, [ebp+ecx*4+4];  ;4*ecx bo int 4bajtowy, +4 bo pierwszy argument znajduje sie w ebp+8, a nie ebp+4
	mov [tablica+4*ecx-4],esi ;4*ecx bo int 4bajtowy, -4 bo zapisywalem wczesniej indeksy 4,3,2,1 a teraz 3,2,1,0
	loop ptl
	
	pop ecx
	dec ecx
	mov edx,0
	ptl2:
	mov eax,[tablica+4*edx]
	cmp eax,[tablica+4*edx+4]
	jae pierwsza_wieksza
		mov eax,[tablica+4*edx+4]
		mov ebx,eax
	pierwsza_wieksza:
	mov ebx,eax
	inc edx
	loop ptl2
	pop ebp
	mov eax,ebx
	ret

_szukaj_max ENDP 

_liczba_przeciwna PROC
	push ebp
	mov ebp,esp
	push ebx

	mov ebx, [ebp+8]
	neg dword ptr [ebx]

	;wersja alternatywna(prostsza)
	;mov ebx, [ebp+8]
	;mov eax, [ebx]
	;neg eax
	;mov [ebx],eax

	pop ebx
	pop ebp
	ret
_liczba_przeciwna ENDP

_odejmij_jeden PROC
	push ebp
	mov ebp,esp
	push ebx
	push edx

	mov edx,[ebp+8]
	mov ebx,[edx]
	mov eax,[ebx]
	dec eax
	mov [ebx],eax

	pop edx
	pop ebx
	pop ebp
	ret
_odejmij_jeden ENDP

_przestaw PROC
	push ebp	
	mov ebp,esp
	pushad

	mov esi, [ebp + 8]
	mov edx, [ebp + 12]
	dec edx ;aby nie wyjsc poza tablice
	mov ecx,edx
	ptl:
		push ecx
		mov ecx,edx
		mov edi,0
		ptl2:
			mov eax,[esi+edi*4]
			mov ebx,[esi+edi*4+4]; +4 czyli nastepna liczba
			cmp ebx,eax
			jle nie_zamieniaj
			mov [esi+edi*4], ebx
			mov [esi+edi*4+4], eax

			nie_zamieniaj:
			inc edi
		loop ptl2
		pop ecx
	loop ptl
	
	popad	
	pop ebp
	ret
_przestaw ENDP

_NWD PROC
	 push ebp
    mov ebp,esp
    pushad
    mov ebx, [ebp + 8] ;a na stos
    mov eax, [ebp + 12] ;b na stos
    call fnwd
    mov ebx,eax
    mov esp,ebp
    pop ebp
    ret

    fnwd:
    push ebp
    mov ebp,esp

    cmp eax,ebx
    je end_recursion
    ja a_wieksze
    jb b_wieksze


    a_wieksze:
    sub eax,ebx
    call fnwd
    jmp koniec

    b_wieksze:
    sub ebx,eax
    call fnwd
    jmp koniec

    koniec:
    end_recursion:
    mov esp,ebp
    pop ebp
    ret

_NWD ENDP

_obj_stozka_sc PROC
	push ebp
	mov ebp,esp

	finit
	fld dword PTR [ebp+8]; st0 r
	fld dword PTR [ebp+8] ;drugie r
	fmulp ;r^2
	fld dword PTR [ebp+12] ;dwa razy R
	fld dword PTR [ebp+12] ;dwa razy R
	fmulp ;R^2
	fld dword PTR [ebp+8]
	fld dword PTR [ebp+12]
	fmulp ;Rr
	faddp ;Rr+R^2
	faddp ;(Rr+R^2)+r^2
	fldpi
	fild trojka
	fdivp st(1),st(0)
	fld dword PTR [ebp+16] ;laduje h
	fmulp ;(pi/3)*h
	fmulp ; h*(pi/3) * (Rr+R^2+r^2)

	pop ebp
	ret
_obj_stozka_sc ENDP

_razy_32 PROC
	push ebp
	mov ebp,esp
	pushad

	mov eax,[ebp+8]
	;mnozenie przez 32 to przesuwania o 5 bitow do przodu, bo 2^32=5
	;przesune wykladnik liczby w formacie float, tak zeby wynosil o 5 wiecej
	;np. liczba miala wykladnik 129, chcemy zeby miala 134
	;wykladnik to miejsce w ktorym stawiamy kropke, wiec jesli zwieksze go o 5
	;to pomnoze moja liczbe o 32
	;bit znaku - 1 bit
	;wykladnik - 8 bitow
	;mantysa  - 23 bitow

	ror eax,23 ;w rejestrze ax, bedzie moj wykladnik
	add al,5 ;dodanie 5 do wykladnika
	rol eax,23 ; powrot do orginalnego stanu

	mov [zmienna],eax ;zapisanie wyniku w pamieci
	fld zmienna ;zaladowanie na czubek koprocesora

	popad
	pop ebp
	ret

_razy_32 ENDP

_avg PROC
	push ebp
	mov ebp,esp
	pushad
	mov esi,[ebp+8]
	mov ecx,[ebp+12]

	mov edx,0
	fldz
	ptl:
	fld dword ptr [esi + edx]
	faddp
	add edx,4
	loop ptl
	fild dword ptr [ebp + 12]
	fdivp st(1), st(0)

	popad
	pop ebp
	ret
_avg ENDP

_sprawdz_okresowosc PROC
	;UWAGA! ZADANIE OSTRO POJEBANE
	push ebp
	mov ebp,esp
	pushad
	mov esi,[ebp+8]
	mov edx,0
	finit

	;obliczam ile jest elementow w tablicy
	mov ecx,0 ;w ecx bedzie ilosc elementow w tablicy
	licz_ilosc_elementow:
	mov ebx,[esi+edx*4]
	inc ecx ;zwiekszam licznik
	inc edx
	cmp ebx,0
	jne licz_ilosc_elementow
	dec ecx ;policzylem zero wiec odejmuje 1
	nop

	;obliczam srednia, czyli y z kreska
	push ecx ;liczba elementow
	push esi ;tablica
	call _avg
	add esp,8 ;dwa argumenty, wyrownanie stosu
	fst srednia ;zapisuje sobie wynik sredniej w przytulnym miejscu w pamieci
	nop
	;obliczam srednia czyli y z kreska
	
	mov edx,0
	finit ;resetuje sobie koprocesor dla przejrzystosci
	fldz
	push ecx ; zapamietuje ile elementow w glownej tablicy

	;lecimy z mianownikiem pepega
	licz_mianownik:
	fld dword ptr [esi+edx*4] ;y(t)
	fld srednia ;y z kreska
	fsubp st(1),st(0) ;pierwszy raz
	fld dword ptr [esi+edx*4] ;y(t)
	fld srednia ;y z kreska
	fsubp st(1),st(0) ;drugi raz
	fmulp ;podnosze wynik do 2 potegi
	faddp ;dodaje do sumy
	inc edx
	loop licz_mianownik
	fst mianownik ;zapisuje sobie wartosc mianownika w wygodnym miejscu w pamieci

	finit ;resetuje sobie koprocesor dla przejrzystosci
	;lecimy z licznikiem pepega
	;jesli t = k + 1, a musimy obliczyc y(t-k), to po wstawieniu y(k+1-k) = y(1)
	;obliczam y(1)- y z kreska
	fld dword ptr [esi]
	fld srednia
	fsubp st(1),st(0)
	fst licznik ;zapisuje sobie ta liczbe w pamieci

	pop ecx
	mov edx,20 ; startowy wspolczynnik k
	dec edx ; poniewaz pierwszy element w tablicy ma indeks 0
	;zaczynamy szukac wyniku ktory jest wiekszy niz 0.2, zwiekszajac wspolczynnik k
	szukaj:
	push ecx
	cmp ecx,edx
	je porazka
	mov ebx,edx
	sub ecx,edx
	licz_licznik:
	fld dword ptr [esi+ebx*4] ;y(t)
	fld srednia ;y z kreska
	fsubp st(1),st(0)
	fld licznik
	fmulp
	inc ebx
	faddp
	loop licz_licznik
	pop ecx
	inc edx
	fld mianownik
	fdivp st(1),st(0) ;licze rk
	fld dwie_dziesiate
	fcomi	st(0),st(1) ;czy aktualne rk jest wieksza od 0.2
	jc koniec ;jesli tak to konczymy
	jmp szukaj

	porazka:
	pop ecx
	fld minus_jeden

	koniec:
	popad
	pop ebp
	ret
_sprawdz_okresowosc ENDP

_aktualna_godzina PROC
    push ebp
    mov ebp,esp
    pushad

    push word ptr offset BIZNES
    call _GetSystemTime@4
    mov ebx,0
    mov bx, [BIZNES+8]

    mov edx,0
    mov eax,ebx
    mov ebx,10
    div ebx
    add eax,30h
    add edx,30h

    mov eax, [ebp+8]
    mov ebx,[eax]
    mov [ebx],al
    mov [ebx+1],dl
    nop

    popad
    pop ebp
    ret
_aktualna_godzina ENDP

_plus_jeden PROC
push ebp
mov ebp,esp
push ebx
finit
mov eax,[ebp+8] ; w eax argument float
shr eax,23 ; w eax wykladnik
mov wykladnik,eax
cmp eax,127
jae wieksza_od_1

; rozpatrujemy liczbe mniejsza od jednosci
mov eax,[ebp+8] ; odczyt arguemntu
shl eax,9 ; wydobycie mantysy
shr eax,9
bts eax,23 ; ustawenie jawnej jedynki
mov ecx,127 ; obliczamy roznice wykladnikow

sub ecx,wykladnik
shr eax,cl ; przesuniecie liczby do wykladnika

; dodajemy 1.00, ktore nastepnie usuwamy jako niejawna jedynka

mov ecx,127 ; wykladnik wynosi 127
shl ecx,23 ; wpisujemy go na wlasciwa pozycje

or eax,ecx ; w eax wynik

jmp koniec

wieksza_od_1:

mov eax,0 ; budujemy mantyse 1 w formacie float
bts eax,23 ;JAKUB BY WYJEBAL
mov ecx,wykladnik ; roznica wykladnikow
sub ecx,127
shr eax,cl ; przesuwamy jedynke TUTAJ ZAJEBAC SHL
mov ebx,[ebp+8] ; odczyt arguemntu float
shl ebx,9 ; wydobycie mantysy
shr ebx,9 
bts ebx,23 ; ustawenie jawnej jedynki
add eax,ebx ; dodajemy 1 do liczby
bt eax,23 ; sprawdzamy czy wystapilo przeniesienie

jnc bez_korekcji
btr eax, 23
;shr eax,1 ;smierdzi
;add wykladnik,1

bez_korekcji:

; mamy mantyse

mov ebx,wykladnik
shl ebx,23
or eax,ebx

koniec:

push eax ; przeniesienie wyniku na wierzcholek stosu koprocesora
fld dword ptr [esp]
add esp,4
pop ebx
pop ebp

ret
_plus_jeden ENDP

_float_na_double PROC
	push ebp
	mov ebp,esp
	pushad
	finit
	mov esi,[ebp+8] 

	;11 bitow wykladnika
	;52 bitowa mantysa
	mov ebx,esi ;chce wydobyc wykladnik
	shl ebx,1
	shr ebx,24 ;wykladnik float w ebx
	sub ebx,127
	mov eax,1023
	add eax,ebx
	mov ebx,eax ;wykladnik doublowy w ebx

	;buduje liczbe 64bitowa, znajdzie sie w rejestrach edx:eax
	mov eax,0
	mov edx,0
	;sprawdzam bit znaku
	bt esi,31
	jnc dodatnia
	bts edx,11 ;ustawilem bit znaku w nowej liczbie, 11, bo mantysa zabiera 11 bitow, 
	;wiec chce ustaic bit znaku na 12 bicie
	dodatnia:
	add edx,ebx
	;shl eax,20 ;w eax bit znaku i 11 bitowy wykladnik

	;wydobywam mantyse
	mov ebx,esi
	shl ebx,9
	;mantysa w ebx
	mov eax,ebx ;cala mantysa w eax
	
	mov ecx,20 ;20 musze przesuwac eax o 20 i edx o 20
	ptl:
	rcl eax,1
	rcl edx,1
	loop ptl

	mov liczba_double,eax
	mov [liczba_double+4],edx
	fld qword ptr liczba_double

	popad
	pop ebp
	ret
_float_na_double ENDP

_liczba_procesow PROC
	push ebp
	mov ebp,esp
	
	push dword ptr offset info
	call _GetSystemInfo@4
	mov eax,[info+20] ;jak sie pominie structa w structcie to to +20 jakos wychodzi
	nop

	pop ebp
	ret
_liczba_procesow ENDP

_sortowanie PROC
	push ebp
	mov ebp,esp
	pushad
	mov esi,[ebp+8]
	mov ecx,[ebp+12]
	ptl2:
		push ecx
		mov ecx,[ebp+12]
		mov edi,0
		ptl:
		mov eax,[esi+edi*4] ;mlodsza czesc liczby
		mov edx,[esi+edi*4 + 4] ;starsza czesc liczby
	
		mov ebx,dword ptr najwiekszy
		cmp edx,ebx
		jne idz_dalej
		mov ebx,dword ptr najwiekszy+4
		cmp edx,ebx
		jb idz_dalej
		mov dword ptr najwiekszy,edx
		mov dword ptr [najwiekszy+4],eax
		idz_dalej:

		mov ebx,[esi+edi*4 + 8] ;pobieram najmlodsza czesc nastepnej liczby
		mov mlodsza, ebx
		mov ebx,[esi+edi*4 + 12] ;pobieram najstarsza czesc nastepnej liczby
		mov starsza,ebx

		cmp edx,starsza ;porownuje najstarsze czesci liczb
		je porownaj_mlodsze
		ja zamien
		jb dalej

		porownaj_mlodsze:
		cmp eax,mlodsza
		jbe dalej

		zamien:
		mov ebx,mlodsza
		mov [esi+edi*4],ebx
		mov [esi+edi*4 + 8],eax ;zamieniam mlodsze czesci liczb

		mov ebx,starsza
		mov [esi+edi*4 + 12],edx
		mov [esi+edi*4 + 4],ebx ;zamieniam starsze czesci liczb

		dalej:

		add edi,2
		loop ptl
		pop ecx
	loop ptl2
	popad
	mov eax,dword ptr [najwiekszy+4]
	mov edx,dword ptr najwiekszy
	pop ebp
	ret
_sortowanie ENDP


END