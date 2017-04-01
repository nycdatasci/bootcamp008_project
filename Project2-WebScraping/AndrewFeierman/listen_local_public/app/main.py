import json
from flask import Flask, request, redirect, g, render_template, jsonify
import requests
import base64
import urllib
import spotipy
import spotipy.util as util
import pandas as pd
import re

# Authentication Steps, parameters, and responses are defined at https://developer.spotify.com/web-api/authorization-guide/
# Visit this url to see all the steps, parameters, and expected response. 

app = Flask(__name__)

#Concert data, scraped from songkick.com
concerts = pd.read_csv("concerts_clean.csv", index_col=0, encoding='utf-8')
concerts['date'] = pd.to_datetime(concerts['date'], format = "%Y/%m/%d")
venues = list(set(concerts['venue']))

#  Client Keys
CLIENT_ID = ""
CLIENT_SECRET = ""

# Spotify URLS
SPOTIFY_AUTH_URL = "https://accounts.spotify.com/authorize"
SPOTIFY_TOKEN_URL = "https://accounts.spotify.com/api/token"
SPOTIFY_API_BASE_URL = "https://api.spotify.com"
API_VERSION = "v1"
SPOTIFY_API_URL = "{}/{}".format(SPOTIFY_API_BASE_URL, API_VERSION)


# Server-side Parameters
CLIENT_SIDE_URL = "http://127.0.0.1"
PORT = 8080
REDIRECT_URI = "{}:{}/callback/q".format(CLIENT_SIDE_URL, PORT)
SCOPE = "playlist-modify-public playlist-modify-private"
STATE = ""
SHOW_DIALOG_bool = True
SHOW_DIALOG_str = str(SHOW_DIALOG_bool).lower()

# Give IDs to Spotipy
SPOTIPY_CLIENT_ID = CLIENT_ID
SPOTIPY_CLIENT_SECRET = CLIENT_SECRET
SPOTIPY_REDIRECT_URI = REDIRECT_URI

#globals that I should fix later, once I understand web frameworks and authorization more
spotipy_token = ""
spotipy_username = ""

auth_query_parameters = {
    "response_type": "code",
    "redirect_uri": REDIRECT_URI,
    "scope": SCOPE,
    # "state": STATE,
    # "show_dialog": SHOW_DIALOG_str,
    "client_id": CLIENT_ID
}

@app.route("/")
def index():
    # Auth Step 1: Authorization
    url_args = "&".join(["{}={}".format(key,urllib.quote(val)) for key,val in auth_query_parameters.iteritems()])
    auth_url = "{}/?{}".format(SPOTIFY_AUTH_URL, url_args)
    return redirect(auth_url)


@app.route("/callback/q")
def callback():
    global spotipy_token
    global spotipy_username
    # Auth Step 4: Requests refresh and access tokens
    auth_token = request.args['code']
    code_payload = {
        "grant_type": "authorization_code",
        "code": str(auth_token),
        "redirect_uri": REDIRECT_URI
    }
    base64encoded = base64.b64encode("{}:{}".format(CLIENT_ID, CLIENT_SECRET))
    headers = {"Authorization": "Basic {}".format(base64encoded)}
    post_request = requests.post(SPOTIFY_TOKEN_URL, data=code_payload, headers=headers)

    # Auth Step 5: Tokens are Returned to Application
    response_data = json.loads(post_request.text)
    access_token = response_data["access_token"]
    refresh_token = response_data["refresh_token"]
    token_type = response_data["token_type"]
    expires_in = response_data["expires_in"]


    # Auth Step 6: Use the access token to access Spotify API
    authorization_header = {"Authorization":"Bearer {}".format(access_token)}

    # Get profile data
    user_profile_api_endpoint = "{}/me".format(SPOTIFY_API_URL)
    profile_response = requests.get(user_profile_api_endpoint, headers=authorization_header)
    profile_data = json.loads(profile_response.text)

    # Get user playlist data (currently unused)
    playlist_api_endpoint = "{}/playlists".format(profile_data["href"])
    playlists_response = requests.get(playlist_api_endpoint, headers=authorization_header)
    playlist_data = json.loads(playlists_response.text)
    
    # Combine profile and playlist data to display
    display_arr = ["You are logged in as: "] + [profile_data['id']]

    #reluctantly setting global variables for spotipy
    spotipy_token = access_token
    spotipy_username = profile_data['id']

    #return data for the display
    return render_template("index.html", sorted_array=display_arr, concerts = concerts, venues = venues)

