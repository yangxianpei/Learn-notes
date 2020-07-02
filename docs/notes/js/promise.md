# Promise的原理

> 关于 Promise 使用方法就不多讲了，我们来聊一聊它的实现原理

**请大家配合最下方的 Promise/A+ 规范实现代码来阅读**

**Promise 有三种状态：pedding, resolved, rejected。**

1. 用户自己决定失败和成功的原因。
2. Promise默认执行器(executor)立即执行。
3. 如果执行器发生异常就回执行失败回调。
4. Promise有个then方法，里面有成功和失败的回调。
5. Promise一旦成功就不能失败，反之一样(只有pedding态才能更改状态)。

``` js
    new Promise((resolve, reject) => {
        resolve();
        throw new Error() //不会执行reject
    })
```

**其次 Promise/A+ 规范实现代码中的 setTimeout 可以理解将代码添加到平台的微任务队列中异步执行**

## 简单版Promise 整个流程

1. `new Promise((resolve, reject) => {})` 内部代码会默认立即执行这个执行器(executor)。

    

``` js
        try {
            executor(resolve, reject);
        } catch (e) {
            reject(e);
        }
```

2. 执行 `new Promise.then(onFulfilled, onRejected)`
   根据A+规范 2.2.1-2.2.3 onFulfilled和onRejected判断是否是一个函数，若不是函数则返回这个值。

   

``` js
    onFulfilled = typeof onFulfilled == "function" ? onFulfilled : v => v;
    onRejected = typeof onRejected == "function" ? onRejected : err => {
        throw err
    };
```

3. 当用户调用resolve和reject时,会根据status的值去判断执行。

    

    - 用户同步调用resolve, reject时, 直接去执行对应的回调。
        ```js
            then(onFulfilled, onRejected) {
                if (this.status == RESOLVED) {
                onFulfilled(this.value);
                }
                if (this.status == REJECTED) {
                onFulfilled(this.reason);
                }
            }
        ```

    - 当用户异步调用resolve, reject时, 此时的status为pedding, 不能立即是去执行这两个回调, 所以我们用两个数组先存起来, 当定时器时间到了后执行resolve或者reject时在去触发。

           

    - 用户同步调用resolve, reject时, 直接去执行对应的回调。

       ```js
        if (this.status == PENDING) {
             this.onFulfilledCallback.push(() => {
                 //todo
                 onFulfilled(this.value);
             });
             his.onRejectedCallback.push(() => {
                 //todo
                 onRejected(this.value);
             });
         }
       ```

4. 简易版promise整体代码

``` js
    const RESOLVED = "RESOLVED";
    const REJECTED = "REJECTED";
    const PENDING = "PENDING";
    class Promise {
        constructor(executor) {
            this.status = PENDING;
            this.reason = undefined;
            this.value = undefined;
            this.onFulfilledCallback = [];
            this.onRejectedCallback = [];
            const resolve = (value) => {
                if (this.status == PENDING) {
                    this.value = value;
                    this.status = RESOLVED;
                    this.onFulfilledCallback.forEach((fn) => fn());
                }
            };
            const reject = (reason) => {
                if (this.status == PENDING) {
                    this.reason = reason;
                    this.status = REJECTED;
                    this.onRejectedCallback.forEach((fn) => fn());
                }
            };

            try {
                executor(resolve, reject);
            } catch (e) {
                reject(e);
            }
        }
        then(onFulfilled, onRejected) {
            if (this.status == RESOLVED) {
                onFulfilled(this.value);
            }
            if (this.status == REJECTED) {
                onFulfilled(this.reason);
            }
            if (this.status == PENDING) {
                this.onFulfilledCallback.push(() => {
                    //todo
                    onFulfilled(this.value);
                });
                this.onRejectedCallback.push(() => {
                    //todo
                    onRejected(this.value);
                });
            }
        }
    }
```

## 详细梳理一下，并解决链式调用。

   - 也就是说Promise是一个类, new的时候传入一个函数, 这个函数内部会在默认立即执行并传入resolve和reject实参, 用户在传入形参的时候就已经执行了resolve或者reject而且传入了值, 这个值会被内部保存下来，并且在你调用then方法时根据status去执行onFulfilled或者onRejected返回值。
   - 链式调用并不像jq里那样返回this而是重新new了一个Promise, 因为Promise的状态一旦确定了不能修改, 这会影响到下一个then的值。

      - Promise 成功和失败返回值都会传到下一个then里。
      - onFulfilled和onRejected的返回值可能是一个Promise或是一个普通值(不是报错和promise都称之为普通值)。
        - 不管失败和成功回调返回普通值都会传到下一个then的成功回调里。
        - 返回Promise会去执行这个promise根据返回的状态去调下个then的成功或失败回调。
        - 若返回一个错误,则一定会传递下一个失败态。如果距离自己最近的then没有reject,它会向下处理。(值的透传下面再说)

   

