# Extension Frontend

_All paths are relative to the `Shared (App)/Shared (Extension)/Resources` directory._

## Overview of files

- The `manifest.json` is essentially the extension's configuration file.

- The `popup.html`, `popup.css`, and `popup.js` files are for the native popover UI.

- The `background.js` file can run scripts at the "browser level", outside of any particular tab/window.

- The `content.js` file is the script injected onto the page when the extension is loaded (if it has permissions). It implements the `window.ethereum` object (EIP-1193 JavaScript API), which is exported from the `ethereum/` folder.

## Messaging

### Messaging between background, content, popup, and window.ethereum

Todo

### Messaging between Swift and Typescript

Typescript code can message the Swift extension from the background script. It does so through the Messenger's `sendNativeMessage` function, which is a wrapper around [browser.runtime.sendNativeMessage](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/runtime/sendNativeMessage).

Messaging between Swift and Typescript is governed by a fixed and typed interface. The basic object sent over the wire is of the form:

```js
{
  "method": string,
  "params": object
}
```

Typings need to be defined on both sides of the interface.

#### TypeScript

On the TypeScript side, messages are defined in `src/messaging/index.ts` and the `src/messaging/messages/*.ts` files.

`src/messaging/index.ts` stores some utility types, and the `NativeMessages` type, which maps method names (its keys) to a message object.

The `src/messaging/messages/*.ts` files store the individual message objects, which specify the shape of the message, most importantly its parameters:

```ts
export type EthGetBalanceMessage = {
    method: "eth_getBalance";
    params: {
        address: string;
        block?: string;
    };
}
```

It is then added to the `NativeMessages` object like so:

```ts
export type NativeMessages = {
    eth_getBalance: EthGetBalanceMessage;
```

This exposes the message to the Messenger interface, which gives you eg type checking:

```ts
const balance = await Messenger.sendToNative(
    'eth_getBalance',
    sessionId,
    {
        unknownProperty: "foo" // Error: Property 'unknownProperty' is missing in type 'EthGetBalanceMessage'
    }
);
```

The Messenger bus will handle serialisation, validation, error checking etc.

#### Swift

On the Swift side, messages are defined in `Messages.swift` and the `Messages/*.swift` files.

`Messages.swift` defines the `NativeMessage` and `NativeMessageMethod` types, and the `NativeMessageParams` protocol.

The `Messages/*.swift` files define the individual message params structs, which provide typing around each message's params:

```swift
struct helloFrenMessageParams: NativeMessageParams {
    let foo: String
    let bar: Int
    let wagmi: Bool?
    
    func execute(with userSettings: UserSettings) async throws -> Any {
        if let wagmi = self.wagmi {
            return wagmi ? "wagmi" : "ngmi"
        }
        return "ngmi"
    }
}
```

The message param structs also implement the `execute` method, which is called by the `SafariWebExtensionHandler#handle` method. `execute` is passed the user settings, and returns a promise that resolves to the result of the message.

This allows the message params struct to pass on control to other parts of the Swift extension or core library in a type-safe way:

```swift
struct SomeParamsObject: NativeMessageParams {
    func execute(with userSettings: UserSettings) async throws -> Any {
        doSomething(with: self)
    }
}

func doSomething(with params: SomeParamsObject) {
    // ...
}
```

Whatever is resolved from the `execute` method is returned as a JSON response, wrapped in a `message` key.

`NativeMessageParams` adheres to the `Decodable` protocol, which allows you to customise the decoding behaviour:

```swift
struct MessageWithDefaultParameterMessageParams: NativeMessageParams {
    let foo: String

    private enum CodingKeys: CodingKey {
        case foo
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let foo = try container.decode(String.self, forKey: .address) {
            self.foo = foo
        } else {
            self.foo = "default"
        }
    }
}
```