# Private VIP Shop override

The default private launcher profile enables `VIP_SHOP_UNLIMITED=1`. Override it with `VIP_SHOP_UNLIMITED=0 ./server/run_all.sh`. Effective enablement also requires the private local launcher or isolated test launcher, the payment sandbox, and `PAYMENT_PROVIDER=local`. Only MarketInfo type 4 uses the override. The checks for SKU, price, currency, VIP rank, inventory capacity and the per-order count remain enforced. Each committed transaction stores its charged amount in `vip_shop_purchases`; the normal weekly counter continues to track quantities.

The client requests `vipShopUnlimited` before rendering VIP products. The setting keeps the quantity picker available, hides the applicable stock and weekly limit labels, and leaves other shop interfaces untouched. The original checkout request 577 still opts out of automatic resend.

Waydroid QA character 834 used two BUY actions for SKU 310 (Master Ball), first 10 and then 1 against the configured weekly limit of 10. Both returned 563/code 0. PostgreSQL recorded 5,000 and 500 diamond deductions, balance 466,296 → 460,796, and stack 96 → 107. [Checkout evidence](../../artifacts/pet-economy-20261126/qa-vip-buy-beyond.png)
