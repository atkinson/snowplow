/*
 * Data for customers cube used in OLAP applications
 * This table is derived from the original log_events table
 * In the event that any customer definitions change, the structure and / or contents
 * of this table may need to be recalculated from the event_logs table 
 * Note: each line of data represents 1 visit
 */

# -----------------------------------------
# 	TABLE DEFINITION
# -----------------------------------------

CREATE TABLE IF NOT EXISTS customers_cube (
# Dimensions
	# Dimensions related to the customer
		`user_id` varchar(16) comment 'lookup',
		`first_visit_date` date,
		`email_address` varchar(30),
		`country` varchar(30),
	# Dimensions related to the visit
		# Descriptions of visit
			`visit_unique_id` varchar(25)
			`visit_counter` int,
			`stage_in_purchase_funnel_reached` ENUM('1. Add-to-basket', '2. Checkout', '3. Enter email', '4. Paypal', '5. Buy')
		# Marketing related metrics (i.e. referrer)
			/*
			 * Proposed model for incoming traffic fields (based on Google Analytics, subject to revision):
			 * 	mkt_medium is highest level: defines the type of marketing (organic, cpc, referrer, affiliate / cpa, cpm, email, lead-gen)
			 * 		-> note: for non-paid traffic we need to disinguish search (organic), social (social) and referrer (all others)
			 *  mkt_source is where the traffic came from (i.e. differentiate different organic by what search engine, different cpc by provider)
			 * 		-> note: for non-paid traffic
			 *  mkt_term is keywords (for search) - differentiate people from same source / medium
			 *  mkt_content is creative_id (e.g. email id, banner id, adwords text)
			 *
			 * mkt_campaign is orthogonal to the above: possible that one campaign spans many sources / mediums / keywords and creatives
			 * New fields added by SnowPlow:
			 * mkt_paid (some sources will be paid and others not, but having a dedicated field should make analysis easier)
			 * mkt_rank (for search - whether the paid ad was top ranked, or result was top rated)
			 * mkt_page (for search, what page on results)
			 */
				`mkt_source` varchar(255) comment 'lookup',
				`mkt_medium` varchar(255) comment 'lookup',
				`mkt_campaign` varchar(255) comment 'lookup',
				`mkt_term` varchar(255) comment 'lookup',
				`mkt_content` varchar(255) comment 'lookup',
				`mkt_paid` boolean,
				`mkt_rank` int,
				`mkt_page` int,
		# Description of technology used (IP address, device, browser, operating system)
			# Device
				`dvce_ismobile` boolean,
				`dvce_type` varchar(30) comment 'lookup',	
				`dvce_screenwidth` mediumint,
				`dvce_screenheight` mediumint,		
			# Operating system
				`os_name` varchar(30) comment 'lookup',
				`os_family` varchar(30) comment 'lookup',
				`os_manufacturer` varchar(30) comment 'lookup',
			# Browser		
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


# Metrics
	# Metrics for each visit
		`page_views` int,
		`unique_pages_per_visit` int,
		`actions` int,
		`product_pages_visited` int,
		`unique_product_pages_visited` int,
		`add_to_baskets` int,
		`value_of_goods_added_to_basket` float,
		`revenue` float

) ENGINE=BRIGHTHOUSE DEFAULT CHARSET=utf8;

# -----------------------------------------
# 	ETL from log_events
# -----------------------------------------

SELECT
	# DIMENSIONS
		# Dimensions related to the customer
			user_id,
			MIN(dt) AS first_visit_date,
			NULL AS email_address, # TO WRITE: base on ev_value WHERE ev_action = 'enter_email'  
			NULL AS country, # TO WRITE: base on Maxmind lookup
		# Dimensions related to the visit
			# Descriptions of visit		
				CONCAT(user_id, "-", visit_id) AS visit_unique_id,
				visit_id AS visit_counter,
				NULL AS stage_in_purchase_funnel_reached, # TO WRITE: base on parsing ev_action fields and page_url fields for a particular visit
			# Marketing related metrics (i.e. referrer)
				NULL AS mkt_source, # TO WRITE: base on values for first line of data in logs for each visit
				NULL AS mkt_medium, 
				NULL AS mkt_campaign,
				NULL as mkt_term,
				NULL AS mkt_content,
				NULL AS mkt_rank,
				NULL AS mkt_page,
			# Description of technology used (IP address, device, browser, operating system)
				# Device
					MAX(dvce_ismobile) AS dvce_ismobile,
					MAX(dvce_type) AS dvce_type,
					MAX(dvce_screenwidth) AS dvce_screenwidth,
					MAX(dvce_screenheight) AS dvce_screenheight,			
				# Operating system
					MAX(os_name) AS os_name,
					MAX(os_family) AS os_family,
					MAX(os_manufacturer) AS os_manufacturer,
				# Browser
					MAX(br_name) AS br_name,
					MAX(br_family) AS br_family,
					MAX(br_version) AS br_version,
					MAX(br_type) AS br_type,
					MAX(br_renderengine) AS br_renderengine,
					MAX(br_lang) AS br_lang,
					MAX(br_features_pdf) AS br_features_pdf,
					MAX(br_features_flash) AS br_features_flash,
					MAX(br_features_java) AS br_features_java,
					MAX(br_features_director) AS br_featurse_director,
					MAX(br_features_quicktime) AS br_features_quicktime,
					MAX(br_features_realplayer) AS br_features_realplayer,
					MAX(br_features_windowsmedia) AS br_features_windowsmedia,
					MAX(br_features_gears) AS br_features_gears,
					MAX(br_features_silverlight) AS br_features_silverlight,
	# METRICS
		NULL AS page_views # need to count all rows WHERE page_url IS NOT NULL
		COUNT(*) AS actions,
		COUNT(DISTINCT(page_url)) - 1 as unique_pages_per_visit,
		NULL as of_add_to_baskets, # based on COUNT where ev_action = add-to-basket
		NULL as value_of_goods_added_to_basket, # base on sum of ev_value where ev_action = 'add-to-basket' - sum of ev_value where ev_action = 'remove_from_basket'
		NULL as revenue # base on sum of ev_value where ev_action = 'order-confirmation'
		


FROM log_events
GROUP BY user_id, visit_id