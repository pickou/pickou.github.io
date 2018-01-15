---
layout: post
title: fasttext source code reading
date: 2018-01-11
description: "fasttext c++ source code reading"
tag:
- c++
- fasttext
- tool
category: blog
comments: true
---
fasttext整个实现并不复杂，整个工程简洁，清楚，是个很好的开源项目，适合我这种新手作为源码阅读的起步。
### project architecture
拿到一份代码之后，首先得分析整个工程的结构,能让你看清楚一个project的结构的有两部分，一部分是`main函数`，
还有一部分是`头文件.h`。

```cpp
int main(int argc, char** argv) {
      std::vector<std::string> args(argv, argv + argc);
      if (args.size() < 2) {
              printUsage();
                  exit(EXIT_FAILURE);
                    
      }
        std::string command(args[1]);
        if (command == "skipgram" || command == "cbow" || command == "supervised") {
                train(args);
                  
        } else if (command == "test") {
                test(args);
                  
        } else if (command == "quantize") {
                quantize(args);
                  
        } else if (command == "print-word-vectors") {
                printWordVectors(args);
                  
        } else if (command == "print-sentence-vectors") {
                printSentenceVectors(args);
                  
        } else if (command == "print-ngrams") {
                printNgrams(args);
                  
        } else if (command == "nn") {
                nn(args);
                  
        } else if (command == "analogies") {
                analogies(args);
                  
        } else if (command == "predict" || command == "predict-prob") {
                predict(args);
                  
        } else if (command == "dump") {
                dump(args);
                  
        } else {
                printUsage();
                    exit(EXIT_FAILURE);
                      
        }
          return 0;

}
```

从main函数中可以看到整个fasttext有哪些功能。现在我从`train(args)`入手，看fasttext训练embedding的整个过程。
### train

```cpp
void train(const std::vector<std::string> args) {
    Args a = Args(); // 参数解析的类
    a.parseArgs(args); //解析参数
    FastText fasttext; // fasttext类
    fasttext.train(a); // 训练
    fasttext.saveModel(); // 保存模型
    fasttext.saveVectors(); // 保存训练好的embedding
    if (a.saveOutput) {
        fasttext.saveOutput();
    }
}
```
那么，接下来重点就放到一个`Args`参数解析类和`fasttext`类上。

