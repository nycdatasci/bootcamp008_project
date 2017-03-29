import json 

# https://docs.mongodb.com/manual/core/2dsphere/
out_file = "test.geojson"
in_file = "/Users/jakebialer/Neuromancers-Kaggle/test.json"

# commands for importing into mongo
# After running this brew install jq and run the following 
# commands 
# jq --compact-output ".features" test.geojson > output.geojson

# mongoimport --db kaggle -c renthop_test1 --file "output.geojson" --jsonArray

data = json.load(open(in_file))



geojson = {
    "type": "FeatureCollection",
    "features": [
    {
        "type": "Feature",
        "geometry" : {
            "type": "Point",
            "coordinates": [data["longitude"].values()[i], data["latitude"].values()[i]],
            },
        "properties" : {
        "bathrooms": data['bathrooms'].values()[i],
        "bedrooms": data['bedrooms'].values()[i],
        "building_id": data['building_id'].values()[i],
        "created": data['created'].values()[i],
        "description": data['display_address'].values()[i],
        "features": data['features'].values()[i],
        # "interest_level": data['interest_level'].values()[i],
        "latitude": data['latitude'].values()[i],
        "listing_id": data['listing_id'].values()[i],
        "longitude": data['longitude'].values()[i],
        "manager_id": data['manager_id'].values()[i],
        "photos": data['photos'].values()[i],
        "price": data['price'].values()[i],
        "street_address": data['street_address'].values()[i]
        }

     } for i in range(len(data['listing_id'].values()))]
}


output = open(out_file, 'w')
json.dump(geojson, output)

