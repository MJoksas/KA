; Uzduoties salyga: programa pagal ivesta teksta pakeicia tarpu
;					simbolius pries tai esanciu simboliu
; Atliko: Martynas Joksas

.model small
.stack 100h
	 
.data
	request		db 'Programa ivestoje eiluteje visus tarpo simbolius pakeicia pries juos einanciu simbobliu (jei tarpas pradzioje, paliekamas tarpas).', 0Dh, 0Ah, 'Iveskite simboliu eilute:', 0Dh, 0Ah, '$'
	result    	db 0Dh, 0Ah, 'Rezultatas:', 0Dh, 0Ah, '$'
	space		db ' (tarpu: ', '$'
	buffer		db 100 ; cia skaitysim eilute
	hex db "0123456789ABCDEF"
	hexnum db 0, 0, 0

.code
 
start:
	MOV ax, @data                   ; perkelti data i registra ax
	MOV ds, ax                      ; perkelti ax (data) i data segmenta
	 
	; Isvesti uzklausa
	MOV ah, 09h
	MOV dx, offset request
	int 21h

	; skaityti eilute
	MOV dx, offset buffer           ; skaityti i buffer offseta 
	MOV ah, 0Ah                     ; eilutes skaitymo subprograma
	INT 21h                         ; dos'o INTeruptas

	; kartoti
	MOV si, offset buffer           ; priskirti source index'ui bufferio koordinates
	INC si                          ; pridedam 1 prie si , nes pirmas kiek simboliu ish viso
	MOV bh, [si]                    ; idedam i bh kiek simboliu is viso
	INC si                          ; pereiname prie pacio simbolio
	
	; isvesti:	
	MOV ah, 09h
	MOV dx, offset result
	INT 21h

	MOV bl, ' '						; begin value

	MOV cl, bh						; loop darysim tiek, kiek yra tekste simboliu
	MOV ch, 0
	MOV bh, 00h	
				
; 1. imsime simboli
; 2. eisime prie kito simbolio
; 3. jei tarpas - spausdinsime pries tai buvusi simboli
; 4. jei ne tarpas - tai pakeisime registro reiksme nauja
; 5. isspausdinsime tarpu kieki

char:
	LODSB                        	; imti is es:si stringo dali ir dedame i al 
	CMP al, 0dh                     ; jei char 0
	JZ ending                   	; tai sokame i klaida 
	
	CMP al, ' '
	JE putLetter					; if yes, jump to putLetter
	mov bl, al						; put current symbol to bl
_1:	 
	MOV ah, 2                    	; isvedimui vieno simbolio
	MOV dl, al                    	; i dl padeti simboli is al
	INT 21h                        	; dos'o INTeruptas
	LOOP char

	JMP ending

putLetter:
	MOV al, bl
	INC bh
	JMP _1	
	 
ending:
	; isvesti kiek tarpu (bh registre)
	MOV ah, 09h
	MOV dx, offset space
	INT 21h
		
	MOV  al, bh					; i al pasidedam skaiciu, kuri spausdinsim																																			; source: http://stackoverflow.com/questions/34254461/assembly-basics-output-register-value
	AAM							; Ascii adjust for multipliation : ah:=al div 10; al:=al mod 10
	ADD  ax, "00"				; pavercia desimtainiu skaiciu
	XCHG al, ah					; sukeicia registro baitus vietomis
	
	MOV  dx, ax					
	MOV  ah, 02h				; int 21,02 spausdina ekrane dl
	INT  21h

	MOV  dl, dh					; isspausdinam ir dh				
	INT  21h

	;;
	;;


	MOV ah, 02h			
	MOV dl, ')'						; skliausto pabaigos simbolis
	INT 21h
	MOV ax, 4c00h 					; griztame i dos'a
	INT 21h                        	; dos'o INTeruptas
	 
end start