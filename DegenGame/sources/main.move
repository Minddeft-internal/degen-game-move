module degengame::main{


    use aptos_framework::account;
    use aptos_framework::table;
    use aptos_framework::resource_account;
    use aptos_framework::signer;
    use aptos_framework::coin::{Self,BurnCapability, MintCapability,FreezeCapability};
    use aptos_framework::aptos_coin::{AptosCoin};
    use aptos_framework::string;


    //ERRORS 
    const ERROR_NOT_ADMIN:u64 = 0;
    const ERROR_SHARES_SUPPLY_NOT_EXIST:u64 = 1;
    const ERROR_ONLY_SHARE_SUBJECT_BUY_FIRST_SHARE:u64 = 2;
    const ERROR_INSUFFICIENT_PAYMENT:u64 = 3;
    const ERROR_CANNOT_SELL_THE_LAST_SHARE:u64 = 4;
    const ERROR_INSUFFICIENT_SHARES:u64 = 5;
    const ERROR_NOT_PROTOCOL_FEE_DESTINATION:u64 = 6;

    const DEV:address = @devaddress;
    const RESOURCE_ACCOUNT:address = @degengame;

    const APTOS:u64 = 100000000;

    struct Coin<phantom ShareAddress> {

    }

    struct ShareMetaData<phantom ShareAddress> has key,store {
        token_address:address,
        token_owner:string::String,
        share_balance:table::Table<address,u64>,
        share_supply:u64,
        threshold:u64,
        is_reached_threshold:bool,
        mint_capability:MintCapability<Coin<ShareAddress>>,
        burn_capability:BurnCapability<Coin<ShareAddress>>,
        freeze_capability:FreezeCapability<Coin<ShareAddress>>,
    }

     struct DataStorage has key,store {
        signer_cap:account::SignerCapability,
        owner:address,
        protocol_fee_destination:address,
        protocol_fee_percent:u64,
        subject_fee_percent:u64,
        shares_balance:table::Table<address,table::Table<address,u64>>,
        shares_supply:table::Table<address,u64>,
        shares_threshold:table::Table<address,u64>,
        collected_protocol_fees:coin::Coin<AptosCoin>
    }
    
    fun init_module(sender:&signer) {
        
        let signer_cap = resource_account::retrieve_resource_account_cap(sender,DEV);

        let resource_signer = account::create_signer_with_capability(&signer_cap);

        move_to(&resource_signer,DataStorage{
            signer_cap:signer_cap,
            owner:DEV,
            protocol_fee_destination:@0x0,
            protocol_fee_percent:0,
            subject_fee_percent:0,
            shares_balance:table::new<address,table::Table<address,u64>>(),
            shares_supply:table::new<address,u64>(),
            shares_threshold:table::new<address,u64>(),
            collected_protocol_fees:coin::zero<AptosCoin>(),
        })

    }

    fun is_owner(sender:&signer)acquires DataStorage{
        let datastorage = borrow_global<DataStorage>(RESOURCE_ACCOUNT);
        assert!(datastorage.owner == signer::address_of(sender), ERROR_NOT_ADMIN);
    }

    fun is_protocol_fee_destination(sender:&signer)acquires DataStorage{
        let datastorage = borrow_global<DataStorage>(RESOURCE_ACCOUNT);
        assert!(datastorage.protocol_fee_destination == signer::address_of(sender), ERROR_NOT_PROTOCOL_FEE_DESTINATION);
    }


    public entry fun set_fee_destination(sender:&signer,fee_destination:address)acquires DataStorage{
        //Check whether caller is owner or not
        is_owner(sender);

        let datastorage = borrow_global_mut<DataStorage>(RESOURCE_ACCOUNT);
        
        datastorage.protocol_fee_destination = fee_destination;
        
    }

    public entry fun set_protocol_fee_percent(sender:&signer,fee_percent:u64) acquires DataStorage{
        //Check whether caller is owner or not
        is_owner(sender);

        let datastorage = borrow_global_mut<DataStorage>(RESOURCE_ACCOUNT);
        
        datastorage.protocol_fee_percent = fee_percent;
    }

    public entry fun set_subject_fee_percent(sender:&signer,fee_percent:u64) acquires DataStorage{
        
        //Check whether caller is owner or not
        is_owner(sender);

        let datastorage = borrow_global_mut<DataStorage>(RESOURCE_ACCOUNT);
        
        datastorage.subject_fee_percent = fee_percent;
    }



    #[test_only]
    use aptos_framework::managed_coin;

    #[test_only]
    use aptos_framework::aptos_coin;
    
    #[test_only]
    struct TestCap has key{
        mint_cap:MintCapability<AptosCoin>,
        burn_cap:BurnCapability<AptosCoin>
    }

    #[test_only]
    public fun initialize(sender: &signer) {
        init_module(sender);
    }

    #[test_only]
    public fun create_aptos_token_for_test(aptos_framework:signer)acquires DataStorage {

        let datastorage = borrow_global_mut<DataStorage>(RESOURCE_ACCOUNT);
        let resource_signer = account::create_signer_with_capability(&datastorage.signer_cap);

        let (burn_cap,mint_cap) = 0x1::aptos_coin::initialize_for_test_without_aggregator_factory(&aptos_framework);
        
        move_to(&resource_signer,TestCap{
            mint_cap:mint_cap,
            burn_cap:burn_cap
        });

    }

    #[test_only]
    public fun register_and_mint(to: &signer, amount: u64)acquires TestCap{
    
        let testcap = borrow_global_mut<TestCap>(RESOURCE_ACCOUNT);
        
        managed_coin::register<AptosCoin>(to);

        let coins = coin::mint(amount, &testcap.mint_cap);

        coin::deposit<AptosCoin>(signer::address_of(to), coins);
    }

    #[test_only]
    public fun register(to: &signer) {
        managed_coin::register<AptosCoin>(to);
    }

    #[test_only]
    public fun aptos_balance(to:address):u64 {
        coin::balance<AptosCoin>(to)
    }



    #[test_only]
    public fun get_data():(address,u64,u64,u64) acquires DataStorage{

        let datastorage = borrow_global<DataStorage>(RESOURCE_ACCOUNT);

        (datastorage.protocol_fee_destination,datastorage.protocol_fee_percent,datastorage.subject_fee_percent,coin::value(&datastorage.collected_protocol_fees))

    }

}