module degengame::main{

    use aptos_framework::account;
    use aptos_framework::table;
    use aptos_framework::resource_account;
    use aptos_framework::signer;
    use aptos_framework::coin::{Self,BurnCapability, MintCapability,FreezeCapability};
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::string::{Self};
    use aptos_framework::event::{Self};
    use aptos_framework::string_utils::to_string;


    //ERRORS 
    const ERROR_NOT_OWNER:u64 = 0;
    const ERROR_SHARES_SUBJECT_NOT_EXIST:u64 = 1;
    const ERROR_ONLY_SHARE_SUBJECT_BUY_FIRST_SHARE:u64 = 2;
    const ERROR_INSUFFICIENT_PAYMENT:u64 = 3;
    const ERROR_CANNOT_SELL_THE_LAST_SHARE:u64 = 4;
    const ERROR_INSUFFICIENT_SHARES:u64 = 5;
    const ERROR_NOT_PROTOCOL_FEE_DESTINATION:u64 = 6;
    const ERROR_TOKEN_ALREADY_EXIST_FOR_THIS_NAME:u64 = 7;
    const ERROR_CURVE_IS_DISABLE:u64 = 8;
    const ERROR_INSUFFICIENT_MAX_IN_AMOUNT:u64 = 9;
    const ERROR_INSUFFICIENT_MIN_OUT_AMOUNT:u64 = 10;
    const ERROR_ZERO_FEES_COLLECTED_IN_VAULT:u64 = 11;
    const ERROR_ZERO_ACCOUNT:u64 = 12;
    const ERROR_NO_CHANGES_DETECTED:u64 = 13;
    const ERROR_CLAIMING_IS_NOT_STARTED_YET:u64 = 14;

    const DEV:address = @devaddress;
    const RESOURCE_ACCOUNT:address = @degengame;

    const APTOS:u64 = 100000000;

    struct DegenGameCoin<phantom UID1,phantom UID2> has key{
     
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

    struct ShareTokenCap<phantom UID1,phantom UID2> has key{
        mint_capability:MintCapability<DegenGameCoin<UID1,UID2>>,
        burn_capability:BurnCapability<DegenGameCoin<UID1,UID2>>,
        freeze_capability:FreezeCapability<DegenGameCoin<UID1,UID2>>,
    }

    struct DataStorage has key,store {
        signer_cap:account::SignerCapability,
        owner:address,
        protocol_fee_destination:address,
        protocol_fee_percent:u64,
        subject_fee_percent:u64,
        collected_protocol_fees:coin::Coin<AptosCoin>,
        create_share_event:event::EventHandle<CreateShareEvent>,
        buy_share_event:event::EventHandle<BuyShareEvent>,
        sell_share_event:event::EventHandle<SellShareEvent>,
        set_fee_destination_event:event::EventHandle<SetFeeDestinationEvent>,
        set_protocol_fee_percent_event:event::EventHandle<SetProtocolFeePercentEvent>,
        set_subject_fee_percent_event:event::EventHandle<SetSubjectFeePercentEvent>,
        collect_protocol_fees_event:event::EventHandle<CollectProtocolFeesEvent>,
        add_liquidity_to_pancake_event:event::EventHandle<AddLiquidityToPancakeEvent>,
        claim_token_event:event::EventHandle<ClaimTokenEvent>
    }

    struct SetFeeDestinationEvent has copy,store,drop{
        old_fee_destination:address,
        new_fee_destination:address,
    }

    struct SetProtocolFeePercentEvent has copy,store,drop{
        old_fee_percent:u64,
        new_fee_percent:u64,
    }

    struct SetSubjectFeePercentEvent has copy,store,drop{
        old_fee_percent:u64,
        new_fee_percent:u64,
    }

    struct CollectProtocolFeesEvent has copy,store,drop{
        fee_destination:address,
        collected_fees_amount:u64,
    }

    struct CreateShareEvent has copy,store,drop{
        share_address:address,
        token_owner:address,
        threshold:u64,
        token_name:string::String,
        token_symbol:string::String,
    }

    struct BuyShareEvent has copy,store,drop{
        share_address:address,
        amount:u64,
        price:u64,
        protocol_fee:u64,
        subject_fee:u64,
    } 

