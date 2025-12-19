import sublime
import sublime_plugin

class ReflowSelectedCommand(sublime_plugin.TextCommand):
    def run(self, edit):
        for region in self.view.sel():
            if region.empty():
                # If nothing selected, expand to current paragraph
                region = self.view.line(region)
            lines = [self.view.substr(self.view.line(r)).strip() for r in self.view.split_by_newlines(region)]
            new_text = ' '.join(lines)
            self.view.replace(edit, region, new_text)