``` js
   then(onFulfilled, onRejected) {
       let promise2 = new Promise((resolve, reject) => {
           if (this.status == RESOLVED) {
               setTimeout(() => {
                   try {
                       let x = onFulfilled(this.value); //x可能是普通值和promise
                       resolve(x)
                       //resolvePromise(x, promise2, resolve, reject);
                   } catch (e) {
                       reject(e);
                   }
               }, 0);
           }
           if (this.status == REJECTED) {
               setTimeout(() => {
                   try {
                       let x = onRejected(this.reason);
                       resolve(x)
                   } catch (e) {
                       reject(e);
                   }
               }, 0);
           }
       });
       return promise2;
   }
```

   + 根据规范A+ 2.2.4 了解到 onFulfilled和onRejected 必须要去异步执行。onFulfilled和onRejected返回值可能是一个promise，逻辑比较复杂，我们抽离出一个函数resolvePromise, 此函数肩负这判断是否promise或者是普通值, 并且去兼容他人的promise。 
   

``` js
if (this.status == RESOLVED) {

    setTimeout(() => {
        try {
            let x = onFulfilled(this.value); //x可能是普通值和promise
            resolvePromise(x, promise2, resolve, reject);
        } catch (e) {
            reject(e);
        }
    }, 0);

}
```

  注：promise2本来是取不到的, 因为类里的代码还没有执行完，所以规范里提到必须去异步执行。

  + 当resolve返回一个promise的情况时。

  

``` js
     new Promise((resolve, reject) => {
         resolve(new Promise((resolve, reject) => {
             resolve(2)
         }))
     })
     const resolve = (value) => {
         if (value instanceof Promise) {
             // 如果value 是一个promise，那我们的库中应该也要实现一个递归解析
             return value.then(resolve, reject);
         }
         if (this.status == PENDING) {
             this.value = value;
             this.status = RESOLVED;
             this.onFulfilledCallback.forEach((fn) => fn());
         }
     };
```

   - 去判断它是不是Pormise实例就可以了若是执行执行去调用 value.then(resolve, reject); 

## resolvePromise函数

  

``` js
  const resolvePromise = function(x, promise2, resolve, reject) {
      console.log(x, promise2, resolve, reject) //x可能是promise或者普通值，promise2是一个promise的实例
  }
```

  + 当Promise遇到循环引用的时候比如以下代码：

  

``` js
        let p = new Promise((resolve, reject) => {
            resolve(200)
        })
        let p2 = p.then(() => {
            return p2
        }, (e) => {
            console.log(e);
        })
```

 + 这类情况我们只需要去判断x是不是promise2的实例就可以了。

``` js
  //1.循环引用，自己等待自己，类型错误
  if (promise2 === x) {
      return reject(
          new TypeError("Chaining cycle detected for promise #<Promise>")
      );
  }
```

  + 当x是一个普通值直接resolve返回, 若是一个promise的时候。

  

``` js
      if ((typeof x == "object" && x != null) || typeof x === "function") {
          //有可能是promise
          try {
              let then = x.then;
              if (typeof then == "function") {
                  //根据X的值判断成功还是失败
                  then.call(
                      x,
                      (y) => {
                          resolvePromise(y, promise2, resolve, reject);
                      },
                      (r) => {
                          reject(r);
                      }
                  );
              } else {
                  //{then:{12}}当then不是一个函数时
                  resolve(x);
              }
          } catch (e) {
              reject(e);
          }
      } else {
          //普通值
          resolve(x);
      }
```

  + 当我们确定了这个x是一个promise的时候，就需要去执行这个promise, 根据规范要求我们Call了这个then并写入成功函数和失败函数, 需要考虑的是成功函数这个y可能还是一个promise, 我们需要去递归执行它就可以。
  + 剩下的还有具体细节, 都是为了防止他人写的promise没按A+规范要求。
  + resolvePromise完整代码

  

``` js
   const resolvePromise = function(x, promise2, resolve, reject) {
       //1.循环引用，自己等待自己，类型错误
       if (promise2 === x) {
           return reject(
               new TypeError("Chaining cycle detected for promise #<Promise>")
           );
       }
       //以下逻辑是兼容其他人promise
       if ((typeof x == "object" && x != null) || typeof x === "function") {
           //有可能是promise
           let called;
           try {
               let then = x.then;
               if (typeof then == "function") {
                   //根据X的值判断成功还是失败
                   then.call(
                       x,
                       (y) => {
                           if (called) return;
                           called = true; //防止别人的promise成功后又调用失败
                           resolvePromise(y, promise2, resolve, reject);
                       },
                       (r) => {
                           if (called) return;
                           called = true;
                           reject(r);
                       }
                   );
               } else {
                   //{then:{12}}是普通值
                   resolve(x);
               }
           } catch (e) {
               if (called) return;
               called = true;
               reject(e);
           }
       } else {
           //普通值
           resolve(x);
       }
   };
```

