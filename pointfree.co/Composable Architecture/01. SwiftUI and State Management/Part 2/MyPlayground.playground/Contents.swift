import SwiftUI

struct ContentView: View {
    @EnvironmentObject var state: AppState
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: CounterView()) {
                    Text("Counter demo")
                }
                NavigationLink(destination: FavoritePrimes()) {
                  Text("Favorite primes")
                }
            }
            .navigationBarTitle("State management")
        }
    }
}

class AppState: ObservableObject {
    @Published var count: Int = 0
    @Published var favoritePrimes: [Int] = []
}

struct CounterView: View {
    @EnvironmentObject var state: AppState
    @State var isPrimeModalShown: Bool = false
    @State var alertNthPrime: PrimeAlert?
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { self.state.count -= 1 }) {
                  Text("-")
                }
                Text("\(self.state.count)")
                Button(action: { self.state.count += 1 }) {
                  Text("+")
                }
            }
            Button(action: { self.isPrimeModalShown = true }) {
                Text("Is this prime?")
            }
            Button(action: {
              nthPrime(self.state.count) { prime in
                self.alertNthPrime = prime.map{PrimeAlert(prime: $0)}
              }
            }) {
              Text("What's the \(ordinal(self.state.count)) prime?")
            }
        }
        .font(.title)
        .navigationBarTitle("Counter demo")
        .sheet(isPresented: $isPrimeModalShown) {
            IsPrimeModalView().environmentObject(self.state)
        }
        .alert(item: self.$alertNthPrime) { alert in
          Alert(
            title: Text("The \(ordinal(self.state.count)) prime is \(alert.prime)"),
            dismissButton: .default(Text("Ok"))
          )
        }
    }
    
    private func ordinal(_ n: Int) -> String {
      let formatter = NumberFormatter()
      formatter.numberStyle = .ordinal
      return formatter.string(for: n) ?? ""
    }
}

struct IsPrimeModalView: View {
  @EnvironmentObject var state: AppState
  var body: some View {
    VStack {
      if isPrime(self.state.count) {
        Text("\(self.state.count) is prime 🎉")
        if self.state.favoritePrimes.contains(self.state.count) {
          Button(action: { self.state.favoritePrimes.removeAll(where: { $0 == self.state.count }) }) {
            Text("Remove from favorite primes")
          }
        } else {
          Button(action: { self.state.favoritePrimes.append(self.state.count) }) {
            Text("Save to favorite primes")
          }
        }
      } else {
        Text("\(self.state.count) is not prime :(")
      }
    }
  }
}

struct FavoritePrimes: View {
  @EnvironmentObject var state: AppState

    var body: some View {
        List {
            ForEach(self.state.favoritePrimes, id: \.self) { prime in
                Text("\(prime)")
            }.onDelete { indexSet in
                for index in indexSet {
                    self.state.favoritePrimes.remove(at: index)
                }
            }
        }
        .navigationBarTitle(Text("Favorite Primes"))
    }
    
}

private func isPrime (_ p: Int) -> Bool {
  if p <= 1 { return false }
  if p <= 3 { return true }
  for i in 2...Int(sqrtf(Float(p))) {
    if p % i == 0 { return false }
  }
  return true
}

struct WolframAlphaResult: Decodable {
  let queryresult: QueryResult

  struct QueryResult: Decodable {
    let pods: [Pod]

    struct Pod: Decodable {
      let primary: Bool?
      let subpods: [SubPod]

      struct SubPod: Decodable {
        let plaintext: String
      }
    }
  }
}

func wolframAlpha(query: String, callback: @escaping (WolframAlphaResult?) -> Void) -> Void {
    let wolframAlphaApiKey = "6H69Q3-828TKQJ4EP"
  var components = URLComponents(string: "https://api.wolframalpha.com/v2/query")!
  components.queryItems = [
    URLQueryItem(name: "input", value: query),
    URLQueryItem(name: "format", value: "plaintext"),
    URLQueryItem(name: "output", value: "JSON"),
    URLQueryItem(name: "appid", value: wolframAlphaApiKey),
  ]

  URLSession.shared.dataTask(with: components.url(relativeTo: nil)!) { data, response, error in
    callback(
      data
        .flatMap { try? JSONDecoder().decode(WolframAlphaResult.self, from: $0) }
    )
    }
    .resume()
}

func nthPrime(_ n: Int, callback: @escaping (Int?) -> Void) -> Void {
  wolframAlpha(query: "prime \(n)") { result in
    callback(
      result
        .flatMap {
          $0.queryresult
            .pods
            .first(where: { $0.primary == .some(true) })?
            .subpods
            .first?
            .plaintext
      }
      .flatMap(Int.init)
    )
  }
}

struct PrimeAlert: Identifiable {
  let prime: Int

  var id: Int { self.prime }
}

//nthPrime(10000) {
//    print($0)
//}

import PlaygroundSupport

PlaygroundPage.current.liveView = UIHostingController(
    rootView: ContentView().environmentObject(AppState())
//  rootView: CounterView()
)
