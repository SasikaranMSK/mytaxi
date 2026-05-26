# Authentication UI Flow Diagrams

## 🎯 Authentication Screen Flow

### High-Level User Journey

```
┌─────────────────────────────────────────────────────────────────┐
│                      USER JOURNEY                               │
└─────────────────────────────────────────────────────────────────┘

    [App Launch]
         │
         ↓
    ┌─────────────┐
    │ LoginPage   │ ← Initial Route (RouteConstants.login)
    └──────┬──────┘
           │
           │ User enters credentials
           │ and taps "Login"
           ↓
    ┌─────────────┐
    │  Loading    │ ← AuthLoading state
    │   Spinner   │
    └──────┬──────┘
           │
     ┌─────┴─────┐
     │           │
     ↓           ↓
┌─────────┐  ┌─────────┐
│ Success │  │  Error  │
└────┬────┘  └────┬────┘
     │            │
     ↓            ↓
[Vehicle    [Error Popup]
  Screen]        │
                 ↓
            [Stay on Login]
```

---

## 📱 Screen Architecture

### Component Hierarchy

```
LoginPage (Stateless Widget)
│
├── BlocListener<AuthBloc, AuthState>
│   └── Listens for:
│       ├── AuthSuccess → Navigate to Vehicle Screen
│       └── AuthFailure → Show Error Popup
│
└── Child: LoginForm
    │
    ├── Container (Gradient Background)
    │   └── LinearGradient [#0F2027, #203A43, #2C5364]
    │
    └── SafeArea
        └── SingleChildScrollView
            └── Column
                ├── Welcome Text
                ├── Username Input Field
                ├── Password Input Field
                ├── Remember Me Checkbox
                ├── Forgot Password Link
                ├── Login Button (BlocBuilder)
                └── Sign Up Link
```

---

## 🔄 State Flow Diagram

### Detailed State Transitions

```
┌────────────────────────────────────────────────────────────────┐
│                    STATE TRANSITION DIAGRAM                     │
└────────────────────────────────────────────────────────────────┘

                        ┌──────────────┐
                   ┌───→│ AuthInitial  │←────┐
                   │    └──────┬───────┘     │
                   │           │             │
                   │           │ LoginRequested Event
                   │           ↓             │
                   │    ┌──────────────┐     │
                   │    │ AuthLoading  │     │
                   │    └──────┬───────┘     │
                   │           │             │
                   │     ┌─────┴─────┐       │
                   │     │           │       │
                   │     ↓           ↓       │
                   │ ┌─────────┐ ┌─────────┐│
                   │ │Success  │ │Failure  ││
                   │ └────┬────┘ └────┬────┘│
                   │      │           │     │
                   │      │           └─────┘
                   │      │
                   │      ↓
                   │ [Navigate Away]
                   │
                   │ LogoutRequested Event
                   │      ↓
                   │ ┌──────────────┐
                   └─│AuthLoggedOut │
                     └──────────────┘
```

---

## 🎨 UI Component States

### Login Button States

```
┌─────────────────────────────────────────────────────────────┐
│                    LOGIN BUTTON STATES                       │
└─────────────────────────────────────────────────────────────┘

┌─────────────────┐
│  AuthInitial    │
└─────────────────┘
        │
        ▼
┌─────────────────────────────────────────┐
│  Button: ENABLED                        │
│  Text: "LOGIN"                          │
│  OnPressed: () => dispatch LoginEvent   │
│  Color: Green (#4CAF50)                 │
└─────────────────────────────────────────┘


┌─────────────────┐
│  AuthLoading    │
└─────────────────┘
        │
        ▼
┌─────────────────────────────────────────┐
│  Button: DISABLED (loading: true)      │
│  Widget: CircularProgressIndicator      │
│  Size: 18x18, strokeWidth: 2           │
│  Color: White                           │
└─────────────────────────────────────────┘


┌─────────────────┐
│  AuthFailure    │
└─────────────────┘
        │
        ▼
┌─────────────────────────────────────────┐
│  Button: RE-ENABLED                     │
│  Text: "LOGIN"                          │
│  Additional: Error popup shown          │
└─────────────────────────────────────────┘
```

