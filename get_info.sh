#!/bin/bash

## print help and exit
_help() {
	cat << 'EOF'

this_script <string>
this_script -h|--help|help
this_script -d|dump|cmds|dumpcmds
this_script -a|append /path/to/file
this_script -r|replace /path/to/file
this_script -c|clean

This script creates /var/tmp/[<string>-]info-[$(date +%Y%m%d%H%M%S)] directory
where it saves the output from commands.

EOF
	exit 0;
};

_dumpcmds() {
#	echo dumping: $_script;
	sed '/^##commands\!/,$!d' "$_script" | while read command; do
    		if echo $command | grep ^# >/dev/null; then
        		continue;
    		fi
    		echo "$command";
	done
	exit 0;
};

_appendcmds() {
	echo appending:;
	exit 0;
};

_replacecmds() {
#	echo replacing:;
	sed '1,/^##commands\!/!d' -i "$_script";
	exit 0;
};

_cleantmp() {
	echo cleaning:;
	exit 0;
};

_basecheck() {
	echo basechecking ...;
	_prefix="$1-";
};

## read the full path to script itself
pushd $(dirname $0) >/dev/null;
_script=$(pwd)/$(basename $0);
popd > /dev/null;


if [ ! -z "$1" ]; then
	case "$1" in
		-h|--help|help) _help;;
		-d|dump|cmds|dumpcmds) _dumpcmds;;
		-a|append) _appendcmds "$2";;
		-r|replace) _replacecmds "$2";;
		-c|clean) _cleantmp;;
		*) _basecheck "$1";;
	esac
fi

## creating an target dir where the output from
## commands is saved and switching there
_dir="$_prefix"info-$(date +%Y%m%d%H%M%S);
mkdir /var/tmp/$_dir 2>/dev/null;
echo;
echo "switching to /var/tmp/$_dir";
echo;
pushd /var/tmp/$_dir >/dev/null;

## commands themselves execution
sed '/^##commands\!/,$!d' $_script | while read command; do
    if echo $command | grep ^# >/dev/null; then
        continue;
    fi
    _outfile="$(echo $command | sed 's/^eval//; s/ //g; s/|/-to-/').out";
    echo "doing: $command";
    $command &> $_outfile;
done

## return back to execution dir
popd >/dev/null;
#exit 0;

echo;
echo "creating archive: /var/tmp/$_dir.tar.gz";

pushd /var/tmp >/dev/null;
if tar cf $_dir.tar $_dir && gzip $_dir.tar; then
    echo done;
else
    echo failure;
    popd;
    exit 1;
fi

popd >/dev/null;
exit 0;

##commands!
prtdiag -v
iostat -En
eval echo|format
diskinfo -a
metastat -t
metastat -c
cfgadm -alv
prtconf -v
dmesg
