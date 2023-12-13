### 排序
 ## 冒泡
```js
        function bubble_sort(arr) {
            for (let i = arr.length; i > 0; i--) {
                for (let j = 0; j < i; j++) {
                    if (arr[i] < arr[j]) {
                        // let t = arr[i]
                        // arr[i] = arr[j]
                        // arr[j] = t
                        [arr[i], arr[j]] = [arr[j], arr[i]]
                    }
                }
            }
          console.log(arr);
        }
      bubble_sort([2, 4, 5, 3, 5, 6, 7, 1, 9])
```

    