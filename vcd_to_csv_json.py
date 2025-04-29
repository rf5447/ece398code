import json
import pandas as pd
from vcdvcd import VCDVCD

# Function to parse VCD and convert to CSV/JSON, forward filling in blank entries
def vcd_to_csv_json(vcd_file, csv_output, json_output):
    vcd = VCDVCD(vcd_file)
    
    # Extract all signals and their time-value pairs
    data = {}
    for signal in vcd.signals:
        for timestamp, value in vcd[signal].tv:
            if timestamp not in data:
                data[timestamp] = {'time': timestamp}
            data[timestamp][signal] = value
    
    # Convert to DataFrame
    df = pd.DataFrame.from_dict(data, orient='index').sort_values(by='time')
    
    # Fill missing values with the previous value (forward fill)
    df.ffill(inplace=True)

    # Filter out rows where any value in the row is 'x'
    df = df[~df.apply(lambda row: row.astype(str).str.contains('x').any(), axis=1)]

    # Save to CSV
    df.to_csv(csv_output, index=False)
    print(f"CSV saved to {csv_output}")
    
    # Save to JSON
    df.to_json(json_output, orient='records', indent=4)
    print(f"JSON saved to {json_output}")

# Remove duplicate entries (rows where every single value except timestamp is the same)
def remove_duplicates(input_file, output_csv, output_json):
    # Read the CSV file
    df = pd.read_csv(input_file)
    
    # Drop duplicates based on all columns except the first one
    df_unique = df.drop_duplicates(subset=df.columns[1:], keep='first')
    
    # Save the result to a new CSV file
    df_unique.to_csv(output_csv, index=False)
    print(f"Duplicates removed. The result is saved in '{output_csv}'.")
    
    # Save the result to a new JSON file
    df_unique.to_json(output_json, orient='records', lines=True)
    print(f"The result is also saved in '{output_json}'.")

# Convert both VCD files
vcd_to_csv_json('SMTTInput.vcd', 'SMTTInput.csv', 'SMTTInput.json')
vcd_to_csv_json('SMTTInputBruteForce.vcd', 'SMTTInputBruteForce.csv', 'SMTTInputBruteForce.json')

# Remove duplicates
remove_duplicates('SMTTInput.csv', 'SMTTInputNoDuplicates.csv', 'SMTTInputNoDuplicates.json')
remove_duplicates('SMTTInputBruteForce.csv', 'SMTTInputBruteForceNoDuplicates.csv', 'SMTTInputBruteForceNoDuplicates.json')