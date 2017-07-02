# Jake's TradeMe Task
TradeMe iOS Client for browsing categories and listings.

## Running
1. Clone this repository.
2. Open the Xcode project, hit build and run.

## Specification
- Allows the user to browse the Trade Me categories and displays the first 20 listings in each category.
  - [Category browsing UI located here](https://github.com/Jake00/TradeMeTask/tree/4122ff0c3b74d3f69f583f58198e9abdb6ea15b7/JakesTradeMe/View%20Controllers/Categories)
  - [Application specifies first 20 listings here](https://github.com/Jake00/TradeMeTask/blob/4122ff0c3b74d3f69f583f58198e9abdb6ea15b7/JakesTradeMe/Models/Search/SearchParameters.swift#L14)
  
- Consumes these API endpoints: 
  - Category browsing: https://api.tmsandbox.co.nz/v1/Categories/0.json 
  - Search: https://api.tmsandbox.co.nz/v1/Search/General.json
  - Listing details: https://api.tmsandbox.co.nz/v1/Listings/1234567890.json
  - [All 3 API Endpoints consumed here](https://github.com/Jake00/TradeMeTask/blob/4122ff0c3b74d3f69f583f58198e9abdb6ea15b7/JakesTradeMe/Services/APIClient/APIClient%2BEndpoints.swift)

- Supports both device and tablet 
  - ✔︎🙂
- Ideally the tablet version allows the user to drill through the categories and view listings at that level at the same time
  - [Enabled via UISplitViewController](https://github.com/Jake00/TradeMeTask/blob/4122ff0c3b74d3f69f583f58198e9abdb6ea15b7/JakesTradeMe/Application/AppDelegate.swift#L34)
