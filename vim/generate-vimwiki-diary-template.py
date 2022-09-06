#!/usr/bin/python3
import datetime
import sys

template = """# {date}

## Daily Activities

- [ ] Plan tomorrow
- [ ] Back2Action Exercise

## Todo

- [ ] 

## Meetings

## Notes"""

date = (
    datetime.date.today()
    if len(sys.argv) < 2
    else sys.argv[1].rsplit(".", 1)[0].rsplit("/", 1)[1]
)
print(template.format(date=date))
