#!/usr/bin/bash

LATEST_PATCH=31463803
SEARCH="https://updates.oracle.com/Orion/SimpleSearch/process_form?search_type=prod&product=17450&product_disp=Solaris+Operating+System+%28solaris%29&product_any=Select+a+Product+or+Product+Family&product_none=&product_auto=on&release=400000110000&release_any=Select+a+Release&release_none=&release_auto=on&patch_type=all&priority=any&plat_lang=23P&display_type=&search_style=8&orderby=&direction=&old_type_list=&gobuttonpressed=&sortcolpressed=&tab_number=&email=martel.meyers%40cgi.com&userid=o-martel.meyers%40cgi.com&c_release_parent=product&c_product_child=release"
PATCH="https://updates.oracle.com/Orion/PatchDetails/process_form?patch_num=31463803&aru=23688499&release=400000110000&plat_lang=23P&patch_num_id=3722325&"

housekeep() {
    sudo su - root
    yum update

}

solpatchcheck() {
    BASE_STR="https://updates.oracle.com/Orion/SimpleSearch/process_form"
    ?search_type=prod
    &product=17450
    &product_disp=Solaris+Operating+System+%28solaris%29
    &product_any=Select+a+Product+or+Product+Family
    &product_none=
    &product_auto=on
    &release=400000110000
    &release_any=Select+a+Release&release_none=
    &release_auto=on
    &patch_type=all
    &priority=any
    &plat_lang=23P
    &display_type=
    &search_style=8
    &orderby=
    &direction=
    &old_type_list=
    &gobuttonpressed=
    &sortcolpressed=
    &tab_number=
    &email=martel.meyers%40cgi.com
    &userid=o-martel.meyers%40cgi.com
    &c_release_parent=product
    &c_product_child=release
}

solpatchfetch() {
    BASE_STR="https://updates.oracle.com/Orion/PatchDetails/process_form"
    PATCH_STR="?patch_num=31463803"
    ARU_STR="&aru=23688499"
    RELEASE_STR="&release=400000110000"
    PLATFORM_STR="&plat_lang=23P"
    PATCH_ID="&patch_num_id=3722325"
}

man curl
man wget