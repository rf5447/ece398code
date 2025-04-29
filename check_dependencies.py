""""
Modified version of Marina's taint tracking code applied on Controllers 1, 2, and 3
Bug fix, in depth comments, function headers, and case specific modifications added by me
"""

from collections import defaultdict
from collections import deque

"""
find denominators: 
finds which nodes must be on every path from START to END (these are denominator nodes)
returns them in BFS order
"""
def find_dominators(graph, start, end):
    # reverse the graph for dominator analysis
    reverse_graph = defaultdict(list) # original graph is also a dict with keys being node names and values are lists/tuples (next state, dependency variables) 
    for node, (neighbors, _) in graph.items(): # only looks at states, doesn't require dependency variables
        # graph.items() returns tuples like ('node', (neighbors, dep_var)) 
        for neighbor in neighbors:
            reverse_graph[neighbor].append(node) # creates directed edge in reverse direction

    # initialize dominator sets
    all_nodes = set(graph.keys())
    dom = {node: set(all_nodes) for node in all_nodes}
    dom[start] = {start}

    # iteratively refine dominator sets
    changed = True
    while changed:
        changed = False
        for node in all_nodes - {start}:
            new_dom = set(all_nodes)
            for pred in reverse_graph[node]:
                new_dom &= dom[pred]
            new_dom.add(node)
            if new_dom != dom[node]:
                dom[node] = new_dom
                changed = True

    # extract dominators of the end node and sort them in order
    dominators_of_end = dom[end]
    ordered_dominators = []

    # perform BFS to order dominators from start to end
    visited = set() # keep track of nodes to not revisit them
    queue = deque([start])
    while queue:
        current = queue.popleft()
        if current in dominators_of_end and current not in visited:
            ordered_dominators.append(current)
            visited.add(current)
        neighbors = graph[current][0]  # get neighbors
        for neighbor in neighbors:
            if neighbor not in visited:
                queue.append(neighbor)

    return ordered_dominators

# usage of above function on Controllers 1, 2, and 3:
import json
import ast

def load_graph_from_file(filepath):
    with open(filepath, "r") as infile:
        data = infile.read()
    graph = ast.literal_eval(data)
    return graph

graphController1 = load_graph_from_file("SMTTFig2.json")
graphController2 = load_graph_from_file("SMTTFig3.json")
graphController3 = load_graph_from_file("SMTTFig4.json")

print("Dominator Nodes of Controller 1: ")
print(find_dominators(graphController1, '0', '110'))
print("Dominator Nodes of Controller 2: ")
print(find_dominators(graphController2, '0', '110'))
print("Dominator Nodes of Controller 3: ")
print(find_dominators(graphController3, '0', '110'))

from collections import deque

""""
check_equal_path_lengths_dependencies:
1: starts from given START node and explores all possible paths in graph to reach END node
keeps track of lengths of these paths; when END is reached, records length of path taken to get there
2: after exploring all paths, checks if recorded path lengths are same
paths are same length return True
3: dependency on secret variables: function also checks for dependencies on secret variables
sets secret_dep to True if there is a dependency
* updated version: debugged to avoid infinite loop caused by circular dependency """
def check_equal_path_lengths_dependencies(graph, start, end, secret_vars):
    queue = deque([(start, 0, [start])])  # wueue of (node, length, path)
    path_lengths = set()
    secret_dep = False

    # track visited nodes with their paths to avoid revisiting
    visited = {}

    while queue:
        node, length, path = queue.popleft()

        # if we reach the end node, record the path length
        if node == end:
            path_lengths.add(length)
            continue

        # access adjacent nodes and add them to the queue with updated path
        neighbors = graph[node][0]
        for neighbor in neighbors:
            # avoid revisiting nodes in the same path
            if neighbor not in path:
                queue.append((neighbor, length + 1, path + [neighbor]))  # add neighbor with updated path

        # check for dependency on secret variable
        dependencies = graph[node][1]
        for dependency in dependencies:
            if dependency in secret_vars:
                secret_dep = True

    # check if all path lengths are the same
    return (len(path_lengths) == 1), secret_dep

""" 
check_secret_dependency:
returns False if there is a pair of denominators where paths are unequal and there is a secret dependency
True otherwise
"""
def check_secret_dependency(graph, start, end, secret_vars):
    # find dominator nodes
    end_dominators = find_dominators(graph, start, end)

    # check if path lengths between dominators are equal 
    # if there are unequal paths between two dominators AND 
    # there is a secret dependency between those dominators, return false
    for i in range(len(end_dominators) - 1):
        equal_lengths, secret_dep = check_equal_path_lengths_dependencies(graph, end_dominators[i], end_dominators[i + 1], secret_vars)

        if not equal_lengths and secret_dep:
            return False
    return True

# usage of above function on Controllers 1, 2, and 3:
secrets = ['SMControlTest.control.mr0', 'SMControlTest.control.mr1', 'SMControlTest.control.mr2', 'SMControlTest.control.mr3']

print("There is NO secret dependency (NO timing side-channel vulnerability) in Controller 1: ")
print(check_secret_dependency(graphController1, '0', '110', secrets))
print("There is NO secret dependency (NO timing side-channel vulnerability) in Controller 2: ")
print(check_secret_dependency(graphController2, '0', '110', secrets))
print("There is NO secret dependency (NO timing side-channel vulnerability) in Controller 3: ")
print(check_secret_dependency(graphController3, '0', '110', secrets))