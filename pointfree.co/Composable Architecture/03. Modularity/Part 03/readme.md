# Modular State Management: View Actions

 View에서 AppState 전체가 아닌 작게 쪼갠 State를 취할 수 있게 되었습니다. View는 점점 Reducer와 비슷한 범위를 가지려 하고 있습니다.



### Transforming a store’s action

 Store를 사용하는 View에서 State에 접근하는 부분을 개선 했지만 AppAction에 의존하는 코드가 남아있어서 모듈로 분리는 불가능합니다.

```swift
final class Store<Value, Action>: ObservableObject {
  …
  func ___<LocalAction>() -> Store<Value, LocalAction>
}
```

 위 처럼 Global Action을 Local Action으로 변환 해 줄 함수가 필요합니다.



```swift
final class Store<Value, Action>: ObservableObject {
  …
  public func view<LocalAction>(
    f: @escaping (LocalAction) -> Action
  ) -> Store<Value, LocalAction> {
    return Store<Value, LocalAction>(
      initialValue: self.value,
      reducer: { value, localAction in
        self.send(f(action))
        value = self.value
    }
    )
  }
}
```



### Combining view functions

 global Store를 local Store로 변환하는 함수와 global Action을 local Action으로 변환하는 기능은 하나로 합칠 수 있습니다.

```swift
public func view<LocalValue, LocalAction>(
        value toLocalValue: @escaping (Value) -> LocalValue,
        action toGlobalAction: @escaping (LocalAction) -> Action
    ) -> Store<LocalValue, LocalAction> {
        let localStore = Store<LocalValue, LocalAction>(
            initialValue: toLocalValue(self.value),
            reducer: { localValue, localAction in
                self.send(toGlobalAction(localAction))
                localValue = toLocalValue(self.value)
            }
        )
        localStore.cancellable = self.$value.sink { [weak localStore] newValue in
            localStore?.value = toLocalValue(newValue)
        }
        return localStore
    }
```



### Focusing on favorite primes actions

```swift
struct FavoritePrimesView: View {
  @ObservedObject var store: Store<[Int], FavoritePrimesAction>
```

 즐겨찾기 View의 액션을 바꿔줍니다. 

```swift
NavigationLink(
  "Favorite primes",
  destination: FavoritePrimesView(
    store: self.store.view(
      value: { $0.favoritePrimes },
      action: { AppAction.favoritePrimes($0) }
    )
  )
)
```



### Extracting our first modular view

  이제 뷰 자체를 모듈화 시킬 준비가 되었습니다. `FavoritePrimesView`를 잘라내어 `FavoritePrimes`모듈로 이동 시킵니다.

 이전에 PrimeModal을 모듈로 옮길 때 와 마찬가지로 자동 생성 이니셜 라이저로는 접근제어자를 변경 할 수 없어서 생성자를 만들어 줘야 합니다.

```swift
public struct FavoritePrimesView: View {
  @ObservedObject var store: Store<[Int], FavoritePrimesAction>

  public init(store: Store<[Int], FavoritePrimesAction>)
    self.store = store
  }

  public var body: some View {
    …
  }
}
```



### Focusing on prime modal actions

 PrimeModal을 위에서 한것과 마찬가지로 모듈로 이동시킨다. 동일한 작업이었고 변경하는데 몇 초 걸리지 않았다.



### Focusing on counter actions

 카운터 View는 PrimeModal Action을 보낼 수 있어야 합니다. 이전에 PrimeModal의 State를 제한 할 때 사용한 방식처럼 중간 유형을 만듭니다. 대신 구조체를 사용하지않고 열거형으로 만들었습니다.

```swift
enum CounterViewAction {
  case counter(CounterAction)
  case primeModal(PrimeModalAction)
}
```

 다른것은 더 변경 할 필요가 없습니다. 다만 카운터 뷰의 초기화 호출 부분이 변경되어야 합니다.

```swift
NavigationLink(
  "Counter demo",
  destination: CounterView(
    store: self.store.view(
      value: { ($0.count, $0.favoritePrimes) },
      action: { $0 }
    )
  )
)
```

기존의 이런 형태에서

```swift
NavigationLink(
  "Counter demo",
  destination: CounterView(
    store: self.store.view(
      value: { ($0.count, $0.favoritePrimes) },
      action: {
        switch $0 {
        case let .counter(action):
          return AppAction.counter(action)
        case let .primeModal(action):
          return AppAction.primeModal(action)
        }
      }
    )
  )
)
```

이런 방식이 됩니다.

 이제 카운터 뷰를 모듈로 옮길 준비가 끝났습니다. 많은 요소가 함께 이동되어야합니다.

```swift
struct PrimeAlert: Identifiable {
  …
}

enum CounterViewAction {
  …
}

struct CounterView: View {
  @ObservedObject var store: Store<CounterViewState, CounterViewAction>
  …

  var body: some View {
    …
  }
}

func nthPrime(_ n: Int, callback: @escaping (Int?) -> Void) -> Void {
  …
}

func ordinal(_ n: Int) -> String {
  …
}
```

 추가적으로 `import  PrimeModal`가 필요합니다.

 많은 컴파일 애러가 발생하게됩니다, 접근제어를 public으로 변경하고, wolframAlpha api 들을 가져옵니다. 그리고 컴파일에 성공하게 됩니다.


