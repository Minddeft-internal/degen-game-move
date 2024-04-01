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

    const APTOS:u64 = 100000000;

    struct Coins<phantom Name> {

    }


    public fun setup_test_with_genesis(dev: &signer, resource_account: &signer,feedes:&signer) {
        genesis::setup();
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

    #[test(dev = @devaddress, resource_account = @degengame,feedes=@0x123)]
    fun test_create_token(dev:&signer,resource_account:&signer,feedes:&signer){
        setup_test_with_genesis(dev,resource_account,feedes);

        degengame::main::set_protocol_fee_percent(dev,50000);
        degengame::main::set_subject_fee_percent(dev,50000);

        degengame::main::create_share(dev,string::utf8(b"Test"),string::utf8(b"TSC"),100,1);

        // degengame::main::create_share(dev,string::utf8(b"Test1"),string::utf8(b"TSC"),100,1);
    }



}