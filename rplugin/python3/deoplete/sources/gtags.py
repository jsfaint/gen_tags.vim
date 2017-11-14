from deoplete.source.base import Base
from distutils.spawn import find_executable
import deoplete.util
import subprocess


class Source(Base):

    GTAGS_DB_NOT_FOUND_ERROR = 3

    def __init__(self, vim):
        super(Source, self).__init__(vim)

        self.name = 'gtags'
        self.mark = '[gtags]'
        self.filetypes = ['c', 'cpp', 'java', 'php']
        self.input_pattern = (r'\w+')
        self.rank = 100

    def print_global_error(self, global_exitcode):
        if global_exitcode == 1:
            error_message = '[gtags] Error: file does not exists'
        elif global_exitcode == 2:
            error_message = '[gtags] Error: invalid argumnets\n'
        elif global_exitcode == 3:
            error_message = '[gtags] Error: GTAGS not found'
        elif global_exitcode == 126:
            error_message = '[gtags] Error: permission denied\n'
        elif global_exitcode == 127:
            error_message = '[gtags] Error: \'global\' command not found\n'
        else:
            error_message = '[gtags] Error: global command failed\n'

        deoplete.util.error(self.vim, error_message)

    def check_executable(self):
        if not find_executable("global"):
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

    def gather_candidates(self, ctx):
        if not self.check_executable():
            return []

        base = ctx['input']

        if not self.is_word_valid_for_search(base):
            return []

        # invoke global
        command = ['global', '-q', '-c', base]

        if self.vim.options['ignorecase']:
            command.append('-i')

        proc = subprocess.Popen(command,
                                cwd=ctx['cwd'],
                                stdin=subprocess.PIPE,
                                stdout=subprocess.PIPE,
                                stderr=subprocess.DEVNULL)

        output = proc.communicate(timeout=30)

        global_exitcode = proc.returncode
        if global_exitcode == self.GTAGS_DB_NOT_FOUND_ERROR:
            return []

        if global_exitcode != 0:
            self.print_global_error(global_exitcode)
            return []

        matches = output[0].decode('utf8').splitlines()

        return [{'word': t} for t in matches]
