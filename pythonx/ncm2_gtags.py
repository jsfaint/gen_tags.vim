# -*- coding: utf-8 -*-

import vim
from ncm2 import Ncm2Source, getLogger, Popen
import subprocess
from distutils.spawn import find_executable

logger = getLogger(__name__)


class Source(Ncm2Source):

    GTAGS_DB_NOT_FOUND_ERROR = 3

    def check_executable(self):
        if not find_executable('global'):
            return False
        else:
            return True

    def is_word_valid_for_search(self, word):
        FORRBIDDEN_CHARACTERS = [
            '^', '$', '{', '}', '(', ')', '.',
            '*', '+', '[', ']', '?', '\\'
            ]

        for forbbiden_char in FORRBIDDEN_CHARACTERS:
            if forbbiden_char in word:
                return False
        return True

    def on_complete(self, ctx):
        if not self.check_executable():
            return []

        base = ctx['base']

        if not self.is_word_valid_for_search(base):
            return []

        # invoke global
        command = ['global', '-q', '-c', base]

        if self.nvim.options['ignorecase']:
            command.append('-i')

        proc = subprocess.Popen(command,
                                stdin=subprocess.PIPE,
                                stdout=subprocess.PIPE,
                                stderr=subprocess.DEVNULL)

        output = proc.communicate(timeout=30)

        global_exitcode = proc.returncode
        if global_exitcode == self.GTAGS_DB_NOT_FOUND_ERROR:
            return []

        if global_exitcode != 0:
            return []

        matches = output[0].decode('utf8').splitlines()

        logger.info('matches %s', matches)

        self.complete(ctx, ctx['startccol'], matches)


source = Source(vim)

on_complete = source.on_complete
