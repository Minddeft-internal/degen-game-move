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
    use degengame::ids::{Self,U0,U1};
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

        degengame::main::create_share<U0,U1>(dev,string::utf8(b"DegenCoin"),string::utf8(b"DGC"),10000000000);

        let seeds = get_seeds(string::utf8(b"DegenCoin"));

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

        degengame::main::create_share<U0,U1>(dev,string::utf8(b"DegenCoin"),string::utf8(b"DGC"),10000000000);

        let seeds = get_seeds(string::utf8(b"DegenCoin"));

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

        degengame::main::create_share<U0,U1>(dev,string::utf8(b"DegenCoin"),string::utf8(b"DGC"),10000000000);

        let seeds = get_seeds(string::utf8(b"DegenCoin"));

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

        degengame::main::create_share<U0,U1>(dev,string::utf8(b"DegenCoin"),string::utf8(b"DGC"),10000000000);

        let seeds = get_seeds(string::utf8(b"DegenCoin"));

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));
        
        let buying_price = degengame::main::get_buy_price(share_subject,1);

    } 

    #[test(dev = @devaddress, resource_account = @degengame,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    #[expected_failure(abort_code = 1)]
    fun test_get_buy_price_with_worong_share_subject(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        degengame::main::register_and_mint(dev,100000000000000);

        degengame::main::create_share<U0,U1>(dev,string::utf8(b"DegenCoin"),string::utf8(b"DGC"),10000000000);

        let seeds = get_seeds(string::utf8(b"DegenCoin"));

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

        degengame::main::create_share<U0,U1>(dev,string::utf8(b"DegenCoin"),string::utf8(b"DGC"),10000000000);

        let seeds = get_seeds(string::utf8(b"DegenCoin"));

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));
        
        let selling_price = degengame::main::get_sell_price(share_subject,1);

    } 

    #[test(dev = @devaddress, resource_account = @degengame,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    #[expected_failure(abort_code = 1)]
    fun test_get_sell_price_with_worong_share_subject(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        degengame::main::register_and_mint(dev,100000000000000);

        degengame::main::create_share<U0,U1>(dev,string::utf8(b"DegenCoin"),string::utf8(b"DGC"),10000000000);

        let seeds = get_seeds(string::utf8(b"DegenCoin"));

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

        degengame::main::create_share<U0,U1>(dev,string::utf8(b"DegenCoin"),string::utf8(b"DGC"),10000000000);

        let seeds = get_seeds(string::utf8(b"DegenCoin"));

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));
        
        let buy_price = degengame::main::get_buy_price_after_fee(share_subject,1);

    } 

    #[test(dev = @devaddress, resource_account = @degengame,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    #[expected_failure(abort_code = 1)]
    fun test_get_buy_price_after_fee_with_worong_share_subject(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        degengame::main::register_and_mint(dev,100000000000000);

        degengame::main::create_share<U0,U1>(dev,string::utf8(b"DegenCoin"),string::utf8(b"DGC"),10000000000);

        let seeds = get_seeds(string::utf8(b"DegenCoin"));

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));
        
        let buy_price = degengame::main::get_buy_price_after_fee(share_subject,1);

        let buy_price1 = degengame::main::get_buy_price_after_fee(@0x01234,1);

    } 
    //End get buy price after fee test cases



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