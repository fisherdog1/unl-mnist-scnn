# Python is a bad language, you should not use it.
# It is used here as a last resort

import sys
import getopt
from intelhex import IntelHex
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
        opts, args = getopt.getopt(argv, "o:p:I:A:")
           
        align = 1
        infiles = []
        infile_isimage = []
        outfile = None
        
        for opt in opts:
            if opt[0] == "-o":
                print(f'Output file: {opt[1]}')
                try:
                    outfile = open(opt[1],"w+")
                except OSError:
                    print(f"Can't open output file, other than file-not-found error")
                    sys.exit(2)
                
            if opt[0] == "-A":
                print(f'Output alignment: {opt[1]}')
                align = int(opt[1])
                
            if opt[0] == "-p" or opt[0] == "-I":
                print(f'Input file: {opt[1]}')
                try:
                    if opt[0] == "-I":
                        infiles.append(Image.open(opt[1],"r").convert("RGB"))
                        infile_isimage.append(1)
                    else:
                        infiles.append(open(opt[1],"rb"))
                        infile_isimage.append(0)
                        
                except FileNotFoundError:
                    print(f"Could not find file: {opt[1]} !")
                    sys.exit(2)
                except OSError:
                    print(f"Could not open parameter file: {opt[1]}, Error other than file-not-found!")
                    sys.exit(2)
        
        if len(infiles) == 0:
            print("No input files :(")
            sys.exit(2)
            
        if outfile == None:
            print("No output file, outputting as out.hex")
            outfile = open("out.hex","w+")
        
        ih = IntelHex()
        mutable_addr = [0] #for fucks sake
        
        for i in range(0, len(infiles)):
            
            # apply alignment
            if mutable_addr[0] % align != 0:
                mutable_addr[0] = ((mutable_addr[0] // align) + 1) * align #Incredible design choice to have / convert the result to float
            
            if infile_isimage[i]:
                print(f"Placing image at address {hex(mutable_addr[0])}")
                write_image(infiles[i], ih, mutable_addr)
            else:
                print(f"Placing {infiles[i].name} at address {hex(mutable_addr[0])}")
                write_weights(numpy.load(infiles[i]), ih, mutable_addr)

        print(f"Total size: {hex(mutable_addr[0])}")

        # Final step to write hex file
        ih.tofile(outfile,format='hex')
        print("Exiting normally")
        
    except getopt.GetoptError:
        print("Usage: \n\
            \t-o\t\tSpecify output .hex file\n\
            \t-p\t\tSpecify a .npy parameter file to include\n\
            \t-I\t\tSpecify an image file to include\n\
            \t\t\tMore than one '-p' may be provided\n\
            \t-A\t\tSpecify alignment in bytes between output sections")
        sys.exit(2)

# Why on gods earth is this how we do this
if __name__ == "__main__":
   main(sys.argv[1:])