### Input Field States

```
┌───────────────────────────────────────────────────────┐
│              USERNAME INPUT FIELD                     │
├───────────────────────────────────────────────────────┤
│  Controller: TextEditingController                    │
│  Icon: Icons.person_outline                           │
│  Hint: "Username"                                     │
│  Background: White with 8% opacity                    │
│  Border: Rounded 12px, no border side                 │
│  Text Color: White                                    │
└───────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────┐
│              PASSWORD INPUT FIELD                     │
├───────────────────────────────────────────────────────┤
│  Controller: TextEditingController                    │
│  Icon: Icons.lock_outline                             │
│  Hint: "Password"                                     │
│  Obscure: _obscure (toggleable via suffix icon)      │
│  Suffix Icon: visibility_off / visibility             │
│  Background: White with 8% opacity                    │
│  Border: Rounded 12px, no border side                 │
│  Text Color: White                                    │
└───────────────────────────────────────────────────────┘
```

---

## 💡 Event Dispatch Flow

### User Interaction to Event

```
┌─────────────────────────────────────────────────────────────┐
│                  USER INTERACTION FLOW                       │
└─────────────────────────────────────────────────────────────┘

  User Action: Tap Login Button
       │
       ↓
  ┌─────────────────────────────┐
  │  LoginButton.onPressed()    │
  └──────────────┬──────────────┘
                 │
                 ↓
  ┌─────────────────────────────────────────────┐
  │  context.read<AuthBloc>().add(              │
  │    LoginRequested(                          │
  │      _username.text.trim(),                 │
  │      _password.text.trim(),                 │
  │    )                                        │
  │  )                                          │
  └──────────────┬──────────────────────────────┘
                 │
                 ↓
  ┌─────────────────────────────┐
  │  AuthBloc receives event    │
  └──────────────┬──────────────┘
                 │
                 ↓
  ┌─────────────────────────────┐
  │  _onLogin() handler called  │
  └──────────────┬──────────────┘
                 │
                 ↓
           [State Changes...]
```

---

## 🔔 Navigation Flow

### Screen Transitions

```
┌────────────────────────────────────────────────────────────┐
│                   NAVIGATION DIAGRAM                        │
└────────────────────────────────────────────────────────────┘

┌──────────────────────┐
│   main.dart          │
│   initialRoute:      │
│   RouteConstants     │
│      .login          │
└──────────┬───────────┘
           │
           ↓
┌──────────────────────┐
│   LoginPage          │ ← Route: '/login'
│   (Authentication)   │
└──────────┬───────────┘
           │
           │ BlocListener detects AuthSuccess
           ↓
┌──────────────────────────────────────────┐
│  Navigator.pushReplacementNamed(         │
│    context,                              │
│    RouteConstants.vehicle                │
│  )                                       │
└──────────┬───────────────────────────────┘
           │
           ↓
┌──────────────────────┐
│  VehicleEntryScreen  │ ← Route: '/vehicle'
│  (wrapped in         │
│   _LogoutScaffold)   │
└──────────┬───────────┘
           │
           │ User enters vehicle number
           ↓
┌──────────────────────┐
│  TaxiMeterScreen     │ ← Route: '/meter'
│  (Main feature)      │
└──────────────────────┘


LOGOUT FLOW:
┌──────────────────────┐
│  Any screen with     │
│  _LogoutScaffold     │
└──────────┬───────────┘
           │
           │ User taps logout in AppBar
           ↓
┌──────────────────────┐
│  Confirmation Dialog │
└──────────┬───────────┘
           │
           │ User confirms
           ↓
┌──────────────────────────────────────────┐
│  context.read<AuthBloc>()                │
│    .add(LogoutRequested())               │
└──────────┬───────────────────────────────┘
           │
           ↓
┌──────────────────────┐
│  AuthLoggedOut state │
└──────────┬───────────┘
           │
           │ BlocListener in _LogoutScaffold
           ↓
┌──────────────────────────────────────────┐
│  Navigator.pushNamedAndRemoveUntil(      │
│    context,                              │
│    RouteConstants.login,                 │
│    (_) => false                          │
│  )                                       │
└──────────┬───────────────────────────────┘
           │
           ↓
┌──────────────────────┐
│  LoginPage           │ ← Back to login (all routes cleared)
└──────────────────────┘
```

