--[[
    This script reads a JSON file called "discovery.json" and parses the data using the dkjson library. 
    It then extracts the "host_list" field from the data and iterates over it. 
    For each host in the list, it extracts the "ip_v4_address" field and performs some basic validation to check that it's in a valid IP address format (i.e., four groups of numbers separated by periods). 
    If the IP address is valid, it runs an "nmap" command on that address and captures the output. 
    It then writes the output to a file named after the IP address (with a ".txt" extension).

    The script also includes some basic error handling to print error messages when the JSON file cannot be read, when the "host_list" field is not present in the JSON data, or when the "ip_v4_address" field is not present in a host object in the host list. 
    Additionally, it will print error messages when it fails to execute the nmap command or when it fails to open the output file.
]]

--- Author Kris Armstrong
--- January 12, 2023


local dkjson = require("dkjson")
local io = require("io")

function read_json_file(filepath)
    --- The function 'read_json_file' is used to read a JSON file and return its contents as a string.
    --- This function takes in one parameter, 'file_path', which is a string representing the file path of the JSON file.
    --- The function uses the 'io.open' method to open the file in read mode, and assigns the contents of the file to a variable 'json_data' using the ':read("*all")' method.
    --- The function then closes the file using the ':close()' method.
    --- The function returns the 'json_data' variable which contains the contents of the JSON file.
    --- If an error occurs while trying to open the file, the function will raise an error with a message indicating that the file was not found and to check the file path.
    
    local file, err = io.open(filepath, "r")
    if not file then
        error("Error: " .. err .. "\n" .. "JSON file not found, please make sure the file exists and the path is correct")
    end
    local json_data = file:read("*all")
    file:close()
    return json_data
end

function parse_json_data(json_data)
    --- The parse_json_data function takes in a string of JSON data as input
    --- It uses the dkjson library to parse the data and convert it into a Lua table
    --- The function returns the parsed data table, as well as any errors that may have occurred during parsing
    --- The purpose of this function is to take raw JSON data and convert it into a usable Lua table for the rest of the script to work with.
    
    local data, pos, err = dkjson.decode(json_data, 1, nil)
    if err then
        error("Error: " .. err)
    end
    return data
end


function get_host_list(data)
    -- Function: get_host_list
    -- Input: json_data (table)
    -- Output: host_list (table)
    -- Description: Extracts the host_list from the json_data and returns it.
    --              If host_list is not found or is not a table, an error is raised.

    local host_list = data.Detail.host_list
    if type(host_list) ~= "table" then
        error("Error: host_list is not a table")
    end
    return host_list
end


function run_nmap(ip_v4_address)
    --- The run_nmap function takes in a single argument, an IP address.
    --- It constructs an nmap command by concatenating the IP address with the nmap command string.
    --- The function then opens a handle to the command using io.popen() function
    --- It reads the output of the command by calling handle:read("*all")
    --- Closes the handle by calling handle:close()
    --- The output of the nmap command is returned by the function
    --- Run nmap command and capture output
    local nmap_command = "nmap " .. ip_v4_address
    local handle = io.popen(nmap_command)
    if not handle then
        error("Error: nmap command failed to execute: " .. nmap_command)
    end
    local output = handle:read("*all")
    handle:close()
    
    -- Write output to a file
    local output_file = io.open(ip_v4_address .. ".txt", "w")
    if not output_file then
        error("Error: failed to open output file for " .. ip_v4_address)
    end
    output_file:write(output)
    output_file:close()
    
    -- Read in the old discovery.json file
    local file,err = io.open("discovery.json", "r")
    if not file then
        error("Error: " .. err .. "\n" .. "JSON file not found, please make sure the file exists and the path is correct")
    end
    local json_data = file:read("*all")
    file:close()
    
    -- Parse the JSON data
    local data, pos, err = dkjson.decode(json_data, 1, nil)
    if err then
        error("Error: " .. err)
    end
    
    -- Update the data with new nmap output
    -- You'll need to implement this step, as it will depend on the structure of your discovery.json file
    -- and the format of the nmap output
    
    -- Write the updated data back to the original file
    local output_file = io.open("discovery_new.json", "w")
    if not output_file then
        error("Error: failed to open output file for " .. ip_v4_address)
    end
    output_file:write(dkjson.encode(data, { indent = true }))
    output_file:close()
end


function merge_data(old_data, new_data)
    -- Iterate over the new data and merge it with the old data
    for _, host in ipairs(new_data) do
        local ip_v4_address = host.host.ip_v4_address
        local nmap_output = host.host.nmap_output
        -- Find the corresponding host in the old data
        for _, old_host in ipairs(old_data.Detail.host_list) do
            if old_host.host.ip_v4_address == ip_v4_address then
                -- Merge the new data with the old data
                old_host.host.nmap_output = nmap_output
                print(nmap_output)
                break
            end
        end
    end
    return old_data
end


function write_output_to_file(ip_address, output)
    --- write_output_to_file: Writes the output of the nmap command to a file.
    --- Parameters:
    ---         ip_v4_address: The IP address that the nmap command was run on.
    ---         output: The output of the nmap command.
    --- Returns: None
    
    -- Open a file with the name of the IP address and write the output to it
    
    local output_file = io.open(ip_address .. ".txt", "w")
    if not output_file then
        print("Error: failed to open output file for " .. ip_address)
        return
    end
    output_file:write(output)
    output_file:close()
end


function main()
    -- Main function that scans a list of IP addresses using Nmap and writes the output to a text file.
    --
    -- Args:
    --   discovery_json_file: string, path to the discovery.json file
    --
    -- Returns:
    --   None
    --
    -- Globals:
    --   dkjson: the dkjson library
    --   io: the io library
    --
    -- Raises:
    --   Error: if discovery.json file cannot be opened or parsed, or if Nmap command fails to execute
    
    local json_data = read_json_file("discovery.json")
    local data = parse_json_data(json_data)
    local host_list = get_host_list(data)
    for _, host in ipairs(host_list) do
        local ip_v4_address = host.host.ip_v4_address
        if ip_v4_address then
            -- validate that the IP address is in a valid format
            if not ip_v4_address:match("^%d+%.%d+%.%d+%.%d+$") then
                print("Error: " .. ip_v4_address .. " is not a valid IP address")
            else
                local output = run_nmap(ip_v4_address)
                if output then
                    write_output_to_file(ip_v4_address, output)
                end
            end
        else
            print("Error: ip_v4_address is nil")
        end
    end
end

main()