@app.route('/create_playlist')
def create_playlist():

    try:
        datefrom = request.args.get('from', 0, type=str) 
        datefrom = datefrom.replace("/", "-")
        dateto = request.args.get('to', 0, type=str)
        dateto = dateto.replace("/", "-")
        venue = request.args.get('venue', 0, type=str)
        user_message = "Playlist created! " + datefrom + " - " + dateto + " at " + venue
        run_listen_local(venue)
        return jsonify(result=user_message)
    except Exception as e:
        return jsonify(result="Uh oh, something went wrong. Did you fill in the date range and select a venue?" + str(e))

#concert retrieval functions below

def get_venue_artists(venue, start_date = "2017-01-01", end_date = "2017-12-31"):
    concert_dates = pd.date_range(start = start_date, end = end_date, freq = 'D')
    artists = []
    for show in concerts.loc[concerts['venue'] == venue, ['date', 'artist']].itertuples():
        if show[1] in concert_dates:
            artists.append(show)
    return artists

def get_artist_ids(artists):
    sp = spotipy.Spotify()
    artist_plus_ids = []
    for artist in artists:
        search = sp.search(q=artist, type = 'artist', limit = 1)
        try:
            artist_plus_ids.append((search['artists']['items'][0]['name'] ,  search['artists']['items'][0]['id']))
        except IndexError:
            pass
    return artist_plus_ids

def get_venue_artist_ids(venue, start_date = "2017-01-01", end_date = "2017-12-31"):
    sp = spotipy.Spotify()
    artists = get_venue_artists(venue, start_date, end_date)
    artist_plus_ids = []
    for artist in artists:
        search = sp.search(q=artist[2], type = 'artist', limit = 1)
        try:
            artist_plus_ids.append((search['artists']['items'][0]['name'] ,  search['artists']['items'][0]['id']))
        except IndexError:
            pass
    return artist_plus_ids

def create_venue_songlist(venue, start_date = "2017-01-01", end_date = "2017-12-31"):
    sp = spotipy.Spotify()
    songlist = []
    num_tracks = 5
    if (start_date == "2017-01-01") and (end_date == "2017-12-31"):
        num_tracks = 1
    for artist in get_venue_artist_ids(venue, start_date, end_date):
        artist_tracks = sp.artist_top_tracks(artist[1])['tracks']
        if len(artist_tracks) >= num_tracks:
            for track in range(0, num_tracks):
                songlist.append((artist_tracks[track]['name'], artist_tracks[track]['id']))
    return songlist

def prepare_song_id_list(songlist):
    song_ids = []
    for song in songlist:
        song_ids.append(str(song[1]))
    return song_ids

def create_venue_songlist_ids(venue, start_date = "2017-01-01", end_date = "2017-12-31"):
    songlist = create_venue_songlist(venue, start_date, end_date)
    #the max length for playlists created via the spotify API is 100 songs, so truncate the song list if it's too long
    if len(songlist) >= 100:
        songlist = songlist[0:99]
    ptitle = ("%s from %s to %s") % (venue, start_date, end_date)
    return (ptitle, prepare_song_id_list(songlist))

#create_venue_songlist_ids returns a tuple with the playlist title, and a list of Spotify song IDs
#main function below (this is what the webapp calls)

def run_listen_local(venue, start_date = "2017-03-01", end_date = "2017-12-31"):
    global spotipy_token
    global spotipy_username
    playlist_prepped = create_venue_songlist_ids(venue, start_date, end_date)
    playlist_title = playlist_prepped[0]
    track_ids = playlist_prepped[1]
    if spotipy_token:
        sp = spotipy.Spotify(auth=spotipy_token)
        sp.trace = False #Not sure if this is needed
        sp.user_playlist_create(spotipy_username, playlist_title)
        playlists = sp.user_playlists(spotipy_username)
        for playlist in playlists['items']:
            if playlist['name'] == playlist_title:
                playlist_id = playlist['id']
                break
        results = sp.user_playlist_add_tracks(spotipy_username, playlist_id, track_ids)
        print("Playlist created! %s") % (results)
    else:
        print("Authentication failed. Can't get token.")

if __name__ == "__main__":
    app.run(debug=True,port=PORT)