### Args
可以看到，Args类的成员变量就是fasttext
需要的参数。参数的具体意义可以在这里找到[link](https://github.com/facebookresearch/fastText/blob/master/docs/options.md)

```cpp
class Args {
  protected:
    std::string lossToString(loss_name) const;
    std::string boolToString(bool) const;
    std::string modelToString(model_name) const;

  public:
    Args();// 构造函数
    std::string input;
    std::string output;
    double lr; // learning rate
    int lrUpdateRate; // change the rate of updates for the learning rate
    int dim; // embedding 维度
    int ws; // size of context window
    int epoch; // 迭代次数
    int minCount;
    int minCountLabel;
    int neg; // number of negatives sampled
    int wordNgrams;
    loss_name loss;
    model_name model;
    int bucket;
    int minn;
    int maxn;
    int thread;
    double t;
    std::string label;
    int verbose;
    std::string pretrainedVectors;
    bool saveOutput;

    bool qout;
    bool retrain;
    bool qnorm;
    size_t cutoff;
    size_t dsub;

    void parseArgs(const std::vector<std::string>& args);
    void printHelp();
    void printBasicHelp();
    void printDictionaryHelp();
    void printTrainingHelp();
    void printQuantizationHelp();
    void save(std::ostream&);
    void load(std::istream&);
    void dump(std::ostream&) const;
};

```
构造函数里面给成员变量赋初值，从这个类里面学会了`enum class`的妙用,
enum class 是c++ 11的特性，[link](https://zhuanlan.zhihu.com/p/21722362)
```cpp
enum class loss_name: int {hs=1, ns, softmax};
std::string Args::lossToString(loss_name ln) const {
  switch (ln) {
    case loss_name::hs:
      return "hs";
    case loss_name::ns:
      return "ns";
    case loss_name::softmax:
      return "softmax";
  }
  return "Unknown loss!"; // should never happen
}class Model {
  protected:
    std::shared_ptr<Matrix> wi_;
    std::shared_ptr<Matrix> wo_;
    std::shared_ptr<QMatrix> qwi_;
    std::shared_ptr<QMatrix> qwo_;
    std::shared_ptr<Args> args_;
    Vector hidden_;
    Vector output_;
    Vector grad_;
    int32_t hsz_;
    int32_t osz_;
    real loss_;
    int64_t nexamples_;
    std::vector<real> t_sigmoid_;
    std::vector<real> t_log_;
    // used for negative sampling:
    std::vector<int32_t> negatives_;
    size_t negpos;
    // used for hierarchical softmax:
    std::vector< std::vector<int32_t> > paths;
    std::vector< std::vector<bool> > codes;
    std::vector<Node> tree;

    static bool comparePairs(const std::pair<real, int32_t>&,
                             const std::pair<real, int32_t>&);

    int32_t getNegative(int32_t target);
    void initSigmoid();
    void initLog();

    static const int32_t NEGATIVE_TABLE_SIZE = 10000000;

  public:
    Model(std::shared_ptr<Matrix>, std::shared_ptr<Matrix>,
          std::shared_ptr<Args>, int32_t);

    real binaryLogistic(int32_t, bool, real);
    real negativeSampling(int32_t, real);
    real hierarchicalSoftmax(int32_t, real);
    real softmax(int32_t, real);

    void predict(const std::vector<int32_t>&, int32_t, real,
                 std::vector<std::pair<real, int32_t>>&,
                 Vector&, Vector&) const;
    void predict(const std::vector<int32_t>&, int32_t, real,
                 std::vector<std::pair<real, int32_t>>&);
    void dfs(int32_t, real, int32_t, real,
             std::vector<std::pair<real, int32_t>>&,
             Vector&) const;
    void findKBest(int32_t, real, std::vector<std::pair<real, int32_t>>&,
                   Vector&, Vector&) const;
    void update(const std::vector<int32_t>&, int32_t, real);
    void computeHidden(const std::vector<int32_t>&, Vector&) const;
    void computeOutputSoftmax(Vector&, Vector&) const;
    void computeOutputSoftmax();

    void setTargetCounts(const std::vector<int64_t>&);
    void initTableNegatives(const std::vector<int64_t>&);
    void buildTree(const std::vector<int64_t>&);
    real getLoss() const;
    real sigmoid(real) const;
    real log(real) const;
    real std_log(real) const;

    std::minstd_rand rng;
    bool quant_;
    void setQuantizePointer(std::shared_ptr<QMatrix>, std::shared_ptr<QMatrix>, bool);
};


```
我更关心的是fasttext类,所以赶紧去看看fasttext.h。
### fasttext
这里就不放代码了,还是从[fasttext.h](https://github.com/facebookresearch/fastText/blob/master/src/fasttext.h)入手，
我关心这几个方面，一个方面是输入是如何读取的,第二个是如何训练的,用的什么数据结构，第三个是模型存储是怎么做到的，用的什么方式。
在这个头文件中，看到`std::shared_ptr`，这是c++11的特性，传统的动态内存分配和释放使用new和delete,但是很容易出现忘记释放内存的情况，
这个时候**智能指针**就解决了这个问题，它自动释放内存,是**模板**，初始化的方法和vector是一样的,存在头文件**memory**中。另外一个
就是使用了很多`const`，TODO             。找到[fasttext.cc](https://github.com/facebookresearch/fastText/blob/master/src/fasttext.cc)
,找到train函数，其中输入数据读取是由下面这个函数解决的。

```cpp
dict_ = std::make_shared<Dictionary>(args_);
std::ifstream ifs(args_->input);
if (!ifs.is_open()) {
    throw std::invalid_argument(
        args_->input + " cannot be opened for training!"
    );
}
  dict_->readFromFile(ifs);
  ifs.close();`
```
接下去就该去[dictionary.h](https://github.com/facebookresearch/fastText/blob/master/src/dictionary.h)中寻找输入读取的细节。首先找到readFromFile这个函数,比较关键的几个函数分别是`readWord(word)`,`add(word)`,`threshhold`, `initTableDiscard`和`initNgrams`。
+ 先去看readWord，发现这个函数就是读取一个词的，分割符号类似`" ", "\r", "\t"`之类的
+ add的实现有些技巧，使用了hash的方式将词进行编码，这样在查找词的时候就会更快，hash采用的32位的[NFV算法](http://www.cppblog.com/koson/archive/2010/03/11/109446.html),
词被存在**words_**里面，它是个vector,每个元素是一个entry的结构体，包含了这个词，词的词频，以及是label还是word,还有子单词的信息。
+ threshold是为了去掉频率过低和过高的词,这里用到了**lambda**表达式
```cpp
words_.erase(remove_if(words_.begin(), words_.end(), [&](const entry& e) {
    return (e.type == entry_type::word && e.count < t) ||
            (e.type == entry_type::label && e.count < tl);
    }), words_.end());
```
remove\_if和erase一般成对出现,lambda表达式查阅[link](http://zh.cppreference.com/w/cpp/language/lambda)
同时，vector里面使用了函数`shrink_to_fit`,这个函数可以释放掉vector中被erase掉的内存空间。
+ initTableDiscard，从新计算一个词的词频，并把计算的词频放到pdiscard\_中,这里采用了一个技巧,计算词频的时候做了一个
缩放$$\sqrt{x/f}+x/f$$，其中f取0.0001,这样能保证f过小的时候整个数不会太大，f过大的时候整个值也不会太小。
```cpp
void Dictionary::initTableDiscard() {
    pdiscard_.resize(size_);
    for (size_t i = 0; i < size_; i++) {
        real f = real(words_[i].count) / real(ntokens_);
        pdiscard_[i] = std::sqrt(args_->t / f) + args_->t / f;
      }
}
```
+ initNgrams主要部分在computeSubwords这个函数中，所以找到这个函数分析。
```
 if ((word[i] & 0xC0) == 0x80) continue;
```
这句话为了检测编码是不是10开头的utf-8，因为10开始的utf-8编码，表示一个多字节序的子序,具体的可以参见reference.
数据处理这部分就算差不多了,接着去看模型训练的过程,

还是接着看train函数，loadVector这个函数就没什么好看的了，就是从文件中读取训练好的embedding.接下来，看到这段代码的时候，
这就是开始了模型的训练，两个模块比较重要，一个是**startThreads()**,另外一个就是**Model**。
```cpp
  startThreads();
  model_ = std::make_shared<Model>(input_, output_, args_, 0);
  if (args_->model == model_name::sup) {
          model_->setTargetCounts(dict_->getCounts(entry_type::label));
            
  } else {
          model_->setTargetCounts(dict_->getCounts(entry_type::word));

  }
```

+ startThreads  把线程放到vector中，用lambda表达式的值传递方式建立线程,之后采用join方式阻塞线程。

```cpp
std::vector<std::thread> threads;
for (int32_t i = 0; i < args_->thread; i++) {
    threads.push_back(std::thread([=]() { trainThread(i);  }));
}
for (int32_t i = 0; i < args_->thread; i++) {
    threads[i].join();
}
```

+ Model 先将Model分析清楚再去分析trainThread函数，找到[Model.h](https://github.com/facebookresearch/fastText/blob/master/src/model.h),
这个类就是整个fasttext的核心算法所在了。Model里面包含了很多东西，有关quantize的先放到后面分析，看README知道这是后面增加的feature,这个方式
下内存占用会变小,这其实就是对网络做了一个压缩。

```cpp
class Model {
  protected:
    std::shared_ptr<Matrix> wi_; //连接input的权值,其中Matrix类以vector存储了二维的数组，并定义了很多类方法，比如l2NormRow, dotRow等等
    std::shared_ptr<Matrix> wo_; //连接output的权值
    std::shared_ptr<QMatrix> qwi_;
    std::shared_ptr<QMatrix> qwo_;
    std::shared_ptr<Args> args_;
    Vector hidden_; // 隐藏层单元，Vector类以vector存储隐层单元的值，也定义了很多基于vector的方法
    Vector output_; // 输出层，类型也是Vector
    Vector grad_; // 梯度值
    int32_t hsz_;
    int32_t osz_;
    real loss_; // loss值，real即为float
    int64_t nexamples_; // 样本总数
    std::vector<real> t_sigmoid_; // 经过sigmoid之后的值
    std::vector<real> t_log_; //经过
    // used for negative sampling:
    std::vector<int32_t> negatives_;
    size_t negpos;
    // used for hierarchical softmax:
    std::vector< std::vector<int32_t> > paths;
    std::vector< std::vector<bool> > codes; //存储哈夫曼编码
    std::vector<Node> tree; //存储这个编码树

    static bool comparePairs(const std::pair<real, int32_t>&,
                             const std::pair<real, int32_t>&);

    int32_t getNegative(int32_t target);
    void initSigmoid();
    void initLog();

    static const int32_t NEGATIVE_TABLE_SIZE = 10000000;

  public:
    Model(std::shared_ptr<Matrix>, std::shared_ptr<Matrix>,
          std::shared_ptr<Args>, int32_t);

    real binaryLogistic(int32_t, bool, real); // logistic回归
    real negativeSampling(int32_t, real); // negative sampling 方法
    real hierarchicalSoftmax(int32_t, real); // hs方法
    real softmax(int32_t, real); // softmax方法

    void predict(const std::vector<int32_t>&, int32_t, real,
                 std::vector<std::pair<real, int32_t>>&,
                 Vector&, Vector&) const; // predict方法
    void predict(const std::vector<int32_t>&, int32_t, real,
                 std::vector<std::pair<real, int32_t>>&);
    void dfs(int32_t, real, int32_t, real,
             std::vector<std::pair<real, int32_t>>&,
             Vector&) const; // 深度优先遍历方法
    void findKBest(int32_t, real, std::vector<std::pair<real, int32_t>>&,
                   Vector&, Vector&) const; // 选出k个最近的
    void update(const std::vector<int32_t>&, int32_t, real); //计算梯度，更新权值
    void computeHidden(const std::vector<int32_t>&, Vector&) const; //计算hidden的值
    void computeOutputSoftmax(Vector&, Vector&) const;//计算经过softmax后的值
    void computeOutputSoftmax();

    void setTargetCounts(const std::vector<int64_t>&);
    void initTableNegatives(const std::vector<int64_t>&);
    void buildTree(const std::vector<int64_t>&);// 建立哈夫曼树
    real getLoss() const;
    real sigmoid(real) const;
    real log(real) const;
    real std_log(real) const;

    std::minstd_rand rng;
    bool quant_;
    void setQuantizePointer(std::shared_ptr<QMatrix>, std::shared_ptr<QMatrix>, bool);
};

```

+ trainThread 分析完Model的结构,转回trainThread，这个threadId主要是为了给各个线程分配不同的数据。
然后有三个模型,分别是**supervised**，**skipgram**和**cbow**,这里选择一个模型**supervised**继续下面的分析。

```cpp
void FastText::supervised(
    Model& model,
    real lr,
    const std::vector<int32_t>& line,
    const std::vector<int32_t>& labels) {
    if (labels.size() == 0 || line.size() == 0) return;
    std::uniform_int_distribution<> uniform(0, labels.size() - 1); // 均匀分布
    int32_t i = uniform(model.rng);
    model.update(line, labels[i], lr);
}
```

### Reference
+ https://github.com/facebookresearch/fastText/tree/master/src
+ https://stackoverflow.com/questions/3911536/utf-8-unicode-whats-with-0xc0-and-0x80
+ http://blog.sina.com.cn/s/blog\_7c4f3b160101dv4p.html
