module degenfun::test{

    use aptos_framework::genesis;
    use aptos_framework::signer;
    use aptos_framework::resource_account;
    use degenfun::main::{initialize};
    use aptos_framework::account::{Self,create_signer_for_test};
    use degenfun::main;
    use aptos_framework::string::{Self};  
    use degenfun::ids::{U0,U1,U2,U3,U4,U5};
    use aptos_framework::coin;
    use pancake::swap::LPToken;
    use aptos_framework::aptos_coin::{AptosCoin};
    use degenfun::main::DegenFunCoin;
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

        string::append(&mut seeds,to_string(&@degenfun));

        string::append(&mut seeds,token_name);

        seeds
    }

    #[test(dev = @devaddress, resource_account = @degenfun,feedes=@0x123)]
    fun test_initialize(dev:&signer,resource_account:&signer,feedes:&signer){
        setup_test_with_genesis(dev,resource_account,feedes);
    }

    //Start set owner test cases 
    #[test(dev = @devaddress, resource_account = @degenfun,new_owner=@0x123)]
    fun test_set_new_owner(dev:&signer,resource_account:&signer,new_owner:&signer){
        
        setup_test_with_genesis(dev,resource_account,new_owner);

        let new_owner_address = signer::address_of(new_owner);

        degenfun::main::set_owner(dev,new_owner_address);

        let (owner_address,_,_,_,_) = degenfun::main::get_data();

        assert!(owner_address == new_owner_address, 0x0);
    }

    #[test(dev = @devaddress, resource_account = @degenfun,new_owner=@0x123)]
    #[expected_failure(abort_code = 0,location = degenfun::main)]
    fun test_set_new_owner_using_wrong_owner(dev:&signer,resource_account:&signer,new_owner:&signer){
        
        setup_test_with_genesis(dev,resource_account,new_owner);

        let new_owner_address = signer::address_of(new_owner);

        degenfun::main::set_owner(new_owner,new_owner_address);
    }

    #[test(dev = @devaddress, resource_account = @degenfun,new_owner=@0x123)]
    #[expected_failure(abort_code = 12,location = degenfun::main)]
    fun test_set_new_owner_with_zero_address(dev:&signer,resource_account:&signer,new_owner:&signer){
        
        setup_test_with_genesis(dev,resource_account,new_owner);
        
        degenfun::main::set_owner(dev,@0x0);
    }
    //End set owner test cases 


    //Start set fee destination test cases 
    #[test(dev = @devaddress, resource_account = @degenfun,feedes=@0x123)]
    fun test_set_fee_destination(dev:&signer,resource_account:&signer,feedes:&signer){
        
        setup_test_with_genesis(dev,resource_account,feedes);

        let new_fee_destination_address = signer::address_of(feedes);

        degenfun::main::set_fee_destination(dev,new_fee_destination_address);

        let (_,datastorage_fee_destinatione,_,_,_) = degenfun::main::get_data();

        assert!(datastorage_fee_destinatione == new_fee_destination_address, 0x0);
    }

    #[test(dev = @devaddress, resource_account = @degenfun,feedes=@0x123)]
    #[expected_failure(abort_code = 0,location = degenfun::main)]
    fun test_set_fee_destination_using_wrong_owner(dev:&signer,resource_account:&signer,feedes:&signer){
        
        setup_test_with_genesis(dev,resource_account,feedes);

        let new_fee_destination_address = signer::address_of(feedes);

        degenfun::main::set_fee_destination(feedes,new_fee_destination_address);
    }

    #[test(dev = @devaddress, resource_account = @degenfun,feedes=@0x123)]
    #[expected_failure(abort_code = 12,location = degenfun::main)]
    fun test_set_fee_destination_with_zero_address(dev:&signer,resource_account:&signer,feedes:&signer){
        
        setup_test_with_genesis(dev,resource_account,feedes);
        
        degenfun::main::set_fee_destination(dev,@0x0);
    }
    //End set fee destination test cases 
    

    //Start set protocol fee test cases 
    #[test(dev = @devaddress, resource_account = @degenfun,feedes=@0x123)]
    fun test_set_protocol_fee(dev:&signer,resource_account:&signer,feedes:&signer){
        
        setup_test_with_genesis(dev,resource_account,feedes);

        let protocol_fee = 5000000;

        degenfun::main::set_protocol_fee_percent(dev,protocol_fee);

        let (_,_,datastorage_protocol_fee,_,_) = degenfun::main::get_data();

        assert!(datastorage_protocol_fee == protocol_fee, 0x1);
    }

    #[test(dev = @devaddress, resource_account = @degenfun,feedes=@0x123)]
    #[expected_failure(abort_code = 0,location = degenfun::main)]
    fun test_set_protocol_fee_using_wrong_owner(dev:&signer,resource_account:&signer,feedes:&signer){
        
        setup_test_with_genesis(dev,resource_account,feedes);

        let protocol_fee = 5000000;

        degenfun::main::set_protocol_fee_percent(feedes,protocol_fee);
    }

    #[test(dev = @devaddress, resource_account = @degenfun,feedes=@0x123)]
    #[expected_failure(abort_code = 13,location = degenfun::main)]
    fun test_set_same_protocol_fee(dev:&signer,resource_account:&signer,feedes:&signer){
        
        setup_test_with_genesis(dev,resource_account,feedes);

        let protocol_fee = 5000000;

        degenfun::main::set_protocol_fee_percent(dev,protocol_fee);

        //Setting same protocol fees here
        degenfun::main::set_protocol_fee_percent(dev,protocol_fee);
    }

    //End set protocol fee test cases



    //Start set subject fee test cases 
    #[test(dev = @devaddress, resource_account = @degenfun,feedes=@0x123)]
    fun test_set_subject_fee(dev:&signer,resource_account:&signer,feedes:&signer){
        
        setup_test_with_genesis(dev,resource_account,feedes);

        let subject_fee = 5000000;

        degenfun::main::set_subject_fee_percent(dev,subject_fee);

        let (_,_,_,datastorage_subject_fee,_) = degenfun::main::get_data();

        assert!(datastorage_subject_fee == subject_fee, 0x2);
    }

    #[test(dev = @devaddress, resource_account = @degenfun,feedes=@0x123)]
    #[expected_failure(abort_code = 0,location = degenfun::main)]
    fun test_set_subject_fee_using_wrong_owner(dev:&signer,resource_account:&signer,feedes:&signer){
        
        setup_test_with_genesis(dev,resource_account,feedes);

        let subject_fee = 5000000;

        degenfun::main::set_subject_fee_percent(feedes,subject_fee);
    }

    #[test(dev = @devaddress, resource_account = @degenfun,feedes=@0x123)]
    #[expected_failure(abort_code = 13,location = degenfun::main)]
    fun test_set_same_subject_fee(dev:&signer,resource_account:&signer,feedes:&signer){
        
        setup_test_with_genesis(dev,resource_account,feedes);

        let subject_fee = 5000000;

        degenfun::main::set_subject_fee_percent(dev,subject_fee);

        //Setting same protocol fees here
        degenfun::main::set_subject_fee_percent(dev,subject_fee);
    }

    //End set subject fee test cases


    //Start collect protocol fees test cases
    #[test(dev = @devaddress, resource_account = @degenfun,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    fun test_check_protocol_fees_in_fee_destination_account(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        let fee_destination_address = signer::address_of(feedes);

        degenfun::main::register_aptos(feedes);

        let protocol_fee = 5000000;

        degenfun::main::set_fee_destination(dev,fee_destination_address);

        degenfun::main::set_protocol_fee_percent(dev,protocol_fee);

        degenfun::main::register_and_mint(dev,100000000000000);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degenfun::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));

        degenfun::main::buy_share<U0,U1>(dev,share_subject,10,10000000000000);

        let (_,_,datastorage_protocol_fee,_,actual_collected_protocol_fees) = degenfun::main::get_data();

        let price = degenfun::main::get_price(1,10);

        //Calculate expected collected protocol fees
        let expected_collected_protocol_fees = price * datastorage_protocol_fee / APTOS;


        let fee_destination_account_balance = coin::balance<AptosCoin>(fee_destination_address);

        //Checking fees in fee destinations account
        assert!(expected_collected_protocol_fees == fee_destination_account_balance, 0x4);

    }

    #[test(dev = @devaddress, resource_account = @degenfun,feedes=@0x123,bob=@0x2121,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    fun test_check_protocol_fees_in_owners_account(dev:&signer,resource_account:&signer,feedes:&signer,bob:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        let bob_address = signer::address_of(bob);

        account::create_account_for_test(bob_address);

        let fee_destination_address = signer::address_of(feedes);

        let protocol_fee = 5000000;

        degenfun::main::set_protocol_fee_percent(dev,protocol_fee);

        degenfun::main::register_and_mint(dev,100000000000000);

        degenfun::main::register_and_mint(bob,100000000000000);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degenfun::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let owner_account_balance_before = coin::balance<AptosCoin>(signer::address_of(dev));

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));

        degenfun::main::buy_share<U0,U1>(bob,share_subject,10,10000000000000);

        let (_,_,datastorage_protocol_fee,_,actual_collected_protocol_fees) = degenfun::main::get_data();

        let price = degenfun::main::get_price(1,10);

        //Calculate expected collected protocol fees
        let expected_collected_protocol_fees = price * datastorage_protocol_fee / APTOS;

        let owner_account_balance_after = coin::balance<AptosCoin>(signer::address_of(dev));

        //Checking fees in fee destinations account
        assert!((owner_account_balance_after - owner_account_balance_before) == expected_collected_protocol_fees, 0x4);

    }

    //End collect protocol fees test cases


    //Start get buy price test cases
    #[test(dev = @devaddress, resource_account = @degenfun,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    fun test_get_buy_price(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        degenfun::main::register_and_mint(dev,100000000000000);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degenfun::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));
        
        let _buying_price = degenfun::main::get_buy_price<U0,U1>(share_subject,1);

    } 

    #[test(dev = @devaddress, resource_account = @degenfun,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    #[expected_failure(abort_code = 1,location = degenfun::main)]
    fun test_get_buy_price_with_wrong_share_subject(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        degenfun::main::register_and_mint(dev,100000000000000);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degenfun::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));
        
        let _buying_price = degenfun::main::get_buy_price<U0,U1>(share_subject,1);

        let _buying_price1 = degenfun::main::get_buy_price<U0,U1>(@0x01234,1);

    } 
    //End get buy price test cases


    //Start get sell price test cases
    #[test(dev = @devaddress, resource_account = @degenfun,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    fun test_get_sell_price(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        degenfun::main::register_and_mint(dev,100000000000000);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degenfun::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));
        
        let _selling_price = degenfun::main::get_sell_price<U0,U1>(share_subject,1);

    } 

    #[test(dev = @devaddress, resource_account = @degenfun,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    #[expected_failure(abort_code = 1,location = degenfun::main)]
    fun test_get_sell_price_with_wrong_share_subject(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        degenfun::main::register_and_mint(dev,100000000000000);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degenfun::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));
        
        let _selling_price = degenfun::main::get_sell_price<U0,U1>(share_subject,1);

        let _selling_price1 = degenfun::main::get_sell_price<U0,U1>(@0x01234,1);

    } 
    //End get sell price test cases


    //Start get buy price after fee test cases
    #[test(dev = @devaddress, resource_account = @degenfun,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    fun test_get_buy_price_after_fee(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        degenfun::main::register_and_mint(dev,100000000000000);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degenfun::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));
        
        let _buy_price = degenfun::main::get_buy_price_after_fee<U0,U1>(share_subject,1);

    } 

    #[test(dev = @devaddress, resource_account = @degenfun,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    #[expected_failure(abort_code = 1,location = degenfun::main)]
    fun test_get_buy_price_after_fee_with_wrong_share_subject(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        degenfun::main::register_and_mint(dev,100000000000000);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degenfun::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));
        
        let _buy_price = degenfun::main::get_buy_price_after_fee<U0,U1>(share_subject,1);

        let _buy_price1 = degenfun::main::get_buy_price_after_fee<U0,U1>(@0x01234,1);

    } 
    //End get buy price after fee test cases


    //Start get sell price after fee test cases
    #[test(dev = @devaddress, resource_account = @degenfun,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    fun test_get_sell_price_after_fee(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        degenfun::main::register_and_mint(dev,100000000000000);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degenfun::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));
        
        let _sell_price = degenfun::main::get_sell_price_after_fee<U0,U1>(share_subject,1);

    } 

    #[test(dev = @devaddress, resource_account = @degenfun,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    #[expected_failure(abort_code = 1,location = degenfun::main)]
    fun test_get_sell_price_after_fee_with_wrong_share_subject(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        degenfun::main::register_and_mint(dev,100000000000000);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degenfun::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));
        
        let _sell_price = degenfun::main::get_sell_price_after_fee<U0,U1>(share_subject,1);

        let _sell_price1 = degenfun::main::get_sell_price_after_fee<U0,U1>(@0x01234,1);

    } 
    //End get sell price after fee test cases


    //Start create share test cases
    #[test(dev = @devaddress, resource_account = @degenfun,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    fun test_create_share(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        degenfun::main::register_and_mint(dev,100000000000000);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degenfun::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

    } 

    #[test(dev = @devaddress, resource_account = @degenfun,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    fun test_create_share_and_check_creator_share_balance(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        degenfun::main::register_and_mint(dev,100000000000000);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degenfun::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));

        let share_balance = degenfun::main::get_share_balance<U0,U1>(signer::address_of(dev),share_subject);

        assert!(share_balance == 1, 0x8);

    } 

    #[test(dev = @devaddress, resource_account = @degenfun,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    #[expected_failure(abort_code = 7,location = degenfun::main)]
    fun test_create_share_with_same_toke_name(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        degenfun::main::register_and_mint(dev,100000000000000);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degenfun::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        //here we creating share with same name
        degenfun::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);
    } 

    #[test(dev = @devaddress, resource_account = @degenfun,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    #[expected_failure(abort_code = 524290,location = aptos_framework::coin)]
    fun test_create_share_with_same_ids(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        degenfun::main::register_and_mint(dev,100000000000000);

        let first_token_name = string::utf8(b"DegenCoin");
        let first_token_symbol = string::utf8(b"DGC");
        let first_token_threshold = 10000000000;

        degenfun::main::create_share<U0,U1>(dev,first_token_name,first_token_symbol,first_token_threshold);

        let second_token_name = string::utf8(b"MdCoin");
        let second_token_symbol = string::utf8(b"MDC");
        let second_token_threshold = 10000000000;

        //here we creating share with same name
        degenfun::main::create_share<U0,U1>(dev,second_token_name,second_token_symbol,second_token_threshold);
    } 

    #[test(dev = @devaddress, resource_account = @degenfun,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    fun test_create_shares_with_multiple_ids(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        degenfun::main::register_and_mint(dev,100000000000000);

        let first_token_name = string::utf8(b"DegenCoin");
        let first_token_symbol = string::utf8(b"DGC");
        let first_token_threshold = 10000000000;

        degenfun::main::create_share<U0,U1>(dev,first_token_name,first_token_symbol,first_token_threshold);

        let second_token_name = string::utf8(b"MdCoin");
        let second_token_symbol = string::utf8(b"MDC");
        let second_token_threshold = 10000000000;

        degenfun::main::create_share<U0,U2>(dev,second_token_name,second_token_symbol,second_token_threshold);

        let third_token_name = string::utf8(b"MemeCoin");
        let third_token_symbol = string::utf8(b"MMC");
        let third_token_threshold = 10000000000;

        degenfun::main::create_share<U0,U3>(dev,third_token_name,third_token_symbol,third_token_threshold);


        let fourth_token_name = string::utf8(b"TestCoin");
        let fourth_token_symbol = string::utf8(b"TC");
        let fourth_token_threshold = 10000000000;

        degenfun::main::create_share<U0,U4>(dev,fourth_token_name,fourth_token_symbol,fourth_token_threshold);

        let fifth_token_name = string::utf8(b"ApeCoin");
        let fifth_token_symbol = string::utf8(b"APC");
        let fifth_token_threshold = 10000000000;

        degenfun::main::create_share<U0,U5>(dev,fifth_token_name,fifth_token_symbol,fifth_token_threshold);
    } 
    //End create share test cases


    //Start buy share test cases
    #[test(dev = @devaddress,bob = @0x2121, resource_account = @degenfun,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    fun test_buy_share(dev:&signer,bob:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        let bob_address = signer::address_of(bob);

        account::create_account_for_test(bob_address);

        let aptos_to_mint = 100000000000000;

        degenfun::main::register_and_mint(dev,aptos_to_mint);

        degenfun::main::register_and_mint(bob,aptos_to_mint);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degenfun::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));

        let shares_to_buy = 1;

        let expected_buy_price = degenfun::main::get_buy_price<U0,U1>(share_subject,shares_to_buy);

        let bob_aptos_balance_before = coin::balance<AptosCoin>(bob_address);
        let share_subject_aptos_balance_before = coin::balance<AptosCoin>(share_subject);

        degenfun::main::buy_share<U0,U1>(bob,share_subject,shares_to_buy,1000000000);

        let bob_aptos_balance_after = coin::balance<AptosCoin>(bob_address);
        let share_subject_aptos_balance_after = coin::balance<AptosCoin>(share_subject);

        let bob_share_balance = degenfun::main::get_share_balance<U0,U1>(signer::address_of(bob),share_subject);
        
        assert!(expected_buy_price == (bob_aptos_balance_before - bob_aptos_balance_after), 0x9);
        assert!(expected_buy_price == (share_subject_aptos_balance_after - share_subject_aptos_balance_before), 0x10);
        assert!(bob_share_balance == shares_to_buy, 0x11);
    } 

    #[test(dev = @devaddress,bob = @0x2121, resource_account = @degenfun,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    #[expected_failure(abort_code = 1,location = degenfun::main)]
    fun test_buy_share_with_wrong_share_subject(dev:&signer,bob:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        let bob_address = signer::address_of(bob);

        account::create_account_for_test(bob_address);

        let aptos_to_mint = 100000000000000;

        degenfun::main::register_and_mint(dev,aptos_to_mint);

        degenfun::main::register_and_mint(bob,aptos_to_mint);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degenfun::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));

        let shares_to_buy = 1;

        degenfun::main::buy_share<U0,U1>(bob,share_subject,shares_to_buy,1000000000);

        //here we trying to buy share with wrong share address
        degenfun::main::buy_share<U0,U1>(bob,@0x1010,shares_to_buy,1000000000);
    }

    #[test(dev = @devaddress,bob = @0x2121, resource_account = @degenfun,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    #[expected_failure(abort_code = 9,location = degenfun::main)]
    fun test_buy_share_slippage_check(dev:&signer,bob:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        let bob_address = signer::address_of(bob);

        account::create_account_for_test(bob_address);

        let aptos_to_mint = 100000000000000;

        degenfun::main::register_and_mint(dev,aptos_to_mint);

        degenfun::main::register_and_mint(bob,aptos_to_mint);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degenfun::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));

        let shares_to_buy = 1000;

        degenfun::main::buy_share<U0,U1>(bob,share_subject,shares_to_buy,1000000000);

    }

    #[test(dev = @devaddress,bob = @0x2121, resource_account = @degenfun,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    #[expected_failure(abort_code = 8,location = degenfun::main)]
    fun test_buy_share_after_threshold_reached(dev:&signer,bob:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        let bob_address = signer::address_of(bob);

        account::create_account_for_test(bob_address);

        let aptos_to_mint = 100000000000000;

        degenfun::main::register_and_mint(dev,aptos_to_mint);

        degenfun::main::register_and_mint(bob,aptos_to_mint);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 200000000;

        degenfun::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));

        let shares_to_buy1 = 30;
        degenfun::main::buy_share<U0,U1>(bob,share_subject,shares_to_buy1,1000000000);
        
        let shares_to_buy2 = 30;
        degenfun::main::buy_share<U0,U1>(bob,share_subject,shares_to_buy2,1000000000);

        
        let shares_to_buy3 = 10;
        //threshold is already reached in above transaction
        degenfun::main::buy_share<U0,U1>(bob,share_subject,shares_to_buy3,1000000000);
    }

    #[test(dev = @devaddress,bob = @0x2121, resource_account = @degenfun,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    #[expected_failure(abort_code = 3,location = degenfun::main)]
    fun test_buy_share_with_low_balance(dev:&signer,bob:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        let bob_address = signer::address_of(bob);

        account::create_account_for_test(bob_address);

        let aptos_to_mint = 100000000000000;

        degenfun::main::register_and_mint(dev,aptos_to_mint);

        degenfun::main::register_and_mint(bob,aptos_to_mint);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 200000000;

        degenfun::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));

        let shares_to_buy = 10000;
        degenfun::main::buy_share<U0,U1>(bob,share_subject,shares_to_buy,1000000000);
        
    }

    #[test(dev = @devaddress,bob = @0x2121, resource_account = @degenfun,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    fun test_buy_share_check_liquidity_in_pancakeswap(dev:&signer,bob:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        let bob_address = signer::address_of(bob);

        account::create_account_for_test(bob_address);

        let aptos_to_mint = 100000000000000;

        degenfun::main::register_and_mint(dev,aptos_to_mint);

        degenfun::main::register_and_mint(bob,aptos_to_mint);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 200000000;

        degenfun::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));

        let shares_to_buy1 = 30;
        degenfun::main::buy_share<U0,U1>(bob,share_subject,shares_to_buy1,1000000000);
        
        let shares_to_buy2 = 30;
        //threshold reach here
        degenfun::main::buy_share<U0,U1>(bob,share_subject,shares_to_buy2,1000000000);

        let coin_x_liquidity = ((1 + shares_to_buy1 + shares_to_buy2) * 10) * APTOS;

        let coin_y_liquidity = (degenfun::main::get_price(1,(shares_to_buy1 + shares_to_buy2)));

        let (balance_y, balance_x) = pancake::swap::token_balances<AptosCoin,DegenFunCoin<U0,U1>>();

        let share_subject_account_lp_balance = coin::balance<LPToken<AptosCoin,DegenFunCoin<U0,U1>>>(share_subject);
       
        let share_subject_account_suppose_lp_balance = pancake::math::sqrt(((coin_x_liquidity as u128) * (coin_y_liquidity as u128))) - 1000;
   
        assert!(balance_x == coin_x_liquidity, 0x12);
        assert!(balance_y == coin_y_liquidity, 0x13);
        assert!(share_subject_account_lp_balance == (share_subject_account_suppose_lp_balance as u64), 0x13);

    }   
    //End buy share test cases


    //Start sell share test case
    #[test(dev = @devaddress,bob = @0x2121, resource_account = @degenfun,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    fun test_sell_share(dev:&signer,bob:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        let bob_address = signer::address_of(bob);

        account::create_account_for_test(bob_address);

        let aptos_to_mint = 100000000000000;

        degenfun::main::register_and_mint(dev,aptos_to_mint);

        degenfun::main::register_and_mint(bob,aptos_to_mint);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degenfun::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));

        let shares_to_buy = 10;
        degenfun::main::buy_share<U0,U1>(bob,share_subject,shares_to_buy,1000000000);

        let bob_share_balance_before = degenfun::main::get_share_balance<U0,U1>(signer::address_of(bob),share_subject);
        let bob_aptos_balance_before = coin::balance<AptosCoin>(bob_address);
        let share_subject_aptos_balance_before = coin::balance<AptosCoin>(share_subject);

        let shares_to_sell = 5;
        let sell_price = degenfun::main::get_sell_price<U0,U1>(share_subject,shares_to_sell);
        degenfun::main::sell_shares<U0,U1>(bob,share_subject,shares_to_sell,0);

        let bob_share_balance_after = degenfun::main::get_share_balance<U0,U1>(signer::address_of(bob),share_subject);
        let bob_aptos_balance_after = coin::balance<AptosCoin>(bob_address);
        let share_subject_aptos_balance_after = coin::balance<AptosCoin>(share_subject);


        assert!((bob_share_balance_before - shares_to_sell) == bob_share_balance_after, 0x14);
        assert!((bob_aptos_balance_after - bob_aptos_balance_before) == sell_price, 0x15);
        assert!((share_subject_aptos_balance_before - share_subject_aptos_balance_after) == sell_price, 0x16);

    } 
     #[test(dev = @devaddress,bob = @0x2121, resource_account = @degenfun,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    #[expected_failure(abort_code = 1,location = degenfun::main)]
    fun test_sell_share_with_wrong_share_subject(dev:&signer,bob:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        let bob_address = signer::address_of(bob);

        account::create_account_for_test(bob_address);

        let aptos_to_mint = 100000000000000;

        degenfun::main::register_and_mint(dev,aptos_to_mint);

        degenfun::main::register_and_mint(bob,aptos_to_mint);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 10000000000;

        degenfun::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));

        let shares_to_buy = 1;
        degenfun::main::buy_share<U0,U1>(bob,share_subject,shares_to_buy,1000000000);

        let shares_to_sell = 1;
        //here we trying to sell share with wrong share address
        degenfun::main::sell_shares<U0,U1>(bob,@0x1010,shares_to_sell,0);
    }

    #[test(dev = @devaddress,bob = @0x2121, resource_account = @degenfun,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    #[expected_failure(abort_code = 8,location = degenfun::main)]
    fun test_sell_share_after_threshold_reached(dev:&signer,bob:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        let bob_address = signer::address_of(bob);

        account::create_account_for_test(bob_address);

        let aptos_to_mint = 100000000000000;

        degenfun::main::register_and_mint(dev,aptos_to_mint);

        degenfun::main::register_and_mint(bob,aptos_to_mint);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 200000000;

        degenfun::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));

        let shares_to_buy1 = 30;
        degenfun::main::buy_share<U0,U1>(bob,share_subject,shares_to_buy1,1000000000);
        
        let shares_to_buy2 = 30;
        degenfun::main::buy_share<U0,U1>(bob,share_subject,shares_to_buy2,1000000000);

        
        let shares_to_sell = 10;
        //threshold is already reached in above transaction
        degenfun::main::sell_shares<U0,U1>(bob,share_subject,shares_to_sell,0);
    }

    #[test(dev = @devaddress,bob = @0x2121, resource_account = @degenfun,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    #[expected_failure(abort_code = 4,location = degenfun::main)]
    fun test_sell_share_sell_last_share(dev:&signer,bob:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        let bob_address = signer::address_of(bob);

        account::create_account_for_test(bob_address);

        let aptos_to_mint = 100000000000000;

        degenfun::main::register_and_mint(dev,aptos_to_mint);

        degenfun::main::register_and_mint(bob,aptos_to_mint);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 200000000;

        degenfun::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));

        let shares_to_buy = 1;
        degenfun::main::buy_share<U0,U1>(bob,share_subject,shares_to_buy,1000000000);

        let shares_to_sell = 1;
        degenfun::main::sell_shares<U0,U1>(dev,share_subject,shares_to_sell,0);

        let shares_to_sell1 = 1;
        //here bob trying to sell last share
        degenfun::main::sell_shares<U0,U1>(bob,share_subject,shares_to_sell1,0);

    }

    #[test(dev = @devaddress,bob = @0x2121, resource_account = @degenfun,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    #[expected_failure(abort_code = 5,location = degenfun::main)]
    fun test_sell_share_with_low_share_balance(dev:&signer,bob:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        let bob_address = signer::address_of(bob);

        account::create_account_for_test(bob_address);

        let aptos_to_mint = 100000000000000;

        degenfun::main::register_and_mint(dev,aptos_to_mint);

        degenfun::main::register_and_mint(bob,aptos_to_mint);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 200000000;

        degenfun::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));

        let shares_to_buy = 10;
        degenfun::main::buy_share<U0,U1>(dev,share_subject,shares_to_buy,1000000000);

        let shares_to_buy1 = 1;
        degenfun::main::buy_share<U0,U1>(bob,share_subject,shares_to_buy1,1000000000);

        let shares_to_sell1 = 1;
        degenfun::main::sell_shares<U0,U1>(bob,share_subject,shares_to_sell1,0);

        let shares_to_sell2 = 1;
        degenfun::main::sell_shares<U0,U1>(bob,share_subject,shares_to_sell2,0);

    }

    #[test(dev = @devaddress,bob = @0x2121, resource_account = @degenfun,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    #[expected_failure(abort_code = 10,location = degenfun::main)]
    fun test_sell_share_slippage_check(dev:&signer,bob:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        let bob_address = signer::address_of(bob);

        account::create_account_for_test(bob_address);

        let aptos_to_mint = 100000000000000;

        degenfun::main::register_and_mint(dev,aptos_to_mint);

        degenfun::main::register_and_mint(bob,aptos_to_mint);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 200000000;

        degenfun::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));

        let shares_to_buy = 10;
        degenfun::main::buy_share<U0,U1>(bob,share_subject,shares_to_buy,1000000000);

        let shares_to_sell = 5;
        degenfun::main::sell_shares<U0,U1>(bob,share_subject,shares_to_sell,10000000000);

    }

    #[test(dev = @devaddress,bob = @0x2121, resource_account = @degenfun,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    #[expected_failure(abort_code = 3,location = degenfun::main)]
    fun test_sell_share_with_low_aptos_balance(dev:&signer,bob:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        let bob_address = signer::address_of(bob);

        account::create_account_for_test(bob_address);

        let aptos_to_mint = 100000000000000;

        degenfun::main::register_and_mint(dev,aptos_to_mint);

        degenfun::main::register_and_mint(bob,6874);

        let protocol_fee = 5000000;
        let subject_fee = 5000000;

        degenfun::main::set_protocol_fee_percent(dev,protocol_fee);

        degenfun::main::set_subject_fee_percent(dev,subject_fee);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 200000000;

        degenfun::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));

        let shares_to_buy = 1;
        degenfun::main::buy_share<U0,U1>(bob,share_subject,shares_to_buy,1000000000);


        let shares_to_sell = 1;
        degenfun::main::sell_shares<U0,U1>(bob,share_subject,shares_to_sell,0);

    }
    //End sell share test case


    //Start claim token test case
    #[test(dev = @devaddress,bob = @0x2121, resource_account = @degenfun,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    fun test_claim_token(dev:&signer,bob:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        let bob_address = signer::address_of(bob);

        account::create_account_for_test(bob_address);

        let aptos_to_mint = 100000000000000;

        degenfun::main::register_and_mint(dev,aptos_to_mint);

        degenfun::main::register_and_mint(bob,aptos_to_mint);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 200000000;

        degenfun::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));

        let shares_to_buy1 = 30;
        degenfun::main::buy_share<U0,U1>(bob,share_subject,shares_to_buy1,1000000000);
        
        let shares_to_buy2 = 30;
        degenfun::main::buy_share<U0,U1>(bob,share_subject,shares_to_buy2,1000000000);

        degenfun::main::register_coin<U0,U1>(bob);

        let bob_share_token_balance_before = coin::balance<DegenFunCoin<U0,U1>>(bob_address);
        let bob_suppose_share_token_balance_after = ((shares_to_buy1 + shares_to_buy2) * 10) * APTOS;
        
        degenfun::main::claim_token<U0,U1>(bob,share_subject);

        let bob_share_token_balance_after = coin::balance<DegenFunCoin<U0,U1>>(bob_address);

        assert!(bob_share_token_balance_before == 0, 0x17);
        assert!(bob_share_token_balance_after == bob_suppose_share_token_balance_after, 0x18);

    }

    #[test(dev = @devaddress,bob = @0x2121, resource_account = @degenfun,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    #[expected_failure(abort_code = 1,location = degenfun::main)]
    fun test_claim_token_with_wrong_share_subject(dev:&signer,bob:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        let bob_address = signer::address_of(bob);

        account::create_account_for_test(bob_address);

        let aptos_to_mint = 100000000000000;

        degenfun::main::register_and_mint(dev,aptos_to_mint);

        degenfun::main::register_and_mint(bob,aptos_to_mint);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 200000000;

        degenfun::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));

        let shares_to_buy1 = 30;
        degenfun::main::buy_share<U0,U1>(bob,share_subject,shares_to_buy1,1000000000);
        
        let shares_to_buy2 = 30;
        degenfun::main::buy_share<U0,U1>(bob,share_subject,shares_to_buy2,1000000000);
        
        degenfun::main::claim_token<U0,U1>(bob,@0x1011);

    }

    #[test(dev = @devaddress,bob = @0x2121, resource_account = @degenfun,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    #[expected_failure(abort_code = 14,location = degenfun::main)]
    fun test_claim_token_before_clamming_start(dev:&signer,bob:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        let bob_address = signer::address_of(bob);

        account::create_account_for_test(bob_address);

        let aptos_to_mint = 100000000000000;

        degenfun::main::register_and_mint(dev,aptos_to_mint);

        degenfun::main::register_and_mint(bob,aptos_to_mint);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 200000000;

        degenfun::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));

        let shares_to_buy1 = 30;
        degenfun::main::buy_share<U0,U1>(bob,share_subject,shares_to_buy1,1000000000);
        
        let shares_to_buy2 = 10;
        degenfun::main::buy_share<U0,U1>(bob,share_subject,shares_to_buy2,1000000000);
        
        degenfun::main::claim_token<U0,U1>(bob,share_subject);

    }

    #[test(dev = @devaddress,bob = @0x2121, resource_account = @degenfun,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    #[expected_failure(abort_code = 5,location = degenfun::main)]
    fun test_claim_token_with_low_share_balance(dev:&signer,bob:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){
        
        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);

        let bob_address = signer::address_of(bob);

        account::create_account_for_test(bob_address);

        let aptos_to_mint = 100000000000000;

        degenfun::main::register_and_mint(dev,aptos_to_mint);

        degenfun::main::register_and_mint(bob,aptos_to_mint);

        let token_name = string::utf8(b"DegenCoin");
        let token_symbol = string::utf8(b"DGC");
        let threshold = 200000000;

        degenfun::main::create_share<U0,U1>(dev,token_name,token_symbol,threshold);

        let seeds = get_seeds(token_name);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&seeds));

        let shares_to_buy1 = 30;
        degenfun::main::buy_share<U0,U1>(bob,share_subject,shares_to_buy1,1000000000);
        
        let shares_to_buy2 = 30;
        degenfun::main::buy_share<U0,U1>(bob,share_subject,shares_to_buy2,1000000000);
        
        degenfun::main::claim_token<U0,U1>(bob,share_subject);

        degenfun::main::claim_token<U0,U1>(bob,share_subject);

    }
    //End claim token test cases





}