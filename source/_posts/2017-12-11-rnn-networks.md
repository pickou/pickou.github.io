---
layout: post
title: recurrent neural networks
description: basic knwoledge about rnn and lstm
tag:
  - rnn
  - lstm
  - DL
categories:
  - deep learning
  - rnn
category: blog
comments: true
mathjax: true
abbrlink: '5e52465'
date: 2017-12-11 00:00:00
---
Introduce basics knowledges about recurrent neural networks !

## RNN

下图是一个RNN循环展开的示意图，$x\_t$是t时刻的输入，$s\_t$是隐藏单元,$s\_t=f(Ux\_t+Ws\_{t-1})$,激活函数f常用`tanh`和`RELU`.RNN的参数是共享的，即图中的`U`,`V`,`W`都是共享的参数.隐藏单元`s`是RNN的
feature所在，包含了一个序列的特征。RNN的训练采用`BPTT`算法进行反向传播。

{% asset_img RNN.png RNN %}

## BPTT

 【1】 `forward` $s\_t=f(Ux\_t+Ws\_{t-1})$以及$o\_t = softmax(Vs\_t)$

 【2】 `cross entropy` $E(y,\hat{y})=-\sum\_t{y\_tlog{\hat{y\_t}}}$

 【3】 `backward` 目标是计算误差对于参数`U`,`V`和`W`的梯度。将每个时刻的梯度相加$\frac{dE}{dW}=\sum\_t{\frac{dE\_t}{dW}}$ , $\frac{dE}{dV}=\sum_t{\frac{dE\_t}{dV}}$ ,$\frac{dE}{dU}=\sum\_t{\frac{dE\_t}{dU}}$. 
 `V`的梯度每个时刻是独立的，不依赖于别的时刻, t时刻,$\frac{dE\_t}{dV}=(\hat{y\_t}-y\_t)\otimes{s\_t}$. 计算W的梯度却不太一样，根据链式求导法则，

$$
\frac{dE_t}{dW}=\frac{dE_t}{d{\hat{y_t}}}\frac{d{\hat{y_t}}}{ds_t}\frac{ds_t}{dW}
$$

又由于$s\_t=f(Ux\_t+Ws\_{t-1})$,t时刻的输出依赖于t-1时刻，所以$s\_{t-1}$也要使用链式求导法则，那么得到

$$
\frac{dE_t}{dW}=\sum_{k=0}^t\frac{dE_t}{d{\hat{y_t}}}\frac{d{\hat{y_t}}}{ds_t}\frac{ds_t}{ds_k}\frac{ds_k}{dW}
$$

以下图为例，计算$s_3$的链式求导，$\frac{ds\_3}{dz\_2}=\frac{ds\_3}{ds\_2}\frac{ds\_2}{ds\_1}\frac{ds\_1}{ds\_0}$,其中$z\_2=Ux\_1+Ws\_1$

{% asset_img bptt.png btpp %}

## LSTM

一个标准的lstm内部结构如下图，包含四个单元

{% asset_img lstm_example.png lstm example %}

+ `forget gate` 激活函数为sigmoid,输出为1，完全通过，输出为0，完全丢失。

{% asset_img which_to_forget.png forget gate %}

+ `存储单元` 通过$i_t$来选择是否让$\tilde{C\_t}$加入到输出中

{% asset_img strore_cell.png store cell %}

+ 接下来是$\tilde{C\_t}$的输出

{% asset_img C_t.png C_t %}

+ 以下面的几个公式来总结一下lstm，

$$
\hat{h_t} = W_{hx}x_t+W_{hh}h_{t-1}\\
i_t = \sigma(W_{ix}x_t+W_{ih}h_{t-1})\\
o_t = \sigma(W_{ox}x_t+W_{oh}h_{t-1})\\
f_t = \sigma(W_{fx}x_t+W_{fh}h_{t-1})\\
c_t = f_t\odot{c_{t-1}}+i_t\odot{\hat{h_t}} \\
h_t = tanh(c_t\odot{o_t})
$$

## mLSTM

$$
m_t = (W_{mx}x_t)\odot(W_{mh}h_{t-1}) \\
\hat{h_t} = W_{hx}x_t+W_{hh}m_t \\
i_t = \sigma(W_{ix}x_t+W_{ih}m_t) \\
o_t = \sigma(W_{ox}x_t+W_{oh}m_t) \\
f_t = \sigma(W_{fx}x_t+W_{fh}m_t) \\
$$

## References

+ <http://colah.github.io/posts/2015-08-Understanding-LSTMs/>
+ <http://www.cs.toronto.edu/%7Eilya/pubs/2011/LANG-RNN.pdf?ref=driverlayer.com>
+ <https://arxiv.org/abs/1609.07959>
