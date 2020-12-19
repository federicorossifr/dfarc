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
    #parser.add_argument('-x',action="store_true")
    args = parser.parse_args()

    model = cp_model.CpModel()
    solver = cp_model.CpSolver()



    pa = json.load(open(args.input,"r"))
    A = pa["A"]
    b = pa["b"]
    p = pa["p"]
    ny = pa["ny"]
    nx = pa["nx"]
    nc = len(p) # constraints
    Lx = [model.NewIntVar(0, 1000, 'Lx%d'%(i+1)) for i in range(0,nx)]
    Ly = [model.NewIntVar(0, 1000, 'Ly%d'%(i+1)) for i in range(0,ny)]
    print("A: %d x %d and b: %d x 1 " % (len(A),len(A[0]),len(b)))

    # add every sum, remember indices are 1-based
    for c in range(0,nc):
        model.Add( Lx[p[c][0]-1] + Lx[p[c][1]-1] == Ly[b[c]-1])

    # lowest shall be zero
    model.Add(Lx[0] == 0)
    for i in range(1,nx):
        # others shall be greater than previous
        model.Add(Lx[i] > Lx[i-1])

    # lowest shall be zero
    model.Add(Ly[0] == 0)
    for i in range(1,ny):
        # others shall be greater than previous
        model.Add(Ly[i] > Ly[i-1])

    solver = cp_model.CpSolver()

    if True:
        # iminimze sum of positive values
        model.Minimize(sum(Ly)+sum(Lx))
        status = solver.Solve(model)
        print('Solve status: %s' % solver.StatusName(status))
        if status == cp_model.OPTIMAL:
            print('Optimal objective value: %i' % solver.ObjectiveValue())
            s={}
            s["Lx"] = [solver.Value(x) for x in Lx]
            s["Ly"] = [solver.Value(x) for x in Ly]
            print(s)
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
