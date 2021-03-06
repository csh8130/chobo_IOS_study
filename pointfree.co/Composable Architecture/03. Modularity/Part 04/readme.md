# Modular State Management: The Point

 리듀서와 뷰를 모듈로 추출했습니다. 앱의 각 화면은 각자 실행 될 수 있으며 서로를 알 필요없이 테스트 가능 해 졌습니다. 이것이 모듈화 된 상태관리의 핵심입니다.

### 

### What’s the point?

 모듈화를 위해 다음과같은 작업을 했습니다.

- Xcode에서 새 프레임워크를 만들고, 복잡한 빌드 세팅을 합니다.

- 모듈로 이동시킬 코드를 찾고 모듈이 외부에 노출할 인터페이스를 찾습니다.

- 초기화 코드에 boilerplate가 추가되거나, 중간 구조체를 만들었습니다.

 이렇게 힘들게 모듈화 할 필요가 있었을까요? 적당히 파일로 구분하고 `private` , `fileprivate` 같은 접근 제어로도 똑같이 할 수 있지 않았을까요?

 힘들게 모듈화 할 가치가 확실히 있기 때문에 했습니다. 각 화면을 프로젝트로 부터 분리해서 플레이그라운드에서 실행 해 봄으로서 모듈성을 테스트 할 수 있습니다.



### The favorite primes app

 즐겨찾기 화면을 playground에서 테스트 해보겠습니다.

```swift
import ComposableArchitecture
import FavoritePrimes
import SwiftUI
import PlaygroundSupport

PlaygroundPage.current.liveView = UIHostingController(
  rootView: FavoritePrimesView(
    store: Store<[Int], FavoritePrimesAction>(
      initialValue: [],
      reducer: favoritePrimesReducer
    )
  )
)
```

실행하면 빈 뷰가 나타나지만 이는 초기값을 제공하지 않아서 입니다.

```swift

```
