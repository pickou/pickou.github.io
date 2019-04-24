---
layout: post
title: Attention based text translation and document classification
description: hierarchical attention networks for document classification
tag:
  - attention
  - document classification
  - DL
categories:
  - deep learning
  - NLP
category: blog
comments: true
mathjax: true
abbrlink: b2144cbd
date: 2017-12-24 00:00:00
---
下图是attention机制在机器翻译上的表现，可以看到attention很好的解决了长句子级的机器翻译问题。
{% asset_img attention_model.png attention model %}


下面我们从文本翻译来讲解attention机制，传统的文本翻译一般是**encoder-decoder**的结构，如下图。现在将英文句子X翻译成中文句子Y，两个句子各自由不同的单词序列组成，表示如下,

$$
X=<x_1, x_2 ... x_m> \\
Y=<y_1,y_2 ...y_n>
$$

{% asset_img old_encoder-decoder.png encoder-decoder %}

其中，encoder负责对输入的句子进行编码，将句子通过非线性变换转化为中间语义表示$C$,表示为$C=E(x_1,x_2...x_m)$。decoder根据X的中间语义$C$和之间的历史信息$y_1, y_2...y_{i-1}$
来生成i时刻的单词$y_i$,表示为$y_i = D(y_1,y_2...y_{i-1})$。

那么attention机制是怎么一回事呢。先举个例子，假设X序列为**Jack love Rose**,Y序列为**杰克喜欢罗斯**。我们用分解encoder-decoder的过程，那么翻译的过程就是依次生成**杰克**、**喜欢**、**罗斯**,表示为

$$
y_1 = D(C) \\
y_2 = D(C,y_1) \\
y_3 = D(C,y_1,y_2)
$$

传统的语义表示方法的局限就体现出来了，在生成目标句子的单词的时候，无论是 $y_1$ , y_2$ 还是 $y_3$ ，都使用的语义编码C,没有变化,换句话来说就是句子X中的任意单词对于生成目标单词$y_i$的
影响都是一样的，这明显是不科学的。attention就是为了解决这个不合理的地方，比如在翻译出`喜欢`这个词的时候，`love`的贡献率应该更大，而`Jack`和`Rose`就显得不那么重要了。
注意力机制要体现英文单词对于翻译当前中文单词的不同影响程度,类似于给出一个概率分布值，比如在翻译出喜欢这个词的时候,表示为$(Jack,0.3)(love,0.5)(Rose,0.2)$。

引入注意力机制之后，目标句子中的每个单词都会学习对应源句子中每个单词的注意力分配概率的信息。这就相当于在生成每个单词$y_i$的时候，都会根据$y_1,y_2...y_{i-1}$来生成新的变化的$c_i$,
模型结构如下图，翻译的过程就变成了下面这个过程

$$
y_1 = D(C_1) \\
y_2 = D(C_2,y_1) \\
y_3 = D(C_3,y_1,y_2)
$$

{% asset_img am-encoder-decoder.png  attention-based encoder-decoder %}

对于上面那个例子，其对应的翻译过程可能如下,其中$F$函数是encoder对英文单词的变换函数，如果是RNN模型，那么$F$对应的结果是某个时刻隐层节点的状态值，
$G$函数代表encoder根据单词的中间表示合成整个句子中间语义表示的变换函数，一般是对构成元素加权求和。

$$
c_{杰克} =G(0.6*F('Jack'),0.2*F('love),0.2*F('Rose')) \\
c_{喜欢} =G(0.2*F('Jack'),0.7*F('love),0.1*F('Rose')) \\
c_{罗斯} =G(0.2*F('Jack'),0.3*F('love),0.5*F('Rose'))
$$

以RNN作为encoder和decoder,那么传统的文本翻译的过程就如下图，经过一个RNN的encoder将一句话的语义全部放在了一个矩阵C中,然后再通过decoder翻译出来,这样看来就更能看出整个模型的缺点了,
这在长句子翻译上的表现差就很容易解释了，因为长句子蕴含的信息量更大，但仍旧只是把句子的语义映射到一个固定大小的矩阵中去，这没办法完整地表示整个句子的语义

{% asset_img RNN-encoder-decoder.png rnn-encoder-decoder %}

attention的结构，就是将之前的隐层单元输出都收集起来，对这些输出做了个加权求和，这个权值体现了源句子中每个词对于当前需要翻译的词的贡献，结构如下图，

{% asset_img am-rnn-encoder-decoder.png am-rnn-encoder-decoder %}


总结下，attention机制，就像人在足球比赛，每个时刻，注意力都可能放到不同的人身上，C罗带球了，你可能关注点放到了C罗身上，梅西射门了,那么你肯定更关注这个球进没进，梅西脚下动作是什么，
相比之下，其他后卫的跑位，掩护可能都没有这些东西更吸引你关注。这个关注就是attention机制，相当于你大脑给这个事件更大的权重。又比如，你读一本小说，需要读懂当前情节，就需要之前的
铺垫和背景知识，但是不是所有的背景知识对于理解当前情节都是很重要的，这个重要程度就是attention机制。简而言之，**attention机制**解决了之前的模型**抓不住重点**的问题.


### Attention for document classification
hierarchical attention network描述了**文档的结构**，文档是由句子构成的，句子是由单词构成的。又加入了**两个层次的attention机制**，一个是句子级的,一个是单词级的，
给出了单词和句子对于整个信息的不同贡献程度。
一个文档有$L$个句子$s_i$，每个句子有$T_i$个词，$w_{it}$表示第i句话中的第t个词

{% asset_img HAN.png hierarchical-atention-networks %}


* word encoder

一开始，需要通过embedding矩阵$W_e$转化为对应的embedding,然后通过双向的GRU，获得前向的hidden state，和反向的hidden state,组合成为一个新的$h_{it}$,
这样都把这个词的语义用周围的词表示出来了。

{% asset_img word-encoder.png word encoder %}

* word attention

不是所有的词都是一句话的重点，所以，引入了attention的机制。先让$h_it$通过一个单层的MLP,得到$h_{it}$的隐层表示$u_{it}$,
然后通过计算$u_{it}$和$u_w$之间的相似度来衡量这个词对于句子语义的重要程度。$u_w$随机初始化的，通过训练学习得到。通过
softmax,最后对所有单词加权和得到句子的表示$s_i$。

{% asset_img word_attention.png word attention %}

* sentence encoder

不是所有的句子都是一个文档的重点，所以，在句子级也引入了attention机制。同理，对于每个句子$s_i$,前向和后向的hidden units组合成一个新的$h_{it}$,
然后通过同样的方式引入attention,最后加权求和得到整个文档的语义表示$v$。

{% asset_img sentence-encoder.png sentence encoder %}


* sentence attention

{% asset_img sentence-attention.png sentence attention %}

### Reference

* http://www.cs.cmu.edu/~./hovy/papers/16HLT-hierarchical-attention-networks.pdf
* https://github.com/richliao/textClassifier
* https://github.com/ematvey/hierarchical-attention-networks
* http://blog.csdn.net/malefactor/article/details/50550211

