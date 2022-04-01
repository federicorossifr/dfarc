import json
import argparse
import os
import sys
import operator
from pyeda.inter import *
import numpy as np
from collections import OrderedDict

r3=[0.5,1,2]
r4=[0.25,0.5,0.75,1,1.5,2,4]
r6=[0.0625,0.125,0.1875,0.25,0.3125,0.375,0.4375,0.5,0.5625,0.625,0.6875,0.75,0.8125,0.875,0.9375,1,1.125,1.25,1.375,1.5,1.625,1.75,1.875,2,2.5,3,3.5,4,6,8,16];
r8=[0.015625,0.03125,0.046875,0.0625,0.078125,0.09375,0.109375,0.125,0.140625,0.15625,0.171875,0.1875,0.203125,0.21875,0.234375,0.25,0.265625,0.28125,0.296875,0.3125,0.328125,0.34375,0.359375,0.375,0.390625,0.40625,0.421875,0.4375,0.453125,0.46875,0.484375,0.5,0.515625,0.53125,0.546875,0.5625,0.578125,0.59375,0.609375,0.625,0.640625,0.65625,0.671875,0.6875,0.703125,0.71875,0.734375,0.75,0.765625,0.78125,0.796875,0.8125,0.828125,0.84375,0.859375,0.875,0.890625,0.90625,0.921875,0.9375,0.953125,0.96875,0.984375,1,1.03125,1.0625,1.09375,1.125,1.15625,1.1875,1.21875,1.25,1.28125,1.3125,1.34375,1.375,1.40625,1.4375,1.46875,1.5,1.53125,1.5625,1.59375,1.625,1.65625,1.6875,1.71875,1.75,1.78125,1.8125,1.84375,1.875,1.90625,1.9375,1.96875,2,2.125,2.25,2.375,2.5,2.625,2.75,2.875,3,3.125,3.25,3.375,3.5,3.625,3.75,3.875,4,4.5,5,5.5,6,6.5,7,7.5,8,10,12,14,16,24,32,64];


def genLxTruthTable(Lx,nbits):
    outbits = max(Lx).bit_length()
    ttouts = np.empty([2**int(nbits), outbits], dtype = str)
    for i,x in enumerate(Lx):
        ttout = np.array(list('{0:0{1}b}'.format(x,outbits)))
        ttouts[i] = ttout
    
    for i in range(len(Lx),2**nbits):
        ttouts[i] = '-'*len(Lx)

    transposed_tt = ttouts.transpose()

    tt_stringlist = [];
    for i,tt_list in enumerate(transposed_tt):
        ttstring= ''.join(list(tt_list))
        tt_stringlist.append(ttstring)

    return tt_stringlist

def genBoolExpr(Lx,nbits):
    X = ttvars('x',int(nbits))
    truth_strings = genLxTruthTable(Lx,nbits)
    logfun = []
    outbits = clog2(max(Lx))
    for i in range(outbits):
        ttable = truthtable(X,truth_strings[i])
        logfun.append(ttable)
    fm = espresso_tts(*logfun)
    return fm


def genLzBoolExpr(x,y,Lx1,Lx2,Ly,nbits):
    lzMap = genLzTable(x,y,Lx1,Lx2,Ly)
    orderedLzMap = OrderedDict(sorted(lzMap.items()))
    return genBoolExpr(orderedLzMap.values(),nbits+1)
    

def genLzTable(x,y,Lx1,Lx2,Ly):
    xlen = len(Lx1)
    ymap = {}
    for i,x1 in enumerate(Lx1):
        for j,x2 in enumerate(Lx2):
            y_ind = (xlen*i+j)
            y_val = y[y_ind]
            
            ly_val = Ly[y_ind]

            try:
                p_ind = x.index(y_val)
                #print(i,j)
                #print(x[i],' op ',x[j]," = ", y_val)
                #print(x1, '+', x2, " = ", ly_val)
            except ValueError:
                print("")

            
            ymap[ly_val] = p_ind

    return ymap

# Output the solution.json content as a text rom to be used in Logisim
def main():
    parser = argparse.ArgumentParser(description='Process some integers.')    
    parser.add_argument('input')
    parser.add_argument('--bits')
    parser.add_argument('--prefix')
    args = parser.parse_args()

    solution = json.load(open(args.input,"r"))
    Lx1 = solution['Lx1']
    Lx2 = solution['Lx2']
    Ly  = solution['Ly']
    y   = solution['y']
    x   = solution['x1']
    m1 = genBoolExpr(Lx1,int(args.bits))
    m2 = genBoolExpr(Lx2,int(args.bits))

    print(m1)
    print(m2)


    m3 = genLzBoolExpr(x,y,Lx1,Lx2,Ly,int(args.bits))
    print(m3)
    return







    #header = "v2.0 raw\n"
    r = [];
    if args.bits == "4":
        r = r4
    elif args.bits == "3":
        r = r3
    elif args.bits == "6":
        r = r6
    else:
        r = r8
    rev = reverse_map(r,Lx,Lx2,Ly,operator.mul,True,int(args.bits))
    print(args.prefix)
    with open(args.prefix+"map.txt","w") as f:
        #f.write(header)
        #f.write(format(0,'x')+"\n")
        f.write('Lx1'+"\n")
        f.write('Posit\tLx1\n')
        f.write('============\n')
        for i,x in enumerate(Lx):
            f.write('{0:03b}'.format(i)+"\t"+'{0:03b}'.format(x)+"\n")

        f.write('\n\nLx2'+"\n")
        f.write('Posit\tLx1\n')
        f.write('============\n') 
        for i,x in enumerate(Lx2):
            f.write('{0:03b}'.format(i)+"\t"+'{0:03b}'.format(x)+"\n")


    with open(args.prefix+"unmap.txt","w") as f:
        #f.write(header)
        f.write('Ly\tPosit\n')
        f.write('============\n') 
        for r in range(0,max(rev)+1):
            try:
                f.write('{0:03b}'.format(r)+"\t"+'{0:03b}'.format(rev[r])+"\n")
            except:
                print("skip")


        
        
        
if __name__ == '__main__':
    main()
