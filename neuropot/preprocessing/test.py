import subprocess

def gen(filename):
	process = subprocess.Popen('mkfile 1g '+filename, shell=True, stdout=subprocess.PIPE)
	_res = []
	for line in process.stdout:
	    _res.append(line)
	process.wait()
	return _res

def list():
	process = subprocess.Popen(['ls','-l'], shell=True, stdout=subprocess.PIPE)
	_res = []
	for line in process.stdout:
	    _res.append(line)
	process.wait()
	return _res