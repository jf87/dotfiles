#!/usr/bin/python3
import datetime
import glob
import re
import sys

# vimwiki_path = "/Users/fues/Drive/sync/vimwiki/diary"
template = """# {date}

## Todo

{todos}- [ ]

## Meetings

## Notes"""


def natural_sort(l):
    convert = lambda text: int(text) if text.isdigit() else text.lower()
    alphanum_key = lambda key: [convert(c) for c in re.split("([0-9]+)", key)]
    return sorted(l, key=alphanum_key, reverse=True)


def get_last_day():
    vimwiki_path = sys.argv[-1] + "/diary"
    # print(vimwiki_path)
    files = glob.glob(vimwiki_path + "/*.md")
    files = natural_sort(files)
    last_day = files[1]  # exclude diary.md
    return last_day


def get_todos(last_day):
    todos = []
    with open(last_day) as f:
        lines = f.readlines()
        start = False
        for line in lines:
            if line[0:7] == "## Todo":
                # print(line[0:7])
                start = True
                continue
            if start:
                # print(line[0:5])
                if line[0:5] == "- [ ]":
                    todos.append(line)
                if line[0:2] == "##":
                    # done
                    return todos
        return todos


last_day = get_last_day()
# print(last_day)
todos = get_todos(last_day)
# print(todos)
todos_str = ""
for t in todos:
    todos_str = todos_str + t


date = (
    datetime.date.today()
    if len(sys.argv) < 3
    else sys.argv[1].rsplit(".", 1)[0].rsplit("/", 1)[1]
)

print(template.format(date=date, todos=todos_str))
