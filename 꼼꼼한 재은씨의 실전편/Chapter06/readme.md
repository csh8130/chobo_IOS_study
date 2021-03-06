# 챕터6 - 데이터베이스와 FMDB

### 프로퍼티 리스트 저장의 단점

 `plist`는 대량의 데이터를 일고 쓰기에는 적합하지않습니다. 예를들어 GPS 신호를 주기적으로 받아 계속 쌓아야하는 상황이 있다고 가정할 때 이런 데이터를 프로퍼티 리스트의 Array에 계속 쌓으면서 저장해야만 합니다.

데이터가 커지면 커질수록 나중에 이 데이터의 일부분이 필요하더라도 Array 전체를 읽어야만 합니다. 데이터 추가의 경우에도 마찬가지로 우선  Array 전체를 읽은 후에 추가가 가능하고 저장을 할 수 있습니다.

 `데이터베이스`를 사용하면 필요한 범위의 데이터만 선택적으로 읽을 수 있으므로 이러한 특징 덕분에 plist에 비해 대용량 데이터 처리에 적합합니다.



### 트랜잭션

 DBMS는 기본적으로 생성, 읽기, 수정, 삭제 4가지 기본기능을 제공하는데 이를 `CRUD`라고 부릅니다. 여기서 하나 이상의 CRUD 명령을 묶은 논리적 단위를 `트랜잭션`이라고 합니다.

트랜잭션이 필요한 이유로 은행의 계좌 이체를 예로 들 수 있습니다. A계좌에서 인출, B 계좌에 입금 같이 여러 명령의 묶음으로 동작하는 작업은 일부 작업만 동작하고 일부작업이 동작하지않으면 매우 위험합니다. 이를 위해 트랜잭션단위로 묶어서 명령은 성공하거나 실패하도록 DBMS에서 관리됩니다.

 트랜잭션을 논리적 작업 단위 (LUW, Logical Units of Work)라고 부르기도 합니다.



DBMS의 트랜잭션에는 4대 원칙인 ACID가 있습니다.

1. 원자성 (Atomicity)

2. 일관성 (Consistency)

3. 격리성 (Isolation)

4. 지속성 (Durability)


