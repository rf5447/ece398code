import pandas as pd

# Filter columns with 'SMControlTest.control' in the column name, reorder them, and save as CSV and JSON
def filter_control_columns(input_csv, output_csv, output_json):
    # Load the CSV into a DataFrame
    df = pd.read_csv(input_csv)
    
    # Filter columns that contain 'SMControlTest.control' in the column name
    filtered_df = df.filter(regex='^SMControlTest.control')
    
    # Define the desired column order (with full prefix)
    column_order = [
        'SMControlTest.control.reset_state[3:0]',

        'SMControlTest.control.start', 
        'SMControlTest.control.mr[3:0]', 
        'SMControlTest.control.s[3:0]', 

        'SMControlTest.control.rsclear', 
        'SMControlTest.control.mdld', 
        'SMControlTest.control.mrld', 
        'SMControlTest.control.rsload', 
        'SMControlTest.control.rsshr', 
        'SMControlTest.control.rst', 
        'SMControlTest.control.clk',
        'SMControlTest.control.n[3:0]', 

    ]
    
    # Reorder columns if they exist in the filtered DataFrame
    # Only select columns that exist in both filtered DataFrame and the column_order list
    filtered_df = filtered_df[[col for col in column_order if col in filtered_df.columns]]
    
    # Save the filtered and reordered DataFrame to a new CSV
    filtered_df.to_csv(output_csv, index=False)
    print(f"Filtered CSV saved to {output_csv}")
    
    # Save the filtered and reordered DataFrame to a new JSON
    filtered_df.to_json(output_json, orient='records', indent=4)
    print(f"Filtered JSON saved to {output_json}")

# Function to filter rows where rst = 0 and clk = 1 and remove duplicates
def filter_rst_clk(input_csv, output_csv, output_json):
    # Load the CSV into a DataFrame
    df = pd.read_csv(input_csv)
    
    # Filter rows where 'rst' is 0 and 'clk' is 1
    filtered_df = df[(df['SMControlTest.control.rst'] == 0) & (df['SMControlTest.control.clk'] == 1)]
    
    # Remove duplicate rows
    filtered_df = filtered_df.drop_duplicates()
    
    # Save the filtered and deduplicated DataFrame to a new CSV
    filtered_df.to_csv(output_csv, index=False)
    print(f"Filtered CSV saved to {output_csv}")
    
    # Save the filtered and deduplicated DataFrame to a new JSON
    filtered_df.to_json(output_json, orient='records', indent=4)
    print(f"Filtered JSON saved to {output_json}")

# Filter control columns
filter_control_columns('SMTTInputNoDuplicates.csv', 'SMTTInputNoDuplicatesControl.csv', 'SMTTInputNoDuplicatesControl.json')
filter_control_columns('SMTTInputBruteForceNoDuplicates.csv', 'SMTTInputBruteForceNoDuplicatesControl.csv', 'SMTTInputBruteForceNoDuplicatesControl.json')

# Filter rows
filter_rst_clk('SMTTInputNoDuplicatesControl.csv', 'SMTTInputClkRst.csv', 'SMTTInputClkRst.json')
filter_rst_clk('SMTTInputBruteForceNoDuplicatesControl.csv', 'SMTTInputBruteForceClkRst.csv', 'SMTTInputBruteForceClkRst.json')