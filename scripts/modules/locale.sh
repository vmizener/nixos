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

    # See wttr.in constants for code/icon mappings
    # https://github.com/chubin/wttr.in/blob/master/lib/constants.py
    local WEATHER_CODES='{
        "113": "Sunny",
        "116": "PartlyCloudy",
        "119": "Cloudy",
        "122": "VeryCloudy",
        "143": "Fog",
        "176": "LightShowers",
        "179": "LightSleetShowers",
        "182": "LightSleet",
        "185": "LightSleet",
        "200": "ThunderyShowers",
        "227": "LightSnow",
        "230": "HeavySnow",
        "248": "Fog",
        "260": "Fog",
        "263": "LightShowers",
        "266": "LightRain",
        "281": "LightSleet",
        "284": "LightSleet",
        "293": "LightRain",
        "296": "LightRain",
        "299": "HeavyShowers",
        "302": "HeavyRain",
        "305": "HeavyShowers",
        "308": "HeavyRain",
        "311": "LightSleet",
        "314": "LightSleet",
        "317": "LightSleet",
        "320": "LightSnow",
        "323": "LightSnowShowers",
        "326": "LightSnowShowers",
        "329": "HeavySnow",
        "332": "HeavySnow",
        "335": "HeavySnowShowers",
        "338": "HeavySnow",
        "350": "LightSleet",
        "353": "LightShowers",
        "356": "HeavyShowers",
        "359": "HeavyRain",
        "362": "LightSleetShowers",
        "365": "LightSleetShowers",
        "368": "LightSnowShowers",
        "371": "HeavySnowShowers",
        "374": "LightSleetShowers",
        "377": "LightSleet",
        "386": "ThunderyShowers",
        "389": "ThunderyHeavyRain",
        "392": "ThunderySnowShowers",
        "395": "HeavySnowShowers"
    }'
    local WEATHER_SYMBOLS='{
        "Unknown":              "✨",
        "Cloudy":               "☁️",
        "Fog":                  "🌫",
        "HeavyRain":            "🌧",
        "HeavyShowers":         "🌧",
        "HeavySnow":            "❄️",
        "HeavySnowShowers":     "❄️",
        "LightRain":            "🌦",
        "LightShowers":         "🌦",
        "LightSleet":           "🌧",
        "LightSleetShowers":    "🌧",
        "LightSnow":            "🌨",
        "LightSnowShowers":     "🌨",
        "PartlyCloudy":         "⛅️",
        "Sunny":                "☀️",
        "ThunderyHeavyRain":    "🌩",
        "ThunderyShowers":      "⛈",
        "ThunderySnowShowers":  "⛈",
        "VeryCloudy":           "☁️"
    }'

    ERR_FILE="$HOME/.cache/locale-weather.out"
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
    o_weatherCode="$(echo "$o" | jq -r '.current_condition[0].weatherCode')"
    iconKey=$(echo "$WEATHER_CODES" | jq -r ".[\"$(echo "$o_weatherCode")\"]")
    o_weatherIco=$(echo "$WEATHER_SYMBOLS" | jq -r ".$(echo "$iconKey")")
    o_weatherDesc="$(echo "$o" | jq -r '.current_condition[0].weatherDesc[0].value' | sed 's/\([[:blank:]][[:lower:]]\)/\U\1/g')"
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

