#!/bin/bash
bucket_name="data-met-api"
path="raw-objects"

# List of object IDs
ids_objects=(335538 436527 436530 436532 436529 436525 436534 336318 436526 437998 436533 436531 436535 335537 336327 437980 436528 459193 437984 335536 459123 436524 436536 438722)
total_objects=${#ids_objects[@]}

# Query
query=' select(.objectEndDate >= 1888) | {title_name: .title, date: .objectBeginDate, artist_name: .constituents[0].name, tags_name: [.tags[].term] }'
json_output="" 

# Imprimir los IDs de objetos
for (( i=0; i<total_objects; i++ )); do
    id=${ids_objects[$i]}
    # Download the JSON file from S3 and extract the required fields
    response=$(aws s3 cp s3://$bucket_name/$path/object_id_$id.json - 2>/dev/null | jq "$query")  # Capturar la salida correctamente
    
    # Validate the json_output variable is empty and add the response 
    if [ ! -z "$response" ]; then
        if [ -z "$json_output" ]; then
            json_output="$response"
        else
            json_output+=", $response"
        fi
    else
        echo "Warning: No valid data found for ID $id"
    fi

    progress=$(( (i + 1) * 100 / total_objects ))
    printf "\rProgress: [%-50s] %d%%" "$(printf '#%.0s' $(seq 1 $((progress / 2))))" "$progress"
    
done

# Create JSON array
json_output="[$json_output]"

# Create the output.json file
echo "$json_output" > output.json
