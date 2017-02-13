import sys

file_to_analyze = sys.argv[1]
print("Analyzing %s"%file_to_analyze)

db={}

with open(file_to_analyze,"r") as f:
	for line in f:
		sha1,author,score,file_name = line.split(":")

		if author not in db:
			db[author] = {"modif":0, "diff":0,"max":-100, "min":100,"sha_list":{}}

		db[author]['modif'] += 1
		db[author]['diff'] += float(score)
		db[author]['max'] = max(float(score),float(db[author]['max']))
		db[author]['min'] = min(float(score),float(db[author]['min']))
		db[author]['sha_list'][sha1] = 1

print("%10s | %3s | %5s | %10s | %10s | %10s"%("author","ci","count","score",'min','max'))
for author in db:
	print("%10s | %3s | %5s | %10f | %10f | %10f"%(author,len(db[author]['sha_list']),db[author]['modif'],db[author]['diff'],db[author]['min'],db[author]['max']))
