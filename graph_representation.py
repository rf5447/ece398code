import csv
import json
import sys
from collections import defaultdict, OrderedDict

# Convert CSV to JSON FSM in the correct format (doesn't include variables causing transitions, only includes states)
def truth_table_to_graph(csv_file_path, json_file_path):
    # Build the graph dictionary from the CSV file
    graph = {}
    with open(csv_file_path, mode='r', newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            current_state = row['SMControlTest.control.reset_state[3:0]'].strip()
            next_state = row['SMControlTest.control.s[3:0]'].strip()
            
            if current_state not in graph:
                graph[current_state] = []
            if next_state not in graph[current_state]:
                graph[current_state].append(next_state)
    
    # Ensure that every state that appears only as a next state is added as a key.
    for states in list(graph.values()):
        for state in states:
            if state not in graph:
                graph[state] = []
    
    # Create a custom formatted JSON string where the list brackets appear on the same line as the key.
    json_str = custom_json_dump(graph)
    
    with open(json_file_path, 'w') as jsonfile:
        jsonfile.write(json_str)
    print(f"Graph JSON written to {json_file_path}")

# Convert CSV to JSON FSM in the correct format (includes variables causing transitions)
def truth_table_to_graph_cause(csv_file_path, json_file_path):
    allowed_fields = [
        'SMControlTest.control.start',
        'SMControlTest.control.mr3',
        'SMControlTest.control.mr2',
        'SMControlTest.control.mr1',
        'SMControlTest.control.mr0'
    ]
    current_col = 'SMControlTest.control.reset_state[3:0]'
    next_col    = 'SMControlTest.control.s[3:0]'
    
    # Group rows by current state; use an OrderedDict to preserve order.
    state_rows = OrderedDict()
    with open(csv_file_path, mode='r', newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            curr = row[current_col].strip()
            nxt = row[next_col].strip()
            if not curr or not nxt:
                continue
            if curr not in state_rows:
                state_rows[curr] = []
            state_rows[curr].append(row)
    
    # Build the graph.
    # For each current state, determine the unique next states (in order of appearance) and the trigger variables that cause a change in the output.
    graph = {}
    for curr, rows in state_rows.items():
        next_states_ordered = []
        # For each allowed field, determine the set of next states (when value is provided)
        triggers = []
        for field in allowed_fields:
            # Build a set of next states for rows where field has a non–don’t-care value.
            values_to_next = defaultdict(set)
            for row in rows:
                value = row[field].strip() if row[field] is not None else ""
                if value != "-" and value != "":
                    values_to_next[value].add(row[next_col].strip())
            # If more than one distinct next state is produced by different values, then this field is causing variability.
            # Otherwise, it doesn't affect the transition.
            all_nexts = set()
            for nxts in values_to_next.values():
                all_nexts.update(nxts)
            if len(all_nexts) > 1:
                triggers.append(field)
        # For each row, record the unique next states in order.
        for row in rows:
            nxt = row[next_col].strip()
            if nxt not in next_states_ordered:
                next_states_ordered.append(nxt)
        # For this current state, if triggers is empty then no variable affects the outcome.
        # Record the same trigger list (or empty) for every transition.
        graph[curr] = [ next_states_ordered, [ triggers if triggers else [] ][0] ]
    
    # Ensure that every state that appears only as a next state is added as a key (with empty transitions).
    all_next_states = set()
    for transitions in graph.values():
        for s in transitions[0]:
            all_next_states.add(s)
    for state in all_next_states:
        if state not in graph:
            graph[state] = [[], []]
    
    # Write the graph to the output JSON file with custom inline formatting.
    json_str = custom_json_dump(graph)
    with open(json_file_path, "w") as jsonfile:
        jsonfile.write(json_str)
    print(f"Graph JSON written to {json_file_path}")

# Create a custom formatted JSON string with inline lists.
def custom_json_dump(graph):
    json_lines = []
    json_lines.append("{\n")
    total_keys = len(graph)
    for i, (key, value) in enumerate(graph.items()):
        # Use json.dumps to properly serialize each value, including nested lists.
        line = f'    "{key}": ' + json.dumps(value)
        if i < total_keys - 1:
            line += ","
        json_lines.append(line + "\n")
    json_lines.append("}")
    return "".join(json_lines)

# Create FSM with only state transitions
truth_table_to_graph("SMTTReachable.csv", "SMTTGraph.json")
truth_table_to_graph("SMTTBruteForceReachable.csv", "SMTTBruteForceGraph.json")

# Create FSM with trigger variables and state transitions
truth_table_to_graph_cause("SMTTReachable.csv", "SMTTCauseGraph.json")
truth_table_to_graph_cause("SMTTBruteForceReachable.csv", "SMTTBruteForceCauseGraph.json")