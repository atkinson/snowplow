/*
 * log_events are the raw SnowPlow event logs
 * This is the basis for any cubes (and other data structures) that are used for SnowPlow reports
 * Ad-hoc reports can be run directly off this table 
 *
 */

CREATE TABLE IF NOT EXISTS log_events (
	`dt` date,
	`tm` time,
	`txn_id` int,
	`user_id` varchar(16) comment 'lookup',
	`user_ipaddress` varchar(19) comment 'lookup',
	`visit_id` smallint,
	`page_url` varchar(2083) comment 'lookup',
	`page_title` varchar(2083) comment 'lookup',
	`page_referrer` varchar(2083) comment 'lookup',
	`mkt_source` varchar(255) comment 'lookup',
	`mkt_medium` varchar(255) comment 'lookup',
	`mkt_term` varchar(255) comment 'lookup',
	`mkt_content` varchar(2083) comment 'lookup',
	`mkt_name` varchar(255) comment 'lookup',
	`ev_category` varchar(255) comment 'lookup',
	`ev_action` varchar(255) comment 'lookup',
	`ev_label` varchar(255) comment 'lookup',
	`ev_property` varchar(255) comment 'lookup',
	`ev_value` float,
	`br_name` varchar(30) comment 'lookup',
	`br_family` varchar(30) comment 'lookup',
	`br_version` varchar(30) comment 'lookup',
	`br_type` varchar(30) comment 'lookup',
	`br_renderengine` varchar(30) comment 'lookup',
	`br_lang` varchar(10) comment 'lookup',
	`br_features_pdf` boolean,
	`br_features_flash` boolean,
	`br_features_java` boolean,
	`br_features_director` boolean,
	`br_features_quicktime` boolean,
	`br_features_realplayer` boolean,
	`br_features_windowsmedia` boolean,
	`br_features_gears` boolean,
	`br_features_silverlight` boolean,
	`br_cookies` boolean,
	`os_name` varchar(30) comment 'lookup',
	`os_family` varchar(30) comment 'lookup',
	`os_manufacturer` varchar(30) comment 'lookup',
	`dvce_type` varchar(30) comment 'lookup',
	`dvce_ismobile` boolean,
	`dvce_screenwidth` mediumint,
	`dvce_screenheight` mediumint
) ENGINE=BRIGHTHOUSE DEFAULT CHARSET=utf8;