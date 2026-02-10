# AppHttpKit

A lightweight Swift HTTP client designed to simplify API requests with an easy-to-use interface and async/await support.

## Features

- Supports common HTTP methods: `GET`, `POST`, `PUT`, `PATCH`, and `DELETE`
- Customizable request headers and query parameters
- Supports multiple body encoders (JSON, URL, Multipart, Data)
- Built-in response handling

## Usage

### Creating an HttpClient instance

```swift
let client = HttpClient(baseURL: "https://api.example.com")
```

### Making requests

#### GET request

```swift
struct UserQuery: QueryParametersConvertible {
    @QueryParameter(123, "id") var id: Int
}

let responseData = try await client.get("/users", queryParams: UserQuery())
```

#### POST request

```swift
let responseData = try await client.post("/users", bodyParams: AnyEncodable(["name": "John Doe"]))
```

#### PUT request

```swift
let responseData = try await client.put("/users/1", bodyParams: AnyEncodable(["name": "Jane Doe"]))
```

#### PATCH request

```swift
let responseData = try await client.patch("/users/1", bodyParams: AnyEncodable(["email": "jane@example.com"]))
```

#### DELETE request

```swift
let responseData = try await client.delete("/users/1")
```

### Handling responses

```swift
let request = Request(method: .get, url: "/users/1")
let response = try await client.request(request)
if response.isSuccessful {
    print("Success: \(response.body)")
} else {
    print("Failed with code: \(response.code)")
}
```

## Error Handling

The `HttpClient` can throw the following errors:

- `ClientError.timeout`: When a request exceeds the timeout interval
- `ClientError.network(response:error:)`: For network-related issues
- `ClientError.encoderNotFound`: When an appropriate encoder is not available
