#!/usr/bin/env bash
if [ -f /usr/bin/pythonw ]; then
	pythonw program.py mac
else
	python program.py mac
fi

