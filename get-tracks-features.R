# Author: Hugo Valenzuela
# ----------------------------------------------------------------
# This script downloads songs features from the Spotify API given
# a Spotify ID for the tracks. It's a direct request with HTTP
# using the httr package.
# ----------------------------------------------------------------


#installing and loading the required libraries 

library("httr")

# Authenticate to get the Access Token
response <- POST(
  "https://accounts.spotify.com/api/token",
  config = authenticate(user = Sys.getenv("SPOTIFY_ID"), 
                        password = Sys.getenv("SECRET_KEY")),
  body = list(grant_type = "client_credentials"), 
  encode = "form"
)

#extract content of response
token <-  content(response) 
# Paste the token_type with the access_token so it's in the format spotify api 
# needs it when making the authorization
bearer.token <- paste(token$token_type, token$access_token)


# ******** GET requests to retrieve features ********

# get features of just  1-track by its Spotify_ID (Santana - Oye Como Va)
features <- GET("https://api.spotify.com/v1/audio-features/5u6y4u5EgDv0peILf60H5t",
               config = add_headers(Authorization = bearer.token)
)

# get Catalog information about album with Search parameters