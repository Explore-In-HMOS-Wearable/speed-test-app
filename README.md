> **Note:** To access all shared projects, get information about environment setup, and view other guides, please visit [Explore-In-HMOS-Wearable Index](https://github.com/Explore-In-HMOS-Wearable/hmos-index).

# Internet Speed Test
This application provides users with accurate measurements of their internet connection performance through a clean and
intuitive interface.

# Preview
<div>
<img src="preview/ss.gif" width="25%" />
</div>

# Use Cases

- Real-time speed testing with progress visualization
- Download speed measurement
- Upload speed measurement
- Ping/latency testing (1-1000 ms)
- Automatic server selection optimization
- Clean and responsive Material Design UI
- Real-time result display with unit formatting

# Technology
## Stack
- **Languages**: ArkTS, ArkUI
- **Frameworks**: HarmonyOS SDK 5.0.2(14)
- **Tools**: DevEco Studio Vers 5.1.0.820
- **Libraries**:
- `@kit.NetworkKit` for network operations
- `@kit.ArkUI` for modern UI components
- `@kit.PerformanceAnalysisKit` for logging and analysis

## Required Permissions
- `ohos.permission.INTERNET`
- `ohos.permission.GET_NETWORK_INFO`

# Directory Structure

```
├── AppScope/
│   ├── app.json5                    # App configuration
│   └── resources/
│       └── base/
│           ├── element/
│           │   └── string.json      # App strings
│           └── media/               # App icons
├── entry/
│   ├── src/
│   │   ├── main/
│   │   │   ├── ets/
│   │   │   │   ├── entryability/   # App entry point
│   │   │   │   ├── interfaces/     # Type definitions
│   │   │   │   ├── pages/         # UI components
│   │   │   │   ├── service/       # Business logic
│   │   │   │   ├── utils/         # Helper functions
│   │   │   │   └── viewmodel/     # View models
│   │   │   └── resources/         # UI resources
│   │   ├── ohosTest/              # Integration tests
│   │   └── test/                  # Unit tests
│   └── build-profile.json5        # Build configuration
└── build-profile.json5            # Project configuration
```

# Constraints and Restrictions
## Supported Device
- Huawei watch 5

# LICENSE
**Internet Speed Test** is distributed under the terms of the MIT License.
See the [LICENSE](/LICENSE) for more information.