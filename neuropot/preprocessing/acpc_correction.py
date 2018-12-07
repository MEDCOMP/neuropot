import subprocess

def correctACPC(filename):
	process = subprocess.Popen('mkfile 1g '+filename, shell=True, stdout=subprocess.PIPE)
	_res = []
	for line in process.stdout:
	    _res.append(line)
	process.wait()
	return _res