# Python is a bad language, you should not use it.
# It is used here as a last resort

# Perform a sample convolution (useful for correctness verification)

import sys
import getopt
from PIL import Image
import numpy

def bipolar_weight_to_fixp8(weight):
    i = int(128 + weight*128)
    return numpy.clip(i,0,255)

def write_weights(npy, ih, mutable_addr):
    if isinstance(npy, numpy.ndarray):
        for l in npy:
            write_weights(l, ih, mutable_addr)
    else:
        ih[mutable_addr[0]] = bipolar_weight_to_fixp8(npy)
        mutable_addr[0] += 1

def write_image(image, ih, mutable_addr):
    pixels = image.load()
    for y in range(0, image.height):
        for x in range(0, image.width):
            ih[y*image.width + x] = pixels[x,y][0]
            mutable_addr[0] += 1

def main(argv):
    try:
        opts, args = getopt.getopt(argv, "ho:p:I:N:")
            
        align = 1
        N = None
        kernel = None
        image_name = None
        outfile_prefix = None
        
        for opt in opts:
            if opt[0] == "-h":
                raise getopt.GetoptError("")
                
            if opt[0] == "-o":
                print(f'Output file: {opt[1]}')
                try:
                    outfile_prefix = opt[1]
                except OSError:
                    print(f"Can't open output file, other than file-not-found error")
                    sys.exit(2)
            
            if opt[0] == "-N":
                N = opt[1]

            if opt[0] == "-p" or opt[0] == "-I":
                print(f'Input file: {opt[1]}')
                try:
                    if opt[0] == "-I":
                        image_name = opt[1]
                    else:
                        kernel = numpy.load(open(opt[1],"rb"))
                        
                except FileNotFoundError:
                    print(f"Could not find file: {opt[1]} !")
                    sys.exit(2)
                except OSError:
                    print(f"Could not open parameter file: {opt[1]}, Error other than file-not-found!")
                    sys.exit(2)
        
        if image_name is None or kernel is None:
            print("Missing an input file :(")
            sys.exit(2)
            
        if outfile_prefix == None:
            print("No output file, outputting as out.png")
            outfile_prefix = "out"
        
        #NCWH kernel format
        
        print(f"Kernel shape: {kernel.shape}")
       
        for ni in range(0, kernel.shape[0]):
            image = Image.open(image_name,"r").convert("RGB")
            pixels = image.load()
            
            out = Image.new("RGB", (image.width, image.height))
            outpix = out.load()
            
            if N is None or ni == N:
                n = kernel[ni]
                for c in n:
                    for y in range(0, image.height):
                        for x in range(0, image.width):
                            pixel_total = 0.0
                    
                            for wi in range(0,kernel.shape[2]):
                                for hi in range(0,kernel.shape[3]):
                                    h = c[hi][wi] # Kernel point
                                    sx = x + wi - 2 # Specific to 5x5 kernels for now
                                    sy = y + hi - 2
                                    if not (sx < 0 or sx >= image.width or sy < 0 or sy >= image.height):
                                        pixel_total += h * (pixels[sx,sy][0] / 255)
                            
                            p = numpy.clip(int(((pixel_total + 1.0) / 2.0)*255), 0, 255)
                            outpix[x,y] = (p,p,p)
                            
                # Write modified image
                out.save(open(f"{outfile_prefix}_N{ni}.png","wb+"), format="png")

        print("Exiting normally")
        
    except getopt.GetoptError:
        print("Usage: \n\
            \t-o\t\tSpecify output file name\n\
            \t\t\tNo file extension!\n\
            \t-p\t\tSpecify a .npy filter kernel\n\
            \t-I\t\tSpecify an image file\n\
            \t-N\t\tSpecify specific batch to use,\n\
            \t\t\totherwise outputs all batches as seperate files")
        sys.exit(2)

# Why on gods earth is this how we do this
if __name__ == "__main__":
   main(sys.argv[1:])