---

## 🎭 Error Handling Flow

### Error State Management

```
┌─────────────────────────────────────────────────────────────┐
│                    ERROR HANDLING FLOW                       │
└─────────────────────────────────────────────────────────────┘

  LoginUseCase throws Exception
       │
       ↓
  ┌─────────────────────────────────────┐
  │  catch (e) in AuthBloc._onLogin()   │
  └──────────────┬──────────────────────┘
                 │
                 ↓
  ┌─────────────────────────────────────────────┐
  │  Error Message Cleaning:                    │
  │  1. e.toString()                            │
  │  2. Remove 'Exception: ' prefix             │
  │  3. Trim whitespace                         │
  │  4. Default to 'Login failed' if empty      │
  └──────────────┬──────────────────────────────┘
                 │
                 ↓
  ┌─────────────────────────────────────┐
  │  emit(AuthFailure(errorMessage))    │
  └──────────────┬──────────────────────┘
                 │
                 ↓
  ┌──────────────────────────────────────────────┐
  │  BlocListener in LoginPage detects failure   │
  └──────────────┬───────────────────────────────┘
                 │
                 ↓
  ┌─────────────────────────────────────┐
  │  showErrorPopup(                    │
  │    context,                         │
  │    message: state.message           │
  │  )                                  │
  └──────────────┬──────────────────────┘
                 │
                 ↓
  ┌─────────────────────────────────────┐
  │  Dialog appears with:               │
  │  • Title: "Error"                   │
  │  • Message: Cleaned error text      │
  │  • Button: "OK"                     │
  └──────────────┬──────────────────────┘
                 │
                 ↓
  [User remains on LoginPage]
  [Login button re-enabled]
```

---

## 🧩 Widget Composition

### LoginForm Widget Tree

```
LoginForm (StatefulWidget)
│
├── Local State:
│   ├── _username: TextEditingController
│   ├── _password: TextEditingController
│   ├── _obscure: bool = true
│   └── _rememberMe: bool = true
│
└── Build Tree:
    │
    Container
    └── decoration: LinearGradient
        └── SafeArea
            └── Center
                └── SingleChildScrollView
                    └── padding: 28px horizontal
                        └── Column
                            ├── SizedBox(height: 40)
                            │
                            ├── Text("Welcome Back")
                            │   └── fontSize: 26, bold, white
                            │
                            ├── SizedBox(height: 8)
                            │
                            ├── Text("Login to continue")
                            │   └── color: white70
                            │
                            ├── SizedBox(height: 40)
                            │
                            ├── _input (Username Field)
                            │   ├── controller: _username
                            │   ├── hint: "Username"
                            │   └── icon: Icons.person_outline
                            │
                            ├── SizedBox(height: 16)
                            │
                            ├── _input (Password Field)
                            │   ├── controller: _password
                            │   ├── hint: "Password"
                            │   ├── icon: Icons.lock_outline
                            │   ├── obscure: _obscure
                            │   └── suffixIcon: IconButton
                            │       └── toggles _obscure
                            │
                            ├── SizedBox(height: 12)
                            │
                            ├── Row
                            │   ├── RememberMeCheckbox
                            │   │   ├── value: _rememberMe
                            │   │   └── onChanged: setState
                            │   │
                            │   └── TextButton("Forgot password?")
                            │       └── onPressed: _showForgotPasswordDialog
                            │
                            ├── SizedBox(height: 20)
                            │
                            ├── BlocBuilder<AuthBloc, AuthState>
                            │   └── LoginButton
                            │       ├── loading: state is AuthLoading
                            │       └── onPressed: () {
                            │             context.read<AuthBloc>().add(
                            │               LoginRequested(
                            │                 _username.text.trim(),
                            │                 _password.text.trim(),
                            │               )
                            │             )
                            │           }
                            │
                            ├── SizedBox(height: 40)
                            │
                            └── Row (Sign Up Link)
                                ├── Text("Create an account")
                                └── Text("Sign up", color: green, bold)
```