## 链式调用的透传

1. 我们可能见过这类代码

``` js
let p = new Promise((resolve, reject) => {
    resolve(1)
})
p.then().then().then((d) => {
    console.log(d);
});
```

  + 顾名思义值的透传就是promise的成功和失败结果都会向下传递。其实很简单，就是判断参数是否传了没传的话执行返回这个值就可以了，以上代码其实可以写成这样。

  

``` js
p.then(
    return 1
).then(
    return 1
).then((d) => {
    console.log(d);
});
```

  + 内部代码实现

``` js
onFulfilled = typeof onFulfilled == "function" ? onFulfilled : v => v;
//失败同理 返会错误
```

## Promise.all

1. `Promise.all` 传入一个数组，里面可以是普通值或者promise, 会等到所有promise完成后返回这个数组。

``` js
  	static all(promises) {
  	        return new Promise((resolve, reject) => {
  	            let arr = [],
  	                i = 0; //resolve 数组
  	            function processData(i, data) {
  	                arr[i] = data
  	                if (++i == promises.length) {
  	                    resolve(arr)
  	                }
  	            }
  	            for (let i = 0; i < promises.length; i++) {
  	                let current = promises[i]
  	                if (isPromise(current)) {
  	                    current.then((value) => {
  	                        processData(i, value)
  	                    }, reject)
  	                } else {
  	                    processData(i, current)
  	                }
  	            }
  	        })
```

  + 迭代传入的数组, 并且去判断每一项是否promise, 若是promise去执行这个promise， `processData` 函数是为了帮助数组各项的值都能拿到值后返回这个数组，因为有异步代码。

## Promise.race

1. `Promise.race` 传入一个数组，数组中可以是普通值或者promise, 先谁完成返回谁。

``` js
	static race(promises) {
	    return new Promise((resolve, reject) => {
	        for (let i = 0; i < promises.length; i++) {
	            let current = promises[i]
	            if (isPromise(current)) {
	                current.then(resolve, reject)
	            } else {
	                resolve(current)
	            }
	        }
	    })
	}
```

## Promise.resolve和Promise.reject

1. 这两个静态方法内部只是在外面包了一层Promise

``` js
static resolve(val) {
    return new Promise((resolve, reject) => {
        resolve(val)
    })
}
static reject(reason) {
    return new Promise((resolve, reject) => {
        reject(reason)
    })
}
```

## finally

1. finally这个原型方法, 不管失败和成功回调都会去执行, 若finally函数里返回了一个Promise, 这 `resolve` 的成功值不会传递下个then `reject` 的失败值会向下传递。

``` js
Promise.resolve(400).finally(() => {
    return new Promise((resolve, reject) => {
        setTimeout(() => {
            resolve('不管这里传了什么，都不会传入下个then')
        }, 2000)
    })
}).then((d) => {
    // throw new Error('fail')
    console.log(d);
}).catch((e) => {
    console.log(e, );
})
```

 + 内部实现

``` js
finally(callback) {
    return this.then((val) => {
        return Promise.resolve(callback()).then(() => val)
    }, (err) => {
        return Promise.resolve(callback()).then(() => {
            throw err
        })
    })
}
```

## catch

1. catch就是一个没有成功回调的then。

``` js
catch (errFN) {
    return this.then(null, errFN)
}
```

## Promise/A+ 规范完整代码

