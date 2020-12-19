import json
import argparse
import os
import sys

r4=[0.25,0.5,0.75,1,1.5,2,4]
r6=[0.0625,0.125,0.1875,0.25,0.3125,0.375,0.4375,0.5,0.5625,0.625,0.6875,0.75,0.8125,0.875,0.9375,1,1.125,1.25,1.375,1.5,1.625,1.75,1.875,2,2.5,3,3.5,4,6,8,16];
r8=[0.015625,0.03125,0.046875,0.0625,0.078125,0.09375,0.109375,0.125,0.140625,0.15625,0.171875,0.1875,0.203125,0.21875,0.234375,0.25,0.265625,0.28125,0.296875,0.3125,0.328125,0.34375,0.359375,0.375,0.390625,0.40625,0.421875,0.4375,0.453125,0.46875,0.484375,0.5,0.515625,0.53125,0.546875,0.5625,0.578125,0.59375,0.609375,0.625,0.640625,0.65625,0.671875,0.6875,0.703125,0.71875,0.734375,0.75,0.765625,0.78125,0.796875,0.8125,0.828125,0.84375,0.859375,0.875,0.890625,0.90625,0.921875,0.9375,0.953125,0.96875,0.984375,1,1.03125,1.0625,1.09375,1.125,1.15625,1.1875,1.21875,1.25,1.28125,1.3125,1.34375,1.375,1.40625,1.4375,1.46875,1.5,1.53125,1.5625,1.59375,1.625,1.65625,1.6875,1.71875,1.75,1.78125,1.8125,1.84375,1.875,1.90625,1.9375,1.96875,2,2.125,2.25,2.375,2.5,2.625,2.75,2.875,3,3.125,3.25,3.375,3.5,3.625,3.75,3.875,4,4.5,5,5.5,6,6.5,7,7.5,8,10,12,14,16,24,32,64];

def reverse_map(rp,Lx,Ly,rely=False,bits=4):
    rev = dict()
    pp_ind = 0
    last_ind = 0
    not_found = 0
    total = 0
    for i,p in enumerate(rp):
        for p1 in rp[i+1:]:
            plx = Lx[rp.index(p)]
            p1lx = Lx[rp.index(p1)]
            pp_y = plx + p1lx            
            try:

                pp_ind = rp.index(p1*p)+1

            except:
                not_found = not_found+1
                if rely and p1*p in r8:
                    pp_ind = round((r8.index(p1*p)+1)/(2**(8-bits)))
                else:
                    pp_ind = last_ind
            pp_ind = min(len(rp),pp_ind)
            last_ind = pp_ind
            rev[pp_y] = pp_ind
            total = total+1
    print (rev)
    print(not_found,total)
    return rev

# Output the solution.json content as a text rom to be used in Logisim
def main():
    parser = argparse.ArgumentParser(description='Process some integers.')    
    parser.add_argument('input')
    parser.add_argument('--bits')
    parser.add_argument('--prefix')
    args = parser.parse_args()

    solution = json.load(open(args.input,"r"))
    Lx = solution['Lx']
    Ly = solution['Ly']

    header = "v2.0 raw\n"
    r = [];
    if args.bits == "4":
        r = r4
    elif args.bits == "6":
        r = r6
    else:
        r = r8
    rev = reverse_map(r,Lx,Ly,True,int(args.bits))
    print(args.prefix)
    with open(args.prefix+"map.txt","w") as f:
        f.write(header)
        f.write(format(0,'x')+"\n")
        for i,x in enumerate(Lx):
            f.write(format(x,'x')+"\n")

    with open(args.prefix+"unmap.txt","w") as f:
        f.write(header)
        for r in range(0,max(rev)+1):
            try:
                f.write(format(rev[r],'x')+"\n")
            except:
                f.write(format(0,'x')+"\n")


        
        
        
if __name__ == '__main__':
    main()
