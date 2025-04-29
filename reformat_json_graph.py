import json
import ast
import pprint

# Reformat JSON to exact format needed by Marina's algorithm
def reformat_json(input_json_path, output_json_path):
    # Load the JSON from file
    with open(input_json_path, "r") as infile:
        data = json.load(infile)
    
    # Process each key-value pair
    new_data = {}
    for key, value in data.items():
        # 'value' is expected to be a list of two strings,
        # each string should represent a list (e.g. "['0', '1']")
        new_list = []
        for item in value:
            # Check if the item is a string representing a list.
            if isinstance(item, str) and item.startswith("[") and item.endswith("]"):
                try:
                    parsed_item = ast.literal_eval(item)
                    new_list.append(parsed_item)
                except Exception:
                    # If evaluation fails, leave the item as is.
                    new_list.append(item)
            else:
                new_list.append(item)
        new_data[key] = new_list
    
    # Write out the reformatted data using pprint.pformat to produce a string with single quotes.
    formatted = pprint.pformat(new_data)
    with open(output_json_path, "w") as outfile:
        outfile.write(formatted)
    print(f"Reformatted JSON written to {output_json_path}")

# Output JSONs ready for taint tracking with taint-kill
reformat_json("Fig2\SMTTCauseGraph.json", "SMTTFig2.json")
reformat_json("Fig3\SMTTCauseGraph.json", "SMTTFig3.json")
reformat_json("Fig4\SMTTCauseGraph.json", "SMTTFig4.json")