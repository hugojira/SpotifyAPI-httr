# ----------------------------------------------------------------
# This script downloads audio features from the Spotify API given
# a Spotify ID for 1-track or an album. It's a direct request with HTTP
# using the httr package.
# ----------------------------------------------------------------


#installing and loading the required libraries 

library(httr)
library(dplyr)

# ---------- Authenticate to get the Access Token ----------
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


# ---------- POST request to retrieve audio features of 1-track -----------

# get features of just  1-track by its Spotify_ID (Santana - Oye Como Va)

track.id <- "5u6y4u5EgDv0peILf60H5t"
track.response <- GET(paste0("https://api.spotify.com/v1/audio-features/",track.id),
               config = add_headers(Authorization = bearer.token)
)

track <- as_tibble(content( track.response ))
track.features <- track %>% select(c(1:11, 17, 18))

# ---------- POST request to retrieve audio features from a album -----------
 
# first, get the tracks info for an album
# Nevermind ID: 2guirTSEqLizK7j9i1MTTZ
# MTV Unplugged In New York ID : 1To7kv722A8SpZF789MZy7


album.id <- "2guirTSEqLizK7j9i1MTTZ"
album.response <-  GET(paste0("https://api.spotify.com/v1/albums/", album.id, "/tracks"),
                          config = add_headers(Authorization = bearer.token)
)


# ---- get tracks' list -----
album.content <- content(album.response)
album.songs <- album.content$items

# ----- unlist to get the songs' ids ------
aux <- unlist(album.songs)
filter.ids <- aux[ grep("^id$", names(aux)) ]
album.songs.ids <- cbind( as.character(filter.ids) )


# audio features for the tracks of the album

# retrieve features to a list
album.features <- lapply(1:length(album.songs.ids), function(i) {
  GET(url = paste0("https://api.spotify.com/v1/audio-features/", album.songs.ids[i]),
      config = add_headers(authorization = bearer.token))
}
)

# get the content of every element in the response list
album.features.content <- sapply(1:length(album.songs.ids), function(i) {
  content(album.features[[i]])
}
)

# convert lists to tibble and then unlist every column
songs.tidy <- as_tibble(t(album.features.content))
for (i in 1:length(songs.tidy)) {
  songs.tidy[,i] <- format (unlist( select(.data = songs.tidy, i), use.names = FALSE ),
                            scientific = FALSE)
}

# the only thing left is to select() the desired columns
songs.features <- songs.tidy %>% select(c(1:11, 17, 18)) 
songs.features

# export table to csv
write.csv(songs.features, file = "nevermind-features.csv", row.names = F)


