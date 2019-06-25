from sampler import Sampler
import sys

class DummyFactory:
	def sample(self, ext, dbb):
		size = 10**(dbb/10.0)
		return ((ext, dbb), size)

	def count(self, ext, dbb):
		return float('inf') # or float(10**16) for the same effect

args = sys.argv[1:]
if len(args) != 3:
	print 'usage: python estimate_bins.py extension ../stats/foo.summary.psv mbytes'
	sys.exit(1)
ext, summary, mbytes = args

stats, total_bytes = Sampler(summary, DummyFactory()).get_files_for_ext(ext, 1000000 * int(mbytes))
for ext, dbb in stats:
	print dbb
