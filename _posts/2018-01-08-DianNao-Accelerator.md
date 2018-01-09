---
layout: post
title: DianNao Accelerator paper reading
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

为了加速神经网络，就需要解决**memory traffic**问题，接下类分析这三个layer的data locality

* classifier layer

```bash
for i in range(1, 2)
```
![]({{site.url}}/pics/diannao/classifier_layer.png)

* pooling layer

![]({{site.url}}/pics/diannao/pooling_layer.png)

* convolutional layer

![]({{site.url}}/pics/diannao/conv_layer.png)
