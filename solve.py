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

    def __init__(self, variables):
        cp_model.CpSolverSolutionCallback.__init__(self)
        self.__variables = variables
        self.__solution_count = 0

    def on_solution_callback(self):
        self.__solution_count += 1
        for v in self.__variables:
            print('%s=%i' % (v, self.Value(v)), end=' ')
        print()

    def solution_count(self):
        return self.__solution_count



def main():
    parser = argparse.ArgumentParser(description='Process some integers.')
    parser.add_argument('input')
    parser.add_argument('--output','-o',default="solution.json")
    #parser.add_argument('output')
    parser.add_argument('--f0',action="store_true")
    parser.add_argument('--amin',action="store_true")
    parser.add_argument('--maxint','-M',type=int,default=32768)
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
    samex = pa["samex"]
    commutative = pa["commutative"]
    pa["nc"] = len(p)
    nc = len(p) # constraints
    if args.minint is None:
        args.minint = 0# if pa["op"] != "/" else -args.maxint
    Lx1 = [model.NewIntVar(args.minint, args.maxint, 'Lx1%d'%(i+1)) for i in range(0,nx1)]
    if samex:
        Lx2 = Lx1
    else:
        Lx2 = [model.NewIntVar(args.minint, args.maxint, 'Lx2%d'%(i+1)) for i in range(0,nx2)]
    Ly = [model.NewIntVar(args.minint, args.maxint, 'Ly%d'%(i+1)) for i in range(0,ny)]
    print("nx1 %d nx2 %d ny %d nc %d samex? %s " % (nx1,nx2,ny,nc,samex))

    # add every sum, remember indices are 1-based
    if commutative: 
        for c in range(0,nc):
            model.Add( Lx1[p[c][0]-1] + Lx2[p[c][1]-1] == Ly[b[c]-1])
        LLq = [0]
    else:
        Lq = model.NewIntVar(-args.maxint, args.maxint, 'Lq')
        for c in range(0,nc):
            model.Add( Lx1[p[c][0]-1] - Lx2[p[c][1]-1] == Ly[b[c]-1]+Lq)
        LLq = [Lq]
    # lowest shall be zero
    if args.f0:
        model.Add(Lx1[0] == 0)
        if not samex:
            model.Add(Lx2[0] == 0)
    for i in range(1,nx1):
        # others shall be greater than previous
        model.Add(Lx1[i] > Lx1[i-1])
    if not samex:
        for i in range(1,nx2):
            # others shall be greater than previous
            model.Add(Lx2[i] > Lx2[i-1])

    # lowest shall be zero
    if args.f0:
        model.Add(Ly[0] == 0)
    if pa["op"] != "/":
        for i in range(1,ny):
            # others shall be greater than previous
            model.Add(Ly[i] > Ly[i-1])
    else:
        for i in range(1,ny):
            # others shall be greater than previous
            model.Add(Ly[i] > Ly[i-1])

    solver = cp_model.CpSolver()

    if True:
        # iminimze sum of positive values
        s = sum(Ly)+sum(Lx1)+sum(LLq)
        if not samex:
            s = s + sum(Lx2)
        if args.minint < 0:
            n = len(Ly)+len(Lx1)
            if not samex:
                n = n +len(Lx2)
            help = model.NewIntVar(args.minint*n,args.maxint*n,"H")
            if args.amin:
                model.Add(s <= help)
                model.Add(-s <= help)
                model.Minimize(help)
            else:                
                if not samex:
                    z =  Lx2[-1]
                else:
                    z = 0
                model.Minimize(Ly[-1]+Lx1[-1]+z)
        else:
            if args.amin:
                if not samex:
                    z =  Lx2[-1]
                else:
                    z = 0
                model.Minimize(Ly[-1]+Lx1[-1]+z)
            else:
                model.Minimize(s)
        status = solver.Solve(model)
        print('Solve status: %s' % solver.StatusName(status))
        if status == cp_model.OPTIMAL:
            print('Optimal objective value: %i' % solver.ObjectiveValue())
            s=pa
            s["Lx1"] = [solver.Value(x) for x in Lx1]
            if not samex:
                s["Lx2"] = [solver.Value(x) for x in Lx2]
            s["Ly"] = [solver.Value(x) for x in Ly]
            print("Lx1",s["Lx1"])
            if not samex:
                print("Lx2",s["Lx2"])
            else:
                print("Lx",s["Lx1"])                
            print("Ly",s["Ly"])
            json.dump(s,open(args.output,"w"))
        print('Statistics')
        print('  - conflicts : %i' % solver.NumConflicts())
        print('  - branches  : %i' % solver.NumBranches())
        print('  - wall time : %f s' % solver.WallTime())        
    else:
        # Force the solver to follow the decision strategy exactly.
        #solver.parameters.search_branching = cp_model.FIXED_SEARCH

        # Search and print out all solutions.
        solution_printer = VarArraySolutionPrinter(Lx+Ly) # skip L0 0
        solver.SearchForAllSolutions(model, solution_printer)

if __name__ == '__main__':
    main()