    struct SellShareEvent has copy,store,drop{
        share_address:address,
        amount:u64,
        price:u64,
        protocol_fee:u64,
        subject_fee:u64,
    } 

    struct AddLiquidityToPancakeEvent has copy,store,drop{
        share_address:address,
        coin_x:u64,
        coin_y:u64,
    }  

    struct ClaimTokenEvent has copy,store,drop{
        share_address:address,
        sender:address,
        claim_amount:u64,
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
            create_share_event:account::new_event_handle<CreateShareEvent>(sender),
            buy_share_event:account::new_event_handle<BuyShareEvent>(sender),
            sell_share_event:account::new_event_handle<SellShareEvent>(sender),
            set_fee_destination_event:account::new_event_handle<SetFeeDestinationEvent>(sender),
            set_protocol_fee_percent_event:account::new_event_handle<SetProtocolFeePercentEvent>(sender),
            set_subject_fee_percent_event:account::new_event_handle<SetSubjectFeePercentEvent>(sender),
            collect_protocol_fees_event:account::new_event_handle<CollectProtocolFeesEvent>(sender),
            add_liquidity_to_pancake_event:account::new_event_handle<AddLiquidityToPancakeEvent>(sender),
            claim_token_event:account::new_event_handle<ClaimTokenEvent>(sender),
        })

    }

    public entry fun set_fee_destination(sender:&signer,fee_destination:address)acquires DataStorage{
        
        //Check whether caller is owner or not
        is_owner(sender);

        is_zero_address(fee_destination);

        let datastorage = borrow_global_mut<DataStorage>(RESOURCE_ACCOUNT);

        let old_fee_destination = datastorage.protocol_fee_destination;
        
        datastorage.protocol_fee_destination = fee_destination;

        event::emit_event(&mut datastorage.set_fee_destination_event,SetFeeDestinationEvent{
            old_fee_destination:old_fee_destination,
            new_fee_destination:fee_destination,
        });
        
    }

    public entry fun set_protocol_fee_percent(sender:&signer,fee_percent:u64) acquires DataStorage{
        
        //Check whether caller is owner or not
        is_owner(sender);

        let datastorage = borrow_global_mut<DataStorage>(RESOURCE_ACCOUNT);

        let old_fee_percent = datastorage.protocol_fee_percent;

        assert!(fee_percent != old_fee_percent, ERROR_NO_CHANGES_DETECTED);
        
        datastorage.protocol_fee_percent = fee_percent;

        event::emit_event(&mut datastorage.set_protocol_fee_percent_event,SetProtocolFeePercentEvent{
            old_fee_percent:old_fee_percent,
            new_fee_percent:fee_percent,
        });
    }

    public entry fun set_subject_fee_percent(sender:&signer,fee_percent:u64) acquires DataStorage{
        
        //Check whether caller is owner or not
        is_owner(sender);

        let datastorage = borrow_global_mut<DataStorage>(RESOURCE_ACCOUNT);

        let old_fee_percent = datastorage.subject_fee_percent;

        assert!(fee_percent != old_fee_percent, ERROR_NO_CHANGES_DETECTED);
        
        datastorage.subject_fee_percent = fee_percent;

        event::emit_event(&mut datastorage.set_protocol_fee_percent_event,SetProtocolFeePercentEvent{
            old_fee_percent:old_fee_percent,
            new_fee_percent:fee_percent,
        });
    }

    public entry fun collect_protocol_fees(sender:&signer)acquires DataStorage{

        is_protocol_fee_destination(sender);

        register_aptos(sender);

        let datastorage = borrow_global_mut<DataStorage>(RESOURCE_ACCOUNT);

        let collected_protocol_fees = coin::extract_all(&mut datastorage.collected_protocol_fees);

        let collected_fees_amount = coin::value<AptosCoin>(&collected_protocol_fees);

        assert!(collected_fees_amount > 0, ERROR_ZERO_FEES_COLLECTED_IN_VAULT);

        coin::deposit(signer::address_of(sender),collected_protocol_fees);

        event::emit_event(&mut datastorage.collect_protocol_fees_event,CollectProtocolFeesEvent{
            fee_destination:signer::address_of(sender),
            collected_fees_amount:collected_fees_amount,
        });
        
    }

    public fun get_price(supply:u64,amount:u64):u64{

        let sum1 = if(supply == 0) 0 else (supply - 1 )* (supply) * (2 * (supply - 1) + 1) / 6 ;

        let sum2 = if(supply == 0 && amount == 1) 0 else (supply - 1 + amount) * (supply + amount) * (2 * (supply - 1 + amount) + 1) / 6 ;
        
        let summation = sum2 - sum1;

        summation * (APTOS / 16000)

    }

    #[view]
    public fun get_buy_price(share_subject:address,amount:u64):u64 acquires ShareMetaData{

        //check whether subject account already exist or not
        is_share_exist(share_subject);

        let share_meta_data = borrow_global<ShareMetaData>(share_subject);

        let supply = share_meta_data.share_supply;

        get_price(supply,amount)
    }

    #[view]
    public fun get_sell_price(share_subject:address,amount:u64):u64 acquires ShareMetaData{
        
        //check whether subject account already exist or not
        is_share_exist(share_subject);

        let share_meta_data = borrow_global<ShareMetaData>(share_subject);

        let supply = share_meta_data.share_supply;

        get_price(supply - amount,amount)
    }

    #[view]
    public fun get_buy_price_after_fee(share_subject:address,amount:u64):u64 acquires DataStorage,ShareMetaData {

        let price = get_buy_price(share_subject,amount);

        let datastorage = borrow_global<DataStorage>(RESOURCE_ACCOUNT);

        let protocol_fee = price * datastorage.protocol_fee_percent / APTOS;

        let subject_fee = price * datastorage.subject_fee_percent / APTOS;

        price + protocol_fee + subject_fee
    }

    #[view]
    public fun get_sell_price_after_fee(share_subject:address,amount:u64):u64 acquires DataStorage,ShareMetaData {
    
        let price = get_sell_price(share_subject,amount);
        
        let datastorage = borrow_global<DataStorage>(RESOURCE_ACCOUNT);

        let protocol_fee = price * datastorage.protocol_fee_percent / APTOS;

        let subject_fee = price * datastorage.subject_fee_percent / APTOS;

        price - protocol_fee - subject_fee

    }

    #[view]
    public fun get_share_balance(sender:&signer,share_subject:address):u64 acquires ShareMetaData {
    
        //check whether subject account already exist or not
        is_share_exist(share_subject);

        let sender_address = signer::address_of(sender);

        let share_meta_data = borrow_global<ShareMetaData>(share_subject);

        let balance = table::borrow_with_default(&share_meta_data.share_balance,sender_address,&0u64);

        *balance
    }   

    public entry fun create_share<UID1,UID2>(sender:&signer,token_name:string::String,token_symbol:string::String,threshold:u64)acquires DataStorage,ShareMetaData,ShareTokenCap {
        
        let sender_address = signer::address_of(sender);

        //Create unique seeds for all coins
        let seeds = get_seeds(token_name);

        let resource_address = account::create_resource_address(&sender_address,*string::bytes(&seeds));

        //Check whether the token name has already been taken by any user or not
        assert!(!account::exists_at(resource_address), ERROR_TOKEN_ALREADY_EXIST_FOR_THIS_NAME);

        let (resource_signer, signer_cap) = account::create_resource_account(sender,*string::bytes(&seeds));

        register_aptos(&resource_signer);

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

        //Create share token
        create_share_token<UID1,UID2>(&resource_signer,token_name,token_symbol);
    
        //Buy 1 share when create new share subject
        buy_share_internal<UID1,UID2>(sender,signer::address_of(&resource_signer),1);

        let datastorage = borrow_global_mut<DataStorage>(RESOURCE_ACCOUNT);

        event::emit_event(&mut datastorage.create_share_event,CreateShareEvent{
            share_address:signer::address_of(&resource_signer),
            token_owner:signer::address_of(sender),
            threshold:threshold,
            token_name:token_name,
            token_symbol:token_symbol,
        });
       
    }

    public entry fun buy_share<UID1,UID2>(sender:&signer,share_subject:address,amount:u64,max_in:u64)acquires DataStorage,ShareMetaData,ShareTokenCap{

        is_share_exist(share_subject);
        
        let price = buy_share_internal<UID1,UID2>(sender,share_subject,amount);

        assert!(price <= max_in,ERROR_INSUFFICIENT_MAX_IN_AMOUNT);
    }

    public entry fun sell_shares(sender:&signer,share_subject:address,amount:u64,min_out:u64)acquires DataStorage,ShareMetaData{

        //register aptos if it's not register
        register_aptos(sender);

        //check whether subject account already exist or not
        is_share_exist(share_subject);

        //check threshold reached or not
        is_threshold_reached(share_subject);

        let sender_address = signer::address_of(sender);

        let share_meta_data = borrow_global_mut<ShareMetaData>(share_subject);

        let datastorage = borrow_global_mut<DataStorage>(RESOURCE_ACCOUNT);

        assert!(share_meta_data.share_supply > amount,ERROR_CANNOT_SELL_THE_LAST_SHARE);

        let price = get_price(share_meta_data.share_supply - amount, amount);

        let protocol_fee = price * datastorage.protocol_fee_percent / APTOS;

        let subject_fee = price * datastorage.subject_fee_percent / APTOS;

        let share_balance = table::borrow_with_default(&share_meta_data.share_balance,sender_address,&0);

        assert!(*share_balance >= amount, ERROR_INSUFFICIENT_SHARES);

        let share_balance = table::borrow_mut(&mut share_meta_data.share_balance,sender_address);

        *share_balance = *share_balance - amount;

        share_meta_data.share_supply = share_meta_data.share_supply - amount;

        if(protocol_fee > 0){
            //Deposit protocol fees amount to pool
            let protocol_fee_amount = coin::withdraw<AptosCoin>(sender,protocol_fee);
            coin::merge(&mut datastorage.collected_protocol_fees,protocol_fee_amount);
        };

        if(subject_fee > 0){
            //Transfer subject fees to owner
            coin::transfer<AptosCoin>(sender,share_meta_data.share_owner,subject_fee);
        };

        if(price > 0){
            //Transfer price amount to user
            transfer_from_share_resource_account(share_subject,sender_address,price);
        };

        event::emit_event(&mut datastorage.sell_share_event,SellShareEvent{
            share_address:share_subject,
            amount:amount,
            price:price,
            protocol_fee:protocol_fee,
            subject_fee:subject_fee,
        });
        
        assert!(price >= min_out, ERROR_INSUFFICIENT_MIN_OUT_AMOUNT);
    }

    public entry fun claim_token<UID1,UID2>(sender:&signer,share_subject:address)acquires DataStorage,ShareMetaData,ShareTokenCap{

        //check whether subject account already exist or not
        is_share_exist(share_subject);

        let sender_address = signer::address_of(sender);

        let share_meta_data = borrow_global_mut<ShareMetaData>(share_subject);

        //check whether curve is disable or not
        assert!(share_meta_data.is_reached_threshold, ERROR_CLAIMING_IS_NOT_STARTED_YET);

        let share_balance = table::borrow_mut_with_default(&mut share_meta_data.share_balance,sender_address,0);

        assert!(*share_balance > 0, ERROR_INSUFFICIENT_SHARES);

        let share_token_cap = borrow_global<ShareTokenCap<UID1,UID2>>(share_subject);

        let coin_to_mint = (*share_balance * 10) * APTOS;

        let minted_coin = coin::mint<DegenGameCoin<UID1,UID2>>(coin_to_mint,&share_token_cap.mint_capability);

        //register coin if not registered
        register_coin<UID1,UID2>(sender);
        
        coin::deposit<DegenGameCoin<UID1,UID2>>(sender_address,minted_coin);

        *share_balance = 0;

        let datastorage = borrow_global_mut<DataStorage>(RESOURCE_ACCOUNT);

        event::emit_event(&mut datastorage.claim_token_event,ClaimTokenEvent{
            share_address:share_subject,
            sender:sender_address,
            claim_amount:coin_to_mint
        });

    }

    fun buy_share_internal<UID1,UID2>(sender:&signer,share_subject:address,amount:u64):u64 acquires DataStorage,ShareMetaData,ShareTokenCap{

        //register aptos if it's not register
        register_aptos(sender);

        //check whether subject account already exist or not
        is_share_exist(share_subject);

        //check threshold reached or not
        is_threshold_reached(share_subject);

        let sender_address = signer::address_of(sender);

        let share_meta_data = borrow_global_mut<ShareMetaData>(share_subject);

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

        if(protocol_fee > 0){
            //Deposit protocol fees amount to pool
            let protocol_fee_amount = coin::withdraw<AptosCoin>(sender,protocol_fee);
            coin::merge(&mut datastorage.collected_protocol_fees,protocol_fee_amount);
        };

        if(subject_fee > 0){
            //Transfer subject fees to owner
            coin::transfer<AptosCoin>(sender,share_meta_data.share_owner,subject_fee);
        };

        if(price > 0){
            //Deposit price amount to pool
            transfer_to_share_resource_account(sender,share_subject,price);
        };

       
        event::emit_event(&mut datastorage.buy_share_event,BuyShareEvent{
            share_address:share_subject,
            amount:amount,
            price:price,
            protocol_fee:protocol_fee,
            subject_fee:subject_fee,
        });

        //check will threshold reached or not
        check_and_switch_threshold<UID1,UID2>(share_subject);

        price
       
    }

    fun transfer_to_share_resource_account(sender:&signer,share_subject:address,price:u64)acquires ShareMetaData{

        let share_meta_data = borrow_global<ShareMetaData>(share_subject);

        let share_signer = account::create_signer_with_capability(&share_meta_data.signer_cap);

        register_aptos(&share_signer);

        coin::transfer<AptosCoin>(sender,share_subject,price);

    }

    fun transfer_from_share_resource_account(share_subject:address,sender:address,price:u64)acquires ShareMetaData{

        let share_meta_data = borrow_global<ShareMetaData>(share_subject);

        let share_signer = account::create_signer_with_capability(&share_meta_data.signer_cap);

        let share_resource_balance = coin::balance<AptosCoin>(share_subject);
        
        assert!(share_resource_balance >= price, ERROR_INSUFFICIENT_PAYMENT);
        
        coin::transfer<AptosCoin>(&share_signer,sender,price);

    }

    fun check_and_switch_threshold<UID1,UID2>(share_subject:address)acquires DataStorage,ShareMetaData,ShareTokenCap{

        let share_meta_data = borrow_global_mut<ShareMetaData>(share_subject);

        let aptos_balance = coin::balance<AptosCoin>(share_subject);

        //change is_reached_threshold if threshold reached
        if(aptos_balance >= share_meta_data.threshold){
            
            share_meta_data.is_reached_threshold = true;

            let share_signer = account::create_signer_with_capability(&share_meta_data.signer_cap);
                   
            // //Mint 10x of share_supply coin into share resource account
            mint_coin_to_share_resource_account<UID1,UID2>(&share_signer);
            
            //add liquidity to pancake swap
            add_liquidity_to_pancake_swap<UID1,UID2>(&share_signer);
      
        };

    }

    fun create_share_token<UID1,UID2>(share_signer:&signer,token_name:string::String,token_symbol:string::String)acquires DataStorage{

        let datastorage = borrow_global<DataStorage>(RESOURCE_ACCOUNT);

        let resource_signer = account::create_signer_with_capability(&datastorage.signer_cap);
        
        let (burn_cap, freeze_cap, mint_cap) = coin::initialize<DegenGameCoin<UID1,UID2>>(
            &resource_signer,
            token_name,
            token_symbol,
            8,
            true
        );


        move_to<ShareTokenCap<UID1,UID2>>(
            share_signer,
            ShareTokenCap {
                burn_capability:burn_cap,
                freeze_capability:freeze_cap,
                mint_capability:mint_cap
            }
        );
    }

    fun mint_coin_to_share_resource_account<UID1,UID2>(share_signer:&signer)acquires ShareMetaData,ShareTokenCap{

        let share_address = signer::address_of(share_signer);

        let share_meta_data = borrow_global<ShareMetaData>(share_address);

        let share_token_cap = borrow_global<ShareTokenCap<UID1,UID2>>(share_address);

        //Mint 50% of coin to share resource account
        let coins_to_mint = (share_meta_data.share_supply * 10) * APTOS;

        register_coin<UID1,UID2>(share_signer);

        let minted_tokens = coin::mint<DegenGameCoin<UID1,UID2>>(coins_to_mint,&share_token_cap.mint_capability);

        coin::deposit<DegenGameCoin<UID1,UID2>>(share_address,minted_tokens);
    }

    fun add_liquidity_to_pancake_swap<UID1,UID2>(share_signer:&signer)acquires DataStorage,ShareMetaData{

        let share_address = signer::address_of(share_signer);

        let share_meta_data = borrow_global<ShareMetaData>(share_address);

        let coin_x = (share_meta_data.share_supply * 10) * APTOS; 

        let coin_y = coin::balance<AptosCoin>(share_address);

        //Add liquidity to pancake swap
        pancake::router::add_liquidity<DegenGameCoin<UID1,UID2>,AptosCoin>(share_signer,coin_x,coin_y,0,0);

        let datastorage = borrow_global_mut<DataStorage>(RESOURCE_ACCOUNT);

        event::emit_event(&mut datastorage.add_liquidity_to_pancake_event,AddLiquidityToPancakeEvent{
            share_address:share_address,
            coin_x:coin_x,
            coin_y:coin_y
        }); 
    }

    fun is_zero_address(account:address){

        assert!(account != @0x0, ERROR_ZERO_ACCOUNT);
    }

    fun is_owner(sender:&signer)acquires DataStorage{
        let datastorage = borrow_global<DataStorage>(RESOURCE_ACCOUNT);
        assert!(datastorage.owner == signer::address_of(sender), ERROR_NOT_OWNER);
    }

    fun is_protocol_fee_destination(sender:&signer)acquires DataStorage{
        let datastorage = borrow_global<DataStorage>(RESOURCE_ACCOUNT);
        assert!(datastorage.protocol_fee_destination == signer::address_of(sender), ERROR_NOT_PROTOCOL_FEE_DESTINATION);
    }

    fun is_threshold_reached(share_subject:address)acquires ShareMetaData{
        
        let share_meta_data = borrow_global_mut<ShareMetaData>(share_subject);

        //check whether curve is disable or not
        assert!(!share_meta_data.is_reached_threshold, ERROR_CURVE_IS_DISABLE);
    }

    fun is_share_exist(share_subject:address){

         //check whether subject account already exist or not
        assert!(exists<ShareMetaData>(share_subject), ERROR_SHARES_SUBJECT_NOT_EXIST);
    }

    public fun register_aptos(sender:&signer){

        let sender_address = signer::address_of(sender);

        // Auto register aptos
        if (!coin::is_account_registered<AptosCoin>(sender_address)) {
            coin::register<AptosCoin>(sender);
        };
    }

    public fun register_coin<UID1,UID2>(sender:&signer){

        let sender_address = signer::address_of(sender);

        // Auto register aptos
        if (!coin::is_account_registered<DegenGameCoin<UID1,UID2>>(sender_address)) {
            coin::register<DegenGameCoin<UID1,UID2>>(sender);
        };
    }

    fun get_seeds(token_name:string::String):string::String{

        let seeds = string::utf8(b"");

        string::append(&mut seeds,to_string(&@degengame));

        string::append(&mut seeds,token_name);

        seeds
    }

    #[test_only]
    use aptos_framework::managed_coin;

    
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
    public fun degencoin_balance<UID1,UID2>(to:address):u64 {
        coin::balance<DegenGameCoin<UID1,UID2>>(to)
    }

    #[test_only]
    public fun get_data():(address,u64,u64,u64) acquires DataStorage{

        let datastorage = borrow_global<DataStorage>(RESOURCE_ACCOUNT);

        (datastorage.protocol_fee_destination,datastorage.protocol_fee_percent,datastorage.subject_fee_percent,coin::value(&datastorage.collected_protocol_fees))

    }

}