---
sidebar_position: 1
---

# Segmented State Pattern (SSP)

When we talk about a single flow state, we end up solving architecture problems early, as we will have only one data flow for each state.

In addition to the maintainability and to the ease of use architecture, we also have the possibility of increasing this flow with other standards such as the Observer, which gives reactivity to the component when it is modified, and Memento, which makes it possible to revert or redo this state.

A beautiful example of a pattern with a single flow is BLoC, giving reactivity to a state allowing all transformations in that flow. This (although complicated for some), consolidates very well in the architecture of a project, even the limits of this practice are beneficial for not allowing the developer to resort to other solutions for the architecture and the standard for its resource.

There are other ways to promote reactivity in a property instead of the entire object, such as MobX's Observable and Flutter's ValueNotifier, and that gives us a lot of choices. However, we lose some important architecture limits, which can put in check the project maintenance in the future. Therefore, it needs a standard to force limits on the individual reactivity of each property and thereby improve the maintainability of the components responsible for managing the states of the application.


## Single Flow Pattern (BLoC and Flux/Redux)
.
![schema](./bloc.png)

When we work with a single flow state, it means that when the reactivity is on the object and not on its properties, we can have more control over the data being processed before reaching a listener.
For example, if your logic manages an X state and it wants to change it to Y, it just needs to assign the value.
```dart
MyState state = X();
state = Y();
```
However, the flow can contain asynchronous elements and it is always interesting to inform us that the state is being loaded. This is quite common in Mobile development with API for example.
```dart
MyState state = X();
state = Loading();
state = await getY(); // return Y
```
The recovery of these data can also fail, and this makes the existence of an error state pertinent.
```dart
MyState state = X();
state = Loading();
try{
  state = await getY();
} catch(e) {
  state = Error();
}

```

As we are talking about a single flow, we use ** POLYMORPHISM ** of OOP to share these 3 responsibilities (State Value, Loading, or Error).

```dart
abstract class MyState {}

class X extends MyState
class Y extends MyState
class Loading extends MyState
class Error extends MyState
```
With that, we have a single Flow of **MyState**, because the objects X, Y, Loading, and Error inherit from **MyState**.
```dart
X is MyState; // it's true!
Y is MyState; // it's true!
Loading is MyState; // it's true!
Error is MyState; // it's also true!
```
Thanks OOP :)

> **IMPORTANT:** BLoC is an acronym for Business Logic Component.

## Targeting the state in State, Error, Loading
.
![schema](schema.png)

Now, because we have the possibility to have reactivity for each property with MobX or ValueNotifier, we would not need Polymorphism if we divide the responsibility of Loading and Error to separate properties within a **STORE**. And so we have a triple making Loading and Error actions post or pre-change of state.
An example using MobX:
```dart
...
@observable 
ProductData state = ProductData.empty();

@observable 
bool isLoading = false;

@observable 
Exception? error;

@action
Future<void> fetchProducts() async {
  isLoading = true;
  try{
    state = await repository.getProducts(); // return ProductData
  } catch(e){
    error = Exception('Error');
  }
  isLoading = false;
}
```

In summary, we have 3 flows, the state that has the state value, the error that holds the exceptions, and the isLoading bool that informs when the loading action is happening.
Being able to listen to these 3 actions separately helps us to transform them and combine them into other actions, supplementing your Store (Class with the logic responsible for managing the state of your component).
As the movement of the state is always around the trio State, Error, and Loading, it makes it worth the standardization.

> **IMPORTANT:** An object called **Store** is responsible for storing the Logic for the state of a component.

## Seeing the Flows

Having 3 separate flows we can have 3 different listeners, for example, we can hear the error and launch it in the form of "SnackBar" and when there are Loadings we can launch a Dialog, but if we need to add to this state a pattern like "memento" we will have to put the 3 properties in a generic object.
To close the pattern of the 3 Flows we can create a generic object, its properties can be reactive as well as the object itself. Let's look at an example with MobX.

```dart

class Triple<Error, State> {
  final State state;
  final Error? error;
  final bool isLoading;

  Triple({required this.state, this.error, this.isLoading = false});

  Triple<Error, State> copyWith({State? state, Error? error, bool? isLoading}){
    return Triple<Error, State>(
      state: state ?? this.state,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

```

