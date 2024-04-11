module degengame::test{

    use aptos_framework::genesis;
    use aptos_framework::signer;
    use aptos_framework::resource_account;
    use degengame::main::{initialize};
    use aptos_framework::account::{Self,create_signer_for_test};
    use aptos_framework::debug;
    use degengame::main;
    use testcoin::testcoins::{Self,TestBNB,TestBUSD};
    use aptos_std::math64::pow;
    use aptos_framework::string::{Self,utf8};  
    use degengame::ids::{Self,U0,U1,U2};
    use aptos_framework::coin;
    use pancake::swap::LPToken;
    use aptos_framework::aptos_coin::AptosCoin;
    use degengame::main::DegenGameCoin;
    use aptos_framework::string_utils::to_string;


    const APTOS:u64 = 100000000;

    struct Coins<phantom Name> {

    }


    public fun setup_test_with_genesis(dev: &signer, resource_account: &signer,feedes:&signer) {
        genesis::setup();
        setup_test(dev, resource_account,feedes);
    }

    public fun setup_test_with_genesis_for_pancake(dev: &signer, resource_account: &signer,feedes:&signer) {
        setup_test(dev, resource_account,feedes);
    }

    public fun setup_test(dev: &signer, resource_account: &signer,feedes:&signer) {
        account::create_account_for_test(signer::address_of(dev));
        account::create_account_for_test(signer::address_of(feedes));

        resource_account::create_resource_account(dev, b"DegenGame", x"e8f6ae923fc761ae5543e72540d9266d6150412917883b05ace80777a9712ebc");
        initialize(resource_account);

        // APTOS token initialize
        let aptos_framework = create_signer_for_test(@0x1);

        main::create_aptos_token_for_test(aptos_framework);
        
    }

    public fun get_seeds(token_name:string::String):string::String{

        let seeds = string::utf8(b"");

        string::append(&mut seeds,to_string(&@degengame));

        string::append(&mut seeds,token_name);

        seeds
    }

    #[test(dev = @devaddress, resource_account = @degengame,feedes=@0x123)]
    fun test_initialize(dev:&signer,resource_account:&signer,feedes:&signer){
        setup_test_with_genesis(dev,resource_account,feedes);
    }


    //Start set fee destination test cases 
    #[test(dev = @devaddress, resource_account = @degengame,feedes=@0x123)]
    fun test_set_fee_destination(dev:&signer,resource_account:&signer,feedes:&signer){
        
        setup_test_with_genesis(dev,resource_account,feedes);

        let new_fee_destination_address = signer::address_of(feedes);

        degengame::main::set_fee_destination(dev,new_fee_destination_address);

        let (datastorage_fee_destinatione,_,_,_) = degengame::main::get_data();

        assert!(datastorage_fee_destinatione == new_fee_destination_address, 0x0);
    }

    #[test(dev = @devaddress, resource_account = @degengame,feedes=@0x123)]
    #[expected_failure(abort_code = 0)]
    fun test_set_fee_destination_using_wrong_owner(dev:&signer,resource_account:&signer,feedes:&signer){
        
        setup_test_with_genesis(dev,resource_account,feedes);

        let new_fee_destination_address = signer::address_of(feedes);

        degengame::main::set_fee_destination(feedes,new_fee_destination_address);
    }

    #[test(dev = @devaddress, resource_account = @degengame,feedes=@0x123)]
    #[expected_failure(abort_code = 12)]
    fun test_set_fee_destination_with_zero_address(dev:&signer,resource_account:&signer,feedes:&signer){
        
        setup_test_with_genesis(dev,resource_account,feedes);
        
        degengame::main::set_fee_destination(dev,@0x0);
    }
    //End set fee destination test cases 
    

    //Start set protocol fee test cases 
    #[test(dev = @devaddress, resource_account = @degengame,feedes=@0x123)]
    fun test_set_protocol_fee(dev:&signer,resource_account:&signer,feedes:&signer){
        
        setup_test_with_genesis(dev,resource_account,feedes);

        let protocol_fee = 5000000;

        degengame::main::set_protocol_fee_percent(dev,protocol_fee);

        let (_,datastorage_protocol_fee,_,_) = degengame::main::get_data();

        assert!(datastorage_protocol_fee == protocol_fee, 0x1);
    }

    #[test(dev = @devaddress, resource_account = @degengame,feedes=@0x123)]
    #[expected_failure(abort_code = 0)]
    fun test_set_protocol_fee_using_wrong_owner(dev:&signer,resource_account:&signer,feedes:&signer){
        
        setup_test_with_genesis(dev,resource_account,feedes);

        let protocol_fee = 5000000;

        degengame::main::set_protocol_fee_percent(feedes,protocol_fee);
    }

    #[test(dev = @devaddress, resource_account = @degengame,feedes=@0x123)]
    #[expected_failure(abort_code = 13)]
    fun test_set_same_protocol_fee(dev:&signer,resource_account:&signer,feedes:&signer){
        
        setup_test_with_genesis(dev,resource_account,feedes);

        let protocol_fee = 5000000;

        degengame::main::set_protocol_fee_percent(dev,protocol_fee);

        //Setting same protocol fees here
        degengame::main::set_protocol_fee_percent(dev,protocol_fee);
    }

    //End set protocol fee test cases



    //Start set subject fee test cases 
    #[test(dev = @devaddress, resource_account = @degengame,feedes=@0x123)]
    fun test_set_subject_fee(dev:&signer,resource_account:&signer,feedes:&signer){
        
        setup_test_with_genesis(dev,resource_account,feedes);

        let subject_fee = 5000000;

        degengame::main::set_subject_fee_percent(dev,subject_fee);

        let (_,_,datastorage_subject_fee,_) = degengame::main::get_data();

        assert!(datastorage_subject_fee == subject_fee, 0x2);
    }

    #[test(dev = @devaddress, resource_account = @degengame,feedes=@0x123)]
    #[expected_failure(abort_code = 0)]
    fun test_set_subject_fee_using_wrong_owner(dev:&signer,resource_account:&signer,feedes:&signer){
        
        setup_test_with_genesis(dev,resource_account,feedes);

        let subject_fee = 5000000;

        degengame::main::set_subject_fee_percent(feedes,subject_fee);
    }

    #[test(dev = @devaddress, resource_account = @degengame,feedes=@0x123)]
    #[expected_failure(abort_code = 13)]
    fun test_set_same_subject_fee(dev:&signer,resource_account:&signer,feedes:&signer){
        
        setup_test_with_genesis(dev,resource_account,feedes);

        let subject_fee = 5000000;

        degengame::main::set_subject_fee_percent(dev,subject_fee);

        //Setting same protocol fees here
        degengame::main::set_subject_fee_percent(dev,subject_fee);
    }

    //End set subject fee test cases


    //Start collect protocol fees test cases
    #[test(dev = @devaddress, resource_account = @degengame,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    fun test_collect_protocol_fees(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        let fee_destination_address = signer::address_of(feedes);

        let protocol_fee = 5000000;

        degengame::main::set_fee_destination(dev,fee_destination_address);

        degengame::main::set_protocol_fee_percent(dev,protocol_fee);

        degengame::main::register_and_mint(dev,100000000000000);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degengame::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));

        degengame::main::buy_share<U0,U1>(dev,share_subject,10,10000000000000);

        let (_,datastorage_protocol_fee,_,actual_collected_protocol_fees) = degengame::main::get_data();

        let price = degengame::main::get_price(1,10);

        //Calculate expected collected protocol fees
        let expected_collected_protocol_fees = price * datastorage_protocol_fee / APTOS;

        //Checking fees in data storage
        assert!(expected_collected_protocol_fees == actual_collected_protocol_fees, 0x3);

        degengame::main::collect_protocol_fees(feedes);

        let fee_destination_account_balance = coin::balance<AptosCoin>(fee_destination_address);

        //Checking fees in fee destinations account
        assert!(actual_collected_protocol_fees == fee_destination_account_balance, 0x4);

    }

    #[test(dev = @devaddress, resource_account = @degengame,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    #[expected_failure(abort_code = 6)]
    fun test_collect_protocol_fees_using_wrong_fee_destination(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        let fee_destination_address = signer::address_of(feedes);

        let protocol_fee = 5000000;

        degengame::main::set_fee_destination(dev,fee_destination_address);

        degengame::main::set_protocol_fee_percent(dev,protocol_fee);

        degengame::main::register_and_mint(dev,100000000000000);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degengame::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));

        degengame::main::buy_share<U0,U1>(dev,share_subject,10,10000000000000);

        let (_,datastorage_protocol_fee,_,actual_collected_protocol_fees) = degengame::main::get_data();

        let price = degengame::main::get_price(1,10);

        //Calculate expected collected protocol fees
        let expected_collected_protocol_fees = price * datastorage_protocol_fee / APTOS;

        //Checking fees in data storage
        assert!(expected_collected_protocol_fees == actual_collected_protocol_fees, 0x6);

        degengame::main::collect_protocol_fees(dev);

        let fee_destination_account_balance = coin::balance<AptosCoin>(fee_destination_address);

        //Checking fees in fee destinations account
        assert!(actual_collected_protocol_fees == fee_destination_account_balance, 0x7);

    }


    #[test(dev = @devaddress, resource_account = @degengame,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    #[expected_failure(abort_code = 11)]
    fun test_collect_protocol_fees_when_collected_fees_is_zero(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        let fee_destination_address = signer::address_of(feedes);

        let protocol_fee = 5000000;

        degengame::main::set_fee_destination(dev,fee_destination_address);

        degengame::main::set_protocol_fee_percent(dev,protocol_fee);

        degengame::main::register_and_mint(dev,100000000000000);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degengame::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));

        degengame::main::buy_share<U0,U1>(dev,share_subject,10,10000000000000);

        let (_,datastorage_protocol_fee,_,actual_collected_protocol_fees) = degengame::main::get_data();

        let price = degengame::main::get_price(1,10);

        //Calculate expected collected protocol fees
        let expected_collected_protocol_fees = price * datastorage_protocol_fee / APTOS;

        //Checking fees in data storage
        assert!(expected_collected_protocol_fees == actual_collected_protocol_fees, 0x6);

        degengame::main::collect_protocol_fees(feedes);

        let fee_destination_account_balance = coin::balance<AptosCoin>(fee_destination_address);

        //Checking fees in fee destinations account
        assert!(actual_collected_protocol_fees == fee_destination_account_balance, 0x7);

        degengame::main::collect_protocol_fees(feedes);

    }
    //End collect protocol fees test cases


    //Strat get buy price test cases
    #[test(dev = @devaddress, resource_account = @degengame,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    fun test_get_buy_price(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        degengame::main::register_and_mint(dev,100000000000000);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degengame::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));
        
        let buying_price = degengame::main::get_buy_price(share_subject,1);

    } 

    #[test(dev = @devaddress, resource_account = @degengame,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    #[expected_failure(abort_code = 1)]
    fun test_get_buy_price_with_worong_share_subject(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        degengame::main::register_and_mint(dev,100000000000000);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degengame::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));
        
        let buying_price = degengame::main::get_buy_price(share_subject,1);

        let buying_price1 = degengame::main::get_buy_price(@0x01234,1);

    } 
    //End get buy price test cases


    //Strat get sell price test cases
    #[test(dev = @devaddress, resource_account = @degengame,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    fun test_get_sell_price(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        degengame::main::register_and_mint(dev,100000000000000);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degengame::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));
        
        let selling_price = degengame::main::get_sell_price(share_subject,1);

    } 

    #[test(dev = @devaddress, resource_account = @degengame,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    #[expected_failure(abort_code = 1)]
    fun test_get_sell_price_with_worong_share_subject(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        degengame::main::register_and_mint(dev,100000000000000);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degengame::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));
        
        let selling_price = degengame::main::get_sell_price(share_subject,1);

        let selling_price1 = degengame::main::get_sell_price(@0x01234,1);

    } 
    //End get sell price test cases


    //Strat get buy price after fee test cases
    #[test(dev = @devaddress, resource_account = @degengame,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    fun test_get_buy_price_after_fee(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        degengame::main::register_and_mint(dev,100000000000000);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degengame::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));
        
        let buy_price = degengame::main::get_buy_price_after_fee(share_subject,1);

    } 

    #[test(dev = @devaddress, resource_account = @degengame,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    #[expected_failure(abort_code = 1)]
    fun test_get_buy_price_after_fee_with_worong_share_subject(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        degengame::main::register_and_mint(dev,100000000000000);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degengame::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));
        
        let buy_price = degengame::main::get_buy_price_after_fee(share_subject,1);

        let buy_price1 = degengame::main::get_buy_price_after_fee(@0x01234,1);

    } 
    //End get buy price after fee test cases


    //Strat get sell price after fee test cases
    #[test(dev = @devaddress, resource_account = @degengame,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    fun test_get_sell_price_after_fee(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        degengame::main::register_and_mint(dev,100000000000000);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degengame::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));
        
        let sell_price = degengame::main::get_sell_price_after_fee(share_subject,1);

    } 

    #[test(dev = @devaddress, resource_account = @degengame,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    #[expected_failure(abort_code = 1)]
    fun test_get_sell_price_after_fee_with_worong_share_subject(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        degengame::main::register_and_mint(dev,100000000000000);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degengame::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));
        
        let sell_price = degengame::main::get_sell_price_after_fee(share_subject,1);

        let sell_price1 = degengame::main::get_sell_price_after_fee(@0x01234,1);

    } 
    //End get sell price after fee test cases


    //Start create share test cases
    #[test(dev = @devaddress, resource_account = @degengame,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    fun test_create_share(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        degengame::main::register_and_mint(dev,100000000000000);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degengame::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

    } 

    #[test(dev = @devaddress, resource_account = @degengame,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    fun test_create_share_and_check_creator_share_balance(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        degengame::main::register_and_mint(dev,100000000000000);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degengame::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));

        let share_balance = degengame::main::get_share_balance(dev,share_subject);

        assert!(share_balance == 1, 0x8);

    } 

    #[test(dev = @devaddress, resource_account = @degengame,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    #[expected_failure(abort_code = 7)]
    fun test_create_share_with_same_toke_name(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        degengame::main::register_and_mint(dev,100000000000000);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degengame::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        //here we createing share with same name
        degengame::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);
    } 

    #[test(dev = @devaddress, resource_account = @degengame,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    #[expected_failure(abort_code = 524290)]
    fun test_create_share_with_same_ids(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        degengame::main::register_and_mint(dev,100000000000000);

        let first_token_name = string::utf8(b"DegenCoin");
        let first_token_symbol = string::utf8(b"DGC");
        let first_token_threshold = 10000000000;

        degengame::main::create_share<U0,U1>(dev,first_token_name,first_token_symbol,first_token_threshold);

        let second_token_name = string::utf8(b"MdCoin");
        let second_token_symbol = string::utf8(b"MDC");
        let second_token_threshold = 10000000000;

        //here we createing share with same name
        degengame::main::create_share<U0,U1>(dev,second_token_name,second_token_symbol,second_token_threshold);
    } 

    #[test(dev = @devaddress, resource_account = @degengame,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    fun test_create_shares_with_multiple_ids(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        degengame::main::register_and_mint(dev,100000000000000);

        let first_token_name = string::utf8(b"DegenCoin");
        let first_token_symbol = string::utf8(b"DGC");
        let first_token_threshold = 10000000000;

        degengame::main::create_share<U0,U1>(dev,first_token_name,first_token_symbol,first_token_threshold);

        let second_token_name = string::utf8(b"MdCoin");
        let second_token_symbol = string::utf8(b"MDC");
        let second_token_threshold = 10000000000;

        //here we createing share with same name
        degengame::main::create_share<U0,U2>(dev,second_token_name,second_token_symbol,second_token_threshold);
    } 
    //End create share test cases


    //Start buy share test cases
    #[test(dev = @devaddress,bob = @0x2121, resource_account = @degengame,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    fun test_buy_share(dev:&signer,bob:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        let bob_address = signer::address_of(bob);

        account::create_account_for_test(bob_address);

        let aptos_to_mint = 100000000000000;

        degengame::main::register_and_mint(dev,aptos_to_mint);

        degengame::main::register_and_mint(bob,aptos_to_mint);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degengame::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));

        let shares_to_buy = 1;

        let expected_buy_price = degengame::main::get_buy_price(share_subject,shares_to_buy);

        let user_balance_before = coin::balance<AptosCoin>(bob_address);

        degengame::main::buy_share<U0,U1>(bob,share_subject,shares_to_buy,1000000000);

        let user_balance_after = coin::balance<AptosCoin>(bob_address);

        assert!(expected_buy_price == (user_balance_before - user_balance_after), 0x9);

        let users_share_balance = degengame::main::get_share_balance(bob,share_subject);
        
        assert!(users_share_balance == shares_to_buy, 0x10);
    } 

    #[test(dev = @devaddress,bob = @0x2121, resource_account = @degengame,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    #[expected_failure(abort_code = 1)]
    fun test_buy_share_with_worong_share_subject(dev:&signer,bob:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        let bob_address = signer::address_of(bob);

        account::create_account_for_test(bob_address);

        let aptos_to_mint = 100000000000000;

        degengame::main::register_and_mint(dev,aptos_to_mint);

        degengame::main::register_and_mint(bob,aptos_to_mint);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degengame::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));

        let shares_to_buy = 1;

        degengame::main::buy_share<U0,U1>(bob,share_subject,shares_to_buy,1000000000);

        //here we trying to buy share with wrong share address
        degengame::main::buy_share<U0,U1>(bob,@0x1010,shares_to_buy,1000000000);
    }

    #[test(dev = @devaddress,bob = @0x2121, resource_account = @degengame,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    #[expected_failure(abort_code = 9)]
    fun test_buy_share_slippage_check(dev:&signer,bob:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        let bob_address = signer::address_of(bob);

        account::create_account_for_test(bob_address);

        let aptos_to_mint = 100000000000000;

        degengame::main::register_and_mint(dev,aptos_to_mint);

        degengame::main::register_and_mint(bob,aptos_to_mint);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degengame::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));

        let shares_to_buy = 1000;

        degengame::main::buy_share<U0,U1>(bob,share_subject,shares_to_buy,1000000000);

    }

    #[test(dev = @devaddress,bob = @0x2121, resource_account = @degengame,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    #[expected_failure(abort_code = 8)]
    fun test_buy_share_after_threshold_reached(dev:&signer,bob:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        let bob_address = signer::address_of(bob);

        account::create_account_for_test(bob_address);

        let aptos_to_mint = 100000000000000;

        degengame::main::register_and_mint(dev,aptos_to_mint);

        degengame::main::register_and_mint(bob,aptos_to_mint);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 200000000;

        degengame::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));

        let shares_to_buy1 = 30;
        degengame::main::buy_share<U0,U1>(bob,share_subject,shares_to_buy1,1000000000);
        
        let shares_to_buy2 = 30;
        degengame::main::buy_share<U0,U1>(bob,share_subject,shares_to_buy2,1000000000);

        
        let shares_to_buy3 = 10;
        //threshold is already reached in above transaction
        degengame::main::buy_share<U0,U1>(bob,share_subject,shares_to_buy2,1000000000);
    }

    #[test(dev = @devaddress,bob = @0x2121, resource_account = @degengame,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    #[expected_failure(abort_code = 3)]
    fun test_buy_share_with_low_balance(dev:&signer,bob:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        let bob_address = signer::address_of(bob);

        account::create_account_for_test(bob_address);

        let aptos_to_mint = 100000000000000;

        degengame::main::register_and_mint(dev,aptos_to_mint);

        degengame::main::register_and_mint(bob,aptos_to_mint);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 200000000;

        degengame::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));

        let shares_to_buy = 10000;
        degengame::main::buy_share<U0,U1>(bob,share_subject,shares_to_buy,1000000000);
        
    }

    #[test(dev = @devaddress,bob = @0x2121, resource_account = @degengame,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    fun test_buy_share_check_liquidity_in_pancakeswap(dev:&signer,bob:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        let bob_address = signer::address_of(bob);

        account::create_account_for_test(bob_address);

        let aptos_to_mint = 100000000000000;

        degengame::main::register_and_mint(dev,aptos_to_mint);

        degengame::main::register_and_mint(bob,aptos_to_mint);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 200000000;

        degengame::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));

        let shares_to_buy1 = 30;
        degengame::main::buy_share<U0,U1>(bob,share_subject,shares_to_buy1,1000000000);
        
        let shares_to_buy2 = 30;
        //threshold reach here
        degengame::main::buy_share<U0,U1>(bob,share_subject,shares_to_buy2,1000000000);

        let coin_x_liquidity = ((1 + shares_to_buy1 + shares_to_buy2) * 10) * APTOS;

        let coin_y_liquidity = (degengame::main::get_price(1,(shares_to_buy1 + shares_to_buy2)));

        let (balance_y, balance_x) = pancake::swap::token_balances<AptosCoin,DegenGameCoin<U0,U1>>();

        let share_subject_account_lp_balance = coin::balance<LPToken<AptosCoin,DegenGameCoin<U0,U1>>>(share_subject);
       
        let share_subject_account_suppose_lp_balance = pancake::math::sqrt(((coin_x_liquidity as u128) * (coin_y_liquidity as u128))) - 1000;
   
        assert!(balance_x == coin_x_liquidity, 0x11);
        assert!(balance_y == coin_y_liquidity, 0x12);
        assert!(share_subject_account_lp_balance == (share_subject_account_suppose_lp_balance as u64), 0x13);
    }
    //End buy share test cases


    //Start sell share test caes
    //End sell share test caes


    //Start claim token test caes
    //End claim token test caes







    // #[test(dev = @devaddress, resource_account = @degengame,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    // fun test_create_token(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){

    //     pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
    //     setup_test_with_genesis_for_pancake(dev,resource_account,feedes);


    //     degengame::main::set_protocol_fee_percent(dev,50000);
    //     degengame::main::set_subject_fee_percent(dev,50000);

    //     degengame::main::register_and_mint(dev,100000000000000);

    //     degengame::main::create_share<U0,U1>(dev,string::utf8(b"Test"),string::utf8(b"TSC"),200000000);

    //     let seeds = string::utf8(b"");
    //     string::append(&mut seeds,to_string(&@degengame));
    //     string::append(&mut seeds,string::utf8(b"Test"));    

    //     let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));

    //     // debug::print(&share_subject);

    //     degengame::main::buy_share<U0,U1>(dev,share_subject,10,10000000000000);
    //     degengame::main::buy_share<U0,U1>(dev,share_subject,10,10000000000000);
    //     degengame::main::buy_share<U0,U1>(dev,share_subject,10,10000000000000);
    //     degengame::main::buy_share<U0,U1>(dev,share_subject,20,10000000000000);

    //     // degengame::main::claim_token<U0,U1>(dev,share_subject);

    //     // aptos_framework::debug::print(&coin::balance<DegenGameCoin<U0,U1>>(signer::address_of(dev)));
        
    //     // degengame::main::buy_share<U0,U1>(dev,share_subject,100,10000000000000);


    //     // degengame::main::buy_share(dev,share_subject,100,10000000000000);
    //     // degengame::main::buy_share(dev,share_subject,1,100000000);

    //     // degengame::main::sell_shares(dev,share_subject,10,0);
    //     // degengame::main::sell_shares(dev,share_subject,10,0);
    //     // degengame::main::sell_shares(dev,share_subject,10,0);
    //     // degengame::main::buy_share(dev,share_subject,50);
    //     // degengame::main::buy_share(dev,share_subject,50);

    //     // degengame::main::create_share(dev,string::utf8(b"Test1"),string::utf8(b"TSC"),100,1);
    // }



}