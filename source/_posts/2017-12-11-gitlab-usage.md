---
title: gitlab workflow
layout: post
date: '2017-12-11 22:20'
image: /assets/images/markdown.jpg
description: 'gitlab, code manage tool for cooperation'
tag:
  - gitlab
  - tools
category: blog
author: jcyan
abbrlink: bd2c5685
---
gitlab作为一个协同工作的代码管理工具，使用起来很方便，能大大提高生产效率。

{% asset_img gitlab.png gitlab %}

git的工作流主要维护本地仓库的三棵树，分别是**工作目录**，包含了实际的文件；**暂存区(Index)**，
相当于一个缓冲区，保存临时改动；**HEAD**,指向最后一次提交的结果。

{% asset_img gitworkflow.png workflow %}

## 1. easy workflow
take demo.cpp for example
* `git add demo.cpp` demo.cpp被添加到暂存区
* `git commit -m "demo cpp"` 提交改动到**HEAD**,但还没有提交到远程分支
* `git pull origin branch-name` 从远程分支上pull到本地，更新本地分支
* `git push origin branch-name` 提交改动到远程分支branch-name上

## 2. branch
一般在创建一个repository之后，会有一个默认的分支master。现在，在本地建立一个新的分支`feature_x`,
使用命令`git checkout -b feature_x`，就在本地新建了一个分支，并同时切换到该分支上，这个分支相当于
另外一个工作区。使用命令`git checkout master`就切换回master了。`git push origin feature_x`本地新建
的分支就被推送到远程，远程多了一个分支`feature_x`。要删除分支，使用命令`git branch -d feature_x`
{% asset_img branch.png branch %}

## 3. merge
在工业生产中，每个人会在一个对应的分支上开发自己的feature,完成开发之后提交**MR**,然后通过review,和CI,
最终merge到master上。这样保证了项目的质量，同时提高工作效率。`git merge feature_x`，提交了
`feature_x`和master的MR。

当你在merge或者是pull的时候可能会出现conflicts，那么你需要先修改好这些冲突，
然后使用`git add`添加修改好的文件，再进行后续的步骤。
{% asset_img merge.png %}

## 4. git rebase
`git rebase`主要作用是将一个分支的修改合并到当前的分支，下面以一个例子来讲解

* 现在有一个远程分支origin,已经有了两个commits，然后基于origin分支新建一个mywork分支
{% asset_img w1.png w1%}

* 你在mywork分支上有了两个commits,你的同事在origin上也提交了两个commits，两个分支各自都前进了,
那么就产生了分叉
{% asset_img w2.png w2 %}

* 你在提交MR之前会先会使用`git pull`更新本地分支，那么两个分支就会产生merge，看起来就是这样的
{% asset_img w3.png w3 %}

* 如果你想要mywork分支像没有经过合并一样，需要使用`git rebase`,这样会把mywork分支中的commits临时
保存在`.git/rebase`中，然后更新mywork为最新的origin分支，接着再把这些临时保存的修改应用到mywork上,
这样，看起来就跟没有合并一样，结构更为清爽，便于repository的管理。
{% asset_img w4.png w4 %}

* 当mywork分支更新之后，之前的commits就会被丢掉，垃圾回收机制就会把这些没有用的commits给删除掉
{% asset_img w5.png w5 %}

如果`git rebase`的过程中出现了conflicts，那么可以先解决玩冲突，然后使用git add添加修改，接着使用
`git rebase --continue`

## 5. conflicts
多人协作的时候,很容易产生conflicts,这时候需要我们先在本地解决好冲突，然后再进行后面的步骤。冲突表现为
下图这样，在`<<<<<<`和`HEAD`之间是你当前的修改,后面那部分是别人的修改或者是你之前的修改。如果两个工作都需要，
那么把所有的非代码部分去掉就可以了，如果只需要其中一个，那就保留其中一个。
{% asset_img conflicts.png conflict %}

## 6. other commands
1. `git stash` 用作你有一些修改，但是又不想提交这些修改，同时你又要回到一个干净的工作环境。这个命令
就会把你在工作环境中和Index下的修改放到一个缓冲区去，然后把工作环境revert到最近的一个commits(HEAD)。
2. `git stash pop` 弹出之前保存的修改
3. `git log` 查看git的日志，所有提交的commits。可以按照树形显示分支，`git log --graph --oneline --decorate --all`
{% asset_img git_log.png git log %}

#### Reference
* http://rogerdudler.github.io/git-guide/index.zh.html
* https://team-coder.com/avoid-merge-conflicts/
* http://blog.csdn.net/hudashi/article/details/7664631/
* https://git-scm.com/docs/git-rebase
* https://team-coder.com/from-git-flow-to-trunk-based-development/
