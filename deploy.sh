# 一般用
hugo -D
cd public

git init
git add -A
git commit -m "updates $(date)"

git push -f git@github.com:ljahum/ljahum.github.io.git master

cd ../



# 重开用
# git init
# git remote add origin git@github.com:ljahum/ljahum.github.io.git
# git add -A
# git commit -m "first commit"
# git push -u origin master

# git commit -m "updates $(date)"