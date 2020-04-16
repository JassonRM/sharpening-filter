import cv2
import numpy
import os
import time
from tkinter import filedialog
from tkinter import messagebox

executing = True
while executing:
    # Open original image and convert to grayscale
    filename = filedialog.askopenfilename(initialdir = "...",title = "Select image",filetypes = (("Images","*.jpg;*.jpeg;*.jpe;*.bmp;*.dib;*.png;*.tiff;*.tif"),))
    if filename:
        original = cv2.imread(filename)
        image = cv2.cvtColor(original, cv2.COLOR_BGR2GRAY)

        # Get size of image
        imageWidth = image.shape[1] #Get image width
        imageHeight = image.shape[0] #Get image height

        if imageWidth * imageHeight > 5000000:
            messagebox.showerror("Error", "La resolución de la imagen es muy alta, disminuya su resolución para poder procesarla.")
        else:
            # Show original image
            cv2.imshow("Grayscale", image)

            # Save binary image
            file = open('image.bin', 'wb')
            size = [imageWidth // 256, imageWidth % 256, imageHeight // 256, imageHeight % 256]
            binSize = bytearray(size)
            file.write(binSize)
            binary_image = image.flatten()
            binary_format = bytearray(binary_image)
            file.write(binary_format)
            file.close()

            # Call Assembly language procedure and wait
            os.system('filter.exe')
            time.sleep(0.01)

            # Open sharpened image
            file = open('sharpened.bin', 'rb')
            data = file.read(imageHeight*imageWidth)
            sharpenedImage = numpy.array(list(data), dtype=numpy.uint8)
            sharpenedImage.shape = (imageHeight, imageWidth)
            cv2.imshow("Sharpened", sharpenedImage)

            # Open oversharpened image
            file = open('oversharpened.bin', 'rb')
            data = file.read(imageHeight*imageWidth)
            overSharpenedImage = numpy.array(list(data), dtype=numpy.uint8)
            overSharpenedImage.shape = (imageHeight, imageWidth)
            cv2.imshow("Oversharpened", overSharpenedImage)

            # Wait for key to exit
            cv2.waitKey(0)
            cv2.destroyAllWindows()

    executing = messagebox.askyesno(None, "¿Desea procesar otra imagen?")