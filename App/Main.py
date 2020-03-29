import cv2
import numpy

# Open original image and convert to grayscale
original = cv2.imread("random.jpeg")
image = cv2.cvtColor(original, cv2.COLOR_BGR2GRAY)
cv2.imshow("Grayscale", image)

# Get size of image
imageWidth = image.shape[1] #Get image width
imageHeight = image.shape[0] #Get image height

# Save binary image
file = open('image.bin', 'wb')
binary_image = image.flatten()
binary_format = bytearray(binary_image)
file.write(binary_format)
file.close()

# Call Assembly language procedure


# Open sharpened image
file = open('sharpened.bin', 'rb')
data = file.read(imageHeight*imageWidth)
sharpenedImage = numpy.array(list(data), dtype=numpy.uint8)
sharpenedImage.shape = (imageHeight, imageWidth)
#
# # Open oversharpened image
# file = open('oversharpened.bin', 'rb')
# data = file.read(imageHeight*imageWidth)
# overSharpenedImage = numpy.array(list(data), dtype=numpy.uint8)
# overSharpenedImage.shape = (imageHeight, imageWidth)
#
#
cv2.imshow("Sharpened", sharpenedImage)
# cv2.imshow("Oversharpened", overSharpenedImage)
cv2.waitKey(0)
cv2.destroyAllWindows()