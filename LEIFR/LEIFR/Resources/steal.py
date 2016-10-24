import shutil
import requests
import os.path
from multiprocessing.dummy import Pool as ThreadPool

template = 'https://api.mapbox.com/styles/v1/echx/cit1xa01k00112wljpa9qu6dg/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoiZWNoeCIsImEiOiJjaXBwZjhhZDcwM3RzZm1uYzVmM2E5MjhtIn0.Z3Qh-zpuvIf7KlVZLCRutA'
coords = [];

for z in xrange(8):
  for x in xrange(2 ** z):
    for y in xrange(2 ** z):
      coords.append({'z': z, 'y': y, 'x': x})

def retrieve(coord):
  fname = 'tiles/{z}-{x}-{y}.png'.format(z = coord['z'], x = coord['x'], y = coord['y'])
  if not os.path.isfile(fname):
    url = template.format(z = coord['z'], x = coord['x'], y = coord['y'])
    response = requests.get(url, stream = True)
    with open(fname, 'wb') as out_file:
        shutil.copyfileobj(response.raw, out_file)
    del response

pool = ThreadPool(30)
pool.map(retrieve, coords)
pool.close()
