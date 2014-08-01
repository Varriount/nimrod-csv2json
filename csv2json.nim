# CSV to JSON converter module for Nimrod.

# Written by Adam Chesak.
# Code released under the MIT open source license.


# Import modules.
import parsecsv
import streams
import strutils
import json


proc parseCSV(csv : string, filenameOut : string, separator : char = ',', quote : char = '\"', escape : char = '\0', skipInitialSpace : bool = true): seq[seq[string]]
proc toJSON*(csv : string, filenameOut: string, separator : char = ',', quote : char = '\"', escape : char = '\0', skipInitialSpace : bool = true): PJsonNode
proc toJSONString*(csv : string, filenameOut: string, separator : char = ',', quote : char = '\"', escape : char = '\0', skipInitialSpace : bool = true): string


proc parseCSV(csv : string, filenameOut : string, separator : char = ',', quote : char = '\"', escape : char = '\0', skipInitialSpace : bool = true): seq[seq[string]] = 
    ## Parses the CSV and returns it as a sequence of sequences.
    
    # Parse the CSV.
    var stream : PStringStream = newStringStream(csv)
    var csvParser : TCsvParser
    csvParser.open(stream, filenameOut, skipInitialSpace = skipInitialSpace, separator = separator, quote = quote, escape = escape)
    
    # Loop through the lines and add them to the sequence.
    var csvSeq = newSeq[seq[string]](len(csv.splitLines()))
    var c : int = 0
    while readRow(csvParser):
        
        var csvSeq2 = newSeq[string](len(csvParser.row))
        for i in 0..high(csvParser.row):
            csvSeq2[i] = csvParser.row[i]
        csvSeq[c] = csvSeq2
        c += 1
    
    return csvSeq


proc toJSON*(csv : string, filenameOut: string, separator : char = ',', quote : char = '\"', escape : char = '\0', skipInitialSpace : bool = true): PJsonNode = 
    ## Parses the CSV and returns it's JSON representation as a PJsonNode. filenameOut is only used for error messages. See Nimrod's parsecsv docs for information on other parameters.
    
    # Parse the CSV then parse the string to JSON.
    var njson : string = toJSONString(csv, filenameOut, separator, quote, escape, skipInitialSpace)
    var json : PJsonNode = parseJSON(njson)
    
    return json


proc toJSONString*(csv : string, filenameOut: string, separator : char = ',', quote : char = '\"', escape : char = '\0', skipInitialSpace : bool = true): string = 
    ## Parses the CSV and returns it as a string containing the JSON. filenameOut is only used for error messages. See Nimrod's parsecsv docs for information on other parameters.
    
    # Parse the CSV.
    var ncsv = parseCSV(csv, filenameOut, separator, quote, escape, skipInitialSpace)
    
    # Convert the CSV to a string.
    var json : string = "{\"data\":["
    for i in 0..high(ncsv) - 1:
        json &= "["
        for j in 0..high(ncsv[i]):
            json &= "\"" & ncsv[i][j] & "\""
            if j != len(ncsv[i]) - 1:
                json &= ","
        json &= "]"
        if i != high(ncsv) - 1:
            json &= ","
    json &= "]}"
    
    return json
