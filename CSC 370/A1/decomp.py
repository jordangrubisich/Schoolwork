#!/usr/bin/env python3

"""
Jordan Grubisich
V00951272
CSC370 - Assignment 1
decomp.py
"""
import sys



# Returns whether or not the provided decomp is possible given the input and decomp algorithm
def compare_outputs(result: list, provided: list)->bool:
    for rel in provided:
        if rel not in result:
            print("False")
            sys.exit()
    print("True")
    sys.exit()    
    
# Runs BCNF decomp algorithm on the relation and fds provided
def BCNF(attributes: set, fds: list, decomp: list):
    # input: set of attributes, list of fds,

    closure = calculate_closure(fds)


    for fd, close in zip(fds, closure):
        if close[0] == attributes:
            
            decomp.append(tuple(attributes))
            
        else:
            
            r1 = set(close[0])
            r1 = tuple(r1)
            f1 = list(close[1])
            
            if len(f1) > 1:
                decomp = decomp + BCNF(set(r1), f1, decomp)
            else:
                decomp.append(r1)

            r2 = (attributes.difference(close[0])).union(set(fd.split("/")[0].split(",")))
            r2 = set(r2)
            r2 = tuple(r2)
            f2 = list(set(fds).difference(set(f1)))

            if len(f2) > 1:
                decomp = decomp + BCNF(attributes, f2, decomp)
            else:
                decomp.append(r2)

   
    return decomp

#Runs 3NF decomp algorithm on the relation and sets provided
def t_nf(attributes: set, fds: list, decomp: list, provided: list):
    
    closure = calculate_closure(fds)

    superKey = False

    for fd, close in zip(fds,closure):
        dep = fd.split("/")
        rel = dep[0] + "," + dep[1]
        temp_dep = rel + "/" + rel
        fd_list = fds.copy()
        fd_list.insert(0,temp_dep)
        closure = calculate_closure(fd_list)
        if closure[0][1] == attributes:
            superKey = True
        decomp.append(set(rel.split(",")))
  
        
    if superKey == False:
        for relation in provided:
            if relation not in decomp:
                cur = list(relation)
                temp_dep = ""
                for x in cur:
                    temp_dep += x + ","
                temp_dep = temp_dep[:-1]
                temp_dep = temp_dep + "/" + temp_dep
                fd_list=fds.copy()
                fd_list.insert(0,temp_dep)
                closure = calculate_closure(fd_list)
                if closure[0][1] == attributes:
                    decomp.append(relation)
                    break
    return decomp
                

#Calculates the closure of a list of fds. Returns the closure and the fds required in each closure
# as a tuple 
def calculate_closure(fds):
    closure = []
    fd_list = fds

    for fd in fd_list:
        used = set()
        close = set(fd.split("/")[0].split(","))
        for x in range(len(fd_list)):
            for dep in fd_list:
                if set(dep.split("/")[0].split(",")).issubset(close):
                    close = close.union(set(dep.split("/")[1].split(",")))
                    used.add(dep)

        closure.append(tuple((close, used)))

    return closure

# Takes inputs from arguments, parses inputs and directs them to the proper decomp algorithm.
# Once algorithm is complete, passes results to compare function for final output.
def main() -> None:
    relation_input = sys.argv[1]
    fd_input = sys.argv[2]
    alg_input = sys.argv[3]
    decomp_input = sys.argv[4]

    relations = (relation_input.split(";"))
    dependencies = fd_input.split(";")
    provided_decomp = []
    for rel in decomp_input.split(";"):
        provided_decomp.append(set(rel.split(",")))

    decomp = []
    

    if alg_input == "B":
        result = []
        if ";" in relation_input:
            for rel in set(relation_input.split(";")):
                current_relation = set(rel.split(","))
                curr = BCNF(current_relation,dependencies,decomp)
                for c in curr:
                    if c not in result:
                        result.append(c)
        else:
            result = BCNF(set(relation_input.split(",")), dependencies, decomp)

        temp = []
        for re in result:
            temp.append(set(re))
        final = []
        for t in temp:
            if t not in final:
                final.append(t)
        compare_outputs(final,provided_decomp)
    elif alg_input == "3":
        result = []
        if ";" in relation_input:
            for rel in set(relation_input.split(";")):
                current_relation = set(rel.split(","))
                curr = t_nf(current_relation,dependencies,decomp,provided_decomp)
                for c in curr:
                    if c not in result:
                        result.append(c)
        else:
            result = t_nf(set(relation_input.split(",")),dependencies, decomp, provided_decomp)
        temp = []
        for re in result:
            temp.append(set(re))
        final = []
        for t in temp:
            if t not in final:
                final.append(t)
        compare_outputs(final, provided_decomp)


    





if __name__ == "__main__":
    main()
