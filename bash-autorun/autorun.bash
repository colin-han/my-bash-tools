for FILE in `dirname $0`/*.sh
do
  . $FILE
done

for FILE in `dirname $0`/private/*.sh
do
  . $FILE
done