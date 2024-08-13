## Bonding Curve

利用bonding curve为任意两种代币创建流动性池

- 添加流动性
- 移除流动性
- 购买代币
- 出售代币

## Test

### create liquidity pool

```bash
rooch move run --function 0x6c46da13ab83ed202be3b91512d7f08be9093c452083cd86c443d40fb635017f::liquidity_pool_test::test_create_pool --args "String:testatokenaa" --args "Str
ing:testbtokenbb" --args "String:tataa" --args "String:tbtbb"
```

![create](.\public\imgs\create.png)

```json
{
  "sequence_info": {
        {
          "metadata": {
            "id": "0x2780843d52a16e30e406acde616be0d7c9809bef1c658875b85a4fa3c0549fa2", // 流动性池 object id
            "owner": "rooch1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqhxqaen",
            "owner_bitcoin_address": null,
            "flag": 1,
            "state_root": "0x5350415253455f4d45524b4c455f504c414345484f4c4445525f484153480000",
            "size": "0",
            "created_at": "1723543360483",
            "updated_at": "1723543360483",
            "object_type": "0x6c46da13ab83ed202be3b91512d7f08be9093c452083cd86c443d40fb635017f::liquidity_pool::LiquidityPool<0x6c46da13ab83ed202be3b91512d7f08be9093c452083cd86c443d40fb635017f::liquidity_pool_test::FSCA, 0x6c46da13ab83ed202be3b91512d7f08be9093c452083cd86c443d40fb635017f::liquidity_pool_test::FSCB>"
          },
}
```

### add liquidity 

```bash
rooch move run --function 0x6c46da13ab83ed202be3b91512d7f08be9093c452083cd86c443d40fb635017f::liquidity_pool_test::test_add_liquidity --args object_id:0x2780843d52a16e30e406acde616be0d7c9809bef1c658875b85a4fa3c0549fa2
```

![add_liquidity](.\public\imgs\add_liquidity.png)

```bash
rooch move view --function 0x6c46da13ab83ed202be3b91512d7f08be9093c452083cd86c443d40fb635017f::liquidity_pool_test::query_pool_details --args object_id:0x2780843d52a16e30e4
06acde616be0d7c9809bef1c658875b85a4fa3c0549fa2
```

```json
{
  "vm_status": "Executed",
  "return_values": [
    {
      "value": {
        "type_tag": "u256",
        "value": "0xd007000000000000000000000000000000000000000000000000000000000000"
      },
      "decoded_value": "2000"	//	total_supply: 流动性池的总供应量
    },
    {
      "value": {
        "type_tag": "u256",
        "value": "0xe803000000000000000000000000000000000000000000000000000000000000"
      },
      "decoded_value": "1000"	//	reserve_token_a：token a 的储备量
    },
    {
      "value": {
        "type_tag": "u256",
        "value": "0xe803000000000000000000000000000000000000000000000000000000000000"
      },
      "decoded_value": "1000"	//	reserve_token_b：token b 的储备量
    },
    {
      "value": {
        "type_tag": "address",
        "value": "0x6c46da13ab83ed202be3b91512d7f08be9093c452083cd86c443d40fb635017f"
      },
      "decoded_value": "0x6c46da13ab83ed202be3b91512d7f08be9093c452083cd86c443d40fb635017f"
    },
    {
      "value": {
        "type_tag": "u8",
        "value": "0x01"
      },
      "decoded_value": 1 // swap 费率(整数)
    },
    {
      "value": {
        "type_tag": "u64",
        "value": "0x402fbb6600000000"
      },
      "decoded_value": "1723543360" // 池子创建时间
    }
  ]
}
```

### buy token a

```bash
rooch move run --function 0x6c46da13ab83ed202be3b91512d7f08be9093c452083cd86c443d40fb635017f::liquidity_pool_test::test_buy_token_a --args object_id:0x2780843d52a16e30e406a
cde616be0d7c9809bef1c658875b85a4fa3c0549fa2
```

![buy_token_a](.\public\imgs\buy_token_a.png)

```bash
rooch move view --function 0x6c46da13ab83ed202be3b91512d7f08be9093c452083cd86c443d40fb635017f::liquidity_pool_test::query_pool_details --args object_id:0x2780843d52a16e30e4
06acde616be0d7c9809bef1c658875b85a4fa3c0549fa2
```

![query_buy_token_a](.\public\imgs\query_buy_token_a.png)

```json
{
  "vm_status": "Executed",
  "return_values": [
    {
      "value": {
        "type_tag": "u256",
        "value": "0xd007000000000000000000000000000000000000000000000000000000000000"
      },
      "decoded_value": "2000"
    },
    {
      "value": {
        "type_tag": "u256",
        "value": "0xe703000000000000000000000000000000000000000000000000000000000000"
      },
      "decoded_value": "999"
    },
    {
      "value": {
        "type_tag": "u256",
        "value": "0x4c04000000000000000000000000000000000000000000000000000000000000"
      },
      "decoded_value": "1100"
    },
    {
      "value": {
        "type_tag": "address",
        "value": "0x6c46da13ab83ed202be3b91512d7f08be9093c452083cd86c443d40fb635017f"
      },
      "decoded_value": "0x6c46da13ab83ed202be3b91512d7f08be9093c452083cd86c443d40fb635017f"
    },
    {
      "value": {
        "type_tag": "u8",
        "value": "0x01"
      },
      "decoded_value": 1
    },
    {
      "value": {
        "type_tag": "u64",
        "value": "0x3032bb6600000000"
      },
      "decoded_value": "1723544112"
    }
  ]
}
```

