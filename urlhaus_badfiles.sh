#!/bin/bash
# Automating the search and download of bad files to download from URLhaus submissions
# Author: Lauren Proehl

# Grabs system date for finding closest API search matches
DATE=$(date "+%Y-%m-%d")

# Output file for samples to be downloaded
RESULTS="~/urlhaus_temp.csv"

# Temporary output file for storing URLScan result IDs
TMP="~/urlhaus_temp.txt"

# Clear output files before beginning
>"$TMP"
>"$RESULTS"

# Download the most recent URLHaus CSV list using wget and rename the csv to urlhaus_temp.csv
wget -O "$RESULTS" "https://urlhaus.abuse.ch/downloads/csv_online/"

# Use awk to sort the csv and check only for current date hits that end in files, and not directories. Print the date and url to a new file.
awk -F "\"*,\"*" '{ if (($2 ~ "'$DATE'") && ($3 !~ /\/$/)) print $2,$3 }' "$RESULTS" | sort -u -k2,2 | sort -r > "$TMP"

# While reading the temporary holding file, try to download the suspicious files. Ignore certificates, try a max of 3 times, and only wait 3s between tries.
while read first second third; do
# Use custom headers to be less suspicious, emulating Google Chrome on a Windows 10 endpoint in English speaking country
	wget --header='User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36' \
	--header='Accept-Encoding: compress, gzip' --header='Accept-Language: en-US,en;q=0.5'\
	"$third" --tries=3  --waitretry=3 --retry-connrefused --no-check-certificate
done < "$TMP"

<<COMMENT
	Here are some other header variations you can try:

	User Agents
	(Yandex Browser) --header='User-Agent: Mozilla/5.0 (Windows NT 6.3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.70 YaBrowser/19.7.3.172 Yowser/2.5 Safari/537.36'
	(Most Recent Chrome) --header='User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.70 Safari/537.36'
	(IE11 Windows 10) --header='User-Agent: Mozilla/5.0 (Windows NT 10.0; Trident/7.0; rv:11.0) like Gecko'
	(IE10 Windows 7) --header='User-Agent: Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; WOW64; Trident/6.0)'

	Accept-Encoding
	(Any Content Encoding not listed) --header='Accept-Encoding: *'
	(Compression Formats except zlib) --header='Accept-Encoding: gzip, compress, br'

	Languages
	(Danish but will accept British English or other English) --header='Accept-Language: da, en-gb;q=0.8, en;q=0.7'
	(Russian) --header='Accept-Language: ru-RU, ru;q=0.9'
	(Chinese) --header='Accept-Language: zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5'
	(United Kingdom) --header='Accept-Language: en-GB'

COMMENT
