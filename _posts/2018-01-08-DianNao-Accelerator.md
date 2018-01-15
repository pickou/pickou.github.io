---
layout: post
title: DianNao Accelerator
date: 2018-01-08
description: "knwoledge and insights from DianNao"
tag:
- convolution
- accelerator
- DL
category: blog
comments: true
---
文章主要关注点在**feed forward**,而不是back propagation。从deep network中选取了两种比较有代表性的网络结构**CNN** 和**DNN**,接着又从这两个网络里面提取了三个具有代表性的layer,分别是 classsifier, convolutional layer 和 pooling layer。如下图，

![]({{site.url}}/pics/diannao/selected-layer.png)

要加速神经网络，**memory traffic**显然是一个很重要的方面，接下类分析这三个layer的data locality
，通过**tiling**调整三个layer作为baseline.用了`cache simulator`来测出memory bandwidth, 其中cache
simulator所需要的输入应该是用模拟器产生的，模拟器可以由 Gem5 改写而成。文中做了一个假设，那就是循环
的每一轮都能处理$$T_n$$个neurons和$$T_i$$个synapses。

* classifier layer

一个classifier layer写出表达式如下，如果略掉偏执b，那么其实就是一个向量乘以一个矩阵，我们看这个向量其实会用很多次，
如果向量一直存在cache中，那么访存就会少很多。学体系结构的人都知道，程序的大部分时间都花在了访存上了，所以通过减少访
存的次数，可以减少运行时间。**loop tiling**是很常用的方法，思想就是`将数据局部性好的数据尽量都保持在cache中`。数据局部性
包含两部分，一部分是temporal locality，这是时间上的，就是说经常用到。一部分是spacial locality,就是空间上了，存储在连续空间的
数据spacial locality会比较好。

$$
y=xw+b
$$


![]({{site.url}}/pics/diannao/classifier_layer.png)

* pooling layer

![]({{site.url}}/pics/diannao/pooling_layer.png)

* convolutional layer

![]({{site.url}}/pics/diannao/conv_layer.png)
