# JSON_Discovery_nmap

**JSON Parser for Nmap Data**

This script is designed to parse a discovery.json file containing a list of IP addresses, and run an Nmap scan on each IP address. The output from Nmap is written to a text file with the same name as the IP address. Additionally, the script merges the original JSON data with the new data from the Nmap output, generating a new discovery.json file.

**Prerequisites**
Nmap must be installed on the system and accessible from the command line
dkjson must be installed and available to the script
A valid discovery.json file must be located in the same directory as the script
Usage

Copy code
lua json_parser.lua

**Functionality**
**read_json_file():** This function reads the discovery.json file and returns the data as a string.
**parse_json_data():** This function takes a JSON string as an argument, and uses dkjson to parse the data and return a Lua table.
**get_host_list():** This function takes a Lua table as an argument, and returns a list of host objects.
**run_nmap():** This function takes an IP address as an argument and runs an Nmap scan on it. It returns the output of the Nmap scan as a string.
**write_output_to_file():** This function takes an IP address and a string as arguments, and writes the string to a text file with the same name as the IP address.
**merge_json():** This function takes the original JSON data and the new data from the Nmap output, and merges them into a new JSON file.
The script can be further customize by editing the functions, for example to scan different ports or to run different Nmap options.

**Error Handling**
If Nmap is not installed or not in the system's PATH, the script will raise an error when trying to execute the Nmap command.
If the discovery.json file is not found or is not a valid JSON file, the script will raise an error when trying to parse the data.
If the dkjson library is not found, the script will raise an error when trying to parse the JSON data.
If the IP addresses in the discovery.json file are not in a valid format, the script will raise an error when trying to run the Nmap command.
If the output file cannot be created, the script will raise an error when trying to write the Nmap output to a file.

**Note**
This script is intended for educational and testing purposes only. Use of Nmap and other network scanning tools can be illegal in some jurisdictions and should be used with caution.
