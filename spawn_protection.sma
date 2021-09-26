    /*
        www.eXtreamCS.com
        
        v1.2 and later official supported by
            CryWolf
        
        v2.3
        - Added Spawn Function from Hamsandwich instead of Event RestHUD
        - Converted player verify function of alive and connected
        - Added cvar for protection time
        - Added cvars for team color
    */
    
    #include < amxmodx >
    #include < engine >
    #include < fakemeta >
    #include < hamsandwich >
    
    
    new const 
        PLUGIN_NAME [ ] = "Spawn Protection",
        PLUGIN_VERSION  [ ] = "2.3";
    
    #pragma semicolon 1
    
    
    new g_Protect       [ 32 ];
    new pCvar_TColor    [ 3 ];
    new pCvar_CtColor   [ 3 ];
    new pCvar_toggle;   
    new pCvar_ProtectTime;  
    
    
public plugin_init ( ) 
{
    register_plugin ( PLUGIN_NAME, PLUGIN_VERSION, "aNNakin" );
    
    register_forward ( FM_PlayerPreThink, "fw_prethink" );
    RegisterHam ( Ham_Spawn, "player", "fwPostSpawn", 1 );
    
    pCvar_toggle      = register_cvar ( "spawn_protection", "1" );
    pCvar_ProtectTime = register_cvar ( "protect_time", "5.0" );    // .0 is not necessary
    
    // Terro colors
    pCvar_TColor [ 0 ] = register_cvar ( "amx_te_rcolor", "255" );
    pCvar_TColor [ 1 ] = register_cvar ( "amx_te_gcolor", "0" );
    pCvar_TColor [ 2 ] = register_cvar ( "amx_te_bcolor", "0" );
    
    // CT Colors
    pCvar_CtColor [ 0 ] = register_cvar ( "amx_ct_rcolor", "0" );
    pCvar_CtColor [ 1 ] = register_cvar ( "amx_ct_gcolor", "0" );
    pCvar_CtColor [ 2 ] = register_cvar ( "amx_ct_bcolor", "255" );
}
 
public client_connect ( id ) {
    g_Protect [ id ] = 0;
}
 
public client_disconnect ( id )
{
    if ( g_Protect [ id ] )
    {
        remove_task ( g_Protect [ id ] );
        g_Protect [ id ] = 0;
    }
}
 
public fwPostSpawn ( id )
{
    if ( g_Protect [ id ] )
        remove_task ( g_Protect [ id ] );
    
    if ( is_user_alive ( id ) )
    {
        set_task ( get_pcvar_float ( pCvar_ProtectTime ), "Remove_Protect", id );
        
        g_Protect [ id ] = id;
        set_pev ( id, pev_takedamage, 0.0 );
        
        switch ( get_user_team ( id ) )
        {
            case 1: {
                set_rendering ( id, kRenderFxGlowShell, get_pcvar_num ( pCvar_TColor [ 0 ] ), get_pcvar_num ( pCvar_TColor [ 1 ] ), get_pcvar_num ( pCvar_TColor [ 2 ] ), kRenderNormal, 20 );
            }
            case 2: {
                set_rendering ( id, kRenderFxGlowShell, get_pcvar_num ( pCvar_CtColor [ 0 ] ), get_pcvar_num ( pCvar_CtColor [ 1 ] ), get_pcvar_num ( pCvar_CtColor [ 2 ] ), kRenderNormal, 20 );
            }
        }
    }
}
 
public Remove_Protect ( id )
{
    g_Protect [ id ] = 0;
    
    if( is_user_alive ( id ) )
    {   
        set_rendering ( id, kRenderFxNone, 0, 0, 0, kRenderNormal, 255 );
        set_pev ( id, pev_takedamage, 2.0 );
    }
}
 
public fw_prethink ( id )
{
    if( !get_pcvar_num ( pCvar_toggle ) || !g_Protect [ id ] || !is_user_alive ( id ) )
        return FMRES_IGNORED;
        
    new button = pev ( id, pev_button );
    if ( ( button & IN_ATTACK) || ( button & IN_ATTACK2 ) )
        Remove_Protect ( id );
        
    return FMRES_IGNORED;
}
