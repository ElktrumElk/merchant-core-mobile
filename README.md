# Merchant Core

A Flutter business management app covering point-of-sale, stock management, credit ledger, sales analytics, and authentication.

---

## Architecture Overview

```
lib/
├── main.dart                        # App entry, theme init, splash↔main shell switch
├── global/                          # State managers, themes, notifiers
│   ├── app_theme.dart               # Light & dark ThemeData definitions
│   ├── theme_notifier.dart          # Dark mode toggle + persistence
│   ├── auth_global.dart             # Login state checker (DeviceStorage)
│   ├── credit_global.dart           # CreditUser model + CreditStore (ChangeNotifier)
│   ├── sales_global.dart            # OrderRecord model + OrderStore (ChangeNotifier)
│   ├── stock/stock_global.dart      # StockGlobal static helpers
│   └── valueNotifiers/...           # GlobalValueNotifiers (notification/backup toggles)
├── module/
│   ├── storage/device_storage.dart  # FlutterSecureStorage wrapper
│   └── chart/chart.dart             # RevenueLineChart (fl_chart)
├── network/
│   ├── authentication/...           # SecreteData, TokenStorage, UserService (login/signup/verify)
│   └── logout/logout.dart           # Logout stub
├── pages/
│   ├── splash/splash_screen.dart    # Onboarding, auto-login check, auth gate
│   ├── homepage/home_page.dart      # Dashboard tab
│   ├── authentication/login/        # AuthBottomSheet, LoginForm, SignupForm
│   ├── stockpage/                   # StockPage (CRUD) + StockStatistics
│   ├── pos/                         # PosPage, CardItems, CartPanel, CategoriesButton
│   └── creditPage/credit_ledger.dart# Credit ledger tab
└── components/                      # Reusable widgets
    ├── greetingCard/
    ├── pageTitle/
    ├── revenueTrend/
    ├── settings/ (user.dart, userDetails.dart, settings.dart, toggle_card.dart)
    ├── statistics/ (statistics.dart, home_statistics.dart)
    └── subcards/
```

---

## Important Class Definitions

### Entry & Shell

| Class | File | Extends | Purpose |
|-------|------|---------|---------|
| `MyApp` | `main.dart:20` | `StatelessWidget` | Root widget. Wraps `MaterialApp` in a `ValueListenableBuilder<ThemeMode>`. Switches between `SplashScreen` and `MainLayoutShell` via `isSplashScreen` notifier. |
| `MainLayoutShell` | `main.dart:48` | `StatefulWidget` | Bottom navigation shell. Hosts 6 tabs: Dashboard, Stock, POS, Credit, Calc, More. |
| `_MainLayoutShellState` | `main.dart:55` | `State` | Manages `_currentIndex` for tab switching. Builds `Scaffold` with `AppBar` + `BottomNavigationBar`. |

### State Managers (Global Notifiers)

| Class | File | Extends | Purpose |
|-------|------|---------|---------|
| `ThemeNotifier` | `theme_notifier.dart:4` | `ValueNotifier<ThemeMode>` | Persists dark mode preference via `DeviceStorage` under key `colorMode`. Call `init()` before `runApp()`. Use `toggle()` to flip. |
| `OrderStore` | `sales_global.dart:20` | `ChangeNotifier` | Singleton sales order store. `addOrder()` records a sale. `revenueByMonth()` aggregates revenue for charting. |
| `CreditStore` | `credit_global.dart:32` | `ChangeNotifier` | Singleton credit ledger. `addCreditUser()`, `markAsPaid()`, `deleteUser()`. Exposes `users`, `totalOutstanding`, `overdueCount`, `collected`. |
| `AddItemsToCart` | `cart_panel.dart:6` | `ChangeNotifier` | Singleton cart manager. `addProduct()`, `removeProduct()`, `clearCart()`. Tracks `items`, `totalItemCount`, `totalPrice`. |

**Usage:**
```dart
// Listen to any ChangeNotifier/ValueNotifier:
ListenableBuilder(
  listenable: Listenable.merge([OrderStore(), CreditStore()]),
  builder: (context, _) { /* rebuild when either store changes */ },
);

// Or individually:
ValueListenableBuilder<ThemeMode>(
  valueListenable: themeNotifier,
  builder: (context, mode, _) { /* react to theme changes */ },
);
```

### Network & Auth

| Class | File | Purpose |
|-------|------|---------|
| `SecreteData` | `user_authentication.dart:9` | API config: base URL + endpoint constants. `getHeaders()` attaches Bearer token. |
| `TokenStorage` | `user_authentication.dart:35` | Static utility wrapping `FlutterSecureStorage` for JWT (`secure_access_token`). |
| `UserService` | `user_authentication.dart:60` | API service: `login()`, `signUp()`, `verifyEmail()`, `getUserInfo()`. |
| `DeviceStorage` | `device_storage.dart:3` | Generic `FlutterSecureStorage` wrapper. Use `setKey(key)` then `saveValue()`/`loadValue()`. |

