# Daniel Clean UI Billing System For Business

---

### Description

The **Daniel Clean UI Billing System** is a powerful and user-friendly billing solution for businesses in FiveM. This script allows jobs (e.g., bankers, shopkeepers) to bill other players for services or products, with an integrated anti-exploit system to ensure safe and reliable billing. The system includes a clean, customizable UI that works seamlessly with various frameworks such as QBCore and ESX.

---

### Features

- **Billing System**: Enables businesses to bill other players.
- **Anti-Exploit System**: Built-in protection against potential exploits.
- **Customizable UI**: Clean, modern design with fully configurable UI elements.
- **Framework Support**: Compatible with both QBCore and ESX frameworks.
- **Target System**: Works with various target systems such as `qb-target` and `ox_target`.
- **Notify System**: Built-in notification support for various notify systems like `qb-core`, `ox_lib`, and `esx`.
- **Business Locations**: Configurable business locations where the billing interaction can occur.
- **Debugging and Developer Options**: Options for debugging and testing the script.

---

### Installation

1. **Add to Your Server**:  
   Download the resource and place it in your `resources` folder.

2. **Add to `server.cfg`**:  
   Add the following line to your `server.cfg` to start the resource:
ensure Daniel-Billing

3. **Configure the Script**:  
Open `Shared/Config.lua` and modify the configuration to suit your server setup.

---

### Configuration

The script is highly customizable via the `Config.lua` file. Here's an overview of the key settings:

#### Framework Configuration

- **`FrameworkType`**: Choose between `QB` (QBCore) or `ESX` based on the framework you are using.
- **`esxLegacy`**: Set to `true` if you are using the older version of ESX.
- **`Core`**: Set to `QBCore` if using QBCore; modify only if using a custom version of QBCore.
- **`Framework`**: The name of the core framework (`qb-core` for QBCore).

#### Debugging Configuration

- **`Debug`**: Toggle to enable/disable debugging messages.
- **`DevMode`**: Enable to send UI commands for testing.

#### System Configuration

- **`TargetSystem`**: Choose between `"qb-target"`, `"ox_target"`, or `"drawtext"` for your interaction system.
- **`Notify`**: Choose your notification system: `qb-core`, `ox_lib`, or `esx`.

#### Exploit Protection

- **`AntiExploit`**: Enable this feature to prevent exploitations in the billing process.

#### Business Locations

Define business locations where players can interact with the billing system. Each business can have unique settings:

- **`coords`**: The location coordinates for the business.
- **`jobs`**: List of job names allowed to interact with the billing system at this location.
- **`interaction`**: Label for the key to trigger the billing interaction.
- **`UseBossMenu`**: Toggle to use a boss menu for business owners.
- **`Distance`**: Interaction distance, change if using `drawtext`.

Example:

```lua
Business = {
 ["bank"] = {
     coords = vector3(-1024.184, -2733.377, 13.757),
     jobs = {"banker"},
     interaction = "[E] - To Access Bank Billing",
     UseBossMenu = false,
     Distance = 2,
 },
 ["store"] = {
     coords = vector3(374.0, -833.0, 29.0),
     jobs = {"shopkeeper"},
     interaction = "access_store",
     UseBossMenu = false,
     Distance = 2,
 }
}
```

#### Previews

Billing Section:
<img src="https://i.imgur.com/7rKZj5s.png">

Paying Section ( Opening This UI To Billed Player ):
<img src="https://i.imgur.com/SLs7Et4.png">
