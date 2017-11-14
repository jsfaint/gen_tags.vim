# -*- coding: utf-8 -*-

from cm import register_source, Base
import subprocess

register_source(name='gtags',
                priority=6,
                abbreviation='gtags',
                word_pattern=r'\w+',
                scoping=True,
                scopes=['c', 'cpp', 'php', 'java'])


class Source(Base):

    GTAGS_DB_NOT_FOUND_ERROR = 3

    def __init__(self, nvim):
        super().__init__(nvim)
        self._checked = False

    def is_word_valid_for_search(self, word):
        FORRBIDDEN_CHARACTERS = [
                '^', '$', '{', '}', '(', ')', '.',
                '*', '+', '[', ']', '?', '\\'
                ]

        for forbbiden_char in FORRBIDDEN_CHARACTERS:
            if forbbiden_char in word:
                return False
        return True

    def cm_refresh(self, info, ctx):
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

        self.complete(info, ctx, ctx['startcol'], matches)