---

## 🔐 Security & Data Flow

### Credential Handling

```
┌─────────────────────────────────────────────────────────────┐
│                 CREDENTIAL FLOW & STORAGE                    │
└─────────────────────────────────────────────────────────────┘

  User Input
       │
       ▼
  ┌─────────────────────────┐
  │  _username.text.trim()  │ ← TextEditingController
  │  _password.text.trim()  │
  └──────────┬──────────────┘
             │
             │ Passed via Event
             ▼
  ┌─────────────────────────┐
  │  LoginRequested(        │
  │    username,            │
  │    password             │
  │  )                      │
  └──────────┬──────────────┘
             │
             │ Handled by BLoC
             ▼
  ┌─────────────────────────┐
  │  LoginUseCase(          │
  │    username,            │
  │    password             │
  │  )                      │
  └──────────┬──────────────┘
             │
             │ Creates Request Model
             ▼
  ┌─────────────────────────┐
  │  LoginRequestModel(     │
  │    username,            │
  │    password,            │
  │    macAddress           │ ← Device ID
  │  )                      │
  └──────────┬──────────────┘
             │
             │ API Call
             ▼
  ┌─────────────────────────┐
  │  Repository.login()     │
  └──────────┬──────────────┘
             │
             │ Returns AuthModel
             ▼
  ┌─────────────────────────────────┐
  │  AuthModel(                     │
  │    token,                       │
  │    username,                    │
  │    deviceId                     │
  │  )                              │
  └──────────┬────────────────────-─┘
             │
             │ Stored Securely
             ▼
  ┌─────────────────────────────────┐
  │  AuthLocalDataSource            │
  │    .saveAuthData()              │
  │                                 │
  │  Storage: FlutterSecureStorage  │
  │    ├─ token                     │
  │    ├─ username                  │
  │    └─ deviceId                  │
  └─────────────────────────────────┘
```

### Token Usage

```
  Subsequent API Calls
       │
       ▼
  ┌─────────────────────────────┐
  │  Dio Interceptor            │
  │  (in ApiClient)             │
  └──────────┬──────────────────┘
             │
             │ Get token from storage
             ▼
  ┌─────────────────────────────┐
  │  AuthLocalDataSource        │
  │    .getToken()              │
  └──────────┬──────────────────┘
             │
             │ Add to headers
             ▼
  ┌─────────────────────────────┐
  │  headers: {                 │
  │    'Authorization':         │
  │      'Bearer $token'        │
  │  }                          │
  └─────────────────────────────┘
```

---

## 📊 BLoC Architecture Details

### Event Flow in AuthBloc