**Authentication flow:**
```
App start → main()
  ├── themeNotifier.init() (load dark mode)
  └── runApp(MyApp)
        └── isSplashScreen.value == true → SplashScreen
              ├── initState() → _autoRouteIfLoggedIn()
              │   ├── isLogin == true  → fetchUserDetails() → isSplashScreen = false → MainLayoutShell
              │   └── isLogin != true  → show "Get Started" button
              │
              └── "Get Started" → _openAuth()
                    └── AuthBottomSheet.show(context)
                          ├── Login tab  → LoginForm._submit()
                          │   ├── UserService().login(email, pass)
                          │   │   └── POST /api/v1/auth/login → save token
                          │   ├── DeviceStorage: set isLogin=true
                          │   └── widget.onSuccess() → Navigator.pop(context, true)
                          │
                          └── Sign Up tab → SignupForm._submit()
                              └── (validates only, no API call yet)
```

### Data Models

| Model | File | Properties |
|-------|------|------------|
| `Product` | `stock_page.dart:33` | `id`, `name`, `price`, `quantity`, `inStock` |
| `CartItem` | `cart_panel.dart:66` | `Product product`, `int quantity` |
| `CreditUser` | `credit_global.dart:6` | `id`, `name`, `amount`, `dueDate`, `CreditStatus status` |
| `OrderRecord` | `sales_global.dart:4` | `id`, `items`, `total`, `date`, `label` |
| `AuthUser` | `user.dart:8` | Static fields: `username`, `userEmail`, `userFullName`, `isEmailVerify`, `createdAt`, `updatedAt` |

### Page Widgets

| Widget | File | Tab | Purpose |
|--------|------|-----|---------|
| `SplashScreen` | `splash_screen.dart:9` | — | Onboarding gate with auto-login check |
| `MyHomePage` | `home_page.dart:12` | 0 (Dashboard) | Greeting, stats, revenue chart, recent transactions, alerts |
| `StockPage` | `stock_page.dart:50` | 1 (Stock) | Full product CRUD with search/filter |
| `PosPage` | `pos_page.dart:8` | 2 (POS) | Product grid + cart panel + checkout |
| `CreditLedger` | `credit_ledger.dart:7` | 3 (Credit) | Credit user list with status management |

### Reusable Components

| Widget | File | Purpose |
|--------|------|---------|
| `Statistics` | `statistics.dart:3` | Dual-mode stat card (hero/standard) |
| `GreetingCard` | `greeting_card.dart:3` | Dark gradient page header |
| `PageTitle` | `pageTitle.dart:3` | AppBar title with icon |
| `SubCards` | `sub_cards.dart:3` | Generic titled card wrapper |
| `ToggleCard` | `toggle_card.dart:4` | Settings row with on/off toggle |
| `UserDetails` | `userDetails.dart:4` | Profile avatar + username + email |
| `RevenueLineChart` | `chart.dart:5` | 6-month revenue line chart |

---

## State Management

The app uses **only Flutter SDK primitives** (no Provider/Riverpod/Bloc):

| Pattern | Where |
|---------|-------|
| `ValueNotifier` | Theme, splash gate, cart toggle, notification/backup toggles |
| `ChangeNotifier` | OrderStore, CreditStore, AddItemsToCart |
| Static fields | AuthUser, StockGlobal, GlobalItems |
| `setState()` | Tab index, stock filters, forms |

**Listen with:**
- `ValueListenableBuilder` for single `ValueNotifier`
- `ListenableBuilder` for `ChangeNotifier` or merged `Listenable`

---

## Storage

All persistent data uses `FlutterSecureStorage`:

| Key | Type | Usage |
|-----|------|-------|
| `secure_access_token` | String | JWT (via `TokenStorage`) |
| `colorMode` | `"true"` / `"false"` | Dark mode preference |
| `isLogin` | `"true"` / `"false"` | Login state flag |
| `user_info` | JSON string | Cached user profile |
| `user_product` | JSON string | Cached user products that has been added | 

---

## Dependencies

| Package | Version | Use |
|---------|---------|-----|
| `fl_chart` | ^1.2.0 | Dashboard revenue line chart |
| `flutter_staggered_grid_view` | ^0.7.0 | Credit page stat layout |
| `http` | ^1.6.0 | REST API calls |
| `flutter_secure_storage` | ^10.3.1 | Encrypted device storage |

---

## Known Gaps

- **Signup form** validates but does not call the API yet
- **Logout** is syntactically broken (`logout.dart`)
- **No IndexedStack** — switching tabs destroys the widget tree
- **`signals_flutter` and `path_provider`** are declared in pubspec but unused