``` js
const {
    resolve
} = require("path");

/**
 * 1. promise 成功和失败的返回值都会传到下个then里面
 * 2. 如果不管fulfilled 和 reject 回调 返回一个普通值(传递到下一个then成功态)，若出错了会一定会传递到失败态，若返回的的是一个promise 会取决于这个promise的状态分发给下个then
   3. 错误处理，如果距离自己最近的then没有reject，它会向下处理。
   4. 每次执行完promise 会返回一个新的promise
 */
const RESOLVED = "RESOLVED";
const REJECTED = "REJECTED";
const PENDING = "PENDING";

const resolvePromise = function(x, promise2, resolve, reject) {
    //1.循环引用，自己等待自己，类型错误
    if (promise2 === x) {
        return reject(
            new TypeError("Chaining cycle detected for promise #<Promise>")
        );
    }
    //以下逻辑是兼容其他人promise
    if ((typeof x == "object" && x != null) || typeof x === "function") {
        //有可能是promise
        let called;
        try {
            let then = x.then;
            if (typeof then == "function") {
                //根据X的值判断成功还是失败
                then.call(
                    x,
                    (y) => {
                        if (called) return;
                        called = true; //防止别人的promise成功后又调用失败
                        resolvePromise(y, promise2, resolve, reject);
                    },
                    (r) => {
                        if (called) return;
                        called = true;
                        reject(r);
                    }
                );
            } else {
                //{then:{12}}是普通值
                resolve(x);
            }
        } catch (e) {
            if (called) return;
            called = true;
            reject(e);
        }
    } else {
        //普通值
        resolve(x);
    }
};
class Promise {
    constructor(executor) {
        this.status = PENDING;
        this.reason = undefined;
        this.value = undefined;
        this.onFulfilledCallback = [];
        this.onRejectedCallback = [];
        const resolve = (value) => {
            if (value instanceof Promise) {
                // 如果value 是一个promise，那我们的库中应该也要实现一个递归解析
                return value.then(resolve, reject);
            }
            if (this.status == PENDING) {
                this.value = value;
                this.status = RESOLVED;
                this.onFulfilledCallback.forEach((fn) => fn());
            }
        };
        const reject = (reason) => {
            if (this.status == PENDING) {
                this.reason = reason;
                this.status = REJECTED;
                this.onRejectedCallback.forEach((fn) => fn());
            }
        };

        try {
            executor(resolve, reject);
        } catch (e) {
            reject(e);
        }
    }
    then(onFulfilled, onRejected) {
        onFulfilled = typeof onFulfilled == "function" ? onFulfilled : v => v;
        onRejected = typeof onRejected == "function" ? onRejected : err => {
            throw err
        };
        let promise2 = new Promise((resolve, reject) => {
            if (this.status == RESOLVED) {
                setTimeout(() => {
                    try {
                        let x = onFulfilled(this.value); //x可能是普通值和promise
                        resolvePromise(x, promise2, resolve, reject);
                    } catch (e) {
                        reject(e);
                    }
                }, 0);
            }
            if (this.status == REJECTED) {
                setTimeout(() => {
                    try {
                        let x = onRejected(this.reason);
                        resolvePromise(x, promise2, resolve, reject);
                    } catch (e) {
                        reject(e);
                    }
                }, 0);
            }

            if (this.status == PENDING) {
                //这里是异步的
                this.onFulfilledCallback.push(() => {
                    //todo
                    setTimeout(() => {
                        try {
                            let x = onFulfilled(this.value);
                            resolvePromise(x, promise2, resolve, reject);
                        } catch (e) {
                            reject(e);
                        }
                    }, 0);
                });
                this.onRejectedCallback.push(() => {
                    //todo
                    setTimeout(() => {
                        try {
                            let x = onRejected(this.reason);
                            resolvePromise(x, promise2, resolve, reject);
                        } catch (e) {
                            reject(e);
                        }
                    }, 0);
                });
            }
        });
        return promise2;
    }
    catch (errFN) {
        return this.then(null, errFN)
    } finally(callback) {
        return this.then((val) => {
            return Promise.resolve(callback()).then(() => val)
        }, (err) => {
            return Promise.resolve(callback()).then(() => {
                throw err
            })
        })
    }
    static all(promises) {
        return new Promise((resolve, reject) => {
            let arr = [],
                i = 0; //resolve 数组
            function processData(i, data) {
                arr[i] = data
                if (++i == promises.length) {
                    resolve(arr)
                }
            }
            for (let i = 0; i < promises.length; i++) {
                let current = promises[i]
                if (isPromise(current)) {
                    current.then((value) => {
                        processData(i, value)
                    }, reject)
                } else {
                    processData(i, current)
                }
            }
        })
    }
    static race(promises) {
        return new Promise((resolve, reject) => {
            for (let i = 0; i < promises.length; i++) {
                let current = promises[i]
                if (isPromise(current)) {
                    current.then(resolve, reject)
                } else {
                    resolve(current)
                }
            }
        })
    }
    static resolve(val) {
        return new Promise((resolve, reject) => {
            resolve(val)
        })
    }
    static reject(reason) {
        return new Promise((resolve, reject) => {
            reject(reason)
        })
    }
}

function isPromise(checkobj) {
    if ((typeof checkobj == 'object' && checkobj != null) || typeof checkobj == 'function') {
        return typeof checkobj.then == 'function'
    }
    return false
}
Promise.defer = Promise.deferred = function() {
    let dfd = {};
    dfd.promise = new Promise((resolve, reject) => {
        dfd.resolve = resolve;
        dfd.reject = reject;
    });
    return dfd;
};
module.exports = Promise;
```