So, we can use:
```dart
@observable 
var triple = Triple<Exception, ProductData>(state: ProductData.empty());

@action
Future<void> fetchProducts() async {
  triple = triple.copyWith(isLoading: true);
  try{
    final state = await repository.getProducts(); // return ProductData
    triple = triple.copyWith(isLoading: false, state: state);
  } catch(e){
    final error = Exception('Error');
    triple = triple.copyWith(isLoading: false, error: error);
  }
}
```

We now have an object that joins the 3 segmented state properties that can also be accessed and transformed individually using MobX's @computed which automatically distinguishes and only triggers a reaction if the property is really a new object.

```dart
@observable 
var _triple = Triple<Exception, ProductData>(state: ProductData.empty());

@computed
ProductData get state => _triple.state;

@computed
Exception get error => _triple.error;

@computed
bool get isLoading => _triple.isLoading;

...
```

With the object bringing together the state and its actions, we can implement other design patterns or just make transformations on the object or separately on its properties.
Let's see a small example of implementation of the Design Pattern Memento that will make it possible for the state to rollback, which means returning to the previous states as a time machine.

```dart
...

@observable 
var _triple = Triple<Exception, ProductData>(state: ProductData.empty());

@computed
ProductData get state => _triple.state;
@computed
Exception get error => _triple.error;
@computed
bool get isLoading => _triple.isLoading;

//save all changed states
final List<Triple<Exception, ProductData>> _history = [];

@action
void update(ProductData state){
  _history.add(_triple);
  _triple = _triple.copyWith(state: state);
}

@action
void setError(Exception error){
  _triple = _triple.copyWith(error: error);
}

@action
void setLoading(bool loading){
  _triple = _triple.copyWith(loading: loading);
}

@action
void undo(){
  if(_history.length > 0){
    _triple = _history.last;
    _history.remove(_triple);
  } else {
    throw Exception('Not have history data');
  }
}

@action
Future<void> fetchProducts() async {
  _triple = setLoading(true);
  try{
    final state = await repository.getProducts(); // return ProductData
    _triple = update(state);
  } catch(e){
    final error = Exception('Error');
    _triple = setError(error);
  }
  _triple = setLoading(false);
}
```

We have implemented something very complex, but it is easy to understand what is happening just by reading the code.
So we come to a standard that can be used to manage states and sub-states using reactivity individually by property.

The Segmented State (Or Triple) pattern can be abstracted to make its reusability stronger. We will use MobX again as an example, but we can use it in any type of reactivity by property.

```dart
abstract class MobXStore<Error, State> {

  @observable 
  late Triple<Error, State> _triple;

  MobXStore(State initialState){
     _triple = Triple<Error, State>(state: initialState);
  }

  @computed
  State get state => _triple.state;
  @computed
  Error get error => _triple.error;
  @computed
  bool get isLoading => _triple.isLoading;

  //save all changed states
  final List<Triple<Error, State>> _history = [];

  @action
  void update(State state){
    _history.add(_triple);
    _triple = _triple.copyWith(state: state);
  }

  @action
  void setError(Error error){
    _triple = _triple.copyWith(error: error);
  }

  @action
  void setLoading(bool isLoading){
    _triple = _triple.copyWith(isLoading: isLoading);
  }

  @action
  void undo(){
    if(_history.length > 0){
      _triple = _history.last;
      _history.remove(_triple);
    } else {
      throw Exception('Not have history data');
    }
  }
}
```

Now, just implement **MobXStore** in any Store of MobX.

```dart
class Product = ProductBase with _$Product;

abstract class ProductBase extends MobXStore<Exception, ProductData> with Store {

  ProductBase(): super(ProductData.empty());

  @action
  Future<void> fetchProducts() async {
    setLoading(true);
    try{
      final state = await repository.getProducts(); // return ProductData
      update(state);
    } catch(e){
      final error = Exception('Error');
      setError(error);
    }
    setLoading(false);
  }
}

```

Once again THANK YOU MOTHER OOP.

