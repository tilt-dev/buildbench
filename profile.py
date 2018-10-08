#!/usr/bin/env python

import datetime
import subprocess

def make(cmd: str):
    return_code = subprocess.call(['make', cmd])
    if return_code != 0:
        raise Exception('"make {}" exited with exit code {}'.format(cmd, return_code))

def time_build(cmd: str):
    """
        Run the make command twice, and time the second one, so that we
        get an incremental build timing.
    """
    make(cmd)

    with Timer() as t:
        make(cmd)

    return t.duration_secs

class Timer:
    def __enter__(self):
        self.start = datetime.datetime.now()
        return self

    def __exit__(self, *args):
        self.duration_secs = secs_since(self.start)

def secs_since(t: datetime.datetime) -> float:
    return(datetime.datetime.now() - t).total_seconds()

make('clean')
naive_dur = time_build('naive')
cachedeps_dur = time_build('cachedeps')
cacheobjs_dur = time_build('cacheobjs')
tailybuild_dur = time_build('tailybuild')
uncontained_dur = time_build('uncontained')

print('\n------------- Results -------------\n')
print('Make naive: {}s'.format(naive_dur))
print('Make cachedeps: {}s'.format(cachedeps_dur))
print('Make cacheobjs: {}s'.format(cacheobjs_dur))
print('Make tailybuild: {}s'.format(tailybuild_dur))
print('Make uncontained: {}s'.format(uncontained_dur))
