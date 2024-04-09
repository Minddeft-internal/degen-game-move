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

    #[test(dev = @devaddress, resource_account = @degengame,feedes=@0x123)]
    fun test_initialize(dev:&signer,resource_account:&signer,feedes:&signer){
        setup_test_with_genesis(dev,resource_account,feedes);
    }

    #[test(dev = @devaddress, resource_account = @degengame,feedes=@0x123,pancakedev=@0xf8982b6548429f48311ea5e4bfe9e4f8e2c1b5d7ffa078bab448d76a7a928581,pancakeadmin=@0xe9e7d98ad629e8d24606a61f4421d1d775e431717a31866788e8e0dcda78a0eb,pancakeresource=@0x274414d1f2b98c47201977edfaeddebb81db2a25885234421c67e8507336f917,pancaketeasury=@0x5432)]
    fun test_create_token(dev:&signer,resource_account:&signer,feedes:&signer,pancakedev:&signer,pancakeadmin:&signer,pancakeresource:&signer,pancaketeasury:&signer){

        pancake::swap_test::setup_test_with_genesis(pancakedev,pancakeadmin,pancaketeasury,pancakeresource);
        
        setup_test_with_genesis_for_pancake(dev,resource_account,feedes);


        degengame::main::set_protocol_fee_percent(dev,50000);
        degengame::main::set_subject_fee_percent(dev,50000);

        degengame::main::register_and_mint(dev,100000000000000);

        degengame::main::create_share<U0,U1>(dev,string::utf8(b"Test"),string::utf8(b"TSC"),200000000);

        let share_subject = account::create_resource_address(&signer::address_of(dev),*string::bytes(&string::utf8(b"Test")));

        // debug::print(&share_subject);

        degengame::main::buy_share<U0,U1>(dev,share_subject,10,10000000000000);
        degengame::main::buy_share<U0,U1>(dev,share_subject,10,10000000000000);
        degengame::main::buy_share<U0,U1>(dev,share_subject,10,10000000000000);
        degengame::main::buy_share<U0,U1>(dev,share_subject,20,10000000000000);

        degengame::main::claim_token<U0,U1>(dev,share_subject);

        // aptos_framework::debug::print(&coin::balance<DegenGameCoin<U0,U1>>(signer::address_of(dev)));
        
        // degengame::main::buy_share<U0,U1>(dev,share_subject,100,10000000000000);


        // degengame::main::buy_share(dev,share_subject,100,10000000000000);
        // degengame::main::buy_share(dev,share_subject,1,100000000);

        // degengame::main::sell_shares(dev,share_subject,10,0);
        // degengame::main::sell_shares(dev,share_subject,10,0);
        // degengame::main::sell_shares(dev,share_subject,10,0);
        // degengame::main::buy_share(dev,share_subject,50);
        // degengame::main::buy_share(dev,share_subject,50);

        // degengame::main::create_share(dev,string::utf8(b"Test1"),string::utf8(b"TSC"),100,1);
    }



}