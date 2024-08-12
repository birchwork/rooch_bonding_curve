module bonding_curve_demo::liquidity_pool_test {
    use std::string;
    use std::signer;
    use std::string::String;
    use rooch_framework::coin;
    use moveos_std::object::ObjectID;
    use bonding_curve_demo::liquidity_pool;
    use rooch_framework::coin_store::{Self};
    use rooch_framework::account_coin_store;

    const FEE_RATE: u8 = 1u8;
    const DECIMALS: u8 = 1u8;
    const MINT_AMOUNT: u256 = 10_000u256;
    const TOTAL_SUPPLY: u256 = 210_000_000_000u256;

    struct FSCA has key, store, copy {}
    struct FSCB has key, store, copy {}

    public entry fun test_create_pool(signer: &signer,token_a_name: String, token_b_name: String, token_a_symbol: String, token_b_symbol: String) {
        let creator = signer::address_of(signer);

        // Mint Token A and deposit into creator's account
        let coin_a_info_obj = coin::register_extend<FSCA>(
            string::utf8(string::into_bytes(token_a_name)),
            string::utf8(string::into_bytes(token_a_symbol)),
            DECIMALS,
        );
        let coin_a = coin::mint_extend<FSCA>(&mut coin_a_info_obj, TOTAL_SUPPLY);
        let coin_a_store_obj = coin_store::create_coin_store<FSCA>();

        coin_store::deposit(&mut coin_a_store_obj, coin_a);
        
        // Withdraw and deposit minted amount directly to creator's account
        let coin_a_amount = coin_store::withdraw(&mut coin_a_store_obj, MINT_AMOUNT);
        account_coin_store::deposit(creator, coin_a_amount);

        // Mint Token B and deposit into creator's account
        let coin_b_info_obj = coin::register_extend<FSCB>(
            string::utf8(string::into_bytes(token_b_name)),
            string::utf8(string::into_bytes(token_b_symbol)),
            DECIMALS,
        );
        let coin_b = coin::mint_extend<FSCB>(&mut coin_b_info_obj, TOTAL_SUPPLY);
        let coin_b_store_obj = coin_store::create_coin_store<FSCB>();

        coin_store::deposit(&mut coin_b_store_obj, coin_b);
        
        // Withdraw and deposit minted amount directly to creator's account
        let coin_b_amount = coin_store::withdraw(&mut coin_b_store_obj, MINT_AMOUNT);
        account_coin_store::deposit(creator, coin_b_amount);

        // Create the liquidity pool
        liquidity_pool::new<FSCA, FSCB>(
            creator,
            coin_a_info_obj,
            coin_b_info_obj,
            coin_a_store_obj,
            coin_b_store_obj,
            FEE_RATE,
        );
    }

    public entry fun test_add_liquidity(signer: &signer, pool_id: ObjectID) {
        let amount_a = 1_000u256;
        let amount_b = 1_000u256;

        let pool_obj = liquidity_pool::get_pool_mut<FSCA, FSCB>(pool_id);

        liquidity_pool::add_liquidity<FSCA, FSCB>(
            signer,
            pool_obj,
            amount_a,
            amount_b
        );
    }

    public entry fun test_remove_liquidity(signer: &signer, pool_id: ObjectID) {
        let shares_to_remove = 500u256;

        let pool_obj = liquidity_pool::get_pool_mut<FSCA, FSCB>(pool_id);

        liquidity_pool::remove_liquidity<FSCA, FSCB>(
            signer,
            pool_obj,
            shares_to_remove
        );
    }

    public entry fun test_buy_token_a(signer: &signer, pool_id: ObjectID) {
        let amount_b_in = 100u256;

        let pool_obj = liquidity_pool::get_pool_mut<FSCA, FSCB>(pool_id);

        liquidity_pool::buy_token_a<FSCA, FSCB>(
            signer,
            pool_obj,
            amount_b_in
        );
    }

    public entry fun test_sell_token_a(signer: &signer, pool_id: ObjectID) {
        let amount_a_in = 100u256;

        let pool_obj = liquidity_pool::get_pool_mut<FSCA, FSCB>(pool_id);

        liquidity_pool::sell_token_a<FSCA, FSCB>(
            signer,
            pool_obj,
            amount_a_in
        );
    }

    // Function to query the details of the liquidity pool
    public fun query_pool_details(pool_id: ObjectID): (u256, u256, u256, address, u8, u64) {
        liquidity_pool::query_pool_details<FSCA, FSCB>(pool_id)
    }
}