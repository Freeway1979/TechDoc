# Firewalla MSP Web Packages

```json
{
  "gid": "xxx",
  "operation": "appPaired" // "appUnPaired" or "appRevoked",
  "appId": "xxxx", // eid
  "ts": 23333
}
```
### package.json

```json
    "start": "cross-env NODE_OPTIONS=--openssl-legacy-provider MODE=non_msp THEME=light PROXY_SERVER=https://my.firewalla.com PROXY_PATH=/dev/ umi dev",
    "start:msp": "cross-env NODE_OPTIONS=--openssl-legacy-provider MODE=msp THEME=dark PROXY_SERVER=https://qici-dev2.dd.firewalla.net umi dev",
    "start:support": "cross-env NODE_OPTIONS=--openssl-legacy-provider MODE=msp SUPPORT=true THEME=dark PROXY_SERVER=https://support-test.dd.firewalla.net umi dev",
    "build": "cross-env NODE_OPTIONS=--openssl-legacy-provider MODE=non_msp THEME=light umi build",
    "build:msp": "cross-env NODE_OPTIONS=--openssl-legacy-provider MODE=msp THEME=dark umi build",
    "build:support": "cross-env NODE_OPTIONS=--openssl-legacy-provider MODE=msp SUPPORT=true THEME=dark umi build",
    "test": "cross-env NODE_OPTIONS=--openssl-legacy-provider umi test",

```

## Dependencies (Runtime packages)

### Core framework and UI
- `antd` (^3.15.0) — Ant Design UI library
  - Usage: Buttons, Forms, Tables, Modals, etc.
  - Example: `<Button>`, `<Form>`, `<Table>`, `<Modal>`

- `react-router-dom` (5.1.2) — React routing
  - Usage: Client-side routing
  - Example: `<Route>`, `<Link>`, `useHistory()`, `useLocation()`

- `react-intl` (5.24.4) — Internationalization
  - Usage: i18n with `formatMessage()`, `<FormattedMessage>`

### State management
- `mobx` (^5.8.0) — Reactive state management
  - Usage: `@observable`, `@action`, `@computed` for stores

- `mobx-react` (^6.0.0) — React bindings for MobX
  - Usage: `observer()` HOC to make components reactive

### Data fetching and HTTP
- `axios` (^1.4.0) — HTTP client
  - Usage: API requests with interceptors

- `@tanstack/react-query` (^4.29.5) — Data fetching and caching
  - Usage: `useQuery`, `QueryClientProvider` for server state

- `@aws-sdk/client-cognito-identity-provider` (^3.154.0) — AWS Cognito
  - Usage: Authentication, token refresh

### Real-time communication
- `socket.io-client` (^2.3.0) — WebSocket client
  - Usage: Real-time updates (box status, events)

### Data visualization
- `echarts` (^5.6.0) — Charting library
  - Usage: Charts and graphs

- `echarts-for-react` (^3.0.2) — React wrapper for ECharts
  - Usage: `<ReactECharts>` components

- `react-sparklines` (^1.7.0) — Sparkline charts
  - Usage: Small inline charts

- `react-simple-maps` (^3.0.0) — Map visualizations
  - Usage: World/region maps

- `react-circular-progressbar` (^2.0.4) — Circular progress bars
  - Usage: Progress indicators

### Date and time
- `dayjs` (^1.11.13) — Date manipulation
  - Usage: Date formatting, parsing, timezone handling

- `moment` (2.9.0) — Legacy date library (likely being phased out)
  - Usage: Date operations (migrating to dayjs)

- `javascript-time-ago` (^2.3.4) — Relative time formatting
  - Usage: "2 hours ago", "3 days ago"

- `cron-parser` (^2.15.0) — Cron expression parsing
  - Usage: Parsing cron schedules

- `timezone-enum` (^1.0.3) — Timezone constants
  - Usage: Timezone selection/enumeration

### Utilities
- `lodash-es` (^4.17.11) — Utility functions
  - Usage: `cloneDeep`, `isEqual`, `debounce`, etc.

- `classnames` (^2.2.6) — Conditional CSS classes
  - Usage: `classNames('foo', { bar: true })`

- `uuid` (^8.3.2) — UUID generation
  - Usage: Unique IDs

- `filesize` (^10.0.6) — File size formatting
  - Usage: "1.5 MB", "500 KB"

- `deep-object-diff` (^1.1.9) — Object diffing
  - Usage: Comparing object changes

### Network utilities
- `is-ip` (^4.0.0) — IP address validation
  - Usage: `isIp('192.168.1.1')`

- `is-cidr` (^5.0.2) — CIDR validation
  - Usage: `isCidr('192.168.1.0/24')`

- `private-ip` (^2.3.4) — Private IP detection
  - Usage: Checking if IP is private

