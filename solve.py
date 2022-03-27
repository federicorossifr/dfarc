import ortools
print(ortools.__version__) 
from ortools.linear_solver import pywraplp
from ortools.sat.python import cp_model

import json
import argparse
import os
import sys



class VarArraySolutionPrinter(cp_model.CpSolverSolutionCallback):
    """Print intermediate solutions."""

    def __init__(self, out, variables):
        cp_model.CpSolverSolutionCallback.__init__(self)
        self.__variables = variables
        self.__solution_count = 0
        self.output = out

    def on_solution_callback(self):
        self.__solution_count += 1
        for k,vars in self.__variables.items():
            self.output[k] = [self.Value(var) for var in vars]
        self.StopSearch()

    def solution_count(self):
        return self.__solution_count



def main():
    parser = argparse.ArgumentParser(description='Process some integers.')
    parser.add_argument('input')
    parser.add_argument('--output','-o',default="solution.json")
    #parser.add_argument('output')
    parser.add_argument('--first0',action="store_true",help="Enforce that first Lx and first Ly are ZERO")
    parser.add_argument('--xpolicy',choices=["distinct","mono","none"],default="none")
    parser.add_argument('--ypolicy',choices=["distinct","mono","none"],default="none")
    parser.add_argument('--target',choices=["maxx","sum"],default="sum")
    parser.add_argument('--firstsol',action="store_true")
    parser.add_argument('--maxint','-M',type=int,help="Fix maximum of Lx and Ly, otherwise compute automatically")
    parser.add_argument('--minint','-m',type=int)
    args = parser.parse_args()

    model = cp_model.CpModel()
    solver = cp_model.CpSolver()



    pa = json.load(open(args.input,"r"))
    print("problem %s" % pa["name"])
    #A = pa["A"]
    b = pa["b"]
    p = pa["p"]
    ny = pa["ny"]
    nx1 = pa["nx1"]
    nx2 = pa["nx2"]
    eqgroups = pa.get("eqgroups",[])
    samex = pa["samex"] # enforce same Lx1=Lx2
    negative = pa.get("negative",False) # allow negative solutions 
    commutative = pa["commutative"] != 0 # NO EFFECT
    pa["nc"] = len(p)
    pa["xpolicy"] = args.xpolicy
    pa["ypolicy"] = args.ypolicy
    nc = len(p) # constraints
    if args.minint is None:
        args.minint = 0
    if args.maxint is None or args.maxint == 0:
        args.maxint = (nx1+1)*(nx2+1) # if pa["op"] != "/" else -args.maxint
    Lx1 = [model.NewIntVar(args.minint, args.maxint, 'Lx1%d'%(i+1)) for i in range(0,nx1)]
    if samex:
        Lx2 = Lx1
    else:
        Lx2 = [model.NewIntVar(args.minint, args.maxint, 'Lx2%d'%(i+1)) for i in range(0,nx2)]
    Ly = [model.NewIntVar(args.minint, args.maxint, 'Ly%d'%(i+1)) for i in range(0,ny)]


    print("nx1 %d nx2 %d ny %d nc %d " % (nx1,nx2,ny,nc))
    print("problem mode name %s op %s xpolicy:%s ypolicy:%s commutative:%s negative:%s samex:%s first0:%s maxint:%d minint:%d eqgroups:%d target:%s firstsol:%s" %(pa["name"],pa["op"],args.xpolicy,args.ypolicy,commutative,negative,samex,args.first0,args.maxint,args.minint,len(eqgroups),args.target,args.firstsol))
    # add every sum, remember indices are 1-based
    if not negative: 
        for c in range(0,nc):
            model.Add( Lx1[p[c][0]-1] + Lx2[p[c][1]-1] == Ly[b[c]-1])
        LLq = []
    else:
        Lq = model.NewIntVar(-args.maxint, args.maxint, 'Lq')
        for c in range(0,nc):
            model.Add( Lx1[p[c][0]-1] - Lx2[p[c][1]-1] + Lq == Ly[b[c]-1])
        LLq = [Lq]
    # lowest shall be zero
    if args.first0:
        model.Add(Lx1[0] == 0)
        if not samex:
            model.Add(Lx2[0] == 0)
    if args.xpolicy == "mono":
        for i in range(1,nx1):
            # others shall be greater than previous
            model.Add(Lx1[i] > Lx1[i-1])
        if not samex:
            for i in range(1,nx2):
                # others shall be greater than previous
                model.Add(Lx2[i] > Lx2[i-1])
    elif args.xpolicy == "distinct":
        model.AddAllDifferent(Lx1)
        if not samex:
            model.AddAllDifferent(Lx2)

    if len(eqgroups) != 0:
        eqgroupsT = max(eqgroups) # 1..N
        for i in range(1,eqgroupsT+1): # each group 
            # split 
            same_i = []
            notsame_i = []
            for j,k in enumerate(eqgroups):
                if k == i:
                    same_i.append(j)
                else:
                    notsame_i.append(j)
            for y1 in same_i:
                for y2 in notsame_i:
                    model.Add(Ly[y1] != Ly[y2])


    # lowest shall be zero
    if args.first0:
        model.Add(Ly[0] == 0)

    if args.ypolicy == "mono":
        for i in range(1,ny):
            # others shall be greater than previous
            model.Add(Ly[i] > Ly[i-1])
    elif args.ypolicy == "distinct":
        model.AddAllDifferent(Ly)
    else:
        pass

    solver = cp_model.CpSolver()
    if "Lx1" in pa:
        for var,value in zip(Lx1,pa["Lx1"]):
            model.AddHint(var,value)
    if not samex and "Lx2" in pa:
        for var,value in zip(Lx2,pa["Lx2"]):
            model.AddHint(var,value)
    if "Ly" in pa:
        for var,value in zip(Ly,pa["Ly"]):
            model.AddHint(var,value)

    if not args.firstsol:        
        # monotonic problem and amin enforces only final term not all terms
        if args.target == "maxx":
            if not samex:
                z =  Lx2[-1]
            else:
                z = 0
            s = Lx1[-1]+z
        else:
            # iminimze sum of positive values
            s = sum(Ly)+sum(Lx1)+(0 if len(LLq) == 0 else sum(LLq))
            if not samex:
                s = s + sum(Lx2)
            if args.minint < 0:
                n = len(Ly)+len(Lx1)
                if not samex:
                    n = n +len(Lx2)
                help = model.NewIntVar(args.minint*n,args.maxint*n,"H")
                model.Add(s <= help)
                model.Add(-s <= help)
                s = help
            else:
                pass
        model.Minimize(s)

        print("start solving")
        status = solver.Solve(model)
        print('Solve status: %s' % solver.StatusName(status))
        if status == cp_model.OPTIMAL:
            print('Optimal objective value: %i' % solver.ObjectiveValue())
            s=pa
            s["Lx1"] = [solver.Value(x) for x in Lx1]
            if not samex:
                s["Lx2"] = [solver.Value(x) for x in Lx2]
            else:
                s["Lx2"] = s["Lx1"]
            s["Ly"] = [solver.Value(x) for x in Ly]
            s["negative"] = negative
            if negative:
                s["Lq"] = solver.Value(LLq[0])
            else:
                s["Lq"] = 0
            if not samex:
                print("Lx1",s["Lx1"])
                print("Lx2",s["Lx2"])
            else:
                print("Lx",s["Lx1"])                
            print("Ly",s["Ly"])
            print("Max Values X1 X2 Y:",max(s["Lx1"]),max(s["Lx1"]),max(s["y"]))
            json.dump(s,open(args.output,"w"))
            print('Statistics')
            print('  - conflicts : %i' % solver.NumConflicts())
            print('  - branches  : %i' % solver.NumBranches())
            print('  - wall time : %f s' % solver.WallTime())       

    else:
        s = pa
        s["negative"] = negative
        s["Lq"] = 0        
        vars = dict(Lx1=Lx1,Ly=Ly)
        if not samex:
            vars["Lx2"] = Lx2
        else:
            vars["Lx2"] = Lx1
        if negative:
            vars["Lq"] = LLq
        # Search and print out all solutions.
        print("start solving first")  
        solution_printer = VarArraySolutionPrinter(s,vars) # skip L0 0
        solver.SearchForAllSolutions(model, solution_printer)
        if solution_printer.solution_count != 0:
            # solutions already written in Lx1, Lx2, Ly Lq of the variable s if found
            json.dump(s,open(args.output,"w"))



if __name__ == '__main__':
    main()
