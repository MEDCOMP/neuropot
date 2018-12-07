import subprocess

def n4():
	process = subprocess.Popen(['ls','-l'], shell=True, stdout=subprocess.PIPE)
	_res = []
	for line in process.stdout:
	    _res.append(line)
	process.wait()
	return _res