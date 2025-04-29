import pandas as pd
import csv
import json
from collections import defaultdict
from copy import deepcopy

# Splits the input CSV's 4-bit column "SMControlTest.control.mr[3:0]" into four separate 1-bit columns
# Replaces the original column with these new columns, writing the new truth table to a CSV and JSON
def split_bits(input_csv, output_csv, output_json):
    # Read the CSV file.
    df = pd.read_csv(input_csv)
    
    # Remove extra whitespace from column names.
    df.columns = [col.strip() for col in df.columns]
    
    # Define the target column name.
    target_col = "SMControlTest.control.mr[3:0]"
    if target_col not in df.columns:
        print("Available columns:", df.columns)
        raise KeyError(f"Column '{target_col}' not found in DataFrame.")
    
    # Get the index of the target column for later insertion.
    insert_index = df.columns.get_loc(target_col)
    
    # Remove the target column from the DataFrame and capture its data.
    original_col = df.pop(target_col)
    
    # Convert each value to a 4-bit binary string and split it into individual bits.
    split_df = original_col.apply(lambda x: pd.Series(list(str(x).zfill(4))))
    
    # Rename the columns as required.
    split_df.columns = [
        "SMControlTest.control.mr3",  # most-significant bit
        "SMControlTest.control.mr2",
        "SMControlTest.control.mr1",
        "SMControlTest.control.mr0"   # least-significant bit
    ]
    
    # Insert the new columns into the original DataFrame at the location of the removed column.
    # Inserting in reverse order maintains the correct column order.
    for col_name in reversed(split_df.columns):
        df.insert(insert_index, col_name, split_df[col_name])
    
    # Write the resulting DataFrame to CSV.
    df.to_csv(output_csv, index=False)
    
    # Write the resulting DataFrame to JSON.
    df.to_json(output_json, orient='records', lines=True)

# Reads input CSV, determines, for each input column, 
# Determines if its value is irrelevant to the output and replaces such cells with "-", writing the result to CSV and JSON
def process_truth_table(input_csv, output_csv, output_json):
    # Define the column names (update these depending on CSV) (ignore clk, rst, n, other irrelevant variables)
    current_state_col = "SMControlTest.control.reset_state[3:0]"
    input_cols = ["SMControlTest.control.start", "SMControlTest.control.mr3", "SMControlTest.control.mr2", "SMControlTest.control.mr1", "SMControlTest.control.mr0"]
    output_cols = [
        "SMControlTest.control.s[3:0]",
        "SMControlTest.control.rsclear",
        "SMControlTest.control.mdld",
        "SMControlTest.control.mrld",
        "SMControlTest.control.rsload",
        "SMControlTest.control.rsshr"
    ]
    
    # Read the CSV into a list of dictionaries.
    with open(input_csv, newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        rows = list(reader)
    
    # Make a deep copy to modify the table (so that comparisons use original values)
    processed_rows = deepcopy(rows)
    
    # For each input column, check if its value is irrelevant.
    for input_col in input_cols:
        # For each row, create a grouping key excluding the candidate input_col.
        groups = defaultdict(list)
        for idx, row in enumerate(rows):
            # Build the key from current state, other input columns, and all output columns.
            other_inputs = tuple(row[col] for col in input_cols if col != input_col)
            outputs = tuple(row[col] for col in output_cols)
            key = (row[current_state_col],) + other_inputs + outputs
            groups[key].append(idx)
        
        # In each group, if there is more than one row, then the candidate input's value did not affect the outputs.
        # Mark that input field as "-" in all corresponding rows.
        for group in groups.values():
            if len(group) > 1:
                values = {rows[i][input_col] for i in group}
                if len(values) > 1:
                    for i in group:
                        processed_rows[i][input_col] = "-"
    
    # Write the processed data to CSV.
    fieldnames = rows[0].keys()  # using the same header order as input
    with open(output_csv, 'w', newline='') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(processed_rows)
    
    # Write the processed data to JSON.
    with open(output_json, 'w') as jsonfile:
        json.dump(processed_rows, jsonfile, indent=2)

# Remove irrelevant columns and duplicates to clean up truth table
def remove_irrelevant_columns(input_file, output_csv, output_json):
    # Define the irrelevant columns that should be dropped.
    irrelevant_cols = [
        "SMControlTest.control.rst", 
        "SMControlTest.control.clk", 
        "SMControlTest.control.n[3:0]"
    ]
    
    # Read the CSV file into a DataFrame.
    df = pd.read_csv(input_file)
    
    # Drop the irrelevant columns.
    df_reduced = df.drop(columns=irrelevant_cols, errors='ignore')
    
    # Drop duplicates from the reduced DataFrame.
    df_unique = df_reduced.drop_duplicates(keep='first')
    
    # Save the resulting DataFrame to a new CSV file.
    df_unique.to_csv(output_csv, index=False)
    print(f"Irrelevant columns removed. The result is saved in '{output_csv}'.")
    
    # Save the resulting DataFrame to a new JSON file.
    df_unique.to_json(output_json, orient='records', lines=True)
    print(f"The result is also saved in '{output_json}'.")

split_bits("SMTTInputClkRst.csv", "SMTTInputClkRstBit.csv", "SMTTInputClkRstBit.json")
split_bits("SMTTInputBruteForceClkRst.csv", "SMTTInputBruteForceClkRstBit.csv", "SMTTInputBruteForceClkRstBit.json")

process_truth_table("SMTTInputClkRstBit.csv", "SMTT.csv", "SMTT.json")
process_truth_table("SMTTInputBruteForceClkRstBit.csv", "SMTTBruteForce.csv", "SMTTBruteForce.json")

remove_irrelevant_columns("SMTT.csv", "SMTTNoDuplicates.csv", "SMTTNoDuplicates.json")
remove_irrelevant_columns("SMTTBruteForce.csv", "SMTTBruteForceNoDuplicates.csv", "SMTTBruteForceNoDuplicates.json")