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
    nx = pa["nx"]
    pa["nc"] = len(p)
    nc = len(p) # constraints
    if args.minint is None:
        args.minint = 0# if pa["op"] != "/" else -args.maxint
    Lx = [model.NewIntVar(args.minint, args.maxint, 'Lx%d'%(i+1)) for i in range(0,nx)]
    Ly = [model.NewIntVar(args.minint, args.maxint, 'Ly%d'%(i+1)) for i in range(0,ny)]
    print("nx %d ny %d nc %d" % (nx,ny,nc))

    # add every sum, remember indices are 1-based
    if pa["op"] != "/":
        for c in range(0,nc):
            model.Add( Lx[p[c][0]-1] + Lx[p[c][1]-1] == Ly[b[c]-1])
        LLq = [0]
    else:
        Lq = model.NewIntVar(-args.maxint, args.maxint, 'Lq')
        for c in range(0,nc):
            model.Add( Lx[p[c][0]-1] - Lx[p[c][1]-1] == Ly[b[c]-1]+Lq)
        LLq = [Lq]
    # lowest shall be zero
    if args.f0:
        model.Add(Lx[0] == 0)
    for i in range(1,nx):
        # others shall be greater than previous
        model.Add(Lx[i] > Lx[i-1])

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
        s = sum(Ly)+sum(Lx)+sum(LLq)
        if args.minint < 0:
            n = len(Ly)+len(Lx)
            help = model.NewIntVar(args.minint*n,args.maxint*n,"H")
            if args.amin:
                model.Add(s <= help)
                model.Add(-s <= help)
                model.Minimize(help)
            else:                
                model.Minimize(Ly[-1]+Lx[-1])
        else:
            if args.amin:
                model.Minimize(Ly[-1]+Lx[-1])
            else:
                model.Minimize(s)
        status = solver.Solve(model)
        print('Solve status: %s' % solver.StatusName(status))
        if status == cp_model.OPTIMAL:
            print('Optimal objective value: %i' % solver.ObjectiveValue())
            s=pa
            s["Lx"] = [solver.Value(x) for x in Lx]
            s["Ly"] = [solver.Value(x) for x in Ly]
            print("Lx",s["Lx"])
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
