#!/bin/bash

if [ $# -ne 1 ]; then
  echo "1 argument is required."
  exit 1
fi

indir=$1
workdir="${indir%/}/work_tmp"
output="${indir%/}/output.jpg"
fileCount=`\find ${indir} -maxdepth 1 -name '*.jpg' | wc -l`;
if [ $fileCount -le 2 ]; then
  echo "Two or more JPG files are required."
  exit 1
fi


# create work directory
`\mkdir ${workdir}`;

baseWidth=0
baseHeight=0
remainingWidth=0
count=0
pointX=0
workfiles=""

# slice files
for file in `\find ${indir} -maxdepth 1 -name '*.jpg' | sort`; do
  count=$(( count + 1 ))
  filename=$(basename "$file")
  name=${filename%.*}
  workfile="${workdir%/}/${name}_ts.jpg"
  workfiles="${workfiles} ${workfile}"

  if [ $count -eq 1 ]; then
    baseWidth=`identify -format "%w" $file`
    baseHeight=`identify -format "%h" $file`
    oneWidth=$(( baseWidth / fileCount ))
    remainingWidth=baseWidth
  fi

  if [ $count -ne ${fileCount} ]; then
    # first - (last - 1)
    # crop file '[h]x[w]+[x]+[y]'
    `\convert $file -crop "${oneWidth}x${baseHeight}+${pointX}+0" $workfile`;
    pointX=$(( pointX + oneWidth ))
    remainingWidth=$(( remainingWidth - oneWidth ))
  else
    # last
    # crop file '[h]x[w]+[x]+[y]'
    `\convert $file -crop "${remainingWidth}x${baseHeight}+${pointX}+0" $workfile`;
  fi
done

# merge files
`\convert +append $workfiles $output`;

# delete work directory
`\rm -rf ${workdir}`;
