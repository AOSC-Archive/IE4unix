#!/usr/bin/env bash
cd "$(dirname "$0")"

if [ -f /usr/bin/pythonw ]; then
	pythonw program.py mac
else
	python program.py mac
fi

