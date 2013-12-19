# Cross Selling

Allows markets to agree to list/sell other market's products

## How does a market set this up?

...

## Levels of cross selling

Chosen both at the market and seller level

* All in (all products and all deliveries)
* Opt out (all products and all deliveries but sellers can choose not to participate)
  * Could be global defaults for new sellers and products
* Opt in (no products or deliveries but sellers can choose to participate)

Market can choose to lock out delivery times

### Implementation thoughts

Each level only stores changes relative to the parent. So default setting is "same as parent", but any level can override the parent setting with an expicit yes or no.

Chain being Market -> Seller -> Product -> Delivery

Full chain being per cross sell market

## Additional delivery charges

Probably by market

How will these get applied?
Who will pay them?
