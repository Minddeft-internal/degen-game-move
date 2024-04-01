module degengame::main{


    use aptos_framework::account;
    use aptos_framework::table;
    use aptos_framework::resource_account;
    use aptos_framework::signer;
    use aptos_framework::coin::{Self,BurnCapability, MintCapability,FreezeCapability};
    use aptos_framework::aptos_coin::{AptosCoin};
    use aptos_framework::string::{Self};
    use aptos_framework::event::{Self};


    //ERRORS 
    const ERROR_NOT_ADMIN:u64 = 0;
    const ERROR_SHARES_SUBJECT_NOT_EXIST:u64 = 1;
    const ERROR_ONLY_SHARE_SUBJECT_BUY_FIRST_SHARE:u64 = 2;
    const ERROR_INSUFFICIENT_PAYMENT:u64 = 3;
    const ERROR_CANNOT_SELL_THE_LAST_SHARE:u64 = 4;
    const ERROR_INSUFFICIENT_SHARES:u64 = 5;
    const ERROR_NOT_PROTOCOL_FEE_DESTINATION:u64 = 6;
    const ERROR_TOKEN_ALREADY_EXIST_FOR_THIS_NAME:u64 = 7;
    const ERROR_BUYING_IS_DISABLE:u64 = 8;

    const DEV:address = @devaddress;
    const RESOURCE_ACCOUNT:address = @degengame;

    const APTOS:u64 = 100000000;

    struct Coin<phantom ShareAddress> {

    }

    struct ShareMetaData has key {
        signer_cap:account::SignerCapability,
        token_name:string::String,
        token_symbol:string::String,
        share_owner:address,
        share_address:address,
        share_balance:table::Table<address,u64>,
        share_supply:u64,
        threshold:u64,
        is_reached_threshold:bool,
        aptos_balance:coin::Coin<AptosCoin>
    }

    struct ShareTokenCap<phantom ShareAddress> has key{
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
        collected_protocol_fees:coin::Coin<AptosCoin>,
        create_token_event:event::EventHandle<CreateTokenEvent>
    }

    struct CreateTokenEvent has copy,store,drop{
        share_address:address,
        token_owner:address,
        threshold:u64,
        token_name:string::String,
        token_symbol:string::String,
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
            collected_protocol_fees:coin::zero<AptosCoin>(),
            create_token_event:account::new_event_handle<CreateTokenEvent>(sender)
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

    public fun get_price(supply:u64,amount:u64):u64{

        let sum1 =  if(supply == 0) {
            0
        }else{
            (supply - 1 )* (supply) * (2 * (supply - 1) + 1) / 6
        };

        let sum2 =  if(supply == 0 && amount == 1) {
            0
        }else{
            (supply - 1 + amount) * (supply + amount) * (2 * (supply - 1 + amount) + 1) / 6
        };

        let summation = sum2 - sum1;

        summation * APTOS / 16000

    }

    #[view]
    public fun get_buy_price(share_subject:address,amount:u64):u64 acquires ShareMetaData{

        //check whether subject account already exist or not
        assert!(exists<ShareMetaData>(share_subject), ERROR_SHARES_SUBJECT_NOT_EXIST);

        let share_meta_data = borrow_global<ShareMetaData>(share_subject);

        let supply = share_meta_data.share_supply;

        get_price(supply,amount)
    }

    #[view]
    public fun get_sell_price(share_subject:address,amount:u64):u64 acquires ShareMetaData{
        
        //check whether subject account already exist or not
        assert!(exists<ShareMetaData>(share_subject), ERROR_SHARES_SUBJECT_NOT_EXIST);

        let share_meta_data = borrow_global<ShareMetaData>(share_subject);

        let supply = share_meta_data.share_supply;

        get_price(supply - amount,amount)
    }



    public entry fun create_share(sender:&signer,token_name:string::String,token_symbol:string::String,threshold:u64)acquires DataStorage,ShareMetaData {
        
        let sender_address = signer::address_of(sender); 

        let resource_address = account::create_resource_address(&sender_address,*string::bytes(&token_name));

        assert!(!account::exists_at(resource_address), ERROR_TOKEN_ALREADY_EXIST_FOR_THIS_NAME);

        let (resource_signer, signer_cap) = account::create_resource_account(sender,*string::bytes(&token_name));

        move_to<ShareMetaData>(&resource_signer,ShareMetaData{
            signer_cap:signer_cap,
            token_name:token_name,
            token_symbol:token_symbol,
            share_owner:sender_address,
            share_address:signer::address_of(&resource_signer),
            share_balance:table::new<address,u64>(),
            share_supply:0,
            threshold:threshold,
            is_reached_threshold:false,
            aptos_balance:coin::zero<AptosCoin>()
        });

        //Buy 1 share when create new share subject
        buy_share_internal(sender,signer::address_of(&resource_signer),1);

        let datastorage = borrow_global_mut<DataStorage>(RESOURCE_ACCOUNT);

        event::emit_event(&mut datastorage.create_token_event,CreateTokenEvent{
            share_address:signer::address_of(&resource_signer),
            token_owner:signer::address_of(sender),
            threshold:threshold,
            token_name:token_name,
            token_symbol:token_symbol,
        });
       
    }

    fun buy_share_internal(sender:&signer,share_subject:address,amount:u64)acquires DataStorage,ShareMetaData{

        let sender_address = signer::address_of(sender);

        //register aptos if it's not register
        register_aptos(sender);

        //check whether subject account already exist or not
        assert!(exists<ShareMetaData>(share_subject), ERROR_SHARES_SUBJECT_NOT_EXIST);

        let share_meta_data = borrow_global_mut<ShareMetaData>(share_subject);

        //check whether curve is disable or not
        assert!(!share_meta_data.is_reached_threshold, ERROR_BUYING_IS_DISABLE);

        let datastorage = borrow_global_mut<DataStorage>(RESOURCE_ACCOUNT);

        let price = get_price(share_meta_data.share_supply, amount);

        let protocol_fee = price * datastorage.protocol_fee_percent / APTOS;

        let subject_fee = price * datastorage.subject_fee_percent / APTOS;

        let aptos_balance = coin::balance<AptosCoin>(sender_address);

        //checking user have enough aptos for this transaction
        assert!(aptos_balance >= price + protocol_fee + subject_fee, ERROR_INSUFFICIENT_PAYMENT);

        let share_balance = table::borrow_mut_with_default(&mut share_meta_data.share_balance,sender_address,0);

        *share_balance = *share_balance + amount;

        share_meta_data.share_supply = share_meta_data.share_supply + amount;


        //Deposit price amount to pool
        let price_amount = coin::withdraw<AptosCoin>(sender,price);
        coin::merge(&mut share_meta_data.aptos_balance,price_amount);

        //Deposit protocol fees amount to pool
        let protocol_fee_amount = coin::withdraw<AptosCoin>(sender,protocol_fee);
        coin::merge(&mut datastorage.collected_protocol_fees,protocol_fee_amount);

        //Transfer subject fees to owner
        coin::transfer<AptosCoin>(sender,share_meta_data.share_owner,subject_fee);
       
    }

    fun check_is_threshold_reached(){

    }

    fun register_aptos(sender:&signer){

        let sender_address = signer::address_of(sender);

        // Auto register aptos
        if (!coin::is_account_registered<AptosCoin>(sender_address)) {
            coin::register<AptosCoin>(sender);
        };
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