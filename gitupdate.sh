_gsub_help()
{
	echo "版本提交使用帮助："
	echo "	gsub 要提交到的分支名 注释文字"
	echo "例如："
	echo "	gsub ms_dsd '测试提交'"
}

gsub()
{
	if [ $# != 2 ]; then
		_gsub_help
		return 1;
	fi
	local branch=`echo $(__git_ps1) | tr -d '[()]'`
	local user=`whoami`

	git commit -am "$user 提交本地 $branch 分支: 
$2"
	if [ $? != '0' ]; then
		echo "本地分支提交失败:$?"
		return 2;
	else
		echo -e "$user$ git commit -am \"$user提交本地$branch分支: $2\"\n"
		local hash=$(git log --pretty=format:"%h" -1)
	fi

	git push 
	if [ $? != '0' ]; then
		echo "提交远程分支 $branch 失败:$?"
		return 3;
	else
		echo -e "$user$ git push\n"
	fi

	git checkout $1
	local origin=`echo $(__git_ps1) | tr -d '[()]'`
	if [ $? != '0' ]; then
		echo "切换分支 $origin 失败:$?"
		return 4;
	else
		echo -e "$user$ git checkout $1\n"
	fi

	git pull
	if [ $? != '0' ]; then
		echo "取回远程分支 $origin 更新失败:$?"
		return 5;
	else
		echo -e "$user$ git pull\n"
	fi

	git merge $branch -m "$user 将 $branch 的代码[$hash]合并到 $origin 中: 
$2"
	if [ $? != '0' ]; then
		echo "合并分支 $branch 失败:$?"
		echo "代码有冲突！请修改后再次提交"
		echo "git commit -am \"$user 将 $branch 的代码合并到 $origin 中: $2\""
		echo "git push"
		echo "git check $branch"
		return 6;
	else
		echo -e "$user$ git merge $branch\n"
	fi

	git push 
	if [ $? != '0' ]; then
		echo "提交远程分支 $origin 失败:$?"
		return 7;
	else
		echo -e "$user$ git push\n"
	fi

	git checkout $branch
	if [ $? != '0' ]; then
		echo "切换分支 $branch 失败:$?"
		return 4;
	else
		echo -e "$user$ git checkout $branch\n"
	fi
}