用户用 100 个 `Token B` 购买到 1 个 `Token A` 代币。

```rust
public fun get_output_amount(input_amount: u256, input_reserve: u256, output_reserve: u256, fee_rate: u8): u256 {
    // 计算扣除手续费后的 token a 数量
    let input_amount_with_fee = input_amount * (100u256 - (fee_rate as u256)) / 100u256;	// 99
    // 扣除手续费后的 token a 数量 * 池子里 token b 的储备量
    let numerator = input_amount_with_fee * output_reserve;	//	99 * 1000 = 99000
    // 池子中 token a 储备量 乘以 100(调整比例) + 计算扣除手续费后的 token a 数量
    let denominator = (input_reserve * 100u256) + input_amount_with_fee;	// 1000 * 100 + 99 =100099
    u256::divide_and_round_up(numerator, denominator)	//	分子除以分母的结果向上取整
}
```


$$
\text{output\_amount} = \left\lceil \frac{\text{input\_amount} \times \frac{100 - \text{fee\_rate}}{100} \times \text{output\_reserve}}{(\text{input\_reserve} \times 100) + \text{input\_amount} \times \frac{100 - \text{fee\_rate}}{100}} \right\rceil
$$

$$
\text{output\_amount} = \left\lceil \frac{100 \times \frac{100 - 1}{100} \times 1000}{(1000 \times 100) + 100 \times \frac{100 - 1}{100}} \right\rceil = \left\lceil \frac{100 \times 99 \times 1000}{100000 + 99} \right\rceil = \left\lceil \frac{99000}{100099} \right\rceil = 1
$$



### sell token a

```bash
rooch move run --function 0x6c46da13ab83ed202be3b91512d7f08be9093c452083cd86c443d40fb635017f::liquidity_pool_test::test_sell_token_a --args object_id:0x2780843d52a16e30e406
acde616be0d7c9809bef1c658875b85a4fa3c0549fa2
```

![sell_token_a](.\public\imgs\sell_token_a.png)

```bash
rooch move view --function 0x6c46da13ab83ed202be3b91512d7f08be9093c452083cd86c443d40fb635017f::liquidity_pool_test::query_pool_details --args object_id:0x2780843d52a16e30e4
06acde616be0d7c9809bef1c658875b85a4fa3c0549fa2
```

![query_sell_token_a](.\public\imgs\query_sell_token_a.png)

```json
{
  "vm_status": "Executed",
  "return_values": [
    {
      "value": {
        "type_tag": "u256",
        "value": "0xd007000000000000000000000000000000000000000000000000000000000000"
      },
      "decoded_value": "2000"
    },
    {
      "value": {
        "type_tag": "u256",
        "value": "0x4b04000000000000000000000000000000000000000000000000000000000000"
      },
      "decoded_value": "1099"
    },
    {
      "value": {
        "type_tag": "u256",
        "value": "0x4b04000000000000000000000000000000000000000000000000000000000000"
      },
      "decoded_value": "1099"
    },
    {
      "value": {
        "type_tag": "address",
        "value": "0x6c46da13ab83ed202be3b91512d7f08be9093c452083cd86c443d40fb635017f"
      },
      "decoded_value": "0x6c46da13ab83ed202be3b91512d7f08be9093c452083cd86c443d40fb635017f"
    },
    {
      "value": {
        "type_tag": "u8",
        "value": "0x01"
      },
      "decoded_value": 1
    },
    {
      "value": {
        "type_tag": "u64",
        "value": "0x5437bb6600000000"
      },
      "decoded_value": "1723545428"
    }
  ]
}
```

### remote liquidity

```bash
rooch move run --function 0x6c46da13ab83ed202be3b91512d7f08be9093c452083cd86c443d40fb635017f::liquidity_pool_test::test_remove_liquidity --args object_id:0x2780843d52a16e30
e406acde616be0d7c9809bef1c658875b85a4fa3c0549fa2
```

![remote_liquidity](.\public\imgs\remote_liquidity.png)

```
rooch move view --function 0x6c46da13ab83ed202be3b91512d7f08be9093c452083cd86c443d40fb635017f::liquidity_pool_test::query_pool_details --args object_id:0x2780843d52a16e30e4
06acde616be0d7c9809bef1c658875b85a4fa3c0549fa2
```

```json
{
  "vm_status": "Executed",
  "return_values": [
    {
      "value": {
        "type_tag": "u256",
        "value": "0xdc05000000000000000000000000000000000000000000000000000000000000"
      },
      "decoded_value": "1500"
    },
    {
      "value": {
        "type_tag": "u256",
        "value": "0x3903000000000000000000000000000000000000000000000000000000000000"
      },
      "decoded_value": "825"
    },
    {
      "value": {
        "type_tag": "u256",
        "value": "0x3903000000000000000000000000000000000000000000000000000000000000"
      },
      "decoded_value": "825"
    },
    {
      "value": {
        "type_tag": "address",
        "value": "0x6c46da13ab83ed202be3b91512d7f08be9093c452083cd86c443d40fb635017f"
      },
      "decoded_value": "0x6c46da13ab83ed202be3b91512d7f08be9093c452083cd86c443d40fb635017f"
    },
    {
      "value": {
        "type_tag": "u8",
        "value": "0x01"
      },
      "decoded_value": 1
    },
    {
      "value": {
        "type_tag": "u64",
        "value": "0xae37bb6600000000"
      },
      "decoded_value": "1723545518"
    }
  ]
}
```

