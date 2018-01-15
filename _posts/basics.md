# Basic knowledges about LSTM

## 1. RNN

下图是一个RNN循环展开的示意图，$`x_t`$是t时刻的输入，$`s_t`$是隐藏单元,$`s_t=f(Ux_t+Ws_{t-1})`$，
激活函数f常用`tanh`和`RELU`.RNN的参数是共享的，即图中的`U`,`V`,`W`都是共享的参数.隐藏单元`s`是RNN的
feature所在，包含了一个序列的特征。RNN的训练采用`BPTT`算法进行反向传播。

![RNN](../pics/RNN.png)

## 2. BPTT

 【1】 `forward` $`s_t=f(Ux_t+Ws_{t-1})`$以及$`o_t = softmax(Vs_t)`$

 【2】 `cross entropy` $`E(y,\hat{y})=-\sum_t{y_tlog{\hat{y_t}}}`$

 【3】 `backward` 目标是计算误差对于参数`U`,`V`和`W`的梯度。将每个时刻的梯度相加$`\frac{dE}{dW}=\sum_t{\frac{dE_t}{dW}}`$ ,
 $`\frac{dE}{dV}=\sum_t{\frac{dE_t}{dV}}`$ ,$`\frac{dE}{dU}=\sum_t{\frac{dE_t}{dU}}`$ .`V`的梯度每个时刻是独立的，不依赖于别的时刻,
t时刻,$`\frac{dE_t}{dV}=(\hat{y_t}-y_t)\otimes{s_t}`$.计算W的梯度却不太一样，根据链式求导法则，

```math
\frac{dE_t}{dW}=\frac{dE_t}{d{\hat{y_t}}}\frac{d{\hat{y_t}}}{ds_t}\frac{ds_t}{dW}
```

又由于$`s_t=f(Ux_t+Ws_{t-1})`$,t时刻的输出依赖于t-1时刻，所以$`s_{t-1}`$也要使用链式求导法则，那么得到

```math
\frac{dE_t}{dW}=\sum_{k=0}^t\frac{dE_t}{d{\hat{y_t}}}\frac{d{\hat{y_t}}}{ds_t}\frac{ds_t}{ds_k}\frac{ds_k}{dW}

```

以下图为例，计算$`s_3`$的链式求导，$`\frac{ds_3}{dz_2}=\frac{ds_3}{ds_2}\frac{ds_2}{ds_1}\frac{ds_1}{ds_0}`$,其中$`z_2=Ux_1+Ws_1`$

![bptt](../pics/bptt.png)

## 3. LSTM

一个标准的lstm内部结构如下图，包含四个单元

![lstm](../pics/lstm_example.png)

+ `forget gate` 激活函数为sigmoid,输出为1，完全通过，输出为0，完全丢失。

![forget_gate](../pics/which_to_forget.png)

+ `存储单元` 通过$`i_t`$来选择是否让$`\tilde{C_t}`$加入到输出中

![strore_cell](../pics/strore_cell.png)

+ 接下来是$`\tilde{C_t}`$的输出

![C_t](../pics/C_t.png)

+ 以下面的几个公式来总结一下lstm，

```math
\hat{h_t} = W_{hx}x_t+W_{hh}h_{t-1}
```

```math
i_t = \sigma(W_{ix}x_t+W_{ih}h_{t-1})
```

```math
o_t = \sigma(W_{ox}x_t+W_{oh}h_{t-1})
```

```math
f_t = \sigma(W_{fx}x_t+W_{fh}h_{t-1})
```

```math
c_t = f_t\odot{c_{t-1}}+i_t\odot{\hat{h_t}}
```

```math
h_t = tanh(c_t\odot{o_t})
```

## 4.mLSTM

```math
m_t = (W_{mx}x_t)\odot(W_{mh}h_{t-1})
```

```math
\hat{h_t} = W_{hx}x_t+W_{hh}m_t
```

```math
i_t = \sigma(W_{ix}x_t+W_{ih}m_t)
```

```math
o_t = \sigma(W_{ox}x_t+W_{oh}m_t)
```

```math
f_t = \sigma(W_{fx}x_t+W_{fh}m_t)
```

## References

+ <http://colah.github.io/posts/2015-08-Understanding-LSTMs/>
+ <http://www.cs.toronto.edu/%7Eilya/pubs/2011/LANG-RNN.pdf?ref=driverlayer.com>
+ <https://arxiv.org/abs/1609.07959>