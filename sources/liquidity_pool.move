module rooch_bonding_curve::liquidity_pool {

    use std::u256;
    use std::signer;
    use moveos_std::timestamp;
    use moveos_std::object::{Self, Object, ObjectID};
    use moveos_std::event::emit;
    use rooch_framework::account_coin_store;
    use rooch_framework::coin::CoinInfo;
    use rooch_framework::coin_store::{balance, deposit, withdraw};
    use rooch_framework::coin_store::CoinStore;

    // Error codes
    const ErrorInsufficientLiquidity: u64 = 1;
    const ErrorInsufficientShares: u64 = 2;
    const ErrorFeeCalculation: u64 = 3;

    // Structure representing a liquidity pool
    struct LiquidityPool<phantom TokenA: key + store + copy, phantom TokenB: key + store + copy> has key, store {
        creator: address,
        token_info_a: Object<CoinInfo<TokenA>>,
        token_info_b: Object<CoinInfo<TokenB>>,
        reserve_store_a: Object<CoinStore<TokenA>>,
        reserve_store_b: Object<CoinStore<TokenB>>,
        total_supply: u256,  // Total supply of liquidity tokens
        reserve_token_a: u256,  // Reserve amount of TokenA in the pool
        reserve_token_b: u256,  // Reserve amount of TokenB in the pool
        fee_rate: u8,  // Transaction fee rate (e.g., 1%)
        create_time: u64,
    }

    // Define events for different actions
    struct AddLiquidityEvent has copy, drop {
        pool_id: ObjectID,
        provider: address,
        amount_a: u256,
        amount_b: u256
    }

    struct RemoveLiquidityEvent has copy, drop {
        pool_id: ObjectID,
        provider: address,
        shares: u256,
        amount_a: u256,
        amount_b: u256
    }

    struct BuyTokenAEvent has copy, drop {
        pool_id: ObjectID,
        buyer: address,
        amount_b_in: u256,
        amount_a_out: u256
    }

    struct SellTokenAEvent has copy, drop {
        pool_id: ObjectID,
        seller: address,
        amount_a_in: u256,
        amount_b_out: u256
    }

    // Function to create a new liquidity pool
    public fun new<TokenA: key + store + copy, TokenB: key + store + copy>(
        creator: address,
        token_info_a: Object<CoinInfo<TokenA>>,
        token_info_b: Object<CoinInfo<TokenB>>,
        reserve_store_a: Object<CoinStore<TokenA>>,
        reserve_store_b: Object<CoinStore<TokenB>>,
        fee_rate: u8,  // Set the fee rate for the pool
    ): ObjectID {
        let pool = LiquidityPool {
            creator,
            token_info_a,
            token_info_b,
            reserve_store_a,
            reserve_store_b,
            total_supply: 0u256,
            reserve_token_a: 0u256,
            reserve_token_b: 0u256,
            fee_rate,
            create_time: timestamp::now_seconds(),
        };
        let pool_obj = object::new_named_object(pool);
        let pool_id = object::id(&pool_obj);
        pool_id
    }

    // Function to add liquidity to the pool
    public entry fun add_liquidity<TokenA: key + store + copy, TokenB: key + store + copy>(
        signer: &signer,
        pool_obj: &mut Object<LiquidityPool<TokenA, TokenB>>,
        amount_a: u256,
        amount_b: u256,
    ) {
        let pool = object::borrow_mut(pool_obj);

        // Withdraw tokens from the user's account
        let token_a = account_coin_store::withdraw<TokenA>(signer, amount_a);
        let token_b = account_coin_store::withdraw<TokenB>(signer, amount_b);

        // Deposit the tokens into the liquidity pool
        deposit(&mut pool.reserve_store_a, token_a);
        deposit(&mut pool.reserve_store_b, token_b);

        // Update pool reserves and total supply
        pool.reserve_token_a = pool.reserve_token_a + amount_a;
        pool.reserve_token_b = pool.reserve_token_b + amount_b;
        pool.total_supply = pool.total_supply + amount_a + amount_b;

        // Emit AddLiquidity event
        emit<AddLiquidityEvent>(AddLiquidityEvent {
            pool_id: object::id(pool_obj),
            provider: signer::address_of(signer),
            amount_a,
            amount_b
        });
    }

    // Function to remove liquidity from the pool
    public entry fun remove_liquidity<TokenA: store + key + copy, TokenB: store + key + copy>(
        signer: &signer,
        pool_obj: &mut Object<LiquidityPool<TokenA, TokenB>>,
        shares: u256,
    ) {
        let pool = object::borrow_mut(pool_obj);

        // Ensure the provider has enough shares to remove liquidity
        assert!(shares <= pool.total_supply, ErrorInsufficientShares);

        // Calculate the amount of each token to withdraw
        let amount_a = shares * pool.reserve_token_a / pool.total_supply;
        let amount_b = shares * pool.reserve_token_b / pool.total_supply;

        // Withdraw tokens from the pool
        let token_a = withdraw(&mut pool.reserve_store_a, amount_a);
        let token_b = withdraw(&mut pool.reserve_store_b, amount_b);

        // Deposit the withdrawn tokens into the user's account
        account_coin_store::deposit(std::signer::address_of(signer), token_a);
        account_coin_store::deposit(std::signer::address_of(signer), token_b);

        // Update pool reserves and total supply
        pool.reserve_token_a = pool.reserve_token_a - amount_a;
        pool.reserve_token_b = pool.reserve_token_b - amount_b;
        pool.total_supply = pool.total_supply - shares;

        pool.create_time = timestamp::now_seconds();

        // Emit RemoveLiquidity event
        emit<RemoveLiquidityEvent>(RemoveLiquidityEvent {
            pool_id: object::id(pool_obj),
            provider: signer::address_of(signer),
            shares,
            amount_a,
            amount_b
        });
    }

    // Function to buy TokenA from the pool using TokenB
    public entry fun buy_token_a<TokenA: store + key + copy, TokenB: store + key + copy>(
        signer: &signer,
        pool_obj: &mut Object<LiquidityPool<TokenA, TokenB>>,
        amount_b_in: u256,
    ) {
        let pool = object::borrow_mut(pool_obj);
        let reserve_a = balance(&pool.reserve_store_a);
        let reserve_b = balance(&pool.reserve_store_b);

        let amount_a_out = get_output_amount(amount_b_in, reserve_b, reserve_a, pool.fee_rate);

        // Withdraw TokenB from the user's account and deposit it into the pool
        let token_b = account_coin_store::withdraw<TokenB>(signer, amount_b_in);
        deposit(&mut pool.reserve_store_b, token_b);

        // Withdraw TokenA from the pool and deposit it into the user's account
        let token_a = withdraw(&mut pool.reserve_store_a, amount_a_out);
        account_coin_store::deposit(std::signer::address_of(signer), token_a);

        // Update reserves
        pool.reserve_token_a = pool.reserve_token_a - amount_a_out;
        pool.reserve_token_b = pool.reserve_token_b + amount_b_in;

        pool.create_time = timestamp::now_seconds();

        // Emit BuyTokenA event
        emit<BuyTokenAEvent>(BuyTokenAEvent {
            pool_id: object::id(pool_obj),
            buyer: signer::address_of(signer),
            amount_b_in,
            amount_a_out
        });
    }

    // Function to sell TokenA to the pool in exchange for TokenB
    public entry fun sell_token_a<TokenA: store + key + copy, TokenB: store + key + copy>(
        signer: &signer,
        pool_obj: &mut Object<LiquidityPool<TokenA, TokenB>>,
        amount_a_in: u256,
    ) {
        let pool = object::borrow_mut(pool_obj);
        let reserve_a = balance(&pool.reserve_store_a);
        let reserve_b = balance(&pool.reserve_store_b);

        let amount_b_out = get_output_amount(amount_a_in, reserve_a, reserve_b, pool.fee_rate);

        // Withdraw TokenA from the user's account and deposit it into the pool
        let token_a = account_coin_store::withdraw<TokenA>(signer, amount_a_in);
        deposit(&mut pool.reserve_store_a, token_a);

        // Withdraw TokenB from the pool and deposit it into the user's account
        let token_b = withdraw(&mut pool.reserve_store_b, amount_b_out);
        account_coin_store::deposit(std::signer::address_of(signer), token_b);

        // Update reserves
        pool.reserve_token_a = pool.reserve_token_a + amount_a_in;
        pool.reserve_token_b = pool.reserve_token_b - amount_b_out;

        pool.create_time = timestamp::now_seconds();

        // Emit SellTokenA event
        emit<SellTokenAEvent>(SellTokenAEvent {
            pool_id: object::id(pool_obj),
            seller: signer::address_of(signer),
            amount_a_in,
            amount_b_out
        });
    }

    // Function to calculate the output amount based on the input amount, reserves, and fee rate
    public fun get_output_amount(input_amount: u256, input_reserve: u256, output_reserve: u256, fee_rate: u8): u256 {
        let input_amount_with_fee = input_amount * (100u256 - (fee_rate as u256)) / 100u256;
        let numerator = input_amount_with_fee * output_reserve;
        let denominator = (input_reserve * 100u256) + input_amount_with_fee;
        u256::divide_and_round_up(numerator, denominator)
    }

    // Method to get mutable reference to LiquidityPool by ObjectID
    public fun get_pool_mut<TokenA: key + store + copy, TokenB: key + store + copy>(
        pool_id: ObjectID
    ): &mut Object<LiquidityPool<TokenA, TokenB>> {
        object::borrow_mut_object_extend<LiquidityPool<TokenA, TokenB>>(pool_id)
    }

    // Query all details of the liquidity pool
    public fun query_pool_details<TokenA: key + store + copy, TokenB: key + store + copy>(pool_id: ObjectID): (u256, u256, u256, address, u8, u64) {
        let pool_obj = get_pool_mut<TokenA, TokenB>(pool_id);
        let pool = object::borrow(pool_obj); 
        (
            pool.total_supply,
            pool.reserve_token_a,
            pool.reserve_token_b,
            pool.creator,
            pool.fee_rate,
            pool.create_time
        )
    }
}