- `subnet-overlap` (^1.0.0) — Subnet overlap detection
  - Usage: Network configuration validation

- `tldjs` (^2.3.1) — TLD extraction
  - Usage: Extracting domain/TLD from URLs

### Country/region
- `country-list` (^2.3.0) — Country data
  - Usage: Country lists and codes

- `i18n-iso-countries` (^7.13.0) — Country names in multiple languages
  - Usage: Localized country names

- `react-country-flag` (^3.1.0) — Country flag components
  - Usage: `<ReactCountryFlag />`

### Data export/import
- `json2csv` (^4.5.4) — JSON to CSV conversion
  - Usage: Exporting data as CSV

- `jszip` (^3.2.2) — ZIP file creation
  - Usage: Creating ZIP archives for exports

### UI components and effects
- `react-loading-skeleton` (^3.0.1) — Skeleton loaders
  - Usage: `<Skeleton />` for loading states

- `react-highlight-words` (^0.20.0) — Text highlighting
  - Usage: Highlighting search terms

- `react-window` (^1.8.6) — Virtualized lists
  - Usage: Rendering large lists efficiently

- `react-window-infinite-loader` (^1.0.7) — Infinite scrolling
  - Usage: Infinite scroll with react-window

- `react-full-screen` (^1.1.1) — Fullscreen API
  - Usage: Fullscreen mode

- `react-markdown` (^6.0.3) — Markdown rendering
  - Usage: Rendering markdown content

- `qrcode.react` (^0.9.2) — QR code generation
  - Usage: `<QRCodeSVG />` components

- `react-jason` (^1.1.2) — JSON viewer
  - Usage: Pretty JSON display

- `@ramonak/react-progress-bar` (^5.0.3) — Progress bars
  - Usage: Progress indicators

- `@uiball/loaders` (^1.2.6) — Loading animations
  - Usage: Various loading spinners

- `react-error-boundary` (^3.1.4) — Error boundaries
  - Usage: `<ErrorBoundary>` for error handling

- `react-use` (^17.4.0) — React hooks collection
  - Usage: `useWindowSize`, `useAsync`, etc.

- `@emotion/react` (^11.4.1) — CSS-in-JS
  - Usage: Styled components (likely used by other libraries)

### Validation
- `yup` (^0.32.11) — Schema validation
  - Usage: Form validation schemas

### Other
- `ansi_up` (^5.1.0) — ANSI color code rendering
  - Usage: Rendering terminal output with colors

---

## DevDependencies (Development tools)

### TypeScript types
- `@types/*` — TypeScript type definitions
  - Usage: Type safety for JavaScript libraries
  - Examples: `@types/react-dom`, `@types/lodash-es`, `@types/jest`

### Build and bundling
- `umi` (^2.13.18) — React framework
  - Usage: Build tool, routing, code splitting, dev server

- `umi-plugin-react` (^1.5.2) — UmiJS React plugin
  - Usage: React support in UmiJS

- `svg-sprite-loader` (^4.1.3) — SVG sprite loader
  - Usage: Bundling SVGs as sprites

- `svgo-loader` (^2.2.0) — SVG optimization
  - Usage: Optimizing SVG files during build

### Code quality
- `eslint` (^5.4.0) — JavaScript linter
  - Usage: Code linting

- `eslint-config-umi` (^0.1.5) — UmiJS ESLint config
  - Usage: ESLint configuration for UmiJS

- `eslint-plugin-*` — ESLint plugins
  - Usage: Additional linting rules
  - Examples: `eslint-plugin-react`, `eslint-plugin-import`

- `babel-eslint` (^9.0.0) — Babel parser for ESLint
  - Usage: Parsing modern JavaScript/TypeScript

### Git hooks
- `husky` (^0.14.3) — Git hooks
  - Usage: Running scripts on git events

- `lint-staged` (^7.2.2) — Lint staged files
  - Usage: Linting only changed files in pre-commit

### Testing
- `@types/jest` (^27.4.1) — Jest type definitions
  - Usage: TypeScript types for Jest

### Build utilities
- `cross-env` (^5.2.0) — Cross-platform environment variables
  - Usage: Setting env vars in npm scripts across platforms

- `babel-plugin-macros` (^3.1.0) — Babel macros
  - Usage: Compile-time code transformations

- `require-context.macro` (^1.2.2) — Require context macro
  - Usage: Dynamic imports with webpack context

---

## Summary

This is a React + TypeScript application using:
- UmiJS for build/routing
- Ant Design for UI
- MobX for state management
- Axios for HTTP
- ECharts for visualization
- Socket.io for real-time updates
- React Router for routing
- Various utilities for networking, dates, and data processing

The architecture supports a network management dashboard with real-time monitoring, data visualization, and internationalization.