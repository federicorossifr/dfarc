import json
import argparse
import os
import sys
import operator
from pyeda.inter import *
import numpy as np
from collections import OrderedDict
import re


def genTruthTable(outputs,inbits,outbits = 0):
    if outbits < 1:
        outbits = max(outputs).bit_length()
    ttout_entries = 2**int(inbits)

    ttouts = np.empty([ttout_entries, outbits], dtype = str)
    
    for i in range(ttout_entries):
        try:
            ttout = np.array(list('{0:0{1}b}'.format(outputs[i],outbits)))
            ttouts[i] = ttout
        except:
            ttouts[i] = '-'*outbits


    transposed_tt = ttouts.transpose()
    tt_stringlist = [];
    for i,tt_list in enumerate(transposed_tt):
        ttstring= ''.join(list(tt_list))
        tt_stringlist.append(ttstring)

    return tt_stringlist,ttouts

def genBoolExpr(outputs,nbits, varname, outbits = -1):
    X = ttvars(varname,int(nbits))
    truth_strings,tt = genTruthTable(outputs,nbits,outbits)
    logfun = []
    if outbits < 1:
        outbits = clog2(max(outputs))
    for i in range(outbits):
        ttable = truthtable(X,truth_strings[i])
        logfun.append(ttable)
    fm = espresso_tts(*logfun)
    return fm,tt


def genLzBoolExpr(x,nbits,uLy,uLy2y):
    lzMap = genLzTable(x,uLy,uLy2y)
    orderedLzMap = OrderedDict(sorted(lzMap.items()))
    return genBoolExpr(lzMap,nbits+1,"z",nbits)
    

def genLzTable(x,uLy,uLy2y):
    ymap = {}

    for i,ly in enumerate(uLy):
        ymap[ly] = x.index(uLy2y[i])    

    return ymap

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
    uLy = list(dict.fromkeys((Ly)))
    uLy2y = solution['uLy2y']
    y   = solution['y']
    x   = solution['x1']
    m1,mx1 = genBoolExpr(Lx1,int(args.bits),"x")
    m2,mx2 = genBoolExpr(Lx2,int(args.bits),"y")
    m3,mx3 = genLzBoolExpr(x,int(args.bits),uLy,uLy2y)

    printRecap(x,y,Lx1,Lx2,Ly,uLy,uLy2y,m1,m2,m3,mx1,mx2,mx3)



def printTruthTab(mx,outbits):
    for i,x in enumerate(mx):
        print('{0:0{1}b}'.format(i,outbits),"\t",''.join(list(mx[i])))

def countGates(boolExpr):
    andGates = len(re.findall("And", boolExpr))
    orGates  = len(re.findall("Or",  boolExpr))
    return andGates + orGates

# We will use paper nomenclature here
# x1 => x; x2 => y; y => z
def printRecap(x,y,Lx1,Lx2,Ly,uLy,uLy2y,m1,m2,m3,mx1,mx2,mx3):
    print("\n===============\n")
    print("POSIT DOMAIN")
    print("Operands (x,y):")
    print(x,"\n")
    print("Result (z):")
    print(y)
    print("\n===============\n")
    print("MAPPING")
    print("x => Lx")
    print(x,"=>",Lx1,"\n")
    print("y => Ly")
    print(x,"=>",Lx2,"\n")

    print("Lx+Ly: ")
    print("\t","\t".join(map(str,Lx1)))
    print("")
    for i,l in enumerate(np.reshape(Ly,[4, 4])):
        print(Lx2[i],"\t","\t".join(map(str,list(l))))
    
    print("\nLz => z [uniques only]")
    print(uLy,"=>",uLy2y,"\n")

    print("Full Lz: ", len(Ly))
    print("Unique Lz: ", len(uLy))
    print("Max Lz: ", max(Ly))
    print("Min Lz: ", min(Ly))
    print("Max-min Lz: ", max(Ly) - min(Ly))
    print("% saved using uniques: ", 100*(len(Ly)-len(uLy))/len(Ly),"%")

    print("\n===============\n")

    print("TRUTH EXPR")
    print("x\t Lx")
    printTruthTab(mx1,3)
    print(str(m1))
    print("Gates: ",countGates(str(m1)))

    print("\ny\t Ly")
    printTruthTab(mx2,3)
    print(m2)
    print("Gates: ",countGates(str(m2)))


    print("\nz\t Lz")
    printTruthTab(mx3,4)
    print(m3)
    print("Gates: ",countGates(str(m3)))

    
if __name__ == '__main__':
    main()
