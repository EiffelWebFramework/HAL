note
	description: "Resources have their own state, links, and embedded resources (which are resources in their own right)"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	HAL_RESOURCE

create
	make,
	make_with_link
--	make_with_link_resources,
--	make_with_link_resources_properties

feature {NONE} -- Initialization
	make
		do
			create links.make (10)
			links.compare_objects
		end

	make_with_link ( a_link : HAL_LINK )
		-- Create a new resource with his self.link
		do
			make
			add_link ("self", a_link)
		end

feature -- Access

	self : detachable HAL_LINK
			-- Return the self link
			--For example if you have the following JSON representation
			--
			--					"_links": {
			--		    "self": { "href": "/orders" },
			--		    "next": { "href": "/orders?page=2" },
			--		    "search": { "href": "/orders?id={order_id}" }
			--		  }
			-- you will get an object equivalent to the following JSON fragment
			-- 			"self": { "href": "/orders" },
			--
 		require
 				valid: is_valid_resource
 		do
 			Result := links.at ("self")
 		ensure
 				valid: Result /= Void
 		end

 	links_keys : ARRAY[STRING]
 			-- Return an array of keys, ie rel attributes
 			--For example if you have the following JSON representation
			--
			--					"_links": {
			--		    "self": { "href": "/orders" },
			--		    "next": { "href": "/orders?page=2" },
			--		    "search": { "href": "/orders?id={order_id}" }
			--		  }
			-- you will get an ARRAY witht he following keys
			-- 			"self","next","search"
			--
 		do
 			Result := links.current_keys
 		end

 	links_by_key ( a_key : STRING) : detachable HAL_LINK
 			-- Retrieve a link given a `a_key', ie a rel attribute if it exist,
 			-- Void in othercase
 			--For example if you have the following JSON representation
			--
			--					"_links": {
			--		    "self": { "href": "/orders" },
			--		    "next": { "href": "/orders?page=2" },
			--		    "search": { "href": "/orders?id={order_id}" }
			--		  }
			-- you will get a LINK if a_key is one of the following values
			-- 			"self","next","search"
			-- Void in other case
 		do
 			Result := links.at (a_key)
 		end

 	embedded_resources_keys : detachable ARRAY[STRING]
 			-- Retrieve an arrray of resource keys, if exist,
 			-- Void in othercase
 		do
 			if attached embedded_resource as er then
 				Result := er.current_keys
 			end
 		end

 	embedded_resources_by_key (a_key : STRING) : detachable LIST[HAL_RESOURCE]
 			-- Return a list embedded resources if it exist or Void in other case
 		do
 			if attached embedded_resource as er then
 				Result := er.at (a_key)
 			end
 		end

 	properties_keys : detachable ARRAY[STRING]
 			-- Return an array of properties keys if exist,
 			-- Void in othercase
 		do
			if attached properties as p then
				Result := p.current_keys
			end
 		end


 	properties_by_key  (a_key:STRING): detachable STRING
 			-- Return an array of properties keys if exist,
 			-- Void in othercase
 		do
			if attached properties as p then
				Result := p.at (a_key)
			end
 		end

feature -- Element Change
	add_all_link ( all_link : HASH_TABLE[HAL_LINK,STRING])
		do
			links.copy (all_link)
		end

	add_link ( a_key: STRING; a_link : HAL_LINK)
			-- add an (a_key,a_link) pair
		do
			links.force (a_link, a_key)
		end

	add_properties (key : STRING; value : STRING)
		do
			if attached properties as l_prop then
				l_prop.force (value, key)
			else
				create properties.make (5)
				if attached properties as l_prop then
					l_prop.force (value, key)
				end
			end
		end

	add_embedded (key: STRING; resources: LIST[HAL_RESOURCE])
		do
			if attached embedded_resource as er then
				er.force (resources, key)
			else
				create embedded_resource.make (10)
				if attached  embedded_resource as er2 then
					er2.force (resources, key)
				end

			end
		end


feature -- Status Report
	is_valid_resource : BOOLEAN
			-- Does this resource contains a self link?
		do
			Result := links.has_key ("self")
		end


feature {JSON_HAL_RESOURCE_CONVERTER}-- Implementation
	links : HASH_TABLE[HAL_LINK,STRING]
	embedded_resource : detachable HASH_TABLE[LIST[HAL_RESOURCE],STRING]
	properties : detachable HASH_TABLE[STRING,STRING]

end

