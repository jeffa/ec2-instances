<?php
/**
 * Provision Kabler School For Dogs pages and primary navigation.
 *
 * Run with WP-CLI:
 *   wp --allow-root --path=/var/www/html eval-file provision-kabler.php
 *
 * This script is intentionally safe to rerun. Pages are matched by slug and
 * updated rather than duplicated. The managed navigation menu is rebuilt so
 * its order and nesting remain deterministic.
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit( "This file must run through WP-CLI or WordPress.\n" );
}

$pages = array(
	'home' => array( 'title' => 'Home', 'parent' => '' ),
	'training-courses' => array( 'title' => 'Training Courses', 'parent' => '' ),
	'puppies' => array( 'title' => 'Puppy Preschool', 'parent' => 'training-courses' ),
	'training' => array( 'title' => 'Private & Day Train Courses', 'parent' => 'training-courses' ),
	'residency' => array( 'title' => 'Residency Board & Train', 'parent' => 'training-courses' ),
	'swimming' => array( 'title' => 'Swimming & Dock Diving', 'parent' => 'training-courses' ),
	'schedule' => array( 'title' => 'Scheduling', 'parent' => '' ),
	'locations' => array( 'title' => 'Locations', 'parent' => '' ),
	'asheville-nc' => array( 'title' => 'Asheville, NC', 'parent' => 'locations' ),
	'columbia-sc' => array( 'title' => 'Columbia, SC', 'parent' => 'locations' ),
	'about' => array( 'title' => 'About', 'parent' => '' ),
	'staff-bios' => array( 'title' => 'Meet Our Trainers', 'parent' => 'about' ),
	'training-philosophy' => array( 'title' => 'Training Philosophy', 'parent' => 'about' ),
	'testimonials' => array( 'title' => 'Testimonials', 'parent' => 'about' ),
	'message-from-david' => array( 'title' => 'Message From David', 'parent' => 'about' ),
	'careers' => array( 'title' => 'Careers', 'parent' => '' ),
	'contact' => array( 'title' => 'Contact', 'parent' => '' ),
	'blog' => array( 'title' => 'Blog', 'parent' => '' ),
);

$page_ids = array();

foreach ( $pages as $slug => $page ) {
	$existing = get_posts(
		array(
			'post_type'      => 'page',
			'post_status'    => 'any',
			'name'           => $slug,
			'posts_per_page' => 1,
			'fields'         => 'ids',
		)
	);

	$parent_id = 0;
	if ( $page['parent'] && isset( $page_ids[ $page['parent'] ] ) ) {
		$parent_id = $page_ids[ $page['parent'] ];
	}

	$postarr = array(
		'post_title'  => $page['title'],
		'post_name'   => $slug,
		'post_status' => 'publish',
		'post_type'   => 'page',
		'post_parent' => $parent_id,
	);

	if ( ! empty( $existing ) ) {
		$postarr['ID'] = (int) $existing[0];
		$page_id       = wp_update_post( wp_slash( $postarr ), true );
		$action        = 'updated';
	} else {
		$page_id = wp_insert_post( wp_slash( $postarr ), true );
		$action  = 'created';
	}

	if ( is_wp_error( $page_id ) ) {
		WP_CLI::error( sprintf( 'Could not %s page %s: %s', $action, $slug, $page_id->get_error_message() ) );
	}

	$page_ids[ $slug ] = (int) $page_id;
	WP_CLI::log( sprintf( '%s page: %s (%d)', ucfirst( $action ), $page['title'], $page_id ) );
}

$menu_name = 'Kabler Primary Navigation';
$menu      = wp_get_nav_menu_object( $menu_name );
$menu_id   = $menu ? (int) $menu->term_id : wp_create_nav_menu( $menu_name );

if ( is_wp_error( $menu_id ) ) {
	WP_CLI::error( 'Could not create the primary navigation menu.' );
}

// Rebuild only this managed menu, leaving other menus untouched.
$menu_items = wp_get_nav_menu_items( $menu_id );
foreach ( (array) $menu_items as $menu_item ) {
	wp_delete_post( $menu_item->ID, true );
}

$menu_structure = array(
	'Home' => array( 'slug' => 'home' ),
	'Training Courses' => array(
		'slug'     => 'training-courses',
		'children' => array(
			'Puppy Preschool' => 'puppies',
			'Private & Day Train Courses' => 'training',
			'Residency Board & Train' => 'residency',
			'Swimming & Dock Diving' => 'swimming',
		),
	),
	'Scheduling' => array( 'slug' => 'schedule' ),
	'Locations' => array(
		'slug'     => 'locations',
		'children' => array(
			'Asheville, NC' => 'asheville-nc',
			'Columbia, SC' => 'columbia-sc',
		),
	),
	'About' => array(
		'slug'     => 'about',
		'children' => array(
			'Meet Our Trainers' => 'staff-bios',
			'Training Philosophy' => 'training-philosophy',
			'Testimonials' => 'testimonials',
			'Message From David' => 'message-from-david',
		),
	),
	'Careers' => array( 'slug' => 'careers' ),
	'Contact' => array( 'slug' => 'contact' ),
	'Blog' => array( 'slug' => 'blog' ),
);

foreach ( $menu_structure as $label => $item ) {
	$parent_menu_id = wp_update_nav_menu_item(
		$menu_id,
		0,
		array(
			'menu-item-title'     => $label,
			'menu-item-object'    => 'page',
			'menu-item-object-id' => $page_ids[ $item['slug'] ],
			'menu-item-type'      => 'post_type',
			'menu-item-status'    => 'publish',
		)
	);

	if ( is_wp_error( $parent_menu_id ) ) {
		WP_CLI::error( sprintf( 'Could not add menu item: %s', $label ) );
	}

	if ( ! empty( $item['children'] ) ) {
		foreach ( $item['children'] as $child_label => $child_slug ) {
			$child_menu_id = wp_update_nav_menu_item(
				$menu_id,
				0,
				array(
					'menu-item-title'      => $child_label,
					'menu-item-object'     => 'page',
					'menu-item-object-id'  => $page_ids[ $child_slug ],
					'menu-item-type'       => 'post_type',
					'menu-item-parent-id'  => $parent_menu_id,
					'menu-item-status'     => 'publish',
				)
			);

			if ( is_wp_error( $child_menu_id ) ) {
				WP_CLI::error( sprintf( 'Could not add submenu item: %s', $child_label ) );
			}
		}
	}
}

$locations = get_registered_nav_menus();
if ( isset( $locations['primary'] ) ) {
	$theme_locations           = get_theme_mod( 'nav_menu_locations', array() );
	$theme_locations['primary'] = $menu_id;
	set_theme_mod( 'nav_menu_locations', $theme_locations );
}

update_option( 'show_on_front', 'page' );
update_option( 'page_on_front', $page_ids['home'] );

WP_CLI::success( sprintf( 'Provisioned %d pages and rebuilt the %s menu.', count( $page_ids ), $menu_name ) );
