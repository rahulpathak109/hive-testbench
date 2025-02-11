#!/bin/sh

# Check for all the stuff I need to function.
for f in gcc javac unzip; do
	which $f > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo "Required program $f is missing. Please install or fix your path and try again."
		exit 1
	fi
done

# Check if Maven is installed and install it if not.
which mvn > /dev/null 2>&1
if [ $? -ne 0 ]; then
	SKIP=0
	if [ -e "apache-maven-3.8.4-bin.tar.gz" ]; then
		SIZE=`du -b apache-maven-3.8.4-bin.tar.gz | cut -f 1`
		if [ $SIZE -eq 9046177 ]; then
			SKIP=1
		fi
	fi
	if [ $SKIP -ne 1 ]; then
		echo "Maven not found, automatically installing it."
		curl -O https://downloads.apache.org/maven/maven-3/3.8.4/binaries/apache-maven-3.8.4-bin.tar.gz 2> /dev/null
		if [ $? -ne 0 ]; then
			echo "Failed to download Maven, check Internet connectivity and try again."
			exit 1
		fi
	fi
	tar -zxf apache-maven-3.8.4-bin.tar.gz > /dev/null
	CWD=$(pwd)
	export PATH="$PATH:$CWD/apache-maven-3.8.4/bin"
	if [ x$HADOOP_VERSION == x ]; then
		echo "Please set your hadoop version"
		echo "example: run 'hadoop version' and use first 3 number from the output"
                echo "hadoop version\nHadoop 3.1.1.3.1.0.0-78\nexport HADOOP_VERSION=3.1.1"
		exit 1
	fi
fi

echo "Building TPC-H Data Generator"
(cd tpch-gen; make)

if [ $? -ne 0 ]; then
	echo "ERROR: TPC-H Data Generator built failed!!"
else
	echo "TPC-H Data Generator built, you can now use tpch-setup.sh to generate data."
fi
