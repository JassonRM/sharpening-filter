TITLE Reading a File(ReadFile.asm)
; Opens, reads, and displays a text file using
; procedures from Irvine32.lib.
INCLUDE Irvine32.inc
INCLUDE macros.inc
BUFFER_SIZE = 500000
.data
buffer BYTE BUFFER_SIZE DUP(? )
sharpened BYTE BUFFER_SIZE DUP(? )
overSharpened BYTE BUFFER_SIZE DUP(? )
filename BYTE "image.bin", 0
sharpenedFile BYTE "sharpened.bin", 0
overSharpenedFile Byte "oversharpened.bin", 0
fileHandle HANDLE ?
sharpenedHandle HANDLE ?
overSharpenedHandle HANDLE ?
imageWidth DWORD 615
imageHeight DWORD 446
.code
main PROC
; Open the file for input.
mov edx, OFFSET filename
call OpenInputFile
mov fileHandle, eax
; Check for errors.
cmp eax, INVALID_HANDLE_VALUE; error opening file ?
jne file_ok; no: skip
mWrite <"Cannot open input file", 0dh, 0ah>
jmp quit;and quit
file_ok :
; Read the file into a buffer.
mov edx, OFFSET buffer
mov ecx, BUFFER_SIZE
call ReadFromFile
jnc check_buffer_size; error reading ?
mWrite "Error reading file. "; yes: show error message
call WriteWindowsMsg
jmp close_file
check_buffer_size :
cmp eax, BUFFER_SIZE; buffer large enough ?
jb buf_size_ok; yes
mWrite <"Error: Buffer too small for the file", 0dh, 0ah>
jmp quit ;and quit

buf_size_ok :
mov esi, 0
mov eax, imageWidth
mul imageHeight
mov ecx, eax

L1 :
mov al, buffer[esi]
add al, 20
mov sharpened[esi], al
add esi, TYPE BYTE
LOOP L1

; Open the sharpened file for output.
mov edx, OFFSET sharpenedFile
call CreateOutputFile
mov sharpenedHandle, eax
; Check for errors.
cmp eax, INVALID_HANDLE_VALUE; error creating file ?
jne sharpenedFile_ok; no: skip
mWrite <"Cannot open sharpened file", 0dh, 0ah>
jmp quit;and quit

sharpenedFile_ok :
mov eax, sharpenedHandle
mov edx, OFFSET sharpened
mov ecx, BUFFER_SIZE
call WriteToFile

close_file :
mov eax, fileHandle
call CloseFile
quit :
exit
main ENDP
END main
