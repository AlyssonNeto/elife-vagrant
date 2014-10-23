import salt.modules.cmdmod

def xdebug_path():
    return {'xdebug_path': salt.modules.cmdmod._run_quiet("find / -name 'xdebug.so' 2> /dev/null")}
