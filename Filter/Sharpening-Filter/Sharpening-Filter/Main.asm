.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

.data
myName BYTE "Jasson", 0
nameLen = ($ - myName) - 1

.code
main PROC
	mov ecx, nameLen
	mov esi, 0

	StackIt:
		movzx eax, myName[esi]
		push eax
		inc esi
		loop StackIt

	mov ecx, nameLen
	mov esi, 0

	PopIt:
		pop eax
		mov myName[esi], al
		inc esi
		loop PopIt

	INVOKE ExitProcess, 0
main ENDP
END main