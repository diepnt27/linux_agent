import json

with open('/tmp/a.txt') as f:
    lines = [line.rstrip() for line in f]
for a in lines:
    #a = a[:-2]
    #request = a.split(',')[6].split(':')[2].replace('"','')
    request = a.split(',')[7]
    #if 'Referer' in request:
    print('request: %s' % request)
    if 'POST' in request:
        body = a.split(',')[-2]
        print(body)
    print('------------------------------------------')
