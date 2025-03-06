SOURCE_URL:="https://api.weather.gov/alerts/active?status=actual&area=CA&code=HWW"
# SOURCE_URL:="https://s3.amazonaws.com/media.johnkeefe.net/data/example_warnings.json"

all: clean download warnings

download:
	-mkdir tmp
	wget --continue --progress=dot:mega --waitretry=60 ${SOURCE_URL} \
		--header='accept: application/geo+json' \
		--header='User-Agent: (nytimes.com, john.keefe@nytimes.com)' \
		-O tmp/download.json

warnings:
	node warnings.js

slack:
	node warnings-slack.js

clean:
	-rm ./tmp/download.json
