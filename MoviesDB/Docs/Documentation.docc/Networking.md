# Networking

- `MoviesService` (in `MovieDBData`) provides:
  - `fetchPopular`, `fetchTopRated`, `fetchDetails`.
- HTTP requests go through `AppHttpKit.Client`.
- A `CachingClient` wraps the network client and uses:
  - `ResponseCache` (disk + memory).
  - `MovieDBCachePolicy` (TTL: list = 1h, details = 24h).

## Key Files
- `Dependencies/MovieDBData/Sources/MovieDBData/Service/MoviesService.swift`
- `Dependencies/MovieDBData/Sources/MovieDBData/Networking/CachingClient.swift`
- `Dependencies/MovieDBData/Sources/MovieDBData/Networking/ResponseCache.swift`
- `Dependencies/MovieDBData/Sources/MovieDBData/Networking/MovieDBCachePolicy.swift`
- `Dependencies/AppHttpKit/Sources/AppHttpKit/Client`
