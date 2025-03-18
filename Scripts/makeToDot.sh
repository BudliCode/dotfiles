#! /bin/bash
for dotfile in "$@"
do
	mv $dotfile dot-"${dotfile#?}"
done
