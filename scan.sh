rm domains/*

./enum_sublistr.sh $1

for i in $(cat domains/sublistr_$1.list);
do
./nuc_runner.sh $i
echo TRYING $i
done

