# Python is a bad language, you should not use it.
# It is used here as a last resort

from intelhex import IntelHex
from PIL import Image


image = Image.open("three.png","r").convert("RGB")
pixels = image.load()
ih = IntelHex()

for y in range(0, image.height):
    for x in range(0, image.width):
        ih[y*image.width + x] = pixels[x,y][0]


ih.tofile(open("image.hex","w+"),format='hex')