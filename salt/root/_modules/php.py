import salt.modules.cmdmod

def xdebug_path():
    return salt.modules.cmdmod._run_quiet("find / -name 'xdebug.so' 2> /dev/null")
