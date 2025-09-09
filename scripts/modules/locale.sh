function locale::location() {
    # Usage:
    #   locale::location
    #
    # Returns location info based on IP
    # Uses ipinfo.io free token (login with github)

    local TOKEN="4c132caf0e6b7a"
    local URL="ipinfo.io?token=${TOKEN}"
    ERR_FILE="$HOME/.cache/eww-location.out"
    o=$(curl -m 10 ${URL} 2>${ERR_FILE})
    OK=$?
    ERR=$(<${ERR_FILE})
    rm ${ERR_FILE}
    if (( $OK != 0 )); then
        >&2 echo "[ERR] locale::location"
        >&2 echo "$ERR"
        >&2 echo "$o"
        echo "{}"
        return 1
    fi
    echo "$o" | jq -c
}

function locale::weather() {
    # Usage:
    #   locale::weather
    #
    # Returns local weather information

    local SYMBOLS='{
        "Unknown":             "✨",
        "Clear":               "☀️",
        "Cloudy":              "☁️",
        "VeryCloudy":          "☁️",
        "Fog":                 "🌫",
        "Mist":                "🌫",
        "HeavyRain":           "🌧",
        "HeavyShowers":        "🌧",
        "HeavySnow":           "❄️",
        "HeavySnowShowers":    "❄️",
        "LightRain":           "🌦",
        "LightShowers":        "🌦",
        "LightSleet":          "🌧",
        "LightSleetShowers":   "🌧",
        "LightSnow":           "🌨",
        "LightSnowShowers":    "🌨",
        "Overcast":            "☁️",
        "PartlyCloudy":        "⛅️",
        "Sunny":               "☀️",
        "ThunderyHeavyRain":   "🌩",
        "ThunderyShowers":     "⛈",
        "ThunderySnowShowers": "⛈"
    }'

    ERR_FILE="$HOME/.cache/eww-weather.out"
    local location=$(locale::location 2>${ERR_FILE} | jq '[.city, .region] | join("+") | gsub(" "; "+")')
    local URL="v2d.wttr.in/${location}?format=j1"
    o=$(curl -m 10 ${URL} 2>${ERR_FILE})
    OK=$?
    ERR=$(<${ERR_FILE})
    rm ${ERR_FILE}
    # Handle when the service is down
    if (( $OK != 0 )) || [[ "$o" =~ "Unknown location" ]]; then
        >&2 echo "[ERR] locale::weather"
        >&2 echo "$ERR"
        >&2 echo "$o"
        echo "{}"
        return 1
    fi
    o_FeelsLikeC=$(echo "$o" | jq -r '.current_condition[0].FeelsLikeC')
    o_FeelsLikeF=$(echo "$o" | jq -r '.current_condition[0].FeelsLikeF')
    o_TempC=$(echo "$o" | jq -r '.current_condition[0].temp_C')
    o_TempF=$(echo "$o" | jq -r '.current_condition[0].temp_F')
    o_Loc="$(echo "$o" | jq -r '.nearest_area[0].areaName[0].value'), $(echo "$o" | jq -r '.nearest_area[0].region[0].value')"
    o_weatherDesc="$(echo "$o" | jq -r '.current_condition[0].weatherDesc[0].value' | sed 's/\([[:blank:]][[:lower:]]\)/\U\1/g')"
    o_weatherIco=$(echo "$SYMBOLS" | jq -r ".$(echo "$o_weatherDesc" | sed 's/[[:blank:]]\(.\)/\1/g')")
    echo '{
        "FeelsLikeC": "'$o_FeelsLikeC'",
        "FeelsLikeF": "'$o_FeelsLikeF'",
        "TempC": "'$o_TempC'",
        "TempF": "'$o_TempF'",
        "Loc": "'$o_Loc'",
        "Desc": "'$o_weatherDesc'",
        "Icon": "'$o_weatherIco'"
    }' | jq -c
}

