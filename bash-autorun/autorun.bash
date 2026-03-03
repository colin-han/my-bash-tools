for FILE in `dirname $0`/*.sh
do
  . $FILE
done

if ls `dirname $0`/private/*.sh >/dev/null 2>&1; then
  for FILE in `dirname $0`/private/*.sh
  do
    . $FILE
  done
fi