```
┌───────────────────────────────────────────────────────────────┐
│                  AuthBloc Event Handlers                       │
└───────────────────────────────────────────────────────────────┘

class AuthBloc extends Bloc<AuthEvent, AuthState> {

  AuthBloc(this._login, this._logout) : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);      ← Event Handler Registration
    on<LogoutRequested>(_onLogout);
  }

  ┌─────────────────────────────────────────────────────┐
  │  _onLogin(LoginRequested event, Emitter emit)       │
  ├─────────────────────────────────────────────────────┤
  │                                                     │
  │  1. emit(AuthLoading())                            │
  │     └─ UI shows loading spinner                    │
  │                                                     │
  │  2. try {                                          │
  │       final auth = await _login(                   │
  │         username: event.username,                  │
  │         password: event.password,                  │
  │       );                                           │
  │                                                     │
  │  3. if (auth == null)                             │
  │       emit(AuthFailure('Login failed'))           │
  │     else                                           │
  │       emit(AuthSuccess(auth))                     │
  │       └─ UI navigates to vehicle screen            │
  │    }                                               │
  │                                                     │
  │  4. catch (e) {                                    │
  │       Clean error message                          │
  │       emit(AuthFailure(cleanedMessage))           │
  │       └─ UI shows error popup                      │
  │     }                                              │
  └─────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────┐
  │  _onLogout(LogoutRequested event, Emitter emit)     │
  ├─────────────────────────────────────────────────────┤
  │                                                     │
  │  1. emit(AuthLoading())                            │
  │                                                     │
  │  2. try {                                          │
  │       await _logout()                              │
  │     } catch (_) { /* ignore */ }                   │
  │                                                     │
  │  3. emit(AuthLoggedOut())                         │
  │     └─ Triggers navigation to login                │
  │                                                     │
  │  4. emit(AuthInitial())                           │
  │     └─ Reset state for next login                  │
  └─────────────────────────────────────────────────────┘
}
```

---

## 🎯 Testing Checklist

### UI Tests
- [ ] Login button is enabled when form is in AuthInitial
- [ ] Login button shows spinner when in AuthLoading
- [ ] Login button is disabled during loading
- [ ] Navigation occurs on AuthSuccess
- [ ] Error popup appears on AuthFailure
- [ ] Password visibility toggle works
- [ ] Remember me checkbox updates state
- [ ] Forgot password dialog opens

### BLoC Tests
- [ ] AuthBloc emits [AuthLoading, AuthSuccess] on successful login
- [ ] AuthBloc emits [AuthLoading, AuthFailure] on failed login
- [ ] AuthBloc emits [AuthLoading, AuthLoggedOut, AuthInitial] on logout
- [ ] Error messages are cleaned properly
- [ ] Null auth response emits failure

### Integration Tests
- [ ] End-to-end login flow works
- [ ] Token is stored after successful login
- [ ] Logout clears stored token
- [ ] Navigation stack is cleared on logout
- [ ] Error handling displays correct messages

---

## 🔧 Code Examples

### Dispatching Login Event

```dart
// In LoginForm widget
ElevatedButton(
  onPressed: () {
    context.read<AuthBloc>().add(
      LoginRequested(
        _username.text.trim(),
        _password.text.trim(),
      ),
    );
  },
  child: const Text('LOGIN'),
)
```

### Listening to State Changes

```dart
// In LoginPage
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthSuccess) {
      Navigator.pushReplacementNamed(
        context,
        RouteConstants.vehicle,
      );
    } else if (state is AuthFailure) {
      showErrorPopup(
        context,
        message: state.message,
      );
    }
  },
  child: const LoginForm(),
)
```

### Building UI Based on State

```dart
// In LoginForm
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    return LoginButton(
      loading: state is AuthLoading,
      onPressed: () {
        // Dispatch event
      },
    );
  },
)
```

---

## 📝 Summary

### Key Points

1. **Separation of Concerns**: UI (LoginPage/LoginForm) is separate from business logic (AuthBloc)

2. **Reactive UI**: UI automatically updates based on state changes via BlocBuilder and BlocListener

3. **Unidirectional Data Flow**: Events → BLoC → State → UI

4. **Error Handling**: Centralized in BLoC with clean error messages

5. **Navigation**: Handled by BlocListener to keep navigation logic out of BLoC

6. **Local State**: TextControllers and UI-only state (_obscure, _rememberMe) managed by StatefulWidget

7. **Global State**: Authentication state managed by BLoC, provided globally via MultiBlocProvider

### Design Decisions

✅ **Good**:
- Clear separation between UI and business logic
- Immutable states using Equatable
- Error message cleaning before display
- Navigation side effects in UI layer, not BLoC

⚠️ **Could Improve**:
- Add form validation before dispatching event
- Implement debouncing on login button to prevent double-tap
- Add loading state to individual form fields
- Implement auto-login with "Remember Me" functionality
