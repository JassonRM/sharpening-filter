TITLE Reading a File(ReadFile.asm)
; Opens, reads, and displays a text file using
; procedures from Irvine32.lib.
INCLUDE Irvine32.inc
INCLUDE macros.inc
BUFFER_SIZE = 5000004
.data
sharpenKernel BYTE 0, -1, 0, -1, 5, -1, 0, -1, 0
kernel DWORD ?
sides BYTE 4 DUP(0)
buffer BYTE BUFFER_SIZE DUP(? )
outputBuffer BYTE BUFFER_SIZE DUP(? )
filename BYTE "image.bin", 0
sharpenedFile BYTE "sharpened.bin", 0
overSharpenedFile BYTE "oversharpened.bin", 0
outputFile DWORD ?
fileHandle HANDLE ?
outputHandle HANDLE ?
imageWidth DWORD ?
imageHeight DWORD ?
imageSize DWORD ?
.code
main PROC
; Open the file for input.
mov edx, OFFSET filename
call OpenInputFile
mov fileHandle, eax
; Check for errors.
cmp eax, INVALID_HANDLE_VALUE; check for error opening input file
jne file_ok;
mWrite <"Cannot open input file", 0dh, 0ah>
jmp quit
file_ok :
; Read the file into a buffer.
mov edx, OFFSET buffer
mov ecx, BUFFER_SIZE
call ReadFromFile
jnc check_buffer_size; check for error reading the file
mWrite "Error reading file. "
call WriteWindowsMsg
jmp close_file
check_buffer_size :
cmp eax, BUFFER_SIZE; checks if buffer is large enough
jb buf_size_ok
mWrite <"Error: Buffer too small for the file", 0dh, 0ah>
jmp quit

buf_size_ok :
mov eax, 0
mov ebx, 0
mov ah, buffer[0]
mov al, buffer[1]
mov bh, buffer[2]
mov bl, buffer[3]
mov imageWidth, eax
mov imageHeight, ebx
mul ebx
mov ecx, eax
mov imageSize, ecx
mov esi, 4
mov kernel, OFFSET sharpenKernel
mov outputFile, OFFSET sharpenedFile
jmp imageProcessing

oversharpen:
mov esi, 4
mov ecx, imageSize
mov outputFile, OFFSET overSharpenedFile

copy:
mov al, outputBuffer[ecx]
mov buffer[ecx], al
loop copy
mov ecx, imageSize

imageProcessing :
call checkSides

mov dx, 0
; Multiply origin
mov ax, 4
call applyKernel

; Multiply top pixel
test sides[0], 1
jz skip_top1
mov ax, 1
call applyKernel

; Multiply top-left pixel
test sides[1], 1
jz skip_left
mov ax, 0
call applyKernel

skip_top1 :
; Multiply left pixel
mov ax, 3
call applyKernel

; Multiply bottom-left pixel
test sides[3], 1
jz skip_bottom1
mov ax, 6
call applyKernel

skip_left:
skip_bottom1:
; Multiply top-right pixel
test sides[0], 1
jz skip_top2
test sides[2], 1
jz skip_right
mov ax, 2
call applyKernel

skip_top2:
; Multiply right pixel
mov ax, 5
call applyKernel

; Multiply bottom-right pixel
test sides[3], 1
jz skip_bottom2
mov ax, 8
call applyKernel

skip_right:
; Multiply bottom pixel
mov ax, 7
call applyKernel

skip_bottom2:
; Check for out of range pixels
test dx, dx
js fix_black
cmp dx, 255
ja fix_white
jmp end_loop

fix_black:
mov dx, 0
jmp end_loop

fix_white:
mov dx, 255

end_loop:
mov ebx, esi
sub ebx, 4
mov outputBuffer[ebx], dl
add esi, TYPE BYTE
dec ecx
jnz imageProcessing

; Open the output file for output.
mov edx, outputFile
call CreateOutputFile
mov outputHandle, eax
; Check for errors.
cmp eax, INVALID_HANDLE_VALUE; check for error creating output file
jne outputFile_ok
mWrite <"Cannot open output file", 0dh, 0ah>
jmp quit

outputFile_ok :
mov eax, outputHandle
mov edx, OFFSET outputBuffer
mov ecx, BUFFER_SIZE
call WriteToFile

close_file :
mov eax, outputHandle
call CloseFile

; Check current file
mov eax, OFFSET sharpenedFile
cmp eax, outputFile
je oversharpen

quit :
exit
main ENDP



; esi contiene el indice, ax contiene el indice del kernel y dx contiene la suma actual 
applyKernel PROC
push ebx
push ecx
mov ebx, esi
cmp al, 0
jz zero
cmp al, 1
jz one
cmp al, 2
jz two
cmp al, 3
jz three
cmp al, 4
jz finish
cmp al, 5
jz five
cmp al, 6
jz six
cmp al, 7
jz seven
cmp al, 8
jz eight
jmp invalid

zero:
sub ebx, imageWidth
dec ebx
jmp finish

one:
sub ebx, imageWidth
jmp finish

two:
sub ebx, imageWidth
inc ebx
jmp finish

three:
dec ebx
jmp finish

five:
inc ebx
jmp finish

six:
add ebx, imageWidth
dec ebx
jmp finish

seven:
add ebx, imageWidth
jmp finish

eight:
add ebx, imageWidth
inc ebx
jmp finish

finish:
mov cx, ax; Copy kernel index to cx
push dx; Save dx
movzx ax, buffer[ebx]; Load the pixel to ax with zero extension
mov ebx, kernel; Load the kernel pointer
add bx, cx; Add the kernel offset
mov cl, [ebx]; Load the kernel value
movsx bx, cl; Extend the kernel value to 16 bit
imul bx; Multiply pixel by kernel
pop dx; Restore dx
add dx, ax
pop ecx
pop ebx

invalid:
ret
applyKernel ENDP

; Checks if current pixel esi is an edge
checkSides PROC
push eax
push ebx
push edx

; Revisar si hay pixeles arriba
mov ebx, esi
sub ebx, 4
cmp ebx, imageWidth
jb is_top
mov sides[0], 1
jmp not_top

is_top :
mov sides[0], 0

not_top :
; Revisar si hay pixeles a la izquierda
push dx
mov eax, esi
sub eax, 4
mov edx, 0
div imageWidth
cmp edx, 0
pop dx
je is_left
mov sides[1], 1
jmp not_left

is_left :
mov sides[1], 0

not_left :
; Revisar si hay pixeles a la derecha
push dx
mov eax, esi
sub eax, 4
mov edx, 0
div imageWidth
mov eax, imageWidth
dec eax
cmp edx, eax
pop dx
je is_right
mov sides[2], 1
jmp not_right

is_right:
mov sides[2], 0

not_right :
; Revisar si hay pixeles abajo
mov ebx, esi
sub ebx, 4
add ebx, imageWidth
cmp ebx, imageSize
jae is_bottom
mov sides[3], 1
jmp not_bottom

is_bottom :
mov sides[3], 0

not_bottom :
pop edx
pop ebx
pop eax
ret
checkSides ENDP
END main