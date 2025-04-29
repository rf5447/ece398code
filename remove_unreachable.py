import pandas as pd

# Post-testbench implementation of "Reachable-Only" algorithm to apply to Brute-Force extraction to get same final truth table
def remove_unreachable(input_csv, output_csv, output_json):
    # Read CSV and ensure that the next state column is interpreted as a string.
    df = pd.read_csv(input_csv, dtype={"SMControlTest.control.s[3:0]": str})
    df.columns = [col.strip() for col in df.columns]
    
    # Define required column names.
    cs_col   = "SMControlTest.control.reset_state[3:0]"  # current state
    start_col = "SMControlTest.control.start"
    mr_cols  = [
        "SMControlTest.control.mr3",
        "SMControlTest.control.mr2",
        "SMControlTest.control.mr1",
        "SMControlTest.control.mr0"
    ]
    s_col    = "SMControlTest.control.s[3:0]"  # next state (4-bit string)
    
    # Check that all required columns are present.
    for col in [cs_col, start_col] + mr_cols + [s_col]:
        if col not in df.columns:
            raise KeyError(f"Column '{col}' not found in DataFrame.")
    
    def matches(field, test_val):
        """Return True if the field from the CSV matches the test value,
           or if the field is a wildcard '-'."""
        return str(field).strip() == '-' or str(field).strip() == test_val
    
    # Initialize the reachable set and the queue with the initial state "0000".
    to_visit = ["0000"]
    reachable = set(["0000"])
    
    # Process states until no new states are found.
    while to_visit:
        cs = to_visit.pop(0)  # current state as a 4-bit string
        # For every combination of multiplier (0-15) and start (0,1)
        for multiplier in range(16):
            multiplier_bin = format(multiplier, '04b')
            for st in ['0', '1']:
                # Look for a matching row in the truth table.
                for idx, row in df.iterrows():
                    row_cs = str(row[cs_col]).zfill(4)
                    if row_cs != cs:
                        continue
                    if not matches(row[start_col], st):
                        continue
                    mr_match = True
                    for i, col_name in enumerate(mr_cols):
                        if not matches(row[col_name], multiplier_bin[i]):
                            mr_match = False
                            break
                    if not mr_match:
                        continue
                    # Row matches; extract next state from the s_col.
                    # Ensure it is a 4-bit binary string.
                    next_state = str(row[s_col]).zfill(4)
                    if next_state not in reachable:
                        reachable.add(next_state)
                        to_visit.append(next_state)
                    # Since the table is assumed deterministic for the combination, break after finding a match.
                    break

    # Filter the original DataFrame to include only rows where the current state (padded to 4 bits) is reachable.
    df_reachable = df[df[cs_col].apply(lambda x: str(x).zfill(4) in reachable)]
    
    # Save the resulting DataFrame to CSV and JSON.
    df_reachable.to_csv(output_csv, index=False)
    df_reachable.to_json(output_json, orient='records', lines=True)


remove_unreachable("SMTTNoDuplicates.csv", "SMTTReachable.csv", "SMTTReachable.json")
remove_unreachable("SMTTBruteForceNoDuplicates.csv", "SMTTBruteForceReachable.csv", "SMTTBruteForceReachable.json")