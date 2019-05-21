import re
import csv
from os import listdir
from os.path import isfile, join
import csv

# either every 100 lines is a scene
# or new scenes are demarcated with lines that start with '['
mypath = "./"
scripts = []
OUTFILE = "script_data.csv" 
output_file = open(OUTFILE, 'w')
keys = ['character', 'dialogue', 'movie']
dict_writer = csv.DictWriter(output_file, keys)
dict_writer.writeheader()

onlyfiles = [f for f in listdir(mypath) if isfile(join(mypath, f))]
for f in onlyfiles:
	#if re.match(".*script.txt", f):
	if re.match(".*script.txt", f):

		scripts.append(f)

		movie = re.sub("_script.txt", "", f)
		filepath = f
		print f

		with open(filepath) as fp:  
			content = fp.readlines()

			for line in content:
	
				line = re.sub('\[.*\]', '', line)
				# get all caps words which represent characters most of the time
				character_match_1 = re.match(r'(\b[A-Z][A-Z]+\b):', line)
				character_match_2 = re.match(r'(\b[A-Z][a-z]+\b):\s+(.*)', line)

				if character_match_1 is not None:
					character = character_match_1.group(1)
					try: 
						dialogue = character_match_1.group(2)
					except:
						dialogue = ""
					dict_writer.writerow({'character': character, 'dialogue': dialogue, 'movie': movie})
				elif character_match_2 is not None:
					#print(line) 
					character = character_match_2.group(1)
					dialogue = character_match_2.group(2)
					dict_writer.writerow({'character': character, 'dialogue': dialogue, 'movie': movie})






with open(filepath) as fp:  
	content = fp.readlines()

# get all _script.txt files, put into database/csv

for line in content:
	m = re.match('^(\w+):', line)
	if m is not None:
		character = m.group(1)
		line = re.sub(character, '', line)
		character = re.sub(':', '', character)
		#print line



#try this - https://github.com/Adrien-Luxey/Da-Fonky-Movie-Script-Parser
# https://github.com/kvtoraman/Screenplay
# https://github.com/pratyakshs/Movie-script-parser
# https://github.com/usc-sail/mica-text-script-parser
# https://ask.metafilter.com/274007/Parsing-movie-TV-scripts
