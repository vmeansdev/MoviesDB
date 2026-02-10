# PlistReader

PlistReader is a Swift utility designed to simplify reading values from a property list (plist) file within an iOS/macOS project. It provides a type-safe way to retrieve values from the `Info.plist` file bundled with the app.

## Features

- Retrieve values from a plist file with type safety.
- Supports `LosslessStringConvertible` types for automatic string-to-type conversion.
- Comprehensive error handling for missing keys and invalid values.

## Usage

### Initialization

```swift
let plistReader = PlistReader(bundle: .main)
```

### Retrieving Values

```swift
let apiKey: String = try plistReader.value(for: "API_KEY")
let portNumber: Int = try plistReader.value(for: "PORT_NUMBER")
```

### Error Handling

The following errors are handled by `PlistReader`:

- `PlistReader.Error.missingKey`: Thrown when the requested key does not exist.
- `PlistReader.Error.invalidValue`: Thrown when the value cannot be converted to the expected type.

Example:

```swift
do {
    let value: String = try plistReader.value(for: "InvalidKey")
} catch PlistReader.Error.missingKey {
    print("Key not found.")
} catch PlistReader.Error.invalidValue {
    print("Invalid value type.")
}
```

## Testing

The project includes unit tests to ensure correct functionality:

- **`test_valueForKey_whenKeyExists_returnsValue`**: Verifies that an existing key returns the correct value.
- **`test_valueForKey_whenKeyIsMissing_throws`**: Ensures an error is thrown when a key is missing.
- **`test_valueForKey_whenValueIsWrongType_throws`**: Ensures an error is thrown when the value type is incorrect.
- **`test_valueForKey_withConvertibleString_returnsConvertedValue`**: Validates conversion from string to the expected type.

The test coverage is sufficient, covering:

- Happy path for valid keys and values.
- Error cases for missing keys and incorrect types.
- Type conversion scenarios.

