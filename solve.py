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
    nc = len(p) # constraints
    L = [0] + [model.NewIntVar(0, 100000, 'L%d'%i) for i in range(1,ny)]
    print("A: %d x %d and b: %d x 1 " % (len(A),len(A[0]),len(b)))

    # add every sum, remember indices are 1-based
    for c in range(0,nc):
        e = L[p[c][0]-1] + L[p[c][1]-1] == L[b[c]-1]
        model.Add( e )

    # lowest shall be zero
    #model.Add(L[0] == 0)
    for i in range(1,ny):
        # others shall be greater than previous
        model.Add(L[i] > L[i-1])

    solver = cp_model.CpSolver()

    # Force the solver to follow the decision strategy exactly.
    #solver.parameters.search_branching = cp_model.FIXED_SEARCH

    # Search and print out all solutions.
    solution_printer = VarArraySolutionPrinter(L[1:])
    solver.SearchForAllSolutions(model, solution_printer)

if __name__ == '__main__':
    main()
